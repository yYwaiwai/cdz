//
//  CDZOrderPaymentClearanceVC.m
//  cdzer
//
//  Created by KEns0nLau on 9/14/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "CDZOrderPaymentClearanceVC.h"
#import "CouponNCreditSectionView.h"
#import "AddressInfoSectionComponent.h"
#import "RepairItemNWorkingPriceInfoView.h"
#import "UIView+LayoutConstraintHelper.h"
#import "UserSelectedAutosInfoDTO.h"
#import "ProductInfoSectionCell.h"
#import "OrderPriceInfoListCell.h"
#import "PaymentCenterVC.h"
#import "MyOrdersVC.h"
#import "MyMaintenanceManagementVC.h"

@interface CDZOrderPaymentClearanceVC () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;


@property (nonatomic, strong) IBOutlet AddressInfoSectionForRegularParts *regularPartsAddressView;
@property (nonatomic, strong) IBOutlet AddressInfoSectionForSpecRepair *specRepairAddressView;
@property (nonatomic, strong) IBOutlet AddressInfoSectionForMaintenanceExpress *maintainExpressAddressView;
@property (nonatomic, strong) IBOutlet RepairItemNWorkingPriceInfoView *repairItemNWorkingPriceView;

@property (weak, nonatomic) IBOutlet UIView *topInfoContentsView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tmpTopInfoContentsViewHeightConstraint;


@property (nonatomic, strong) IBOutlet CouponNCreditSectionView *cncView;
@property (weak, nonatomic) IBOutlet UIView *centerContentsView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tmpCenterContentsViewHeightConstraint;


@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UITableView *productsTableView;


@property (strong, nonatomic) IBOutlet NSLayoutConstraint *orderPriceInfoTVHeightConstraint;
@property (weak, nonatomic) IBOutlet UITableView *orderPriceInfoTableView;
@property (nonatomic, strong) NSMutableArray <NSDictionary *> *orderPriceInfoList;
@property (nonatomic, strong) NSString *totalDiscount;

@property (weak, nonatomic) IBOutlet UILabel *discountTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *discountPriceLabel;
@property (weak, nonatomic) IBOutlet UIView *discountInfoSubContainerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *discountInfoSubContainerViewTopConstraint;


@property (weak, nonatomic) IBOutlet UILabel *totalPriceLabel;



@property (nonatomic, strong) UserSelectedAutosInfoDTO *selectedAutosDTO;
@property (nonatomic, strong) NSDictionary *orderInfoDetail;
@property (nonatomic, strong) NSMutableArray <PISCConfigObject *> *productsConfigList;

@end

@implementation CDZOrderPaymentClearanceVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)viewDidLoad {
    self.title = @"确认订单";
    if (self.orderClearanceType==CDZOrderPaymentClearanceTypeOfRepairNMaintenance) {
        self.title = @"维修支付";
    }
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self componentSetting];
    [self initializationUI];
    [self setReactiveRules];
//    [self getOrderInfo];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getOrderInfo];
    NSLog(@"/////%lu",(unsigned long)self.orderClearanceType);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self.discountInfoSubContainerView.superview.superview setViewBorderWithRectBorder:UIRectBorderTop borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self.discountInfoSubContainerView.superview setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    [[self.view viewWithTag:99] setViewBorderWithRectBorder:UIRectBorderTop borderSize:0.5 withColor:nil withBroderOffset:nil];
}

- (void)componentSetting {
    @autoreleasepool {
        self.navShouldPopOtherVC = YES;
        self.productsConfigList = [@[] mutableCopy];
        self.selectedAutosDTO = [DBHandler.shareInstance getSelectedAutoData];
        [[UINib nibWithNibName:@"CouponNCreditSectionView" bundle:nil] instantiateWithOwner:self options:nil];
        if(self.orderClearanceType!=CDZOrderPaymentClearanceTypeOfRepairNMaintenance){
            [[UINib nibWithNibName:@"AddressInfoSectionComponent" bundle:nil] instantiateWithOwner:self options:nil];
        }else {
            [[UINib nibWithNibName:@"RepairItemNWorkingPriceInfoView" bundle:nil] instantiateWithOwner:self options:nil];
        }
        
        self.productsTableView.rowHeight = UITableViewAutomaticDimension;
        self.productsTableView.estimatedRowHeight = 400.0f;
        self.productsTableView.showsVerticalScrollIndicator = NO;
        [self.productsTableView registerNib:[UINib nibWithNibName:@"ProductInfoSectionCell" bundle:nil] forCellReuseIdentifier:CDZKeyOfCellIdentKey];
        
        self.orderPriceInfoTableView.rowHeight = UITableViewAutomaticDimension;
        self.orderPriceInfoTableView.estimatedRowHeight = 400.0f;
        self.orderPriceInfoTableView.showsVerticalScrollIndicator = NO;
        [self.orderPriceInfoTableView registerNib:[UINib nibWithNibName:@"OrderPriceInfoListCell" bundle:nil] forCellReuseIdentifier:CDZKeyOfCellIdentKey];
        
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(adjustTextViewPosition:) name:PISCTextViewAdjustPositionNotification object:nil];
    }
}

