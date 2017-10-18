//
//  MyAddressesVC.m
//  cdzer
//
//  Created by 车队长 on 16/9/9.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "MyAddressesVC.h"
#import "MyAddressesCell.h"
#import "MyAddressEditWithInsertVC.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>


@interface MyAddressesVC ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIButton *submitButton;

@property (nonatomic, strong) NSArray <AddressDTO *> *dataList;

@end

@implementation MyAddressesVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getUserAddressList];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"收货地址";

    [self.submitButton setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:4.f];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 100.0f;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor=self.view.backgroundColor;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    UINib*nib = [UINib nibWithNibName:@"MyAddressesCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:CDZKeyOfCellIdentKey];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MyAddressesCell *cell = [tableView dequeueReusableCellWithIdentifier:CDZKeyOfCellIdentKey forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.editImage.hidden = self.isForSelection;
    cell.isForSelection = self.isForSelection;
    AddressDTO *dto = self.dataList[indexPath.row];
    [cell updateUIData:dto];
    
    return cell;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    AddressDTO *dto = self.dataList[indexPath.row];
    if (self.isForSelection) {
        if (self.resultBlock) {
            self.resultBlock(dto);
            [self.navigationController popViewControllerAnimated:YES];
        }
    }else {
        [self pushToAddAddressByMode:YES withAddressID:dto.addressID];
    }
}

- (void)pushToAddAddressByMode:(BOOL)isReviewEditMode withAddressID:(NSString *)addressID {
    @autoreleasepool {
        MyAddressEditWithInsertVC *vc = [MyAddressEditWithInsertVC new];
        if (isReviewEditMode&&(!addressID||[addressID isEqualToString:@""])) isReviewEditMode = NO;
        if (addressID&&isReviewEditMode) {
            vc.addressID = addressID;
        }
        vc.firstAdd = self.dataList.count==0;
        vc.isReviewEditMode = isReviewEditMode;
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)pushToAddAddress {
    [self pushToAddAddressByMode:NO withAddressID:nil];
}

#pragma -mark Address List Request functions
// 请求地址列表
- (void)getUserAddressList {
    
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    
    @weakify(self);
    [ProgressHUDHandler showHUD];
    NSLog(@"%@ accessing network request",NSStringFromClass(self.class));
    [[APIsConnection shareConnection] personalCenterAPIsGetShippingAddressListWithAccessToken:self.accessToken success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        if (errorCode==2) {
            [ProgressHUDHandler dismissHUD];
            NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
            NSLog(@"%@",message);
            [SupportingClass showAlertViewWithTitle:@"error" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                
            }];
            return;
        }
        [ProgressHUDHandler dismissHUD];
        self.dataList = [AddressDTO handleDataListToDTOList:[responseObject objectForKey:CDZKeyOfResultKey]];
        AddressDTO *selectedAddress = DBHandler.shareInstance.getUserDefaultAddress;
        if (self.dataList.count>0&&
            (!selectedAddress||![self.dataList.firstObject.addressID isEqualToString:selectedAddress.addressID])) {
            [DBHandler.shareInstance clearUserDefaultAddress];
            BOOL isDone = [DBHandler.shareInstance updateUserDefaultAddress:self.dataList.firstObject];
            NSLog(@"Was Update Address====>:: %d At %@", isDone, NSStringFromClass([self class]));
        }
        
        [self.tableView reloadData];
        if (self.selectedDTO&&self.dataList.count>0&&self.isForSelection) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.address CONTAINS[cd] %@", self.selectedDTO.address];
            NSArray *result = [self.dataList filteredArrayUsingPredicate:predicate];
            if (result.count>0) {
                AddressDTO *dto = result.lastObject;
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.dataList indexOfObject:dto] inSection:0];
                [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionTop];
            }else {
                [DBHandler.shareInstance clearUserDefaultAddress];
            }
        }else if (self.dataList.count==0) {
            [DBHandler.shareInstance clearUserDefaultAddress];
        }
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        NSLog(@"%@",error);
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
