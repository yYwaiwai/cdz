//
//  OrderDetailsModel.m
//  cdzer
//
//  Created by 车队长 on 16/9/5.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#define kCellTypeKey @"type"
#define kFristValue @"fristValue"
#define kSecondValue @"secondValue"
#define kThirdValue @"thirdValue"
#define kFourValue @"fourValue"
#import "OrderDetailsModel.h"

#import "MaintenanceDetailsOneCell.h"
#import "MaintenanceDetailsTwoCell.h"
#import "MaintenanceDetailsFourCell.h"
#import "MaintenanceDetailsSixCell.h"
#import "CommodityInformationCell.h"
#import "TimeCostInformationCell.h"
#import "PartsDetailVC.h"
#import "SpecAutosPartsDetailVC.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface OrderDetailsModel ()
//原始配置列表
@property (nonatomic, strong) NSMutableArray <NSDictionary *> *uiDataStructuralConfigList;

@property (nonatomic) BOOL hideProductListInfo;

@property (nonatomic, strong) NSString *orderID;

@end

@implementation OrderDetailsModel

- (instancetype)init {
    if (self=[super init]) {
        self.hideProductListInfo = NO;
        self.uiDataStructuralConfigList = [NSMutableArray array];
    }
    return self;
}

- (void)setTableView:(UITableView *)tableView {
    _tableView = tableView;
    [tableView registerNib:[UINib nibWithNibName:@"MaintenanceDetailsOneCell" bundle:nil] forCellReuseIdentifier:kCellTypeOfTitle];
    [tableView registerNib:[UINib nibWithNibName:@"MaintenanceDetailsTwoCell" bundle:nil] forCellReuseIdentifier:kCellTypeOfNormalContent];
    [tableView registerNib:[UINib nibWithNibName:@"MaintenanceDetailsFourCell" bundle:nil] forCellReuseIdentifier:kCellTypeOfPriceContent];
    [tableView registerNib:[UINib nibWithNibName:@"MaintenanceDetailsSixCell" bundle:nil] forCellReuseIdentifier:kCellTypeOfSpace];
    
    [tableView registerNib:[UINib nibWithNibName:@"CommodityInformationCell" bundle:nil] forCellReuseIdentifier:kCellTypeOfCommodityInformation];
    [tableView registerNib:[UINib nibWithNibName:@"TimeCostInformationCell" bundle:nil] forCellReuseIdentifier:kCellTypeOfTimeCostInformation];
}

- (void)setContentDetail:(NSDictionary *)contentDetail {
    _contentDetail = contentDetail;
    self.orderID = self.contentDetail[@"order_no"];
    [self updateMainConfigList];
}

