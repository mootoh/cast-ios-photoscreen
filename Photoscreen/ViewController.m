//
//  ViewController.m
//  Photoscreen
//
//  Created by Motohiro Takayama on 8/5/13.
//  Copyright (c) 2013 Motohiro Takayama. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "PhotoScreenMessageStream.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "HTTPServer.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
#import "DDLog.h"
#import "DDTTYLogger.h"

#define TENTATIVE 1

static NSString * const kUserAgent = @"net.mootoh.cast.photoscreen";
static NSString * const kProtocol = @"net.mootoh.cast.photoscreen";
static const NSInteger kHTTPD_PORT = 1978;

@interface ViewController ()
@end

@implementation ViewController

- (NSString *) cacheURL
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *dirs = [fm URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask];
    NSURL *cacheURL = dirs[0];

    return [cacheURL relativePath];
}

#pragma mark - HTTPd
- (void) startServer
{
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    self.httpd = [[HTTPServer alloc] init];
	[self.httpd setType:@"_http._tcp."];
    [self.httpd setPort:kHTTPD_PORT];
    [self.httpd setDocumentRoot:[self cacheURL]];
    
	NSError *error;
	if([self.httpd start:&error])
	{
		NSLog(@"Started HTTP Server on port %hu", [self.httpd listeningPort]);
	}
	else
	{
		NSLog(@"Error starting HTTP Server: %@", error);
	}
}

#pragma mark - AssetsLibrary

- (NSString *) assetID:(ALAsset *)asset
{
    NSLog(@"asset url : %@", [asset valueForProperty:ALAssetPropertyAssetURL]);
    NSString *assetURL = [[asset valueForProperty:ALAssetPropertyAssetURL] absoluteString];
    NSRange id_is = [assetURL rangeOfString:@"id="];
    NSRange ext_is = [assetURL rangeOfString:@"&ext="];
    NSRange range = { id_is.location + 3, ext_is.location - id_is.location - 3 };
    return [assetURL substringWithRange:range];
}

- (void) saveAsJPEG:(ALAsset *)asset
{
    NSLog(@"asset url : %@", [asset valueForProperty:ALAssetPropertyAssetURL]);
    NSString *assetURL = [[asset valueForProperty:ALAssetPropertyAssetURL] absoluteString];
    NSRange id_is = [assetURL rangeOfString:@"id="];
    NSRange ext_is = [assetURL rangeOfString:@"&ext="];
    NSRange range = { id_is.location + 3, ext_is.location - id_is.location - 3 };
    NSString *assetID = [assetURL substringWithRange:range];
    NSRange extRange = { ext_is.location + 5, 3 };
    NSString *ext = [[assetURL substringWithRange:extRange] lowercaseString];
    NSString *filename = [NSString stringWithFormat:@"%@.%@", assetID, @"jpg"];
    
    if ([ext isEqualToString:@"jpg"]) {
        NSLog(@"JPEG!");
    } else if ([ext isEqualToString:@"raw"]) {
        NSLog(@"RAW!");
    } else {
        NSLog(@"ext not expected: ");
    }
    
    NSLog(@"assetID = %@", assetID);
    ALAssetRepresentation *assetRepresentation = [asset defaultRepresentation];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *filePath = [[self cacheURL] stringByAppendingPathComponent:filename];
    if ([fm fileExistsAtPath:filePath]) {
        NSLog(@"already exists. skip %@", filePath);
        return;
    }
    NSLog(@"%@ not exists, writing...", filePath);

    UIImage *fullResolutionImage = [UIImage imageWithCGImage:[assetRepresentation fullResolutionImage] scale:[assetRepresentation scale] orientation:(UIImageOrientation)[assetRepresentation orientation]];
    
//    UIImage *fullScreenImage = [UIImage imageWithCGImage:[assetRepresentation fullScreenImage] scale:[assetRepresentation scale] orientation:(UIImageOrientation)[assetRepresentation orientation]];
//    
    NSData *jpegData = UIImageJPEGRepresentation(fullResolutionImage, 1.0);
    if ([fm createFileAtPath:filePath contents:jpegData attributes:nil]) {
        NSLog(@"file written: %@", filePath);
    } else {
        NSLog(@"failed in write: %@", filePath);
    }
}

