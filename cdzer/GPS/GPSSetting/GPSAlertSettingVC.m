//
//  GPSAlertSettingVC.m
//  cdzer
//
//  Created by KEns0n on 6/2/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//


#define rowHeights 44
#define normalSectionHeights 10.0f
#define kBaseSwithTag 200
#define kBaseSwithTag 200
#import "GPSAlertSettingVC.h"
#import "GPSElectricFencingVC.h"
#import "MoresetDto.h"
#import "OverSpeedSettingView.h"
#import "GPSSpeedSettingVC.h"
#import "UIView+Borders.h"


@interface GPSAlertSettingVC ()<UITableViewDataSource, UITableViewDelegate>{
    NSString* _isOpen;
    NSString* _isNotOpen;
    NSString* _isSet;
    NSString* _isNotSet;
}

//@property (nonatomic, strong) OverSpeedSettingView *ossView;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *settingArray;

@property (nonatomic, strong) NSMutableDictionary *objectContainerByIDList;

@property (nonatomic, strong) NSDictionary *statusDetial;

@end

@implementation GPSAlertSettingVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"报警设置";
    [self setReactiveRules];
    [self componentSetting];
    [self initializationUI];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:CDZNotiKeyOfManualUpdateAutoGPSInfo object:nil];
    [self getAutoPowerAndOilControlStatus];
//    [self getOverSpeedStatsus];
    [self getAllSettingStatus];
    
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
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(getAllSettingStatus) name:@"updateAllSettingStatus" object:nil];
    _isOpen = getLocalizationString(@"home_security_setting_open");
    _isNotOpen = getLocalizationString(@"home_security_setting_no_open");
    _isSet = getLocalizationString(@"home_security_setting_set");
    _isNotSet = getLocalizationString(@"home_security_setting_no_set");
    
//    * cf 侧翻 （1.开启，0.关闭）
//    * pz 碰撞 （1.开启，0.关闭）
//    * dpddy 电瓶低电压（1.开启，0.关闭）
//    * tc 拖车（1.开启，0.关闭）
//    * dd 断电（1.开启，0.关闭）
//    * fdlb 防盗喇叭（1.开启，0.关闭）
//    * pljs 疲劳驾驶（1.开启，0.关闭）
//    * alarmTime 报警时间（1.开启，0.关闭）
//    * imei 设备号
//    * defences 原地设防（1.开启，0.关闭）
//    * ratedStatus 超速设置开关
//    * ratedSpeed 速度
    
    
//        NSString* j_imei = [resultDic objectForKey:@"imei"];
//        NSString* j_speedSet = [resultDic objectForKey:@"speedSet"];

