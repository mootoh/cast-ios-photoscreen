//
//  ViewController.h
//  Photoscreen
//
//  Created by Motohiro Takayama on 8/5/13.
//  Copyright (c) 2013 Motohiro Takayama. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GCKFramework/GCKFramework.h>

@class GCKContext;
@class GCKDevice;
@class GCKDeviceManager;

@interface ViewController : UIViewController <GCKDeviceManagerListener>

@property (nonatomic, strong, readwrite) GCKContext *context;
@property (nonatomic, strong) GCKDeviceManager *deviceManager;
@property (nonatomic, strong) GCKDevice *device;
@property (nonatomic, strong) NSMutableArray *devices;

@end
