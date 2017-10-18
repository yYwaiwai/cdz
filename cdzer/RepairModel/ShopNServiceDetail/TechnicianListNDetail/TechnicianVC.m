//
//  TechnicianVC.m
//  cdzer
//
//  Created by 车队长 on 16/7/25.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "TechnicianVC.h"
#import "TechnicianDetailsVC.h"
#import <ODRefreshControl/ODRefreshControl.h>
#import <MJRefresh/MJRefresh.h>
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>

@interface TechnicianListCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *technicianPortraitIV;

@property (nonatomic, weak) IBOutlet UILabel *technicianNameLabel;

@property (nonatomic, weak) IBOutlet UILabel *technicianWorkingExperienceLabel;

@property (nonatomic, weak) IBOutlet UILabel *technicianWorkingSpecLabel;

@end

@implementation TechnicianListCell

@end

@interface TechnicianVC ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (weak, nonatomic) IBOutlet UITableView *tableView;


@property (nonatomic, strong) NSMutableArray <NSDictionary *> *technicianList;

@end

@implementation TechnicianVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    [self.searchBar setContentMode:UIViewContentModeLeft];
    [self.searchBar setDelegate:self];
    
    self.title = self.onlyForSelection?@"技师选择":@"技师中心";
    self.technicianList = [NSMutableArray array];
    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 100;
    self.tableView.tableFooterView = [UIView new];
    [self.tableView registerNib:[UINib nibWithNibName:@"TechnicianListCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    ODRefreshControl *refreshControl = [[ODRefreshControl alloc] initInScrollView:self.tableView];
    [refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(refreshView:)];
    self.tableView.mj_footer.automaticallyHidden = NO;
    self.tableView.mj_footer.hidden = YES;
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    [self getMaintenanceShopsTechnicianList:nil isReloadAll:YES];
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *text = @"暂无更多技师数据！";
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0f],
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TechnicianListCell *cell = [tableView dequeueReusableCellWithIdentifier:CDZKeyOfCellIdentKey forIndexPath:indexPath];
    
    NSDictionary *detail = self.technicianList[indexPath.row];
    cell.technicianPortraitIV.image = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"eservice_default_img_M@3x" ofType:@"png"]];
    NSString *imgString = detail[@"face_img"];
    if ([imgString isContainsString:@"http"]) {
        [cell.technicianPortraitIV setImageWithURL:[NSURL URLWithString:imgString] placeholderImage:[UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"eservice_default_img_M@3x" ofType:@"png"]] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    cell.technicianNameLabel.text = detail[@"real_name"];
    NSString *workingGrade = detail[@"aptitude_type_name"];
    NSString *workingExperience = detail[@"work_age"];
    NSString *workingItem = [[detail[@"speciality_info"] valueForKey:@"name"] componentsJoinedByString:@"+"];
    workingItem = [workingItem stringByReplacingOccurrencesOfString:@" " withString:@""];
    workingItem = [workingItem stringByReplacingOccurrencesOfString:@"+" withString:@"  "];
    

    cell.technicianWorkingExperienceLabel.text = [NSString stringWithFormat:@"资质：%@  工龄：%@", workingGrade, workingExperience];
    cell.technicianWorkingSpecLabel.text = workingItem;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.onlyForSelection) {
        if (self.resultBlock) {
            self.selectedEngineerData = self.technicianList[indexPath.row];
            self.resultBlock(self.selectedEngineerData);
        }
        [self.navigationController popViewControllerAnimated:YES];
    }else {
        TechnicianDetailsVC *vc = [[TechnicianDetailsVC alloc]init];
        vc.technicianID = [SupportingClass verifyAndConvertDataToString:[self.technicianList[indexPath.row] objectForKey:@"id"]];
        [self.navigationController pushViewController:vc animated:YES];
        [self setDefaultNavBackButtonWithoutTitle];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.technicianList.count;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // 设置需要的偏移量,这个UIEdgeInsets左右偏移量不要太大，不然会titleLabel也会便宜的。
    UIEdgeInsets inset = UIEdgeInsetsMake(0, 10, 0, 0);
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) { // iOS8的方法
        if (indexPath.row==self.technicianList.count-1) {
            [cell setLayoutMargins:UIEdgeInsetsZero];
        } else {
            // 设置边界为0，默认是{8,8,8,8}
            [cell setLayoutMargins:inset];
        }
        
    }
    
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        
        if (indexPath.row==self.technicianList.count-1) {
            [cell setSeparatorInset:UIEdgeInsetsZero];
        } else {
            [cell setSeparatorInset:inset];
        }
    }
}

