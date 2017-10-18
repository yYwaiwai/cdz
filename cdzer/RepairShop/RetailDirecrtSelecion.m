//
//  RetailDirecrtSelecion.m
//  cdzer
//
//  Created by KEns0n on 3/5/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#define vStandardWidth SCREEN_WIDTH
#define vStandardHeight 102.0f
#define vStandardMaxHeight 175.0f
#define vStartOffsetX 26.0f


#import "RetailDirecrtSelecion.h"
#import "InsetsLabel.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface FixImageButton : UIButton

@end

@implementation FixImageButton

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.imageView.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.frame), CGRectGetWidth(self.frame));
    self.titleLabel.frame = CGRectMake(0.0f, CGRectGetMaxY(self.imageView.frame), CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)-CGRectGetMaxY(self.imageView.frame));
    
    self.imageView.autoresizingMask = UIViewAutoresizingNone;
    [self.titleLabel setAutoresizingMask:UIViewAutoresizingNone];
}

@end

@interface RetailDirecrtSelecion ()

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) NSArray *theList;

@end


@implementation RetailDirecrtSelecion

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.theList = DBHandler.shareInstance.getRepairShopServiceTypeList;
    }
    return self;
}

- (void)initializationUIWithTarget:(id)target action:(SEL)action {
    
    @autoreleasepool {
        self.backgroundColor = CDZColorOfWhite;
        [self setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:1.0f withColor:[UIColor colorWithRed:0.882f green:0.882f blue:0.882f alpha:1.00f] withBroderOffset:nil];
        CGFloat fontSize = 12.0f*vWidthRatio;
        
        InsetsLabel *titleLabel = [[InsetsLabel alloc]initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.frame), 24.0f)
                                                 andEdgeInsetsValue:UIEdgeInsetsMake(0.0f, vStartOffsetX, 0.0f, vStartOffsetX)];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        [titleLabel setTextAlignment:NSTextAlignmentLeft];
        [titleLabel setText:getLocalizationString(@"direct_hits")];
        [titleLabel setFont:[UIFont systemFontOfSize:fontSize]];
        [self addSubview:titleLabel];
        
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(titleLabel.frame), CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)-CGRectGetMaxY(titleLabel.frame))];
        [_scrollView setShowsHorizontalScrollIndicator:YES];
        [_scrollView setShowsVerticalScrollIndicator:YES];
        [_scrollView setBounces:NO];
        [self addSubview:_scrollView];
        
        
        CGFloat fixWidth = 56.0f;
        CGFloat fixHeight = fixWidth+22.0f;
        CGFloat leftSideMargin = vStartOffsetX;
        NSUInteger numOfColumn = 4;
        CGFloat btn2btnColumnSpace = 5.0f;
        CGFloat btn2btnRowSpace = (CGRectGetWidth(_scrollView.frame)-fixWidth*numOfColumn)/(numOfColumn+1);
        CGSize contentSize = CGSizeMake(_theList.count*fixWidth+(_theList.count-1)*btn2btnRowSpace+leftSideMargin*2, CGRectGetHeight(_scrollView.frame));
        

        if (IS_IPHONE_5_ABOVE) {
            NSUInteger row = _theList.count/numOfColumn;
            if (_theList.count%numOfColumn!=0) {
                row++;
            }
            leftSideMargin = btn2btnRowSpace;
            contentSize = CGSizeMake(CGRectGetWidth(_scrollView.frame),(fixHeight+btn2btnColumnSpace)*row);
            
        }
        

        for (int i = 0; i <_theList.count; i++) {
            NSUInteger row = 0;
            NSUInteger column = i;
            if (IS_IPHONE_5_ABOVE) {
                row = i/numOfColumn;
                column = i%numOfColumn;
            }
            CGRect rect = CGRectZero;
            rect.origin.x = leftSideMargin+column*(fixWidth+btn2btnRowSpace);
            rect.size = CGSizeMake(fixWidth, fixHeight);
            rect.origin.y = row*(fixHeight+btn2btnColumnSpace);
            
            NSDictionary *detail = _theList[i];
            FixImageButton *button = [FixImageButton buttonWithType:UIButtonTypeCustom];
            button.frame = rect;
            button.tag = i;
            button.titleLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 12, NO);
            button.titleLabel.textAlignment = NSTextAlignmentCenter;
            [button setImage:ImageHandler.getWhiteLogo forState:UIControlStateNormal];
            [button setTitle:detail[@"name"] forState:UIControlStateNormal];
            [button setTitleColor:CDZColorOfDefaultColor forState:UIControlStateNormal];
            [_scrollView addSubview:button];
            
            NSString *urlString = detail[@"imgurl"];
            if ([urlString rangeOfString:@"http"].location != NSNotFound) {
                [button.imageView sd_setImageWithURL:[NSURL URLWithString:urlString] placeholderImage:ImageHandler.getWhiteLogo
                                             options:SDWebImageContinueInBackground|SDWebImageAvoidAutoSetImage
                                           completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                               if (image&&!error) {
                                                   [button setImage:image forState:UIControlStateNormal];
                                               }else {
                                                   [button setImage:ImageHandler.getWhiteLogo forState:UIControlStateNormal];
                                               }
                                           }];
            }
            if ([target respondsToSelector:action]) {
                [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
            }
            
        }
        _scrollView.canCancelContentTouches = YES;
        _scrollView.delaysContentTouches = YES;
        _scrollView.panGestureRecognizer.delaysTouchesBegan = _scrollView.delaysContentTouches;
        _scrollView.contentSize = contentSize;
        [_scrollView flashScrollIndicators];
    }
}

@end

