//
//  MYCumulativeScoringVC.m
//  cdzer
//
//  Created by 车队长 on 16/8/17.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "MYCumulativeScoringVC.h"
#import "CumulativeScoringHeadView.h"
#import "CumulativeScoringCell.h"
#import <ODRefreshControl/ODRefreshControl.h>
#import <MJRefresh/MJRefresh.h>
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import "Masonry.h"

@interface MYCumulativeScoringVC ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableview;

@property (nonatomic , strong) CumulativeScoringHeadView * headView;

/// 数据清单列表
@property (nonatomic, strong) NSMutableArray *creditList;

@property (nonatomic,strong) NSString *existingIntegralString;

@property(nonatomic,strong) UILabel *numberLable;

@property(nonatomic,strong) UIImageView *bgImageView;
@end

@implementation MYCumulativeScoringVC
- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getUserCreditListWithRefreshView:nil isAllReload:YES];
}
- (void)componentSetting {
    
    //    self.editButtonItem.title = getLocalizationString(@"edit");
    //    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self pageObjectToDefault];
    self.creditList = [NSMutableArray array];
}
- (void)reloadViewData {
    [super reloadViewData];
    [self getUserCreditListWithRefreshView:nil isAllReload:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title=@"我的积分";
    [self initializationUI];
    [self componentSetting];
    
    self.tableview.rowHeight = UITableViewAutomaticDimension;
    self.tableview.estimatedRowHeight = 121.0f;
    self.tableview.tableFooterView=[UIView new];
    self.tableview.backgroundColor=self.view.backgroundColor;
    self.tableview.showsVerticalScrollIndicator = NO;
    UINib*nib=[UINib nibWithNibName:@"CumulativeScoringCell" bundle:nil];
    [self.tableview registerNib:nib forCellReuseIdentifier:@"CumulativeScoringCell"];
    
    
    ODRefreshControl *refreshControl = [[ODRefreshControl alloc] initInScrollView:_tableview];
    [refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    _tableview.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(refreshView:)];
    _tableview.mj_footer.automaticallyHidden = NO;
    _tableview.mj_footer.hidden = YES;
}
- (void)initializationUI
{
    
    _bgImageView=[[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)/2, 13, 176, 90)];
    [_bgImageView setCenter:CGPointMake(self.view.frame.size.width/2, _bgImageView.frame.size.height/2+13)];
    _bgImageView.image=[UIImage imageNamed:@"wallet@3x.png"];
    [self.view addSubview:_bgImageView];
    @weakify(self);
    [_bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.centerX.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view).offset(13);
        make.height.mas_offset(90);
    }];
    
    
    UILabel*existingCumulativeScoringLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 50, 12)];
    [existingCumulativeScoringLabel setCenter:CGPointMake(_bgImageView.frame.size.width/2, 25)];
    existingCumulativeScoringLabel.text=@"现有积分";
    existingCumulativeScoringLabel.font=[UIFont systemFontOfSize:10];
    existingCumulativeScoringLabel.textColor=[UIColor orangeColor];
    [_bgImageView addSubview:existingCumulativeScoringLabel];
    
    _numberLable=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 160, 13)];
    [_numberLable setCenter:CGPointMake(_bgImageView.frame.size.width/2, 45)];
    _numberLable.textColor=[UIColor orangeColor];
    _numberLable.textAlignment=NSTextAlignmentCenter;
    [_bgImageView addSubview:_numberLable];
    _numberLable.text= self.existingIntegralString;
    
