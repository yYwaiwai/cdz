//
//  SelfInspectSuggestionVC.m
//  cdzer
//
//  Created by KEns0n on 16/4/6.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "SelfInspectSuggestionVC.h"
#import "RepairGudieProcedureVC.h"
#import "UserSelectedAutosInfoDTO.h"
#import "SelfDiagnosisResultVC.h"

@interface SelfInspectSuggestionVC ()

@property (nonatomic, weak) IBOutlet UILabel *displayLabelView;

@property (nonatomic, weak) IBOutlet UIView *displayBarView;

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;

@property (nonatomic, weak) IBOutlet UIImageView *titleImageView;

@property (nonatomic, weak) IBOutlet UIImageView *partImageView;

@property (nonatomic, weak) IBOutlet UIImageView *wxsImageView;

@property (nonatomic, weak) IBOutlet UILabel *partTotalPrice;

@property (nonatomic, weak) IBOutlet UILabel *workingHourLabel;

@property (nonatomic, weak) IBOutlet UILabel *workingTotalPrice;


@end

@implementation SelfInspectSuggestionVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (void)setReactiveRules {
    @autoreleasepool {
        
    }
    
}

- (void)componentSetting {
    @autoreleasepool {
        
        self.navShouldPopOtherVC = YES;
        
        
        self.titleLabel.text = [NSString stringWithFormat:@"您需要维修%@", self.titleName];
        
        UIImage *titleImage = [ImageHandler getImageFromCacheWithByFixdeRatioFileRootPath:nil fileName:@"inspect_title" type:FMImageTypeOfPNG needToUpdate:YES];
        self.titleImageView.image = titleImage;
        
        UIImage *partImage = [ImageHandler getImageFromCacheWithByFixdeRatioFileRootPath:nil fileName:@"male_info" type:FMImageTypeOfPNG needToUpdate:YES];
        self.partImageView.image = partImage;
        
        UIImage *wxsImage = [ImageHandler getImageFromCacheWithByFixdeRatioFileRootPath:nil fileName:@"store_info" type:FMImageTypeOfPNG needToUpdate:YES];
        self.wxsImageView.image = wxsImage;
        
        
        NSString *totalPartPrice = [SupportingClass verifyAndConvertDataToString:_detail[@"partPrice"]];
        if (![totalPartPrice isEqualToString:@"暂无报价"]) {
            totalPartPrice = [@"¥" stringByAppendingString:totalPartPrice];
        }
        NSMutableAttributedString* totalPartPriceAttrStr = [NSMutableAttributedString new];
        [totalPartPriceAttrStr appendAttributedString:[[NSAttributedString alloc]
                                                       initWithString:@"价格："
                                                       attributes:@{NSForegroundColorAttributeName:CDZColorOfBlack}]];
        [totalPartPriceAttrStr appendAttributedString:[[NSAttributedString alloc]
                                                       initWithString:totalPartPrice
                                                       attributes:@{NSForegroundColorAttributeName:CDZColorOfTureRed}]];
        self.partTotalPrice.attributedText = totalPartPriceAttrStr;
    
        
        
        
        NSString *workingHours = [SupportingClass verifyAndConvertDataToString:_detail[@"mhour"]];
        self.workingHourLabel.text = [NSString stringWithFormat:@"工时：%@", workingHours];
        
        NSString *totalWorkingPrice = [SupportingClass verifyAndConvertDataToString:_detail[@"sumPrice"]];
        if (![totalWorkingPrice isEqualToString:@"暂无报价"]) {
            totalWorkingPrice = [@"¥" stringByAppendingString:totalWorkingPrice];
            
        }
        NSMutableAttributedString* totalWorkingPriceAttrStr = [NSMutableAttributedString new];
        [totalWorkingPriceAttrStr appendAttributedString:[[NSAttributedString alloc]
                                                          initWithString:@"价格："
                                                          attributes:@{NSForegroundColorAttributeName:CDZColorOfBlack}]];
        [totalWorkingPriceAttrStr appendAttributedString:[[NSAttributedString alloc]
                                                          initWithString:totalWorkingPrice
                                                          attributes:@{NSForegroundColorAttributeName:CDZColorOfTureRed}]];
        self.workingTotalPrice.attributedText = totalWorkingPriceAttrStr;
        
        [self.displayLabelView setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:CGRectGetHeight(self.displayLabelView.frame)/2.0f];
        [self.displayBarView setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:CGRectGetHeight(self.displayBarView.frame)/2.0f];
    }
}

