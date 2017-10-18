//
//  PersonalCenterTVCell.m
//  cdzer
//
//  Created by KEns0nLau on 8/18/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "PersonalCenterTVCell.h"
@interface PersonalCenterTVCell ()

@property (nonatomic, weak) IBOutlet UIView *contentContainerView;

@end

@implementation PersonalCenterTVCell

- (void)layoutSubviews {
    [super layoutSubviews];
    BorderOffsetObject *offsetObject = [BorderOffsetObject new];
    if (!self.isSpaceOnly&&self.rectBorder&UIRectBorderBottom) offsetObject.bottomLeftOffset = 12;
    [self setViewBorderWithRectBorder:self.rectBorder borderSize:0.5 withColor:nil withBroderOffset:offsetObject];
}

- (void)setIsSpaceOnly:(BOOL)isSpaceOnly {
    _isSpaceOnly = isSpaceOnly;
    self.contentContainerView.hidden = _isSpaceOnly;
}

- (void)awakeFromNib {
    self.rectBorder = UIRectBorderNone;
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
