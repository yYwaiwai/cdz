//
//  ReplacementOfGoodsVC.m
//  cdzer
//
//  Created by 车队长 on 16/10/9.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "ReplacementOfGoodsVC.h"
#import "FindAccessoriesWithProductCell.h"
#import <MJRefresh/MJRefresh.h>
#import <ODRefreshControl/ODRefreshControl.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface ReplacementOfGoodsVC ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIButton *allButton;

@property (weak, nonatomic) IBOutlet UIButton *scoreButton;//评分

@property (weak, nonatomic) IBOutlet UIButton *scoreButtonUP;//

@property (weak, nonatomic) IBOutlet UIButton *scoreButtonDown;

@property (weak, nonatomic) IBOutlet UIButton *salesVolumeButton;//销量

@property (weak, nonatomic) IBOutlet UIButton *salesVolumeButtonUP;

@property (weak, nonatomic) IBOutlet UIButton *salesVolumeButtonDown;


@property (weak, nonatomic) IBOutlet UIButton *priceButton;//价格

@property (weak, nonatomic) IBOutlet UIButton *priceButtonUP;

@property (weak, nonatomic) IBOutlet UIButton *priceButtonDown;

@property (weak, nonatomic) IBOutlet UIView *buttonBgView;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, assign) BOOL needReload;
/// 维修订单列表
@property (nonatomic, strong) NSMutableArray *productList;

@property (nonatomic, strong) NSNumber *sortNumber;

@property (nonatomic, assign) NSInteger indexPath;

@property (nonatomic,assign) BOOL score;
@property (nonatomic,assign) BOOL salesVolume;
@property (nonatomic,assign) BOOL price;
@end

@implementation ReplacementOfGoodsVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.sortNumber = @(0);
    if (_productList.count==0||_needReload) {
        [self getChangeProductWithRefreshView:nil isAllReload:YES];
    }
    self.score = NO;
    self.salesVolume = NO;
    self.price = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"更换商品";
    [self.buttonBgView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5f withColor:nil withBroderOffset:nil];
    [self componentSetting];
    [self setReactiveRules];

    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 110.0f;
    self.tableView.tableFooterView = [UIView new];
    UINib*nib = [UINib nibWithNibName:@"FindAccessoriesWithProductCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"FindAccessoriesWithProductCell"];
    
    
    if (self.productList.count>0) {
        NSDictionary*deatil = self.productList[self.indexPath];
        if ([[deatil objectForKey:@"no_yes"] isEqualToString:@"0"]) {
            ODRefreshControl *refreshControl = [[ODRefreshControl alloc] initInScrollView:_tableView];
            [refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
            
            _tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(refreshView:)];
            _tableView.mj_footer.automaticallyHidden = NO;
            _tableView.mj_footer.hidden = YES;
        }
    }
    
    
    
    self.allButton.tag = 1;
    self.scoreButton.tag = 5;
    self.salesVolumeButton.tag = 2;
    self.priceButton.tag = 4;

}

- (void)setReactiveRules {
    
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    [self reloadPageData];
    self.sortNumber = @(0);
    [self getChangeProductWithRefreshView:nil isAllReload:YES];
    
}

- (void)reloadPageData {
    
    [self pageObjectToDefault];
}

- (void)componentSetting {
    self.productList = [NSMutableArray array];
    [self pageObjectToDefault];
    
}

