//
//  RepairExpressVC.m
//  cdzer
//
//  Created by KEns0n on 11/25/15.
//  Copyright © 2015 CDZER. All rights reserved.
//

#import "RepairExpressVC.h"
#import "InsetsLabel.h"
#import "AutosSelectedView.h"
#import "VehicleSelectionPickerVC.h"
#import "RepairExpressPayVC.h"

@interface RepairExpressVC ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) AutosSelectedView *ASView;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) InsetsLabel *countingLabel;

@property (nonatomic, strong) NSArray *repairServiceList;

@end

@implementation RepairExpressVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.contentView setBackgroundColor:[UIColor colorWithRed:0.953f green:0.953f blue:0.953f alpha:1.00f]];
    [self setTitle:getLocalizationString(@"快捷保养")];
    [self initializationUI];
    [self componentSetting];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_ASView reloadUIData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)componentSetting {
    @autoreleasepool {
        NSDictionary *serviceDetail = DBHandler.shareInstance.getRepairShopServiceList;
        if (serviceDetail.count&&serviceDetail) {
            self.repairServiceList = @[serviceDetail[CDZObjectKeyOfConventionMaintain],
                                       serviceDetail[CDZObjectKeyOfDeepnessMaintain]];
        }
        [self setRightNavButtonWithTitleOrImage:@"submit" style:UIBarButtonItemStyleDone target:self action:@selector(getPurchaseList) titleColor:nil isNeedToSet:YES];
        
    }
}

- (void)initializationUI {
    @autoreleasepool {
        self.ASView = [[AutosSelectedView alloc] initWithOrigin:CGPointMake(0.0f, 0.0f) showMoreDeatil:NO onlyForSelection:NO];
        [self.contentView addSubview:_ASView];
        [_ASView addTarget:self action:@selector(pushToVehicleSelectedVC) forControlEvents:UIControlEventTouchUpInside];
        [_ASView setBorderWithColor:nil borderWidth:0.0f];
        
        InsetsLabel *topRemindLabel = [[InsetsLabel alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(_ASView.frame), CGRectGetWidth(self.contentView.frame), vAdjustByScreenRatio(24.0f))
                                                      andEdgeInsetsValue:DefaultEdgeInsets];
        topRemindLabel.backgroundColor = CDZColorOfBlue;
        topRemindLabel.text = @"你可以直接选择你需要的保养项目进行自助保养";
        topRemindLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 13.0f, YES);
        topRemindLabel.textColor = CDZColorOfWhite;
        [self.contentView addSubview:topRemindLabel];
        
        self.countingLabel = [[InsetsLabel alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(topRemindLabel.frame), CGRectGetWidth(self.contentView.frame), vAdjustByScreenRatio(24.0f))
                                                      andEdgeInsetsValue:DefaultEdgeInsets];
        _countingLabel.backgroundColor = CDZColorOfBlue;
        _countingLabel.text = @"已选择的服务项目：0项";
        _countingLabel.font = topRemindLabel.font;
        _countingLabel.textColor = topRemindLabel.textColor;
        [self.contentView addSubview:_countingLabel];
        
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(_countingLabel.frame),
                                                                       CGRectGetWidth(self.contentView.frame),
                                                                       CGRectGetHeight(self.contentView.frame)-CGRectGetMaxY(_countingLabel.frame))];
        _tableView.backgroundColor = CDZColorOfBackgroudColor;
        _tableView.bounces = NO;
        _tableView.editing = YES;
        _tableView.showsHorizontalScrollIndicator = YES;
        _tableView.showsVerticalScrollIndicator = YES;
        _tableView.allowsSelection = NO;
        _tableView.allowsMultipleSelection = NO;
        _tableView.allowsSelectionDuringEditing = YES;
        _tableView.allowsMultipleSelectionDuringEditing = YES;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self.contentView addSubview:_tableView];
        
    }
}

- (void)pushToVehicleSelectedVC {
    @autoreleasepool {
        VehicleSelectionPickerVC *vc = [VehicleSelectionPickerVC new];
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma -mark UITableViewDelgate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return _repairServiceList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [_repairServiceList[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CDZKeyOfCellIdentKey];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CDZKeyOfCellIdentKey];
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 16.0f, NO);
        
    }
    NSDictionary *configDetail = [_repairServiceList[indexPath.section] objectAtIndex:indexPath.row];
    cell.textLabel.text = @"";
    cell.textLabel.text = [[SupportingClass verifyAndConvertDataToString:configDetail[@"main_name"]] stringByReplacingOccurrencesOfString:@" " withString:@""];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    static NSString *headerIdentifier = @"header";
    UITableViewHeaderFooterView *myHeader = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerIdentifier];
    if(!myHeader) {
        myHeader = [[UITableViewHeaderFooterView alloc]initWithReuseIdentifier:headerIdentifier];
        InsetsLabel *titleLabel = [[InsetsLabel alloc] initWithFrame:CGRectZero
                                                  andEdgeInsetsValue:DefaultEdgeInsets];
        titleLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfBold, 17.5f, NO);
        titleLabel.backgroundColor = CDZColorOfBlack;
        titleLabel.textColor = CDZColorOfWhite;
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.tag = 10;
        titleLabel.translatesAutoresizingMaskIntoConstraints = YES;
        titleLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        [myHeader addSubview:titleLabel];
        
        [myHeader setNeedsUpdateConstraints];
        [myHeader updateConstraintsIfNeeded];
        [myHeader setNeedsLayout];
        [myHeader layoutIfNeeded];
    }
    InsetsLabel *titleLabel = (InsetsLabel *)[myHeader viewWithTag:10];
    titleLabel.text = (section==0)?@"常规保养项目":@"深度保养项目";
    return myHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30.0f;
}