//    _headView=[[CumulativeScoringHeadView alloc]initWithFrame:CGRectMake(0, 13, CGRectGetWidth(self.view.frame), 103)];
//    _headView.numberLable.text= self.existingIntegralString;
//    [self.view addSubview:_headView];
}
- (void)refreshView:(id)refresh {
    if (!self.accessToken) {
        [self stopRefresh:refresh];
        return;
    }
    if ([refresh isKindOfClass:[ODRefreshControl class]]) {
        if ([(ODRefreshControl *)refresh refreshing]) {
            [self pageObjectToDefault];
        }
        
    }else if ([refresh isKindOfClass:[MJRefreshAutoNormalFooter class]]){
        if ([(MJRefreshAutoNormalFooter *)refresh isRefreshing]) {
            self.pageNums = @(self.pageNums.integerValue+1);
        }
    }
    [self performSelector:@selector(delayHandleData:) withObject:refresh afterDelay:1.5];
}
- (void)delayHandleData:(id)refresh {
    
    if ([refresh isKindOfClass:[ODRefreshControl class]]) {
        if ([(ODRefreshControl *)refresh refreshing]) {
            [self getUserCreditListWithRefreshView:refresh isAllReload:YES];
        }
        
    }else if ([refresh isKindOfClass:[MJRefreshAutoNormalFooter class]]){
        if ([(MJRefreshAutoNormalFooter *)refresh isRefreshing]) {
            self.pageNums = @(self.pageNums.integerValue+1);
            [self getUserCreditListWithRefreshView:refresh isAllReload:NO];
        }
    }
    
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ident=@"CumulativeScoringCell";
    CumulativeScoringCell*cell=(CumulativeScoringCell*)[tableView dequeueReusableCellWithIdentifier:ident];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    if (self.creditList.count>0) {
        NSDictionary *dic=self.creditList[indexPath.row];
        cell.creditsLabel.text=[NSString stringWithFormat:@"%@",dic[@"credits"]];
        cell.typeLabel.text=[NSString stringWithFormat:@"类型:%@",dic[@"type"]];
        if ([dic[@"type"] isEqualToString:@"支出"]) {
            cell.creditsLabel.textColor=[UIColor colorWithRed:50.00/255.00 green:50.00/255.00 blue:50.00/255.00 alpha:1.0];
        }else{
            cell.creditsLabel.textColor=CDZColorOfOrangeColor;
        }
        cell.addTimeLabel.text=dic[@"add_time"];
        cell.contentLabel.text=[NSString stringWithFormat:@"%@",dic[@"main_id"]];
        cell.remarkLabel.text=[NSString stringWithFormat:@"说明: %@",dic[@"remark"]];
    }
    
    return cell;
}


- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *text = @"暂无更多积分历史！";
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0f],
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (void)emptyDataSet:(UIScrollView *)scrollView didTapView:(UIView *)view {
    [self getUserCreditListWithRefreshView:nil isAllReload:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    self.tableview.separatorStyle = (_creditList.count==0)?UITableViewCellSeparatorStyleNone:UITableViewCellSeparatorStyleSingleLine;
    return _creditList.count;
   
}


- (void)stopRefresh:(id)refresh {
    [refresh endRefreshing];
}

#pragma mark- API Access Code Section
- (void)getUserCreditListWithRefreshView:(id)refreshView isAllReload:(BOOL)isAllReload {
    
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    if (!refreshView) [ProgressHUDHandler showHUD];
    
    
    @weakify(self);
    [[APIsConnection shareConnection] personalCenterAPIsGetCreditPointsHistoryWithAccessToken:self.accessToken pageNums:self.pageNums pageSizes:self.pageSizes success:^(NSURLSessionDataTask *operation, id responseObject) {
        if(!refreshView){
            [ProgressHUDHandler dismissHUD];
        }else{
            [self stopRefresh:refreshView];
        }
        
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        if(errorCode!=0){
            [SupportingClass showAlertViewWithTitle:@"error" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                
            }];
            return;
        }
        self.totalPageSizes = @([responseObject[CDZKeyOfTotalPageSizesKey] integerValue]);
        self.pageNums = responseObject[CDZKeyOfPageNumsKey];
        self.pageSizes = responseObject[CDZKeyOfPageSizesKey];
        self.tableview.mj_footer.hidden = ((self.pageNums.intValue*self.pageSizes.intValue)>=self.totalPageSizes.intValue);
        @strongify(self);
        if (isAllReload) [self.creditList removeAllObjects];
        NSDictionary* detailData = responseObject[CDZKeyOfResultKey];
        
        
        
//        self.totalCredits = @([detailData[@"credits_all"] doubleValue]);
//        [self updateTotalCredit];
        [self.creditList addObjectsFromArray:detailData[@"credits_list"]];
        self.existingIntegralString=detailData[@"credits_all"];
        self.numberLable.text= self.existingIntegralString;
        [self.tableview reloadData];
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        if(!refreshView){
            [ProgressHUDHandler dismissHUD];
        }else{
            [self stopRefresh:refreshView];
        }
        
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
