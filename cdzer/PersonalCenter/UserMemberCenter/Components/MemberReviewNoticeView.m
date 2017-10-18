//
//  MemberReviewNoticeView.m
//  cdzer
//
//  Created by KEns0n on 31/10/2016.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "MemberReviewNoticeView.h"
#import "UIView+LayoutConstraintHelper.h"

@interface MemberReviewNoticeView ()

@property (weak, nonatomic) IBOutlet UIView *successNoticeContainerView;

@property (weak, nonatomic) IBOutlet UIImageView *successMemberTypeIV;

@property (weak, nonatomic) IBOutlet UIButton *successBtn;


@property (weak, nonatomic) IBOutlet UIView *failNoticeContainerView;

@property (weak, nonatomic) IBOutlet UIImageView *failMemberTypeIV;

@property (weak, nonatomic) IBOutlet UILabel *failTitleLabel;

@property (weak, nonatomic) IBOutlet UILabel *rejectReasonLabel;

@property (weak, nonatomic) IBOutlet UIButton *failBtn;

@property (nonatomic, strong) NSMutableArray *constraints;


@end

@implementation MemberReviewNoticeView


- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.successBtn setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:3.0f];
    
    [[self.failNoticeContainerView viewWithTag:1] setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:5.0f];
    [self.failBtn setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:CGRectGetHeight(self.failBtn.frame)/2.0f];
}

- (void)showView {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [self removeFromSuperview];
    UIWindow *window = UIApplication.sharedApplication.keyWindow;
    [window addSubview:self];
    if (!self.constraints) {
        self.constraints = [self addSelfByFourMarginToSuperview:window];
    }
    [window addConstraints:self.constraints];
    [window bringSubviewToFront:self];
    [self setNeedsUpdateConstraints];
    [self setNeedsDisplay];
    [self setNeedsLayout];
    
}

- (void)showReviewNoticeSuccess:(BOOL)isSuccess memberType:(UserMemberType)memberType withRejectReason:(NSString *)rejectReason {
    [self showView];
    [self updateMemberIconWithMemberType:memberType];
    if (isSuccess) {
        [self showSuccessNoticeWithMemberType:memberType];
    }else {
        [self showFailNoticeWithMemberType:memberType andRejectReason:rejectReason];
    }
}

- (void)updateMemberIconWithMemberType:(UserMemberType)memberType {
    NSString *iconName = @"mrnv_review_silver_medal_icon@3x";
    switch (memberType) {
        case UserMemberTypeOfGoldMedal:
            iconName = @"mrnv_review_gold_medal_icon@3x";
            break;
        case UserMemberTypeOfPlatinum:
            iconName = @"mrnv_review_platinum_icon@3x";
            break;
        case UserMemberTypeOfDiamond:
            iconName = @"mrnv_review_diamond_icon@3x";
            break;
            
        case UserMemberTypeOfNone:
        case UserMemberTypeOfBronzeMedal:
        case UserMemberTypeOfSilverMedal:
        default:
            iconName = @"mrnv_review_silver_medal_icon@3x";
            break;
    }
    UIImage *image = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:iconName ofType:@"png"]];
    self.successMemberTypeIV.image = image;
    self.failMemberTypeIV.image = image;
}

- (void)showSuccessNoticeWithMemberType:(UserMemberType)memberType {
    self.successNoticeContainerView.alpha = 1;
}

- (void)showFailNoticeWithMemberType:(UserMemberType)memberType andRejectReason:(NSString *)rejectReason{
    self.rejectReasonLabel.text = rejectReason;
    self.failNoticeContainerView.alpha = 1;
}

- (IBAction)dismissSelf {
    self.successNoticeContainerView.alpha = 0;
    self.failNoticeContainerView.alpha = 0;
    [self removeFromSuperview];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
