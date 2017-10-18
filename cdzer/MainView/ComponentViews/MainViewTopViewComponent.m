//
//  MainViewTopViewComponent.m
//  cdzer
//
//  Created by KEns0nLau on 6/16/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "MainViewTopViewComponent.h"
#import "DBHandler.h"
#import "MyCarVC.h"
#import "MessageAlertVC.h"
#import "XIBBaseViewController.h"
#import <M13BadgeView/M13BadgeView.h>

@interface MainViewTopViewComponent ()

@property (nonatomic, strong) M13BadgeView *badgeView;

@property (nonatomic, weak) IBOutlet UIView *autosInfoView;

@property (nonatomic, weak) IBOutlet UIControl *reminderView;

@property (nonatomic, weak) IBOutlet UIView *autosLogoContainerView;

@property (nonatomic, weak) IBOutlet UIImageView *autosLogoIV;

@property (nonatomic, weak) IBOutlet UILabel *autosUpperLabel;

@property (nonatomic, weak) IBOutlet UILabel *autosBottomLabel;

@property (nonatomic, weak) IBOutlet UILabel *mileLabel;

@property (nonatomic, weak) IBOutlet UILabel *registrTimeLabel;

@property (nonatomic, strong) UIImage *defaultLogoImage;

@property (nonatomic, strong) UserAutosInfoDTO *autosInfoDTO;

@property (weak, nonatomic) IBOutlet UIButton *messageAlertButton;

@end

@implementation MainViewTopViewComponent

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)awakeFromNib {
    [super awakeFromNib];
    NSLog(@"%@", NSStringFromCGRect(self.frame));
    self.defaultLogoImage = self.autosLogoIV.image;
}

- (void)viewWillAppear {
    self.autosInfoDTO = [DBHandler.shareInstance getUserAutosDetail];
    [self initializationUI];
    [self updataUIDataStatus];
    
}

- (void)initializationUI {
    @autoreleasepool {
        if (!self.badgeView) {
            self.badgeView = [[M13BadgeView alloc] initWithFrame:CGRectMake(0, 0, 8.0, 8.0)];
            self.badgeView.font = [UIFont systemFontOfSize:11.0];
//            self.badgeView.textColor = [UIColor colorWithRed:0.961 green:0.404 blue:0.412 alpha:1.00];
            self.badgeView.badgeBackgroundColor = CDZColorOfRed;
            self.badgeView.borderColor = CDZColorOfWhite;
//            self.badgeView.hidesWhenZero = YES;
            self.badgeView.borderWidth = 1.0f;
            self.badgeView.cornerRadius = ceilf(CGRectGetHeight(self.badgeView.frame)/2.0f);
            self.badgeView.horizontalAlignment = M13BadgeViewHorizontalAlignmentCenter;
            self.badgeView.verticalAlignment = M13BadgeViewVerticalAlignmentMiddle;
        }
    }
}


