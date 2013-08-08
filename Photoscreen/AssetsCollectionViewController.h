//
//  AssetsCollectionViewController.h
//  Photoscreen
//
//  Created by Motohiro Takayama on 8/7/13.
//  Copyright (c) 2013 Motohiro Takayama. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ALAssetsGroup;

@interface AssetsCollectionViewController : UICollectionViewController

@property (nonatomic, strong) ALAssetsGroup *group;
@property (nonatomic, strong) NSMutableArray *assets;

@end