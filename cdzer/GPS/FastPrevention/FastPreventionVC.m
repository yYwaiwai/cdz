//
//  FastPreventionVC.m
//  cdzer
//
//  Created by KEns0n on 6/2/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#import "FastPreventionVC.h"
#import "MBSliderView.h"

@interface FastPreventionVC () <MBSliderViewDelegate>

@property (nonatomic, strong) UILabel *tagLa;

@property (nonatomic, strong) UIButton *circleBtn;

@property (nonatomic, strong) UIButton *lockBtn;

@end

@implementation FastPreventionVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor grayColor];
    [self.contentView setBackgroundImageByCALayerWithImage:[UIImage imageNamed:@"f_bg@2x.png"]];
    self.title = @"快速设防";
    [self setReactiveRules];
    [self componentSetting];
    [self initializationUI];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    [self getFastPreventionDetail];
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
}

- (void)initializationUI {
    UIImage *circleBtnImage = [ImageHandler getImageFromCacheByScreenRatioWithFileRootPath:nil fileName:@"f_circle" type:FMImageTypeOfPNG scaleWithPhone4:NO offsetRatioForP4:0 needToUpdate:YES];
    self.circleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _circleBtn.frame = CGRectMake(0.0f, roundf(vAdjustByScreenRatio(44)), circleBtnImage.size.width, circleBtnImage.size.height);
    _circleBtn.userInteractionEnabled = NO;
    _circleBtn.center = CGPointMake(CGRectGetWidth(self.contentView.frame)/2.0f, _circleBtn.center.y);
    [_circleBtn setImage:circleBtnImage forState:UIControlStateNormal];
    [self.contentView addSubview:_circleBtn];
    
    
    UIImage *lockBtnImageOn = [ImageHandler getImageFromCacheByScreenRatioWithFileRootPath:nil fileName:@"f_open_lock" type:FMImageTypeOfPNG scaleWithPhone4:NO offsetRatioForP4:0 needToUpdate:YES];
    UIImage *lockBtnImageOff = [ImageHandler getImageFromCacheByScreenRatioWithFileRootPath:nil fileName:@"f_close_lock" type:FMImageTypeOfPNG scaleWithPhone4:NO offsetRatioForP4:0 needToUpdate:YES];
    self.lockBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _lockBtn.frame = CGRectMake(0.0f, roundf(vAdjustByScreenRatio(120)), lockBtnImageOn.size.width, lockBtnImageOn.size.height);
    _lockBtn.userInteractionEnabled = NO;
    _lockBtn.center = CGPointMake(CGRectGetWidth(self.contentView.frame)/2.0f, _lockBtn.center.y);
    [_lockBtn setImage:lockBtnImageOn forState:UIControlStateNormal];
    [_lockBtn setImage:lockBtnImageOff forState:UIControlStateSelected];
    [self.contentView addSubview:_lockBtn];
    
    
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    UIImage *sliderImage = [ImageHandler getImageFromCacheByScreenRatioWithFileRootPath:nil fileName:@"f_slider_bg" type:FMImageTypeOfPNG scaleWithPhone4:NO offsetRatioForP4:0 needToUpdate:YES];
    UIImageView *sliderImg = [[UIImageView alloc] init];
    sliderImg.frame = CGRectMake(0.0f, roundf(vAdjustByScreenRatio(352)), roundf(sliderImage.size.width), 51);
    sliderImg.image = sliderImage;
    sliderImg.center = CGPointMake(CGRectGetWidth(self.contentView.frame)/2.0f, sliderImg.center.y);
    
    self.tagLa = [[UILabel alloc] init];
    self.tagLa.frame = sliderImg.frame;
    self.tagLa.textColor = [UIColor whiteColor];
    self.tagLa.textAlignment = NSTextAlignmentCenter;
    self.tagLa.text = @"关闭设防";
    
    
    MBSliderView *silderView = [[MBSliderView alloc] init];
    silderView.delegate = self ;
    silderView.frame = CGRectMake(0.0f, roundf(vAdjustByScreenRatio(360)), roundf(vAdjustByScreenRatio(274)), 31);
    [silderView setThumbColor:[UIColor whiteColor]];
    [silderView setLabelColor:[UIColor clearColor]];
    silderView.center = CGPointMake(CGRectGetWidth(self.contentView.frame)/2.0f, sliderImg.center.y);
    
    [self.view addSubview:self.tagLa];
    [self.view addSubview:sliderImg];
    [self.view addSubview:silderView];
    
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

}

