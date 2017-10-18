//
//  TireSpecificationsVC.m
//  cdzer
//
//  Created by 车队长 on 16/7/23.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "TireSpecificationsVC.h"
#import "OtherTireSpecificationsVC.h"//其他规格
#import "TheMainViewController.h"


@interface TireSpecificationsVC ()
@property (weak, nonatomic) IBOutlet UIControl *specificationView1;
@property (weak, nonatomic) IBOutlet UILabel *specificationLable1;

@property (weak, nonatomic) IBOutlet UIControl *specificationView2;
@property (weak, nonatomic) IBOutlet UILabel *specificationLabel2;

@property (weak, nonatomic) IBOutlet UIButton *otherSpecificationsButton;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;


@property (nonatomic, strong) NSString *tireDefaultSpec;
@property (nonatomic, strong) NSString *specificationString;

@property (nonatomic, strong) UserSelectedAutosInfoDTO *autosData;

@end

@implementation TireSpecificationsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self componentSetting];
}

- (void)setupReturnSpecificationsText:(ReturnSpecificationTextBlock)block {
    self.returnSpecificationTextBlock = block;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)componentSetting {
    @autoreleasepool {
        self.navShouldPopOtherVC = YES;
        self.autosData = [DBHandler.shareInstance getSelectedAutoData];
        if (self.autosData.tireDefaultSpec) {
            [self getAutosDefaultTireSpec];
        }
        self.specificationString = self.autosData.tireDefaultSpec;
        self.specificationLable1.text = self.autosData.selectedTireSpec;
        self.specificationLable1.textColor = CDZColorOfDefaultColor;
        
        [self.otherSpecificationsButton.layer setMasksToBounds:YES];
        [self.otherSpecificationsButton.layer setCornerRadius:3.0];
        UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"snsslvc_tire_spec_bkg@3x" ofType:@"png"]];
        self.imageView.image = image;
        
        self.specificationView1.tag = 101;
        self.specificationView2.tag = 102;
        
        [self.specificationView1 addTarget:self action:@selector(specificationViewClick:) forControlEvents:UIControlEventTouchUpInside];
        NSString *title = self.autosData.seriesName;
        if (![self.autosData.seriesName isContainsString:self.autosData.brandName]) {
            title = [self.autosData.brandName stringByAppendingString:self.autosData.seriesName];
        }
        self.title = title;
    }
}

#pragma mark--换车按钮

- (void)specificationViewClick:(UIControl*)sender {
    if (sender.tag==101) {
        self.specificationLable1.textColor=CDZColorOfDefaultColor;
        self.specificationLabel2.textColor=CDZColorOfBlack;
    }
    if (sender.tag==102) {
        self.specificationLable1.textColor=CDZColorOfBlack;
        self.specificationLabel2.textColor=CDZColorOfDefaultColor;
    }
    
    self.specificationString=self.specificationLable1.text;
//    if (self.returnSpecificationTextBlock ) {
//        
//        if (sender.tag==101) {
//            self.specificationString=self.specificationLable1.text;
//            
//        }
//        if (sender.tag==102) {
//            self.specificationString=self.specificationLabel2.text;
//        }
//        self.returnSpecificationTextBlock(self.specificationString);
//        
//    }
//    [self.navigationController popViewControllerAnimated:YES];
    [self updateTireSpecSelection];
}

- (IBAction)otherSpecificationsButtonClick:(id)sender {
    OtherTireSpecificationsVC *vc = [OtherTireSpecificationsVC new];
    vc.popBackProductCenter = self.popBackProductCenter;
    [self setDefaultNavBackButtonWithoutTitle];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getAutosDefaultTireSpec {
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    
    @weakify(self);
    [APIsConnection.shareConnection personalCenterAPIsGetRapidRepairTireDefaultSpecWithAccessToken:self.accessToken success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        if (errorCode!=0) {
            [ProgressHUDHandler dismissHUD];
            [SupportingClass showAlertViewWithTitle:@"" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            }];
            return ;
        }
        [ProgressHUDHandler dismissHUD];
        self.tireDefaultSpec = responseObject[@"sign"];
        self.specificationLable1.text = self.tireDefaultSpec;
        self.autosData.selectedTireSpec = self.tireDefaultSpec;
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        @strongify(self);
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

- (void)updateTireSpecSelection {
    
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    
    @weakify(self);
    [APIsConnection.shareConnection personalCenterAPIsPostUpdateRapidRepairTireSpecSelectionWithAccessToken:self.accessToken tireSpecModel:self.autosData.tireDefaultSpec modelID:self.autosData.modelID success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        if (errorCode!=0) {
            [ProgressHUDHandler dismissHUD];
            [SupportingClass showAlertViewWithTitle:@"" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            }];
            return;
        }
        [ProgressHUDHandler dismissHUD];
        self.autosData.selectedTireSpec = self.autosData.tireDefaultSpec;
        BOOL success = [DBHandler.shareInstance updateSelectedAutoData:self.autosData];
        if (self.autosData.isSelectFromOnline) {
            [self reloadMyAutoData];
        }
        if (self.returnSpecificationTextBlock) {
            self.returnSpecificationTextBlock(self.autosData.selectedTireSpec);
        }
        [self.navigationController popViewControllerAnimated:YES];
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

- (void)reloadMyAutoData {
    if (!self.accessToken) {
        return;
    }
    [[APIsConnection shareConnection] personalCenterAPIsGetMyAutoListWithAccessToken:self.accessToken success:^(NSURLSessionDataTask *operation, id responseObject) {
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        [ProgressHUDHandler dismissHUD];
        if (errorCode==0) {
            NSDictionary *autosData = responseObject[CDZKeyOfResultKey];
            UserAutosInfoDTO *dto = [UserAutosInfoDTO new];
            [dto processDataToObject:autosData optionWithUID:UserBehaviorHandler.shareInstance.getUserID];
            [DBHandler.shareInstance updateUserAutosDetailData:dto.processObjectToDBData];
        }
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        
    }];
    
}

- (void)handleNavBackBtnPopOtherAction {
    if (self.returnSpecificationTextBlock) {
        self.returnSpecificationTextBlock(nil);
    }
    [self.navigationController popViewControllerAnimated:YES];
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