//        NSString* j_cf = [resultDic objectForKey:@"cf"];
//        NSString* j_pz = [resultDic objectForKey:@"pz"];
//        NSString* j_dpddy = [resultDic objectForKey:@"dpddy"];
//        NSString* j_tc = [resultDic objectForKey:@"tc"];
//        NSString* j_dd = [resultDic objectForKey:@"dd"];
//        NSString* j_fdlb = [resultDic objectForKey:@"fdlb"];
//        NSString* j_pljs = [resultDic objectForKey:@"pljs"];
//        NSString* j_defences = [resultDic objectForKey:@"defences"];
//        NSString* j_urgencyMessage = [resultDic objectForKey:@"urgencyMessage"];
//        NSString *j_speedSet = [resultDic objectForKey:@"ratedStatus"];
//        NSString* j_alarmTime = [resultDic objectForKey:@"alarmTime"];
//        NSString *electronicFence = [resultDic objectForKey:@"electronicFence"];
    
    self.objectContainerByIDList = [NSMutableDictionary dictionary];
    self.settingArray = [@[
//                           @[@{@"title":@"home_security_setting_0",@"icon":@"Home_SecuritySetting_0",@"height":@(rowHeights),@"valueForKey":@"electronicFence",
//                               @"type":@"switchOfText"}],
//                           
//                           @[@{@"title":@"space",@"height":@(normalSectionHeights)}],
//                           
//                           @[@{@"title":@"home_security_setting_1",@"icon":@"Home_SecuritySetting_1",@"height":@(rowHeights),@"valueForKey":@"urgencyMessage",
//                               @"type":@"setOfText"}],
//                           @[@{@"title":@"space",@"height":@(normalSectionHeights)}],
                           
                           @[@{@"title":@"home_security_setting_2",@"height":@(rowHeights),@"valueForKey":@"ratedStatus",
                               @"type":@"setOfText"}],
                           @[@{@"title":@"space",@"height":@(normalSectionHeights)}],
                           
                           
                           @[@{@"title":@"home_security_setting_3",@"icon":@"",@"height":@(rowHeights),@"valueForKey":@"cf",
                               @"type":@"switch",@"selector":NSStringFromSelector(@selector(updateAutoRoleAlertStatus:))},
                             @{@"title":@"home_security_setting_4",@"icon":@"",@"height":@(rowHeights),@"valueForKey":@"pz",
                               @"type":@"switch",@"selector":NSStringFromSelector(@selector(updateAutoImpactAlertStatus:))},
                             @{@"title":@"home_security_setting_5",@"icon":@"",@"height":@(rowHeights),@"valueForKey":@"dpddy",
                               @"type":@"switch",@"selector":NSStringFromSelector(@selector(updateAutoBatteryLowAlertStatus:))},
//                             @{@"title":@"home_security_setting_10",@"icon":@"",@"height":@(rowHeights),@"valueForKey":@"",
//                               @"type":@"switch",@"selector":NSStringFromSelector(@selector(updateAutoPowerAndOilControlStatus:))}
                             ],
                           @[@{@"title":@"space",@"height":@(normalSectionHeights)}],
                           
                           @[@{@"title":@"home_security_setting_6",@"icon":@"",@"height":@(rowHeights),@"valueForKey":@"tc",
                               @"type":@"switch",@"selector":NSStringFromSelector(@selector(updateAutoTrailingAlertStatus:))},
                             @{@"title":@"home_security_setting_7",@"icon":@"",@"height":@(rowHeights),@"valueForKey":@"dd",
                               @"type":@"switch",@"selector":NSStringFromSelector(@selector(updateAutoODBRemoveAlertStatus:))},
                             @{@"title":@"home_security_setting_8",@"icon":@"",@"height":@(rowHeights),@"valueForKey":@"fdlb",
                               @"type":@"switch",@"selector":NSStringFromSelector(@selector(updateAutoSecurityAlertStatus:))},
//                             @{@"title":@"home_security_setting_9",@"icon":@"",@"height":@(rowHeights),@"valueForKey":@"pljs",
//                               @"type":@"switch",@"selector":NSStringFromSelector(@selector(updateAutoFatigueDrivingStatus:))}
                             ],] mutableCopy];
    
    @weakify(self);
    [_settingArray enumerateObjectsUsingBlock:^(id sectionObj, NSUInteger sectionIdx, BOOL *stop) {
        @strongify(self);
        [(NSArray *)sectionObj enumerateObjectsUsingBlock:^(id rowObj, NSUInteger rowIdx, BOOL *stop) {
            if (![rowObj[@"title"] isEqualToString:@"space"]) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:rowIdx inSection:sectionIdx];
                NSString * stringOfSelector = rowObj[@"selector"];
                [self setupWithGetSwitcherORStringWithType:rowObj[@"type"] indexPath:indexPath withSelector:stringOfSelector];
            }
        }];
        
    }];
}

- (void)initializationUI {
    
    self.tableView = [[UITableView alloc] initWithFrame:self.contentView.bounds];
    _tableView.backgroundColor = [UIColor colorWithRed:0.961 green:0.961 blue:0.961 alpha:1.00];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.scrollsToTop = YES;
    _tableView.bounces = NO;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.tableFooterView = [UIView new];
    [self.contentView addSubview:_tableView];

    
//    self.ossView = [[OverSpeedSettingView alloc] initWithFrame:self.contentView.bounds];
//    [self.view addSubview:_ossView];
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    
}

