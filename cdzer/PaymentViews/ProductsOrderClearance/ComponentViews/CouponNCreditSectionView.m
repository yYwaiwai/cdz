//
//  CouponNCreditSectionView.m
//  cdzer
//
//  Created by KEns0nLau on 9/18/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "CouponNCreditSectionView.h"
#import "CouponSelectionVC.h"
#import "ValidCodeButton.h"
#import "UITextField+ShareAction.h"
#import <RegexKitLite/RegexKitLite.h>


@interface CouponNCreditSectionView () <UITextFieldDelegate>




@property (weak, nonatomic) IBOutlet UILabel *couponNameLabel;

@property (weak, nonatomic) IBOutlet UISwitch *accumulatePointActiveSwitch;

@property (weak, nonatomic) IBOutlet UILabel *totalAccumulatePointLabel;

@property (weak, nonatomic) IBOutlet UITextField *accumulatePointTF;

@property (weak, nonatomic) IBOutlet UITextField *verifyCodeTF;

@property (strong, nonatomic) IBOutlet ValidCodeButton *verifyCodeBtn;

@property (weak, nonatomic) IBOutlet UIView *apContainerView;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *apContainerViewTopConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *couponViewTopConstraint;

@property (weak, nonatomic) IBOutlet UIView *couponContainerView;

@property (weak, nonatomic) IBOutlet UIView *totalAccumulatePointView;

@property (strong, nonatomic) NSDictionary *couponDetail;

@property (strong, nonatomic) NSMutableArray *couponList;

@property (nonatomic) CGFloat apRatio;

@property (nonatomic) NSUInteger maxConsumedPoints;

@property (nonatomic, strong) NSString *repairShopName;

@end
@implementation CouponNCreditSectionView

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [[self.apContainerView viewWithTag:4] setViewBorderWithRectBorder:UIRectBorderTop borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self.apContainerView setViewBorderWithRectBorder:UIRectBorderTop borderSize:0.5 withColor:nil withBroderOffset:nil];
    [[self viewWithTag:2] setViewBorderWithRectBorder:UIRectBorderTop borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self setViewBorderWithRectBorder:UIRectBorderTop|UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    BorderOffsetObject *offset = [BorderOffsetObject new];
    offset.bottomOffset = 2;
    [self.verifyCodeTF setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    
    [self.verifyCodeBtn setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:3.0f];
}
    
- (void)awakeFromNib {
    [super awakeFromNib];
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillAppear:) name:UIKeyboardWillShowNotification object:nil];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(textFieldTextDidChange:) name:UITextFieldTextDidChangeNotification object:self.accumulatePointTF];
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.frame), 44.0f)];
    [toolbar setBarStyle:UIBarStyleDefault];
    UIBarButtonItem *spaceButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                target:self
                                                                                action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]initWithTitle:getLocalizationString(@"finish")
                                                                  style:UIBarButtonItemStyleDone
                                                                 target:self
                                                                 action:@selector(hiddenKeyboard)];
    NSArray * buttonsArray = [NSArray arrayWithObjects:spaceButton,doneButton,nil];
    [toolbar setItems:buttonsArray];
    self.verifyCodeTF.inputAccessoryView = toolbar;
    self.accumulatePointTF.inputAccessoryView = toolbar;
    self.accumulatePointTF.shouldStopPCDAction = YES;
    self.verifyCodeTF.shouldStopPCDAction = YES;
    [self.verifyCodeBtn buttonSettingWithType:VCBTypeOfOrderCreditValid];
    self.verifyCodeBtn.shouldChangBGColor = YES;
//    [self setReactiveRules];
}

- (void)setReactiveRules {
    @weakify(self);
    [RACObserve(self, verifyCodeBtn.isRequested) subscribeNext:^(NSNumber *requested) {
        @strongify(self);
        BOOL isRequested = requested.boolValue;
        self.verifyCodeTF.enabled = isRequested;
    }];
}

- (void)setConsumedPoints:(NSInteger)consumedPoints {
    _consumedPoints = consumedPoints;
}

- (void)setIsActiveAccumulatePoints:(BOOL)isActiveAccumulatePoints {
    if (isActiveAccumulatePoints) {
        self.isActiveCoupon = NO;
    }
    _isActiveAccumulatePoints = isActiveAccumulatePoints;
    [self updateConsumedPoints];
}

- (void)setIsActiveCoupon:(BOOL)isActiveCoupon {
    if (isActiveCoupon) {
        self.isActiveAccumulatePoints = NO;
    }
    _isActiveCoupon = isActiveCoupon;
    [self updateCouponInfo];
}

- (void)setTotalRemainPrice:(CGFloat)totalRemainPrice {
    _totalRemainPrice = totalRemainPrice;
}