- (IBAction)buttonClick:(UIButton *)button {
    
    self.sortNumber = @(button.tag);
    [self removeAllBtnsTitleColor];
    [self getChangeProductWithRefreshView:nil isAllReload:YES];
    [button setTitleColor:[UIColor colorWithHexString:@"f8af30"] forState:UIControlStateNormal];
    if (button.tag==1||button.tag==2) {
        [self.salesVolumeButton setTitleColor:[UIColor colorWithHexString:@"f8af30"] forState:UIControlStateNormal];
        if (self.salesVolume==YES) {
            [self.salesVolumeButtonDown setBackgroundImage:[UIImage imageNamed:@"kjby-genghuanshangping-Down@3x"] forState:UIControlStateNormal];
            self.salesVolume = NO;
        }else{
            [self.salesVolumeButtonUP setBackgroundImage:[UIImage imageNamed:@"kjby-genghuanshangping-UP@3x"] forState:UIControlStateNormal];
            self.salesVolume = YES;
        }
    }
    if (button.tag==4||button.tag==3) {
        [self.priceButton setTitleColor:[UIColor colorWithHexString:@"f8af30"] forState:UIControlStateNormal];
        if (self.price==YES) {
            [self.priceButtonDown setBackgroundImage:[UIImage imageNamed:@"kjby-genghuanshangping-Down@3x"] forState:UIControlStateNormal];
            self.price = NO;
        }else{
            [self.priceButtonUP setBackgroundImage:[UIImage imageNamed:@"kjby-genghuanshangping-UP@3x"] forState:UIControlStateNormal];
            self.price = YES;
        }
    }
    if (button.tag==5||button.tag==6) {
        [self.scoreButton setTitleColor:[UIColor colorWithHexString:@"f8af30"] forState:UIControlStateNormal];
        if (self.score==YES) {
            [self.scoreButtonDown setBackgroundImage:[UIImage imageNamed:@"kjby-genghuanshangping-Down@3x"] forState:UIControlStateNormal];
            self.score = NO;
        }else{
            [self.scoreButtonUP setBackgroundImage:[UIImage imageNamed:@"kjby-genghuanshangping-UP@3x"] forState:UIControlStateNormal];
            self.score = YES;
        }
    }
    
}

- (IBAction)dismissSelfVC {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)removeAllBtnsTitleColor {
    [self.salesVolumeButtonUP setBackgroundImage:[UIImage imageNamed:@"kjby_genghuanshangping_notSelect@3x"] forState:UIControlStateNormal];
    [self.salesVolumeButtonDown setBackgroundImage:[UIImage imageNamed:@"kjby_genghuanshangping_notSelectDown@3x"] forState:UIControlStateNormal];
    [self.priceButtonUP setBackgroundImage:[UIImage imageNamed:@"kjby_genghuanshangping_notSelect@3x"] forState:UIControlStateNormal];
    [self.priceButtonDown setBackgroundImage:[UIImage imageNamed:@"kjby_genghuanshangping_notSelectDown@3x"] forState:UIControlStateNormal];
    [self.scoreButtonUP setBackgroundImage:[UIImage imageNamed:@"kjby_genghuanshangping_notSelect@3x"] forState:UIControlStateNormal];
    [self.scoreButtonDown setBackgroundImage:[UIImage imageNamed:@"kjby_genghuanshangping_notSelectDown@3x"] forState:UIControlStateNormal];
    [self.allButton setTitleColor:[UIColor colorWithHexString:@"646464"] forState:UIControlStateNormal];
    [self.scoreButton setTitleColor:[UIColor colorWithHexString:@"646464"] forState:UIControlStateNormal];
    [self.salesVolumeButton setTitleColor:[UIColor colorWithHexString:@"646464"] forState:UIControlStateNormal];
    [self.priceButton setTitleColor:[UIColor colorWithHexString:@"646464"] forState:UIControlStateNormal];
}

#pragma mark- Data Receive Handle

- (void)handleReceivedData:(id)responseObject withRefreshView:(id)refreshView isAllReload:(BOOL)isAllReload {
    if(!refreshView){
        [ProgressHUDHandler dismissHUD];
    }else{
        [self stopRefresh:refreshView];
    }
    if (!responseObject||![responseObject isKindOfClass:[NSDictionary class]]) {
        NSLog(@"Data Error!");
        return;
    }
    
    @autoreleasepool {
        if (isAllReload){
            [self.productList removeAllObjects];
        }
        
        [self.productList addObjectsFromArray:responseObject[CDZKeyOfResultKey]];
        self.totalPageSizes = @([responseObject[CDZKeyOfTotalPageSizesKey] integerValue]);
        self.pageNums = responseObject[CDZKeyOfPageNumsKey];
        self.pageSizes = responseObject[CDZKeyOfPageSizesKey];
        self.tableView.mj_footer.hidden = ((self.pageNums.intValue*self.pageSizes.intValue)>self.totalPageSizes.intValue);
        [self.tableView reloadData];
    }
}

- (void)stopRefresh:(id)refresh {
    [refresh endRefreshing];
}

- (void)delayHandleData:(id)refresh {
    
    if ([refresh isKindOfClass:[ODRefreshControl class]]) {
        if ([(ODRefreshControl *)refresh refreshing]) {
            [self getChangeProductWithRefreshView:refresh isAllReload:YES];
        }
        
    }else if ([refresh isKindOfClass:[MJRefreshAutoNormalFooter class]]){
        if ([(MJRefreshAutoNormalFooter *)refresh isRefreshing]) {
            self.pageNums = @(self.pageNums.integerValue+1);
            [self getChangeProductWithRefreshView:refresh isAllReload:NO];
        }
    }
}

