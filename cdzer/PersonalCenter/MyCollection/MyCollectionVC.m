//
//  MyCollectionVC.m
//  cdzer
//
//  Created by 车队长 on 16/8/18.
//  Copyright © 2016年 CDZER. All rights reserved.
//
#define defaultBtnTags 300
#define vStartSpace vAdjustByScreenRatio(10.0f)
#import "MyCollectionVC.h"
#import "CommodityCell.h"
#import "ShopCell.h"
#import "InsetsLabel.h"
#import "PartsDetailVC.h"
#import "ShopNServiceDetailVC.h"
#import "UserLocationHandler.h"
#import "SMSLResultDTO.h"
#import "ShopMechanicSearchListCell.h"
#import "ShopMechanicDetailVC.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import <ODRefreshControl/ODRefreshControl.h>
#import <MJRefresh/MJRefresh.h>
#import <SDWebImage/UIImageView+WebCache.h>


@interface MyCollectionVC ()<UITableViewDataSource,UITableViewDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property (weak, nonatomic) IBOutlet UIButton *commodityButton;

@property (weak, nonatomic) IBOutlet UIButton *shopButton;

@property (weak, nonatomic) IBOutlet UIButton *mechanicButton;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (copy, nonatomic) APIsConnectionFailureBlock failure;

/// 数据表格
@property (nonatomic, strong) NSMutableArray *dataList;

@property (nonatomic, assign) NSUInteger currentCollectionType;
/// 删除按钮
@property (nonatomic, weak) IBOutlet UIButton *deleteBtn;

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@end

@implementation MyCollectionVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (_dataList.count == 0) {
        [self getCollectedList:nil];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"我的收藏";
    [self updateUserLocation];
    [self.commodityButton setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5f withColor:CDZColorOfOrangeColor withBroderOffset:nil];
    
    self.editButtonItem.title = getLocalizationString(@"edit");
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self componentSetting];
    [self initializationUI];
    [self updateButtonsToMatchTableState];
    
}

- (void)componentSetting {
    @autoreleasepool {
        
        self.failure = ^(NSURLSessionDataTask *operation, NSError *error) {
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
            
        };
        
        self.currentCollectionType = 0;
        
        self.dataList = [@[] mutableCopy];
        
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 100.0f;
        self.tableView.tableFooterView = [UIView new];
        self.tableView.showsVerticalScrollIndicator = NO;
        UINib *nib = [UINib nibWithNibName:@"CommodityCell" bundle:nil];
        [self.tableView registerNib:nib forCellReuseIdentifier:@"CommodityCell"];
        UINib *shopNib = [UINib nibWithNibName:@"ShopCell" bundle:nil];
        [self.tableView registerNib:shopNib forCellReuseIdentifier:@"ShopCell"];
        UINib *mechanicNib = [UINib nibWithNibName:@"ShopMechanicSearchListCell" bundle:nil];
        [self.tableView registerNib:mechanicNib forCellReuseIdentifier:@"ShopMechanicSearchListCell"];
        
        ODRefreshControl *refreshControl = [[ODRefreshControl alloc] initInScrollView:_tableView];
        [refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
        
        _tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(refreshView:)];
        _tableView.mj_footer.automaticallyHidden = NO;
        _tableView.mj_footer.hidden = YES;
        
    }
    
}

