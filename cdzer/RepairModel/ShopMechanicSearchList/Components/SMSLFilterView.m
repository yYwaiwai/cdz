//
//  SMSLFilterView.m
//  cdzer
//
//  Created by KEns0n on 15/11/2016.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "SMSLFilterView.h"
#import "SMSLFilterOtherOptionView.h"

@interface SMSLFilterView ()

@property (nonatomic, strong) IBOutlet SMSLFilterOtherOptionView *otherOtionView;

@property (nonatomic, assign) BOOL wasSelectedOtherOption;

@end

@implementation SMSLFilterView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (NSString *)otherFilterString {
    return self.otherOtionView.otherFilterString;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    [[UINib nibWithNibName:@"SMSLFilterOtherOptionView" bundle:nil] instantiateWithOwner:self options:nil];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                    attribute:NSLayoutAttributeHeight
                                                    relatedBy:NSLayoutRelationEqual
                                                       toItem:nil
                                                    attribute:NSLayoutAttributeNotAnAttribute
                                                   multiplier:1
                                                      constant:42]];
    _filterType = SMSLFilterTypeOfAll;
    for (UIView *view in self.subviews) {
        if (view.tag==1) {
            UILabel *title = (UILabel *)[[view viewWithTag:10] viewWithTag:11];
            title.highlighted = YES;
        }else if (view.tag==2||view.tag==3) {
            UIImageView *ascendIconIV = (UIImageView *)[[[view viewWithTag:10] viewWithTag:12] viewWithTag:1];
            UIImageView *decadendIconIV = (UIImageView *)[[[view viewWithTag:10] viewWithTag:12] viewWithTag:2];
            ascendIconIV.highlightedImage = [ascendIconIV.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            decadendIconIV.highlightedImage = [decadendIconIV.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];;
        }else if(view.tag==4){
            UIImageView *iconIV = (UIImageView *)[[view viewWithTag:10] viewWithTag:12];
            iconIV.highlightedImage = [iconIV.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        }
    }
    
    self.wasSelectedOtherOption = NO;
    
    @weakify(self);
    self.otherOtionView.responseBlock = ^() {
        @strongify(self);
        self.wasSelectedOtherOption = (![self.otherOtionView.otherFilterString isEqualToString:@""]);
        UIView *view = [self viewWithTag:4];
        UILabel *title = (UILabel *)[[view viewWithTag:10] viewWithTag:11];
        UIImageView *iconIV = (UIImageView *)[[view viewWithTag:10] viewWithTag:12];
        title.highlighted = self.wasSelectedOtherOption;
        iconIV.highlighted = self.wasSelectedOtherOption;
        if (self.responseBlock) {
            self.responseBlock();
        }
    };
}

- (IBAction)changeFilterOption:(UIControl *)sender {
    [UIApplication.sharedApplication.keyWindow endEditing:YES];
    if (sender.tag==4) {
        [self.otherOtionView showView];
    }else {
        [self changeOptionViewStatus:sender.tag];
        if (self.responseBlock) {
            self.responseBlock();
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
}

- (void)changeOptionViewStatus:(NSUInteger)tag {
    if (tag<1&&tag>3) return;
    for (UIView *view in self.subviews) {
        BOOL isSelected = (view.tag==tag);
        if (view.tag==1) {
            _filterType = SMSLFilterTypeOfAll;
            UILabel *title = (UILabel *)[[view viewWithTag:10] viewWithTag:11];
            title.highlighted = isSelected;
        }else if (view.tag==2||view.tag==3) {
            UILabel *title = (UILabel *)[[view viewWithTag:10] viewWithTag:11];
            UIImageView *ascendIconIV = (UIImageView *)[[[view viewWithTag:10] viewWithTag:12] viewWithTag:1];
            UIImageView *decadendIconIV = (UIImageView *)[[[view viewWithTag:10] viewWithTag:12] viewWithTag:2];
            if (isSelected) {
                title.highlighted = YES;
                if (!ascendIconIV.highlighted&&decadendIconIV.highlighted) {
                    ascendIconIV.highlighted = YES;
                    decadendIconIV.highlighted = NO;
                    _filterType = ((view.tag==2)?SMSLFilterTypeOfCommentAscend:SMSLFilterTypeOfExperienceAscend);
                }else {
                    ascendIconIV.highlighted = NO;
                    decadendIconIV.highlighted = YES;
                    _filterType = ((view.tag==2)?SMSLFilterTypeOfCommentDescend:SMSLFilterTypeOfExperienceDescend);
                }
            }else {
                title.highlighted = NO;
                ascendIconIV.highlighted = NO;
                decadendIconIV.highlighted = NO;
            }
        }
    }
}

@end