- (void)updateMainConfigList {
    [self.uiDataStructuralConfigList removeAllObjects];
    if (!self.contentDetail||self.contentDetail==0) {
        return;
    }
    
    if (self.contentDetail[@"express"]&&
        self.contentDetail[@"mail_no"]) {
        
        [self.uiDataStructuralConfigList addObjectsFromArray:@[@{kCellTypeKey:kCellTypeOfSpace, @"height":@11},
                                                               @{@"title":@"物流信息", @"textColor":@"323232",
                                                                 kCellTypeKey:kCellTypeOfTitle, },
                                                               @{@"title":@"物流公司：", @"textColor":@"323232", @"valueKey":@"express",
                                                                 kCellTypeKey:kCellTypeOfNormalContent, },
                                                               @{@"title":@"物流单号：", @"textColor":@"323232", @"valueKey":@"mail_no",
                                                                 kCellTypeKey:kCellTypeOfNormalContent, },
                                                               ]];
        
    }
    
    //商品信息配置
    NSArray *productInfo = self.contentDetail[@"product_info"];
    if (productInfo&&[productInfo isKindOfClass:NSArray.class]){
        
        NSMutableDictionary *productTitleConfig = [@{@"title":@"商品信息", @"textColor":@"323232",
                                                     kCellTypeKey:kCellTypeOfTitle,} mutableCopy];
        if (productInfo.count>5) {
            [productTitleConfig setObject:@(self.hideProductListInfo) forKey:@"hideProductInfo"];
        }
        if (self.orderClearanceType!=CDZOrderPaymentClearanceTypeOfUserMember) {
            [self.uiDataStructuralConfigList addObject:@{kCellTypeKey:kCellTypeOfSpace, @"height":@11}];
        }
        [self.uiDataStructuralConfigList addObject:productTitleConfig];
        
        if (!self.hideProductListInfo) {
            @weakify(self);
            [productInfo enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull detail, NSUInteger idx, BOOL * _Nonnull stop) {
                @strongify(self);
                NSString *img = detail[@"product_img"];
                NSString *name = detail[@"product_name"];
                NSString *num = [NSString stringWithFormat:@"x%@", [SupportingClass verifyAndConvertDataToString:detail[@"product_num"]]];
                NSString *productID = [SupportingClass verifyAndConvertDataToString:detail[@"product_id"]];
                NSString *stateName = detail[@"state_name"];
                
                NSString *price = [SupportingClass verifyAndConvertDataToString:detail[@"product_price"]];
                price = [NSString stringWithFormat:@"¥%0.2f", price.floatValue];
                
                [self.uiDataStructuralConfigList
                 addObject:@{kFristValue:img, kSecondValue:name, kThirdValue:num, kFourValue:price,
                             kCellTypeKey:kCellTypeOfCommodityInformation, @"productID":productID, @"stateName":stateName, @"isLastCell": @((idx+1==productInfo.count))}];
            }];
        }
        
        if (self.orderClearanceType!=CDZOrderPaymentClearanceTypeOfUserMember) {
            [self.uiDataStructuralConfigList
             addObjectsFromArray:@[@{@"title":@"买家留言", @"textColor":@"323232", @"valueKey":@"remarks",@"subTextAlignment":@(NSTextAlignmentRight),
                                     kCellTypeKey:kCellTypeOfNormalContent, },
                                   @{@"title":@"配送方式", @"textColor":@"323232", @"valueKey":@"ooo",@"subTextAlignment":@(NSTextAlignmentRight),
                                     kCellTypeKey:kCellTypeOfNormalContent, },]];
        }
    }
    
    //工时费信息配置
    NSArray *workInfo = self.contentDetail[@"work_info"];
    if (workInfo&&[workInfo isKindOfClass:NSArray.class]){
        [self.uiDataStructuralConfigList
         addObjectsFromArray:@[@{kCellTypeKey:kCellTypeOfSpace, @"height":@11},
                               @{@"title":@"工时费信息", @"textColor":@"323232",
                                 kCellTypeKey:kCellTypeOfTitle, },
                               ]];
        @weakify(self);
        [workInfo enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull detail, NSUInteger idx, BOOL * _Nonnull stop) {
            @strongify(self);
            NSString *img = detail[@"img"];
            NSString *name=detail[@"name"];
            NSString *prices=detail[@"price"];
            NSString *workPreice=self.contentDetail[@"work_price"];
            int num =workPreice.intValue/prices.intValue;
            NSString *numb = [NSString stringWithFormat:@"x%d", num];
            NSString *price = [SupportingClass verifyAndConvertDataToString:detail[@"price"]];
            price = [NSString stringWithFormat:@"¥%0.2f", price.floatValue];
            
            [self.uiDataStructuralConfigList addObject:@{kFristValue:img, kSecondValue:name, kThirdValue:numb, kFourValue:price, kCellTypeKey:kCellTypeOfTimeCostInformation, }];
        }];
    }
    
    [self.uiDataStructuralConfigList addObjectsFromArray:@[@{kCellTypeKey:kCellTypeOfSpace, @"height":@11},
                                                           @{@"title":@"发票信息", @"textColor":@"323232",
                                                             kCellTypeKey:kCellTypeOfTitle, },
                                                           @{@"title":@"发票：", @"textColor":@"323232", @"valueKey":@"invoice",
                                                             kCellTypeKey:kCellTypeOfNormalContent, },
                                                           @{@"title":@"发票抬头：", @"textColor":@"323232", @"valueKey":@"invoice_head",
                                                             kCellTypeKey:kCellTypeOfNormalContent, },
                                                           ]];
    
    if (self.contentDetail[@"center_name"]||
        self.contentDetail[@"center_tel"]||
        self.contentDetail[@"center_address"]) {
        
        [self.uiDataStructuralConfigList addObjectsFromArray:@[@{kCellTypeKey:kCellTypeOfSpace, @"height":@11},
                                                               @{@"title":@"配件中心信息", @"textColor":@"323232",
                                                                 kCellTypeKey:kCellTypeOfTitle, },
                                                               @{@"title":@"配件中心：", @"textColor":@"323232", @"valueKey":@"center_name",
                                                                 kCellTypeKey:kCellTypeOfNormalContent, },
                                                               @{@"title":@"电话：", @"textColor":@"323232", @"valueKey":@"center_tel",
                                                                 kCellTypeKey:kCellTypeOfNormalContent, },
                                                               @{@"title":@"所在城市：", @"textColor":@"323232", @"valueKey":@"center_address", kCellTypeKey:kCellTypeOfNormalContent, },]];
        
    }
    
    
    [self.uiDataStructuralConfigList
     addObjectsFromArray:@[@{kCellTypeKey:kCellTypeOfSpace, @"height":@11},
                           @{@"title":@"商品金额", @"textColor":@"323232",@"subTextColor":@"F8AF30", @"valueKey":@"good_price", @"extValue4Front":@"¥", @"subTextAlignment":@(NSTextAlignmentRight), kCellTypeKey:kCellTypeOfNormalContent, },]];
    //    CDZOrderPaymentClearanceTypeOfRegularParts,
    //    CDZOrderPaymentClearanceTypeOfSpecRepair,
    //    CDZOrderPaymentClearanceTypeOfMaintainExpress,
    
    if (self.orderClearanceType!=CDZOrderPaymentClearanceTypeOfSpecRepair&&
        self.orderClearanceType!=CDZOrderPaymentClearanceTypeOfUserMember) {
        if (self.orderClearanceType==CDZOrderPaymentClearanceTypeOfMaintainExpress) {
            [self.uiDataStructuralConfigList
             addObject:@{@"title":@"工时费：", @"textColor":@"323232", @"subTextColor":@"F8AF30",
                         @"valueKey":@"work_price", @"extValue4Front":@"¥", @"subTextAlignment":@(NSTextAlignmentRight), kCellTypeKey:kCellTypeOfNormalContent, }];
        }
        [self.uiDataStructuralConfigList addObject:@{@"title":@"运费：", @"textColor":@"323232", @"subTextColor":@"F8AF30", @"valueKey":@"send_price",
                                                     @"extValue4Front":@"¥", @"subTextAlignment":@(NSTextAlignmentRight), kCellTypeKey:kCellTypeOfNormalContent,}];
    }
    NSString *costCredits = [SupportingClass verifyAndConvertDataToString:self.contentDetail[@"cost_credits"]];
    NSString *costPrefer = [SupportingClass verifyAndConvertDataToString:self.contentDetail[@"cost_prefer"]];
    if (costCredits.floatValue>0) {
        [self.uiDataStructuralConfigList addObject:@{@"title":@"积分抵扣：", @"textColor":@"323232", @"subTextColor":@"49C7F5",  @"valueKey":@"cost_credits", @"extValue4Front":@"-¥",
                                                     @"subTextAlignment":@(NSTextAlignmentRight), kCellTypeKey:kCellTypeOfNormalContent,}];
    }
    if (costPrefer.floatValue>0) {
        [self.uiDataStructuralConfigList addObject:@{@"title":@"优惠券抵扣：", @"textColor":@"323232", @"subTextColor":@"49C7F5",  @"valueKey":@"cost_prefer", @"extValue4Front":@"-¥",
                                                     @"subTextAlignment":@(NSTextAlignmentRight), kCellTypeKey:kCellTypeOfNormalContent,}];
    }
    
    NSString *totalMaterialCount = [NSString stringWithFormat:@"实付款:"];
    
    NSString *materialPrice = [SupportingClass verifyAndConvertDataToString:self.contentDetail[@"real_pay"]];
    if (!materialPrice) materialPrice = @"0.00";
    NSString *totalMaterialPrice = [NSString stringWithFormat:@"¥%@", materialPrice];
    [self.uiDataStructuralConfigList
     addObject:@{kFristValue:totalMaterialCount, kSecondValue:totalMaterialPrice, @"textColor":@"F8AF30",
                 kCellTypeKey:kCellTypeOfPriceContent,  }];
    
    
    if (self.orderClearanceType==CDZOrderPaymentClearanceTypeOfUserMember) {
        [self.uiDataStructuralConfigList
         addObjectsFromArray:@[@{kCellTypeKey:kCellTypeOfSpace, @"height":@11},
                               @{@"title":@"订单号：", @"textColor":@"909090", @"valueKey":@"order_no", kCellTypeKey:kCellTypeOfNormalContent},
                               @{@"title":@"下单时间：", @"textColor":@"909090", @"valueKey":@"add_time", kCellTypeKey:kCellTypeOfNormalContent},
                               @{@"title":@"支付方式：", @"textColor":@"909090", @"valueKey":@"pay_type", kCellTypeKey:kCellTypeOfNormalContent},@{kCellTypeKey:kCellTypeOfSpace, @"height":@11},]];
    }else {
        [self.uiDataStructuralConfigList
         addObjectsFromArray:@[@{kCellTypeKey:kCellTypeOfSpace, @"height":@11},
                               @{@"title":@"订单号：", @"textColor":@"909090", @"valueKey":@"order_no", kCellTypeKey:kCellTypeOfNormalContent},
                               @{@"title":@"下单时间：", @"textColor":@"909090", @"valueKey":@"add_time", kCellTypeKey:kCellTypeOfNormalContent},
                               @{@"title":@"支付时间：", @"textColor":@"909090", @"valueKey":@"add_time", kCellTypeKey:kCellTypeOfNormalContent},
                               @{@"title":@"收货时间：", @"textColor":@"909090", @"valueKey":@"recept_time", kCellTypeKey:kCellTypeOfNormalContent},
                               @{@"title":@"支付方式：", @"textColor":@"909090", @"valueKey":@"pay_type", kCellTypeKey:kCellTypeOfNormalContent},@{kCellTypeKey:kCellTypeOfSpace, @"height":@11},]];
    }
    [self.tableView reloadData];
    
}

