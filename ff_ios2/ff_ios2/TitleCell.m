//
//  Cell.m
//  PSPDFKit
//
//  Copyright (c) 2012 Peter Steinberger. All rights reserved.
//

#import "ReactiveCocoa/ReactiveCocoa.h"
#import "ReactiveCocoa/RACScheduler.h"

#import "TitleCell.h"
#import "TitleCollectionViewLayoutAttributes.h"
#import "RoundedLabel.h"
#import "UIGlossyButton.h"
#import "TagContainerView.h"
#import "PurchaseManager.h"

#define LEFT_VIEW_WIDTH 77.0
#define IMAGE_WIDTH 64.0
#define MARGIN_X 8
#define MARGIN_Y 14
#define RIGHT_VIEW_WIDTH 62.0

@interface TitleCell ()

@property (nonatomic) UIView *leftView;
@property (nonatomic) UIImageView *tnView;
@property (nonatomic) UIView *notifyView;

@property (nonatomic) UIView *middleView;
@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) TagContainerView *tcv;

@property (nonatomic) UIView *rightView;
@property (nonatomic) UIGlossyButton *bt;
@property (nonatomic) UILabel *footnoteLabel;

@property (nonatomic) PurchaseManager *purchaseManager;

@property (nonatomic) BOOL tapToBuy;

@property (nonatomic) RACSubject *updateButtonSubject;
@property (nonatomic) RACSubject *updateNotifierSubject;

@end

@implementation TitleCell

- (id)initWithFrame:(CGRect)frame {
    if (!(self = [super initWithFrame:frame])) {
        return self;
    }

    _titleInfo = nil;
    _purchaseManager = [PurchaseManager instance];
    _updateButtonSubject = [RACSubject subject];
    _updateNotifierSubject = [RACSubject subject];
    
    CGFloat height = frame.size.height - MARGIN_Y * 2;
    CGFloat width = frame.size.width;

    _notifyView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, MARGIN_X - 2, frame.size.height)];
    _notifyView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    RACSignal *notifySignal = [RACSignal merge:@[RACAble(titleInfo.lastUpdated), RACAble(titleInfo.lastViewed)]];
    [self rac_liftSelector:@selector(updateNotifier:) withObjects:notifySignal];

    _leftView = [[UIView alloc] initWithFrame: CGRectMake(MARGIN_X, MARGIN_Y, LEFT_VIEW_WIDTH - MARGIN_X, height)];
    _leftView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
    
    UIImage *img = [UIImage imageNamed:@"test_image.png"];
    _tnView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, IMAGE_WIDTH, height)];
    _tnView.contentMode = UIViewContentModeScaleAspectFit;
    _tnView.image = img;
    [_leftView addSubview: _tnView];

    RAC(tnView.image) = [[RACAble(titleInfo.thumbnailUrl) map:^(NSURL *url) {
        if (url) {
            NSData *d = [NSData dataWithContentsOfURL: url];
            return [UIImage imageWithData: d];
        } else {
            return [UIImage imageNamed:@"test_image.png"];
        }
    }] deliverOn: RACScheduler.mainThreadScheduler];
    
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
    _titleLabel.text = @"";
    _titleLabel.backgroundColor = [UIColor clearColor];
    [_middleView addSubview: _titleLabel];

    RAC(titleLabel.text) = [RACAble(titleInfo.name) deliverOn: RACScheduler.mainThreadScheduler];
    
    _tcv = [[TagContainerView alloc] initWithFrame:CGRectMake(4.0, 44.0, _middleView.frame.size.width - 8.0, height - 44.0)];
    _tcv.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    _tcv.tags = @[];
    [_middleView addSubview: _tcv];
    
    RAC(tcv.tags) = [RACAble(titleInfo.tags) deliverOn: RACScheduler.mainThreadScheduler];
    
    _bt = [[UIGlossyButton alloc] initWithFrame:CGRectMake(0.0, 0.0, RIGHT_VIEW_WIDTH - MARGIN_X, 20.0)];
    _bt.center = CGPointMake(_rightView.frame.size.width / 2.0, _rightView.frame.size.height / 2.0);
    _bt.buttonCornerRadius = 4.0;
    _bt.tintColor = [UIColor colorWithRed:0.62 green:0.9 blue:0.9 alpha:1.000];
    [_bt setGradientType:kUIGlossyButtonGradientTypeLinearGlossyStandard];
    [_bt setTitle:@"" forState:UIControlStateNormal];
    [_bt.titleLabel setFont:[UIFont systemFontOfSize:12.0]];
    [_bt addTarget: self action: @selector(tapped) forControlEvents: UIControlEventTouchUpInside];
    [_rightView addSubview: _bt];

    RACSignal *buttonSignal = [RACSignal merge:@[RACAble(titleInfo.status), RACAble(titleInfo.price), RACAble(titleInfo.priceLocale), RACAble(titleInfo.purchased), RACAble(purchaseManager.online)]];
    [self rac_liftSelector:@selector(updateButtonStyle:) withObjects:buttonSignal];

    _footnoteLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, RIGHT_VIEW_WIDTH - MARGIN_X, 30.0)];
    CGRect f = _footnoteLabel.frame;
    f.origin.y = _bt.frame.origin.y + _bt.frame.size.height;
    _footnoteLabel.frame = f;
    _footnoteLabel.textAlignment = NSTextAlignmentCenter;
    _footnoteLabel.font = [UIFont systemFontOfSize:12.0];
    _footnoteLabel.textColor = [UIColor blackColor];
    _footnoteLabel.numberOfLines = 0;
    _footnoteLabel.lineBreakMode = UILineBreakModeCharacterWrap | UILineBreakModeTailTruncation;
    _footnoteLabel.text = @"";
    _footnoteLabel.backgroundColor = [UIColor clearColor];
    [_rightView addSubview:_footnoteLabel];
    
    RAC(footnoteLabel.text) = [[RACAble(titleInfo.footnote) map:^(NSString *note) {
        if (note) {
            return note;
        } else {
            return @"";
        }
    }] deliverOn: RACScheduler.mainThreadScheduler];
    
    [self.contentView addSubview: _notifyView];
    [self.contentView addSubview: _leftView];
    [self.contentView addSubview: _middleView];
    [self.contentView addSubview: _rightView];

    return self;
}

