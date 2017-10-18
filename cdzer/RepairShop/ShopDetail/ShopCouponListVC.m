//
//  ShopCouponListVC.m
//  cdzer
//
//  Created by KEns0n on 11/3/15.
//  Copyright © 2015 CDZER. All rights reserved.
//

#import "ShopCouponListVC.h"
#import "InsetsLabel.h"
#import "ShopCouponCell.h"

@interface ShopCouponListVC ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *couponList;
@end
@implementation ShopCouponListVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self componentSetting];
    [self initializationUI];
    [self setReactiveRules];
    self.title = getLocalizationString(@"coupon");
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getMyCollectedCouponList];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)componentSetting {
    self.couponList = [NSMutableArray array];
    [self setRightNavButtonWithSystemItemStyle:UIBarButtonSystemItemRefresh target:self action:@selector(reloadDataFromNet) isNeedToSet:YES];
    
}

- (void)initializationUI {
    @autoreleasepool {
        
        CGRect tableViewFrame = self.contentView.bounds;
        self.tableView = [[UITableView alloc] initWithFrame:tableViewFrame];
        _tableView.backgroundColor = [UIColor colorWithRed:0.937f green:0.937f blue:0.957f alpha:1.00f];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.scrollsToTop = YES;
        _tableView.bounces = YES;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.contentView addSubview:_tableView];
    }
}

- (void)setReactiveRules {

}



- (void)reloadDataFromNet {
    [self getMyCollectedCouponList];
}


#pragma -mark UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return (_couponList.count==0)?1:_couponList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ShopCouponCell *cell = [tableView dequeueReusableCellWithIdentifier:CDZKeyOfCellIdentKey];
    if (!cell) {
        cell = [[ShopCouponCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CDZKeyOfCellIdentKey];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    cell.remindLabel.hidden = NO;
    if (_couponList.count>0) {
        cell.remindLabel.hidden = YES;
        NSDictionary *couponDetail = _couponList[indexPath.row];
        [cell updateUIDataWithData:couponDetail];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_couponList.count==0) return CGRectGetHeight(tableView.frame);
    UIImage *image = ImageHandler.getCouponOffImage;
    return image.size.height+10.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_couponList.count>0) {
        [self collectCoupon:indexPath];
    }
}

- (void)collectCoupon:(NSIndexPath *)indexPath {
    @autoreleasepool {
        if (!self.accessToken) {
            [self handleMissingTokenAction];
            return;
        }
        NSDictionary *couponDetail = _couponList[indexPath.row];
        if ([SupportingClass verifyAndConvertDataToNumber:couponDetail[@"mark"]].boolValue) {
            return;
        }
        
        NSString *couponID = [SupportingClass verifyAndConvertDataToString:couponDetail[@"id"]];
        
        if (!self.accessToken||!couponID||[couponID isEqualToString:@""])return;
        [ProgressHUDHandler showHUD];
        @weakify(self);
        [APIsConnection.shareConnection maintenanceShopsAPIsPostUserCollectMaintenanceShopCouponWithAccessToken:self.accessToken couponID:couponID success:^(NSURLSessionDataTask *operation, id responseObject) {
            NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
            NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
            NSLog(@"%@",message);
            @strongify(self);
            
            if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
                return;
            }
            [ProgressHUDHandler dismissHUD];
            
             [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                 if(errorCode==0){
                     @strongify(self);
                     [self getMyCollectedCouponList];
                 }
             }];
            
            
        } failure:^(NSURLSessionDataTask *operation, NSError *error) {
            
            if (error.code==-1009) {
                [SupportingClass showAlertViewWithTitle:@"error" message:@"网络连接失败，请检查网络设置！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                    [ProgressHUDHandler dismissHUD];
                }];
                return;
            }
            
            
            if (error.code==-1001) {
                [SupportingClass showAlertViewWithTitle:@"error" message:@"网络连接逾时，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                    [ProgressHUDHandler dismissHUD];
                }];
                return;
            }
            
            [SupportingClass showAlertViewWithTitle:@"error" message:@"网络错误，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                [ProgressHUDHandler dismissHUD];
            }];
        }];
        
    }
}

- (void)getMyCollectedCouponList{
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    if (!self.accessToken||!self.shopID||[self.shopID isEqualToString:@""]) return;
    
    [ProgressHUDHandler showHUD];
    [self.couponList removeAllObjects];
    
    @weakify(self);
    [APIsConnection.shareConnection maintenanceShopsAPIsGetMaintenanceShopCouponAvailableListWithAccessToken:self.accessToken maintenanceShopID:_shopID success:^(NSURLSessionDataTask *operation, id responseObject) {
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        @strongify(self);
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        
        [ProgressHUDHandler dismissHUD];
        
        self.tableView.bounces = YES;
        if(errorCode==0){
            [self.couponList addObjectsFromArray:responseObject[CDZKeyOfResultKey]];
            if (self.couponList.count==0) self.tableView.bounces = NO;
        }else {
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:nil];
            if (self.couponList.count!=0) self.tableView.bounces = NO;
        }
        
        
        [self.tableView reloadData];
        
        
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        @strongify(self);
        if (self.couponList.count==0) self.tableView.bounces = NO;
        [self.tableView reloadData];
        if (error.code==-1009) {
            [SupportingClass showAlertViewWithTitle:@"error" message:@"网络连接失败，请检查网络设置！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                [ProgressHUDHandler dismissHUD];
            }];
            return;
        }
        
        
        if (error.code==-1001) {
            [SupportingClass showAlertViewWithTitle:@"error" message:@"网络连接逾时，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                [ProgressHUDHandler dismissHUD];
            }];
            return;
        }
        
        [SupportingClass showAlertViewWithTitle:@"error" message:@"网络错误，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            [ProgressHUDHandler dismissHUD];
        }];
    }];
}

- (void)handleUserLoginResult:(BOOL)isSuccess fromAlert:(BOOL)fromAlert{
    if (isSuccess) {
        NSLog(@"success reload function %d", [self executeReloadFunction]);
    }else {
        [self.navigationController popViewControllerAnimated:YES];
    }
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

