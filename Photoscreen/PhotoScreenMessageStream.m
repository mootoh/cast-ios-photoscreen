//
//  PhotoScreenMessageStream.m
//  Photoscreen
//
//  Created by Motohiro Takayama on 8/5/13.
//  Copyright (c) 2013 Motohiro Takayama. All rights reserved.
//

#import "PhotoScreenMessageStream.h"

@implementation PhotoScreenMessageStream

- (void) didReceiveMessage:(id)message
{
    [super didReceiveMessage:message];
    NSLog(@"PhotoScreenMessageStream: didReceiveMessage: %@", message);
}

@end