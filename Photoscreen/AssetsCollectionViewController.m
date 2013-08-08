//
//  AssetsCollectionViewController.m
//  Photoscreen
//
//  Created by Motohiro Takayama on 8/7/13.
//  Copyright (c) 2013 Motohiro Takayama. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "AssetsCollectionViewController.h"
#import "AppDelegate.h"
#import "CastSender.h"

@implementation AssetsCollectionViewController

- (void)showPhoto:(ALAsset *)asset
{
    NSDictionary *message = @{@"command": @"show", @"image_id": [self assetID:asset]};
    AppDelegate *ad = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [ad.sender sendMessage:message];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.assets = [NSMutableArray array];
    [self collectAssets:self.group];
}

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
        if (result) {
            NSLog(@"asset : %@", result);
            [self.assets addObject:result];
//            [self performSelectorInBackground:@selector(saveAsJPEG:) withObject:result];
            [self.collectionView reloadData];
        }
    };
    
    ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allPhotos];
    [group setAssetsFilter:onlyPhotosFilter];
    [group enumerateAssetsUsingBlock:assetsEnumerationBlock];
}


#pragma mark - UICollectionViewController

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
    return [self.group numberOfAssets];
}

#define kCellID @"PhotoCell"

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ALAsset *asset = self.assets[indexPath.row];
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellID forIndexPath:indexPath];
    cell.tag = indexPath.row;

    UIImageView *iv = (UIImageView *)[cell.contentView viewWithTag:1];
    iv.image = [UIImage imageWithCGImage:asset.thumbnail];

    if (cell.gestureRecognizers.count == 0) {
        UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapped:)];
        [cell addGestureRecognizer:tgr];
    }
    return cell;
}

- (void) onTapped:(UITapGestureRecognizer *)sender
{
    NSInteger idx = sender.view.tag;
    ALAsset *asset = self.assets[idx];
    [self saveAsJPEG:asset];
    [self showPhoto:asset];
}

@end