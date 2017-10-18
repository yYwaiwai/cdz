//
//  MemberDetailRightsCell.m
//  cdzer
//
//  Created by KEns0n on 28/10/2016.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "MemberDetailRightsCell.h"
#import "UserMemberCenterConfig.h"
#import <SDWebImage/UIImageView+WebCache.h>
@interface MemberDetailRightsCell()

@property (weak, nonatomic) IBOutlet UIImageView *userRightsIconIV;

@property (weak, nonatomic) IBOutlet UILabel *userRightsTitleLabel;

@property (weak, nonatomic) IBOutlet UILabel *userRightsContentLabel;

@property (nonatomic, strong) BorderOffsetObject *borderOffset;

@end

@implementation MemberDetailRightsCell

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.userRightsIconIV setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:CGRectGetWidth(self.userRightsIconIV.frame)/2.0f];
    
    self.borderOffset.bottomLeftOffset = CGRectGetMinX(self.userRightsTitleLabel.superview.frame);
    if (self.isLastCell) {
        self.borderOffset.bottomLeftOffset = 0;
    }
    [self setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:self.borderOffset];
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.borderOffset = [BorderOffsetObject new];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateUIDataWithDataModel:(MDRDataModel *)dataModel {
    self.userRightsTitleLabel.text = dataModel.title;
    self.userRightsContentLabel.text = dataModel.content;
    self.userRightsIconIV.image = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"white_logo_small@3x" ofType:@"png"]];
    if ([dataModel.iconURL isContainsString:@"http"]) {
        [self.userRightsIconIV sd_setImageWithURL:[NSURL URLWithString:dataModel.iconURL]];
    }
}

@end
