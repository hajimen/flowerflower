//
//  Cell.h
//  PSPDFKit
//
//  Copyright (c) 2012 Peter Steinberger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSTCollectionView.h"
#import "TitleInfo.h"

@interface TitleCell : PSTCollectionViewCell

@property (nonatomic) TitleInfo *titleInfo;

@end
