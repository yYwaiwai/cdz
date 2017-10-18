//
//  MaintenanceRecordVC.m
//  cdzer
//
//  Created by KEns0nLau on 10/11/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "MaintenanceRecordVC.h"
#import "MaintenanceRecordCell.h"
#import "MaintenanceRecordInsertEditVC.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import <MJRefresh/MJRefresh.h>
@interface MaintenanceRecordVC ()<UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, UIScrollViewDelegate>

@property (nonatomic, weak) IBOutlet UIView *autosMaintenanceInfoView;

@property (nonatomic, weak) IBOutlet UILabel *start2DriveDateTimeLabel;

@property (nonatomic, weak) IBOutlet UILabel *mileageLabel;

@property (nonatomic, weak) IBOutlet UIView *headerContentView;

@property (nonatomic, weak) IBOutlet UIView *logoImageContainer;

@property (nonatomic, weak) IBOutlet UIImageView *logoImage;

@property (nonatomic, weak) IBOutlet UILabel *selectedAutosLabel;

@property (weak, nonatomic) IBOutlet UILabel *repairReordCountLabel;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIButton *addRecordBtn;

@property (nonatomic, strong) NSMutableArray <NSDictionary *> *repairRecordList;

@property (nonatomic, strong) NSString *start2DriveDateTime;

@property (nonatomic, strong) NSString *totalMileage;

@property (nonatomic, strong) UIImage *autoDefaultImage;

@property (nonatomic, strong) UserAutosInfoDTO *userAutosData;

@property (nonatomic, strong) MaintenanceRecordInsertEditVC *recordInsertEditVC;

@end

@implementation MaintenanceRecordVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)viewDidLoad {
    self.title = @"保养记录";
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self componentSetting];
    [self initializationUI];
    [self setReactiveRules];
    [self getRepairRecordList:nil isReloadAll:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self.autosMaintenanceInfoView setViewBorderWithRectBorder:UIRectBorderTop|UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    BorderOffsetObject *borderOffset = [BorderOffsetObject new];
    borderOffset.rightUpperOffset = 8;
    borderOffset.rightBottomOffset = borderOffset.rightUpperOffset;
    [[self.autosMaintenanceInfoView viewWithTag:100] setViewBorderWithRectBorder:UIRectBorderRight borderSize:0.5 withColor:nil withBroderOffset:borderOffset];
    
    [self.logoImageContainer setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:CGRectGetHeight(self.logoImageContainer.frame)/2.0f];
    [self.logoImage setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:CGRectGetHeight(self.logoImage.frame)/2.0f];
    [self.repairReordCountLabel.superview setViewBorderWithRectBorder:UIRectBorderTop|UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    
    [self.addRecordBtn.superview setViewBorderWithRectBorder:UIRectBorderTop borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self.addRecordBtn setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:5.0f];
}

- (void)componentSetting {
    @autoreleasepool {
        self.repairRecordList = [@[] mutableCopy];
        self.userAutosData = [DBHandler.shareInstance getUserAutosDetail];
        self.autoDefaultImage = self.logoImage.image;
        [self updateHeaderStatus];
    }
}

- (void)initializationUI {
    @autoreleasepool {
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 110;
        [self.tableView registerNib:[UINib nibWithNibName:@"MaintenanceRecordCell" bundle:nil] forCellReuseIdentifier:CDZKeyOfCellIdentKey];
        self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(refreshView:)];
        self.tableView.mj_footer.automaticallyHidden = NO;
        self.tableView.mj_footer.hidden = YES;
        
        self.recordInsertEditVC = [[MaintenanceRecordInsertEditVC alloc] initWithNibName:@"MaintenanceRecordInsertEditVC" bundle:nil];
        if (!self.recordInsertEditVC.successBlock) {
            @weakify(self);
            self.recordInsertEditVC.successBlock = ^(){
                @strongify(self);
                [self getRepairRecordList:nil isReloadAll:YES];
            };
        }
    }
}