- (void)initializationUI {
    @autoreleasepool {
        
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self componentSetting];
    [self initializationUI];
    [self setReactiveRules];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)getRepairGuideVC {
    if (!_stepTitle||!_procedureDetailID) {
        NSLog(@"Missing Parameters");
        return;
    }
    
    [self getRepairGuideProcedureDetail:_procedureDetailID withTitle:_stepTitle];
}

- (void)getRepairGuideProcedureDetail:(NSString *)procedureDetailID withTitle:(NSString *)title {
    if (!procedureDetailID||[procedureDetailID isEqualToString:@""]) {
        NSLog(@"Missing Parameters");
        return;
    }
    [ProgressHUDHandler showHUD];
    @weakify(self);
    [APIsConnection.shareConnection repairGuideAPIsGetRepairGuideProcedureDetailWithProcedureDetailID:procedureDetailID success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        [ProgressHUDHandler dismissHUD];
        if (errorCode!=0&&![message isEqualToString:@"返回成功"]) {
            [ProgressHUDHandler dismissHUD];
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
            return;
        }
        
        NSDictionary *procedureDetail = responseObject[CDZKeyOfResultKey];
        RepairGudieProcedureVC *vc = [RepairGudieProcedureVC new];
        vc.procedureDetail = procedureDetail;
        vc.title = title;
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
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
        return;
    }];
}

- (IBAction)getDiagnosisResult {
    if (!_titleName) {
        NSLog(@"Missing Parameters");
        return;
    }
    UserSelectedAutosInfoDTO *autoData = [[DBHandler shareInstance] getSelectedAutoData];
    if (!autoData.modelID||!autoData.seriesID||!_procedureDetailID||[_procedureDetailID isEqualToString:@""]) {
        NSLog(@"Missing autoData Parameters");
        return;
    }
    NSString *brandId = autoData.brandID;
    NSNumber *pageNums = @(1);
    NSNumber *pageSizes = @(10);
    NSNumber *longitude = @(112.979353);
    NSNumber *latitude = @(28.213478);
    NSNumber *cityID = @(197);
//    [ProgressHUDHandler showHUD];
//    [[APIsConnection shareConnection] selfDiagnoseAPIsGetDiagnoseResultListWithReasonName:_titleName brandId:brandId pageNums:pageNums pageSizes:pageSizes longitude:longitude latitude:latitude cityID:cityID success:^(NSURLSessionDataTask *operation, id responseObject) {
//        
//        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
//        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
//        NSLog(@"%@",message);
//        [ProgressHUDHandler dismissHUD];
//        if (errorCode!=0) {
//            [SupportingClass showAlertViewWithTitle:@"error" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
//            }];
//            return ;
//        }
//        
//        SelfDiagnosisResultVC *sdrVC = [[SelfDiagnosisResultVC alloc] init];
//        sdrVC.resultData = responseObject[CDZKeyOfResultKey];
//        [self setDefaultNavBackButtonWithoutTitle];
//        [self.navigationController pushViewController:sdrVC animated:YES];
//        
//    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
//        [ProgressHUDHandler dismissHUD];
//        if (error.code==-1009) {
//            [SupportingClass showAlertViewWithTitle:@"error" message:@"网络连接失败，请检查网络设置！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
//            }];
//            return;
//        }
//        
//        
//        if (error.code==-1001) {
//            [SupportingClass showAlertViewWithTitle:@"error" message:@"网络连接逾时，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
//            }];
//            return;
//        }
//        
//        [SupportingClass showAlertViewWithTitle:@"error" message:@"网络错误，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
//        }];
//    }];
}

- (void)handleNavBackBtnPopOtherAction {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.class == %@", NSClassFromString(@"SelfDiagnosisVC")];
    NSArray *result = [self.navigationController.viewControllers filteredArrayUsingPredicate:predicate];
    if (result&&result.count>0) {
        [self.navigationController popToViewController:result.firstObject animated:YES];
    }else {
        [self.navigationController popViewControllerAnimated:YES];
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
