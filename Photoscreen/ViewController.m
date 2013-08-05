//
//  ViewController.m
//  Photoscreen
//
//  Created by Motohiro Takayama on 8/5/13.
//  Copyright (c) 2013 Motohiro Takayama. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

static NSString * const kUserAgent = @"net.mootoh.cast.photoscreen";

@interface ViewController ()
@end

@implementation ViewController

- (void) setupCastSender
{
    self.context = [[GCKContext alloc] initWithUserAgent:kUserAgent];
    self.deviceManager = [[GCKDeviceManager alloc] initWithContext:self.context];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupCastSender];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.deviceManager addListener:self];
    [self.deviceManager startScan];
}

- (void) scanStarted
{
    NSLog(@"scan started");
}

- (void) scanStopped
{
    NSLog(@"scan stopped");
}

// Adds a device to the list when it comes online.
- (void) deviceDidComeOnline:(GCKDevice *)device {
    NSLog(@"device IP : %@", device.ipAddress);
    [self.devices addObject:device];
    if (self.devices.count == 1)
        self.device = device;
}

// Remove a device from the display list when it goes offline.
- (void)deviceDidGoOffline:(GCKDevice *)device {
    NSLog(@"mDeviceDidGoOffLine  %@" , device.friendlyName);
}

@end
