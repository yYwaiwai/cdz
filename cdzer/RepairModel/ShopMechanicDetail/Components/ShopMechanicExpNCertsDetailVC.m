//
//  ShopMechanicExpNCertsDetailVC.m
//  cdzer
//
//  Created by KEns0n on 19/11/2016.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "ShopMechanicExpNCertsDetailVC.h"
#import "ShopMechanicENCDCell.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import <ODRefreshControl/ODRefreshControl.h>
#import <MJRefresh/MJRefresh.h>

@interface ShopMechanicExpNCertsDetailVC ()<UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray <NSDictionary *> *dataList;

@end

@implementation ShopMechanicExpNCertsDetailVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"培训及荣誉";
    // Do any additional setup after loading the view from its nib.
    [self componentSetting];
    [self initializationUI];
    [self setReactiveRules];
    self.loginAfterShouldPopToRoot = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
}

- (void)handleNavBackBtnPopOtherAction {
    @autoreleasepool {
        
    }
}

- (void)componentSetting {
    @autoreleasepool {
        self.dataList = [@[] mutableCopy];
        [self pageObjectToDefault];
        
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 100;
        [self.tableView registerNib:[UINib nibWithNibName:@"ShopMechanicENCDCell" bundle:nil] forCellReuseIdentifier:CDZKeyOfCellIdentKey];
    
        
        ODRefreshControl *refreshControl = [[ODRefreshControl alloc] initInScrollView:_tableView];
        [refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
        self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(refreshView:)];
        self.tableView.mj_footer.automaticallyHidden = NO;
        self.tableView.mj_footer.hidden = YES;
        
        [self getMechanicExpNCertsListWithRefreshView:nil isAllReload:YES];
    }
}

- (void)initializationUI {
    @autoreleasepool {
        
    }
}

- (void)setReactiveRules {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)stopRefresh:(id)refresh {
    [refresh endRefreshing];
}

- (void)delayHandleData:(id)refresh {
    
    if ([refresh isKindOfClass:[ODRefreshControl class]]) {
        if ([(ODRefreshControl *)refresh refreshing]) {
            [self getMechanicExpNCertsListWithRefreshView:refresh isAllReload:YES];
        }
        
    }else if ([refresh isKindOfClass:[MJRefreshAutoNormalFooter class]]){
        if ([(MJRefreshAutoNormalFooter *)refresh isRefreshing]) {
            [self pageObjectPlusOne];
            [self getMechanicExpNCertsListWithRefreshView:refresh isAllReload:NO];
        }
    }
}

- (void)refreshView:(id)refresh {
    if (!self.accessToken) {
        [self stopRefresh:refresh];
        return;
    }
    
    
    [self performSelector:@selector(delayHandleData:) withObject:refresh afterDelay:1.5];
    
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *text = @"暂无更多技师经验信息";
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:15.0f],
                                 NSForegroundColorAttributeName: [UIColor colorWithHexString:@"646464"]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"eservice_list_no_record@3x" ofType:@"png"]];
    
    return image;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section  {
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ShopMechanicENCDCell *cell = [tableView dequeueReusableCellWithIdentifier:CDZKeyOfCellIdentKey forIndexPath:indexPath];
    [cell updateUIData:self.dataList[indexPath.row]];
    return cell;
}

- (void)getMechanicExpNCertsListWithRefreshView:(id)refreshView isAllReload:(BOOL)isAllReload {
    
    if(!refreshView){
        [ProgressHUDHandler showHUD];
    }
    @weakify(self);
    [APIsConnection.shareConnection mechanicCenterAPIsGetMechanicExpNCertsListWithMechanicID:self.mechanicID success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@-----%@", NSStringFromClass(self.class), operation.currentRequest);
        
        
        if(!refreshView){
            [ProgressHUDHandler dismissHUD];
        }else{
            [self stopRefresh:refreshView];
        }
        if (errorCode!=0) {
            if ([refreshView isKindOfClass:MJRefreshFooter.class]) {
                [self pageObjectMinusOne];
            }
            [SupportingClass showAlertViewWithTitle:@"error" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                
            }];
            return;
        }
        
        if (isAllReload){
            [self.dataList removeAllObjects];
        }
        
        [self.dataList addObjectsFromArray:responseObject[CDZKeyOfResultKey]];
        self.totalPageSizes = @([responseObject[CDZKeyOfTotalPageSizesKey] integerValue]);
        self.pageNums = responseObject[CDZKeyOfPageNumsKey];
        self.pageSizes = responseObject[CDZKeyOfPageSizesKey];
        self.tableView.mj_footer.hidden = ((self.pageNums.intValue*self.pageSizes.intValue)>self.totalPageSizes.intValue);
        [self.tableView reloadData];
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        NSLog(@"%@",error);
        @strongify(self);
        if (isAllReload) {
            [self.dataList removeAllObjects];
            [self.tableView reloadData];
        }
        if(!refreshView){
            [ProgressHUDHandler dismissHUD];
        }else{
            if ([refreshView isKindOfClass:MJRefreshFooter.class]) {
                [self pageObjectMinusOne];
            }
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
