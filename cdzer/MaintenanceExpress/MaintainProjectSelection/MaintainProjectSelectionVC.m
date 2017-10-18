//
//  MaintainProjectSelectionVC.m
//  cdzer
//
//  Created by 车队长 on 16/8/19.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "MaintainProjectSelectionVC.h"
#import "ProjectCell.h"
#import "MaintainDetailView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <SDWebImage/UIImageView+HighlightedWebCache.h>

@interface MaintainProjectSelectionVC ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIButton *routineMaintenanceButton;

@property (weak, nonatomic) IBOutlet UIButton *deepMaintenanceButton;

@property (weak, nonatomic) IBOutlet UIButton *determineButton;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet MaintainDetailView *detailView;

@property (nonatomic, assign) NSInteger typeIdx;

@property (nonatomic, strong) NSString * maintainProjectSelectionString;

@end

@implementation MaintainProjectSelectionVC

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self updateUILayouSubview];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self updateUILayouSubview];
}

- (void)updateUILayouSubview {
    
    BorderOffsetObject *offsets = [BorderOffsetObject new];
    offsets.bottomLeftOffset = round(offsets.leftBottomOffset = CGRectGetWidth(self.routineMaintenanceButton.frame)*0.2);
    
    offsets.bottomRightOffset = offsets.bottomLeftOffset;
    UIButton *showButton = self.routineMaintenanceButton;
    UIButton *dismissButton = self.deepMaintenanceButton;
    if (self.typeIdx==1) {
        showButton = self.deepMaintenanceButton;
        dismissButton = self.routineMaintenanceButton;
        
    }
    [showButton setViewBorderWithRectBorder:UIRectBorderBottom borderSize:1.0f withColor:[UIColor colorWithHexString:@"49C7F5"] withBroderOffset:offsets];
    [dismissButton setViewBorderWithRectBorder:UIRectBorderNone borderSize:1.0f withColor:nil withBroderOffset:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title=@"保养项目选择";
    [[UINib nibWithNibName:@"MaintainDetailView" bundle:nil] instantiateWithOwner:self options:nil];
    
    self.typeIdx = 0;
    self.dataSourceList = [@[] mutableCopy];
    if (!self.regularMaintenanceSelectedList) {
        self.regularMaintenanceSelectedList = [NSMutableSet set];
    }
    if (!self.deepMaintenanceSelectedList) {
        self.deepMaintenanceSelectedList = [NSMutableSet set];
    }
    NSDictionary *serviceDetail = DBHandler.shareInstance.getMaintenanceServiceList;
    if (serviceDetail.count&&serviceDetail) {
        [self.dataSourceList addObjectsFromArray:@[serviceDetail[CDZObjectKeyOfConventionMaintain],
                                                   serviceDetail[CDZObjectKeyOfDeepnessMaintain]]];
    }
    [self.routineMaintenanceButton addTarget:self action:@selector(maintenanceButtonClick:) forControlEvents:UIControlEventTouchUpInside];
     [self.deepMaintenanceButton addTarget:self action:@selector(maintenanceButtonClick:) forControlEvents:UIControlEventTouchUpInside];

    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.tableFooterView = [UIView new];
    [self.tableView registerNib:[UINib nibWithNibName:@"ProjectCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    [
     self.determineButton.layer setCornerRadius:3.0];
    [self.determineButton.layer setMasksToBounds:YES];
    if (self.dataSourceList.count<2) {
        [self getMaintenanceExpressServiceList];
    }else {
        [self buttontitle];
        [self.tableView reloadData];
        [self updateTableViewSelection];
    }
}

- (void)buttontitle {
    NSUInteger norMainCount = 0;
    NSUInteger deepMainCount = 0;
    if (self.dataSourceList.count==2) {
        norMainCount = [self.dataSourceList[0] count];
        deepMainCount = [self.dataSourceList[1] count];
    }
    NSString*routineMaintenanceButtonStr=[NSString stringWithFormat:@"常规保养(%d/%d)",self.regularMaintenanceSelectedList.count, norMainCount];
    NSString*deepMaintenanceButtonStr=[NSString stringWithFormat:@"深度保养(%d/%d)",self.deepMaintenanceSelectedList.count,deepMainCount];
    @weakify(self);
    [UIView performWithoutAnimation:^{
        @strongify(self);
        [self.routineMaintenanceButton setTitle:routineMaintenanceButtonStr forState:UIControlStateNormal];
        [self.deepMaintenanceButton setTitle:deepMaintenanceButtonStr forState:UIControlStateNormal];
        [self.routineMaintenanceButton layoutIfNeeded];
        [self.deepMaintenanceButton layoutIfNeeded];
    }];
}

- (void)updateTableViewSelection {
    if (self.dataSourceList.count>=2&&self.typeIdx==0&&self.regularMaintenanceSelectedList.count>0) {
        @weakify(self);
        [self.regularMaintenanceSelectedList enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, BOOL * _Nonnull stop) {
            @strongify(self);
            [self.tableView selectRowAtIndexPath:obj animated:NO scrollPosition:UITableViewScrollPositionNone];
        }];
    }else if (self.dataSourceList.count>=2&&self.typeIdx==1&&self.deepMaintenanceSelectedList.count>0) {
        @weakify(self);
        [self.regularMaintenanceSelectedList enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, BOOL * _Nonnull stop) {
            @strongify(self);
            [self.tableView selectRowAtIndexPath:obj animated:NO scrollPosition:UITableViewScrollPositionNone];
        }];
    }
}

