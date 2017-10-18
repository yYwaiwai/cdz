//
//  OtherTireSpecificationsVC.m
//  cdzer
//
//  Created by 车队长 on 16/7/23.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "OtherTireSpecificationsVC.h"
#import "ShopNServiceSearchListVC.h"
#import "SpecProductCenterVC.h"

@interface OtherTireSpecificationsVC ()<UIPickerViewDelegate, UIPickerViewDataSource>
@property (weak, nonatomic) IBOutlet UIImageView *topImageView;

@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;

@property (weak, nonatomic) IBOutlet UIButton *searchButton;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *pickerHeightConstraint;

@property (nonatomic, strong) NSArray *tireSpecificationList;

@property (nonatomic, strong) UserSelectedAutosInfoDTO *autosData;
@end

@implementation OtherTireSpecificationsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.autosData = [DBHandler.shareInstance getSelectedAutoData];
    self.title = @"其他规格";
    self.topImageView.image = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"snsslvc_other_tire_spec_bkg@3x" ofType:@"png"]];
    self.pickerView.delegate = self;
    [self.searchButton.layer setCornerRadius:3.0];
    [self.searchButton.layer setMasksToBounds:YES];
    self.pickerView.backgroundColor=CDZColorOfWhite;
    if (IS_IPHONE_4_OR_LESS) {
        self.pickerHeightConstraint.constant = 130;
    }
    
    [self getTireSizeData];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return self.tireSpecificationList.count;
    
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if (self.tireSpecificationList[component]&&[self.tireSpecificationList[component] isKindOfClass:NSArray.class]) {
        return [self.tireSpecificationList[component] count];
    }
    return 0;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *titleLabel = (UILabel *)view;
    if (!view||![view isKindOfClass:UILabel.class]) {
        titleLabel = [UILabel new];
        titleLabel.numberOfLines = 0;
        titleLabel.textColor = [UIColor colorWithHexString:@"323232"];
        titleLabel.font = [titleLabel.font fontWithSize:15];
        titleLabel.textAlignment = NSTextAlignmentCenter;

    }
    titleLabel.text = [SupportingClass verifyAndConvertDataToString:[self.tireSpecificationList[component] objectAtIndex:row]];
    return titleLabel;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
   
    NSInteger comp1 = [self.pickerView selectedRowInComponent:0];
    NSInteger comp2 = [self.pickerView selectedRowInComponent:1];
    NSInteger comp3 = [self.pickerView selectedRowInComponent:2];
    NSString *tireWidth = [SupportingClass verifyAndConvertDataToString:[self.tireSpecificationList[0] objectAtIndex:comp1]];
    NSString *aspectRatio = [SupportingClass verifyAndConvertDataToString:[self.tireSpecificationList[1] objectAtIndex:comp2]];
    NSString *wheelDiameter = [SupportingClass verifyAndConvertDataToString:[self.tireSpecificationList[2] objectAtIndex:comp3]];
    
    self.autosData.selectedTireSpec = [NSString stringWithFormat:@"%@/%@R%@", tireWidth, aspectRatio, wheelDiameter];
}

- (IBAction)searchButtonClick:(id)sender {
    [self updateTireSpecSelection];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getTireSizeData {
    @weakify(self);
    [APIsConnection.shareConnection personalCenterAPIsGetRapidRepairTireSpecListWithSuccess:^(NSURLSessionDataTask *operation, id responseObject) {
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
        NSDictionary *tireSpecificationDetail = responseObject[CDZKeyOfResultKey];
        NSArray *tireWidthList = [tireSpecificationDetail[@"tread_width"] valueForKey:@"name"];
        NSArray *aspectRatioList = [tireSpecificationDetail[@"flat_surface"] valueForKey:@"name"];
        NSArray *wheelDiameterList = [tireSpecificationDetail[@"diameter"] valueForKey:@"name"];
        if (!tireWidthList) tireWidthList = @[];
        if (!aspectRatioList) aspectRatioList = @[];
        if (!wheelDiameterList) wheelDiameterList = @[];
        self.tireSpecificationList = @[tireWidthList, aspectRatioList, wheelDiameterList];
        
        if (tireWidthList.count>0&&aspectRatioList.count>0&&wheelDiameterList.count>0) {
            NSString *tireWidth = [SupportingClass verifyAndConvertDataToString:[self.tireSpecificationList[0] objectAtIndex:0]];
            NSString *aspectRatio = [SupportingClass verifyAndConvertDataToString:[self.tireSpecificationList[1] objectAtIndex:0]];
            NSString *wheelDiameter = [SupportingClass verifyAndConvertDataToString:[self.tireSpecificationList[2] objectAtIndex:0]];
            self.autosData.selectedTireSpec = [NSString stringWithFormat:@"%@/%@R%@", tireWidth, aspectRatio, wheelDiameter];
        }
        [self.pickerView reloadAllComponents];
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

- (void)updateTireSpecSelection {
    
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    
    @weakify(self);
    [APIsConnection.shareConnection personalCenterAPIsPostUpdateRapidRepairTireSpecSelectionWithAccessToken:self.accessToken tireSpecModel:self.autosData.selectedTireSpec modelID:self.autosData.modelID success:^(NSURLSessionDataTask *operation, id responseObject) {
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
        BOOL success = [DBHandler.shareInstance updateSelectedAutoData:self.autosData];
        UserSelectedAutosInfoDTO *autosData = [DBHandler.shareInstance getSelectedAutoData];;
        if (self.autosData.isSelectFromOnline) {
            [self reloadMyAutoData];
        }
        [self popBackToList];
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

- (void)popBackToList {
    if (self.popBackProductCenter) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.class == %@", SpecProductCenterVC.class];
        NSArray *result = [self.navigationController.viewControllers filteredArrayUsingPredicate:predicate];
        if (result&&result.count>0) {
            [self.navigationController popToViewController:result.lastObject animated:YES];
            return;
        }
        
        ShopNServiceSearchListVC *vc = ShopNServiceSearchListVC.new;
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];

        return;
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.class == %@", ShopNServiceSearchListVC.class];
    NSArray *result = [self.navigationController.viewControllers filteredArrayUsingPredicate:predicate];
    if (result&&result.count>0) {
        [self.navigationController popToViewController:result.lastObject animated:YES];
        return;
    }
    
    ShopNServiceSearchListVC *vc = ShopNServiceSearchListVC.new;
    [self setDefaultNavBackButtonWithoutTitle];
    [self.navigationController pushViewController:vc animated:YES];

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
