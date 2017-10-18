//
//  RepairManagementUIConfigModel.m
//  cdzer
//
//  Created by KEns0nLau on 8/27/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#define kCellTypeKey @"type"
#define kFristValue @"fristValue"
#define kSecondValue @"secondValue"
#define kThirdValue @"thirdValue"
#define kSpecActionOfArrayToStr @"arrayToStr"
#define kSelectionIdentID @"selectionIdentID"
#define kActiveSelection @"activeSelection"
#define kSubDependencyID @"subDependencyID"
#define kDependencyID @"dependencyID"
#define kExpanding @"expanding"

#import "MaintenanceDetailsOneCell.h"
#import "MaintenanceDetailsTwoCell.h"
#import "MaintenanceDetailsThreeCell.h"
#import "MaintenanceDetailsFourCell.h"
#import "MaintenanceDetailsSixCell.h"
#import "RepairManagementUIConfigModel.h"


@interface RepairManagementUIConfigModel ()
//原始配置列表
@property (nonatomic, strong) NSMutableArray <NSDictionary *> *uiDataStructuralConfigList;
//展开用的配置列表
@property (nonatomic, strong) NSMutableArray <NSDictionary *> *expandionConfigList;

@property (nonatomic, strong) NSMutableSet *selectedItemSet;


@end

@implementation RepairManagementUIConfigModel

- (instancetype)init {
    if (self=[super init]) {
        self.selectedItemSet = [NSMutableSet set];
        self.uiDataStructuralConfigList = [NSMutableArray array];
        self.expandionConfigList = [NSMutableArray array];
        self.processID = 0;
    }
    return self;
}

- (NSString *)selectedItemsString {
    @autoreleasepool {
        
        NSString *selectedItemsString = @"";
        NSMutableArray *selectedItemsList = [NSMutableArray array];
        NSMutableArray *tmpSelectedItemSet = [self.selectedItemSet.allObjects mutableCopy];
        [self.uiDataStructuralConfigList enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull detail, NSUInteger idx, BOOL * _Nonnull stop) {
            if (tmpSelectedItemSet.count==0) {
                *stop = YES;
            }else {
                NSString *type = detail[kCellTypeKey];
                NSString *identID = detail[kSelectionIdentID];
                if ([type isEqualToString:kCellTypeOfDetailContent]&&identID) {
                    if ([tmpSelectedItemSet containsObject:identID]) {
                        [selectedItemsList addObject:detail[kFristValue]];
                        [tmpSelectedItemSet removeObject:identID];
                    }
                }
            }
        }];
        selectedItemsString = [selectedItemsList componentsJoinedByString:@"-"];
        return selectedItemsString;
    }
}

- (void)setTableView:(UITableView *)tableView {
    _tableView = tableView;
        [tableView registerNib:[UINib nibWithNibName:@"MaintenanceDetailsOneCell" bundle:nil] forCellReuseIdentifier:kCellTypeOfTitle];
    [tableView registerNib:[UINib nibWithNibName:@"MaintenanceDetailsTwoCell" bundle:nil] forCellReuseIdentifier:kCellTypeOfNormalContent];
    [tableView registerNib:[UINib nibWithNibName:@"MaintenanceDetailsThreeCell" bundle:nil] forCellReuseIdentifier:kCellTypeOfDetailContent];
    [tableView registerNib:[UINib nibWithNibName:@"MaintenanceDetailsFourCell" bundle:nil] forCellReuseIdentifier:kCellTypeOfPriceContent];
    [tableView registerNib:[UINib nibWithNibName:@"MaintenanceDetailsSixCell" bundle:nil] forCellReuseIdentifier:kCellTypeOfSpace];
    tableView.allowsSelection = YES; 
}

- (void)setContentDetail:(NSDictionary *)contentDetail {
    _contentDetail = contentDetail;
    [self updateMainConfigList];
}