- (NSString *)selectedCouponAmount {
    if (self.couponDetail&&self.couponDetail.count>3) {
        return [SupportingClass verifyAndConvertDataToString:self.couponDetail[@"amount"]];
    }
    return nil;
}

- (NSString *)selectedCouponID {
    if (self.couponDetail&&self.couponDetail.count>3) {
        return [SupportingClass verifyAndConvertDataToString:self.couponDetail[@"id"]];
    }
    return nil;
}

- (NSString *)selectedCouponDescription {
    if (self.couponDetail&&self.couponDetail.count>3) {
        return [SupportingClass verifyAndConvertDataToString:self.couponDetail[@"content"]];
    }
    return nil;
}

- (NSInteger)totalAccumulatePoints {
    return self.totalAccumulatePointLabel.text.integerValue;
}

- (NSString *)verifyCode {
    return self.verifyCodeTF.text;
}

- (void)updateUIData:(NSDictionary *)sourceData {
    self.repairShopName = sourceData[@"wxs_name"];
    self.apRatio = 100.f;
    CGFloat totalPrice = 0;
    NSNumber *consumedPoints = nil;
    if (self.orderClearanceType==CDZOrderPaymentClearanceTypeOfRegularParts) {
        totalPrice = [SupportingClass verifyAndConvertDataToNumber:sourceData[@"sum_price"]].floatValue;
        consumedPoints = @((NSInteger)(totalPrice*self.apRatio));
        self.totalAccumulatePointLabel.text = [SupportingClass verifyAndConvertDataToString:sourceData[@"credits"]];
    }else if (self.orderClearanceType==CDZOrderPaymentClearanceTypeOfSpecRepair) {
        totalPrice = [SupportingClass verifyAndConvertDataToNumber:sourceData[@"sum_price"]].floatValue;
        consumedPoints = [SupportingClass verifyAndConvertDataToNumber:sourceData[@"use_credit"]];
        self.totalAccumulatePointLabel.text = [SupportingClass verifyAndConvertDataToString:sourceData[@"credits"]];
    }else if (self.orderClearanceType==CDZOrderPaymentClearanceTypeOfMaintainExpress) {
        totalPrice = [SupportingClass verifyAndConvertDataToNumber:sourceData[@"sum_price"]].floatValue;
        consumedPoints = [SupportingClass verifyAndConvertDataToNumber:sourceData[@"use_credits"]];
        self.totalAccumulatePointLabel.text = [SupportingClass verifyAndConvertDataToString:sourceData[@"credits"]];
    }else if (self.orderClearanceType==CDZOrderPaymentClearanceTypeOfRepairNMaintenance) {
        totalPrice = [SupportingClass verifyAndConvertDataToNumber:sourceData[@"sum_price"]].floatValue;
        consumedPoints = [SupportingClass verifyAndConvertDataToNumber:sourceData[@"valiable_cre"]];
        self.totalAccumulatePointLabel.text = [SupportingClass verifyAndConvertDataToString:sourceData[@"credits"]];
    }
    if ([[SupportingClass verifyAndConvertDataToString:sourceData[@"credits"]] isEqualToString:@"0"]||[[SupportingClass verifyAndConvertDataToString:sourceData[@"credits"]] isEqualToString:@"0.0"]) {
        self.accumulatePointActiveSwitch.enabled=NO;
    }
    self.maxConsumedPoints = consumedPoints.integerValue;
    if (self.maxConsumedPoints>self.totalAccumulatePointLabel.text.integerValue) {
        self.maxConsumedPoints = self.totalAccumulatePointLabel.text.integerValue;
    }
    
    //判断是否展示优惠劵
    if (sourceData[@"prefer_info"]) {
        self.couponViewTopConstraint.constant = 0;
        self.couponContainerView.hidden = NO;
        if (!self.couponList) self.couponList = [@[] mutableCopy];
        [self.couponList removeAllObjects];
        [self.couponList addObjectsFromArray:sourceData[@"prefer_info"]];
        
        if (self.couponList.count>0) {
            NSArray *filter = [self.couponList valueForKey:@"mark"];
            NSMutableIndexSet *indextSet = [NSMutableIndexSet indexSet];
            [filter enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *mark = [SupportingClass verifyAndConvertDataToString:obj];
                if ([mark isEqualToString:@"0"]) {
                    [indextSet addIndex:idx];
                }
            }];
            [self.couponList removeObjectsAtIndexes:indextSet];
        }
    }else {
        self.couponViewTopConstraint.constant = -CGRectGetHeight(self.couponContainerView.frame);
        self.couponContainerView.hidden = YES;
    }
    self.accumulatePointTF.text = @"";
    self.consumedPoints = 0;
    _totalRemainPrice = 0;
    _isActiveCoupon = NO;
    _isActiveAccumulatePoints = NO;