-(void)updateNotifier: (id) _ {
    __weak TitleCell *ws = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (ws) {
            switch ([ws.titleInfo.lastUpdated compare: ws.titleInfo.lastViewed]) {
                case NSOrderedDescending: {
                    UIColor *c = [UIColor colorWithRed: 144 / 256.0 green: 238 / 256.0 blue: 144 / 256.0 alpha:1.0];
                    ws.notifyView.backgroundColor = c;
                    break;
                }
                default:
                    ws.notifyView.backgroundColor = [UIColor clearColor];
                    break;
            }
        }
    });
}

-(void)updateButtonStyle: (id) _ {
    __weak TitleCell *ws = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (ws) {
            if (ws.titleInfo.price && (!ws.titleInfo.purchased)) {
                if (ws.purchaseManager.online) {
                    NSNumberFormatter *nf = [NSNumberFormatter new];
                    nf.numberStyle = NSNumberFormatterCurrencyStyle;
                    nf.locale = ws.titleInfo.priceLocale;
                    NSDecimalNumber *p = ws.titleInfo.price;
                    if ([p isEqualToNumber: UNKNOWN_PRICE]) {
                        [ws setButtonText:@"---" red:120 green:120 blue:120 enabled:NO];
                    } else {
                        [ws setButtonText:[nf stringFromNumber: ws.titleInfo.price] red:159 green:179 blue:230 enabled:YES];
                    }
                } else {
                    [ws setButtonText:@"Offline" red:120 green:120 blue:120 enabled:NO];
                }
                ws.tapToBuy = YES;
            } else {
                switch (ws.titleInfo.status) {
                    case TitleStatusCompleted:
                        [ws setButtonText:@"Complete" red:231 green:225 blue:143 enabled:NO];
                        break;
                    case TitleStatusOnAir:
                        [ws setButtonText:@"On Air" red:67 green:135 blue:233 enabled:YES];
                        break;
                    case TitleStatusPushEnabled:
                        [ws setButtonText:@"Tuned" red:11 green:218 blue:81 enabled:YES];
                        break;
                    default:
                        break;
                }
                ws.tapToBuy = NO;
            }
        }
    });
}

-(void)setButtonText: (NSString *)text red:(int)red green:(int)green blue:(int)blue enabled:(BOOL)enabled {
    UIColor *c = [UIColor colorWithRed:red / 256.0 green:green / 256.0 blue:blue / 256.0 alpha:1.0];
    if (enabled) {
        _bt.tintColor = c;
        [_bt setTitle:text forState:UIControlStateNormal];
        _bt.enabled = YES;
    } else {
        _bt.disabledColor = c;
        [_bt setTitle:text forState:UIControlStateDisabled];
        _bt.enabled = NO;
    }
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

-(void)tapped {
    UIActionSheet *as = [UIActionSheet new];
    as.delegate = self;
    if (_tapToBuy) {
        [as addButtonWithTitle:@"Buy Now"];
        as.destructiveButtonIndex = 0;
    } else {
        [as addButtonWithTitle:@"Tune On"];
        [as addButtonWithTitle:@"Tune Off"];
    }
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        [as addButtonWithTitle:@"Cancel"];
        as.cancelButtonIndex = as.numberOfButtons - 1;
    }
    [as showFromRect:_bt.frame inView:_bt.superview animated:YES];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"clicked");
    if (_tapToBuy) {
        if (buttonIndex == 0) {
            [_purchaseManager buyWithTitleInfo: _titleInfo];
        }
    } else {
        if (buttonIndex == 0) {
            _titleInfo.status = TitleStatusPushEnabled;
        } else if (buttonIndex == 1) {
            _titleInfo.status = TitleStatusOnAir;
        }
    }
}

@end
