
//
//  SelfDiagnosisModuleHeaderView.m
//  cdzer
//
//  Created by KEns0n on 08/11/2016.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "SelfDiagnosisModuleHeaderView.h"

@interface SelfDiagnosisModuleHeaderView (){
    IBOutlet UIView *_contentView;
}

@end

@implementation SelfDiagnosisModuleHeaderView

- (UIView *)contentView {
    return _contentView;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self setViewBorderWithRectBorder:UIRectBorderTop|UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