- (void)showDetailView:(NSIndexPath *)indexPath {
    NSDictionary *detail = [self.dataSourceList[self.typeIdx] objectAtIndex:indexPath.row];
    self.detailView.titleLabel.text = detail[@"name"];
    self.detailView.contentLabel.text = detail[@"describle"];
    [self.detailView showView];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    "id": "15090210255229074544",
//    "uncheck_icon": "http://cdz.cdzer.net:80/imgUpload/uploads/20160721112632bRM8aG07b4.png",
//    "describle": "汽车保养是指定期对汽车相关部分进行检查、清洁、补给、润滑、调整或更换某些零件的预防性工作，又称汽车维护。\r\n  汽车保养的目的是保持车辆技术状况正常，消除隐患，预防故障发生，减缓劣化过程，延长使用周期",
//    "name": "更换空气格",
//    "mark": 0,
//    "check_icon": "http://cdz.cdzer.net:80/imgUpload/uploads/20160721112646qg4c9DvZUi.png
    
    
    ProjectCell *cell = [tableView dequeueReusableCellWithIdentifier:CDZKeyOfCellIdentKey forIndexPath:indexPath];
    cell.indexPath = indexPath;
    NSDictionary *detail = [self.dataSourceList[self.typeIdx] objectAtIndex:indexPath.row];
    NSString *checkIcon = detail[@"check_icon"];
    NSString *uncheckIcon = detail[@"uncheck_icon"];
    
    if ([checkIcon isContainsString:@"http"]) {
        [cell.titleImageView sd_setHighlightedImageWithURL:[NSURL URLWithString:checkIcon]];
    }
    
    if ([uncheckIcon isContainsString:@"http"]) {
        [cell.titleImageView sd_setImageWithURL:[NSURL URLWithString:uncheckIcon]];
    }
    
    if (!cell.detailBlock) {
        @weakify(self);
        cell.detailBlock = ^(NSIndexPath *indexPath){
            @strongify(self);
            [self showDetailView:indexPath];
        };
    }
    
    cell.titleLabel.text=detail[@"name"];
 
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.dataSourceList.count==0) {
        return 0;
    }
    return [self.dataSourceList[self.typeIdx] count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.typeIdx==0) {
        [self.regularMaintenanceSelectedList addObject:indexPath];
    }else {
        [self.deepMaintenanceSelectedList addObject:indexPath];
    }
    [self buttontitle];
    
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.typeIdx==0) {
        [self.regularMaintenanceSelectedList removeObject:indexPath];
    }else {
        [self.deepMaintenanceSelectedList removeObject:indexPath];
    }
    [self buttontitle];
}

- (void)maintenanceButtonClick:(UIButton*)button {
    self.routineMaintenanceButton.selected = NO;
    self.deepMaintenanceButton.selected = NO;
    button.selected = YES;
    if (button==self.routineMaintenanceButton) self.typeIdx = 0;
        else self.typeIdx = 1;
    
    [self updateUILayouSubview];
    [self.tableView reloadData];
    @weakify(self);
    if (button==self.routineMaintenanceButton) {
        [self.regularMaintenanceSelectedList enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, BOOL * _Nonnull stop) {
            @strongify(self);
            [self.tableView selectRowAtIndexPath:obj animated:NO scrollPosition:UITableViewScrollPositionNone];
        }];
    }else {
        @strongify(self);
        [self.deepMaintenanceSelectedList enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, BOOL * _Nonnull stop) {
            [self.tableView selectRowAtIndexPath:obj animated:NO scrollPosition:UITableViewScrollPositionNone];
        }];
    }
    
}

- (IBAction)determineButton:(id)sender {
    if (self.regularMaintenanceSelectedList.count==0&&
        self.deepMaintenanceSelectedList.count==0) {
        [SupportingClass showAlertViewWithTitle:nil message:@"请至少选择一个项目" isShowImmediate:YES cancelButtonTitle:@"cancel" otherButtonTitles:@"ok" clickedButtonAtIndexWithBlock:nil];
        return;
    }
    if (self.selectionBlock) {
        self.selectionBlock(self.regularMaintenanceSelectedList, self.deepMaintenanceSelectedList, self.dataSourceList);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getMaintenanceExpressServiceList {
    
    @weakify(self);
    [ProgressHUDHandler showHUD];
    [APIsConnection.shareConnection maintenanceExpressAPIsGetmaintenanceExpressServiceItemListWithSuccess:^(NSURLSessionDataTask *operation, id responseObject) {
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
        NSDictionary *detail = responseObject[CDZKeyOfResultKey];
        [self.dataSourceList addObjectsFromArray:@[detail[@"regular_maintain"], detail[@"depth_maintain"]]];
        [NSUserDefaults.standardUserDefaults setObject:self.dataSourceList forKey:kMaintenanceItemListObject];
        [NSUserDefaults.standardUserDefaults synchronize];
        [self buttontitle];
        [self.tableView reloadData];
        [self updateTableViewSelection];
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
