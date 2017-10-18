//
//  MaintenancePaymentUIConfigModel.m
//  cdzer
//
//  Created by 车队长 on 16/9/3.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#define kCellTypeKey @"type"
#define kFristValue @"fristValue"
#define kSecondValue @"secondValue"
#define kThirdValue @"thirdValue"

#define kExpanding @"expanding"

#import "MaintenanceDetailsOneCell.h"
#import "MaintenanceDetailsTwoCell.h"
#import "MaintenanceDetailsThreeCell.h"
#import "MaintenanceDetailsFourCell.h"
#import "MaintenanceDetailsSixCell.h"
#import "MaintenanceDetailsFiveCell.h"


#import "MaintenancePaymentUIConfigModel.h"

#import "MyCouponVC.h"

@interface MaintenancePaymentUIConfigModel ()<UITextFieldDelegate>
{
    int secondsCountDown; //倒计时总时长
    NSTimer *countDownTimer;
}
//原始配置列表
@property (nonatomic, strong) NSMutableArray <NSDictionary *> *uiDataStructuralConfigList;

@property (nonatomic) BOOL shouldStatementRequest;


@property(nonatomic,assign)BOOL daoshu;
@end

@implementation MaintenancePaymentUIConfigModel

- (instancetype)init {
    if (self=[super init]) {
        self.uiDataStructuralConfigList = [NSMutableArray array];
    }
    return self;
}
- (void)dealloc
{
    NSLog(@"Passing Dealloc At %@",NSStringFromClass([self class]));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)setCouponContent:(NSString *)couponContent {
    _couponContent = couponContent;
    [self.tableView reloadData];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tongzhi:) name:@"wxzfTongZhi" object:nil];

}

- (void)setTableView:(UITableView *)tableView {
    _tableView = tableView;
    [tableView registerNib:[UINib nibWithNibName:@"MaintenanceDetailsOneCell" bundle:nil] forCellReuseIdentifier:kCellTypeOfTitle];
    [tableView registerNib:[UINib nibWithNibName:@"MaintenanceDetailsTwoCell" bundle:nil] forCellReuseIdentifier:kCellTypeOfNormalContent];
    [tableView registerNib:[UINib nibWithNibName:@"MaintenanceDetailsThreeCell" bundle:nil] forCellReuseIdentifier:kCellTypeOfDetailContent];
    [tableView registerNib:[UINib nibWithNibName:@"MaintenanceDetailsFourCell" bundle:nil] forCellReuseIdentifier:kCellTypeOfPriceContent];
    [tableView registerNib:[UINib nibWithNibName:@"MaintenanceDetailsSixCell" bundle:nil] forCellReuseIdentifier:kCellTypeOfSpace];
    
    [tableView registerNib:[UINib nibWithNibName:@"MaintenanceDetailsFiveCell" bundle:nil] forCellReuseIdentifier:kCellTypeOfqweContent];

    }
