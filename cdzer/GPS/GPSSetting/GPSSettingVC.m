//
//  GPSSettingVC.m
//  cdzer
//
//  Created by KEns0n on 6/2/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//


#define rowHeight 44
#define normalSectionHeight 10.0f
#import "GPSSettingVC.h"
#import "GPSAlertSettingVC.h"
@interface GPSSVCell : UITableViewCell
@property (nonatomic, strong) NSDictionary *config;
@end

@implementation GPSSVCell

- (void)layoutSubviews {
    [super layoutSubviews];
    if ([_config[@"topBorder"] boolValue]) {
        [self setViewBorderWithRectBorder:UIRectBorderTop borderSize:0.5f withColor:[UIColor colorWithRed:0.784f green:0.780f blue:0.800f alpha:1.00f] withBroderOffset:nil];
    }
    if ([_config[@"bottomBorder"] boolValue]) {
        [self setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5f withColor:[UIColor colorWithRed:0.784f green:0.780f blue:0.800f alpha:1.00f] withBroderOffset:nil];
    }
    
}

@end

@interface GPSSettingVC ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *settingArray;

@property (nonatomic, strong) UISwitch *savePowerSwitch;

@end

@implementation GPSSettingVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"GPS设置";
    [self setReactiveRules];
    [self componentSetting];
    [self initializationUI];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self getPowerSaveStatus];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setReactiveRules {
    
}

- (void)componentSetting {
    self.settingArray = @[@[@{@"title":@"点火校正", @"icon":@"GPS_setting_ignition_adjust_icon@3x",
                              @"topBorder":@(YES), @"bottomBorder":@(YES)},
                            @{@"title":@"设备安装设置", @"icon":@"GPS_setting_device_adjust_icon@3x",
                              @"topBorder":@(YES),@"bottomBorder":@(YES)}],
                        @[@{@"title":@"报警设置", @"icon":@"GPS_setting_alert_icon@3x",
                            @"topBorder":@(YES), @"bottomBorder":@(YES)},
                          @{@"title":@"省电设置", @"icon":@"GPS_setting_save_mode_icon@3x",
                            @"topBorder":@(YES), @"bottomBorder":@(YES)}]];
}

- (void)initializationUI {
    self.savePowerSwitch = [[UISwitch alloc] init];
    _savePowerSwitch.on = NO;
    _savePowerSwitch.onTintColor = [UIColor colorWithRed:0.314 green:0.784 blue:0.953 alpha:1.00];
    [_savePowerSwitch addTarget:self action:@selector(changePowerSaveStatus:) forControlEvents:UIControlEventValueChanged];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.contentView.bounds];
    _tableView.backgroundColor = [UIColor colorWithRed:0.961 green:0.961 blue:0.961 alpha:1.00];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.scrollsToTop = YES;
    _tableView.bounces = NO;
    _tableView.tableFooterView = [UIView new];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.contentView addSubview:_tableView];

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    
}

- (void)changePowerSaveStatus:(UISwitch *)powerSwitch {
    [self updatePowerSaveStatus:powerSwitch.on];
}

#pragma mark -  setFlame 点火熄火校正
- (void)startIgnitionSystemCalibration {
    
    [SupportingClass showAlertViewWithTitle:@"熄火低电压校正（一）" message:@"校正前请确保车辆处于熄火状态！" isShowImmediate:YES cancelButtonTitle:@"cancel" otherButtonTitles:@"next_step"
              clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                  if (btnIdx.integerValue == 1) {
                      [self ignitionSystemCalibration:NO];
                  }
    }];
    
}

#pragma mark -  setupDevice 设备配置安装
- (void)startSetupDevice {
    NSNumber *accStatus = [[[DBHandler shareInstance] getAutoRealtimeDataWithDataID:0] objectForKey:@"acc"];
    if (![SupportingClass analyseCarStatus:accStatus.stringValue withParentView:self.view]) return;
    
    [SupportingClass showAlertViewWithTitle:@"设备安装角度校正" message:@"请固定好你的设备，然后进行校正！" isShowImmediate:YES cancelButtonTitle:@"cancel" otherButtonTitles:@"next_step"
              clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                  if (btnIdx.integerValue == 1) {
                      [self autoDeviceCalibration];
                  }
              }];
}

