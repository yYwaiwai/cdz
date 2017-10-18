//
//  ShopMapDetailView.m
//  cdzer
//
//  Created by KEns0n on 6/1/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//


#import "ShopMapDetailView.h"


@implementation ShopMapDetailView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    UIEdgeInsets insetsValue = UIEdgeInsetsMake(0.0f, 7.0f, 0.0f, 7.0f);
    self.shopName.edgeInsets = insetsValue;
    self.address.edgeInsets = insetsValue;
    return self;
}

#pragma mark -设置维修商信息
- (void)setShopDetailWithData:(NSDictionary *)detail {
    self.shopName.text = [NSString stringWithFormat:@"维修商：%@",detail[@"wxs_name"]];
    self.address.text = [NSString stringWithFormat:@"地址：%@",detail[@"address"]];
    self.distance.text = [NSString stringWithFormat:@"距离：%@KM",detail[@"distance"]];
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