- (void)setContentDetail:(NSDictionary *)contentDetail {
    _contentDetail = contentDetail;
    [self updateMainConfigList];
}
- (void)updateMainConfigList {
    [self.uiDataStructuralConfigList removeAllObjects];
    if (!self.contentDetail||self.contentDetail==0) {
        return;
    }
    
    //诊断项目配置
    NSArray *repairItems = self.contentDetail[@"repair_item"];
    if (repairItems&&[repairItems isKindOfClass:NSArray.class]){
        [self.uiDataStructuralConfigList
         addObjectsFromArray:@[@{@"title":@"诊断项目", @"textColor":@"323232",
                                 kCellTypeKey:kCellTypeOfTitle,},
                               @{kFristValue:@"维修项目", kSecondValue:@"维修工时", kThirdValue:@"工时费用", @"textColor":@"646464",
                                 kCellTypeKey:kCellTypeOfDetailContent}]];
        @weakify(self);
        [repairItems enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull detail, NSUInteger idx, BOOL * _Nonnull stop) {
            @strongify(self);
            NSString *name = detail[@"name"];
            NSString *hour = [SupportingClass verifyAndConvertDataToString:detail[@"hour"]];
            hour = [NSString stringWithFormat:@"x%@", hour];
            NSString *price = [SupportingClass verifyAndConvertDataToString:detail[@"price"]];
            price = [NSString stringWithFormat:@"¥%0.2f", price.floatValue];
            
            [self.uiDataStructuralConfigList
             addObject:@{kFristValue:name, kSecondValue:hour, kThirdValue:price, @"textColor":@"323232",
                         kCellTypeKey:kCellTypeOfDetailContent}];
        }];
        
        
        NSString *workingHour = [SupportingClass verifyAndConvertDataToString:self.contentDetail[@"work_hour"]];
        if (!workingHour) workingHour = @"0";
        NSString *totalWorkingHour = [NSString stringWithFormat:@"共%@工时 合计：", workingHour];
        
        NSString *workingHourPrice = [SupportingClass verifyAndConvertDataToString:self.contentDetail[@"work_price"]];
        if (!workingHourPrice) workingHourPrice = @"0.00";
        NSString *totalWorkingHourPrice = [NSString stringWithFormat:@"¥%@", workingHourPrice];
        [self.uiDataStructuralConfigList
         addObject:@{kFristValue:totalWorkingHour, kSecondValue:totalWorkingHourPrice, @"textColor":@"646464",
                     kCellTypeKey:kCellTypeOfPriceContent}];
    }
    
    //维修材料配置
    NSArray *repairMaterial = self.contentDetail[@"repair_materials"];
    if (repairMaterial&&[repairMaterial isKindOfClass:NSArray.class]){
        [self.uiDataStructuralConfigList
         addObjectsFromArray:@[@{kCellTypeKey:kCellTypeOfSpace, @"height":@11},
                               @{@"title":@"维修材料", @"textColor":@"323232", kExpanding:@YES,
                                 kCellTypeKey:kCellTypeOfTitle},
                               @{kFristValue:@"配件名称", kSecondValue:@"数量", kThirdValue:@"单价", @"textColor":@"646464",
                                 kCellTypeKey:kCellTypeOfDetailContent}]];
        @weakify(self);
        [repairMaterial enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull detail, NSUInteger idx, BOOL * _Nonnull stop) {
            @strongify(self);
            NSString *name = detail[@"name"];
            NSString *numCount = [SupportingClass verifyAndConvertDataToString:detail[@"hour"]];
            numCount = [NSString stringWithFormat:@"x%@", numCount];
            NSString *price = [SupportingClass verifyAndConvertDataToString:detail[@"price"]];
            price = [NSString stringWithFormat:@"¥%0.2f", price.floatValue];
            [self.uiDataStructuralConfigList
             addObject:@{kFristValue:name, kSecondValue:numCount, kThirdValue:price, @"textColor":@"323232",
                         kCellTypeKey:kCellTypeOfDetailContent}];
        }];
        
        
        NSString *materialCount = [SupportingClass verifyAndConvertDataToString:self.contentDetail[@"product_num"]];
        if (!materialCount) materialCount = @"0";
        NSString *totalMaterialCount = [NSString stringWithFormat:@"共%d件材料 合计：", materialCount.intValue];
        
        NSString *materialPrice = [SupportingClass verifyAndConvertDataToString:self.contentDetail[@"product_price"]];
        if (!materialPrice) materialPrice = @"0.00";
        NSString *totalMaterialPrice = [NSString stringWithFormat:@"¥%@", materialPrice];
        [self.uiDataStructuralConfigList
         addObject:@{kFristValue:totalMaterialCount, kSecondValue:totalMaterialPrice, @"textColor":@"646464",
                     kCellTypeKey:kCellTypeOfPriceContent}];
    }
    [self.uiDataStructuralConfigList
     addObjectsFromArray:@[@{kCellTypeKey:kCellTypeOfqweContent, @"height":@278}]];
    
    [self.uiDataStructuralConfigList
     addObjectsFromArray:@[@{kCellTypeKey:kCellTypeOfSpace, @"height":@11},
                           @{@"title":@"管理费", @"textColor":@"323232",@"subTextColor":@"F8AF30", @"valueKey":@"manager_fee", @"extValue4Front":@"¥", @"subTextAlignment":@(NSTextAlignmentRight), kCellTypeKey:kCellTypeOfNormalContent},
                           
                           @{@"title":@"诊断费：", @"textColor":@"323232", @"subTextColor":@"F8AF30", @"valueKey":@"check_fee", @"extValue4Front":@"¥", @"subTextAlignment":@(NSTextAlignmentRight), kCellTypeKey:kCellTypeOfNormalContent,},
                           @{@"title":@"总工时费：", @"textColor":@"323232", @"subTextColor":@"F8AF30", @"valueKey":@"work_price",
                             @"extValue4Front":@"¥", @"subTextAlignment":@(NSTextAlignmentRight), kCellTypeKey:kCellTypeOfNormalContent,},
                           
                           @{@"title":@"材料费：", @"textColor":@"323232", @"subTextColor":@"F8AF30", @"valueKey":@"product_price", @"extValue4Front":@"¥",
                             @"subTextAlignment":@(NSTextAlignmentRight), kCellTypeKey:kCellTypeOfNormalContent,},]];
                           
    
    
