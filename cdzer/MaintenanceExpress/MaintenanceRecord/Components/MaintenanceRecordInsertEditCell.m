//
//  MaintenanceRecordInsertEditCell.m
//  cdzer
//
//  Created by KEns0nLau on 10/13/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "MaintenanceRecordInsertEditCell.h"

@implementation MaintenanceRecordInsertEditCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:1.0];
    UIColor *borderColor = [UIColor colorWithRed:0.839 green:0.843 blue:0.863 alpha:1.00];
    [self setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:0.5 withColor:borderColor withBroderOffset:nil];
    // Initialization code
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    self.backgroundColor = [UIColor colorWithHexString:selected?@"50c7f3":@"FFFFFF"];
    self.maintainNameLabel.textColor = [UIColor colorWithHexString:selected?@"FFFFFF":@"323232"];
}

@end
