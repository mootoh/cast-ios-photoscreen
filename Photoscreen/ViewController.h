//
//  ViewController.h
//  Photoscreen
//
//  Created by Motohiro Takayama on 8/5/13.
//  Copyright (c) 2013 Motohiro Takayama. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GCKFramework/GCKFramework.h>
#import "PhotoScreenMessageStream.h"

@class GCKContext;
@class GCKDevice;
@class GCKDeviceManager;

@class ALAssetsLibrary;
@class HTTPServer;

@interface ViewController : UIViewController <GCKDeviceManagerListener, GCKApplicationSessionDelegate>

@property (nonatomic, strong, readwrite) GCKContext *context;
@property (nonatomic, strong) GCKDeviceManager *deviceManager;
@property (nonatomic, strong) GCKDevice *device;
@property (nonatomic, strong) NSMutableArray *devices;
@property (nonatomic, strong) GCKApplicationSession *session;
@property (nonatomic, strong) PhotoScreenMessageStream *stream;

@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, strong) NSMutableArray *assetsGroups;
@property (nonatomic, strong) NSMutableArray *assets;
@property (nonatomic) NSInteger currentAsset;

@property (nonatomic, strong) HTTPServer *httpd;

- (IBAction)showPhoto:(id)sender;

@end
