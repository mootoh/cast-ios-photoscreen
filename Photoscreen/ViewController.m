//
//  ViewController.m
//  Photoscreen
//
//  Created by Motohiro Takayama on 8/5/13.
//  Copyright (c) 2013 Motohiro Takayama. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "ViewController.h"
#import "AppDelegate.h"
#import "CastSender.h"

#define TENTATIVE 1

@interface ViewController ()
@end

@implementation ViewController

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
    AppDelegate *ad = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSString *filePath = [[ad cacheURL] stringByAppendingPathComponent:filename];
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

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.currentAsset = 0;
    [self setupAssetsLibrary];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (IBAction)showPhoto:(id)sender
{
    ALAsset *asset = self.assets[self.currentAsset++];
    if (self.currentAsset >= self.assets.count)
        self.currentAsset = 0;

    NSDictionary *message = @{@"command": @"show", @"image_id": [self assetID:asset]};
    AppDelegate *ad = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [ad.sender sendMessage:message];
}

@end