//    [self.uiDataStructuralConfigList addObject:@{@"title":@"积分抵用：", @"textColor":@"323232", @"subTextColor":@"49C7F5", @"valueKey":@"cre_discount", @"extValue4Front":@"-¥",
//                                                 @"subTextAlignment":@(NSTextAlignmentRight), kCellTypeKey:kCellTypeOfNormalContent,}];
    
    [self.uiDataStructuralConfigList addObject:@{@"title":@"预计优惠金额：", @"textColor":@"323232", @"subTextColor":@"49C7F5", @"valueKey":@"discount_fee", @"extValue4Front":@"-¥",
                                                 @"subTextAlignment":@(NSTextAlignmentRight), kCellTypeKey:kCellTypeOfNormalContent,}];
    [self.uiDataStructuralConfigList addObject:@{kCellTypeKey:kCellTypeOfSpace, @"height":@11}];
    
    [self.tableView reloadData];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *detail = self.uiDataStructuralConfigList[indexPath.row];
    NSString *ident = detail[kCellTypeKey];
    if ([ident isEqualToString:kCellTypeOfSpace]) {
        CGFloat spaceHeight = [detail[@"height"] floatValue];
        MaintenanceDetailsSixCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellTypeOfSpace forIndexPath:indexPath];
        return cell;
    }
    
    if ([ident isEqualToString:kCellTypeOfTitle]) {
        NSString *mainColorStr = detail[@"textColor"];
        if (!mainColorStr) mainColorStr = @"323232";
//        UIColor *mainColor = [UIColor colorWithHexString:mainColorStr];
        NSString *title = detail[@"title"];
        MaintenanceDetailsOneCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellTypeOfTitle forIndexPath:indexPath];
        cell.titleLabel.text=title;
        cell.selectImageView.hidden=YES;;
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
        if (!valueStr||[valueStr isEqualToString:@""]) valueStr = @"暂无";
        if (detail[@"extValue4Front"]&&![valueStr isEqualToString:@"暂无"]) {
            valueStr = [detail[@"extValue4Front"] stringByAppendingString:valueStr];
        }
        
        if (detail[@"extValue4Back"]&&![valueStr isEqualToString:@"暂无"]) {
            valueStr = [valueStr stringByAppendingString:detail[@"extValue4Back"]];
        }
        
        MaintenanceDetailsTwoCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellTypeOfNormalContent forIndexPath:indexPath];
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
        MaintenanceDetailsThreeCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellTypeOfDetailContent forIndexPath:indexPath];
        cell.fristLabel.text=fristValue;
        cell.secondLabel.text=secondValue;
        cell.thirdLabel.text=thirdValue;
        cell.fristLabel.textColor=mainColor;
        cell.secondLabel.textColor=mainColor;
        cell.thirdLabel.textColor=mainColor;
        cell.selectImageView.hidden = YES;

        
        return cell;
    }
    
    if ([ident isEqualToString:kCellTypeOfPriceContent]) {
        NSString *mainColorStr = detail[@"textColor"];
        if (!mainColorStr) mainColorStr = @"323232";
        UIColor *mainColor = [UIColor colorWithHexString:mainColorStr];
        NSString *fristValue = detail[kFristValue];
        NSString *secondValue = detail[kSecondValue];
        MaintenanceDetailsFourCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellTypeOfPriceContent forIndexPath:indexPath];
        cell.leftLabel.text=fristValue;
        cell.rightLabel.text=secondValue;
        return cell;
    }
    if ([ident isEqualToString:kCellTypeOfqweContent]) {
        MaintenanceDetailsFiveCell *cell=[tableView dequeueReusableCellWithIdentifier:kCellTypeOfqweContent forIndexPath:indexPath];
        cell.tag=1;
        [cell.bgView1 setViewBorderWithRectBorder:UIRectBorderTop|UIRectBorderBottom borderSize:0.25 withColor:nil withBroderOffset:nil];
        [cell.bgView2 setViewBorderWithRectBorder:UIRectBorderTop|UIRectBorderBottom borderSize:0.25 withColor:nil withBroderOffset:nil];
        [cell.bgView3 setViewBorderWithRectBorder:UIRectBorderTop|UIRectBorderBottom borderSize:0.25 withColor:nil withBroderOffset:nil];
        [cell.bgView4 setViewBorderWithRectBorder:UIRectBorderTop|UIRectBorderBottom borderSize:0.25 withColor:nil withBroderOffset:nil];
        [cell.bgView5 setViewBorderWithRectBorder:UIRectBorderTop|UIRectBorderBottom borderSize:0.25 withColor:nil withBroderOffset:nil];
        [cell.bgView6 setViewBorderWithRectBorder:UIRectBorderTop|UIRectBorderBottom borderSize:0.25 withColor:nil withBroderOffset:nil];
        
        cell.geVerificationCodeButton.layer.masksToBounds=YES;
        cell.geVerificationCodeButton.layer.cornerRadius=3.0;
        cell.invoiceTextField.delegate=self;
        cell.VerificationCodeTextFiled.delegate=self;
        cell.invoiceTextField.tag=2;
        cell.VerificationCodeTextFiled.tag=3;
        
        if (cell.invoiceTextField.text.length==0) {
            cell.invoiceTextField.text=@"";
            self.invoiceTextStr=@"";
        }
        cell.totalIntegralLabel.text=[NSString stringWithFormat:@"(总积分:%@)",self.contentDetail[@"credits"]];
        self.integralStr=self.contentDetail[@"valiable_cre"];
        cell.integralLabel.text=self.integralStr;
        
        
        if ([self.discountStr containsString:@"使用优惠券"]) {
            [cell.discountButton setTitle:@"使用优惠券" forState:UIControlStateNormal];
            }
        else{
             self.VerificationCode=@"";
             cell.VerificationCodeTextFiled.text=@"";
            if (self.discountStr.length==0) {
                if (self.VerificationCode.length!=0) {
                    [cell.discountButton setTitle:@"使用优惠券" forState:UIControlStateNormal];
                }
                
            }else
            [cell.discountButton setTitle:[NSString stringWithFormat:@"￥%@",self.discountStr] forState:UIControlStateNormal];
            }
        
         
        [cell.discountButton addTarget:self action:@selector(discountButtonClick) forControlEvents:UIControlEventTouchUpInside];
        
        [cell.geVerificationCodeButton addTarget:self action:@selector(geVerificationCodeButtonClick) forControlEvents:UIControlEventTouchUpInside];
        if (self.daoshu==YES) {
            //设置倒计时显示的时间
            [cell.geVerificationCodeButton setTitle:[NSString stringWithFormat:@"%d秒",secondsCountDown] forState:UIControlStateNormal];
            cell.geVerificationCodeButton.backgroundColor=CDZColorOfLightGray;
        }
        
         [cell.invoiceSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
         [cell.integralSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
        self.isInvoice=cell.invoiceSwitch.isOn;
        self.isIntegral=cell.integralSwitch.isOn;
        if (cell.invoiceSwitch.isOn==YES) {
             cell.layoutConstraintInvoice.constant=0;
            cell.bgView2.hidden=NO;
        }else{
         cell.layoutConstraintInvoice.constant=-43;
            cell.bgView2.hidden=YES;
        }
        if (cell.integralSwitch.isOn==YES) {
            cell.layoutConstraintIntegral.constant=0;
            cell.bgView5.hidden=NO;
            cell.layoutConstraintVerificationCode.constant=0;
            cell.bgView6.hidden=NO;
            cell.VerificationCodeBottomLayoutConstraint.constant=0;
        }else{
            cell.layoutConstraintIntegral.constant=-43;
            cell.bgView5.hidden=YES;
            cell.layoutConstraintIntegral.constant=-43;
            cell.bgView6.hidden=YES;
            cell.VerificationCodeBottomLayoutConstraint.constant=-46;
        }
        return cell;
    }

    return nil;
}
- (void)tongzhi:(NSNotification *)text{
    self.discountStr=text.userInfo[@"content"];
    self.discountID=text.userInfo[@"id"];
    
    NSLog(@"－－－－－ 接收到通知------");
    [self.tableView reloadData];
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.uiDataStructuralConfigList.count;
}

- (void)switchAction:(UISwitch*)sender
{
    
    [self.tableView reloadData];
}
- (void)discountButtonClick
{
    NSMutableArray*preferInfo=self.contentDetail[@"prefer_info"];
    if (preferInfo.count>0) {
        if (self.pushingBlock) {
            self.pushingBlock();
        }
    }else{
        [SupportingClass showAlertViewWithTitle:@"" message:@"暂无可用优惠券"
                                isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil
                  clickedButtonAtIndexWithBlock:nil];
        
    }

    
    
}
- (void)geVerificationCodeButtonClick
{
    //设置倒计时总时长
    secondsCountDown = 60;//60秒倒计时
    //开始倒计时
    countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeFireMethod) userInfo:nil repeats:YES]; //启动倒计时后会每秒钟调用一次方法 timeFireMethod
    
    //设置倒计时显示的时间
    
    [self getVerificationCode];
   }