- (void)showHideProductionList {
    self.hideProductListInfo = !self.hideProductListInfo;
    [self updateMainConfigList];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *detail = self.uiDataStructuralConfigList[indexPath.row];
    NSString *ident = detail[kCellTypeKey];
    if ([ident isEqualToString:kCellTypeOfSpace]) {
        //        CGFloat spaceHeight = [detail[@"height"] floatValue];
        MaintenanceDetailsSixCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellTypeOfSpace forIndexPath:indexPath];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        return cell;
    }
    
    if ([ident isEqualToString:kCellTypeOfTitle]) {
        NSString *mainColorStr = detail[@"textColor"];
        if (!mainColorStr) mainColorStr = @"323232";
        //        UIColor *mainColor = [UIColor colorWithHexString:mainColorStr];
        NSString *title = detail[@"title"];
        MaintenanceDetailsOneCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellTypeOfTitle forIndexPath:indexPath];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        cell.titleLabel.text=title;
        cell.selectImageView.hidden=YES;
        if ([cell.productShowHideBtn actionsForTarget:self forControlEvent:UIControlEventTouchUpInside].count==0) {
            [cell.productShowHideBtn addTarget:self action:@selector(showHideProductionList) forControlEvents:UIControlEventTouchUpInside];
        }
        cell.productShowHideBtn.hidden=YES;
        if (detail[@"hideProductInfo"]) {
            @weakify(cell);
            [UIView performWithoutAnimation:^{
                @strongify(cell);
                BOOL hideProductInfo = [detail[@"hideProductInfo"] boolValue];
                cell.productShowHideBtn.hidden = NO;
                cell.productShowHideBtn.selected = hideProductInfo;
            }];
            
        }
        return cell;
    }
    
    if ([ident isEqualToString:kCellTypeOfNormalContent]) {
        NSString *mainColorStr = detail[@"textColor"];
        if (!mainColorStr) mainColorStr = @"323232";
        UIColor *mainColor = [UIColor colorWithHexString:mainColorStr];
        UIColor *subTextColor = mainColor;
        if (detail[@"subTextColor"]&&![detail[@"subTextColor"] isEqualToString:@""]) {
            subTextColor = [UIColor colorWithHexString:detail[@"subTextColor"]];
        }
        
        
        NSString *title = detail[@"title"];
        NSString *valueKey = detail[@"valueKey"];
        NSString *valueStr = [SupportingClass verifyAndConvertDataToString:self.contentDetail[valueKey]];
        if (!valueStr||[valueStr isEqualToString:@""]||[valueStr isContainsString:@"无-"]) valueStr = @"暂无";
        if (detail[@"extValue4Front"]&&![valueStr isEqualToString:@"暂无"]) {
            valueStr = [detail[@"extValue4Front"] stringByAppendingString:valueStr];
        }
        
        if (detail[@"extValue4Back"]&&![valueStr isEqualToString:@"暂无"]) {
            valueStr = [valueStr stringByAppendingString:detail[@"extValue4Back"]];
        }
        
        MaintenanceDetailsTwoCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellTypeOfNormalContent forIndexPath:indexPath];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        cell.rightLabel.textAlignment = NSTextAlignmentLeft;
        if (detail[@"subTextAlignment"]) {
            cell.rightLabel.textAlignment = [detail[@"subTextAlignment"] integerValue];
        }
        cell.leftLabel.textColor = mainColor;
        cell.rightLabel.textColor = subTextColor;
        cell.leftLabel.text=title;
        cell.rightLabel.text=valueStr;
        return cell;
    }
    
    
    if ([ident isEqualToString:kCellTypeOfPriceContent]) {
        NSString *mainColorStr = detail[@"textColor"];
        if (!mainColorStr) mainColorStr = @"323232";
        UIColor *mainColor = [UIColor colorWithHexString:mainColorStr];
        NSString *fristValue = detail[kFristValue];
        NSString *secondValue = detail[kSecondValue];
        MaintenanceDetailsFourCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellTypeOfPriceContent forIndexPath:indexPath];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        cell.leftLabel.text=fristValue;
        cell.rightLabel.text=secondValue;
        return cell;
    }
    if ([ident isEqualToString:kCellTypeOfCommodityInformation]) {
        NSString *mainColorStr = detail[@"textColor"];
        if (!mainColorStr) mainColorStr = @"323232";
        UIColor *mainColor = [UIColor colorWithHexString:mainColorStr];
        NSString *fristValue = detail[kFristValue];
        NSString *secondValue = detail[kSecondValue];
        NSString *thirdValue = detail[kThirdValue];
        NSString *fourValue = detail[kFourValue];
        NSString *stateName = detail[@"stateName"];
        CommodityInformationCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellTypeOfCommodityInformation forIndexPath:indexPath];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        NSString *imgURL = fristValue;
        if ([imgURL containsString:@"http"]) {
            [cell.commodityImageView sd_setImageWithURL:[NSURL URLWithString:imgURL] placeholderImage:[ImageHandler getDefaultWhiteLogo]];
        }
        cell.isLastCell = [detail[@"isLastCell"] boolValue];
        cell.commodityNameLabel.text=secondValue;
        cell.numberLabel.text=thirdValue;
        cell.priceLabel.text=fourValue;
        [cell.commodityButton.layer setCornerRadius:3.0];
        [cell.commodityButton.layer setMasksToBounds:YES];
        cell.commodityButton.tag=indexPath.row;
        cell.commodityButton.hidden=YES;
        [cell.commodityButton setTitle:@"申请售后" forState:UIControlStateNormal];
        if ([stateName isEqualToString:@"订单完成"]&&![secondValue isContainsString:@"会员年费"]){
            cell.commodityButton.hidden=NO;
            [cell.commodityButton setTitle:@"申请售后" forState:UIControlStateNormal];
        }
        
        if (![stateName isEqualToString:@"退款中"]&&![stateName isEqualToString:@"退款完成"]&&
            ![stateName isEqualToString:@"未付款"]&&![stateName isEqualToString:@"交易关闭"]&&
            ![stateName isEqualToString:@"派送中"]&&![stateName isEqualToString:@"待安装"]&&
            ![stateName isEqualToString:@"已到店"]&&![stateName isEqualToString:@"已付款"]&&
            ![stateName isEqualToString:@"订单取消"]&&![stateName isEqualToString:@"货到付款"]) {
            cell.commodityButton.hidden=NO;
            [cell.commodityButton setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:1.0f withColor:CDZColorOfLightGray withBroderOffset:nil];
            [cell.commodityButton addTarget:self action:@selector(commodityButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            
        }
        
        return cell;
    }
    if ([ident isEqualToString:kCellTypeOfTimeCostInformation]) {
        NSString *mainColorStr = detail[@"textColor"];
        if (!mainColorStr) mainColorStr = @"323232";
        UIColor *mainColor = [UIColor colorWithHexString:mainColorStr];
        NSString *fristValue = detail[kFristValue];
        NSString *secondValue = detail[kSecondValue];
        NSString *thirdValue = detail[kThirdValue];
        NSString *fourValue = detail[kFourValue];
        TimeCostInformationCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellTypeOfTimeCostInformation forIndexPath:indexPath];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        NSString *imgURL = fristValue;
        if ([imgURL containsString:@"http"]) {
            [cell.headImageView sd_setImageWithURL:[NSURL URLWithString:imgURL] placeholderImage:[ImageHandler getDefaultWhiteLogo]];
        }
        cell.nameLabel.text=secondValue;
        cell.numberLabel.text=thirdValue;
        cell.priceLabel.text=fourValue;
        
        
        
        return cell;
    }
    
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.uiDataStructuralConfigList.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *detail = self.uiDataStructuralConfigList[indexPath.row];
    NSString *ident = detail[kCellTypeKey];
    if ([ident isEqualToString:kCellTypeOfCommodityInformation]) {
        NSString *productID = detail[@"productID"];
        if ([productID isContainsString:@"PD"]) {
            [self getPartsDetailWithPartsID:productID];
        }else {
            [self pushToSpecPartItemDetailViewWithPartsID:productID];
        }
    }
}

