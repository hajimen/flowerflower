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
@end

@implementation TitleCollectionViewController

// TODO encodeRestorableStateWithCoder, decodeRestorableStateWithCoder (iOS 6)

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

- (NSInteger)collectionView:(PSTCollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return self.cellCount;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSTCollectionViewDelegate

- (PSTCollectionViewCell *)collectionView:(PSTCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TitleCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MY_CELL" forIndexPath:indexPath];
    if (indexPath.item == 1) {
        NSString *p = [[NSBundle mainBundle] pathForResource:@"test_image2" ofType:@"png"];
        TitleInfo *ti = [[TitleInfo alloc] initWithId:@"test"];
        ti.thumbnailUrl = [NSURL fileURLWithPath: p];
        ti.name = @"My Name";
        ti.tags = @[@"my tag", @"my tag 2", @"my tag 33"];
        ti.price = [NSDecimalNumber decimalNumberWithString:@"1000"];
        ti.priceLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"ja_JP"];
        ti.purchased = NO;
        ti.status = TitleStatusPushEnabled;
        ti.footnote = @"初回購入特別価格";
        cell.titleInfo = ti;
    }

    return cell;
}

///////////////////////////////////////////////////////////////////////////////////////////
-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
}

///////////////////////////////////////////////////////////////////////////////////////////
-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

@end