#pragma -mark UITableViewDelgate
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *text = [NSString stringWithFormat:@"抱歉，暂无更多信息"];
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0f],
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (void)refreshView:(id)refresh {
    if (!self.accessToken) {
        [self stopRefresh:refresh];
        return;
    }
    
    
    [self performSelector:@selector(delayHandleData:) withObject:refresh afterDelay:1.5];
    
}

- (void)emptyDataSet:(UIScrollView *)scrollView didTapView:(UIView *)view {
    [self getChangeProductWithRefreshView:nil isAllReload:YES];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ident = @"FindAccessoriesWithProductCell";
    FindAccessoriesWithProductCell *cell = [tableView dequeueReusableCellWithIdentifier:ident forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    self.indexPath = indexPath.row;
    if (self.productList.count>0) {
        
        
        NSDictionary*deatil = self.productList[indexPath.row];
        NSString *imgURL = [deatil objectForKey:@"product_img"];
        if ([imgURL containsString:@"http"]&&imgURL.length!=0) {
            [cell.productImageView sd_setImageWithURL:[NSURL URLWithString:imgURL] placeholderImage:[ImageHandler getDefaultWhiteLogo]];
        }
        cell.productNameLabel.text = deatil[@"product_name"];
        cell.productPriceLabel.text = [NSString stringWithFormat:@"￥%0.2f", [SupportingClass verifyAndConvertDataToString:deatil[@"product_price"]].floatValue];
        
        cell.dateLabel.text = [NSString stringWithFormat:@"%@人购买|%@人评价",deatil[@"sales"],deatil[@"comment_len"]];
        cell.starLabel.text = [NSString stringWithFormat:@"%@分",deatil[@"star"]];
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _productList.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary*detail = self.productList[indexPath.row];
    [self.productItemDTO productItemReplacementBySourceData:detail];
    if (self.selectedResultBlock) {
        self.selectedResultBlock(self.productItemDTO);
    }
    [self dismissSelfVC];
}

- (void)getChangeProductWithRefreshView:(id)refreshView isAllReload:(BOOL)isAllReload {
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    if (!refreshView) {
        [ProgressHUDHandler showHUD];
    }
    if (isAllReload) {
        [self pageObjectToDefault];
    }
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObject:@(isAllReload) forKey:@"isAllReload"];
    if (refreshView) {
        [userInfo addEntriesFromDictionary:@{@"refreshView":refreshView}];
    }
    
    [[APIsConnection shareConnection] personalCenterAPIsGetChangeProductByautopartInfo:self.productItemDTO.autopartInfoID pageNums:self.pageNums pageSizes:self.pageSizes number:@(self.productItemDTO.currentSelectedCount).stringValue speci:self.carModels sort:self.sortNumber standard:self.productItemDTO.productStandard success:^(NSURLSessionDataTask *operation, id responseObject) {
        operation.userInfo = userInfo;
        [self requestResultHandle:operation responseObject:responseObject withError:nil];
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        operation.userInfo = userInfo;
        [self requestResultHandle:operation responseObject:nil withError:error];
    }];
}

- (void)requestResultHandle:(NSURLSessionDataTask *)operation responseObject:(id)responseObject withError:(NSError *)error {
    id refreshView = operation.userInfo[@"refreshView"];
    BOOL isAllReload = [operation.userInfo[@"isAllReload"] boolValue];
    
    if (error&&!responseObject) {
        NSLog(@"%@",error);
        if(!refreshView){
            [ProgressHUDHandler dismissHUD];
        }else{
            if (!isAllReload) self.pageNums = @(self.pageNums.integerValue-1);
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
        [SupportingClass showAlertViewWithTitle:@"error" message:@"连接超时，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
        }];
        
    }else if (!error&&responseObject) {
        
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@-----%@",message,operation.currentRequest.URL.absoluteString);
        
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        
        if (errorCode!=0) {
            if(!refreshView){
                [ProgressHUDHandler dismissHUD];
            }else{
                if (!isAllReload) self.pageNums = @(self.pageNums.integerValue-1);
                [self stopRefresh:refreshView];
            }
            [SupportingClass showAlertViewWithTitle:@"error" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                
            }];
            return;
        }
        
        [self handleReceivedData:responseObject withRefreshView:refreshView isAllReload:isAllReload];
        
    }
    
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