- (void) collectAssets:(ALAssetsGroup *)group
{
    ALAssetsGroupEnumerationResultsBlock assetsEnumerationBlock = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
        NSLog(@"asset : %@", result);
        if (result) {
            [self.assets addObject:result];
            [self performSelectorInBackground:@selector(saveAsJPEG:) withObject:result];
        }
#ifdef TENTATIVE
        if (self.assets.count > 8)
            *stop = YES;
#endif // TENTATIVE
    };

    ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allPhotos];
    [group setAssetsFilter:onlyPhotosFilter];
    [group enumerateAssetsUsingBlock:assetsEnumerationBlock];
}

    - (void) setupAssetsLibrary
{
    self.assetsLibrary = [[ALAssetsLibrary alloc] init];
    self.assetsGroups = [NSMutableArray array];
    self.assets = [NSMutableArray array];
    
    ALAssetsLibraryGroupsEnumerationResultsBlock listGroupBlock = ^(ALAssetsGroup *group, BOOL *stop) {
        NSLog(@"group found: %@", group);
        if (group) {
#ifdef TENTATIVE
            if (group.numberOfAssets == 9) {
                [self collectAssets:group];
                *stop = YES;
            }
#endif // TENTATIVE
        }
    };
    
    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {
        NSLog(@"error in accessing AssetsLibrary: %@", error);
    };
    
    NSUInteger groupTypes = ALAssetsGroupAlbum | ALAssetsGroupEvent;
    [self.assetsLibrary enumerateGroupsWithTypes:groupTypes usingBlock:listGroupBlock failureBlock:failureBlock];
    
}

- (void) setupCastSender
{
    self.context = [[GCKContext alloc] initWithUserAgent:kUserAgent];
    self.deviceManager = [[GCKDeviceManager alloc] initWithContext:self.context];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self startServer];
    self.currentAsset = 0;
    [self setupAssetsLibrary];
    [self setupCastSender];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.deviceManager addListener:self];
    [self.deviceManager startScan];
}

#pragma mark - GCKDeviceManagerListener

- (void) scanStarted
{
    NSLog(@"scan started");
}

- (void) scanStopped
{
    NSLog(@"scan stopped");
}

- (void) startSession
{
    NSLog(@"Starting session.");

    self.session = [[GCKApplicationSession alloc] initWithContext:self.context device:self.device];
    self.session.delegate = self;
    [self.session startSessionWithApplication:@"4ae9614b-5792-4ab3-97e5-cf69ea69f7cc"];
}

// Adds a device to the list when it comes online.
- (void) deviceDidComeOnline:(GCKDevice *)device {
    NSLog(@"device IP : %@", device.ipAddress);
    if (self.deviceManager.devices.count == 1) { // use the first found device
        self.device = device;
        [self startSession];
    }
}

// Remove a device from the display list when it goes offline.
- (void)deviceDidGoOffline:(GCKDevice *)device {
    NSLog(@"mDeviceDidGoOffLine  %@" , device.friendlyName);
    if (device == self.device)
        self.device = nil;
}

#pragma mark - GCKApplicationSessionDelegate

// http://stackoverflow.com/questions/7072989/iphone-ipad-how-to-get-my-ip-address-programmatically
- (NSString *)getIPAddress
{
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    NSString *wifiAddress = nil;
    NSString *cellAddress = nil;
    
    // retrieve the current interfaces - returns 0 on success
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            sa_family_t sa_type = temp_addr->ifa_addr->sa_family;
            if(sa_type == AF_INET || sa_type == AF_INET6) {
                NSString *name = [NSString stringWithUTF8String:temp_addr->ifa_name];
                NSString *addr = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)]; // pdp_ip0
                NSLog(@"NAME: \"%@\" addr: %@", name, addr); // see for yourself
                
                if([name isEqualToString:@"en0"]) {
                    // Interface is the wifi connection on the iPhone
                    wifiAddress = addr;
                } else
                    if([name isEqualToString:@"pdp_ip0"]) {
                        // Interface is the cell connection on the iPhone
                        cellAddress = addr;
                    }
            }
            temp_addr = temp_addr->ifa_next;
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    NSString *addr = wifiAddress ? wifiAddress : cellAddress;
    return addr ? addr : @"0.0.0.0";
}

- (void) applicationSessionDidStart
{
    NSLog(@"Application session started");
    GCKApplicationChannel *channel = self.session.channel;
    self.stream = [[PhotoScreenMessageStream alloc] initWithNamespace:kProtocol];
    [channel attachMessageStream:self.stream];

    NSDictionary *message = @{@"command": @"sender_info", @"ip_address": [self getIPAddress], @"port": [NSNumber numberWithInteger:kHTTPD_PORT]};
    [self.stream sendMessage:message];

}


- (void) applicationSessionDidFailToStartWithError:(GCKApplicationSessionError *)error
{
    NSLog(@"applicationSessionDidFailToStartWithError: %@", error);
}

- (void) applicationSessionDidEndWithError:(GCKApplicationSessionError *)error
{
    NSLog(@"applicationSessionDidEndWithError: %@", error);
}

- (IBAction)showPhoto:(id)sender
{
    ALAsset *asset = self.assets[self.currentAsset++];
    if (self.currentAsset >= self.assets.count)
        self.currentAsset = 0;

    NSDictionary *message = @{@"command": @"show", @"image_id": [self assetID:asset]};
    [self.stream sendMessage:message];
}

@end