- (void)updateMainConfigList {
    [self.uiDataStructuralConfigList removeAllObjects];
    [self.expandionConfigList removeAllObjects];
    [self.selectedItemSet removeAllObjects];
    if (!self.contentDetail||self.contentDetail==0) {
        return;
    }
    
    if (self.currentStatusType==CDZMaintenanceStatusTypeOfAppointment) {
        NSArray *config = @[@{kCellTypeKey:kCellTypeOfSpace, @"height":@11},
                            
                            @{@"title":@"预约信息", @"textColor":@"323232", kExpanding:@YES,
                              kCellTypeKey:kCellTypeOfTitle, kDependencyID:@1},
                            
                            @{@"title":@"预约人：", @"textColor":@"323232", @"valueKey":@"contact_name",
                              kCellTypeKey:kCellTypeOfNormalContent, kSubDependencyID:@1},
                            @{@"title":@"预约手机：", @"textColor":@"323232", @"valueKey":@"contact_tel",
                              kCellTypeKey:kCellTypeOfNormalContent, kSubDependencyID:@1},
                            @{@"title":@"预约时间：", @"textColor":@"323232", @"valueKey":@"add_time",
                              kCellTypeKey:kCellTypeOfNormalContent, kSubDependencyID:@1},
                            @{@"title":@"预约技师：", @"textColor":@"323232", @"valueKey":@"technician_name",
                              kCellTypeKey:kCellTypeOfNormalContent, kSubDependencyID:@1},
                            @{@"title":@"服从调配：", @"textColor":@"323232", @"valueKey":@"ischange",
                              kCellTypeKey:kCellTypeOfNormalContent, kSubDependencyID:@1},
                            @{@"title":@"预约项目：", @"textColor":@"323232", @"specAction":kSpecActionOfArrayToStr,
                              @"specActionValueKey":@"name", @"valueKey":@"service_info",
                              kCellTypeKey:kCellTypeOfNormalContent, kSubDependencyID:@1},
                            
                            @{kCellTypeKey:kCellTypeOfSpace, @"height":@11},
                            @{@"title":@"车辆信息", @"textColor":@"323232", kExpanding:@YES,
                              kCellTypeKey:kCellTypeOfTitle, kDependencyID:@2},
                            @{@"title":@"汽车品牌：", @"textColor":@"323232", @"valueKey":@"brand_name",
                              kCellTypeKey:kCellTypeOfNormalContent, kSubDependencyID:@2},
                            @{@"title":@"汽车商：", @"textColor":@"323232", @"valueKey":@"factory_name",
                              kCellTypeKey:kCellTypeOfNormalContent, kSubDependencyID:@2},
                            @{@"title":@"汽车系列：", @"textColor":@"323232", @"valueKey":@"fct_name",
                              kCellTypeKey:kCellTypeOfNormalContent, kSubDependencyID:@2},
                            @{@"title":@"汽车型号：", @"textColor":@"323232", @"valueKey":@"speci_name",
                              kCellTypeKey:kCellTypeOfNormalContent, kSubDependencyID:@2},
                            
                            @{kCellTypeKey:kCellTypeOfSpace, @"height":@11},
                            @{@"title":@"订单号：", @"textColor":@"909090", @"valueKey":@"order_id", kCellTypeKey:kCellTypeOfNormalContent},
                            @{@"title":@"下单时间：", @"textColor":@"909090", @"valueKey":@"create_time", kCellTypeKey:kCellTypeOfNormalContent},
                            @{@"title":@"下单账号：", @"textColor":@"909090", @"valueKey":@"user_name", kCellTypeKey:kCellTypeOfNormalContent},];
        [self.uiDataStructuralConfigList addObjectsFromArray:config];
        
    }else if (self.currentStatusType==CDZMaintenanceStatusTypeOfDiagnosis&&
              (self.processID.integerValue==2||self.processID.integerValue==3)) {
        NSArray *config = @[@{kCellTypeKey:kCellTypeOfSpace, @"height":@11},
                            @{@"title":@"接待信息：", @"textColor":@"323232", kExpanding:@YES,
                              kCellTypeKey:kCellTypeOfTitle, kDependencyID:@1},
                            @{@"title":@"车主名称：", @"textColor":@"323232", @"valueKey":@"contact_name",
                              kCellTypeKey:kCellTypeOfNormalContent, kSubDependencyID:@1},
                            @{@"title":@"联系电话：", @"textColor":@"323232", @"valueKey":@"contact_tel",
                              kCellTypeKey:kCellTypeOfNormalContent, kSubDependencyID:@1},
                            
                            @{@"title":@"汽车品牌：", @"textColor":@"323232", @"valueKey":@"brand_name",
                              kCellTypeKey:kCellTypeOfNormalContent, kSubDependencyID:@1},
                            @{@"title":@"汽车商：", @"textColor":@"323232", @"valueKey":@"factory_name",
                              kCellTypeKey:kCellTypeOfNormalContent, kSubDependencyID:@1},
                            @{@"title":@"汽车系列：", @"textColor":@"323232", @"valueKey":@"fct_name",
                              kCellTypeKey:kCellTypeOfNormalContent, kSubDependencyID:@1},
                            @{@"title":@"汽车型号：", @"textColor":@"323232", @"valueKey":@"speci_name",
                              kCellTypeKey:kCellTypeOfNormalContent, kSubDependencyID:@1},
                            
                            @{@"title":@"汽车颜色：", @"textColor":@"323232", @"valueKey":@"color",
                              kCellTypeKey:kCellTypeOfNormalContent, kSubDependencyID:@1},
                            @{@"title":@"汽车外观：", @"textColor":@"323232", @"valueKey":@"face",
                              kCellTypeKey:kCellTypeOfNormalContent, kSubDependencyID:@1},
                            @{@"title":@"车架号：", @"textColor":@"323232", @"valueKey":@"frame_no",
                              kCellTypeKey:kCellTypeOfNormalContent, kSubDependencyID:@1},
                            @{@"title":@"发动机号：", @"textColor":@"323232", @"valueKey":@"engine_code",
                              kCellTypeKey:kCellTypeOfNormalContent, kSubDependencyID:@1},
                            @{@"title":@"里程数：", @"textColor":@"323232", @"valueKey":@"mileage", @"extValue4Back":@"KM",
                              kCellTypeKey:kCellTypeOfNormalContent, kSubDependencyID:@1},
                            @{@"title":@"保险到期：", @"textColor":@"323232", @"valueKey":@"insure_time",
                              kCellTypeKey:kCellTypeOfNormalContent, kSubDependencyID:@1},
                            @{@"title":@"油量：", @"textColor":@"323232", @"valueKey":@"oil",
                              kCellTypeKey:kCellTypeOfNormalContent, kSubDependencyID:@1},
                            
                            @{@"title":@"维修项目：", @"textColor":@"323232", @"specAction":kSpecActionOfArrayToStr,
                              @"specActionValueKey":@"name", @"valueKey":@"service_info",
                              kCellTypeKey:kCellTypeOfNormalContent, kSubDependencyID:@1},
                            @{@"title":@"维修技师：", @"textColor":@"323232", @"valueKey":@"technician_name",
                              kCellTypeKey:kCellTypeOfNormalContent, kSubDependencyID:@1},
                            @{@"title":@"账号：", @"textColor":@"323232", @"valueKey":@"user_name",
                              kCellTypeKey:kCellTypeOfNormalContent, kSubDependencyID:@1},
                            
                            @{kCellTypeKey:kCellTypeOfSpace, @"height":@11},
                            @{@"title":@"订单号：", @"textColor":@"909090", @"valueKey":@"order_id", kCellTypeKey:kCellTypeOfNormalContent},
                            @{@"title":@"下单时间：", @"textColor":@"909090", @"valueKey":@"create_time", kCellTypeKey:kCellTypeOfNormalContent},
                            @{@"title":@"预约时间：", @"textColor":@"909090", @"valueKey":@"add_time", kCellTypeKey:kCellTypeOfNormalContent},
                            @{@"title":@"接待时间：", @"textColor":@"909090", @"valueKey":@"recept_time", kCellTypeKey:kCellTypeOfNormalContent},
                            @{@"title":@"下单账号：", @"textColor":@"909090", @"valueKey":@"user_name", kCellTypeKey:kCellTypeOfNormalContent},];
        [self.uiDataStructuralConfigList addObjectsFromArray:config];
        
    }else {
        [self.uiDataStructuralConfigList
         addObjectsFromArray:@[@{kCellTypeKey:kCellTypeOfSpace, @"height":@11},
                               @{@"title":@"接待信息", @"textColor":@"323232", kExpanding:@YES,
                                 kCellTypeKey:kCellTypeOfTitle, kDependencyID:@1},
                               @{@"title":@"车主名称：", @"textColor":@"323232", @"valueKey":@"contact_name",
                                 kCellTypeKey:kCellTypeOfNormalContent, kSubDependencyID:@1},
                               @{@"title":@"联系电话：", @"textColor":@"323232", @"valueKey":@"contact_tel",
                                 kCellTypeKey:kCellTypeOfNormalContent, kSubDependencyID:@1},
                               
                               @{@"title":@"汽车品牌：", @"textColor":@"323232", @"valueKey":@"brand_name",
                                 kCellTypeKey:kCellTypeOfNormalContent, kSubDependencyID:@1},
                               @{@"title":@"汽车商：", @"textColor":@"323232", @"valueKey":@"factory_name",
                                 kCellTypeKey:kCellTypeOfNormalContent, kSubDependencyID:@1},
                               @{@"title":@"汽车系列：", @"textColor":@"323232", @"valueKey":@"fct_name",
                                 kCellTypeKey:kCellTypeOfNormalContent, kSubDependencyID:@1},
                               @{@"title":@"汽车型号：", @"textColor":@"323232", @"valueKey":@"speci_name",
                                 kCellTypeKey:kCellTypeOfNormalContent, kSubDependencyID:@1},
                               
                               @{@"title":@"汽车颜色：", @"textColor":@"323232", @"valueKey":@"color",
                                 kCellTypeKey:kCellTypeOfNormalContent, kSubDependencyID:@1},
                               @{@"title":@"汽车外观：", @"textColor":@"323232", @"valueKey":@"face",
                                 kCellTypeKey:kCellTypeOfNormalContent, kSubDependencyID:@1},
                               @{@"title":@"车架号：", @"textColor":@"323232", @"valueKey":@"frame_no",
                                 kCellTypeKey:kCellTypeOfNormalContent, kSubDependencyID:@1},
                               @{@"title":@"发动机号：", @"textColor":@"323232", @"valueKey":@"engine_code",
                                 kCellTypeKey:kCellTypeOfNormalContent, kSubDependencyID:@1},
                               @{@"title":@"里程数：", @"textColor":@"323232", @"valueKey":@"mileage", @"extValue4Back":@"KM",
                                 kCellTypeKey:kCellTypeOfNormalContent, kSubDependencyID:@1},
                               @{@"title":@"保险到期：", @"textColor":@"323232", @"valueKey":@"insure_time",
                                 kCellTypeKey:kCellTypeOfNormalContent, kSubDependencyID:@1},
                               @{@"title":@"油量：", @"textColor":@"323232", @"valueKey":@"oil",
                                 kCellTypeKey:kCellTypeOfNormalContent, kSubDependencyID:@1},
                               @{@"title":@"维修项目：", @"textColor":@"323232", @"specAction":kSpecActionOfArrayToStr,
                                 @"specActionValueKey":@"name", @"valueKey":@"service_info",
                                 kCellTypeKey:kCellTypeOfNormalContent, kSubDependencyID:@1},
                               @{@"title":@"维修技师：", @"textColor":@"323232", @"valueKey":@"technician_name",
                                 kCellTypeKey:kCellTypeOfNormalContent, kSubDependencyID:@1},
                               @{@"title":@"账号：", @"textColor":@"323232", @"valueKey":@"user_name",
                                 kCellTypeKey:kCellTypeOfNormalContent, kSubDependencyID:@1}]];
        
        //诊断项目配置
        NSArray *repairItems = self.contentDetail[@"repair_item"];
        if (repairItems&&[repairItems isKindOfClass:NSArray.class]){
            [self.uiDataStructuralConfigList
             addObjectsFromArray:@[@{kCellTypeKey:kCellTypeOfSpace, @"height":@11},
                                   @{@"title":@"诊断项目", @"textColor":@"323232", kExpanding:@YES,
                                     kCellTypeKey:kCellTypeOfTitle, kDependencyID:@2},
                                   @{kFristValue:@"维修项目", kSecondValue:@"维修工时", kThirdValue:@"工时费用", @"textColor":@"646464",
                                     kCellTypeKey:kCellTypeOfDetailContent, kActiveSelection:@NO, kSubDependencyID:@2}]];
            @weakify(self);
            [repairItems enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull detail, NSUInteger idx, BOOL * _Nonnull stop) {
                @strongify(self);
                NSString *name = detail[@"name"];
                NSString *hour = [SupportingClass verifyAndConvertDataToString:detail[@"hour"]];
                hour = [NSString stringWithFormat:@"x%@", hour];
                NSString *price = [SupportingClass verifyAndConvertDataToString:detail[@"price"]];
                price = [NSString stringWithFormat:@"¥%0.2f", price.floatValue];
                BOOL activeSelection = (self.processID.integerValue==4);
                
                NSString *identID = [NSString stringWithFormat:@"repairItems%02d", idx];
                [self.uiDataStructuralConfigList
                 addObject:@{kFristValue:name, kSecondValue:hour, kThirdValue:price, @"textColor":@"323232",
                             kCellTypeKey:kCellTypeOfDetailContent, kActiveSelection:@(activeSelection),
                             kSelectionIdentID:identID, kSubDependencyID:@2}];
                if (activeSelection) {
                    [self.selectedItemSet addObject:identID];
                }
            }];
            
            
            NSString *workingHour = [SupportingClass verifyAndConvertDataToString:self.contentDetail[@"work_hour"]];
            if (!workingHour) workingHour = @"0";
            NSString *totalWorkingHour = [NSString stringWithFormat:@"共%@工时 合计：", workingHour];
            
            NSString *workingHourPrice = [SupportingClass verifyAndConvertDataToString:self.contentDetail[@"work_price"]];
            if (!workingHourPrice) workingHourPrice = @"0.00";
            NSString *totalWorkingHourPrice = [NSString stringWithFormat:@"¥%@", workingHourPrice];
            [self.uiDataStructuralConfigList
             addObject:@{kFristValue:totalWorkingHour, kSecondValue:totalWorkingHourPrice, @"textColor":@"646464",
                         kCellTypeKey:kCellTypeOfPriceContent, kActiveSelection:@NO, kSubDependencyID:@2}];
        }
        
        //维修材料配置
        NSArray *repairMaterial = self.contentDetail[@"repair_materials"];
        if (repairMaterial&&[repairMaterial isKindOfClass:NSArray.class]){
            [self.uiDataStructuralConfigList
             addObjectsFromArray:@[@{kCellTypeKey:kCellTypeOfSpace, @"height":@11},
                                   @{@"title":@"维修材料", @"textColor":@"323232", kExpanding:@YES,
                                     kCellTypeKey:kCellTypeOfTitle, kDependencyID:@3},
                                   @{kFristValue:@"配件名称", kSecondValue:@"数量", kThirdValue:@"单价", @"textColor":@"646464",
                                     kCellTypeKey:kCellTypeOfDetailContent, kActiveSelection:@NO, kSubDependencyID:@3}]];
            @weakify(self);
            [repairMaterial enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull detail, NSUInteger idx, BOOL * _Nonnull stop) {
                @strongify(self);
                NSString *name = detail[@"name"];
                NSString *numCount = [SupportingClass verifyAndConvertDataToString:detail[@"num"]];
                numCount = [NSString stringWithFormat:@"x%@", numCount];
                NSString *price = [SupportingClass verifyAndConvertDataToString:detail[@"price"]];
                price = [NSString stringWithFormat:@"¥%0.2f", price.floatValue];
                [self.uiDataStructuralConfigList
                 addObject:@{kFristValue:name, kSecondValue:numCount, kThirdValue:price, @"textColor":@"323232",
                             kCellTypeKey:kCellTypeOfDetailContent, kActiveSelection:@NO, kSubDependencyID:@3}];
            }];
            
            
            NSString *materialCount = [SupportingClass verifyAndConvertDataToString:self.contentDetail[@"product_num"]];
            if (!materialCount) materialCount = @"0";
            NSString *totalMaterialCount = [NSString stringWithFormat:@"共%d件材料 合计：", materialCount.intValue];
            
            NSString *materialPrice = [SupportingClass verifyAndConvertDataToString:self.contentDetail[@"product_price"]];
            if (!materialPrice) materialPrice = @"0.00";
            NSString *totalMaterialPrice = [NSString stringWithFormat:@"¥%@", materialPrice];
            [self.uiDataStructuralConfigList
             addObject:@{kFristValue:totalMaterialCount, kSecondValue:totalMaterialPrice, @"textColor":@"646464",
                         kCellTypeKey:kCellTypeOfPriceContent, kActiveSelection:@NO, kSubDependencyID:@3}];
        }
        //尾部配置
        BOOL wasPaidStatus = (self.processID.integerValue==9||self.processID.integerValue==10);
        [self.uiDataStructuralConfigList
         addObjectsFromArray:@[@{kCellTypeKey:kCellTypeOfSpace, @"height":@11},
                               @{@"title":@"价格详情", @"textColor":@"323232", kExpanding:@YES,
                                 kCellTypeKey:kCellTypeOfTitle, kDependencyID:@4},
                               @{@"title":(wasPaidStatus?@"管理费":@"预估管理费"), @"textColor":@"323232",@"subTextColor":@"F8AF30", @"valueKey":@"manager_fee", @"extValue4Front":@"¥", @"subTextAlignment":@(NSTextAlignmentRight), kCellTypeKey:kCellTypeOfNormalContent, kSubDependencyID:@4},
                               
                               @{@"title":@"诊断费：", @"textColor":@"323232", @"subTextColor":@"F8AF30", @"valueKey":@"check_fee", @"extValue4Front":@"¥", @"subTextAlignment":@(NSTextAlignmentRight), kCellTypeKey:kCellTypeOfNormalContent, kSubDependencyID:@4},
                               @{@"title":@"总工时费：", @"textColor":@"323232", @"subTextColor":@"F8AF30", @"valueKey":@"work_price",
                                  @"extValue4Front":@"¥", @"subTextAlignment":@(NSTextAlignmentRight), kCellTypeKey:kCellTypeOfNormalContent, kSubDependencyID:@4},
                               
                               @{@"title":(wasPaidStatus?@"材料费：":@"预计材料费："), @"textColor":@"323232", @"subTextColor":@"F8AF30", @"valueKey":@"product_price", @"extValue4Front":@"¥",
                                 @"subTextAlignment":@(NSTextAlignmentRight), kCellTypeKey:kCellTypeOfNormalContent, kSubDependencyID:@4},
                               @{@"title":(wasPaidStatus?@"优惠金额：":@"预计优惠金额："), @"textColor":@"323232", @"subTextColor":@"49C7F5",  @"valueKey":@"discount_fee", @"extValue4Front":@"-¥",
                                 @"subTextAlignment":@(NSTextAlignmentRight), kCellTypeKey:kCellTypeOfNormalContent, kSubDependencyID:@4},]];
        
        if (wasPaidStatus&&self.contentDetail[@"cre_discount"]) {
            [self.uiDataStructuralConfigList addObject:
             @{@"title":@"积分抵用", @"textColor":@"323232", @"subTextColor":@"49C7F5", @"valueKey":@"cre_discount", @"extValue4Front":@"-¥", @"subTextAlignment":@(NSTextAlignmentRight), kCellTypeKey:kCellTypeOfNormalContent, kSubDependencyID:@4}];
        }
        
        [self.uiDataStructuralConfigList
         addObjectsFromArray:@[@{kCellTypeKey:kCellTypeOfSpace, @"height":@11},
                               @{@"title":@"订单号：", @"textColor":@"909090", @"valueKey":@"order_id", kCellTypeKey:kCellTypeOfNormalContent},
                               @{@"title":@"下单时间：", @"textColor":@"909090", @"valueKey":@"create_time", kCellTypeKey:kCellTypeOfNormalContent},
                               @{@"title":@"预约时间：", @"textColor":@"909090", @"valueKey":@"add_time", kCellTypeKey:kCellTypeOfNormalContent},
                               @{@"title":@"接待时间：", @"textColor":@"909090", @"valueKey":@"recept_time", kCellTypeKey:kCellTypeOfNormalContent},
                               @{kCellTypeKey:kCellTypeOfSpace, @"height":@11},]];
        
        if (wasPaidStatus&&self.contentDetail[@"pay_type"]){
            [self.uiDataStructuralConfigList addObject:@{@"title":@"支付方式：", @"textColor":@"909090", @"valueKey":@"pay_type", kCellTypeKey:kCellTypeOfNormalContent}];
        }
        [self.uiDataStructuralConfigList addObject:@{@"title":@"下单账号：", @"textColor":@"909090", @"valueKey":@"user_name", kCellTypeKey:kCellTypeOfNormalContent}];
        
        [self.uiDataStructuralConfigList addObject:@{kCellTypeKey:kCellTypeOfSpace, @"height":@11}];
    }
    [self updateDispalyConfigList];
}