- (void)updataUIDataStatus {
    @autoreleasepool {
        if (vGetUserToken) {
            if (!self.autosInfoDTO||
                [self.autosInfoDTO.brandID isEqualToString:@""]||
                [self.autosInfoDTO.dealershipID isEqualToString:@""]||
                [self.autosInfoDTO.seriesID isEqualToString:@""]||
                [self.autosInfoDTO.modelID isEqualToString:@""]) {
                self.autosInfoView.hidden = YES;
                self.autosLogoContainerView.hidden = YES;
                self.reminderView.hidden = NO;
                self.autosLogoIV.image = self.defaultLogoImage;
            }else {
                self.autosInfoView.hidden = NO;
                self.autosLogoContainerView.hidden = NO;
                self.reminderView.hidden = YES;
                self.autosLogoIV.image = self.defaultLogoImage;
                if ([self.autosInfoDTO.brandImgURL isContainsString:@"http"]) {
                    [self.autosLogoIV setImageWithURL:[NSURL URLWithString:self.autosInfoDTO.brandImgURL] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                }
                
                self.autosUpperLabel.text = [self.autosInfoDTO.brandName stringByAppendingFormat:@" %@", self.autosInfoDTO.dealershipName];
                if ([self.autosInfoDTO.dealershipName isContainsString:self.autosInfoDTO.brandName]) {
                    self.autosUpperLabel.text = self.autosInfoDTO.dealershipName;
                }
                if (IS_IPHONE_5||IS_IPHONE_4_OR_LESS) {
                    self.autosBottomLabel.text = [self.autosInfoDTO.seriesName stringByAppendingFormat:@"\n%@", self.autosInfoDTO.modelName];
                }else {
                    self.autosBottomLabel.text = [self.autosInfoDTO.seriesName stringByAppendingFormat:@" %@", self.autosInfoDTO.modelName];
                }
                
                if ([self.autosInfoDTO.mileage isEqualToString:@""]) {
                    self.mileLabel.text = @"请编辑";
                }else {
                    self.mileLabel.text = [NSString stringWithFormat:@"%@公里", self.autosInfoDTO.mileage];
                }
                
                if ([self.autosInfoDTO.registrTime isEqualToString:@""]) {
                    self.registrTimeLabel.text = @"请编辑";
                }else {
                    NSMutableArray *dateTimeComponents = [[self.autosInfoDTO.registrTime componentsSeparatedByString:@"-"] mutableCopy];
                    [dateTimeComponents removeLastObject];
                    self.registrTimeLabel.text = [dateTimeComponents componentsJoinedByString:@"-"];
                }
            }
            
            [self.badgeView removeFromSuperview];
            [self.messageAlertButton addSubview:self.badgeView];
            self.badgeView.alignmentShift=CGSizeMake(-7, 7);
            self.badgeView.horizontalAlignment = M13BadgeViewHorizontalAlignmentRight;
            self.badgeView.verticalAlignment = M13BadgeViewVerticalAlignmentTop;
            self.badgeView.text = [SupportingClass verifyAndConvertDataToString:@""];
            if ([UserBehaviorHandler.shareInstance.pcIndicateInfo.UnMessageCount isEqualToString:@"0"]) {
                self.badgeView.hidden = YES;
            }

        }else {
            self.autosInfoView.hidden = YES;
            self.autosLogoContainerView.hidden = YES;
            self.reminderView.hidden = NO;
            self.autosLogoIV.image = self.defaultLogoImage;
        }
    }
}

- (IBAction)showLoginView {
    if (vGetUserToken) {
        if (!self.autosInfoDTO||
            [self.autosInfoDTO.brandID isEqualToString:@""]||
            [self.autosInfoDTO.dealershipID isEqualToString:@""]||
            [self.autosInfoDTO.seriesID isEqualToString:@""]||
            [self.autosInfoDTO.modelID isEqualToString:@""]) {
            [self pushToAutosInfoVC];
        }
    }else {
        [self presentLoginView];
    }
}

- (IBAction)pushToAutosInfoVC {
    @autoreleasepool {
        if ([UIApplication.sharedApplication.keyWindow.rootViewController isKindOfClass:BaseNavigationController.class]) {
            if (!vGetUserToken) {
                [self presentLoginView];
                return;
            }
            BaseNavigationController *nav = (BaseNavigationController*)UIApplication.sharedApplication.keyWindow.rootViewController;
            if ([nav.topViewController respondsToSelector:@selector(setNavBackButtonTitleOrImage:titleColor:)]) {
                [nav.topViewController setDefaultNavBackButtonWithoutTitle];
            }
            MyCarVC *vc = [MyCarVC new];
            vc.wasSubmitAfterLeave = YES;
            [nav pushViewController:vc animated:YES];
        }
    }
}

- (IBAction)pushToMessageAlertVC {
    @autoreleasepool {
        if ([UIApplication.sharedApplication.keyWindow.rootViewController isKindOfClass:BaseNavigationController.class]) {
            if (!vGetUserToken) {
                [self presentLoginView];
                return;
            }
            BaseNavigationController *nav = (BaseNavigationController*)UIApplication.sharedApplication.keyWindow.rootViewController;
            if ([nav.topViewController respondsToSelector:@selector(setNavBackButtonTitleOrImage:titleColor:)]) {
                [nav.topViewController setDefaultNavBackButtonWithoutTitle];
            }
            MessageAlertVC *vc = [MessageAlertVC new];
            vc.isNormalAlertMessage = YES;
            [nav pushViewController:vc animated:YES];
        }
    }
}

- (void)presentLoginView {
    @autoreleasepool {
        BaseNavigationController *nav = (BaseNavigationController*)UIApplication.sharedApplication.keyWindow.rootViewController;
        
        if ([nav.topViewController isKindOfClass:BaseTabBarController.class]){
            if ([[(BaseTabBarController *)nav.topViewController selectedViewController] isKindOfClass:[BaseViewController class]]) {
                BaseViewController *bvc = (BaseViewController *)[(BaseTabBarController *)nav.topViewController selectedViewController];
                if ([bvc respondsToSelector:@selector(viewWillDisappearShoulPassIt)]) {
                    [bvc setViewWillDisappearShoulPassIt:YES];
                }
                [bvc presentLoginViewWithBackTitle:nil animated:YES completion:nil];
                
            }else if ([[(BaseTabBarController *)nav.topViewController selectedViewController] isKindOfClass:[XIBBaseViewController class]]) {
                XIBBaseViewController *xbvc = (XIBBaseViewController *)[(BaseTabBarController *)nav.topViewController selectedViewController];
                if ([xbvc respondsToSelector:@selector(viewWillDisappearShoulPassIt)]) {
                    [xbvc setViewWillDisappearShoulPassIt:YES];
                }
                [xbvc presentLoginViewWithBackTitle:nil animated:YES completion:nil];
                
            }else if ([[(BaseTabBarController *)nav.topViewController selectedViewController] isKindOfClass:[BaseTableViewController class]]) {
                BaseTableViewController *btvc = (BaseTableViewController *)[(BaseTabBarController *)nav.topViewController selectedViewController];
                if ([btvc respondsToSelector:@selector(viewWillDisappearShoulPassIt)]) {
                    [btvc setViewWillDisappearShoulPassIt:YES];
                }
                [btvc presentLoginViewWithBackTitle:nil animated:YES completion:nil];
            }
            
        }else if ([nav.topViewController isKindOfClass:[BaseViewController class]]) {
            BaseViewController *bvc = (BaseViewController *)nav.topViewController;
            if ([bvc respondsToSelector:@selector(viewWillDisappearShoulPassIt)]) {
                [bvc setViewWillDisappearShoulPassIt:YES];
            }
            [bvc presentLoginViewWithBackTitle:nil animated:YES completion:nil];
            
        }else if ([nav.topViewController isKindOfClass:[XIBBaseViewController class]]) {
            XIBBaseViewController *xbvc = (XIBBaseViewController *)nav.topViewController;
            if ([xbvc respondsToSelector:@selector(viewWillDisappearShoulPassIt)]) {
                [xbvc setViewWillDisappearShoulPassIt:YES];
            }
            [xbvc presentLoginViewWithBackTitle:nil animated:YES completion:nil];
            
        }else if ([nav.topViewController isKindOfClass:[BaseTableViewController class]]) {
            BaseTableViewController *btvc = (BaseTableViewController *)nav.topViewController;
            if ([btvc respondsToSelector:@selector(viewWillDisappearShoulPassIt)]) {
                [btvc setViewWillDisappearShoulPassIt:YES];
            }
            [btvc presentLoginViewWithBackTitle:nil animated:YES completion:nil];
        }
    }
}

@end