- (void)initializationUI {
    
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    UIColor *selectedColor = [self.commodityButton titleColorForState:UIControlStateSelected];
    [self.commodityButton setViewBorderWithRectBorder:UIRectBorderBottom
                                           borderSize:0.5f
                                            withColor:(self.commodityButton.selected?selectedColor:nil)
                                     withBroderOffset:nil];
    [self.shopButton setViewBorderWithRectBorder:UIRectBorderBottom
                                      borderSize:0.5f
                                       withColor:(self.shopButton.selected?selectedColor:nil)
                                withBroderOffset:nil];
    [self.mechanicButton setViewBorderWithRectBorder:UIRectBorderBottom
                                          borderSize:0.5f
                                           withColor:(self.mechanicButton.selected?selectedColor:nil)
                                    withBroderOffset:nil];
    
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *text = @"暂无更多收藏信息";
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:15.0f],
                                 NSForegroundColorAttributeName: [UIColor colorWithHexString:@"646464"]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"eservice_list_no_record@3x" ofType:@"png"]];
    
    return image;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *theCell = nil;
    if (self.currentCollectionType==0) {
        static NSString *ident = @"CommodityCell";
        CommodityCell *cell = [tableView dequeueReusableCellWithIdentifier:ident forIndexPath:indexPath];
        NSDictionary *detail = _dataList[indexPath.row];
        NSString *nameString = [SupportingClass verifyAndConvertDataToString:detail[@"goods_name"]];
        NSNumber *priceNum = [SupportingClass verifyAndConvertDataToNumber:detail[@"goods_price"]];
        NSNumber *favoriteCount = [SupportingClass verifyAndConvertDataToNumber:detail[@"favorite_count"]];
        
        cell.priceLabel.text=[NSString stringWithFormat:@"￥%@",priceNum];
        cell.countText.text=nameString;
        cell.favoriteCount.text=[NSString stringWithFormat:@"%@",favoriteCount];
        cell.logoImage.image = [ImageHandler getDefaultWhiteLogo];
        NSString *vehicleImgURL = detail[@"goods_img"];
        if ([vehicleImgURL isContainsString:@"http"]) {
            [cell.logoImage setImageWithURL:[NSURL URLWithString:vehicleImgURL] placeholderImage:[ImageHandler getDefaultWhiteLogo] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        }
        theCell = cell;
    }else if (self.currentCollectionType==1) {
        static NSString *ident = @"ShopCell";
        ShopCell *cell = [tableView dequeueReusableCellWithIdentifier:ident forIndexPath:indexPath];
        NSDictionary *detail = _dataList[indexPath.row];
        [cell updateUIData:detail];
        theCell = cell;
    }else if (self.currentCollectionType==2) {
        static NSString *ident = @"ShopMechanicSearchListCell";
        ShopMechanicSearchListCell *cell = [tableView dequeueReusableCellWithIdentifier:ident forIndexPath:indexPath];
        cell.showSelection=NO;
        SMSLResultDTO *detail = _dataList[indexPath.row];
        [cell updateUIData:detail];
        theCell = cell;
    }
    theCell.selectionStyle = tableView.editing?UITableViewCellSelectionStyleDefault:UITableViewCellSelectionStyleNone;
    return theCell;
   
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (IBAction)updateCollcetionType:(UIButton *)sender {
    self.commodityButton.selected = NO;
    self.shopButton.selected = NO;
    self.mechanicButton.selected = NO;
    [self.commodityButton setViewBorderWithRectBorder:UIRectBorderBottom
                                           borderSize:0.5f
                                            withColor:nil
                                     withBroderOffset:nil];
    [self.shopButton setViewBorderWithRectBorder:UIRectBorderBottom
                                      borderSize:0.5f
                                       withColor:nil
                                withBroderOffset:nil];
    [self.mechanicButton setViewBorderWithRectBorder:UIRectBorderBottom
                                          borderSize:0.5f
                                           withColor:nil
                                    withBroderOffset:nil];
    
    
    
    [sender setViewBorderWithRectBorder:UIRectBorderBottom
                             borderSize:0.5f
                              withColor:[sender titleColorForState:UIControlStateSelected]
                       withBroderOffset:nil];
    sender.enabled = YES;
    self.currentCollectionType = sender.tag-defaultBtnTags;
    
    [self pageObjectToDefault];
    [self getCollectedList:nil];
}

- (void)updateUserLocation {
    @weakify(self);
    [UserLocationHandler.shareInstance startUserLocationServiceWithBlock:^(BMKUserLocation *userLocation, NSError *error) {
        @strongify(self);
        if(!error) {
            [UserLocationHandler.shareInstance stopUserLocationService];
            self.coordinate = userLocation.location.coordinate;
        }else {
            self.coordinate = CLLocationCoordinate2DMake(28.224610, 112.893959);
        }
    }];
}

#pragma -mark Pirvate Function Section

- (void)isNeedHiddenPageUpdateView {
    NSUInteger totalPage = self.totalPageSizes.integerValue;
    NSUInteger cpageSizes = self.pageSizes.integerValue;
    NSUInteger cpageNums = self.pageNums.integerValue;
    BOOL isHidden = (cpageNums*cpageSizes>=totalPage);
    _tableView.mj_footer.hidden = isHidden;
}

// 处理资料更新
- (void)handleData:(id)refresh {
    [_tableView reloadData];
    if (refresh) {
        [refresh endRefreshing];
    }
    
    self.commodityButton.enabled = YES;
    self.commodityButton.selected = (self.currentCollectionType==0);
    self.shopButton.enabled = YES;
    self.shopButton.selected = (self.currentCollectionType==1);
    self.mechanicButton.enabled = YES;
    self.mechanicButton.selected = (self.currentCollectionType==2);
    
    [self updateButtonsToMatchTableState];
    [self isNeedHiddenPageUpdateView];
}

- (void)refreshView:(id)refresh {
    BOOL isRefreshing = NO;
    self.commodityButton.enabled = NO;
    self.commodityButton.selected = NO;
    self.shopButton.enabled = NO;
    self.shopButton.selected = NO;
    self.mechanicButton.enabled = NO;
    self.mechanicButton.selected = NO;

    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    if ([refresh isKindOfClass:[ODRefreshControl class]]) {
        isRefreshing = [(ODRefreshControl *)refresh refreshing];
        [self pageObjectToDefault];
    }else if ([refresh isKindOfClass:[MJRefreshAutoNormalFooter class]]) {
        isRefreshing = [(MJRefreshAutoNormalFooter *)refresh isRefreshing];
        [self pageObjectPlusOne];
    }
    if (isRefreshing) {
        [self performSelector:@selector(getCollectedList:) withObject:refresh afterDelay:1];
        
    }
}

- (void)checkAllAction:(UIButton *)sender {
    for (int i = 0; i<[_dataList count]; i++) {
        if (sender.selected) {
            [_tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:NO];
        }else{
            [_tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
    }
    
    [self updateButtonsToMatchTableState];
}

- (IBAction)deleteAction:(id)sender {
    if (!self.tableView.editing)return;
    
    // Open a dialog with just an OK button.
    NSString *actionTitle;
    NSString *itemName = getLocalizationString(@"product");
     if (self.currentCollectionType==1) {
        itemName = getLocalizationString(@"store");
    }else if (self.currentCollectionType==2) {
        itemName = @"技师";
    }
    
    if (([[self.tableView indexPathsForSelectedRows] count] == [_dataList count] || [[self.tableView indexPathsForSelectedRows] count] == 0)) {
        actionTitle = [NSString stringWithFormat:getLocalizationString(@"delete_all_warning"),itemName];
    } else {
        actionTitle = [NSString stringWithFormat:getLocalizationString(@"delete_warning"),itemName];
    }
    
    NSString *cancelTitle = getLocalizationString(@"cancel");
    NSString *okTitle = getLocalizationString(@"ok");
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:actionTitle
                                                             delegate:nil
                                                    cancelButtonTitle:cancelTitle
                                               destructiveButtonTitle:okTitle
                                                    otherButtonTitles:nil];
    
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    // Show from our table view (pops up in the middle of the table).
    [actionSheet showInView:self.view];
    [[actionSheet.rac_buttonClickedSignal filter:^BOOL(NSNumber *btnIdx) {
        // The user tapped one of the OK/Cancel buttons.
        return (btnIdx.integerValue == 0);
    }] subscribeNext:^(NSNumber *isConfirm) {
        if (isConfirm) {
            [self deleteCollectedList];
        }
    }];
}

- (void)executeDetele {
    NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
    BOOL deleteSpecificRows = selectedRows.count > 0;
    if (deleteSpecificRows) {
        // Build an NSIndexSet of all the objects to delete, so they can all be removed at once.
        NSMutableIndexSet *indicesOfItemsToDelete = [NSMutableIndexSet new];
        for (NSIndexPath *selectionIndex in selectedRows)
        {
            [indicesOfItemsToDelete addIndex:selectionIndex.row];
        }
        // Delete the objects from our data model.
        [self.dataList removeObjectsAtIndexes:indicesOfItemsToDelete];
        
        // Tell the tableView that we deleted the objects
        [self.tableView deleteRowsAtIndexPaths:selectedRows withRowAnimation:UITableViewRowAnimationAutomatic];
    } else {
        // Delete everything, delete the objects from our data model.
        [self.dataList removeAllObjects];
        
        // Tell the tableView that we deleted the objects.
        // Because we are deleting all the rows, just reload the current table section
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
    // Exit editing mode after the deletion.
    [self setEditing:NO animated:YES];
    [self updateButtonsToMatchTableState];
    [self updateDeleteButtonTitle];
    [self setTextOnQuantityLabel:@(_dataList.count).stringValue];
    
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Update the delete button's title based on how many items are selected.
    [self updateDeleteButtonTitle];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Update the delete button's title based on how many items are selected.
    if (tableView.editing) {
        [self updateButtonsToMatchTableState];
    }else {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        if (self.currentCollectionType==0) {
            [self getPartsDetailDataWithPartsID:[self.dataList[indexPath.row] objectForKey:@"goods_id"]];
            
        }else if (self.currentCollectionType==1) {
            NSDictionary *detail = self.dataList[indexPath.row];
            NSString *majorService = detail[@"service_name"];
            NSArray *specCheckList = @[@"轮胎", @"玻璃", @"电瓶"];
            ShopNServiceDetailVC *vc = [ShopNServiceDetailVC new];
            vc.shopOrServiceID = [SupportingClass verifyAndConvertDataToString:detail[@"wxs_id"]];
            vc.wasSpecItemService = [specCheckList containsObject:majorService];
            [self setDefaultNavBackButtonWithoutTitle];
            [self.navigationController pushViewController:vc animated:YES];
        }else if (self.currentCollectionType==2) {
            [self getMechanicDetail:indexPath];
        }
        
    }
}


#pragma -mark Updating button state
- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    // Make sure you call super first
    [super setEditing:editing animated:animated];
    editing = !self.tableView.editing;
    self.deleteBtn.hidden = !editing;
    [self.tableView reloadData];
    if (editing) {
        self.editButtonItem.title = getLocalizationString(@"cancel");
        self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(_tableView.frame), 40.0f)];
        [_deleteBtn setBackgroundColor:CDZColorOfLightGray];
        [_deleteBtn setEnabled:NO];
    } else {
        self.editButtonItem.title = getLocalizationString(@"edit");
        self.tableView.tableFooterView = [UIView new];
    }
    [self.tableView setBounces:!editing];
    if (editing) {
        self.tableView.mj_footer.hidden = editing;
    }else {
        [self isNeedHiddenPageUpdateView];
    }
    
    [self.tableView setEditing:editing animated:animated];

    self.commodityButton.enabled = YES;
    self.commodityButton.selected = (self.currentCollectionType==0);
    self.shopButton.enabled = YES;
    self.shopButton.selected = (self.currentCollectionType==1);
    self.mechanicButton.enabled = YES;
    self.mechanicButton.selected = (self.currentCollectionType==2);
    [self updateDeleteButtonTitle];
    
}