- (void)updateDispalyConfigList {
    [self.expandionConfigList removeAllObjects];
    @weakify(self);
    __block NSInteger dependencyID = 1;
    __block BOOL expanding = YES;
    [self.uiDataStructuralConfigList enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull detail, NSUInteger idx, BOOL * _Nonnull stop) {
        @strongify(self);
        NSString *ident = detail[kCellTypeKey];
        NSNumber *subDependencyID = detail[kSubDependencyID];
        if ([ident isEqualToString:kCellTypeOfTitle]) {
            dependencyID = [detail[kDependencyID] integerValue];
            expanding = [detail[kExpanding] boolValue];
        }
        
        if (!subDependencyID||
            (subDependencyID.integerValue==dependencyID&&expanding)) {
            [self.expandionConfigList addObject:detail];
        }
    }];
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    [self.selectedItemSet enumerateObjectsUsingBlock:^(NSString * _Nonnull selectionIdentID, BOOL * _Nonnull stop) {
        @strongify(self);
        [self.uiDataStructuralConfigList enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull detail, NSUInteger row, BOOL * _Nonnull sourceStop) {
            NSString *typeIdent = detail[kCellTypeKey];
            NSString *theSelectionIdentID = detail[kSelectionIdentID];
            if ([typeIdent isEqualToString:kCellTypeOfDetailContent]&&
                detail[kActiveSelection]&&[detail[kActiveSelection] boolValue]
                &&[selectionIdentID isEqualToString:theSelectionIdentID]) {
                [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
                *sourceStop = YES;
            }
        }];
    }];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *detail = self.expandionConfigList[indexPath.row];
    NSString *ident = detail[kCellTypeKey];
    if ([ident isEqualToString:kCellTypeOfSpace]) {
        CGFloat spaceHeight = [detail[@"height"] floatValue];
        MaintenanceDetailsSixCell *cell = [tableView dequeueReusableCellWithIdentifier:ident forIndexPath:indexPath];
        return cell;
    }
    
    if ([ident isEqualToString:kCellTypeOfTitle]) {
        NSString *mainColorStr = detail[@"textColor"];
        if (!mainColorStr) mainColorStr = @"323232";
        UIColor *mainColor = [UIColor colorWithHexString:mainColorStr];
        NSString *title = detail[@"title"];
        BOOL isExpanded = [detail[kExpanding] boolValue];
        MaintenanceDetailsOneCell *cell = [tableView dequeueReusableCellWithIdentifier:ident forIndexPath:indexPath];
        cell.titleLabel.text=title;
        cell.selectImageView.highlighted=isExpanded;
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
        if (detail[@"specAction"]&&[detail[@"specAction"] isEqualToString:kSpecActionOfArrayToStr]) {
            NSArray *stringArray = self.contentDetail[valueKey];
            if (detail[@"specActionValueKey"]&&![detail[@"specActionValueKey"] isEqualToString:@""]) {
                stringArray = [stringArray valueForKey:detail[@"specActionValueKey"]];
            }
            valueStr = [stringArray componentsJoinedByString:@" "];
        }
        if (!valueStr||[valueStr isEqualToString:@""]) valueStr = @"暂无";
        if (detail[@"extValue4Front"]&&![valueStr isEqualToString:@"暂无"]) {
            valueStr = [detail[@"extValue4Front"] stringByAppendingString:valueStr];
        }
        
        if (detail[@"extValue4Back"]&&![valueStr isEqualToString:@"暂无"]) {
            valueStr = [valueStr stringByAppendingString:detail[@"extValue4Back"]];
        }
        
        MaintenanceDetailsTwoCell *cell = [tableView dequeueReusableCellWithIdentifier:ident forIndexPath:indexPath];
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
    
    if ([ident isEqualToString:kCellTypeOfDetailContent]) {
        NSString *mainColorStr = detail[@"textColor"];
        if (!mainColorStr) mainColorStr = @"323232";
        UIColor *mainColor = [UIColor colorWithHexString:mainColorStr];
        NSString *fristValue = detail[kFristValue];
        NSString *secondValue = detail[kSecondValue];
        NSString *thirdValue = detail[kThirdValue];
        BOOL isActiveSelection = (detail[kActiveSelection]&&[detail[kActiveSelection] boolValue]);
        NSString *selectionIdentID = detail[kSelectionIdentID];
        MaintenanceDetailsThreeCell *cell = [tableView dequeueReusableCellWithIdentifier:ident forIndexPath:indexPath];
        cell.fristLabel.text=fristValue;
        cell.secondLabel.text=secondValue;
        cell.thirdLabel.text=thirdValue;
        cell.fristLabel.textColor=mainColor;
        cell.secondLabel.textColor=mainColor;
        cell.thirdLabel.textColor=mainColor;
        cell.selectImageView.hidden = !isActiveSelection;
        if (selectionIdentID&&isActiveSelection) {
            BOOL wasSelected = [self.selectedItemSet containsObject:selectionIdentID];
            if (wasSelected) {
                [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            }else {
                [tableView deselectRowAtIndexPath:indexPath animated:NO];
            }
        }
        
        return cell;
    }
    
    if ([ident isEqualToString:kCellTypeOfPriceContent]) {
        NSString *mainColorStr = detail[@"textColor"];
        if (!mainColorStr) mainColorStr = @"323232";
        UIColor *mainColor = [UIColor colorWithHexString:mainColorStr];
        NSString *fristValue = detail[kFristValue];
        NSString *secondValue = detail[kSecondValue];
        MaintenanceDetailsFourCell *cell = [tableView dequeueReusableCellWithIdentifier:ident forIndexPath:indexPath];
        cell.leftLabel.text=fristValue;
        cell.rightLabel.text=secondValue;
        return cell;
    }
    
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.expandionConfigList.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *detail = self.expandionConfigList[indexPath.row];
    NSString *typeIdent = detail[kCellTypeKey];
    if ([typeIdent isEqualToString:kCellTypeOfDetailContent]&&
        detail[kActiveSelection]&&[detail[kActiveSelection] boolValue]) {
        NSString *selectionIdentID = detail[kSelectionIdentID];
        [self.selectedItemSet addObject:selectionIdentID];
        return;
    }
    if ([typeIdent isEqualToString:kCellTypeOfTitle]) {
        NSString *title = detail[@"title"];
        BOOL wasExpanded = [detail[kExpanding] boolValue];
        NSMutableDictionary *willChangedDetail = [detail mutableCopy];
        willChangedDetail[kExpanding] = @(!wasExpanded);
        __block NSInteger foundIdx = -1;
        [self.uiDataStructuralConfigList enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull oldDetail, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([oldDetail[@"title"] isEqualToString:title]&&[oldDetail[kCellTypeKey] isEqualToString:kCellTypeOfTitle]) {
                foundIdx = idx;
                *stop = YES;
            }
        }];
        if (foundIdx>-1) {
            [self.uiDataStructuralConfigList replaceObjectAtIndex:foundIdx withObject:willChangedDetail];
            [self updateDispalyConfigList];
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    tableView.tableFooterView=[UIView new];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (indexPath.row+1>self.expandionConfigList.count) {
        return;
    }
    NSDictionary *detail = self.expandionConfigList[indexPath.row];
    NSString *typeIdent = detail[kCellTypeKey];
    NSArray *repairItems = self.contentDetail[@"repair_item"];
    if ([typeIdent isEqualToString:kCellTypeOfDetailContent]&&[detail[kActiveSelection] boolValue]&&repairItems.count>1) {
        NSString *selectionIdentID = detail[kSelectionIdentID];
        [self.selectedItemSet removeObject:selectionIdentID];
    }else {
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }

}

@end