- (void)initializationUI {
    @autoreleasepool {
        switch (self.orderClearanceType) {
            case CDZOrderPaymentClearanceTypeOfRegularParts:
                [self.regularPartsAddressView addSelfByFourMarginToSuperview:self.topInfoContentsView];
                self.specRepairAddressView = nil;
                self.maintainExpressAddressView = nil;
                break;
            case CDZOrderPaymentClearanceTypeOfSpecRepair:
                self.regularPartsAddressView = nil;
                [self.specRepairAddressView addSelfByFourMarginToSuperview:self.topInfoContentsView];
                self.maintainExpressAddressView = nil;
                break;
            case CDZOrderPaymentClearanceTypeOfMaintainExpress:
                self.regularPartsAddressView = nil;
                self.specRepairAddressView = nil;
                self.maintainExpressAddressView.maintainItemList = self.maintainItemList;
                [self.maintainExpressAddressView addSelfByFourMarginToSuperview:self.topInfoContentsView];
                break;
            case CDZOrderPaymentClearanceTypeOfRepairNMaintenance:
                [self.repairItemNWorkingPriceView addSelfByFourMarginToSuperview:self.topInfoContentsView];
                break;
            default:
                break;
        }
        
        [self.topInfoContentsView removeConstraint:self.tmpTopInfoContentsViewHeightConstraint];
        self.tmpTopInfoContentsViewHeightConstraint = nil;
        
        self.cncView.orderClearanceType = self.orderClearanceType;
        [self.cncView addSelfByFourMarginToSuperview:self.centerContentsView];
        [self.centerContentsView removeConstraint:self.tmpCenterContentsViewHeightConstraint];
        self.tmpCenterContentsViewHeightConstraint = nil;
    }
}

- (void)setReactiveRules {
    @weakify(self);
    [RACObserve(self, productsTableView.contentSize) subscribeNext:^(id size) {
        @strongify(self);
        CGSize contentSize = [size CGSizeValue];
        self.tableViewHeightConstraint.constant = contentSize.height;
    }];
    
    [RACObserve(self, orderPriceInfoTableView.contentSize) subscribeNext:^(id size) {
        @strongify(self);
        CGSize contentSize = [size CGSizeValue];
        self.orderPriceInfoTVHeightConstraint.constant = contentSize.height;
    }];
    
    if (self.orderClearanceType==CDZOrderPaymentClearanceTypeOfMaintainExpress) {
        [RACObserve(self, self.maintainExpressAddressView.repairShopID) subscribeNext:^(NSString *repairShopID) {
            @strongify(self);
            if (repairShopID&&repairShopID.length>6) {
                [self getOrderInfo];
            }
        }];
    }
    
    [RACObserve(self, cncView.isActiveCoupon) subscribeNext:^(NSNumber *isActiveCoupon) {
        @strongify(self);
        [self updateTotalPriceNDiscountValue];
    }];
    
    [RACObserve(self, cncView.isActiveAccumulatePoints) subscribeNext:^(NSNumber *isActiveAccumulatePoints) {
        @strongify(self);
        [self updateTotalPriceNDiscountValue];
    }];
    
    [RACObserve(self, cncView.totalRemainPrice) subscribeNext:^(NSNumber *totalRemainPrice) {
        @strongify(self);
        [self updateTotalPriceNDiscountValue];
    }];
}

