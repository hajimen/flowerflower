//
//  ViewController.m
//  ff_ios2
//
//  Created by 岩田 健一 on 13/03/22.
//  Copyright (c) 2013年 NAKAZATO Hajime. All rights reserved.
//

#import "TitleCollectionViewController.h"
#import "TitleCell.h"

@interface TitleCollectionViewController ()
@property (atomic, readwrite, assign) NSInteger cellCount;
@property (atomic, readwrite, assign) NSInteger itemsPerRow;
@end

@implementation TitleCollectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.collectionView.backgroundColor = [UIColor underPageBackgroundColor];
    self.cellCount = 10;
    [self.collectionView registerClass:[TitleCell class] forCellWithReuseIdentifier:@"MY_CELL"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSTCollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return self.cellCount;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSTCollectionViewDelegate

- (PSUICollectionViewCell *)collectionView:(PSUICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TitleCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MY_CELL" forIndexPath:indexPath];
    int row = (indexPath.item / self.itemsPerRow);
    if (row % 2 == 1) {
        cell.label.backgroundColor = [UIColor whiteColor];
    }
    return cell;
}

///////////////////////////////////////////////////////////////////////////////////////////
-(void)viewWillLayoutSubviews {
    PSUICollectionViewFlowLayout *flowLayout = (PSUICollectionViewFlowLayout *) self.collectionView.collectionViewLayout;
    self.itemsPerRow = 2;
    CGFloat itemWidth = (self.view.bounds.size.width - 10) / 2;
    flowLayout.itemSize = CGSizeMake(itemWidth, 200);
    flowLayout.minimumLineSpacing = 50;
    flowLayout.minimumInteritemSpacing = 10;
}

///////////////////////////////////////////////////////////////////////////////////////////
-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

@end
