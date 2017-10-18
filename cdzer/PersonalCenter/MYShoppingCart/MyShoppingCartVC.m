//
//  MyShoppingCartVC.m
//  cdzer
//
//  Created by 车队长 on 16/8/25.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "MyShoppingCartVC.h"
#import "MyShoppingCartCell.h"
#import "PartsDetailVC.h"
#import "QuantityControlView.h"
#import "MaintenanceExpressVC.h"
#import "CDZOrderPaymentClearanceVC.h"
#import "MyShopingCartProductComponents.h"
#import "MyShoppingCartHeadView.h"
#import "MyAddressesVC.h"
#import <ODRefreshControl/ODRefreshControl.h>
#import <MJRefresh/MJRefresh.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>

@interface MyShoppingCartVC ()<UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
/// 是否是编辑模式
@property (nonatomic, assign) BOOL isEditingMode;

@property (nonatomic, strong) NSMutableArray <MSCProductCenter *> *cartList;

@property (nonatomic, strong) NSArray <NSIndexPath *> *indexPathsForSelectedRows;



@property (nonatomic, strong) NSMutableArray *countingList;

@property (weak, nonatomic) IBOutlet UIButton *settlementButton;//结算按钮

@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@property (weak, nonatomic) IBOutlet UIButton *selectAllBtn;//全选按钮
@property (weak, nonatomic) IBOutlet UIButton *moveToCollect;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;

@property (nonatomic, strong) NSMutableSet <NSIndexPath *> *selectedList;

@property (weak, nonatomic) IBOutlet UILabel *totalLabel;
@property (weak, nonatomic) IBOutlet UILabel *littleLabel;//不含运费label

@end

@implementation MyShoppingCartVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.cartList.count==0||self.shouldReloadData) {
        [self getCartListWithRefreshView:nil isAllReload:YES];
        self.shouldReloadData = NO;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title=@"我的购物车";
    
    [self componentSetting];
    [self initializationUI];
    [self setReactiveRules];
}