- (void)commodityButtonClick:(UIButton *)button {
    NSDictionary *detail = self.uiDataStructuralConfigList[button.tag];
    NSString *productID = detail[@"productID"];
    NSString *stateName = detail[@"stateName"];
    
    ApplyRefundVC *vc = [ApplyRefundVC new];
    vc.orderID = self.orderID;
    vc.productID = productID;
    vc.stateName = stateName;
    UINavigationController *nav = (UINavigationController *)UIApplication.sharedApplication.keyWindow.rootViewController;
    [nav.visibleViewController setDefaultNavBackButtonWithoutTitle];
    [nav pushViewController:vc animated:YES];
    if (!vc.successBlock) {
        @weakify(self);
        vc.successBlock = ^() {
            @strongify(self);
            if (self.applySuccessBlock) {
                self.applySuccessBlock();
            }
        };
    }
    
    
}

- (void)pushToSpecPartItemDetailViewWithPartsID:(NSString *)partsID {
    @autoreleasepool {
        BaseNavigationController *nav = (BaseNavigationController *)UIApplication.sharedApplication.keyWindow.rootViewController;
        SpecAutosPartsDetailVC *vc = [SpecAutosPartsDetailVC new];
        vc.specProductID = partsID;
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(28.224610, 112.893959);
        vc.coordinate = coordinate;
        [nav.visibleViewController setDefaultNavBackButtonWithoutTitle];
        [nav pushViewController:vc animated:YES];
    }
}