- (void)updateButtonsToMatchTableState {
    if (self.tableView.editing) {
        
        [self updateDeleteButtonTitle];
        
    } else {
        // Not in editing mode.
        
        // Show the edit button, but disable the edit button if there's nothing to edit.
        if (self.dataList.count > 0)
        {
            self.editButtonItem.enabled = YES;
        }
        else
        {
            self.editButtonItem.enabled = NO;
        }
        
    }
}

- (void)updateDeleteButtonTitle {
    // Update the delete button's title, based on how many items are selected
    NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
    
    BOOL allItemsAreSelected = selectedRows.count == self.dataList.count;
    BOOL noItemsAreSelected = selectedRows.count == 0;
    NSString *titleString = nil;
    if (noItemsAreSelected) {
        titleString = getLocalizationString(@"delete");
    }else {
        NSString *titleFormatString = [getLocalizationString(@"delete") stringByAppendingString:@" (%d)"];
        titleString = allItemsAreSelected?getLocalizationString(@"delete_all"):[NSString stringWithFormat:titleFormatString, selectedRows.count];
    }
    
    
    [_deleteBtn setBackgroundColor:noItemsAreSelected?CDZColorOfLightGray:CDZColorOfRed];
    [_deleteBtn setEnabled:!noItemsAreSelected];
    [_deleteBtn setTitle:titleString forState:UIControlStateNormal];
    
}

