//
//  DiagnosticResultsVC.m
//  cdzer
//
//  Created by 车队长 on 16/10/28.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "DiagnosticResultsVC.h"
#import "DiagnosticResultsCell.h"
#import "MaintenanceGuideVC.h"
#import "SelfInspectVC.h"
#import "MaintenanceSuggestionVC.h"
//#import "DRVCCircularMenu.h"
#import "RepairShopResultsVC.h"

@interface DiagnosticResultsVC ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet UIView *animationView;

@property (weak, nonatomic) IBOutlet UIButton *plusButton;

@property (weak, nonatomic) IBOutlet UIImageView *plusImageView;

@property (weak, nonatomic) IBOutlet UIView *optionsView;//选项View

@property (weak, nonatomic) IBOutlet UIImageView *optionsImageView;

@property (weak, nonatomic) IBOutlet UIControl *findBusinessesControl;//查找商家

@property (weak, nonatomic) IBOutlet UIControl *maintenanceGuideControl;//维修指南

@property (weak, nonatomic) IBOutlet UIControl *continueToViewControl;//继续检查

//@property (strong, nonatomic) IBOutlet DRVCCircularMenu *circularMenuView;

@property (nonatomic, assign)BOOL isShow;

@property (nonatomic, assign)BOOL isOptionsViewShow;

@property (nonatomic, strong) UserSelectedAutosInfoDTO *autosSelectedData;

@property (nonatomic, strong) NSIndexPath *indexPathForSelectedRow;

@property (nonatomic, assign) BOOL isSelectedRow;


@end

@implementation DiagnosticResultsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"诊断结果";
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 44.0f;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor=self.view.backgroundColor;
    UINib*nib = [UINib nibWithNibName:@"DiagnosticResultsCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"DiagnosticResultsCell"];
    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    
    self.optionsImageView.hidden=YES;
    self.findBusinessesControl.hidden=YES;
    self.maintenanceGuideControl.hidden=YES;
    self.continueToViewControl.hidden=YES;
    
    [self.findBusinessesControl addTarget:self action:@selector(findBusinessesControlClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.maintenanceGuideControl addTarget:self action:@selector(maintenanceGuideControlClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.continueToViewControl addTarget:self action:@selector(continueToViewControlClick:) forControlEvents:UIControlEventTouchUpInside];
    
}

- (IBAction)plusButtonClick:(UIButton*)sender {
    
    self.plusButton.selected=!sender.selected;
    self.isOptionsViewShow=sender.selected;
    [self.plusButton setImage:nil forState:UIControlStateNormal];
    if (!self.isOptionsViewShow) {
        NSString *imgName = (self.indexPathForSelectedRow)?@"zhenduanjieguo-selected-round@3x":@"zhenduanjieguo-unselect-round@3x";
        UIImage *image = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:imgName ofType:@"png"]];
        [self.plusButton setImage:image forState:UIControlStateNormal];
    }
    if (self.isOptionsViewShow==YES) {
        [self showOptionsView];
    }else{
        [self dismissOptionsView];
    }
    
    
}

- (void)showOptionsView {
    @weakify(self);
    [UIView animateWithDuration:0.25 animations:^{
        @strongify(self);
        self.optionsImageView.hidden=NO;
        self.findBusinessesControl.hidden=NO;
        self.maintenanceGuideControl.hidden=NO;
        self.continueToViewControl.hidden=NO;
        self.plusImageView.transform=CGAffineTransformMakeRotation(M_PI/4);
    } completion:^(BOOL finished) {
        @strongify(self);
        self.isShow=YES;
    }];
}

