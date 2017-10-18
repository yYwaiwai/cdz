//
//  HVLocationDetailView.m
//  cdzer
//
//  Created by KEns0n on 6/1/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//


#import "HVLocationDetailView.h"
#import "PositionErrorCorrectionVC.h"
@implementation HVLocationDetailView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    UIEdgeInsets insetsValue = UIEdgeInsetsMake(0.0f, 7.0f, 0.0f, 7.0f);
    self.vlNumLabel.edgeInsets = insetsValue;
    self.address.edgeInsets = insetsValue;
    return self;
}

#pragma mark -设置维修商信息
- (void)setShopDetailWithData:(NSDictionary *)detail {
    self.address.text = [NSString stringWithFormat:@"地址：%@",detail[@"place_name"]];
    NSString *lvNum = [SupportingClass verifyAndConvertDataToString:detail[@"num"]];
    self.vlNumLabel.text = [NSString stringWithFormat:@"违章次数：%@条",lvNum];
    self.addressStr=detail[@"place_name"];
    self.longi=detail[@"longitude"];
    self.latit=detail[@"latitude"];
}
- (IBAction)pushToLocationRemarkVC:(id)sender {//28.175903  113.063660
    PositionErrorCorrectionVC *vc = [PositionErrorCorrectionVC new];
    vc.address=self.addressStr;
    vc.longitude=self.longi;
    vc.latitude=self.latit;
    [self.owner.navigationController  pushViewController:vc animated:YES];
    
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