#pragma -mark Updating Page state

- (void)setTextOnQuantityLabel:(NSString *)quantity {
    NSMutableAttributedString* message = [NSMutableAttributedString new];
    UIFont *font = [UIFont systemFontOfSize:vAdjustByScreenRatio(15.0f)];
    [message appendAttributedString:[[NSAttributedString alloc]
                                     initWithString:getLocalizationString(@"title_head_caption")
                                     attributes:@{NSForegroundColorAttributeName:CDZColorOfBlack,
                                                  NSFontAttributeName:font
                                                  }]];
    [message appendAttributedString:[[NSAttributedString alloc]
                                     initWithString:quantity
                                     attributes:@{NSForegroundColorAttributeName:CDZColorOfRed,
                                                  NSFontAttributeName:font
                                                  }]];
    
    NSString *caption = getLocalizationString(@"product_tail_caption");
    if (self.currentCollectionType==1) {
        caption = getLocalizationString(@"store_tail_caption");
    }else if (self.currentCollectionType==2) {
        caption = @" 位技师";
    }
    
    [message appendAttributedString:[[NSAttributedString alloc]
                                     initWithString:caption
                                     attributes:@{NSForegroundColorAttributeName:CDZColorOfBlack,
                                                  NSFontAttributeName:font
                                                  }]];
//    [_quantityLabel setAttributedText:message];
}