- (void)updateTotalPriceNDiscountValue {
    CGFloat totalPrice = [SupportingClass verifyAndConvertDataToString:self.orderInfoDetail[@"sum_price"]].floatValue;
    BOOL isCouponNAccumulatePointsInactive = (!self.cncView.isActiveCoupon&&!self.cncView.isActiveAccumulatePoints);
    CGFloat constant = isCouponNAccumulatePointsInactive?-(CGRectGetHeight(self.discountInfoSubContainerView.frame)):0;
    self.discountInfoSubContainerView.hidden = isCouponNAccumulatePointsInactive;
    self.discountInfoSubContainerViewTopConstraint.constant = constant;
    self.discountTitleLabel.text = @"优惠抵用";
    self.discountPriceLabel.text = @"0.00";
    self.totalPriceLabel.text = [NSString stringWithFormat:@"%.02f", totalPrice];
    if (!isCouponNAccumulatePointsInactive){
        if (self.cncView.isActiveCoupon) {
            
            self.discountTitleLabel.text = @"优惠劵抵用";
            CGFloat remainPrice = totalPrice-self.cncView.selectedCouponAmount.floatValue;
            if (remainPrice<0) remainPrice = totalPrice;
            self.discountPriceLabel.text = [NSString stringWithFormat:@"%0.2f", self.cncView.selectedCouponAmount.floatValue];
            self.totalPriceLabel.text = [NSString stringWithFormat:@"%.02f", remainPrice];
            
        }else if (self.cncView.isActiveAccumulatePoints) {
            
            self.discountTitleLabel.text = @"积分抵用";
            CGFloat remainPrice = totalPrice-self.cncView.totalRemainPrice;
            self.discountPriceLabel.text = [NSString stringWithFormat:@"%0.2f", self.cncView.totalRemainPrice];
            self.totalPriceLabel.text = [NSString stringWithFormat:@"%.02f", remainPrice];
            
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateAddressSectionInfo {
    switch (self.orderClearanceType) {
        case CDZOrderPaymentClearanceTypeOfRegularParts:
            
            break;
        case CDZOrderPaymentClearanceTypeOfSpecRepair:
            
            break;
        case CDZOrderPaymentClearanceTypeOfMaintainExpress:
            
            break;
            
        default:
            break;
    }
}

- (void)updateUIDate {
    self.totalDiscount = @"0.00";
    if (!self.orderPriceInfoList) self.orderPriceInfoList = [@[] mutableCopy];
    [self.orderPriceInfoList removeAllObjects];
    if (self.orderClearanceType==CDZOrderPaymentClearanceTypeOfRepairNMaintenance) {
        
        NSString *manageFee = [NSString stringWithFormat:@"%.02f", [SupportingClass verifyAndConvertDataToString:self.orderInfoDetail[@"manager_fee"]].floatValue];
        [self.orderPriceInfoList addObject:@{@"title":@"管理费", @"value":manageFee}];
        
        NSString *diagnoseFee = [NSString stringWithFormat:@"%.02f", [SupportingClass verifyAndConvertDataToString:self.orderInfoDetail[@"check_fee"]].floatValue];
        [self.orderPriceInfoList addObject:@{@"title":@"诊断费", @"value":diagnoseFee}];
        
        NSString *totalWorkingPrice = [NSString stringWithFormat:@"%.02f", [SupportingClass verifyAndConvertDataToString:self.orderInfoDetail[@"work_price"]].floatValue];
        [self.orderPriceInfoList addObject:@{@"title":@"总工时费", @"value":totalWorkingPrice}];
        
        NSString *materialPrice = [NSString stringWithFormat:@"%.02f", [SupportingClass verifyAndConvertDataToString:self.orderInfoDetail[@"product_price"]].floatValue];
        [self.orderPriceInfoList addObject:@{@"title":@"材料费", @"value":materialPrice}];
        
        self.totalPriceLabel.text = [NSString stringWithFormat:@"%.02f", [SupportingClass verifyAndConvertDataToString:self.orderInfoDetail[@"sum_price"]].floatValue];
        
        [self.repairItemNWorkingPriceView updateUIData:self.orderInfoDetail];
    }else{
        
        if (self.orderClearanceType==CDZOrderPaymentClearanceTypeOfRegularParts) {
            NSString *productTotalPrice = [NSString stringWithFormat:@"%.02f", [SupportingClass verifyAndConvertDataToString:self.orderInfoDetail[@"goods_fee"]].floatValue];
            [self.orderPriceInfoList addObject:@{@"title":@"产品金额", @"value":productTotalPrice}];
            
            NSString *freightPrice = [NSString stringWithFormat:@"%.02f", [SupportingClass verifyAndConvertDataToString:self.orderInfoDetail[@"send_cost"]].floatValue];
            [self.orderPriceInfoList addObject:@{@"title":@"运费", @"value":freightPrice}];
            
            self.totalPriceLabel.text = [NSString stringWithFormat:@"%.02f", [SupportingClass verifyAndConvertDataToString:self.orderInfoDetail[@"sum_price"]].floatValue];
            
        }else if (self.orderClearanceType==CDZOrderPaymentClearanceTypeOfSpecRepair) {
            
            NSString *productTotalPrice = [NSString stringWithFormat:@"%.02f", [SupportingClass verifyAndConvertDataToString:self.orderInfoDetail[@"sum_price"]].floatValue];
            [self.orderPriceInfoList addObject:@{@"title":@"产品金额", @"value":productTotalPrice}];
            self.totalPriceLabel.text = productTotalPrice;
            [self.specRepairAddressView updateUIData:self.orderInfoDetail];
        }else if (self.orderClearanceType==CDZOrderPaymentClearanceTypeOfMaintainExpress) {
            
            NSString *productTotalPrice = [NSString stringWithFormat:@"%.02f", [SupportingClass verifyAndConvertDataToString:self.orderInfoDetail[@"goods_fee"]].floatValue];
            [self.orderPriceInfoList addObject:@{@"title":@"产品金额", @"value":productTotalPrice}];
            
            NSString *workingPrice = [NSString stringWithFormat:@"%.02f", [SupportingClass verifyAndConvertDataToString:self.orderInfoDetail[@"service_price"]].floatValue];
            [self.orderPriceInfoList addObject:@{@"title":@"工时费", @"value":workingPrice}];
            
            NSString *freightPrice = [NSString stringWithFormat:@"%.02f", [SupportingClass verifyAndConvertDataToString:self.orderInfoDetail[@"send_cost"]].floatValue];
            [self.orderPriceInfoList addObject:@{@"title":@"运费", @"value":freightPrice}];
            
            self.totalPriceLabel.text = [NSString stringWithFormat:@"%.02f", [SupportingClass verifyAndConvertDataToString:self.orderInfoDetail[@"sum_price"]].floatValue];
            NSString *repairID = [SupportingClass verifyAndConvertDataToString:self.orderInfoDetail[@"wxs_id"]];
            
            [self.maintainExpressAddressView setDefaultRepairShopID:repairID andRepairShopName:self.orderInfoDetail[@"wxs_name"]];
        }
    }
    [self.orderPriceInfoTableView reloadData];
    NSMutableDictionary *detail = [self.orderInfoDetail mutableCopy];
    if (self.repairShopName&&!self.orderInfoDetail[@"wxs_name"]) {
        [detail setObject:self.repairShopName forKey:@"wxs_name"];
    }
    [self.cncView updateUIData:detail];
    [self reloadProductSectionConfig];
    
}

- (void)adjustTextViewPosition:(NSNotification *)notiObj {
    UITextField *textField = (UITextField *)notiObj.userInfo[@"tf"];
    CGRect keyboardRect = [notiObj.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    if (textField) {
        CGRect rect = [self.scrollView convertRect:textField.frame fromView:textField.superview];
        CGFloat centerPoint = CGRectGetMidY(rect);
        CGFloat visibleSpace = SCREEN_HEIGHT-64.f-CGRectGetHeight(keyboardRect);
        [self.scrollView setContentOffset:CGPointMake(0.0, centerPoint-visibleSpace/2) animated:NO];
    }
}

- (void)reloadProductSectionConfig {
    [self.productsConfigList removeAllObjects];
    if (self.orderClearanceType==CDZOrderPaymentClearanceTypeOfRegularParts) {
        NSArray <NSDictionary *> *centerList = self.orderInfoDetail[@"center_info"];
        @weakify(self);
        [centerList enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull detail, NSUInteger idx, BOOL * _Nonnull stop) {
            @strongify(self);
            NSArray *productList = detail[@"product_info"];
            PISCConfigObject *cfgObj = [PISCConfigObject new];
            cfgObj.isMultiProduct = (productList.count>=2);
            cfgObj.showUserRemarkView = YES;
            cfgObj.showTotalPriceView = YES;
            cfgObj.showExpressPriceInfoView = YES;
            cfgObj.orderClearanceType = self.orderClearanceType;
            cfgObj.dataConfigDetail = detail;
            [self.productsConfigList addObject:cfgObj];
        }];
    }else if (self.orderClearanceType==CDZOrderPaymentClearanceTypeOfSpecRepair) {
        PISCConfigObject *cfgObj = [PISCConfigObject new];
        cfgObj.isMultiProduct = NO;
        cfgObj.orderClearanceType = self.orderClearanceType;
        cfgObj.dataConfigDetail = self.orderInfoDetail;
        [self.productsConfigList addObject:cfgObj];
    }else if (self.orderClearanceType==CDZOrderPaymentClearanceTypeOfMaintainExpress) {
        NSArray <NSDictionary *> *centerList = self.orderInfoDetail[@"center_info"];
        @weakify(self);
        [centerList enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull detail, NSUInteger idx, BOOL * _Nonnull stop) {
           @strongify(self);
            NSMutableDictionary *mutableDetail = [detail mutableCopy];
            [mutableDetail setObject:self.orderInfoDetail[@"send_cost"] forKey:@"send_cost"];
            NSArray *productList = mutableDetail[@"product_info"];
            NSArray *workingList = mutableDetail[@"work_info"];
            PISCConfigObject *cfgObj = [PISCConfigObject new];
            cfgObj.isMultiProduct = (productList.count>=2||workingList.count>0);
            cfgObj.showUserRemarkView = YES;
            cfgObj.showTotalPriceView = YES;
            cfgObj.showExpressPriceInfoView = YES;
            cfgObj.orderClearanceType = self.orderClearanceType;
            cfgObj.dataConfigDetail = mutableDetail;
            [self.productsConfigList addObject:cfgObj];
        }];
    }
    
    [self.productsTableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.orderPriceInfoTableView==tableView) return self.orderPriceInfoList.count;
    return self.productsConfigList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.orderPriceInfoTableView==tableView) {
        OrderPriceInfoListCell *cell = [tableView dequeueReusableCellWithIdentifier:CDZKeyOfCellIdentKey forIndexPath:indexPath];
        NSDictionary *detail = self.orderPriceInfoList[indexPath.row];
        cell.titleLabel.text = detail[@"title"];
        cell.priceLabel.text = detail[@"value"];
        return cell;
    }
    
    ProductInfoSectionCell *cell = [tableView dequeueReusableCellWithIdentifier:CDZKeyOfCellIdentKey forIndexPath:indexPath];
    if (!cell.tvContainerView||cell.tvContainerView!=tableView) {
        cell.tvContainerView = tableView;
    }
    cell.indexPath = indexPath;
    PISCConfigObject *configObj = self.productsConfigList[indexPath.row];
    [cell updateUIDataConfig:configObj];
    return cell;
}

- (IBAction)submitOrder {
    @weakify(self);
    if (self.orderClearanceType==CDZOrderPaymentClearanceTypeOfRepairNMaintenance) {
        NSString *payeeNameString = self.repairItemNWorkingPriceView.payeeNameString;
        if (self.repairItemNWorkingPriceView.isNeedInvoice&&
            (!payeeNameString||[payeeNameString isEqualToString:@""])) {
            [SupportingClass showAlertViewWithTitle:nil message:@"请输入发票抬头！" isShowImmediate:YES cancelButtonTitle:nil otherButtonTitles:nil clickedButtonAtIndexWithBlock:nil];
            return;
        }
    }else {
        __block BOOL wasFoundCondition = NO;
        [self.productsConfigList enumerateObjectsUsingBlock:^(PISCConfigObject * _Nonnull cfgObj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *payeeNameString = cfgObj.payeeNameString;
            if (cfgObj.showPayeeNameLabel&&(!payeeNameString||[payeeNameString isEqualToString:@""])) {
                wasFoundCondition = YES;
                *stop = YES;
            }
        }];
        if (wasFoundCondition) {
            [SupportingClass showAlertViewWithTitle:nil message:@"请输入发票抬头！" isShowImmediate:YES cancelButtonTitle:nil otherButtonTitles:nil clickedButtonAtIndexWithBlock:nil];
            return;
        }
    }
    if (self.cncView.isActiveAccumulatePoints&&self.cncView.verifyCode.length<4) {
        [SupportingClass showAlertViewWithTitle:nil message:@"请输入验证码！" isShowImmediate:YES cancelButtonTitle:nil otherButtonTitles:nil clickedButtonAtIndexWithBlock:nil];
        return;
    }
    [SupportingClass showAlertViewWithTitle:nil message:@"是否确认支付订单" isShowImmediate:YES cancelButtonTitle:@"cancel" otherButtonTitles:@"ok" clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
        if (btnIdx.integerValue>0) {
            @strongify(self);
            [self submitOrderRequest];
        }
    }];
}

