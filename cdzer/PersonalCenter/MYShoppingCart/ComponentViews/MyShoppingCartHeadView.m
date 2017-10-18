//
//  MyShoppingCartHeadView.m
//  cdzer
//
//  Created by KEns0nLau on 10/10/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "MyShoppingCartHeadView.h"
#import "UIView+LayoutConstraintHelper.h"

@interface MyShoppingCartHeadView ()

@property (strong, nonatomic) IBOutlet UIView *subContentView;
@end

@implementation MyShoppingCartHeadView

- (void)layoutSubviews {
    [super layoutSubviews];
    BorderOffsetObject *offset = BorderOffsetObject.new;
    offset.bottomLeftOffset = 12;
    [self setViewBorderWithRectBorder:UIRectBorderTop|UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:offset];
}

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self=[super initWithReuseIdentifier:reuseIdentifier]) {
        [[UINib nibWithNibName:@"MyShoppingCartHeadView" bundle:nil] instantiateWithOwner:self options:nil];
        self.subContentView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.subContentView addSelfByFourMarginToSuperview:self.contentView];
    }
    return self;
}

- (IBAction)selection:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (self.selectionBlock) {
        self.selectionBlock(sender.selected, self.sectionIdx);
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