- (void)updatePageStateWithpageNums:(NSNumber *)pageNums pageSizes:(NSNumber *)pageSizes totalPageSizes:(NSNumber *)totalPageSizes {
    if (totalPageSizes) {
        self.totalPageSizes = totalPageSizes;
        [self setTextOnQuantityLabel:totalPageSizes.stringValue];
    }
    if (pageNums) {
        self.pageNums = pageNums;
    }
    if (pageSizes) {
        self.pageSizes = pageSizes;
    }
}

#pragma -mark Collection List Request functions
- (void)getCollectedList:(id)refresh{
    if (self.currentCollectionType==0) {
        [self getCollectedProductList:refresh];
        
    }else if (self.currentCollectionType==1) {
        [self getCollectedStoreList:refresh];
        
    }else if (self.currentCollectionType==2) {
        [self getMechanicList:refresh];
    }
}

// 请求货品收藏列表
- (void)getCollectedProductList:(id)refresh {
    
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    if (!refresh) {
        [ProgressHUDHandler showHUD];
    }
    BOOL isNeedReload = (!refresh||[refresh isKindOfClass:ODRefreshControl.class]);
    NSLog(@"%@ accessing network product list request",NSStringFromClass(self.class));
    [[APIsConnection shareConnection] personalCenterAPIsGetProductsCollectionListWithAccessToken:self.accessToken pageNums:self.pageNums pageSizes:self.pageSizes success:^(NSURLSessionDataTask *operation, id responseObject) {
        operation.userInfo = @{@"isNeedReload":@(isNeedReload)};
        [self requestResultHandle:operation responseObject:responseObject withError:nil withRefresh:refresh];
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        [self requestResultHandle:operation responseObject:nil withError:error withRefresh:refresh];
    }];
}

// 请求 收藏的店铺列表
- (void)getCollectedStoreList:(id)refresh {
    
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    if (!refresh) {
        [ProgressHUDHandler showHUD];
    }
    BOOL isNeedReload = (!refresh||[refresh isKindOfClass:ODRefreshControl.class]);
    NSLog(@"%@ accessing network store list request",NSStringFromClass(self.class));
    [[APIsConnection shareConnection] personalCenterAPIsGetShopsCollectionListWithAccessToken:self.accessToken pageNums:self.pageNums pageSizes:self.pageSizes coordinate:self.coordinate success:^(NSURLSessionDataTask *operation, id responseObject) {
        operation.userInfo = @{@"isNeedReload":@(isNeedReload)};
        [self requestResultHandle:operation responseObject:responseObject withError:nil withRefresh:refresh];
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        [self requestResultHandle:operation responseObject:nil withError:error withRefresh:refresh];
    }];
}