#pragma -mark UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return _settingArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [_settingArray[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    GPSSVCell *cell = [tableView dequeueReusableCellWithIdentifier:CDZKeyOfCellIdentKey];
    if (!cell) {
        cell = [[GPSSVCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CDZKeyOfCellIdentKey];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        [cell setBackgroundColor:CDZColorOfWhite];
        
        
    }
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    if (indexPath.section == 1&& indexPath.row == 1) {
        cell.accessoryView = self.savePowerSwitch;
    }else {
        cell.accessoryView = nil;
    }
    
    NSDictionary *config = [_settingArray[indexPath.section] objectAtIndex:indexPath.row];
    cell.textLabel.text = config[@"title"];
    cell.textLabel.font = [cell.textLabel.font fontWithSize:14];
    cell.textLabel.textColor = [UIColor colorWithRed:0.392 green:0.392 blue:0.392 alpha:1.00];
    cell.imageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:config[@"icon"] ofType:@"png"]];
    cell.config = config;
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
 
    return rowHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {

    return (section ==0)?0:normalSectionHeight;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section==0) {
        if (indexPath.row==0) {
            [self startIgnitionSystemCalibration];
        }
        if (indexPath.row==1) {
            [self startSetupDevice];
        }
    }
    if (indexPath.section==1) {
        @autoreleasepool {
            GPSAlertSettingVC *vc = GPSAlertSettingVC.new;
            [self setDefaultNavBackButtonWithoutTitle];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

#pragma mark- APIs Access Request

- (void)getPowerSaveStatus {
    
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    [ProgressHUDHandler showHUDWithTitle:getLocalizationString(@"loading") onView:nil];
    @weakify(self);
    [self setReloadFuncWithAction:_cmd parametersList:nil];
    [[APIsConnection shareConnection] personalGPSAPIsGetAutoPowerSaveStatusWithAccessToken:self.accessToken success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        if (errorCode==0) {
            BOOL status = [[responseObject[CDZKeyOfResultKey] objectForKey:@"status"] boolValue];
            self.savePowerSwitch.on = status;
        }
        [ProgressHUDHandler dismissHUD];
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        [ProgressHUDHandler dismissHUD];
        if (error.code==-1009) {
            [SupportingClass showAlertViewWithTitle:@"error" message:@"网络连接失败，请检查网络设置！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            }];
            return;
        }
        
        
        if (error.code==-1001) {
            [SupportingClass showAlertViewWithTitle:@"error" message:@"网络连接逾时，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            }];
            return;
        }
        
        [SupportingClass showAlertViewWithTitle:@"error" message:@"网络错误，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
        }];

    }];
}

- (void)updatePowerSaveStatus:(BOOL)status {
    
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    [ProgressHUDHandler showHUDWithTitle:@"更新设置中...." onView:nil];
    @weakify(self);
    [[APIsConnection shareConnection] personalGPSAPIsPostAutoPowerSaveChangeStatusWithAccessToken:self.accessToken status:status success:^(NSURLSessionDataTask *operation, id responseObject) {
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        if (errorCode!=0) {
            [ProgressHUDHandler showErrorWithStatus:message onView:nil completion:nil];
            return;
        }
        [ProgressHUDHandler showSuccessWithStatus:@"更新成功！" onView:nil completion:nil];
        
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        @strongify(self);
        self.savePowerSwitch.on = !self.savePowerSwitch.on;
        [ProgressHUDHandler dismissHUD];
        NSString *message = @"更新失败！未知错误";
        if (error.code==-1009) {
            message = @"网络连接失败，请检查网络设置！";
        }
        
        if (error.code==-1001) {
            message = @"网络连接逾时，请稍后再试！";
        }

        [ProgressHUDHandler showErrorWithStatus:message onView:nil completion:nil];
    }];
}

- (void)ignitionSystemCalibration:(BOOL)status {
    
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    [[APIsConnection shareConnection] personalGPSAPIsPostAutoIgnitionSystemCalibrationWithAccessToken:self.accessToken status:status success:^(NSURLSessionDataTask *operation, id responseObject) {
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        if (errorCode!=0) {
            [SupportingClass addLabelWithFrame:alertFrame content:@"校正失败！" radius:5.0f fontSize:14.0f parentView:self.view isAlertShow:NO pushBlock:^{
            }];
            return;
        }
        if (status) {
            [SupportingClass addLabelWithFrame:alertFrame content:@"校正成功！"  radius:5.0f fontSize:14.0f parentView:self.view isAlertShow:NO pushBlock:^{
            }];
        }else {
            [SupportingClass showAlertViewWithTitle:@"熄火低电压校正（二）" message:@"校正前请确保车辆处于熄火状态！" isShowImmediate:YES cancelButtonTitle:@"cancel" otherButtonTitles:@"next_step"
                      clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                          if (btnIdx.integerValue == 1) {
                              [self ignitionSystemCalibration:YES];
                          }
                      }];
        }
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        
        
        NSString *message = @"校正失败！发生不明问题！";
        if (error.code==-1009) {
            message = @"网络连接失败，请检查网络设置！";
        }
        
        if (error.code==-1001) {
            message = @"网络连接逾时，请稍后再试！";
        }
        
        [ProgressHUDHandler showErrorWithStatus:message onView:nil completion:nil];
        
    }];
}

- (void)autoDeviceCalibration {
    
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    
    [ProgressHUDHandler showHUDWithTitle:@"正在安装中..." onView:nil];
    [[APIsConnection shareConnection] personalGPSAPIsPostAutoDeviceCalibrationWithAccessToken:self.accessToken success:^(NSURLSessionDataTask *operation, id responseObject) {
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        if (errorCode!=0) {
            [ProgressHUDHandler showErrorWithStatus:@"安装失败！" onView:nil completion:nil];
            return;
        }
        [ProgressHUDHandler showSuccessWithStatus:@"安装成功！" onView:nil completion:nil];
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
         [ProgressHUDHandler showErrorWithStatus:@"安装失败！" onView:nil completion:nil];
    }];
}

- (void)handleUserLoginResult:(BOOL)isSuccess fromAlert:(BOOL)fromAlert{
    if (isSuccess) {
        if (UserBehaviorHandler.shareInstance.getUserType!=CDZUserTypeOfGPSWithODBUser) {
            [SupportingClass showAlertViewWithTitle:nil message:@"登陆的账号并没有绑定GPS或不ODB功能，请重新登录已绑定含ODB功能的GPS账号" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                [self.navigationController popToRootViewControllerAnimated:YES];
            }];
            return;
        }
        NSLog(@"success reload function %d", [self executeReloadFunction]);
    }else {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
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