- (void)setReactiveRules {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateHeaderStatus {
    BOOL userAutosInfoExist = (self.userAutosData.brandID.integerValue>0&&
                               self.userAutosData.dealershipID.integerValue>0&&
                               self.userAutosData.seriesID.integerValue>0&&
                               self.userAutosData.modelID.integerValue>0);
    self.headerContentView.hidden = !userAutosInfoExist;
    self.selectedAutosLabel.text = @"";
    self.logoImage.image = self.autoDefaultImage;
    if (userAutosInfoExist) {
        self.selectedAutosLabel.text = [NSString stringWithFormat:@"%@ %@ %@ %@",self.userAutosData.brandName, self.userAutosData.dealershipName, self.userAutosData.seriesName, self.userAutosData.modelName];
        
        if ([self.userAutosData.brandImgURL isContainsString:@"http"]) {
            [self.logoImage setImageWithURL:[NSURL URLWithString:self.userAutosData.brandImgURL] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        }
    }
    
    self.start2DriveDateTime = self.userAutosData.registrTime;
    self.totalMileage = self.userAutosData.mileage;
    
    self.start2DriveDateTimeLabel.text = self.start2DriveDateTime;
    if (!self.start2DriveDateTime||[self.start2DriveDateTime isEqualToString:@""]) {
        self.start2DriveDateTimeLabel.text = @"--";
    }
    
    self.mileageLabel.text = self.totalMileage;
    if (!self.totalMileage||[self.totalMileage isEqualToString:@""]) {
        self.mileageLabel.text = @"0";
    }
}

- (void)stopRefresh:(MJRefreshAutoNormalFooter *)refreshView {
    [refreshView endRefreshing];
}

- (void)handleData:(MJRefreshAutoNormalFooter *)refreshView {
    [self getRepairRecordList:refreshView isReloadAll:NO];
}

- (void)refreshView:(MJRefreshAutoNormalFooter *)refreshView {
    BOOL isRefreshing = NO;
    if ([refreshView isKindOfClass:[MJRefreshAutoNormalFooter class]]) {
        isRefreshing = [(MJRefreshAutoNormalFooter *)refreshView isRefreshing];
        [self pageObjectPlusOne];
    }
    if (isRefreshing) {
        [self performSelector:@selector(handleData:) withObject:refreshView afterDelay:1.5];
    }
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *text = @"暂无更多保养数据！\n你可自行添加保养记录或者使用车队长保养服务";
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:15.0f],
                                 NSForegroundColorAttributeName: [UIColor colorWithHexString:@"646464"]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"eservice_list_no_record@3x" ofType:@"png"]];
    
    return image;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MaintenanceRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:CDZKeyOfCellIdentKey forIndexPath:indexPath];
    cell.indexPath = indexPath;
    if (!cell.editBlock) {
        @weakify(self);
        cell.editBlock = ^(NSIndexPath *indexPath){
            @strongify(self);
            [self editRecordByIndexPath:indexPath];
        };
    }
    NSDictionary *dataDetail = self.repairRecordList[indexPath.row];
    [cell updateUIDate:dataDetail];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.repairRecordList.count;
}

- (void)editRecordByIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dataDetail = self.repairRecordList[indexPath.row];
    NSArray <NSString *> *itemList = [dataDetail[@"maintain_info"] valueForKey:@"name"];
    NSString *recordID = dataDetail[@"id"];
    NSString *dateTime = dataDetail[@"add_time"];
    NSString *mileage = [[SupportingClass verifyAndConvertDataToString:dataDetail[@"mileage"]] stringByReplacingOccurrencesOfString:@"km" withString:@""];
    [self.recordInsertEditVC showEditModeViewWithRecordID:recordID selectedItemList:itemList dateTime:dateTime mileageRecord:mileage];
}

- (IBAction)showInsertView {
    [self.recordInsertEditVC showInsertModeView];
}

- (void)getRepairRecordList:(id)refreshView isReloadAll:(BOOL)isReloadAll {
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    if (isReloadAll) {
        [self pageObjectToDefault];
    }
    if (!refreshView) {
        [ProgressHUDHandler showHUD];
    }
    @weakify(self);
    [APIsConnection.shareConnection maintenanceRecordAPIsGetMaintenanceRecordListWithAccessToken:self.accessToken modelID:self.userAutosData.modelID pageNums:self.pageNums pageSizes:self.pageSizes success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        if (!refreshView) {
            [ProgressHUDHandler dismissHUD];
        }else {
            [self stopRefresh:refreshView];
        }
        if (errorCode!=0) {
            NSLog(@"%@",message);
            [self pageObjectMinusOne];
            if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:!refreshView]) {
                return;
            }
            [SupportingClass showAlertViewWithTitle:@"" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            }];
            return ;
        }
        if (isReloadAll) {
            [self.repairRecordList removeAllObjects];
        }
        
        self.pageNums = [SupportingClass verifyAndConvertDataToNumber:responseObject[CDZKeyOfPageNumsKey]];
        self.pageSizes = [SupportingClass verifyAndConvertDataToNumber:responseObject[CDZKeyOfPageSizesKey]];
        self.totalPageSizes = [SupportingClass verifyAndConvertDataToNumber:responseObject[CDZKeyOfTotalPageSizesKey]];
        self.tableView.mj_footer.hidden = ((self.pageNums.intValue*self.pageSizes.intValue)>=self.totalPageSizes.intValue);
        
        [self.repairRecordList addObjectsFromArray:responseObject[CDZKeyOfResultKey]];
        [self.tableView reloadData];
        self.repairReordCountLabel.text = @(self.repairRecordList.count).stringValue;
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        @strongify(self);
        if (!refreshView) {
            [ProgressHUDHandler dismissHUD];
        }else {
            [self pageObjectMinusOne];
            [self stopRefresh:refreshView];
        }
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    scrollView.bounces = !(scrollView.contentOffset.y<=20);
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
