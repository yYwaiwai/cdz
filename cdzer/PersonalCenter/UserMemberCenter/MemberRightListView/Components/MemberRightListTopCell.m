//
//  MemberRightListTopCell.m
//  cdzer
//
//  Created by KEns0n on 09/12/2016.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "MemberRightListTopCell.h"
#import "UserMemberCenterConfig.h"

@interface MemberRightListTopCell()

@property (nonatomic, weak) IBOutlet UIImageView *iconIV;
@property (nonatomic, weak) IBOutlet UILabel *iconTitle;

@property (nonatomic, weak) IBOutlet UIImageView *smallIconIV;
@property (nonatomic, weak) IBOutlet UILabel *smallIconTitle;

@end

@implementation MemberRightListTopCell

- (void)dealloc {
    NSLog(@"dealloc On %@", NSStringFromClass(self.class));
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)updateSettingByIndex:(NSIndexPath *)indexPath andSelected:(BOOL)selected {
    self.smallIconIV.superview.hidden = selected;
    self.iconIV.superview.hidden = !selected;
    NSUInteger itemIdx = indexPath.item;
    if (itemIdx>4) itemIdx = 4;
    itemIdx+=1;
    UIImage *image = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:[NSString stringWithFormat:@"mrl_display_icon_%02d@3x", itemIdx] ofType:@"png"]];
    self.iconIV.image = image;
    self.smallIconIV.image = self.iconIV.image;
    self.iconTitle.text = [UserMemberCenterConfig getMemberTypeNameByType:itemIdx];
    self.smallIconTitle.text = self.iconTitle.text;
}

- (void)imageTransitionReduction {
    [UIView transitionFromView:self.iconIV.superview toView:self.smallIconIV.superview duration:1 options:UIViewAnimationOptionTransitionFlipFromLeft|UIViewAnimationOptionShowHideTransitionViews completion:^(BOOL finished) {
        [self layoutIfNeeded];
    }];
}

- (void)imageTransitionSelection {
    [UIView transitionFromView:self.smallIconIV.superview toView:self.iconIV.superview duration:1 options:UIViewAnimationOptionTransitionFlipFromRight|UIViewAnimationOptionShowHideTransitionViews completion:^(BOOL finished) {
        [self layoutIfNeeded];
    }];
}


@end