- (void)updateSelectionCounting {
    _countingLabel.text = [NSString stringWithFormat:@"已选择的服务项目：%d项", _tableView.indexPathsForSelectedRows.count];
    
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self updateSelectionCounting];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self updateSelectionCounting];
}


- (void)getPurchaseList {
    @autoreleasepool {
        NSMutableArray *selectList = [@[] mutableCopy];
        NSMutableArray *selectStringList = [@[] mutableCopy];
        @weakify(self);
        [_tableView.indexPathsForSelectedRows enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull selectionIndex, NSUInteger idx, BOOL * _Nonnull stop) {
            @strongify(self);
            if (selectionIndex.section+1<=self.repairServiceList.count) {
                NSArray *list = [self.repairServiceList[selectionIndex.section] valueForKey:@"id"];
                NSArray *strList = [self.repairServiceList[selectionIndex.section] valueForKey:@"main_name"];
                [selectList addObject:list[selectionIndex.row]];
                [selectStringList addObject:[strList[selectionIndex.row] stringByReplacingOccurrencesOfString:@" " withString:@""]];
            }
        }];
        [self getPurchaseListWithMaintenanceIDList:selectList withMaintenanceStringList:selectStringList];
    }
    
}

- (void)pushToExpressPurchaseVC:(id)responseObject withMaintenanceStringList:(NSArray *)maintenanceStringList{
    @autoreleasepool {
        [ProgressHUDHandler dismissHUD];
        if (!responseObject||![responseObject isKindOfClass:NSArray.class]||[responseObject count]==0) {
            [SupportingClass showAlertViewWithTitle:nil message:@"找不到你所需求的结果！" isShowImmediate:YES cancelButtonTitle:nil otherButtonTitles:nil clickedButtonAtIndexWithBlock:nil];
            return;
        }
        
        NSMutableArray *reOrderList = [@[] mutableCopy];
        [maintenanceStringList enumerateObjectsUsingBlock:^(NSString * _Nonnull stringName, NSUInteger idx, BOOL * _Nonnull stop) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.maintain_name CONTAINS[cd] %@ ", stringName];
            NSArray *itemsList = [(NSArray *)responseObject filteredArrayUsingPredicate:predicate];
            NSDictionary *detail = @{@"title":stringName,
                                     @"list":itemsList};
            [reOrderList addObject:detail];
        }];
        
        RepairExpressPayVC *vc = RepairExpressPayVC.new;
        vc.purchaseList = reOrderList;
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
        
    }
}
- (void)showAlertDidNotSelectAutos {
    [SupportingClass showAlertViewWithTitle:@"alert_remind" message:@"请先选择车系车型" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
        
    }];
}

#pragma mark- API Access Code Section
- (void)getPurchaseListWithMaintenanceIDList:(NSArray *)maintenanceIDList withMaintenanceStringList:(NSArray *)maintenanceStringList{
    if (!maintenanceIDList||maintenanceIDList.count==0) {
        [SupportingClass showAlertViewWithTitle:nil message:@"请选择要保养项目" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            
        }];
        return;
    }
    
    if (!_ASView.autoData.modelID) {
        [self showAlertDidNotSelectAutos];
        return;
    }
    
    @weakify(self);
    [ProgressHUDHandler showHUD];
    [[APIsConnection shareConnection] theSelfMaintenanceAPIsGetMaintenancePartsRequestListWithPartsIDList:maintenanceIDList modelID:_ASView.autoData.modelID success:^(NSURLSessionDataTask *operation, id responseObject) {
        NSLog(@"%@",responseObject);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        if(errorCode!=0){
            [ProgressHUDHandler dismissHUD];
            [SupportingClass showAlertViewWithTitle:nil message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                
            }];
            return;
        }
        @strongify(self);
        [self pushToExpressPurchaseVC:[responseObject[CDZKeyOfResultKey] objectForKey:@"maintain_peijian"] withMaintenanceStringList:maintenanceStringList];
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
