//
//  UserMemberHistoryVC.m
//  cdzer
//
//  Created by KEns0n on 28/10/2016.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "UserMemberHistoryVC.h"
#import "UserMemberHistoryCell.h"
#import "UserMemberCenterConfig.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>

@interface UserMemberHistoryVC () <UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray <UMHDataModel *> *dataList;

@end

@implementation UserMemberHistoryVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"我的成长";
    // Do any additional setup after loading the view.
    [self componentSetting];
    [self initializationUI];
    [self setReactiveRules];
    [self.tableView setNeedsLayout];
    [self.tableView layoutIfNeeded];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getHistoryList];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self setAllContainerBorder];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self setAllContainerBorder];
}

- (void)setAllContainerBorder {
    
}

- (void)setReactiveRules {
    @autoreleasepool {
        
    }
    
}

- (void)componentSetting {
    @autoreleasepool {
        [self pageObjectToDefault];
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 100.0f;
        [self.tableView registerNib:[UINib nibWithNibName:@"UserMemberHistoryCell" bundle:nil] forCellReuseIdentifier:CDZKeyOfCellIdentKey];
        
        [self setRightNavButtonWithSystemItemStyle:UIBarButtonSystemItemRefresh target:self action:@selector(reloadData) isNeedToSet:YES];
    }
}

- (void)initializationUI {
    @autoreleasepool {
        
    }
}

- (void)reloadData {
    [self getHistoryList];
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *text = @"暂无更多成长记录！";
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:13.0f],
                                 NSForegroundColorAttributeName: [UIColor colorWithHexString:@"646464"]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"eservice_list_no_record@3x" ofType:@"png"]];
    
    return image;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserMemberHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:CDZKeyOfCellIdentKey forIndexPath:indexPath];
    UMHDataModel *dataModel = self.dataList[indexPath.row];
    dataModel.isLastRow = (self.dataList.count==indexPath.row+1);
    [cell updateUIDataWithDataModel:dataModel];
    return cell;
}

- (void)getHistoryList {
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    [ProgressHUDHandler showHUD];
    
    [APIsConnection.shareConnection personalCenterAPIsGetUserMemberHistoryListWithAccessToken:self.accessToken pageNums:self.pageNums pageSizes:self.pageSizes success:^(NSURLSessionDataTask *operation, id responseObject) {
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"详情%@-----%@",message, operation.currentRequest.URL.absoluteString);
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        [ProgressHUDHandler dismissHUD];
        if (errorCode!=0) {
            [SupportingClass showAlertViewWithTitle:@"error" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                
            }];
            return;
        }
        self.dataList = [UMHDataModel createDataModelWithSourceList:responseObject[CDZKeyOfResultKey]];
        [self.tableView reloadData];
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