- (void)componentSetting {
    self.selectedList = [NSMutableSet set];
    self.cartList = [@[] mutableCopy];
    self.countingList = [@[] mutableCopy];
    [self pageObjectToDefault];
    self.isEditingMode = NO;
    self.deleteBtn.hidden = YES;
    self.moveToCollect.hidden = YES;
    [self setRightNavButtonWithTitleOrImage:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(editor:) titleColor:[UIColor grayColor] isNeedToSet:YES];
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void)initializationUI {
    @autoreleasepool {
        ODRefreshControl *refreshControl = [[ODRefreshControl alloc] initInScrollView:self.tableView];
        [refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
        
        self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(refreshView:)];
        self.tableView.mj_footer.automaticallyHidden = NO;
        self.tableView.mj_footer.hidden = YES;
        
        self.tableView.sectionHeaderHeight = 34.0f;
        self.tableView.sectionFooterHeight = 10.0f;
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 110.0f;
        self.tableView.tableFooterView = [UIView new];
        self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
        UINib *nib = [UINib nibWithNibName:@"MyShoppingCartCell" bundle:nil];
        [self.tableView registerNib:nib forCellReuseIdentifier:@"MyShoppingCartCell"];
        [self.tableView registerClass:MyShoppingCartHeadView.class forHeaderFooterViewReuseIdentifier:@"MyShoppingCartHeaderCell"];
        [self.tableView registerClass:UITableViewHeaderFooterView.class forHeaderFooterViewReuseIdentifier:@"MyShoppingCartFooterCell"];
        
        [self.selectAllBtn addTarget:self action:@selector(checkAllAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.deleteBtn addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.settlementButton addTarget:self action:@selector(confirmCartOrder) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)setReactiveRules {
    @weakify(self);
    [RACObserve(self, indexPathsForSelectedRows) subscribeNext:^(NSArray <NSIndexPath *> *indexPathsForSelectedRows) {
        @strongify(self);
        self.priceLabel.text = @"0.00";
        if (indexPathsForSelectedRows&&indexPathsForSelectedRows.count>0) {
            __block double totalPrice = 0.00f;
            [indexPathsForSelectedRows enumerateObjectsUsingBlock:^(NSIndexPath * indexPath, NSUInteger idx, BOOL *stop) {
                MSCProductCenter *productCenter = self.cartList[indexPath.section];
                MSCProductDetail *productDetail = productCenter.productList[indexPath.row];
                totalPrice += productDetail.totalPrice;
            }];
            self.priceLabel.text = [NSString stringWithFormat:@"%.02f",totalPrice];
        }
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)editor:(UIBarButtonItem*)sender {
    
    if ([sender.title isEqualToString:@"编辑"]) {
        sender.title = @"取消";
        self.deleteBtn.hidden = NO;
        self.moveToCollect.hidden = NO;
        self.priceLabel.superview.hidden = YES;
        self.settlementButton.hidden = YES;
        self.isEditingMode = YES;
    }else{
        sender.title=@"编辑";
        self.priceLabel.superview.hidden = NO;
        self.settlementButton.hidden = NO;
        self.deleteBtn.hidden = YES;
        self.moveToCollect.hidden = YES;
        self.isEditingMode = NO;
    }
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *text = @"暂无更多购物车数据！";
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:15.0f],
                                 NSForegroundColorAttributeName: [UIColor colorWithHexString:@"646464"]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"eservice_list_no_record@3x" ofType:@"png"]];
    
    return image;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.cartList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.cartList[section].productList.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    MyShoppingCartHeadView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"MyShoppingCartHeaderCell"];
    MSCProductCenter *productCenter = self.cartList[section];
    headerView.sectionIdx = section;
    headerView.centerNameLabel.text = productCenter.centerName;
    if(!headerView.selectionBlock) {
        @weakify(self);
        headerView.selectionBlock = ^(BOOL selected, NSUInteger sectionIdx) {
            @strongify(self);
            [self updateTableViewHeaderSelection:selected headerInSection:sectionIdx];
        };
    }
    [self updateTableViewHeaderView:headerView viewForHeaderInSection:section];
    return headerView;
}

- (void)updateTableViewHeaderView:(MyShoppingCartHeadView *)headerView viewForHeaderInSection:(NSInteger)section {
    MSCProductCenter *productCenter = self.cartList[section];
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NSIndexPath * _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return (evaluatedObject.section==section);
    }];
    NSArray *result = [self.tableView.indexPathsForSelectedRows filteredArrayUsingPredicate:predicate];
    headerView.sectionSelectAllBtn.selected = (result.count==productCenter.productList.count);
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UITableViewHeaderFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"MyShoppingCartFooterCell"];
    headerView.contentView.backgroundColor = [UIColor colorWithHexString:@"f5f5f5"];
    return headerView;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ident = @"MyShoppingCartCell";
    MyShoppingCartCell *cell = [tableView dequeueReusableCellWithIdentifier:ident forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    MSCProductCenter *productCenter = self.cartList[indexPath.section];
    MSCProductDetail *productDetail = productCenter.productList[indexPath.row];
    cell.fullBottomLine = (productCenter.productList.count-1==indexPath.row);
    cell.titleLable.text = productDetail.productName;
    cell.priceLable.text = [NSString stringWithFormat:@"￥%0.02f", productDetail.retailPrice.floatValue];
    if (productDetail.productImgURL) {
        [cell.titleImageView sd_setImageWithURL:productDetail.productImgURL placeholderImage:[ImageHandler getDefaultWhiteLogo]];
    }
    NSUInteger maxValue = 30;
    if (productDetail.isGPSDevice) maxValue = 1;
    [cell.stepper setValue:productDetail.purchaseCount withMaxValue:maxValue];
    cell.stepper.identifierIndexPath = indexPath;
    [cell.stepper addTarget:self action:@selector(updateProductQuantityCount:) forControlEvents:UIControlEventValueChanged];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   //    if(!_isEditingMode){
//        if ([self checkWasGPSDeviceExsitWithIndexPath:indexPath]) {
//            if (tableView.indexPathsForSelectedRows.count>1) {
//                [tableView reloadData];
//                [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
//                [SupportingClass showToast:@"GPS设备只能单独提交"];
//            }
//        }else {
//            [self.tableView.indexPathsForSelectedRows enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//                NSIndexPath *subIndexPath = (NSIndexPath *)obj;
//                NSDictionary *data = self.cartList[subIndexPath.row];
//                NSString *subProductType = data[@"productType"];
//                NSString *subProductName = data[@"productName"];
//                if ([subProductName isContainsString:@"GPS"]&&[subProductType isContainsString:@"官方商品"]) {
//                    [tableView deselectRowAtIndexPath:subIndexPath animated:NO];
//                    [tableView reloadRowsAtIndexPaths:@[subIndexPath] withRowAnimation:UITableViewRowAnimationNone];
//                }
//            }];
//        }
//    
    //    }
    
    self.indexPathsForSelectedRows = tableView.indexPathsForSelectedRows;
    [self.selectedList addObjectsFromArray:tableView.indexPathsForSelectedRows];
    __block NSUInteger count = 0;
    [self.cartList enumerateObjectsUsingBlock:^(MSCProductCenter * _Nonnull center, NSUInteger idx, BOOL * _Nonnull stop) {
        count+= center.productList.count;
    }];
    MyShoppingCartHeadView *headerView = (MyShoppingCartHeadView *)[tableView headerViewForSection:indexPath.section];
    [self updateTableViewHeaderView:headerView viewForHeaderInSection:indexPath.section];
    [self updateButtonsToMatchTableState];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    [self.selectedList removeObject:indexPath];
    self.indexPathsForSelectedRows = tableView.indexPathsForSelectedRows;
    __block NSUInteger count = 0;
    [self.cartList enumerateObjectsUsingBlock:^(MSCProductCenter * _Nonnull center, NSUInteger idx, BOOL * _Nonnull stop) {
        count+= center.productList.count;
    }];
    MyShoppingCartHeadView *headerView = (MyShoppingCartHeadView *)[tableView headerViewForSection:indexPath.section];
    [self updateTableViewHeaderView:headerView viewForHeaderInSection:indexPath.section];
    [self updateButtonsToMatchTableState];
}