- (id)setupWithGetSwitcherORStringWithType:(NSString *)type indexPath:(NSIndexPath *)indexPath withSelector:(NSString *)stringOfSelector {
    /* 备用 */
    
//    @autoreleasepool {
//        __block UISwitch * statusSwitcher = nil;
//        NSInteger tag = kBaseSwithTag+indexPath.section*10+indexPath.row;
//        NSMutableArray *arraylist = _switcherByIDList[@(indexPath.section).stringValue];
//        if (!arraylist) arraylist = [NSMutableArray array];
//        
//        [arraylist enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//            if ([obj isKindOfClass:[UISwitch class]]) {
//                if (statusSwitcher.tag == tag) {
//                    statusSwitcher = (UISwitch *)obj;
//                }
//            }
//        }];
//        
//        if (!statusSwitcher) {
//            statusSwitcher = [[UISwitch alloc]init];
//            statusSwitcher.on = NO;
//            [arraylist addObject:statusSwitcher];
//            [_switcherByIDList setObject:arraylist forKey:@(indexPath.section).stringValue];
//            
//            if (stringOfSelector||![stringOfSelector isEqualToString:@""]){
//                SEL selector = NSSelectorFromString(stringOfSelector);
//                if ([self respondsToSelector:selector]){
//                    [statusSwitcher addTarget:self action:selector forControlEvents:UIControlEventValueChanged];
//                }
//            }
//        }
//        
//        
//        return statusSwitcher;
//    }
    
    
    @autoreleasepool {
        NSInteger tag = kBaseSwithTag+indexPath.section*10+indexPath.row;
        id statusSwitcherOrString = _objectContainerByIDList[@(tag).stringValue];
        if (!statusSwitcherOrString) {
            if ([type isEqualToString:@"setOfText"]){
                [_objectContainerByIDList setObject:_isNotSet forKey:@(tag).stringValue];
            }
            
            if ([type isEqualToString:@"switchOfText"]){
                [_objectContainerByIDList setObject:self->_isNotOpen forKey:@(tag).stringValue];
            }
            
            if ([type isEqualToString:@"switch"]) {
                statusSwitcherOrString = [[UISwitch alloc]init];
                [(UISwitch *)statusSwitcherOrString setOn:NO];
                [(UISwitch *)statusSwitcherOrString setTag:tag];
                
                [(UISwitch *)statusSwitcherOrString setOnTintColor:[UIColor colorWithRed:0.314 green:0.784 blue:0.953 alpha:1.00]];
                [_objectContainerByIDList setObject:statusSwitcherOrString forKey:@(tag).stringValue];
                
                if (stringOfSelector||![stringOfSelector isEqualToString:@""]){
                    SEL selector = NSSelectorFromString(stringOfSelector);
                    if ([self respondsToSelector:selector]){
                        [(UISwitch *)statusSwitcherOrString addTarget:self action:selector forControlEvents:UIControlEventValueChanged];
                    }
                }

            }
        
        }
        
        
        return statusSwitcherOrString;
    }

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
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CDZKeyOfCellIdentKey];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CDZKeyOfCellIdentKey];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell setBackgroundColor:CDZColorOfWhite];
        
    }
    @autoreleasepool {
        
        NSArray *cellSublayer = [NSArray arrayWithArray:cell.layer.sublayers];
        [cellSublayer enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[CALayer class]]) {
                CALayer *layer = (CALayer *)obj;
                if ([layer.name isEqualToString:@"topBorder"]) [layer removeFromSuperlayer];
                if ([layer.name isEqualToString:@"bottomBorder"]) [layer removeFromSuperlayer];
            }
        }];
        cellSublayer = nil;
        cell.accessoryView = nil;
        cell.textLabel.text = nil;
        cell.detailTextLabel.text = nil;
        cell.textLabel.font = [cell.textLabel.font fontWithSize:14];
        cell.textLabel.textColor = [UIColor colorWithRed:0.392 green:0.392 blue:0.392 alpha:1.00];
        cell.detailTextLabel.font = [cell.textLabel.font fontWithSize:14];
        cell.detailTextLabel.textColor = [UIColor colorWithRed:0.565 green:0.565 blue:0.565 alpha:1.00];
        cell.imageView.image = nil;
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        NSDictionary *config = [_settingArray[indexPath.section] objectAtIndex:indexPath.row];
        NSString *title = getLocalizationString(config[@"title"]);
        cell.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(tableView.frame), [config[@"height"] floatValue]);
        
        
        if ([title isEqualToString:@"space"]) {
            
            cell.backgroundColor = _tableView.backgroundColor;
            CALayer *topLayer = [cell createTopBorderWithHeight:0.5 andColor:[UIColor colorWithRed:0.784f green:0.780f blue:0.800f alpha:1.00f]];
            topLayer.name = @"topBorder";
            [cell.layer addSublayer:topLayer];
            if (_settingArray.count!=indexPath.section+1) {
                CALayer *bottomLayer = [cell createBottomBorderWithHeight:0.5 andColor:[UIColor colorWithRed:0.784f green:0.780f blue:0.800f alpha:1.00f]];
                bottomLayer.name = @"bottomBorder";
                [cell.layer addSublayer:bottomLayer];
            }
            
        }else {
            
            cell.backgroundColor = CDZColorOfWhite;
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            cell.textLabel.text = title;
            cell.imageView.image = nil;
            if(config[@"icon"]&&![config[@"icon"] isEqualToString:@""]) cell.imageView.image = [UIImage imageNamed:config[@"icon"]];
           
            if (indexPath.row>0) {
                
                CGFloat leftOffset = 15.0f+((cell.imageView.image)?15.0f+cell.imageView.image.size.width:0);
                CALayer *topLayer = [cell createTopBorderWithHeight:0.5
                                                              color:[UIColor colorWithRed:0.784f green:0.780f blue:0.800f alpha:1.00f]
                                                         leftOffset:leftOffset
                                                        rightOffset:0.0f
                                                       andTopOffset:0.0f];
                topLayer.name = @"topBorder";
                [cell.layer addSublayer:topLayer];
            }
            
            if (config[@"type"]&&![config[@"type"] isEqualToString:@""]) {
                NSString * stringOfSelector = config[@"selector"];
                id object = [self setupWithGetSwitcherORStringWithType:config[@"type"] indexPath:indexPath withSelector:stringOfSelector];
                
                if ([object isKindOfClass:[NSString class]]){
                    cell.detailTextLabel.text = (NSString *)object;
                    
                }
        
                if ([object isKindOfClass:[UISwitch class]]) {
                    cell.accessoryView = (UISwitch *)object;
                }
            }
            
            
            
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *config = [_settingArray[indexPath.section] objectAtIndex:indexPath.row];
    return [config[@"height"] floatValue];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (indexPath.section==1) {
//        @autoreleasepool {
//            GPSElectricFencingVC *vc = [GPSElectricFencingVC new];
//            [self setDefaultNavBackButtonWithoutTitle];
//            [self.navigationController pushViewController:vc animated:YES];
//        }
//    }
//    
//    if (indexPath.section==2) {
//        @autoreleasepool {
//            GPSElectricFencingVC *vc = [GPSElectricFencingVC new];
//            [self setDefaultNavBackButtonWithoutTitle];
//            [self.navigationController pushViewController:vc animated:YES];
//        }
//    }
//    
//    if (indexPath.section==5) {
//        [self.ossView showView];
//    }
//    
    if (indexPath.section==0) {
//        [self.ossView showView];
        [self pushToGPSSpeedSettingVC];
    }
}

- (void)pushToGPSSpeedSettingVC {
    @autoreleasepool {
        GPSSpeedSettingVC *vc = [GPSSpeedSettingVC new];
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

- (void)updateAllSettingStatus {
    @autoreleasepool {
        if (!self.statusDetial) return;
        
        @weakify(self);
        [_settingArray enumerateObjectsUsingBlock:^(id sectionObj, NSUInteger sectionIdx, BOOL *stop) {
            [(NSArray*)sectionObj enumerateObjectsUsingBlock:^(id rowObj, NSUInteger rowIdx, BOOL *stop) {
                @strongify(self);
                NSInteger tag = kBaseSwithTag+sectionIdx*10+rowIdx;
                id pointer = self.objectContainerByIDList[@(tag).stringValue];
                if (pointer!=nil&&![rowObj[@"title"] isEqualToString:@"space"]) {
                    BOOL status = NO;
                    NSString *key = rowObj[@"valueForKey"];
                    
                    if (key||![key isEqualToString:@""]) {
                        status = [self.statusDetial[key] boolValue];
                        
                        if ([pointer isKindOfClass:[UISwitch class]]) {
                            [(UISwitch*)pointer setOn:status];
                            
                        }
                        
                        if ([pointer isKindOfClass:[NSString class]]) {
                            NSString *string = @"";
                            if ([rowObj[@"type"] isEqualToString:@"setOfText"]){
                                string = status?self->_isSet:self->_isNotSet;
                            }
                            
                            if ([rowObj[@"type"] isEqualToString:@"switchOfText"]){
                                string = status?self->_isOpen:self->_isNotOpen;
                            }
                            
                            
                            [self.objectContainerByIDList setObject:string forKey:@(tag).stringValue];
                        }
                    }
                }
            }];
        }];
        [self.tableView reloadData];
    }
    
}

#pragma mark- APIs Access Request
/* 获取安全设置 */
- (void)getAllSettingStatus {
    
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    [ProgressHUDHandler showHUDWithTitle:getLocalizationString(@"loading") onView:nil];
    @weakify(self);
    [[APIsConnection shareConnection] personalGPSAPIsGetAutoAllAlertStatusListWithAccessToken:self.accessToken success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        if (errorCode==0) {
            self.statusDetial = responseObject[CDZKeyOfResultKey];
            [self updateAllSettingStatus];
        }
        [ProgressHUDHandler dismissHUD];
        
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        [ProgressHUDHandler dismissHUD];
    }];
}

/* 修改侧翻设置 */
- (void)updateAutoRoleAlertStatus:(UISwitch *)switcher {
    NSNumber *accStatus = [[[DBHandler shareInstance] getAutoRealtimeDataWithDataID:0] objectForKey:@"acc"];
    if (![SupportingClass analyseCarStatus:accStatus.stringValue withParentView:self.view]){
        switcher.on = !switcher.on;
        return;
    }

    
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    [ProgressHUDHandler showHUDWithTitle:@"更新设置中...." onView:nil];
    //    @weakify(self);
    [[APIsConnection shareConnection] personalGPSAPIsPostAutoRoleAlertStatusUpdateWithAccessToken:self.accessToken status:switcher.on success:^(NSURLSessionDataTask *operation, id responseObject) {
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        if (errorCode!=0) {
            [ProgressHUDHandler showErrorWithStatus:message onView:nil completion:^{
                switcher.on = !switcher.on;
            }];
            return;
        }
        [ProgressHUDHandler showSuccessWithStatus:@"更新成功！" onView:nil completion:nil];
        
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        //        @strongify(self);
        [ProgressHUDHandler showErrorWithStatus:@"更新失败！" onView:nil completion:^{
            switcher.on = !switcher.on;
        }];
    }];
}

/* 修改碰撞设置*/
- (void)updateAutoImpactAlertStatus:(UISwitch *)switcher {
    NSNumber *accStatus = [[[DBHandler shareInstance] getAutoRealtimeDataWithDataID:0] objectForKey:@"acc"];
    if (![SupportingClass analyseCarStatus:accStatus.stringValue withParentView:self.view]){
        switcher.on = !switcher.on;
        return;
    }

    
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    [ProgressHUDHandler showHUDWithTitle:@"更新设置中...." onView:nil];
    //    @weakify(self);
    [[APIsConnection shareConnection] personalGPSAPIsPostAutoImpactAlertStatusUpdateWithAccessToken:self.accessToken status:switcher.on success:^(NSURLSessionDataTask *operation, id responseObject) {
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        if (errorCode!=0) {[ProgressHUDHandler showErrorWithStatus:message onView:nil completion:^{
                switcher.on = !switcher.on;
            }];
            return;
        }
        [ProgressHUDHandler showSuccessWithStatus:@"更新成功！" onView:nil completion:nil];
        
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        //        @strongify(self);
        [ProgressHUDHandler showErrorWithStatus:@"更新失败！" onView:nil completion:^{
            switcher.on = !switcher.on;
        }];
    }];
}

/* 修改电瓶低电压设置 */
- (void)updateAutoBatteryLowAlertStatus:(UISwitch *)switcher {
    NSNumber *accStatus = [[[DBHandler shareInstance] getAutoRealtimeDataWithDataID:0] objectForKey:@"acc"];
    if (![SupportingClass analyseCarStatus:accStatus.stringValue withParentView:self.view]){
        switcher.on = !switcher.on;
        return;
    }

    
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    [ProgressHUDHandler showHUDWithTitle:@"更新设置中...." onView:nil];
    //    @weakify(self);
    [[APIsConnection shareConnection] personalGPSAPIsPostAutoBatteryLowAlertStatusUpdateWithAccessToken:self.accessToken status:switcher.on success:^(NSURLSessionDataTask *operation, id responseObject) {
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        if (errorCode!=0) {[ProgressHUDHandler showErrorWithStatus:message onView:nil completion:^{
                switcher.on = !switcher.on;
            }];
            return;
        }
        [ProgressHUDHandler showSuccessWithStatus:@"更新成功！" onView:nil completion:nil];
        
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        //        @strongify(self);
        [ProgressHUDHandler showErrorWithStatus:@"更新失败！" onView:nil completion:^{
            switcher.on = !switcher.on;
        }];
    }];
}

/* 修改拖车设置 */
- (void)updateAutoTrailingAlertStatus:(UISwitch *)switcher {
    NSNumber *accStatus = [[[DBHandler shareInstance] getAutoRealtimeDataWithDataID:0] objectForKey:@"acc"];
    if (![SupportingClass analyseCarStatus:accStatus.stringValue withParentView:self.view]){
        switcher.on = !switcher.on;
        return;
    }

    
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    [ProgressHUDHandler showHUDWithTitle:@"更新设置中...." onView:nil];
    //    @weakify(self);
    [[APIsConnection shareConnection] personalGPSAPIsPostAutoTrailingAlertStatusUpdateWithAccessToken:self.accessToken status:switcher.on success:^(NSURLSessionDataTask *operation, id responseObject) {
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        if (errorCode!=0) {[ProgressHUDHandler showErrorWithStatus:message onView:nil completion:^{
                switcher.on = !switcher.on;
            }];
            return;
        }
        [ProgressHUDHandler showSuccessWithStatus:@"更新成功！" onView:nil completion:nil];
        
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        //        @strongify(self);
        [ProgressHUDHandler showErrorWithStatus:@"更新失败！" onView:nil completion:^{
            switcher.on = !switcher.on;
        }];
    }];
}

/* 修改设备移除（断电）设置 */
- (void)updateAutoODBRemoveAlertStatus:(UISwitch *)switcher {
    NSNumber *accStatus = [[[DBHandler shareInstance] getAutoRealtimeDataWithDataID:0] objectForKey:@"acc"];
    if (![SupportingClass analyseCarStatus:accStatus.stringValue withParentView:self.view]){
        switcher.on = !switcher.on;
        return;
    }

    
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    [ProgressHUDHandler showHUDWithTitle:@"更新设置中...." onView:nil];
    //    @weakify(self);
    [[APIsConnection shareConnection] personalGPSAPIsPostAutoODBRemoveAlertStatusUpdateWithAccessToken:self.accessToken status:switcher.on success:^(NSURLSessionDataTask *operation, id responseObject) {
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        if (errorCode!=0) {[ProgressHUDHandler showErrorWithStatus:message onView:nil completion:^{
                switcher.on = !switcher.on;
            }];
            return;
        }
        [ProgressHUDHandler showSuccessWithStatus:@"更新成功！" onView:nil completion:nil];
        
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        //        @strongify(self);
        [ProgressHUDHandler showErrorWithStatus:@"更新失败！" onView:nil completion:^{
            switcher.on = !switcher.on;
        }];
    }];
}

/* 修改防盗喇叭设置 */
- (void)updateAutoSecurityAlertStatus:(UISwitch *)switcher {
    NSNumber *accStatus = [[[DBHandler shareInstance] getAutoRealtimeDataWithDataID:0] objectForKey:@"acc"];
    if (![SupportingClass analyseCarStatus:accStatus.stringValue withParentView:self.view]){
        switcher.on = !switcher.on;
        return;
    }

    
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    [ProgressHUDHandler showHUDWithTitle:@"更新设置中...." onView:nil];
    //    @weakify(self);
    [[APIsConnection shareConnection] personalGPSAPIsPostAutoSecurityAlertStatusUpdateWithAccessToken:self.accessToken status:switcher.on success:^(NSURLSessionDataTask *operation, id responseObject) {
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        if (errorCode!=0) {[ProgressHUDHandler showErrorWithStatus:message onView:nil completion:^{
                switcher.on = !switcher.on;
            }];
            return;
        }
        [ProgressHUDHandler showSuccessWithStatus:@"更新成功！" onView:nil completion:nil];
        
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        //        @strongify(self);
        [ProgressHUDHandler showErrorWithStatus:@"更新失败！" onView:nil completion:^{
            switcher.on = !switcher.on;
        }];
    }];
}

/* 修改疲劳驾驶设置 */
- (void)updateAutoFatigueDrivingStatus:(UISwitch *)switcher {
    NSNumber *accStatus = [[[DBHandler shareInstance] getAutoRealtimeDataWithDataID:0] objectForKey:@"acc"];
    if (![SupportingClass analyseCarStatus:accStatus.stringValue withParentView:self.view]){
        switcher.on = !switcher.on;
        return;
    }

    
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    [ProgressHUDHandler showHUDWithTitle:@"更新设置中...." onView:nil];
    //    @weakify(self);
    [[APIsConnection shareConnection] personalGPSAPIsPostAutoFatigueDrivingAlertStatusUpdateWithAccessToken:self.accessToken status:switcher.on success:^(NSURLSessionDataTask *operation, id responseObject) {
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        if (errorCode!=0) {[ProgressHUDHandler showErrorWithStatus:message onView:nil completion:^{
                switcher.on = !switcher.on;
            }];
            return;
        }
        [ProgressHUDHandler showSuccessWithStatus:@"更新成功！" onView:nil completion:nil];
        
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        //        @strongify(self);
        [ProgressHUDHandler showErrorWithStatus:@"更新失败！" onView:nil completion:^{
            switcher.on = !switcher.on;
        }];
    }];
}

///* 获取超速设置 */
//- (void)getOverSpeedStatsus {
//    
//    if (!self.accessToken) {
//        [self handleMissingTokenAction];
//        return;
//    }
//    @weakify(self);
//    [[APIsConnection shareConnection] personalGPSAPIsGetAutoOverSpeedSettingWithAccessToken:self.accessToken success:^(NSURLSessionDataTask *operation, id responseObject) {
//        @strongify(self);
//        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
//        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
//        NSLog(@"%@",message);
//        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
//            return;
//        }
//        if (errorCode==0) {
//            NSDictionary *settingDetail = responseObject[CDZKeyOfResultKey];
//            
//            NSString *speedString = settingDetail[@"ratedSpeed"];
//            BOOL speedStatus = [settingDetail[@"ratedStatus"] boolValue];
//            BOOL voiceStatus =[settingDetail[@"voiceStatus"] boolValue];
//            [self.ossView  setVoiceSwitchValue:voiceStatus];
//            [self.ossView  setSpeedSwitchValue:speedStatus];
//            [self.ossView  setLimitSpeed:speedString];
//        }
//        
//        
//    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
//        
//        NSString *message = @"设置失败！发生不明问题！";
//        if (error.code==-1009) {
//            message = @"设置失败！网络连接失败，请检查网络设置！";
//        }
//        
//        if (error.code==-1001) {
//            message = @"设置失败！网络连接逾时，请稍后再试！";
//        }
//        
//        [ProgressHUDHandler showErrorWithStatus:message onView:nil completion:nil];
//    }];
//}

/* 获取断油断电设置 */
- (void)getAutoPowerAndOilControlStatus {
    
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    @weakify(self);
    [[APIsConnection shareConnection] personalGPSAPIsGetAutoPowerAndOilControlStatusWithAccessToken:self.accessToken success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        if (errorCode==0) {
            BOOL status = [[responseObject[CDZKeyOfResultKey] objectForKey:@"status"] boolValue];
            
            [self.settingArray enumerateObjectsUsingBlock:^(id sectionObj, NSUInteger sectionIdx, BOOL *sectionStop) {
                [(NSArray*)sectionObj enumerateObjectsUsingBlock:^(id rowObj, NSUInteger rowIdx, BOOL *rowStop) {
                    @strongify(self);
                    if ([rowObj[@"title"] isEqualToString:@"home_security_setting_10"]) {
                        NSInteger tag = kBaseSwithTag+sectionIdx*10+rowIdx;
                        id pointer = self.objectContainerByIDList[@(tag).stringValue];
                        if ([pointer isKindOfClass:[UISwitch class]]) {
                            [(UISwitch*)pointer setOn:status];
                        }
                        *rowStop = YES;
                        *sectionStop = YES;
                    }
                }];
            }];

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

/* 修改断油断电设置*/
- (void)updateAutoPowerAndOilControlStatus:(UISwitch *)switcher {
    NSNumber *accStatus = [[[DBHandler shareInstance] getAutoRealtimeDataWithDataID:0] objectForKey:@"acc"];
    if (![SupportingClass analyseCarStatus:accStatus.stringValue withParentView:self.view]){
        switcher.on = !switcher.on;
        return;
    }
    
    
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    [ProgressHUDHandler showHUDWithTitle:@"更新设置中...." onView:nil];
    //    @weakify(self);
    [[APIsConnection shareConnection] personalGPSAPIsPostAutoPowerAndOilControlStatusUpdateWithAccessToken:self.accessToken status:switcher.on success:^(NSURLSessionDataTask *operation, id responseObject) {
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        if (errorCode!=0) {[ProgressHUDHandler showErrorWithStatus:message onView:nil completion:^{
            switcher.on = !switcher.on;
        }];
            return;
        }
        [ProgressHUDHandler showSuccessWithStatus:@"更新成功！" onView:nil completion:nil];
        
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        //        @strongify(self);
        [ProgressHUDHandler showErrorWithStatus:@"更新失败！" onView:nil completion:^{
            switcher.on = !switcher.on;
        }];
    }];
}

- (void)handleUserLoginResult:(BOOL)isSuccess fromAlert:(BOOL)fromAlert {
    if (isSuccess) {
        if (UserBehaviorHandler.shareInstance.getUserType!=CDZUserTypeOfGPSWithODBUser) {
            [SupportingClass showAlertViewWithTitle:nil message:@"登陆的账号并没有绑定GPS或不ODB功能，请重新登录已绑定含ODB功能的GPS账号" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                [self.navigationController popToRootViewControllerAnimated:YES];
            }];
            return;
        }
        //        NSLog(@"success reload function %d", [self executeReloadFunction]);
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
