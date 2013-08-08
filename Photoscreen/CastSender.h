//
//  CastSender.h
//  Photoscreen
//
//  Created by Motohiro Takayama on 8/7/13.
//  Copyright (c) 2013 Motohiro Takayama. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GCKFramework/GCKFramework.h>
#import "PhotoScreenMessageStream.h"

@interface CastSender : NSObject <GCKDeviceManagerListener, GCKApplicationSessionDelegate>

@property (nonatomic, strong, readwrite) GCKContext *context;
@property (nonatomic, strong) GCKDeviceManager *deviceManager;
@property (nonatomic, strong) GCKDevice *device;
@property (nonatomic, strong) NSMutableArray *devices;
@property (nonatomic, strong) GCKApplicationSession *session;
@property (nonatomic, strong) PhotoScreenMessageStream *stream;

- (void) sendMessage:(NSDictionary *)message;

@end