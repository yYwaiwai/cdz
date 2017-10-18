//
//  RepairShopAnnouncementListVC.m
//  cdzer
//
//  Created by KEns0n on 16/4/13.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "RepairShopAnnouncementListVC.h"
#import "RepairShopAnnouncementDetailVC.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import <MJRefresh/MJRefresh.h>

@interface RepairShopAnnouncementListCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *announcementBanner;

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;

@property (nonatomic, weak) IBOutlet UILabel *contentLabel;

@property (nonatomic, weak) IBOutlet UILabel *dateTime;;

@property (nonatomic, weak) IBOutlet UIButton *setTopButton;

@end

@implementation RepairShopAnnouncementListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end


@interface RepairShopAnnouncementListVC () <UITableViewDataSource, UITableViewDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataList;

@end

@implementation RepairShopAnnouncementListVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (void)viewDidLoad {
    self.title = @"商家公告";
    [super viewDidLoad];
    [self componentSetting];
    [self initializationUI];
    [self setReactiveRules];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadAllData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)setReactiveRules {
    @autoreleasepool {
        
    }
    
}

- (void)componentSetting {
    @autoreleasepool {
        self.dataList = [NSMutableArray array];
        [self pageObjectToDefault];
        
        self.tableView.estimatedRowHeight = 132.5;
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        
        self.tableView.emptyDataSetSource = self;
        self.tableView.emptyDataSetDelegate = self;
        
        // A little trick for removing the cell separators
        self.tableView.tableFooterView = [UIView new];
        
        //        ODRefreshControl *refreshControl = [[ODRefreshControl alloc] initInScrollView:self.tableView];
        //        [refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
        
        self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(refreshView:)];
        self.tableView.mj_footer.automaticallyHidden = NO;
        self.tableView.mj_footer.hidden = YES;
        
        UINib *nib = [UINib nibWithNibName:@"RepairShopAnnouncementListCell" bundle:nil];
        [self.tableView registerNib:nib forCellReuseIdentifier:@"cell"];
        
        self.dataList = [NSMutableArray array];
        [self setRightNavButtonWithSystemItemStyle:UIBarButtonSystemItemRefresh target:self action:@selector(reloadAllData) isNeedToSet:YES];
    }
}

- (void)reloadAllData {
    [self getUserRepairShopAnnouncementListAndWasRelaodAll:YES];
}

#pragma mark- DZNEmptyDataSetSource & DZNEmptyDataSetDelegate code Section

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *text = @"暂无更多商家公告数据！";
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0f],
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (void)stopRefresh {
    [self.tableView.mj_footer endRefreshing];
}

- (void)pageObjectPlusOne {
    self.pageNums = @(self.pageNums.intValue+1);
}

- (void)handleData:(id)refresh {
    [self getUserRepairShopAnnouncementListAndWasRelaodAll:NO];
}

- (void)refreshView:(id)refresh {
    BOOL isRefreshing = NO;
    if ([refresh isKindOfClass:[MJRefreshAutoNormalFooter class]]) {
        isRefreshing = [(MJRefreshAutoNormalFooter *)refresh isRefreshing];
        [self pageObjectPlusOne];
    }
    if (isRefreshing) {
        [self performSelector:@selector(handleData:) withObject:refresh afterDelay:1.5];
    }
}

- (void)initializationUI {
    @autoreleasepool {
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return _dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    RepairShopAnnouncementListCell *cell = [tableView dequeueReusableCellWithIdentifier:CDZKeyOfCellIdentKey forIndexPath:indexPath];
    NSDictionary *detail = _dataList[indexPath.row];
    BOOL wasTaged = [[SupportingClass verifyAndConvertDataToNumber:detail[@"tag"]] boolValue];
    cell.setTopButton.enabled = !wasTaged;
    cell.setTopButton.backgroundColor = !wasTaged?[UIColor colorWithRed:1.000 green:0.718 blue:0.043 alpha:1.00]:CDZColorOfTureRed;

    cell.announcementBanner.image = [ImageHandler getDefaultWhiteLogo];
    NSString *bannerImgURL = detail[@"image"];
    if ([bannerImgURL isContainsString:@"http"]) {
        @weakify(cell)
        [cell.announcementBanner setImageWithURL:[NSURL URLWithString:bannerImgURL] placeholderImage:[ImageHandler getDefaultWhiteLogo] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            @strongify(cell)
            if (!image&&error) {
                image = [ImageHandler getDefaultWhiteLogo];
            }
            CGRect frame = cell.announcementBanner.frame;
            frame.size.height = roundf(CGRectGetWidth(frame)*image.size.height/image.size.width);
            cell.announcementBanner.frame = frame;
            cell.announcementBanner.image = image;
            [cell setNeedsDisplay];
            [cell setNeedsLayout];
            [cell setNeedsUpdateConstraints];
            
        } usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    
    cell.titleLabel.text = detail[@"titile"];
    cell.contentLabel.text = [NSString stringWithFormat:@"发布商家：%@", [SupportingClass verifyAndConvertDataToString:detail[@"wxs_name"]]];
    cell.dateTime.text = [NSString stringWithFormat:@"发布时间：%@", [SupportingClass verifyAndConvertDataToString:detail[@"addtime"]]];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    @autoreleasepool {
        NSDictionary *detail = _dataList[indexPath.row];
        NSString *announcementID = [SupportingClass verifyAndConvertDataToString:detail[@"id"]];
        RepairShopAnnouncementDetailVC *vc = [RepairShopAnnouncementDetailVC new];
        NSString *urlString = [kTNCURLPrefix stringByAppendingFormat:@"news/shop_notice.html?id=%@", announcementID];
        vc.URL = [NSURL URLWithString:urlString];
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)getUserRepairShopAnnouncementListAndWasRelaodAll:(BOOL)reloadAll {
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    @weakify(self);
    
    if (reloadAll) {
        [self.dataList removeAllObjects];
        [self pageObjectToDefault];
        [ProgressHUDHandler showHUD];
    }
    
    [APIsConnection.shareConnection personalCenterAPIsGetUserRepairShopAnnouncementListWithAccessToken:self.accessToken pageNums:self.pageNums pageSizes:self.pageSizes success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        if (errorCode!=0) {
            if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:reloadAll]) {return;};
            if(reloadAll){
                [ProgressHUDHandler dismissHUD];
            }else{
                [self stopRefresh];
            }
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
            return;
        }
        if(reloadAll){
            [ProgressHUDHandler dismissHUD];
        }else{
            [self stopRefresh];
        }
        self.pageNums = [SupportingClass verifyAndConvertDataToNumber:responseObject[CDZKeyOfPageNumsKey]];
        self.pageSizes = [SupportingClass verifyAndConvertDataToNumber:responseObject[CDZKeyOfPageSizesKey]];
        self.totalPageSizes = [SupportingClass verifyAndConvertDataToNumber:responseObject[CDZKeyOfTotalPageSizesKey]];
        self.tableView.mj_footer.hidden = ((self.pageNums.intValue*self.pageSizes.intValue)>=self.totalPageSizes.intValue);
        [self.dataList addObjectsFromArray:responseObject[CDZKeyOfResultKey]];
        [self.tableView reloadData];
        [self.tableView reloadData];
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        @strongify(self);
        NSLog(@"%@",error);
        if (reloadAll) {
            [ProgressHUDHandler showError];
        }else {
            [self stopRefresh];
            self.pageNums = @(self.pageNums.integerValue-1);
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