- (void)updateTableViewHeaderSelection:(BOOL)selected headerInSection:(NSInteger)section {
    MSCProductCenter *productCenter = self.cartList[section];
    @weakify(self);
    [productCenter.productList enumerateObjectsUsingBlock:^(MSCProductDetail * _Nonnull productDetail, NSUInteger row, BOOL * _Nonnull stop) {
        @strongify(self);
        if (selected) {
            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section] animated:NO scrollPosition:UITableViewScrollPositionNone];
        }else {
            [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section] animated:NO];
        }
    }];
    self.indexPathsForSelectedRows = self.tableView.indexPathsForSelectedRows;
    [self updateButtonsToMatchTableState];
}

- (void)updateProductQuantityCount:(QuantityControlView *)countView {
    @autoreleasepool {
        NSIndexPath *indexPath = countView.identifierIndexPath;
        if (![self.tableView.indexPathsForSelectedRows containsObject:indexPath]) {
            [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            self.indexPathsForSelectedRows = self.tableView.indexPathsForSelectedRows;
        }
        MSCProductCenter *productCenter = self.cartList[indexPath.section];
        MSCProductDetail *productDetail = productCenter.productList[indexPath.row];
        productDetail.purchaseCount = countView.value;
        [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
        
    }
}

- (void)checkAllAction:(UIButton *)sender {
    
    for (int section=0; section<self.cartList.count; section++) {
        MSCProductCenter *productCenter = self.cartList[section];
        for (int row=0; row<productCenter.productList.count; row++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            if (sender.selected) {
                [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
            }else{
                [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
//                if ([self checkWasGPSDeviceExsitWithIndexPath:indexPath]&&!self.isEditingMode) {
//                    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
//                    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
//                    [SupportingClass showToast:@"GPS设备只能单独选择提交"];
//                }
            }
            
        }
        MyShoppingCartHeadView *headerView = (MyShoppingCartHeadView *)[self.tableView headerViewForSection:section];
        [self updateTableViewHeaderView:headerView viewForHeaderInSection:section];
    }
    sender.selected = !sender.selected;
    self.indexPathsForSelectedRows = self.tableView.indexPathsForSelectedRows;
    [self updateButtonsToMatchTableState];
}

- (void)updateButtonsToMatchTableState {
    if (!self.isEditingMode) {
        // Not in editing mode.
        
        // Show the edit button, but disable the edit button if there's nothing to edit.
        if (self.cartList.count > 0)
        {
            self.navigationItem.rightBarButtonItem.enabled = YES;
            self.navigationItem.rightBarButtonItem.tintColor = CDZColorOfBlack;
        }
        else
        {
            self.navigationItem.rightBarButtonItem.enabled = NO;
        }
        
    }
    [self updateDeleteButtonTitle];
}

- (void)updateDeleteButtonTitle {
    // Update the delete button's title, based on how many items are selected
    NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
    
    __block NSUInteger count = 0;
    [self.cartList enumerateObjectsUsingBlock:^(MSCProductCenter * _Nonnull center, NSUInteger idx, BOOL * _Nonnull stop) {
        count+= center.productList.count;
    }];
    BOOL allItemsAreSelected = (selectedRows.count==count&&self.cartList.count!=0);
    BOOL noItemsAreSelected = selectedRows.count==0;
    NSString *titleString = nil;
    if (noItemsAreSelected) {
        titleString = getLocalizationString(@"delete");
    }else {
        NSString *titleFormatString = [getLocalizationString(@"delete") stringByAppendingString:@" (%d)"];
        titleString = allItemsAreSelected?getLocalizationString(@"delete_all"):[NSString stringWithFormat:titleFormatString, selectedRows.count];
    }
    
    
    self.deleteBtn.backgroundColor = noItemsAreSelected?CDZColorOfLightGray:CDZColorOfDefaultColor;
    self.deleteBtn.enabled = !noItemsAreSelected;
    [self.deleteBtn setTitle:titleString forState:UIControlStateNormal];
    
    self.settlementButton.enabled = !noItemsAreSelected;
    self.settlementButton.backgroundColor = noItemsAreSelected?CDZColorOfLightGray:CDZColorOfDefaultColor;
    self.selectAllBtn.selected = allItemsAreSelected;
    
}

- (void)refreshView:(id)refresh {
    if (!self.accessToken) {
        [self stopRefresh:refresh];
        return;
    }
    [self performSelector:@selector(delayHandleData:) withObject:refresh afterDelay:1.5];
}

- (void)stopRefresh:(id)refresh {
    [refresh endRefreshing];
}

- (void)delayHandleData:(id)refresh {
    
    if ([refresh isKindOfClass:[ODRefreshControl class]]) {
        if ([(ODRefreshControl *)refresh refreshing]) {
            [self getCartListWithRefreshView:refresh isAllReload:YES];
        }
        
    }else if ([refresh isKindOfClass:[MJRefreshAutoNormalFooter class]]){
        if ([(MJRefreshAutoNormalFooter *)refresh isRefreshing]) {
            self.pageNums = @(self.pageNums.integerValue+1);
            [self getCartListWithRefreshView:refresh isAllReload:NO];
        }
    }
}

- (void)deleteAction:(UIButton*)sender {
    [SupportingClass showAlertViewWithTitle:@"" message:@"您确定要删除所选的商品吗？" isShowImmediate:YES cancelButtonTitle:@"cancel" otherButtonTitles:@"ok" clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
        if (btnIdx.integerValue>0) {
            [self deleteCartOrder];
        }
    }];
}

- (void)pushPartItemDetailViewWithItemDetail:(id)detail {
    if (!detail||![detail isKindOfClass:[NSDictionary class]]) {
        return;
    }
    @autoreleasepool {
        PartsDetailVC *vc = [PartsDetailVC new];
        vc.itemDetail = detail;
        vc.hiddenExpressBtnNCartAddBtnNGPSBtn = YES;
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)selectedProductMoveCollection {
    @weakify(self);
    [SupportingClass showAlertViewWithTitle:nil message:@"是否将以选的商品已到收藏？" isShowImmediate:YES cancelButtonTitle:@"cancel" otherButtonTitles:@"ok" clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
        @strongify(self);
        if (btnIdx.integerValue>0) {
            [self postCartListMoveCollection];
        }
    }];
}

#pragma mark- API Access Code Section
/* 购物车列表 */
- (void)getCartListWithRefreshView:(id)refreshView isAllReload:(BOOL)isAllReload {
    
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    if (!refreshView) {
        [ProgressHUDHandler showHUDWithTitle:getLocalizationString(@"loading") onView:nil];
    }
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObject:@(isAllReload) forKey:@"isAllReload"];
    if (refreshView) {
        [userInfo addEntriesFromDictionary:@{@"refreshView":refreshView}];
    }
    
    [[APIsConnection shareConnection] personalCenterAPIsGetCartListWithAccessToken:self.accessToken success:^(NSURLSessionDataTask *operation, id responseObject) {
        operation.userInfo = userInfo;
        [self requestResultHandle:operation responseObject:responseObject withError:nil];
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        operation.userInfo = userInfo;
        [self requestResultHandle:operation responseObject:nil withError:error];
    }];
}
/* 删除购物车的商品 */
- (void)deleteCartOrder {
    
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    [ProgressHUDHandler showHUD];
    NSMutableArray *productIDList = [@[] mutableCopy];
    [self.tableView.indexPathsForSelectedRows enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull indexPath, NSUInteger idx, BOOL * _Nonnull stop) {
        MSCProductDetail *productDetail = self.cartList[indexPath.section].productList[indexPath.row];
        [productIDList addObject:productDetail.productID];
    }];
    [[APIsConnection shareConnection] personalCenterAPIsPostDeleteProductFormTheCartWithAccessToken:self.accessToken productIDList:productIDList success:^(NSURLSessionDataTask *operation, id responseObject) {
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"4%@",message);
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        if(errorCode!=0){
            [SupportingClass showAlertViewWithTitle:@"error" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                
            }];
            return;
        }
        [self getCartListWithRefreshView:nil isAllReload:YES];
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        [self requestResultHandle:operation responseObject:nil withError:error];
    }];
}
/* 提交订单 */
- (void)confirmCartOrder {
    
    AddressDTO *selectedAddressDTO = [DBHandler.shareInstance getUserDefaultAddress];
    if (!selectedAddressDTO.addressID||[selectedAddressDTO.addressID isEqualToString:@""]) {
        @weakify(self);
        [SupportingClass showAlertViewWithTitle:@"" message:@"请添加收货信息！现在是否前往添加？" isShowImmediate:YES cancelButtonTitle:@"cancel" otherButtonTitles:@"ok"  clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            if (btnIdx.integerValue>0) {
                @strongify(self);
                MyAddressesVC *vc = [MyAddressesVC new];
                [self setDefaultNavBackButtonWithoutTitle];
                [self.navigationController pushViewController:vc animated:YES];
            }
        }];
        return;
    }
    @autoreleasepool {
        NSMutableArray *productslist = [@[] mutableCopy];
        NSMutableArray *countingList = [@[] mutableCopy];
        [self.tableView.indexPathsForSelectedRows enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull indexPath, NSUInteger idx, BOOL * _Nonnull stop) {
            MSCProductDetail *productDetail = self.cartList[indexPath.section].productList[indexPath.row];
            [productslist addObject:productDetail.productID];
            [countingList addObject:@(productDetail.purchaseCount)];
        }];
        
        CDZOrderPaymentClearanceVC *vc = [CDZOrderPaymentClearanceVC new];
        vc.orderClearanceType = CDZOrderPaymentClearanceTypeOfRegularParts;
        vc.productList = productslist;
        vc.productCountList = countingList;
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }
}
/* 配件详情 */
- (void)getPartsDetailWithPartsID:(NSString *)partsID {
    [ProgressHUDHandler showHUDWithTitle:getLocalizationString(@"loading") onView:nil];
    [[APIsConnection shareConnection] theSelfMaintenanceAPIsGetItemDetailWithWithAccessToken:self.accessToken productID:partsID success:^(NSURLSessionDataTask *operation, id responseObject) {
        
        
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"2%@",message);
        if(errorCode!=0){
            [ProgressHUDHandler dismissHUD];
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                
            }];
            return;
        }
        [ProgressHUDHandler dismissHUDWithCompletion:^{
            [self pushPartItemDetailViewWithItemDetail:responseObject[CDZKeyOfResultKey]];
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
//购物车移至收藏
- (void)postCartListMoveCollection {
    
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    [ProgressHUDHandler showHUD];
    
    NSMutableArray *productIDList = [@[] mutableCopy];
    [self.tableView.indexPathsForSelectedRows enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull indexPath, NSUInteger idx, BOOL * _Nonnull stop) {
        MSCProductDetail *productDetail = self.cartList[indexPath.section].productList[indexPath.row];
        [productIDList addObject:productDetail.productID];
    }];
    if (productIDList.count==0) {
        [ProgressHUDHandler dismissHUD];
        [SupportingClass showAlertViewWithTitle:@"" message:@"请选择商品" isShowImmediate:YES cancelButtonTitle:nil otherButtonTitles:nil clickedButtonAtIndexWithBlock:nil];
        return;
    }
    [[APIsConnection shareConnection] personalCenterAPIsPostCartListMoveCollectionWithAccessToken:self.accessToken productIDList:productIDList success:^(NSURLSessionDataTask *operation, id responseObject) {
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"4%@",message);
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        if(errorCode!=0){
            [SupportingClass showAlertViewWithTitle:@"error" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                
            }];
            [ProgressHUDHandler dismissHUD];
            return;
        }
        [self getCartListWithRefreshView:nil isAllReload:YES];
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
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
            [self stopRefresh:refreshView];
            if (!isAllReload) self.pageNums = @(self.pageNums.integerValue-1);
        }
        
        @weakify(self);
        if (error.code==-1009) {
            [SupportingClass showAlertViewWithTitle:@"error" message:@"网络连接失败，请检查网络设置！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                @strongify(self);
                [self.cartList removeAllObjects];
                [self.tableView reloadData];
            }];
            return;
        }
        
        
        if (error.code==-1001) {
            [SupportingClass showAlertViewWithTitle:@"error" message:@"网络连接逾时，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                @strongify(self);
                [self.cartList removeAllObjects];
                [self.tableView reloadData];
            }];
            return;
        }
        
        [SupportingClass showAlertViewWithTitle:@"error" message:@"网络错误，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            @strongify(self);
            [self.cartList removeAllObjects];
            [self.tableView reloadData];
        }];
    }else if (!error&&responseObject) {
        
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"1%@",message);
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:!refreshView]) {
            return;
        }
        if(!refreshView){
            [ProgressHUDHandler dismissHUD];
        }else{
            [self stopRefresh:refreshView];
        }
        if(errorCode!=0){
            if (!isAllReload) self.pageNums = @(self.pageNums.integerValue-1);
            
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                
            }];
            return;
        }
        self.totalPageSizes = [SupportingClass verifyAndConvertDataToNumber:responseObject[CDZKeyOfTotalPageSizesKey]];
        self.pageNums = responseObject[CDZKeyOfPageNumsKey];
        self.pageSizes = responseObject[CDZKeyOfPageSizesKey];
        self.tableView.mj_footer.hidden = ((self.pageNums.intValue*self.pageSizes.intValue)>=self.totalPageSizes.intValue);
        
        if (isAllReload) [self.cartList removeAllObjects];
        NSMutableArray <MSCProductCenter *> *cartDataList = [MSCProductCenter createDataObjectListWithCenterSourceDataList:responseObject[CDZKeyOfResultKey]];
        [self.cartList addObjectsFromArray:cartDataList];
        [self.tableView reloadData];
        [self updateButtonsToMatchTableState];
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