bool isOpen ;
#pragma mark 滑动条的监听方法
- (void)sliderDidSlide:(MBSliderView *)slideView{
    if(isOpen){
        [self shutdownFastPreventionProtect];
    }else{
        [self turnOnFastPreventionProtect];
    }
}


#pragma mark- APIs Access Request

- (void)getFastPreventionDetail {
    
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    [ProgressHUDHandler showHUDWithTitle:getLocalizationString(@"loading") onView:nil];
    NSDictionary *userInfo = @{@"ident":@0};
    [[APIsConnection shareConnection] personalGPSAPIsGetFastPreventionDetailWithAccessToken:self.accessToken success:^(NSURLSessionDataTask *operation, id responseObject) {
        operation.userInfo = userInfo;
        [self requestResultHandle:operation responseObject:responseObject withError:nil];
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        operation.userInfo = userInfo;
        [self requestResultHandle:operation responseObject:nil withError:error];
    }];
}

- (void)turnOnFastPreventionProtect {
    
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    [ProgressHUDHandler showHUDWithTitle:@"正在开启设防...." onView:nil];
    NSDictionary *userInfo = @{@"ident":@1};
    [[APIsConnection shareConnection] personalGPSAPIsPostFastPreventionOfnWithAccessToken:self.accessToken success:^(NSURLSessionDataTask *operation, id responseObject) {
        operation.userInfo = userInfo;
        [self requestResultHandle:operation responseObject:responseObject withError:nil];
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        operation.userInfo = userInfo;
        [self requestResultHandle:operation responseObject:nil withError:error];
    }];
}

- (void)shutdownFastPreventionProtect {
    
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    [ProgressHUDHandler updateProgressStatusWithTitle:@"正在关闭设防...."];
    NSDictionary *userInfo = @{@"ident":@2};
    
    [[APIsConnection shareConnection] personalGPSAPIsPostFastPreventionOffWithAccessToken:self.accessToken success:^(NSURLSessionDataTask *operation, id responseObject) {
        operation.userInfo = userInfo;
        [self requestResultHandle:operation responseObject:responseObject withError:nil];
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        operation.userInfo = userInfo;
        [self requestResultHandle:operation responseObject:nil withError:error];
    }];
}

- (void)requestResultHandle:(NSURLSessionDataTask *)operation responseObject:(id)responseObject withError:(NSError *)error {
    NSNumber *ident = operation.userInfo[@"ident"];
    if (error&&!responseObject) {
        NSLog(@"%@",error);
        [ProgressHUDHandler showError];
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
        switch (errorCode) {
            case 0:
                NSLog(@"%@",responseObject);
                switch (ident.integerValue) {
                    case 0:{
                        BOOL isON = ![responseObject[CDZKeyOfResultKey] boolValue];
                        isOpen = isON ;
                        self.lockBtn.selected = !isON ;
                        self.circleBtn.selected = isON;
                        self.tagLa.text = isON?@"关闭设防":@"开启设防";
                        [ProgressHUDHandler dismissHUD];
                    }
                        break;
                        
                    case 1:
                        isOpen = YES;
                        self.tagLa.text = @"关闭设防";
                        self.lockBtn.selected = NO ;
                        self.circleBtn.selected = !self.circleBtn.selected ;
                        [ProgressHUDHandler showSuccessWithStatus:@"开启成功" onView:nil completion:^{
                            
                        }];
                        break;
                        
                    case 2:
                        isOpen = NO;
                        self.tagLa.text = @"开启设防";
                        self.lockBtn.selected = YES ;
                        self.circleBtn.selected = !self.circleBtn.selected ;
                        [ProgressHUDHandler showSuccessWithStatus:@"关闭成功" onView:nil completion:^{
                            
                        }];
                        break;
                        
                    default:
                        break;
                }
                break;
            case 1:
            case 2:{
                [ProgressHUDHandler dismissHUD];
                NSString *title = getLocalizationString(@"error");
                if (ident.integerValue >= 1) {
                    title = getLocalizationString(@"alert_remind");
                }
                if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {return;}
                
                [SupportingClass showAlertViewWithTitle:title message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                }];
            }
                break;
                
            default:
                break;
        }
        
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
