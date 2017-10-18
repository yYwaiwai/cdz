//
//  MyCouponVC.m
//  cdzer
//
//  Created by 车队长 on 16/8/17.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "MyCouponVC.h"
#import "MyCouponCell.h"
#import <ODRefreshControl/ODRefreshControl.h>
#import <MJRefresh/MJRefresh.h>
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>

@interface MyCouponVC ()<UITableViewDelegate,UITableViewDataSource,DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, weak) IBOutlet UIControl *controlOne;

@property (nonatomic, weak) IBOutlet UIControl *controlTwo;

@property (nonatomic, weak) IBOutlet UIControl *controlThree;


@property (weak, nonatomic) IBOutlet UILabel *labelOne;

@property (weak, nonatomic) IBOutlet UILabel *labelTwo;

@property (weak, nonatomic) IBOutlet UILabel *labelThree;

@property (nonatomic,strong) NSString * availableString;//可用。不可用，过期

@property (nonatomic, strong) NSNumber *status;//0未使用，1已使用，2已过期
/// 我的优惠券列表数组
@property (nonatomic, strong) NSMutableArray *myCouponList;

@property (nonatomic,strong) NSString * preferAllStr;
/// 控件刷新模块
@property (nonatomic, strong) ODRefreshControl *refreshControl;

@end

