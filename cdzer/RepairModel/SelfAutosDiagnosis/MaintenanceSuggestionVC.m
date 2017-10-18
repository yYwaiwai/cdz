//
//  MaintenanceSuggestionVC.m
//  cdzer
//
//  Created by 车队长 on 16/10/31.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "MaintenanceSuggestionVC.h"
#import "MaintenanceGuideVC.h"
#import "RepairShopResultsVC.h"

@interface MaintenanceSuggestionVC ()

@property (weak, nonatomic) IBOutlet UILabel *titleRepairNameLabel;

@property (weak, nonatomic) IBOutlet UIButton *theirOwnRepairButton;//自己维修

@property (weak, nonatomic) IBOutlet UIButton *businessRepairButton;//商家维修

@property (weak, nonatomic) IBOutlet UILabel *repairNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *partsLabel;

@property (weak, nonatomic) IBOutlet UILabel *leftLabelThree;

@property (weak, nonatomic) IBOutlet UILabel *leftLabelFour;

@property (weak, nonatomic) IBOutlet UILabel *rightLabelThree;

@property (weak, nonatomic) IBOutlet UILabel *rightLabelFour;

@property (weak, nonatomic) IBOutlet UIButton *repairButton;

@property (weak, nonatomic) IBOutlet UIView *buttonBgView;

@property (nonatomic, assign) BOOL isShopRepairSuggestion;

@end

@implementation MaintenanceSuggestionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"维修建议";

//    {"repair_name":"ABS系统故障",
//        "tool_info":[{"tool":"千斤顶"},
//                     {"tool":"保险凳"},
//                     {"tool":"组合工具"}],
//        "part_info":[{"name":"ABS控制单元"}],
//        "partPrice":"暂无报价",
//        "sumPrice":"750.00",
//        "mhour":10}
//    }

    self.titleRepairNameLabel.text = self.resultData[@"repair_name"];
    self.repairNameLabel.text = self.titleRepairNameLabel.text;
    self.partsLabel.text = [[self.resultData[@"part_info"] valueForKey:@"name"] componentsJoinedByString:@"，"];
    self.rightLabelThree.text = [NSString stringWithFormat:@"¥%0.2f", [SupportingClass verifyAndConvertDataToString:self.resultData[@"sumPrice"]].floatValue];
    
    self.rightLabelFour.text = [[self.resultData[@"tool_info"] valueForKey:@"tool"] componentsJoinedByString:@"、"];
    [self.theirOwnRepairButton setViewBorderWithRectBorder:UIRectBorderBottom borderSize:1.0f withColor:[UIColor colorWithHexString:@"49c7f5"] withBroderOffset:nil];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self.buttonBgView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5f withColor:nil withBroderOffset:nil];
    
}

- (IBAction)buttonClick:(UIButton *)button {
    
    [self removeAllEmbellish];
    [button setTitleColor:[UIColor colorWithHexString:@"49c7f5"] forState:UIControlStateNormal];
    [button setViewBorderWithRectBorder:UIRectBorderBottom borderSize:1.0f withColor:[UIColor colorWithHexString:@"49c7f5"] withBroderOffset:nil];
    if (button.tag==1) {
        self.isShopRepairSuggestion = NO;
        self.leftLabelThree.text = @"配件价格：";
        self.rightLabelThree.text = [NSString stringWithFormat:@"¥%0.2f", [SupportingClass verifyAndConvertDataToString:self.resultData[@"sumPrice"]].floatValue];
        
        self.leftLabelFour.text = @"所需工具：";
        self.rightLabelFour.text = [[self.resultData[@"tool_info"] valueForKey:@"tool"] componentsJoinedByString:@"、"];
        
        [self.repairButton setTitle:@"操作指南" forState:UIControlStateNormal];
    }else {
        self.isShopRepairSuggestion = YES;
        self.leftLabelThree.text = @"工时估算：";
        self.rightLabelThree.text = [SupportingClass verifyAndConvertDataToString:self.resultData[@"mhour"]];
        
        self.leftLabelFour.text = @"费用估算：";
        self.rightLabelFour.text = [NSString stringWithFormat:@"¥%0.2f", [SupportingClass verifyAndConvertDataToString:self.resultData[@"sumPrice"]].floatValue];
        
        [self.repairButton setTitle:@"查找商家" forState:UIControlStateNormal];
    }
    
    
}

- (void)removeAllEmbellish {
    [self.theirOwnRepairButton setViewBorderWithRectBorder:UIRectBorderNone borderSize:0.0f withColor:nil withBroderOffset:nil];
    [self.businessRepairButton setViewBorderWithRectBorder:UIRectBorderNone borderSize:0.0f withColor:nil withBroderOffset:nil];
    [self.theirOwnRepairButton setTitleColor:[UIColor colorWithHexString:@"333333"] forState:UIControlStateNormal];
    [self.businessRepairButton setTitleColor:[UIColor colorWithHexString:@"333333"] forState:UIControlStateNormal];
    
}

- (IBAction)repairButtonClick:(id)sender {
    if (self.isShopRepairSuggestion) {
        RepairShopResultsVC *vc = [RepairShopResultsVC new];
        [self setDefaultNavBackButtonWithoutTitle];
        vc.repairItem = self.repairItem;
        [self.navigationController pushViewController:vc animated:YES];
    }else {
        [self getRepairGuideProcedureDetail];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)getRepairGuideProcedureDetail {
    [ProgressHUDHandler showHUD];
    @weakify(self);
    [APIsConnection.shareConnection repairGuideAPIsGetRepairGuideProcedureDetailWithProcedureDetailID:self.procedureDetailID success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        NSLog(@"维修指南 %@",operation.currentRequest.URL.absoluteString);
        [ProgressHUDHandler dismissHUD];
        if (errorCode!=0&&![message isEqualToString:@"返回成功"]) {
            [ProgressHUDHandler dismissHUD];
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
            return;
        }
        if (responseObject) {
            [self goToPepairGuideWithProcedureDetail:responseObject[CDZKeyOfResultKey] andTitle:self.titleName];
        }
        
        
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

- (void)goToPepairGuideWithProcedureDetail:(NSDictionary *)procedureDetail andTitle:(NSString *)title {
    @autoreleasepool {
        MaintenanceGuideVC *vc = [MaintenanceGuideVC new];
        vc.procedureDetail = procedureDetail;
        vc.title = title;
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
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