// 请求 收藏的店铺列表
- (void)getMechanicList:(id)refresh {
    
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    if (!refresh) {
        [ProgressHUDHandler showHUD];
    }
    BOOL isNeedReload = (!refresh||[refresh isKindOfClass:ODRefreshControl.class]);
    NSLog(@"%@ accessing network store list request",NSStringFromClass(self.class));
    [[APIsConnection shareConnection] personalCenterAPIsGetMechanicCollectionListWithAccessToken:self.accessToken pageNums:self.pageNums pageSizes:self.pageSizes success:^(NSURLSessionDataTask *operation, id responseObject) {
        operation.userInfo = @{@"isNeedReload":@(isNeedReload)};
        [self requestResultHandle:operation responseObject:responseObject withError:nil withRefresh:refresh];
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        [self requestResultHandle:operation responseObject:nil withError:error withRefresh:refresh];
    }];
}

- (void)requestResultHandle:(NSURLSessionDataTask *)operation responseObject:(id)responseObject withError:(NSError *)error withRefresh:(id)refresh {
    
    if (error&&!responseObject) {
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
    }else if (!error&&responseObject) {
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        
        [ProgressHUDHandler dismissHUD];
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        BOOL isNoData = [message isEqualToString:@"没有数据"];
        NSLog(@"%@----%@",message,operation.currentRequest.URL.absoluteString);
        if (errorCode!=0&&!isNoData) {
            NSLog(@"%@--",message);
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                
            }];
            return;
        }
        
        BOOL isNeedReload = [[operation.userInfo objectForKey:@"isNeedReload"] boolValue];
        if (isNeedReload||  isNoData) {
            [self.dataList removeAllObjects];
        }
        [self updatePageStateWithpageNums:[SupportingClass verifyAndConvertDataToNumber:[responseObject objectForKey:CDZKeyOfPageNumsKey]]
                                pageSizes:[SupportingClass verifyAndConvertDataToNumber:[responseObject objectForKey:CDZKeyOfPageSizesKey]]
                           totalPageSizes:[SupportingClass verifyAndConvertDataToNumber:[responseObject objectForKey:CDZKeyOfTotalPageSizesKey]]];
        
        if (self.currentCollectionType==2) {
            NSArray *list = [SMSLResultDTO createSMSLResultDataObjectFromSourceList:responseObject[CDZKeyOfResultKey]];
            [self.dataList addObjectsFromArray:list];
        }else {
            [self.dataList addObjectsFromArray:responseObject[CDZKeyOfResultKey]];
        }
        [self.tableView reloadData];
        
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self handleData:refresh];
        [ProgressHUDHandler dismissHUD];
    }
    
}

//删除收藏
- (void)deleteCollectedList {
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    [ProgressHUDHandler showHUD];
    NSLog(@"%@ accessing network delete collection request",NSStringFromClass(self.class));
    NSMutableArray *colloectList = [NSMutableArray array];
    [[_tableView indexPathsForSelectedRows] enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
        NSString *collectionID = @"";
        id obj = self.dataList[indexPath.row];
        if ([obj isKindOfClass:SMSLResultDTO.class]) {
            collectionID = [(SMSLResultDTO *)obj collectionID];
        }else if ([obj isKindOfClass:NSDictionary.class]) {
            collectionID = obj[@"id"];
        }
        if (![collectionID isEqualToString:@""]) {
            [colloectList addObject:collectionID];
        }
    }];
    if (colloectList.count==0||!self.accessToken) return;
    if (self.currentCollectionType==0) {
        [[APIsConnection shareConnection] personalCenterAPIsPostDeleteProductsCollectionWithAccessToken:self.accessToken collectionIDList:colloectList success:^(NSURLSessionDataTask *operation, id responseObject) {
            [self deleteRequestResultHandle:operation responseObject:responseObject withError:nil];
            
        } failure:^(NSURLSessionDataTask *operation, NSError *error) {
            [self deleteRequestResultHandle:operation responseObject:nil withError:error];
        }];
        
    }else if (self.currentCollectionType==1||self.currentCollectionType==2) {
        [[APIsConnection shareConnection] personalCenterAPIsPostDeleteShopCollectionWithAccessToken:self.accessToken collectionIDList:colloectList success:^(NSURLSessionDataTask *operation, id responseObject) {
            [self deleteRequestResultHandle:operation responseObject:responseObject withError:nil];
            
        } failure:^(NSURLSessionDataTask *operation, NSError *error) {
            [self deleteRequestResultHandle:operation responseObject:nil withError:error];
        }];

    }
}

