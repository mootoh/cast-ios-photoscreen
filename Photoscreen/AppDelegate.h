//
//  AppDelegate.h
//  Photoscreen
//
//  Created by Motohiro Takayama on 8/5/13.
//  Copyright (c) 2013 Motohiro Takayama. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kHTTPD_PORT 1978

@class CastSender;
@class HTTPServer;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) CastSender *sender;
@property (strong, nonatomic) HTTPServer *httpd;

- (NSString *) cacheURL;

@end