//
//  AutosSelectedView.m
//  cdzer
//
//  Created by KEns0n on 3/3/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#define vStandardHeight vAdjustByScreenRatio(70.0f)
#import "AutosSelectedView.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface AutosSelectedView ()

@property (nonatomic, strong) UIImageView *carLogo;

@property (nonatomic, strong) UILabel *carDescription;

@property (nonatomic, strong) UIImageView *arrowIV;

@property (nonatomic, assign) BOOL moreDetail;

@property (nonatomic, assign) BOOL onlyForSelection;

@end

@implementation AutosSelectedView


- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (instancetype)initWithOrigin:(CGPoint)origin showMoreDeatil:(BOOL)moreDetail onlyForSelection:(BOOL)onlyForSelection {
    CGFloat width = CGRectGetWidth([[UIScreen mainScreen] bounds]);
    
    self = [super initWithFrame:CGRectMake(origin.x, origin.y, width, vStandardHeight+(moreDetail?20.0f:0.0f))];
    if (self) {
        self.onlyForSelection = onlyForSelection;
        self.moreDetail = moreDetail;
        [self initializationUI];
    }
    return self;
}

- (void)initializationUI {
    @autoreleasepool {
        [self setBackgroundColor:CDZColorOfWhite];
        self.layer.borderColor = [[UIColor colorWithRed:0.882f green:0.882f blue:0.882f alpha:1.00f] CGColor];
        self.layer.borderWidth = 1.0f;
        
        self.carLogo = [[UIImageView alloc] initWithFrame:CGRectMake(vAdjustByScreenRatio(18.0f),
                                                                       vAdjustByScreenRatio(5.0f),
                                                                       vAdjustByScreenRatio(60.0f),
                                                                       vAdjustByScreenRatio(60.0f))];
        _carLogo.center = CGPointMake(_carLogo.center.x, CGRectGetHeight(self.frame)/2.0f);
        _carLogo.image = ImageHandler.getDefaultWhiteLogo;
        _carLogo.shapeLayer = [ImageHandler drawDashedBorderByType:BorderTypeDashed
                                                            target:_carLogo
                                                        shapeLayer:_carLogo.shapeLayer
                                                       borderColor:[UIColor colorWithRed:0.627f green:0.627f blue:0.627f alpha:1.00f]
                                                      cornerRadius:0
                                                       borderWidth:2
                                                       dashPattern:4
                                                      spacePattern:4
                                                   numberOfColumns:0
                                                      numberOfRows:0];
        [self addSubview:_carLogo];
        
        [self setCarDescription:[[UILabel alloc] initWithFrame:CGRectMake(vAdjustByScreenRatio(88.0f),
                                                                          0.0f,
                                                                          CGRectGetWidth(self.frame)-vAdjustByScreenRatio(88.0f),
                                                                          CGRectGetHeight(self.frame))]];
        [_carDescription setTextAlignment:NSTextAlignmentLeft];
        [_carDescription setText:getLocalizationString(@"carSelectRemind")];
        [_carDescription setFont:[UIFont systemFontOfSize:vAdjustByScreenRatio(15)]];
        [_carDescription setTextColor:[UIColor blackColor]];
        [_carDescription setBackgroundColor:[UIColor clearColor]];
        _carDescription.numberOfLines = 0;
        [self addSubview:_carDescription];
        
//        UILabel *remindLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(_carDescription.frame),
//                                                                         CGRectGetMaxY(_carDescription.frame),
//                                                                         CGRectGetWidth(_carDescription.frame),
//                                                                         CGRectGetHeight(_carDescription.frame))];
//        [remindLabel setTextAlignment:NSTextAlignmentLeft];
//        [remindLabel setText:getLocalizationString(@"carSelectRemind")];
//        [remindLabel setFont:[UIFont systemFontOfSize:vAdjustByScreenRatio(14)]];
//        [remindLabel setTextColor:[UIColor colorWithRed:0.984f green:0.420f blue:0.133f alpha:1.00f]];
//        [remindLabel setBackgroundColor:[UIColor clearColor]];
//        [self addSubview:remindLabel];
        
        CGFloat width = vAdjustByScreenRatio(12.0f);
        self.arrowIV= [[UIImageView alloc] initWithFrame:CGRectMake(vAdjustByScreenRatio(290.0f), (CGRectGetHeight(self.frame)-width)/2, width, width)];
        _arrowIV.image = ImageHandler.getRightArrow;
        [self addSubview:_arrowIV];
    }
    [self reloadUIData];
}

- (void)reloadUIData {
    @autoreleasepool {
        if (!_onlyForSelection) {
            self.autoData = [[DBHandler shareInstance] getSelectedAutoData];
        }
        if (_autoData) {
            NSString *urlString = _autoData.brandImgURL;
            [_carLogo sd_setImageWithURL:[NSURL URLWithString:urlString] placeholderImage:[ImageHandler getDefaultWhiteLogo]];
            NSMutableString *string = [NSMutableString string];
            BOOL showArrow = NO;
            if (_onlyForSelection) {
                showArrow = YES;
            }else {
                if (!_moreDetail) {
                    showArrow = YES;
                }
            }
            self.arrowIV.hidden = !showArrow;
            if (!_moreDetail) {
                [string appendFormat:@"%@\n%@",_autoData.seriesName, _autoData.modelName];
            }else {
                [string appendFormat:@"品牌：%@\n", _autoData.brandName];
                [string appendFormat:@"代理商：%@\n", _autoData.dealershipName];
                [string appendFormat:@"车系：%@\n", _autoData.seriesName];
                [string appendFormat:@"车型：%@", _autoData.modelName];
            }
            _carDescription.text = string;
        }else {
            _carDescription.text = @"请选择需要投保的汽车";
        }
    }
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
