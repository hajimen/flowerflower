//
//  Cell.m
//  PSPDFKit
//
//  Copyright (c) 2012 Peter Steinberger. All rights reserved.
//

#import "ReactiveCocoa/ReactiveCocoa.h"
#import "EXTScope.h"
#import "TitleCell.h"
#import "TitleCollectionViewLayoutAttributes.h"
#import "RoundedLabel.h"
#import "UIGlossyButton.h"
#import "TagContainerView.h"

#define LEFT_VIEW_WIDTH 77.0
#define IMAGE_WIDTH 64.0
#define MARGIN_X 8
#define MARGIN_Y 14
#define RIGHT_VIEW_WIDTH 62.0

@interface TitleCell ()

@property (nonatomic) UIView *leftView;
@property (nonatomic) UIImageView *tnView;

@property (nonatomic) UIView *middleView;
@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) TagContainerView *tcv;

@property (nonatomic) UIView *rightView;
@property (nonatomic) UIGlossyButton *bt;
@property (nonatomic) UILabel *footnoteLabel;

@end

@implementation TitleCell

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        _titleInfo = [[TitleInfo alloc] initWithId:@""];

        CGFloat height = frame.size.height - MARGIN_Y * 2;
        CGFloat width = frame.size.width;

        _leftView = [[UIView alloc] initWithFrame: CGRectMake(MARGIN_X, MARGIN_Y, LEFT_VIEW_WIDTH - MARGIN_X, height)];
        _leftView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
        
        UIImage *img = [UIImage imageNamed:@"test_image.png"];
        _tnView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, IMAGE_WIDTH, height)];
        _tnView.contentMode = UIViewContentModeScaleAspectFit;
        _tnView.image = img;
        [_leftView addSubview: _tnView];
        
        RAC(tnView.image) = [[RACAble(titleInfo.thumbnailUrl) filter:^BOOL(NSURL *url) {
            return (url != nil);
        }] map:^(NSURL *url) {
            NSData *d = [NSData dataWithContentsOfURL: url];
            return [UIImage imageWithData: d];
        }];
        
        _middleView = [[UIView alloc] initWithFrame: CGRectMake(LEFT_VIEW_WIDTH, MARGIN_Y, width - LEFT_VIEW_WIDTH - RIGHT_VIEW_WIDTH - MARGIN_X, height)];
        _middleView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

        _rightView = [[UIView alloc] initWithFrame: CGRectMake(width - RIGHT_VIEW_WIDTH, MARGIN_Y, RIGHT_VIEW_WIDTH - MARGIN_X, height)];
        _rightView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;

        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(4.0, 0.0, _middleView.frame.size.width - 8.0, 40)];
        _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.font = [UIFont boldSystemFontOfSize:18.0];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.numberOfLines = 0;
        _titleLabel.lineBreakMode = UILineBreakModeCharacterWrap | UILineBreakModeTailTruncation;
        _titleLabel.text = @"東京特許許可局 東京特許許可局 東京特許許可局";
        _titleLabel.backgroundColor = [UIColor clearColor];
        [_middleView addSubview: _titleLabel];

        RAC(titleLabel.text) = [RACAble(titleInfo.name) filter:^BOOL(NSString *name) {
            return (name != nil);
        }];
        
        _tcv = [[TagContainerView alloc] initWithFrame:CGRectMake(4.0, 44.0, _middleView.frame.size.width - 8.0, height - 44.0)];
        _tcv.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        _tcv.tags = @[@"TAG 1", @"TAG 2", @"TAG 3", @"TAG 4", @"TAG 5", @"TAG 6", @"TAG 7", @"TAG 8"];
        [_middleView addSubview: _tcv];
        
        RAC(tcv.tags) = [RACAble(titleInfo.tags) filter:^BOOL(NSArray *tags) {
            return (tags != nil);
        }];
        
        _bt = [[UIGlossyButton alloc] initWithFrame:CGRectMake(0.0, 0.0, RIGHT_VIEW_WIDTH - MARGIN_X, 20.0)];
        _bt.center = CGPointMake(_rightView.frame.size.width / 2.0, _rightView.frame.size.height / 2.0);
        _bt.buttonCornerRadius = 4.0;
        _bt.tintColor = [UIColor colorWithRed:0.62 green:0.9 blue:0.9 alpha:1.000];
        [_bt setGradientType:kUIGlossyButtonGradientTypeLinearGlossyStandard];
        [_bt setTitle:@"$2,000" forState:UIControlStateNormal];
        [_bt setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_bt.titleLabel setFont:[UIFont systemFontOfSize:12.0]];
        [_rightView addSubview: _bt];
        
        @weakify(self);
        [[RACSignal combineLatest:@[RACAble(titleInfo.status), RACAble(titleInfo.price), RACAble(titleInfo.priceLocale), RACAble(titleInfo.purchased)] reduce:^(NSNumber *statusN, NSDecimalNumber *price, NSLocale *priceLocale, NSNumber *purchasedN){
            @strongify(self);
            TitleStatus status = (TitleStatus)[statusN integerValue];
            if (price && (![purchasedN boolValue])) {
                NSNumberFormatter *nf = [NSNumberFormatter new];
                nf.numberStyle = NSNumberFormatterCurrencyStyle;
                nf.locale = priceLocale;
                [self setButtonText:[nf stringFromNumber: price] red:159 green:179 blue:230];
            } else {
                switch (status) {
                    case TitleStatusCompleted:
                        [self setButtonText:@"Complete" red:231 green:225 blue:143];
                        break;
                    case TitleStatusOnAir:
                        [self setButtonText:@"On Air" red:67 green:135 blue:233];
                        break;
                    case TitleStatusPushEnabled:
                        [self setButtonText:@"Tuned" red:11 green:218 blue:81];
                        break;
                    default:
                        break;
                }
            }

            return @0;
        }] subscribeNext:^(NSNumber *dummy) {
        }];

        _footnoteLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, RIGHT_VIEW_WIDTH - MARGIN_X, 30.0)];
        CGRect f = _footnoteLabel.frame;
        f.origin.y = _bt.frame.origin.y + _bt.frame.size.height;
        _footnoteLabel.frame = f;
        _footnoteLabel.textAlignment = NSTextAlignmentCenter;
        _footnoteLabel.font = [UIFont systemFontOfSize:12.0];
        _footnoteLabel.textColor = [UIColor blackColor];
        _footnoteLabel.numberOfLines = 0;
        _footnoteLabel.lineBreakMode = UILineBreakModeCharacterWrap | UILineBreakModeTailTruncation;
        _footnoteLabel.text = @"購入時の注意事項";
        _footnoteLabel.backgroundColor = [UIColor clearColor];
        [_rightView addSubview:_footnoteLabel];
        
        RAC(footnoteLabel.text) = [RACAble(titleInfo.footnote) filter:^BOOL(NSString *note) {
            return (note != nil);
        }];

        [self.contentView addSubview: _leftView];
        [self.contentView addSubview: _middleView];
        [self.contentView addSubview: _rightView];
    }
    return self;
}

-(void)setButtonText: (NSString *)text red:(int)red green:(int)green blue:(int)blue {
    _bt.tintColor = [UIColor colorWithRed:red / 256.0 green:green / 256.0 blue:blue / 256.0 alpha:1.0];
    [_bt setTitle:text forState:UIControlStateNormal];
}

-(void)applyLayoutAttributes:(PSTCollectionViewLayoutAttributes *)layoutAttributes {
    [super applyLayoutAttributes:layoutAttributes];
    
    TitleCollectionViewLayoutAttributes *attr = (TitleCollectionViewLayoutAttributes *) layoutAttributes;

    if (attr.row % 2 == 1) {
        self.contentView.backgroundColor = [UIColor colorWithRed:0.875 green:0.902 blue:0.9375 alpha:1.000];
    } else {
        self.contentView.backgroundColor = [UIColor colorWithRed:0.832 green:0.859 blue:0.895 alpha:1.000];
    }
}

@end