- (void)submitOrderRequest {
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    @weakify(self);
    [ProgressHUDHandler showHUD];
    
    if (self.orderClearanceType==CDZOrderPaymentClearanceTypeOfRegularParts) {
        NSString *addressID = self.regularPartsAddressView.selectedAddressDTO.addressID;
        if (!addressID||[addressID isEqualToString:@""]) {
            [SupportingClass showAlertViewWithTitle:@"" message:@"请选择收货地址" isShowImmediate:YES cancelButtonTitle:nil otherButtonTitles:nil clickedButtonAtIndexWithBlock:nil];
            [ProgressHUDHandler dismissHUD];
            return;
        }
        NSMutableArray *userRemarkList = [@[] mutableCopy];
        NSMutableArray *productIDList = [@[] mutableCopy];
        NSMutableArray *invoicePayeeNameList = [@[] mutableCopy];
        [self.productsConfigList enumerateObjectsUsingBlock:^(PISCConfigObject * _Nonnull cfgObj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *payeeNameString = cfgObj.payeeNameString;
            if (!cfgObj.showPayeeNameLabel) payeeNameString = @"";
            [invoicePayeeNameList addObject:payeeNameString];
            
            NSString *userRemark = cfgObj.userRemarkString;
            if (!cfgObj.showUserRemarkView) userRemark = @"";
            [userRemarkList addObject:userRemark];
            
            NSArray *producLit = [cfgObj.dataConfigDetail[@"product_info"] valueForKey:@"product_id"];
            [productIDList addObjectsFromArray:producLit];
            
        }];
        NSString *totalPrice = [SupportingClass verifyAndConvertDataToString:self.orderInfoDetail[@"sum_price"]];        NSString *creditTotalConsumed = nil;
        NSString *verifyCode = nil;
        if (self.cncView.isActiveAccumulatePoints) {
            verifyCode = self.cncView.verifyCode;
            creditTotalConsumed = @(self.cncView.consumedPoints).stringValue;
        }
        [APIsConnection.shareConnection personalCenterAPIsPostConfirmOrderAndPaymentWithAccessToken:self.accessToken productIDList:productIDList addressID:addressID totalPrice:totalPrice creditTotalConsumed:creditTotalConsumed verifyCode:verifyCode invoicePayeeNameList:invoicePayeeNameList userRemarkList:userRemarkList isFormCart:!self.isBuyNow success:^(NSURLSessionDataTask *operation, id responseObject) {
            @strongify(self);
            NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
            NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
            NSLog(@"订单确认  %@  %@",message,operation.currentRequest.URL.absoluteString);
            if (errorCode!=0){
                if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {return;};
                [ProgressHUDHandler dismissHUD];
                [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
                return;
            }
            [ProgressHUDHandler dismissHUD];
            if ([message isContainsString:@"支付成功"]) {
                [self pushToOrderListOrOrderDetail];
            }else if ([message isContainsString:@"订单提交成功"]){
                [self pushToPaymentCenter:responseObject[CDZKeyOfResultKey]];
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
        
    }else if (self.orderClearanceType==CDZOrderPaymentClearanceTypeOfSpecRepair) {
        NSString *shopID = self.orderInfoDetail[@"wxs_id"];
        NSString *productID = self.orderInfoDetail[@"product_id"];
        NSString *totalPrice = [SupportingClass verifyAndConvertDataToString:self.orderInfoDetail[@"sum_price"]];
        NSString *invoicePayeeName = self.productsConfigList.firstObject.payeeNameString;
        if (!self.productsConfigList.firstObject.showPayeeNameLabel) invoicePayeeName = @"";
        NSString *creditTotalConsumed = nil;
        NSString *verifyCode = nil;
        NSString *couponID = nil;
        if (self.cncView.isActiveAccumulatePoints) {
            verifyCode = self.cncView.verifyCode;
            creditTotalConsumed = @(self.cncView.consumedPoints).stringValue;
        }else if (self.cncView.isActiveCoupon) {
            couponID = self.cncView.selectedCouponID;
        }
        [APIsConnection.shareConnection personalCenterAPIsPostRapidRepairSpecPartsOrderSubmitWithAccessToken:self.accessToken shopID:shopID productID:productID purchaseCount:self.specProductPurchaseCount totalPrice:totalPrice creditTotalConsumed:creditTotalConsumed verifyCode:verifyCode couponID:couponID invoicePayeeName:invoicePayeeName success:^(NSURLSessionDataTask *operation, id responseObject) {
            @strongify(self);
            NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
            NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
            NSLog(@"提交订单（轮胎、电瓶、玻璃  %@  %@",message,operation.currentRequest.URL.absoluteString);
            if (errorCode!=0){
                if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {return;};
                [ProgressHUDHandler dismissHUD];
                [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
                return;
            }
            [ProgressHUDHandler dismissHUD];
            
            if ([message isContainsString:@"支付成功"]) {
                [self pushToOrderListOrOrderDetail];
            }else if ([message isContainsString:@"订单提交成功"]){
                [self pushToPaymentCenter:responseObject[CDZKeyOfResultKey]];
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
    }else if (self.orderClearanceType==CDZOrderPaymentClearanceTypeOfMaintainExpress) {
        
        NSString *addressID = self.maintainExpressAddressView.selectedAddressDTO.addressID;
        if (!addressID||[addressID isEqualToString:@""]) {
            [SupportingClass showAlertViewWithTitle:@"" message:@"请选择收货人和号码" isShowImmediate:YES cancelButtonTitle:nil otherButtonTitles:nil clickedButtonAtIndexWithBlock:nil];
            [ProgressHUDHandler dismissHUD];
            return;
        }
        NSString *repairShopID = [SupportingClass verifyAndConvertDataToString:self.orderInfoDetail[@"wxs_id"]];
        NSMutableArray *userRemarkList = [@[] mutableCopy];
        NSMutableArray *productIDList = [@[] mutableCopy];
        NSMutableArray *invoicePayeeNameList = [@[] mutableCopy];
        [self.productsConfigList enumerateObjectsUsingBlock:^(PISCConfigObject * _Nonnull cfgObj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *payeeNameString = cfgObj.payeeNameString;
            if (!cfgObj.showPayeeNameLabel) payeeNameString = @"";
            [invoicePayeeNameList addObject:payeeNameString];
            
            NSString *userRemark = cfgObj.userRemarkString;
            if (!cfgObj.showUserRemarkView) userRemark = @"";
            [userRemarkList addObject:userRemark];
            
            NSArray *producLit = [cfgObj.dataConfigDetail[@"product_info"] valueForKey:@"product_id"];
            [productIDList addObjectsFromArray:producLit];
            
        }];
        NSString *totalPrice = [SupportingClass verifyAndConvertDataToString:self.orderInfoDetail[@"sum_price"]];
        NSString *creditTotalConsumed = nil;
        NSString *verifyCode = nil;
        if (self.cncView.isActiveAccumulatePoints) {
            verifyCode = self.cncView.verifyCode;
            creditTotalConsumed = @(self.cncView.consumedPoints).stringValue;
        }
        [APIsConnection.shareConnection maintenanceExpressAPIsGetMaintenanceOrderSubmitWithAccessToken:self.accessToken repairShopID:repairShopID productIDList:productIDList addressID:addressID totalPrice:totalPrice creditTotalConsumed:creditTotalConsumed verifyCode:verifyCode invoicePayeeNameList:invoicePayeeNameList userRemarkList:userRemarkList  success:^(NSURLSessionDataTask *operation, id responseObject) {
            @strongify(self);
            NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
            NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
            NSLog(@"快捷保养提交订单  %@  %@",message,operation.currentRequest.URL.absoluteString);
            if (errorCode!=0){
                if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {return;};
                [ProgressHUDHandler dismissHUD];
                [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
                return;
            }
            [ProgressHUDHandler dismissHUD];
            if ([message isContainsString:@"支付成功"]) {
                [self pushToOrderListOrOrderDetail];
            }else if ([message isContainsString:@"订单提交成功"]){
                [self pushToPaymentCenter:responseObject[CDZKeyOfResultKey]];
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
    }else if(self.orderClearanceType==CDZOrderPaymentClearanceTypeOfRepairNMaintenance){
        NSNumber *mark = [SupportingClass verifyAndConvertDataToNumber:self.orderInfoDetail[@"mark"]];
        NSString *creditTotalConsumed = nil;
        NSString *verifyCode = nil;
        NSString *selectedCouponID = nil;
        if (self.cncView.isActiveAccumulatePoints) {
            verifyCode = self.cncView.verifyCode;
            creditTotalConsumed = @(self.cncView.consumedPoints).stringValue;
        }
        if (self.cncView.isActiveCoupon) {
            selectedCouponID = self.cncView.selectedCouponID;
        }
        
        [[APIsConnection shareConnection] personalCenterAPIsPostEnsurePayorderWithAccessToken:self.accessToken repairOrderID:self.repairOrderID mark:mark credits:creditTotalConsumed validCode:verifyCode preferId:selectedCouponID invoiceHead:self.repairItemNWorkingPriceView.payeeNameString success:^(NSURLSessionDataTask *operation, id responseObject) {
            @strongify(self);
            NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
            NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
            NSLog(@"维修点击确认付款  %@  %@",message,operation.currentRequest.URL.absoluteString);
            if (errorCode!=0){
                if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {return;};
                [ProgressHUDHandler dismissHUD];
                [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
                return;
            }
            [ProgressHUDHandler dismissHUD];
            if ([message isContainsString:@"支付成功"]) {
                [self pushToRepairList];
            }else if ([message isContainsString:@"提交成功"]){
                [self pushToPaymentCenter:responseObject[CDZKeyOfResultKey]];
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
}

- (void)getOrderInfo {
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    @weakify(self);
    [ProgressHUDHandler showHUD];
    
    if (self.orderClearanceType==CDZOrderPaymentClearanceTypeOfRegularParts) {
        if (self.isBuyNow) {
            AddressDTO *address = self.regularPartsAddressView.selectedAddressDTO;
            NSString *addressIDStr;
            if (address.addressID==nil) {
                addressIDStr=@"";
            }else{
                addressIDStr=address.addressID;
            }
            [[APIsConnection shareConnection] productDetailAPIsGetProductBuyNowPaymentInfoWithAccessToken:self.accessToken productID:self.productList.firstObject purchaseCount:self.productCountList.firstObject brandID:self.selectedAutosDTO.brandID dealershipID:self.selectedAutosDTO.dealershipID seriesID:self.selectedAutosDTO.seriesID modelID:self.selectedAutosDTO.modelID addressID:addressIDStr success:^(NSURLSessionDataTask *operation, id responseObject) {
                @strongify(self);
                NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
                NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
                NSLog(@"快速购买配件  %@  %@",message,operation.currentRequest.URL.absoluteString);
                if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
                    return;
                }
                [ProgressHUDHandler dismissHUD];
                if(errorCode!=0){
                    [SupportingClass showAlertViewWithTitle:@"error" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                        
                    }];
                    return;
                }
                self.orderInfoDetail = responseObject[CDZKeyOfResultKey];
                [self updateUIDate];
                
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
        }else {
            
            AddressDTO *address = self.regularPartsAddressView.selectedAddressDTO;
            [[APIsConnection shareConnection] personalCenterAPIsPostOrderSubmitWithAccessToken:self.accessToken productIDList:self.productList productCountList:self.productCountList addressID:address.addressID success:^(NSURLSessionDataTask *operation, id responseObject) {
                @strongify(self);
                NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
                NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
                NSLog(@"提交订单  %@  %@",message,operation.currentRequest.URL.absoluteString);
                if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
                    return;
                }
                [ProgressHUDHandler dismissHUD];
                if(errorCode!=0){
                    [SupportingClass showAlertViewWithTitle:@"error" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                        
                    }];
                    return;
                }
                //                __block BOOL wasGPSDevice = NO;
                //                NSMutableArray *stockList = [NSMutableArray array];
                //                [self.tableView.indexPathsForSelectedRows enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                //                    NSIndexPath *indexPath = (NSIndexPath *)obj;
                //                    NSDictionary *data = self.cartList[indexPath.row];
                //                    NSString *stocknum = [SupportingClass verifyAndConvertDataToString:data[@"stocknum"]];
                //                    if ([self checkWasGPSDeviceExsitWithIndexPath:indexPath]) {
                //                        stocknum = @"1";
                //                        wasGPSDevice = YES;
                //                    }
                //                    NSDictionary *detail = @{@"productId":data[@"productId"], @"stocknum":stocknum};
                //                    [stockList addObject:detail];
                //                }];
                
                self.orderInfoDetail = responseObject[CDZKeyOfResultKey];
                [self updateUIDate];
                
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
    }else if (self.orderClearanceType==CDZOrderPaymentClearanceTypeOfSpecRepair) {
        
        [APIsConnection.shareConnection personalCenterAPIsGetRapidRepairSpecPartsBuyNowInfoWithAccessToken:self.accessToken productID:self.specProductID purchaseCount:self.specProductPurchaseCount brandID:self.selectedAutosDTO.brandID brandDealershipID:self.selectedAutosDTO.dealershipID seriesID:self.selectedAutosDTO.seriesID modelID:self.selectedAutosDTO.modelID success:^(NSURLSessionDataTask *operation, id responseObject) {
            @strongify(self);
            NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
            NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
            NSLog(@"立即购买（轮胎、电瓶、玻璃）  %@  %@",message,operation.currentRequest.URL.absoluteString);
            if (errorCode!=0){
                if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {return;};
                [ProgressHUDHandler dismissHUD];
                [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
                return;
            }
            [ProgressHUDHandler dismissHUD];
            NSMutableDictionary *detail = [responseObject[CDZKeyOfResultKey] mutableCopy];
            if (self.shopLogoImage) {
                [detail setObject:self.shopLogoImage forKey:@"wxs_logo"];
            }
            self.orderInfoDetail = detail;
            [self updateUIDate];
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
    }else if (self.orderClearanceType==CDZOrderPaymentClearanceTypeOfMaintainExpress) {
        
        if (self.maintainExpressAddressView.repairShopID) {
            [APIsConnection.shareConnection maintenanceExpressAPIsGetMaintenanceClearanceInfoAndShopSelectedWithAccessToken:self.accessToken productList:self.productList productCountList:self.productCountList brandID:self.selectedAutosDTO.brandID dealershipID:self.selectedAutosDTO.dealershipID seriesID:self.selectedAutosDTO.seriesID modelID:self.selectedAutosDTO.modelID repairShopID:self.maintainExpressAddressView.repairShopID repairShopRepairPrice:self.maintainExpressAddressView.repairShopWorkingPrice success:^(NSURLSessionDataTask *operation, id responseObject) {
                
                @strongify(self);
                NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
                NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
                NSLog(@"快捷保养结算确定安装门店初始  %@  %@",message,operation.currentRequest.URL.absoluteString);
                if (errorCode!=0){
                    if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {return;};
                    [ProgressHUDHandler dismissHUD];
                    [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
                    return;
                }
                [ProgressHUDHandler dismissHUD];
                self.orderInfoDetail = responseObject[CDZKeyOfResultKey];
                [self updateUIDate];
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
        }else {
            
            [APIsConnection.shareConnection maintenanceExpressAPIsGetMaintenanceClearanceDefaultInfoWithAccessToken:self.accessToken productList:self.productList productCountList:self.productCountList workHours:self.workingHours brandID:self.selectedAutosDTO.brandID dealershipID:self.selectedAutosDTO.dealershipID seriesID:self.selectedAutosDTO.seriesID modelID:self.selectedAutosDTO.modelID coordinate:self.coordinate cityName:self.cityName success:^(NSURLSessionDataTask *operation, id responseObject) {
                @strongify(self);
                NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
                NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
                NSLog(@"快捷保养结算初始数据  %@  %@",message,operation.currentRequest.URL.absoluteString);
                if (errorCode!=0){
                    if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {return;};
                    [ProgressHUDHandler dismissHUD];
                    [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
                    return;
                }
                [ProgressHUDHandler dismissHUD];
                self.orderInfoDetail = responseObject[CDZKeyOfResultKey];
                [self updateUIDate];
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
    }else if(self.orderClearanceType==CDZOrderPaymentClearanceTypeOfRepairNMaintenance){
        
        [[APIsConnection shareConnection] personalCenterAPIsPostConfirmPayWithAccessToken:self.accessToken keyID:self.repairOrderID success:^(NSURLSessionDataTask *operation, id responseObject) {
            @strongify(self);
            NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
            NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
            NSLog(@"%@---%@",message,operation.currentRequest.URL.absoluteString);
            if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
                return;
            }
            
            if (errorCode!=0) {
                [ProgressHUDHandler dismissHUD];
                [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
                return;
            }
            
            [ProgressHUDHandler dismissHUD];
            self.orderInfoDetail = responseObject[CDZKeyOfResultKey];
            [self updateUIDate];            
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
}

- (void)pushToPaymentCenter:(NSDictionary *)paymentDetail {
    @autoreleasepool {
        PaymentCenterVC *vc = [PaymentCenterVC new];
        vc.paymentDetail = paymentDetail;
        vc.orderClearanceType = self.orderClearanceType;
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)pushToOrderListOrOrderDetail {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.class == %@", MyOrdersVC.class];
    NSArray *result = [self.navigationController.viewControllers filteredArrayUsingPredicate:predicate];
    if (result&&result.count>0) {
        [(MyOrdersVC *)result.lastObject setShouldReloadData:YES];
        [(MyOrdersVC *)result.lastObject setStateNumber:@0];
        [self.navigationController popToViewController:result.lastObject animated:YES];
        return;
    }
    
    MyOrdersVC *vc = MyOrdersVC.new;
    [self setDefaultNavBackButtonWithoutTitle];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)handleNavBackBtnPopOtherAction {
    [self.view endEditing:YES];
    [NSNotificationCenter.defaultCenter postNotificationName:PISCTextViewDidEndNotification object:nil];
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)pushToRepairList {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.class == %@", MyMaintenanceManagementVC.class];
    NSArray *result = [self.navigationController.viewControllers filteredArrayUsingPredicate:predicate];
    if (result&&result.count>0) {
        [(MyMaintenanceManagementVC *)result.lastObject setShouldReloadData:YES];
        [self.navigationController popToViewController:result.lastObject animated:YES];
        return;
    }
    
    MyMaintenanceManagementVC *vc = MyMaintenanceManagementVC.new;
    vc.currentStatusType = CDZMaintenanceStatusTypeOfHasBeenClearing;
    [self setDefaultNavBackButtonWithoutTitle];
    [self.navigationController pushViewController:vc animated:YES];
    return;
}

@end
