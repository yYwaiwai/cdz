//
//  RepairServiceItemCell.m
//  cdzer
//
//  Created by 车队长 on 16/8/19.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "RepairServiceItemCell.h"
#import "RepairServiceItemImage.h"

@interface RepairServiceItemCell ()

@property (weak, nonatomic) IBOutlet UIImageView *titleImageView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UIImageView *checkMarkIV;

@end

@implementation RepairServiceItemCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.rectBorder = UIRectBorderNone;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.contentView setViewBorderWithRectBorder:self.rectBorder borderSize:0.5 withColor:nil withBroderOffset:nil];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if (!self.allIVHighlighted) {
        self.checkMarkIV.highlighted = selected;
        self.titleImageView.highlighted = selected;
    }
    // Configure the view for the selected state
}

- (void)updateItemName:(NSString *)itemName {
    self.titleLabel.text = itemName;
    self.titleImageView.image = [RepairServiceItemImage specRepairIcon:itemName wasSelected:NO];
    self.titleImageView.highlightedImage = [RepairServiceItemImage specRepairIcon:itemName wasSelected:YES];
    self.checkMarkIV.highlighted = NO;
    self.titleImageView.highlighted = NO;
    if (self.allIVHighlighted) {
        self.checkMarkIV.highlighted = YES;
        self.titleImageView.highlighted = self.checkMarkIV.highlighted;
    }
}

@end

@implementation RepairServiceItemSpaceCell

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.contentView setViewBorderWithRectBorder:UIRectBorderBottom|UIRectBorderTop borderSize:0.5 withColor:nil withBroderOffset:nil];
}

@end