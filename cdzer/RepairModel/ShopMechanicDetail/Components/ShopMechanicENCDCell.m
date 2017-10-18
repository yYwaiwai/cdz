//
//  ShopMechanicENCDCell.m
//  cdzer
//
//  Created by KEns0n on 19/11/2016.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "ShopMechanicENCDCell.h"
@interface ShopMechanicENCDCell ()

@property (nonatomic, weak) IBOutlet UILabel *contentLabel;

@property (nonatomic, weak) IBOutlet UILabel *datetimeLabe;

@property (nonatomic, weak) IBOutlet UIView *theContentView;

@property (nonatomic, weak) IBOutlet UIView *shadowView;

@end

@implementation ShopMechanicENCDCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.theContentView setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:5];
    [self.shadowView setViewCornerWithRectCorner:UIRectCornerBottomLeft|UIRectCornerBottomRight cornerSize:5];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateUIData:(NSDictionary *)sourceData {
    self.contentLabel.text = sourceData[@"content"];
    self.datetimeLabe.text = sourceData[@"addtime"];
}

@end
