//
//  SelfDiagnosisMBVCell.m
//  cdzer
//
//  Created by KEns0n on 08/11/2016.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "SelfDiagnosisMBVCell.h"

@interface SelfDiagnosisMBVCell()

@property (nonatomic, strong) BorderOffsetObject *borderOffset;

@property (nonatomic, weak) IBOutlet UIView *selectedIndicatorView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UIImageView *iconIV;

@end

@implementation SelfDiagnosisMBVCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.borderOffset = [BorderOffsetObject new];
    self.viewBorderRect = UIRectBorderNone;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.selectedIndicatorView setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:1 withColor:[UIColor colorWithHexString:@"50c8f3"] withBroderOffset:nil];
    self.borderOffset.leftUpperOffset = (CGRectGetHeight(self.frame)-30)/2.f;
    self.borderOffset.leftBottomOffset = self.borderOffset.leftUpperOffset;
    self.borderOffset.rightUpperOffset = self.borderOffset.leftUpperOffset;
    self.borderOffset.rightBottomOffset = self.borderOffset.leftBottomOffset;
    [self setViewBorderWithRectBorder:self.viewBorderRect borderSize:0.5 withColor:nil withBroderOffset:self.borderOffset];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    self.selectedIndicatorView.hidden = !selected;
}

- (void)updateUIData:(NSDictionary *)detail {
    NSString *title = detail[@"name"];
    NSString *iconName = @"sdmbvc_engine_icon@3x";
    if ([title isContainsString:@"发动机"]) {
        iconName = @"sdmbvc_engine_icon@3x";
    }else if ([title isContainsString:@"变速器"]) {
        iconName = @"sdmbvc_gear_icon@3x";
    }else if ([title isContainsString:@"刹车"]) {
        iconName = @"sdmbvc_break_icon@3x";
    }else if ([title isContainsString:@"灯光"]) {
        iconName = @"sdmbvc_light_icon@3x";
    }else if ([title isContainsString:@"冷暖空调"]) {
        iconName = @"sdmbvc_air_con_icon@3x";
    }else if ([title isContainsString:@"电子电器"]) {
        iconName = @"sdmbvc_electric_icon@3x";
    }
    self.titleLabel.text = title;
    self.iconIV.image = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:iconName ofType:@"png"]];
}

@end
