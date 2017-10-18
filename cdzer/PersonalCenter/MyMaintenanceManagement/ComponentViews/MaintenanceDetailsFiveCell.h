//
//  MaintenanceDetailsFiveCell.h
//  cdzer
//
//  Created by 车队长 on 16/8/30.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MaintenanceDetailsFiveCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UISwitch *invoiceSwitch;//发票

@property (weak, nonatomic) IBOutlet UITextField *invoiceTextField;

@property (weak, nonatomic) IBOutlet UIButton *discountButton;//使用优惠券

@property (weak, nonatomic) IBOutlet UISwitch *integralSwitch;//积分

@property (weak, nonatomic) IBOutlet UILabel *totalIntegralLabel;//总积分

@property (weak, nonatomic) IBOutlet UILabel *integralLabel;//积分数目

@property (weak, nonatomic) IBOutlet UIButton *geVerificationCodeButton;//获取验证码按钮

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *layoutConstraintInvoice;//发票的

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *layoutConstraintIntegral;//积分数目de

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *layoutConstraintVerificationCode;//获取验证码de

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *VerificationCodeBottomLayoutConstraint;

@property (weak, nonatomic) IBOutlet UITextField *VerificationCodeTextFiled;

@property (weak, nonatomic) IBOutlet UIView *bgView1;

@property (weak, nonatomic) IBOutlet UIView *bgView2;

@property (weak, nonatomic) IBOutlet UIView *bgView3;

@property (weak, nonatomic) IBOutlet UIView *bgView4;

@property (weak, nonatomic) IBOutlet UIView *bgView5;

@property (weak, nonatomic) IBOutlet UIView *bgView6;



@end