- (void)timeFireMethod{
    //倒计时-1
    secondsCountDown--;
    //修改倒计时标签现实内容
    MaintenanceDetailsFiveCell*cell=(MaintenanceDetailsFiveCell*)[self.tableView viewWithTag:1];
    [cell.geVerificationCodeButton setTitle:[NSString stringWithFormat:@"%d秒",secondsCountDown] forState:UIControlStateNormal];
    cell.geVerificationCodeButton.userInteractionEnabled = NO;
    //当倒计时到0时，做需要的操作，比如验证码过期不能提交
    if(secondsCountDown==0){
        [cell.geVerificationCodeButton setTitle:@"获取验证码" forState:UIControlStateNormal];
        cell.geVerificationCodeButton.userInteractionEnabled = YES;
        cell.geVerificationCodeButton.backgroundColor=CDZColorOfDefaultColor;
        [countDownTimer invalidate];
    }
}
- (void)getVerificationCode
{
    @weakify(self);
    [UserBehaviorHandler.shareInstance userRequestCreditValidCodeWithSuccessBlock:^(NSString *code){
        [SupportingClass showAlertViewWithTitle:@"alert_remind" message:@"验证码请求成功"
                                isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil
                  clickedButtonAtIndexWithBlock:nil];
        self.daoshu=YES;
        [self.tableView reloadData];
    } failure:^(NSString *errorMessage, NSError *error) {
        
        [SupportingClass showAlertViewWithTitle:@"alert_remind" message:errorMessage
                                isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil
                  clickedButtonAtIndexWithBlock:nil];
        @strongify(self);
    }];

}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    UITextField * invoiceTextField=(UITextField*)[self.tableView viewWithTag:2];
    if (invoiceTextField) {
        self.invoiceTextStr=textField.text;
    }
    UITextField * VerificationCodeTextFiled=(UITextField*)[self.tableView viewWithTag:3];
    if (VerificationCodeTextFiled) {
        self.VerificationCode=textField.text;
        self.discountStr=@"使用优惠券";
    }
    if (self.VerificationCode.length!=0) {
        self.discountStr=@"使用优惠券";

    }
    [self.tableView reloadData];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    
    return YES;
    
}
@end
