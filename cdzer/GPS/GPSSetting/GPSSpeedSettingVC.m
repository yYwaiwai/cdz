//
//  GPSSpeedSettingVC.m
//  cdzer
//
//  Created by KEns0n on 6/2/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//
#define rowHeight 44
#define topSectionHeight 16.0f
#define normalSectionHeight 16.0f
#import "GPSSpeedSettingVC.h"
#import "InsetsTextField.h"
@interface GPSSSVCell : UITableViewCell
@property (nonatomic, strong) NSDictionary *config;
@end

@implementation GPSSSVCell

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

@interface GPSSpeedSettingVC ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *settingArray;

@property (nonatomic, strong) UISwitch *speedSwitcher;

@property (nonatomic, strong) UITextField *speedTextField;

@property (nonatomic, assign) BOOL voiceSwitchValue;

@property (nonatomic, assign) BOOL speedSwitchValue;

@property (nonatomic, strong) NSString *limitSpeed;
@end

@implementation GPSSpeedSettingVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"超速设置";
    [self setReactiveRules];
    [self componentSetting];
    [self initializationUI];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self getOverSpeedStatsus];
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
    self.settingArray = @[@[@{@"title":@"额定速度设置", @"topBorder":@(YES), @"bottomBorder":@(NO)},
                            @{@"title":@"额定车速", @"topBorder":@(NO),@"bottomBorder":@(YES)}]];
}

- (void)initializationUI {
    self.speedSwitcher = [[UISwitch alloc] init];
    _speedSwitcher.on = NO;
    _speedSwitcher.onTintColor = [UIColor colorWithRed:0.314 green:0.784 blue:0.953 alpha:1.00];
    [_speedSwitcher addTarget:self action:@selector(changeSpeedSettingStatus:) forControlEvents:UIControlEventValueChanged];
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.view.frame), 44.0f)];
    [toolbar setBarStyle:UIBarStyleDefault];
    UIBarButtonItem *spaceButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                target:self
                                                                                action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]initWithTitle:getLocalizationString(@"finish")
                                                                  style:UIBarButtonItemStyleDone
                                                                 target:self
                                                                 action:@selector(hiddenKeyboard)];
    NSArray * buttonsArray = [NSArray arrayWithObjects:spaceButton,doneButton,nil];
    [toolbar setItems:buttonsArray];

    
    self.speedTextField = [[InsetsTextField alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 180.0f, 36.0f)
                                              andEdgeInsetsValue:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 36.0f)];
    _speedTextField.borderStyle = UITextBorderStyleRoundedRect;
    _speedTextField.font = [_speedTextField.font fontWithSize:14];
    _speedTextField.placeholder = @"请输入限制车速";
    _speedTextField.textAlignment = NSTextAlignmentCenter;
    _speedTextField.layer.masksToBounds = YES;
//    _speedTextField.delegate = self;
    _speedTextField.layer.cornerRadius = 5.0f;
    _speedTextField.returnKeyType = UIReturnKeyDone;
    _speedTextField.keyboardType = UIKeyboardTypeNumberPad;
    _speedTextField.inputAccessoryView = toolbar;
    
    UILabel *kmLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetWidth(_speedTextField.frame)-36.0f, 0.0, 36.0f, 36.0f)];
    kmLabel.font = _speedTextField.font;
    kmLabel.textColor = CDZColorOfDeepGray;
    kmLabel.backgroundColor = CDZColorOfLightGray;
    kmLabel.text = @"KM";
    kmLabel.textAlignment = NSTextAlignmentCenter;
    [_speedTextField addSubview:kmLabel];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.contentView.bounds];
    _tableView.backgroundColor = [UIColor colorWithRed:0.961 green:0.961 blue:0.961 alpha:1.00];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.scrollsToTop = YES;
    _tableView.bounces = NO;
    _tableView.tableFooterView = [UIView new];
    [self.contentView addSubview:_tableView];

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    
}

- (void)hiddenKeyboard {
    @weakify(self);
    [UIView animateWithDuration:0.25 animations:^{
        @strongify(self);
        [self.speedTextField resignFirstResponder];
    }];
}

