//
//  ViewController.m
//  ff_ios2
//
//  Created by 岩田 健一 on 13/03/22.
//  Copyright (c) 2013年 NAKAZATO Hajime. All rights reserved.
//

#import "ReactiveCocoa/ReactiveCocoa.h"
#import "EXTScope.h"
#import "TitleCollectionViewController.h"
#import "TitleCell.h"
#import "TitleManager.h"

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
    
    {
        @weakify(self);
        [[[RACSignal merge:@[RACAble(self.titleManager, titleInfoSet), _sortCommand]] deliverOn: RACScheduler.mainThreadScheduler] subscribeNext:^(id _){

            @strongify(self);
            [self generateTitleInfos];
            [self.collectionView reloadData];
        }];
    }

    [self generateTitleInfos];

    return self;
}

-(void)sortCellsWithOld:(NSArray *)oldTitleInfos {
    PSTCollectionView *v = self.collectionView;
    [v performBatchUpdates:^{
        NSMutableArray *temps = [oldTitleInfos mutableCopy];
        NSUInteger ni = 0;
        for (TitleInfo *ti in _titleInfos) {
            NSUInteger oi = [temps indexOfObject: ti];
            if (oi == NSNotFound) {
            } else {
                [temps insertObject:ti atIndex:ni];
                NSIndexPath *np = [NSIndexPath indexPathForRow:ni inSection:0];
                [v insertItemsAtIndexPaths:@[np]];
            }
            ni ++;
        }
    } completion:^(BOOL finished) {
        
    }];
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
    
    @weakify(self)
    [[[RACSignal merge:ds] take: 1] subscribeNext:^(id _) {
        @strongify(self)
        [self.sortCommand execute:nil];
    }];
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
