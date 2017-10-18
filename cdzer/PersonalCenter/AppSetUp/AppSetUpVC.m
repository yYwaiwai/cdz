//
//  AppSetUpVC.m
//  cdzer
//
//  Created by 车队长 on 16/8/22.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "AppSetUpVC.h"
#import "UserAgreementVC.h"
#import "FeedbackVC.h"
#import "AboutUsVC.h"
#import "BDPushConfigDTO.h"


@interface AppSetUpVC ()

@property (weak, nonatomic) IBOutlet UISwitch *pushSwitch;

@property (weak, nonatomic) IBOutlet UIControl *userAgreementControl;

@property (weak, nonatomic) IBOutlet UIControl *feedbackControl;

@property (weak, nonatomic) IBOutlet UIControl *evaluateControl;

@property (weak, nonatomic) IBOutlet UIControl *aboutUsControl;

/// 推送来的数据
@property (nonatomic, strong) BDPushConfigDTO *pushDTO;

@end

@implementation AppSetUpVC
- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title=@"设置";
    
    self.pushDTO = [DBHandler.shareInstance getBDAPNSConfigData];
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"isOnPush"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isOnPush"];
    }
    BOOL isOnPush = [[NSUserDefaults.standardUserDefaults objectForKey:@"isOnPush"] boolValue];
    _pushSwitch.on = isOnPush;
    [_pushSwitch addTarget:self action:@selector(updatePushOn:) forControlEvents:UIControlEventValueChanged];
    NSString *channelID = _pushDTO.channelID;
    NSString *deviceToken = _pushDTO.deviceToken;
    NSString *apnsUserID = _pushDTO.bdpUserID;
    if ([channelID isEqualToString:@""]||[deviceToken isEqualToString:@""]||[apnsUserID isEqualToString:@""]) {
        _pushSwitch.enabled  = NO;
        _pushSwitch.on = NO;
        [self updatePushSwitchStatusWithMessageON:NO channelID:@"" deviceToken:@"" apnsUserID:@"" showHud:NO];
    }

    
    
    [self.userAgreementControl setViewBorderWithRectBorder:UIRectBorderBottom|UIRectBorderTop borderSize:0.5f withColor:[UIColor colorWithHexString:@"CDCED4"] withBroderOffset:nil];
    [self.feedbackControl setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5f withColor:[UIColor colorWithHexString:@"CDCED4"] withBroderOffset:nil];
    [self.evaluateControl setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5f withColor:[UIColor colorWithHexString:@"CDCED4"] withBroderOffset:nil];
    [self.aboutUsControl setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5f withColor:[UIColor colorWithHexString:@"CDCED4"] withBroderOffset:nil];
    [self.userAgreementControl addTarget:self action:@selector(userAgreement) forControlEvents:UIControlEventTouchUpInside];
     [self.feedbackControl addTarget:self action:@selector(feedback) forControlEvents:UIControlEventTouchUpInside];
     [self.evaluateControl addTarget:self action:@selector(evaluate) forControlEvents:UIControlEventTouchUpInside];
     [self.aboutUsControl addTarget:self action:@selector(aboutUs) forControlEvents:UIControlEventTouchUpInside];

}

- (void)userAgreement {
    UserAgreementVC*vc=[[UserAgreementVC alloc]init];
    vc.showPageTitleAndURL = NO;
    vc.title = @"用户协议";
    [self setDefaultNavBackButtonWithoutTitle];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)feedback {
    FeedbackVC*vc = [[FeedbackVC alloc]init];
    [self setDefaultNavBackButtonWithoutTitle];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)evaluate {
    [UIApplication.sharedApplication openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=919374012"]];
}

- (void)aboutUs {
    AboutUsVC*vc=[[AboutUsVC alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
    [self setDefaultNavBackButtonWithoutTitle];
}

- (void)updatePushOn:(UISwitch *)switchs {
    NSString *channelID = _pushDTO.channelID;
    NSString *deviceToken = _pushDTO.deviceToken;
    NSString *apnsUserID = _pushDTO.bdpUserID;
    if ([channelID isEqualToString:@""]||[deviceToken isEqualToString:@""]||[apnsUserID isEqualToString:@""]) {
        if (switchs.on) {
            [SupportingClass showAlertViewWithTitle:@"" message:@"" isShowImmediate:YES cancelButtonTitle:@"" otherButtonTitles:@"" clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                
            }];
        }
        channelID = @"";
        deviceToken = _pushDTO.deviceToken;
        apnsUserID = _pushDTO.bdpUserID;
        [_pushSwitch setOn:NO animated:YES];
        [[NSUserDefaults standardUserDefaults] setBool:_pushSwitch.on forKey:@"isOnPush"];
    }
    [[NSUserDefaults standardUserDefaults] setBool:switchs.on forKey:@"isOnPush"];
    [self updatePushSwitchStatusWithMessageON:switchs.on channelID:channelID deviceToken:deviceToken apnsUserID:apnsUserID showHud:YES];
}


- (void)updatePushSwitchStatusWithMessageON:(BOOL)messageON channelID:(NSString *)channelID deviceToken:(NSString *)deviceToken apnsUserID:(NSString *)apnsUserID showHud:(BOOL)showHud{
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    if (showHud) {
        [ProgressHUDHandler showHUD];
    }
    @weakify(self);
    [APIsConnection.shareConnection personalCenterAPNSSettingAlertListWithAccessToken:self.accessToken messageON:messageON channelID:channelID deviceToken:deviceToken apnsUserID:apnsUserID success:^(NSURLSessionDataTask *operation, id responseObject) {
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        @strongify(self);
        if (errorCode!=0) {
            self.pushSwitch.on = !self.pushSwitch.on;
            if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:showHud]) return;
            [ProgressHUDHandler showErrorWithStatus:messageON?@"开启失败":@"关闭失败" onView:nil completion:nil];
            [[NSUserDefaults standardUserDefaults] setBool:self.pushSwitch.on forKey:@"isOnPush"];
            return;
        }
        if (showHud) {
            [ProgressHUDHandler showSuccessWithStatus:messageON?@"开启成功":@"关闭成功" onView:nil completion:nil];
        }
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        if (showHud) {
            [ProgressHUDHandler showErrorWithStatus:messageON?@"开启失败":@"关闭失败" onView:nil completion:nil];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