- (void)pushPartItemDetailViewWithItemDetail:(id)detail {
    if (!detail||![detail isKindOfClass:[NSDictionary class]]) {
        return;
    }
    @autoreleasepool {
        BaseNavigationController *nav = (BaseNavigationController *)UIApplication.sharedApplication.keyWindow.rootViewController;
        PartsDetailVC *vc = [PartsDetailVC new];
        vc.itemDetail = detail;
        [nav.visibleViewController setDefaultNavBackButtonWithoutTitle];
        [nav pushViewController:vc animated:YES];
    }
}
///* 配件详情 */
- (void)getPartsDetailWithPartsID:(NSString *)partsID {
    [ProgressHUDHandler showHUD];
    [[APIsConnection shareConnection] theSelfMaintenanceAPIsGetItemDetailWithWithAccessToken:vGetUserToken productID:partsID success:^(NSURLSessionDataTask *operation, id responseObject) {
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        if(errorCode!=0){
            [ProgressHUDHandler dismissHUD];
            [SupportingClass showAlertViewWithTitle:@"error" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                
            }];
            return;
        }
        [ProgressHUDHandler dismissHUDWithCompletion:^{
            [self pushPartItemDetailViewWithItemDetail:responseObject[CDZKeyOfResultKey]];
        }];
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

@end