- (void)dismissOptionsView {
    @weakify(self);
    [UIView animateWithDuration:0.25 animations:^{
        @strongify(self);
        self.optionsImageView.hidden=YES;
        self.findBusinessesControl.hidden=YES;
        self.maintenanceGuideControl.hidden=YES;
        self.continueToViewControl.hidden=YES;
        self.plusImageView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        @strongify(self);
        self.isShow=NO;
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.resultList.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ident = @"DiagnosticResultsCell";
    DiagnosticResultsCell *cell = [tableView dequeueReusableCellWithIdentifier:ident forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.titleLabel.text=[self.resultList[indexPath.row] objectForKey:@"name"];
    cell.contentLabel.text=[self.resultList[indexPath.row] objectForKey:@"detail_content"];
    
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.indexPathForSelectedRow = indexPath;
    self.isSelectedRow=YES;
    if ([self.plusButton imageForState:UIControlStateNormal]) {
        [self.plusButton setImage:nil forState:UIControlStateNormal];
    }
    self.optionsImageView.highlighted = YES;
    self.plusButton.selected = YES;
    if (!self.isOptionsViewShow) {
        self.isOptionsViewShow = YES;
        [self showOptionsView];
    }
}

- (void)confirmTheResult:(NSDictionary *)resultData {
    @autoreleasepool {
        MaintenanceSuggestionVC *sdrVC = [[MaintenanceSuggestionVC alloc] init];
        sdrVC.resultData = resultData;
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:sdrVC animated:YES];
    }
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

- (void)goToNextStepWithRepairGuideDetail:(NSDictionary *)repairGuideDetail procedureDetailID:(NSString *)procedureDetailID andTitle:(NSString *)title andRepairItem:(NSString *)repairItem {
    @autoreleasepool {
        SelfInspectVC *vc = [SelfInspectVC new];
        vc.repairGuideDetail = repairGuideDetail;
        vc.procedureDetailID = procedureDetailID;
        vc.title = @"继续检查";
        vc.titleName = title;
        vc.repairItem = repairItem;
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }
}


//查找商家
- (void)findBusinessesControlClick:(UIButton*)button {
    if (self.isSelectedRow==YES) {
//    if (!self.indexPathForSelectedRow) return;
    NSString *repairItem = [self.resultList[self.indexPathForSelectedRow.row] objectForKey:@"service_item"];
    @autoreleasepool {
        RepairShopResultsVC *vc = [RepairShopResultsVC new];
        [self setDefaultNavBackButtonWithoutTitle];
        vc.repairItem = repairItem;
        [self.navigationController pushViewController:vc animated:YES];
    }
        
    }
}
//维修指南
- (void)maintenanceGuideControlClick:(UIButton*)button {
    if (self.isSelectedRow==YES) {
//    if (!self.indexPathForSelectedRow) return;
    NSString *reasonName = [self.resultList[self.indexPathForSelectedRow.row] objectForKey:@"name"];
    NSString *repairGuideID = [self.resultList[self.indexPathForSelectedRow.row] objectForKey:@"relateId"];
    if (!reasonName||!repairGuideID) {
        NSLog(@"Missing Parameters");
        return;
    }
        if (repairGuideID.length==0) {
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:@"暂无维修指南！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
            return;
        }
    
    [self getRepairGuideProcedureDetail:repairGuideID withTitle:reasonName];
        
    }
}
//继续检查
- (void)continueToViewControlClick:(UIButton*)button {
    if (self.isSelectedRow==YES) {
//    if (!self.indexPathForSelectedRow) return;
    NSString *repairItem = [self.resultList[self.indexPathForSelectedRow.row] objectForKey:@"service_item"];
    NSString *reasonName = [self.resultList[self.indexPathForSelectedRow.row] objectForKey:@"name"];
    NSString *repairGuideID = [self.resultList[self.indexPathForSelectedRow.row] objectForKey:@"relateId"];
    if (!reasonName||!repairGuideID) {
        NSLog(@"Missing Parameters");
        return;
    }
        if (repairGuideID.length==0) {
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:@"暂无法检查！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
            return;
        }
    [self getNexitDiagnosisResultDetail:repairGuideID withTitle:reasonName andRepairItem:repairItem];
    }
}

- (void)getRepairGuideProcedureDetail:(NSString *)procedureDetailID withTitle:(NSString *)title {
    if (!procedureDetailID||[procedureDetailID isEqualToString:@""]) {
        return;
    }
    [ProgressHUDHandler showHUD];
    @weakify(self);
    [APIsConnection.shareConnection repairGuideAPIsGetRepairGuideProcedureDetailWithProcedureDetailID:procedureDetailID success:^(NSURLSessionDataTask *operation, id responseObject) {
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
            [self goToPepairGuideWithProcedureDetail:responseObject[CDZKeyOfResultKey] andTitle:title];
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

- (void)getNexitDiagnosisResultDetail:(NSString *)procedureDetailID  withTitle:(NSString *)title andRepairItem:(NSString *)repairItem {
    if (!procedureDetailID||[procedureDetailID isEqualToString:@""]) {
        return;
    }
    
    [ProgressHUDHandler showHUD];
    @weakify(self);
    [APIsConnection.shareConnection repairGuideAPIsGetRepairStepGuideDetailWithProcedureDetailID:procedureDetailID success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        NSLog(@"继续检查%@",operation.currentRequest.URL.absoluteString);
        [ProgressHUDHandler dismissHUD];
        if (errorCode!=0&&![message isEqualToString:@"返回成功"]) {
            [ProgressHUDHandler dismissHUD];
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
            return;
        }
        if (responseObject) {
            [self goToNextStepWithRepairGuideDetail:responseObject[CDZKeyOfResultKey] procedureDetailID:procedureDetailID andTitle:title andRepairItem:repairItem];
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