- (void)handleData:(id)refresh {
    [self getMaintenanceShopsTechnicianList:refresh isReloadAll:[refresh isKindOfClass:ODRefreshControl.class]];
}

- (void)pageObjectPlusOne {
    self.pageNums = @(self.pageNums.integerValue+1);
}

- (void)stopRefresh:(id)refresh {
    if (refresh&&[refresh respondsToSelector:@selector(endRefreshing)]) {
        [refresh endRefreshing];
    }
}

- (void)refreshView:(id)refresh {
    BOOL isRefreshing = NO;
    if ([refresh isKindOfClass:[ODRefreshControl class]]) {
        isRefreshing = [(ODRefreshControl *)refresh refreshing];
    }else if ([refresh isKindOfClass:[MJRefreshAutoNormalFooter class]]) {
        isRefreshing = [(MJRefreshAutoNormalFooter *)refresh isRefreshing];
        [self pageObjectPlusOne];
    }
    if (isRefreshing) {
        [self performSelector:@selector(handleData:) withObject:refresh afterDelay:1.5];
    }
}


#pragma mark--searchBar的delegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    
    [searchBar setShowsCancelButton:YES animated:YES];
    for (UIView *view in [searchBar subviews]) {
        for (UIView *subview in [view subviews]) {
            if ([subview isKindOfClass:[UIButton class]] && [[(UIButton *)subview currentTitle] isEqualToString:@"Cancel"] ) {
                [(UIButton*)subview setTitle:@"取消" forState:UIControlStateNormal];
            }
        }
    }
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
     
- (void)getMaintenanceShopsTechnicianList:(id)refreshView isReloadAll:(BOOL)isReloadAll {
    
    if(isReloadAll&&!refreshView){
        [ProgressHUDHandler showHUD];
    }
    
    if (isReloadAll) {
        [self pageObjectToDefault];

    }
    @weakify(self);
    
    
    [[APIsConnection shareConnection] maintenanceShopsAPIsGetMaintenanceShopsTechnicianListWithShopID:self.shopID pageNums:self.pageNums pageSizes:self.pageSizes success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        if (errorCode!= 0) {
            if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:!refreshView]) {return;};
            if(isReloadAll&&!refreshView){
                [ProgressHUDHandler dismissHUD];
            }else{
                [self stopRefresh:refreshView];
                if (![message isContainsString:@"数据"]) {
                    self.pageNums = @(self.pageNums.integerValue-1);
                }
            }
            [SupportingClass showAlertViewWithTitle:@"" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            }];
            return ;
        }
        
        if (isReloadAll&&!refreshView) {
            [ProgressHUDHandler dismissHUD];
        }else{
            [self stopRefresh:refreshView];
        }
        
        if (isReloadAll) {
            [self.technicianList removeAllObjects];
        }
        self.pageNums = [SupportingClass verifyAndConvertDataToNumber:responseObject[CDZKeyOfPageNumsKey]];
        self.pageSizes = [SupportingClass verifyAndConvertDataToNumber:responseObject[CDZKeyOfPageSizesKey]];
        self.totalPageSizes = [SupportingClass verifyAndConvertDataToNumber:responseObject[CDZKeyOfTotalPageSizesKey]];
        self.tableView.mj_footer.hidden = ((self.pageNums.intValue*self.pageSizes.intValue)>= self.totalPageSizes.intValue);
        
        [self.technicianList addObjectsFromArray:responseObject[CDZKeyOfResultKey]];
        [self.tableView reloadData];
        if (self.selectedEngineerData&&self.onlyForSelection) {
            NSInteger idx = [self.technicianList indexOfObject:self.selectedEngineerData];
            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
        }
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        @strongify(self);
        if(isReloadAll&&!refreshView){
            [ProgressHUDHandler dismissHUD];
        }else{
            [self stopRefresh:refreshView];
            self.pageNums = @(self.pageNums.integerValue-1);
        }
        if (error.code == -1009) {
            [SupportingClass showAlertViewWithTitle:@"error" message:@"网络连接失败，请检查网络设置！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            }];
            return;
        }
        
        
        if (error.code == -1001) {
            [SupportingClass showAlertViewWithTitle:@"error" message:@"网络连接逾时，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            }];
            return;
        }
        
        [SupportingClass showAlertViewWithTitle:@"error" message:@"网络错误，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
        }];
        
    }];
}

@end