- (void)deleteRequestResultHandle:(NSURLSessionDataTask *)operation responseObject:(id)responseObject withError:(NSError *)error {
    
    if (error&&!responseObject) {
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
    }else if (!error&&responseObject) {
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        switch (errorCode) {
            case 0:
                [self executeDetele];
                [ProgressHUDHandler dismissHUD];
                break;
            case 1:
            case 2:{
                [ProgressHUDHandler dismissHUD];
                NSLog(@"%@",message);
                [SupportingClass showAlertViewWithTitle:@"error" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                    
                }];
            }
                break;
                
            default:
                break;
        }
    }
    
}

//请求商店详情
- (void)getShopDetailDataWithShopID:(NSString *)shopID {
    if (!shopID) return;
    [[APIsConnection shareConnection] maintenanceShopsAPIsGetMaintenanceShopsDetailWithShopID:shopID success:^(NSURLSessionDataTask *operation, id responseObject) {
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        [ProgressHUDHandler dismissHUD];
        if (errorCode!=0) {
            [SupportingClass showAlertViewWithTitle:@"error" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                
            }];
            return ;
        }
        
        @autoreleasepool {
//            RepairShopDetailVC *rsdvc = [[RepairShopDetailVC alloc] init];
//            rsdvc.detailData = responseObject[CDZKeyOfResultKey];
//            [self setDefaultNavBackButtonWithoutTitle];
//            [[self navigationController] pushViewController:rsdvc animated:YES];
        }
    } failure:self.failure];
    
}

//请求配件详情
- (void)getPartsDetailDataWithPartsID:(NSString *)partsID {
    if (!partsID) return;
    [[APIsConnection shareConnection]  theSelfMaintenanceAPIsGetItemDetailWithWithAccessToken:self.accessToken productID:partsID success:^(NSURLSessionDataTask *operation, id responseObject) {
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        [ProgressHUDHandler dismissHUD];
        if (errorCode!=0) {
            
            [SupportingClass showAlertViewWithTitle:@"error" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                
            }];
            return;
        }
        PartsDetailVC *ridvc = PartsDetailVC.new;
        ridvc.itemDetail = responseObject[CDZKeyOfResultKey];
        [self setDefaultNavBackButtonWithoutTitle];
        [[self navigationController] pushViewController:ridvc animated:YES];
        
    } failure:self.failure];
}

//请求技师详情
- (void)getMechanicDetail:(NSIndexPath *)indexPath {
    if (!indexPath) {
        return;
    }
    SMSLResultDTO *dto = self.dataList[indexPath.row];
    [ProgressHUDHandler showHUD];
    @weakify(self);
    [APIsConnection.shareConnection mechanicCenterAPIsGetMechanicDetailWithAccessToken:self.accessToken mechanicID:dto.mechanicID success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@-----%@", NSStringFromClass(self.class), operation.currentRequest.URL.absoluteString);
        
        [ProgressHUDHandler dismissHUD];
        if (errorCode!=0) {
            [SupportingClass showAlertViewWithTitle:@"error" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                
            }];
            return;
        }
        ShopMechanicDetailVC *vc = [ShopMechanicDetailVC new];
        vc.mechanicID = dto.mechanicID;
        vc.detailData = [ShopMechanicDetailDTO createMechanicDetailFromSourceData:responseObject[CDZKeyOfResultKey]];
        vc.selectedMechanicDetail = dto;
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        NSLog(@"%@",error);
        @strongify(self);
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
