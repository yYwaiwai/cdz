//
//
//  RealtimeAutoInfoVC.m
//  cdzer
//
//  Created by KEns0n on 5/26/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#import "RealtimeAutoInfoVC.h"
#import "InsetsLabel.h"
#define vLabelTag 100
@interface RealtimeAutoInfoVC ()
@property (nonatomic, weak) IBOutlet UIView *infoContainerView;

@property (nonatomic, strong) IBOutlet NSLayoutConstraint *engineLabelXConstraint;

@property (nonatomic, strong) IBOutlet NSLayoutConstraint *voltLabelXConstraint;

@property (nonatomic, strong) IBOutlet NSLayoutConstraint *waterTempLabelXConstraint;

@property (nonatomic, strong) IBOutlet NSLayoutConstraint *mileLabelXConstraint;

@property (nonatomic, strong) IBOutlet NSLayoutConstraint *speedLabelXConstraint;


@property (nonatomic, strong) UIView *imageBGView;


@property (nonatomic, weak) IBOutlet UILabel *engineRPMLabel;

@property (nonatomic, weak) IBOutlet UILabel *battaryVoltage;

@property (nonatomic, weak) IBOutlet UILabel *waterTemperature;

@property (nonatomic, weak) IBOutlet UILabel *totalMiles;

@property (nonatomic, weak) IBOutlet UILabel *autoSpeed;

@property (nonatomic, weak) IBOutlet UILabel *fuelConsumption;

@property (nonatomic, weak) IBOutlet UILabel *fuelConsumptionPerKM;

@property (nonatomic, weak) IBOutlet UILabel *journeyTime;


@end

@implementation RealtimeAutoInfoVC


- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"实时车况";
    // Do any additional setup after loading the view.
    [self componentSetting];
    [self initializationUI];
    [self setReactiveRules];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getUserAutoOBDData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)setReactiveRules {
    @autoreleasepool {
        
    }
    
}

- (void)componentSetting {
    @autoreleasepool {
        UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshODBData)];
        self.navigationItem.rightBarButtonItem = rightButton;
        
        if (IS_IPHONE_5||IS_IPHONE_4_OR_LESS) {
            [self.infoContainerView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull firstLayerView, NSUInteger idx, BOOL * _Nonnull stop) {
                if (firstLayerView.tag==901) {
                    [firstLayerView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull secondLayerView, NSUInteger sIdx, BOOL * _Nonnull sStop) {
                        if (secondLayerView.tag==902&&[secondLayerView isKindOfClass:UILabel.class]) {
                            UILabel *label = (UILabel *)secondLayerView;
                            label.font = [label.font fontWithSize:11];
                        }
                    }];
                }
                if (firstLayerView.tag==903) {
                    [firstLayerView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull secondLayerView, NSUInteger sIdx, BOOL * _Nonnull sStop) {
                        if (secondLayerView.tag==901) {
                            [secondLayerView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull lastLayerView, NSUInteger lIdx, BOOL * _Nonnull lStop) {
                                if (lastLayerView.tag==902&&[lastLayerView isKindOfClass:UILabel.class]) {
                                    UILabel *label = (UILabel *)lastLayerView;
                                    label.font = [label.font fontWithSize:11];
                                }
                            }];
                        }

                        
                    }];
                }

            }];
        }
        
        self.engineLabelXConstraint.constant = roundf(self.engineLabelXConstraint.constant*SCREEN_WIDTH/414.0f);
        
        self.voltLabelXConstraint.constant = roundf(self.voltLabelXConstraint.constant*SCREEN_WIDTH/414.0f);
        
        self.waterTempLabelXConstraint.constant = roundf(self.waterTempLabelXConstraint.constant*SCREEN_WIDTH/414.0f);
        
        self.mileLabelXConstraint.constant = roundf(self.mileLabelXConstraint.constant*SCREEN_WIDTH/414.0f);
        
        self.speedLabelXConstraint.constant = roundf(self.speedLabelXConstraint.constant*SCREEN_WIDTH/414.0f);
    }
}

- (void)initializationUI {
    @autoreleasepool {
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refreshODBData {
    NSString *status = @"0";
    if (![status isEqualToString:@"0"]) {
        CGRect frame =  CGRectMake(20, self.view.frame.size.height-150,self.view.frame.size.width-40, 45);
        NSString *msg ;
        if ([status isEqualToString:@"1"]) {
            msg = @"熄火";
        }else if([status isEqualToString:@"2"]){
            msg = @"离线";
        }else{
            msg = @"无信号";
        }
        NSString *text = [NSString stringWithFormat:@"您当前的车辆处于%@状态，此数据是历史数据，请检查设备是否安装正确！",msg];
        [SupportingClass addLabelWithFrame:frame content:text radius:5.0f fontSize:13.0f parentView:self.view isAlertShow:YES pushBlock:^{
            
        }];
        return;
    }
    [self getUserAutoOBDData];
}

#pragma mark- Data Handle Request
- (void)handleResponseData:(id)responseObject {
    if (!responseObject||![responseObject isKindOfClass:NSDictionary.class]) {
        NSLog(@"data Error");
        return;
    }
    
    if ([responseObject count]==0) {
        self.engineRPMLabel.text = @"--";
        self.battaryVoltage.text = @"--";
        self.waterTemperature.text = @"--";
        self.totalMiles.text = @"--";
        self.autoSpeed.text = @"--";
        self.fuelConsumption.text = @"--";
        self.fuelConsumptionPerKM.text = @"--";
        self.journeyTime.text = @"--";
        [SupportingClass showAlertViewWithTitle:@"alert_remind" message:@"没有更多ODB数据！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
         
        }];
        return;
    }
    self.engineRPMLabel.text = responseObject[@"fdjzs"];
    self.battaryVoltage.text = responseObject[@"dpdy"];
    self.waterTemperature.text = responseObject[@"sw"];
    self.totalMiles.text = responseObject[@"lc"];
    self.autoSpeed.text = responseObject[@"cs"];
    self.fuelConsumption.text = responseObject[@"yh"];
    self.fuelConsumptionPerKM.text = responseObject[@"bglyh"];
    self.journeyTime.text = responseObject[@"xssj"];
}

#pragma mark- APIs Access Request
- (void)getUserAutoOBDData {
    
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    [self setReloadFuncWithAction:_cmd parametersList:nil];
    [ProgressHUDHandler showHUD];
    [[APIsConnection shareConnection] personalGPSAPIsGetAutoOBDDataWithAccessToken:self.accessToken success:^(NSURLSessionDataTask *operation, id responseObject) {
        [self requestResultHandle:operation responseObject:responseObject withError:nil];
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        [self requestResultHandle:operation responseObject:nil withError:error];
    }];
}

- (void)requestResultHandle:(NSURLSessionDataTask *)operation responseObject:(id)responseObject withError:(NSError *)error {
    
    if (error&&!responseObject) {
        NSLog(@"%@",error);
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
    }else if (!error&&responseObject) {
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        [ProgressHUDHandler dismissHUD];
        if (errorCode!=0) {
            [SupportingClass showAlertViewWithTitle:@"error" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
//                if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject]) {
//                    [self setAccessToken:nil];
//                    [self.navigationController popViewControllerAnimated:YES];
//                }
            }];
            return;
        }
        
        NSLog(@"%@",responseObject);
        [self handleResponseData:responseObject[CDZKeyOfResultKey]];
        
    }
    
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
 #pragma mark- Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