- (void)changeSpeedSettingStatus:(UISwitch *)speedSwitch {
    if (self.speedTextField.text.integerValue==0||[self.speedTextField.text isEqualToString:@""]||!self.speedTextField.text) {
        [SupportingClass showAlertViewWithTitle:@"alert_remind"
                                        message:@"请填写限制速度！"
                                isShowImmediate:YES
                              cancelButtonTitle:@"ok"
                              otherButtonTitles:nil clickedButtonAtIndexWithBlock:nil];
        [speedSwitch setOn:!speedSwitch.on animated:YES];
        return;
    }
    [self hiddenKeyboard];
    [self updateLimitSpeedSettingWithSpeedStatus:self.speedSwitcher.on speed:self.speedTextField.text voiceStatus:self.voiceSwitchValue];
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
    
    GPSSSVCell *cell = [tableView dequeueReusableCellWithIdentifier:CDZKeyOfCellIdentKey];
    if (!cell) {
        cell = [[GPSSSVCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CDZKeyOfCellIdentKey];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        [cell setBackgroundColor:CDZColorOfWhite];
        
        
    }
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    if (indexPath.row == 0) {
        cell.accessoryView = self.speedSwitcher;
        self.speedSwitcher.on = self.speedSwitchValue;
    }else if (indexPath.row == 1) {
        cell.accessoryView = self.speedTextField;
        self.speedTextField.text = self.limitSpeed;
    }
    
    NSDictionary *config = [_settingArray[indexPath.section] objectAtIndex:indexPath.row];
    cell.textLabel.text = config[@"title"];
    cell.textLabel.font = [cell.textLabel.font fontWithSize:14];
    cell.textLabel.textColor = [UIColor colorWithRed:0.392 green:0.392 blue:0.392 alpha:1.00];
//    cell.imageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:config[@"icon"] ofType:@"png"]];
    cell.config = config;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
 
    return rowHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {

    return 16.0f;//(section ==0)?topSectionHeight:normalSectionHeight;
}

#pragma mark- APIs Access Request/* 获取超速设置 */
- (void)getOverSpeedStatsus {
    
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    @weakify(self);
    [[APIsConnection shareConnection] personalGPSAPIsGetAutoOverSpeedSettingWithAccessToken:self.accessToken success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        if (errorCode==0) {
            NSDictionary *settingDetail = responseObject[CDZKeyOfResultKey];
            
            NSString *speedString = settingDetail[@"ratedSpeed"];
            BOOL speedStatus = [settingDetail[@"ratedStatus"] boolValue];
            BOOL voiceStatus =[settingDetail[@"voiceStatus"] boolValue];
            self.voiceSwitchValue = voiceStatus;
            self.voiceSwitchValue = YES;
            self.speedSwitchValue  = speedStatus;
            self.limitSpeed = speedString;
            [self.tableView reloadData];
        }
        
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        
        NSString *message = @"设置失败！发生不明问题！";
        if (error.code==-1009) {
            message = @"设置失败！网络连接失败，请检查网络设置！";
        }
        
        if (error.code==-1001) {
            message = @"设置失败！网络连接逾时，请稍后再试！";
        }
        
        [ProgressHUDHandler showErrorWithStatus:message onView:nil completion:nil];
    }];
}
/* 修改超速设置 */
- (void)updateLimitSpeedSettingWithSpeedStatus:(BOOL)speedStatus speed:(NSString *)speed voiceStatus:(BOOL)voiceStatus {
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    NSNumber *accStatus = [[[DBHandler shareInstance] getAutoRealtimeDataWithDataID:0] objectForKey:@"acc"];
    if (![SupportingClass analyseCarStatus:accStatus.stringValue withParentView:self.view]){
        return;
    }
    [ProgressHUDHandler showHUDWithTitle:@"更新设置中...." onView:nil];
    @weakify(self);
    [[APIsConnection shareConnection] personalGPSAPIsPostAutoOverSpeedSettingUpdateWithAccessToken:vGetUserToken speedStatus:speedStatus speed:@(speed.integerValue) voiceStatus:voiceStatus success:^(NSURLSessionDataTask *operation, id responseObject) {
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        if (errorCode!=0) {
            [ProgressHUDHandler showErrorWithStatus:message onView:nil completion:^{
                
            }];
            return;
        }
        self.speedSwitchValue = self.speedSwitcher.on;
        self.limitSpeed = self.speedTextField.text;
        [ProgressHUDHandler showSuccessWithStatus:@"更新成功！" onView:nil completion:^{
            
        }];
        
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        [ProgressHUDHandler showErrorWithStatus:@"更新失败！" onView:nil completion:^{
        }];
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
