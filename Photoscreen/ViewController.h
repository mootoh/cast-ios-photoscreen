//
//  ViewController.h
//  Photoscreen
//
//  Created by Motohiro Takayama on 8/5/13.
//  Copyright (c) 2013 Motohiro Takayama. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ALAssetsLibrary;

@interface ViewController : UIViewController

@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, strong) NSMutableArray *assetsGroups;
@property (nonatomic, strong) NSMutableArray *assets;
@property (nonatomic) NSInteger currentAsset;

- (IBAction)showPhoto:(id)sender;

@end
