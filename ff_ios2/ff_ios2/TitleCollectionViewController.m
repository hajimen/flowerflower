//
//  ViewController.m
//  ff_ios2
//
//  Created by 岩田 健一 on 13/03/22.
//  Copyright (c) 2013年 NAKAZATO Hajime. All rights reserved.
//

#import "ReactiveCocoa/ReactiveCocoa.h"

#import "TitleCollectionViewController.h"
#import "TitleCell.h"
#import "TitleManager.h"
#import "Foreground.h"

@interface TitleCollectionViewController ()

@property (nonatomic) TitleManager *titleManager;
@property (nonatomic) NSArray *titleInfos;
@property (nonatomic) RACCommand *sortCommand;

@end

@implementation TitleCollectionViewController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (!self) {
        return self;
    }

    _titleManager = [TitleManager instance];
    
    _sortCommand = [RACCommand command];

    RACSignal *reloadSignal = [[RACSignal merge:@[RACAble(self.titleManager, titleInfoSet), _sortCommand]] deliverOn: RACScheduler.mainThreadScheduler];
    [self rac_liftSelector:@selector(generateTitleInfosAndReload:) withObjects:reloadSignal];

    [self generateTitleInfos];

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.collectionView.backgroundColor = [UIColor underPageBackgroundColor];
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
    return [[_titleManager titleInfoSet] count];
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSTCollectionViewDelegate

-(void)collectionView:(PSTCollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    TitleInfo *ti = [_titleInfos objectAtIndex:indexPath.item];
    [[Foreground instance] cellTapped: ti];
}

- (PSTCollectionViewCell *)collectionView:(PSTCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TitleCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MY_CELL" forIndexPath:indexPath];

    cell.titleInfo = [_titleInfos objectAtIndex:indexPath.item];

    return cell;
}

-(void)generateTitleInfos {
    NSArray *s = [[_titleManager titleInfoSet] allObjects];
    self.titleInfos = [s sortedArrayUsingComparator:^NSComparisonResult(TitleInfo *l, TitleInfo *r) {
        return -[[l.lastUpdated laterDate: l.lastViewed] compare: [r.lastUpdated laterDate: r.lastViewed]];
    }];
    
    NSMutableArray *ds = [self.titleInfos.rac_sequence foldLeftWithStart:[NSMutableArray arrayWithCapacity:self.titleInfos.count * 2] combine:^NSMutableArray *(NSMutableArray *accumulator, TitleInfo *value) {
        [accumulator addObject: RACAble(value, lastUpdated)];
        [accumulator addObject: RACAble(value, lastViewed)];
        return accumulator;
    }];

    [[[RACSignal merge:ds] take: 1] executeCommand:_sortCommand];
}

-(void)generateTitleInfosAndReload: (id) _ {
    [self generateTitleInfos];
    [self.collectionView reloadData];
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
