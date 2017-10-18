//
//  CumulativeScoringHeadView.m
//  cdzer
//
//  Created by 车队长 on 16/8/17.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "CumulativeScoringHeadView.h"

@implementation CumulativeScoringHeadView
- (instancetype)init {
    self = [super init];
    
    if (self) {
        [self initConfig];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initConfig];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initConfig];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
     self.frame=CGRectMake(0, 0, CGRectGetWidth(self.frame), 90);
    _bgImageView.frame=CGRectMake(0, 0, 176, 90);
     [_bgImageView setCenter:CGPointMake(self.frame.size.width/2, self.frame.size.height/2+8)];
    _bgImageView.center=self.center;
    _existingCumulativeScoringLabel.frame=CGRectMake(0, 0, 50, 12);
    [_existingCumulativeScoringLabel setCenter:CGPointMake(self.bgImageView.frame.size.width/2, 25)];
    _numberLable.frame=CGRectMake(0, 0, 150, 13);
    [_numberLable setCenter:CGPointMake(self.bgImageView.frame.size.width/2, 45)];
}
- (void)initConfig {
   @autoreleasepool {
       CGRect rect = CGRectZero;
       rect.size = CGSizeMake(vAdjustByScreenRatio(176.0f), vAdjustByScreenRatio(90.0f));
       rect.origin = CGPointMake(vAdjustByScreenRatio(self.frame.size.width/2), vAdjustByScreenRatio(self.frame.size.height/2+8));
       
    _bgImageView=[[UIImageView alloc]initWithFrame:rect];
     [_bgImageView setCenter:CGPointMake(self.frame.size.width/2, self.frame.size.height/2+8)];
    _bgImageView.image=[UIImage imageNamed:@"wallet@3x.png"];
    [self addSubview:_bgImageView];
    
    _existingCumulativeScoringLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 50, 12)];
     [_existingCumulativeScoringLabel setCenter:CGPointMake(self.bgImageView.frame.size.width/2, 25)];
    _existingCumulativeScoringLabel.text=@"现有积分";
    _existingCumulativeScoringLabel.font=[UIFont systemFontOfSize:10];
    _existingCumulativeScoringLabel.textColor=[UIColor orangeColor];
    [self.bgImageView addSubview:_existingCumulativeScoringLabel];
    
    _numberLable=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 160, 13)];
    [_numberLable setCenter:CGPointMake(self.bgImageView.frame.size.width/2, 45)];
    _numberLable.textColor=[UIColor orangeColor];
    _numberLable.textAlignment=NSTextAlignmentCenter;
    [self.bgImageView addSubview:_numberLable];
    _numberLable.text=@"121010.0";
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