//    [self updateCouponInfo];
}

- (IBAction)apActiveSwitch:(UISwitch *)activeSwitch {
        BOOL isOn = activeSwitch.on;
        self.isActiveAccumulatePoints = isOn;
}

- (IBAction)pushToCouponSelectionVC {
    @autoreleasepool {
        UIViewController *rootVC = UIApplication.sharedApplication.keyWindow.rootViewController;
        CouponSelectionVC *vc = [CouponSelectionVC new];
        vc.repairShopName = self.repairShopName;
        vc.couponList = [self.couponList mutableCopy];
        vc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [rootVC presentViewController:vc animated:YES completion:^{
            
        }];
        if (!vc.resultBlock) {
            @weakify(self);
            vc.resultBlock = ^(NSDictionary * couponDetail){
                @strongify(self);
                self.couponDetail = couponDetail;
            };
        }
    }
    
}

- (IBAction)showCreditRule {
    [SupportingClass showAlertViewWithTitle:@"积分使用规则" message:@"积分专属车队长平台，凡是在车队长平台消费均可使用，积分可以累积  注：100积分=1元抵扣现金（暂不支持积分兑现）" isShowImmediate:YES cancelButtonTitle:nil otherButtonTitles:nil clickedButtonAtIndexWithBlock:nil];
}

- (void)updateConsumedPoints {
    [self endEditing:YES];
    self.apContainerViewTopConstraint.constant = self.isActiveAccumulatePoints?0:-CGRectGetHeight(self.apContainerView.frame);
    self.apContainerView.hidden = !self.isActiveAccumulatePoints;
    self.verifyCodeTF.text = @"";
}

- (void)updateCouponInfo {
    if (self.isActiveCoupon) {
        self.couponNameLabel.text = self.couponDetail[@"content"];
    }else {
        self.couponNameLabel.text = [NSString stringWithFormat:@"%d张可用优惠劵", self.couponList.count];
    }
    if (self.couponList.count==0) self.couponNameLabel.text = @"暂无更多优惠劵选择";
}

- (void)setCouponDetail:(NSDictionary *)couponDetail {
    _couponDetail = couponDetail;
    self.accumulatePointActiveSwitch.on = NO;
    [self.accumulatePointActiveSwitch sendActionsForControlEvents:UIControlEventValueChanged];
    self.isActiveCoupon = (couponDetail&&couponDetail.count>0);
}

- (void)keyboardWillAppear:(NSNotification *)notiObj {
    if ([self.accumulatePointTF isFirstResponder]) {
        NSMutableDictionary *userInfo = [notiObj.userInfo mutableCopy];
        userInfo[@"tf"] = self.accumulatePointTF;
        [NSNotificationCenter.defaultCenter postNotificationName:PISCTextViewAdjustPositionNotification object:nil userInfo:userInfo];
    }
    if ([self.verifyCodeTF isFirstResponder]) {
        NSMutableDictionary *userInfo = [notiObj.userInfo mutableCopy];
        userInfo[@"tf"] = self.verifyCodeTF;
        [NSNotificationCenter.defaultCenter postNotificationName:PISCTextViewAdjustPositionNotification object:nil userInfo:userInfo];
    }
}

- (void)updateAccumulatePoint {
    self.consumedPoints = self.accumulatePointTF.text.integerValue;
    NSLog(@"%f", (CGFloat)self.consumedPoints/100);
    self.totalRemainPrice = (CGFloat)self.consumedPoints/100;
}

- (void)hiddenKeyboard {
    if (self.accumulatePointTF.isFirstResponder) [self updateAccumulatePoint];
    [self.verifyCodeTF resignFirstResponder];
    [self.accumulatePointTF resignFirstResponder];
}

- (void)textFieldTextDidChange:(NSNotification *)notiObj {
    if (self.accumulatePointTF==notiObj.object) [self updateAccumulatePoint];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField==self.accumulatePointTF) {
        if (![string isMatchedByRegex:@"^[0-9]*$"]&&![string isEqualToString:@""]) return NO;
        if (range.length==0&&range.location==0&&[string isEqualToString:@"0"]) return NO;
        NSInteger value = textField.text.integerValue;
        NSInteger cValue = [textField.text stringByReplacingCharactersInRange:range withString:string].integerValue;
        if (value>self.maxConsumedPoints||cValue>self.maxConsumedPoints) {
            textField.text = @(self.maxConsumedPoints).stringValue;
            [self updateAccumulatePoint];
            return NO;
        }
    }
    
    if (textField==self.verifyCodeTF) {
        NSUInteger length = textField.text.length;
        if (length>=6&&![string isEqualToString:@""]) {
            return NO;
        }
    }
    
    return YES;
}

@end
