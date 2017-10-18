//
//  SNSDShopServiceViewCell.m
//  cdzer
//
//  Created by KEns0nLau on 8/30/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "SNSDShopServiceViewCell.h"
#import "RepairServiceItemImage.h"

@interface SNSDShopServiceViewCell()

@property (nonatomic, weak) IBOutlet UIImageView *serviceImageView;

@property (nonatomic, weak) IBOutlet UILabel *serviceName;

@end

@implementation SNSDShopServiceViewCell

- (void)layoutSubviews {
    [super layoutSubviews];
    [self setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:2.0f];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)updateUIData:(NSDictionary *)dataDetail {
    self.serviceName.text = dataDetail[@"name"];
    self.serviceImageView.image = [RepairServiceItemImage specRepairIcon:self.serviceName.text wasSelected:NO];
}

@end