@implementation MyCouponVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title=@"我的优惠券";
    
    [self componentSetting];
    [self initializationUI];
    [self setReactiveRules];
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
    [self getMyCollectedCouponListWithRefreshView:nil isReloadAll:YES];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)componentSetting {
    self.totalPageSizes = @(0);
    self.pageNums = @(1);
    self.pageSizes = @(10);
    self.status = @(0);
    self.myCouponList = [NSMutableArray array];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 122.0f;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.showsVerticalScrollIndicator = NO;
    UINib*nib = [UINib nibWithNibName:@"MyCouponCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"cell"];
    
    [self.labelOne setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5f withColor:[UIColor colorWithHexString:@"F8AF30" alpha:1.0] withBroderOffset:nil];
    
}

- (void)initializationUI {
    @autoreleasepool {
        self.refreshControl = [[ODRefreshControl alloc] initInScrollView:_tableView];
        [_refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
        
        _tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(refreshView:)];
        _tableView.mj_footer.automaticallyHidden = NO;
        _tableView.mj_footer.hidden = YES;
    }
}

- (void)setReactiveRules {
    @weakify(self);
    [RACObserve(self, tableView.bounces) subscribeNext:^(NSNumber *bounces) {
        @strongify(self);
        if (bounces.boolValue) {
            self.navigationItem.rightBarButtonItem = nil;
        }else {
            [self setRightNavButtonWithSystemItemStyle:UIBarButtonSystemItemRefresh target:self action:@selector(reloadDataFromNet) isNeedToSet:YES];
        }
    }];
}

- (void)reloadDataFromNet {
    [self getMyCollectedCouponListWithRefreshView:nil isReloadAll:YES];
}

- (void)hiddenRefreshView:(id)refreshView {
    [refreshView endRefreshing];
}

- (void)refreshView:(id)refresh {
    BOOL isRefreshing = NO;
    BOOL isFirstRequest = NO;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    if ([refresh isKindOfClass:[ODRefreshControl class]]) {
        isRefreshing = [(ODRefreshControl *)refresh refreshing];
        isFirstRequest = YES;
    }else if ([refresh isKindOfClass:[MJRefreshAutoNormalFooter class]]) {
        isRefreshing = [(MJRefreshAutoNormalFooter *)refresh isRefreshing];
        [self pageObjectPlusOne];
    }
    if (isRefreshing) {
        [self performSelector:@selector(delayRunData:) withObject:@[refresh, @(isFirstRequest)] afterDelay:2];
        
    }
}

- (void)stopRefresh:(id)refresh {
    [refresh endRefreshing];
}

- (void)delayRunData:(NSArray *)arguments {
    [self getMyCollectedCouponListWithRefreshView:[arguments objectAtIndex:0] isReloadAll:[[arguments objectAtIndex:1] boolValue]];
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *text = @"暂无更多优惠劵";
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:15.0f],
                                 NSForegroundColorAttributeName:[UIColor colorWithHexString:@"646464"]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"poc_no_coupon_icon@3x" ofType:@"png"]];
    
    return image;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MyCouponCell *cell = [tableView dequeueReusableCellWithIdentifier:CDZKeyOfCellIdentKey forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    cell.businessLabel.adjustsFontSizeToFitWidth=YES;
    cell.dateLabel.adjustsFontSizeToFitWidth=YES;
    
    
    NSDictionary *datail=self.myCouponList[indexPath.row];
    cell.priceLabel.text=[NSString stringWithFormat:@"￥%@",datail[@"amount"]];
    cell.preferentialQuotaLabel.text=datail[@"content"];
    cell.businessLabel.text=datail[@"storeName"];
    cell.dateLabel.text=[NSString stringWithFormat:@"有效日期:%@至%@",[datail[@"startime"] stringByReplacingOccurrencesOfString:@":"withString:@"-"],[datail[@"endtime"] stringByReplacingOccurrencesOfString:@":"withString:@"-"]];
    
    NSString *overdue=datail[@"overdue"];
    if ([overdue isEqualToString:@"0"]) {
        cell.overdueImageView.image=[UIImage imageNamed:@"aboutToExpire@3x.png"];
        cell.bgImageView.image=[UIImage imageNamed:@"coupon-available@3x"];
    }
    if ([overdue isEqualToString:@"1"]) {
        cell.overdueImageView.image=[UIImage imageNamed:@"available@3x.png"];
        cell.bgImageView.image=[UIImage imageNamed:@"coupon-available@3x"];
    }
    if ([overdue isEqualToString:@"2"]) {
        cell.overdueImageView.image=[UIImage imageNamed:@"beOverdue@3x.png"];
        cell.bgImageView.image=[UIImage imageNamed:@"coupon-hasBeenUsed@3x"];
    }if ([overdue isEqualToString:@"3"]){
        cell.overdueImageView.image=[UIImage imageNamed:@"hasBeenUsed@3x.png"];
        cell.bgImageView.image=[UIImage imageNamed:@"coupon-hasBeenUsed@3x"];
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.myCouponList.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

- (IBAction)controlClick:(UIControl *)sender {
    self.status=@(sender.tag);
    [self removewAllEmbellish];
    [self getMyCollectedCouponListWithRefreshView:nil isReloadAll:YES];
    if (sender.tag==0) {
        [self.labelOne setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5f withColor:[UIColor colorWithHexString:@"F8AF30" alpha:1.0] withBroderOffset:nil];
        self.labelOne.textColor=[UIColor colorWithHexString:@"F8AF30" alpha:1.0];
    }
    if (sender.tag==1) {
        [self.labelThree setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5f withColor:[UIColor colorWithHexString:@"F8AF30" alpha:1.0] withBroderOffset:nil];
        self.labelThree.textColor=[UIColor colorWithHexString:@"F8AF30" alpha:1.0];
    }
    if (sender.tag==2) {
        [self.labelTwo setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5f withColor:[UIColor colorWithHexString:@"F8AF30" alpha:1.0] withBroderOffset:nil];
        self.labelTwo.textColor=[UIColor colorWithHexString:@"F8AF30" alpha:1.0];
    }
}

-(void)removewAllEmbellish
{
    [self.labelOne setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.0f withColor:nil withBroderOffset:nil];
    [self.labelTwo setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.0f withColor:nil withBroderOffset:nil];
    [self.labelThree setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.0f withColor:nil withBroderOffset:nil];
    self.labelOne.textColor=[UIColor colorWithHexString:@"323232" alpha:1.0];
    self.labelTwo.textColor=[UIColor colorWithHexString:@"323232" alpha:1.0];
    self.labelThree.textColor=[UIColor colorWithHexString:@"323232" alpha:1.0];
}

- (void)getMyCollectedCouponListWithRefreshView:(id)refreshView isReloadAll:(BOOL)isReloadAll {
    
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    if(!refreshView){
        [ProgressHUDHandler showHUD];
    }
    
    if (isReloadAll){
        [self pageObjectToDefault];
        [self.myCouponList removeAllObjects];
    }
    @weakify(self);
    [APIsConnection.shareConnection personalCenterAPIsGetMyCouponCollectedListWithAccessToken:self.accessToken pageNums:self.pageNums pageSizes:self.pageSizes status:self.status success:^(NSURLSessionDataTask *operation, id responseObject) {
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@---%@",message,operation.currentRequest.URL.absoluteString);
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        @strongify(self);
        if(refreshView){
            [self hiddenRefreshView:refreshView];
        }else {
            [ProgressHUDHandler dismissHUD];
        }
        self.tableView.bounces = YES;
        if(errorCode==0){
            [self.myCouponList addObjectsFromArray:[responseObject[CDZKeyOfResultKey] objectForKey:@"prefer_list"]];
            NSString *unUsed =[responseObject[CDZKeyOfResultKey] objectForKey:@"un_used"];
            NSString *hasUsed =[responseObject[CDZKeyOfResultKey] objectForKey:@"has_used"];
            NSString *hasOverdue =[responseObject[CDZKeyOfResultKey] objectForKey:@"has_overdue"];
            
            self.labelOne.text=[NSString stringWithFormat:@"未使用(%@)",unUsed];
            self.labelThree.text=[NSString stringWithFormat:@"已使用(%@)",hasUsed];
            self.labelTwo.text=[NSString stringWithFormat:@"已过期(%@)",hasOverdue];
            
            if (self.myCouponList.count==0) self.tableView.bounces = NO;
        }else {
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:nil];
            if (self.myCouponList.count!=0) self.tableView.bounces = NO;
        }
        
        if (self.totalPageSizes.integerValue==0) {
            self.totalPageSizes = [SupportingClass verifyAndConvertDataToNumber:responseObject[CDZKeyOfTotalPageSizesKey]];
        }
        NSMutableAttributedString* totalItemString = [NSMutableAttributedString new];
        [totalItemString appendAttributedString:[[NSAttributedString alloc]
                                                 initWithString:@"现有优惠劵总数："
                                                 attributes:@{NSForegroundColorAttributeName:UIColor.lightGrayColor,
                                                              NSFontAttributeName:vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 15.0f, NO)}]];
        
        [totalItemString appendAttributedString:[[NSAttributedString alloc]
                                                 initWithString:self.totalPageSizes.stringValue
                                                 attributes:@{NSForegroundColorAttributeName:CDZColorOfWeiboColor,
                                                              NSFontAttributeName:vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 16.0f, NO)}]];
//        self.totalCouponLabel.attributedText = totalItemString;
        
        self.pageNums = responseObject[CDZKeyOfPageNumsKey];
        self.pageSizes = responseObject[CDZKeyOfPageSizesKey];
        self.tableView.mj_footer.hidden = ((self.pageNums.intValue*self.pageSizes.intValue)>=self.totalPageSizes.intValue);
        
        [self.tableView reloadData];
        
        
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        @strongify(self);
        if (isReloadAll) {
            
            if (self.myCouponList.count==0) self.tableView.bounces = NO;
        }else {
            
            if (self.myCouponList.count!=0) self.tableView.bounces = NO;
        }
        [self.tableView reloadData];
        
        if (error.code==-1009) {
            [SupportingClass showAlertViewWithTitle:@"error" message:@"网络连接失败，请检查网络设置！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                if(refreshView){
                    [self hiddenRefreshView:refreshView];
                }else {
                    [ProgressHUDHandler dismissHUD];
                }
            }];
            return;
        }
        
        
        if (error.code==-1001) {
            [SupportingClass showAlertViewWithTitle:@"error" message:@"网络连接逾时，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                if(refreshView){
                    [self hiddenRefreshView:refreshView];
                }else {
                    [ProgressHUDHandler dismissHUD];
                }
            }];
            return;
        }
        
        [SupportingClass showAlertViewWithTitle:@"error" message:@"网络错误，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            if(refreshView){
                [self hiddenRefreshView:refreshView];
            }else {
                [ProgressHUDHandler dismissHUD];
            }
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
