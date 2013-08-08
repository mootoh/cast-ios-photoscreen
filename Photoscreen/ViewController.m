//
//  ViewController.m
//  Photoscreen
//
//  Created by Motohiro Takayama on 8/5/13.
//  Copyright (c) 2013 Motohiro Takayama. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "ViewController.h"
#import "AppDelegate.h"
#import "CastSender.h"
#import "AssetsCollectionViewController.h"

@interface ViewController ()
@end

@implementation ViewController

#pragma mark - AssetsLibrary

- (void) setupAssetsLibrary
{
    self.assetsLibrary = [[ALAssetsLibrary alloc] init];
    self.assetsGroups = [NSMutableArray array];
    
    ALAssetsLibraryGroupsEnumerationResultsBlock listGroupBlock = ^(ALAssetsGroup *group, BOOL *stop) {
        if (group) {
            NSLog(@"group found: %@", group);
            [self.assetsGroups addObject:group];
            [self.collectionView reloadData];
        }
    };
    
    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {
        NSLog(@"error in accessing AssetsLibrary: %@", error);
    };
    
    NSUInteger groupTypes = ALAssetsGroupAlbum | ALAssetsGroupEvent;
    [self.assetsLibrary enumerateGroupsWithTypes:groupTypes usingBlock:listGroupBlock failureBlock:failureBlock];
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupAssetsLibrary];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showAssetsInGroup"])
    {
        NSIndexPath *selectedIndexPath = [self.collectionView indexPathsForSelectedItems][0];
        AssetsCollectionViewController *nextViewController = [segue destinationViewController];
        nextViewController.group = self.assetsGroups[selectedIndexPath.row];
    }
}

#pragma mark - UICollectionViewController

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
    return self.assetsGroups.count;
}

#define kCellID @"PhotoCell"

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ALAssetsGroup *group = self.assetsGroups[indexPath.row];
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellID forIndexPath:indexPath];
    UIImageView *iv = (UIImageView *)[cell.contentView viewWithTag:1];
    iv.image = [UIImage imageWithCGImage:group.posterImage];
    return cell;
}

@end