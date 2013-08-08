//
//  CastSender.m
//  Photoscreen
//
//  Created by Motohiro Takayama on 8/7/13.
//  Copyright (c) 2013 Motohiro Takayama. All rights reserved.
//

#import <ifaddrs.h>
#import <arpa/inet.h>
#import "CastSender.h"
#import "AppDelegate.h"

static NSString * const kUserAgent = @"net.mootoh.cast.photoscreen";
static NSString * const kProtocol = @"net.mootoh.cast.photoscreen";
static NSString * const kAPP_ID = @"4ae9614b-5792-4ab3-97e5-cf69ea69f7cc";
@implementation CastSender

- (id) init
{
    self = [super init];
    if (self) {
        self.context = [[GCKContext alloc] initWithUserAgent:kUserAgent];
        self.deviceManager = [[GCKDeviceManager alloc] initWithContext:self.context];

        [self.deviceManager addListener:self];
        [self.deviceManager startScan];

    }
    return self;
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
    [self.session startSessionWithApplication:kAPP_ID];
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

- (void) sendMessage:(NSDictionary *)message
{
    [self.stream sendMessage:message];
}

@end