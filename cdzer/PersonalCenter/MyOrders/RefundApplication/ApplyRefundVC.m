//
//  ApplyRefundVC.m
//  cdzer
//
//  Created by 车队长 on 16/9/6.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "ApplyRefundVC.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "RefundReasonVC.h"
#import "RefundAgreementVC.h"
#import "QuantityControlView.h"
#import "MyOrdersVC.h"
#import "UIView+LayoutConstraintHelper.h"

@interface ApplyRefundVC ()<UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIView *warningView;

@property (weak, nonatomic) IBOutlet UIButton *warningButton;

@property (weak, nonatomic) IBOutlet UIImageView *productImageView;

@property (weak, nonatomic) IBOutlet UILabel *productNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *productPriceLabel;

@property (weak, nonatomic) IBOutlet UILabel *refundAmountLabel;//退款金额

@property (weak, nonatomic) IBOutlet UIControl *refundReasonControl;//退款原因

@property (weak, nonatomic) IBOutlet UITextView *refundReasonTextView;

@property (weak, nonatomic) IBOutlet UIButton *selectButton;

@property (weak, nonatomic) IBOutlet UIButton *submitApplicationButton;

@property (strong, nonatomic) IBOutlet QuantityControlView *changeNumView;

@property (weak, nonatomic) IBOutlet UIButton *agreementButton;

@property (nonatomic, strong) NSDictionary *resultDic;

@property (weak, nonatomic) IBOutlet UILabel *reasonString;//退款原因

@property (nonatomic, strong) NSString *productNumStr;//申请退款商品数量
@property (nonatomic, strong) NSString *refundAmount;


@property (nonatomic, strong) UIToolbar *toolBar; ///<工具条

@property (nonatomic, assign) CGRect keyboardRect; ///<键盘坐标组
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *wainingLayoutConstraint;//与信息view的衔接处


@end

@implementation ApplyRefundVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@",NSStringFromClass([self class]));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"申请退款";
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardDidShowNotification object:nil];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tongzhi:) name:@"reasonTongZhi" object:nil];
    if ([self.stateName isEqualToString:@"派送中"]||
        [self.stateName isEqualToString:@"待安装"]) {
        self.warningView.hidden = YES;
        self.wainingLayoutConstraint.constant = -27;
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!self.resultDic||self.resultDic.count==0) {
        [self applyRefund];
    }
}

- (void)viewDateUI {
    NSString *imgURL = self.resultDic[@"product_img"];
    if ([imgURL containsString:@"http"]) {
        [self.productImageView sd_setImageWithURL:[NSURL URLWithString:imgURL] placeholderImage:[ImageHandler getDefaultWhiteLogo]];
    }
    self.productNameLabel.text = self.resultDic[@"product_name"];
    self.productPriceLabel.text = [NSString stringWithFormat:@"￥%@",self.resultDic[@"product_price"]];
    self.productNumStr = [SupportingClass verifyAndConvertDataToString:self.resultDic[@"product_num"]];
    self.refundAmountLabel.text = [NSString stringWithFormat:@"￥%@",self.resultDic[@"product_price"]];
    NSString *productPrice = [SupportingClass verifyAndConvertDataToString:self.resultDic[@"product_price"]];
    self.refundAmount = [NSString stringWithFormat:@"%.2f",self.productNumStr.integerValue*productPrice.floatValue];    
    
    [self.changeNumView setValue:1 withMaxValue:self.productNumStr.integerValue];
    [self.changeNumView addTarget:self action:@selector(updateProductQuantityCount:) forControlEvents:UIControlEventValueChanged];
    
    
    [self.refundReasonControl addTarget:self action:@selector(refundReasonControlClick) forControlEvents:UIControlEventTouchUpInside];
    [self.selectButton addTarget:self action:@selector(selectButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.agreementButton addTarget:self action:@selector(agreementButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.submitApplicationButton addTarget:self action:@selector(submitApplicationButtonClick) forControlEvents:UIControlEventTouchUpInside];
    self.submitApplicationButton.layer.cornerRadius = 3.0;
    self.submitApplicationButton.layer.masksToBounds = YES;
    
    self.refundReasonTextView.delegate = self;
    self.toolBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 40)];
    self.toolBar =  [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), 40)];
    [_toolBar setBarStyle:UIBarStyleDefault];
    UIBarButtonItem *spaceButton = [[UIBarButtonItem  alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                  target:self
                                                                                  action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]initWithTitle:getLocalizationString(@"finish")
                                                                   style:UIBarButtonItemStyleDone
                                                                  target:self
                                                                  action:@selector(hiddenKeyboard)];
    NSArray *buttonsArray = [NSArray arrayWithObjects:spaceButton,doneButton,nil];
    [_toolBar setItems:buttonsArray];
    [_refundReasonTextView setInputAccessoryView:_toolBar];
}

- (void)keyboardWillShow:(NSNotification *)notifyObject {
    CGRect keyboardRect = [[notifyObject.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    if (!CGRectEqualToRect(keyboardRect, _keyboardRect)) {
        self.keyboardRect = keyboardRect;
        if ([_refundReasonTextView isFirstResponder]) {
            [self shiftScrollViewWithAnimationForTextView];
        }
    }
    
}

- (void)shiftScrollViewWithAnimationForTextView {
    UIView *theView = self.view;
    CGPoint point = CGPointZero;
    CGFloat contanierViewMaxY = CGRectGetMidY([_refundReasonTextView.superview convertRect:_refundReasonTextView.frame toView:theView]);
    CGFloat visibleContentsHeight = (CGRectGetHeight(theView.frame)-CGRectGetHeight(_keyboardRect))/2.0f;
    if (contanierViewMaxY > visibleContentsHeight) {
        CGFloat offsetY = contanierViewMaxY-visibleContentsHeight;
        point.y = offsetY;
    }
    [self.scrollView setContentOffset:point animated:NO];
    self.scrollView.scrollEnabled = NO;
}

- (void)hiddenKeyboard {
    [_refundReasonTextView resignFirstResponder];
    self.keyboardRect = CGRectZero;
    CGPoint point = CGPointZero;
    [self.scrollView setContentOffset:point animated:NO];
    self.scrollView.scrollEnabled = YES;
}

- (void)updateProductQuantityCount:(QuantityControlView *)countView {
    @autoreleasepool {
        self.productNumStr = [NSString stringWithFormat:@"%d",countView.value];
        NSString *productPrice = self.resultDic[@"product_price"];
        self.refundAmount = [NSString stringWithFormat:@"%.2f",self.productNumStr.integerValue*productPrice.floatValue];
        self.refundAmountLabel.text = [NSString stringWithFormat:@"￥%@",_refundAmount];
    }
}

- (void)tongzhi:(NSNotification *)text{
    self.reasonString.text = text.userInfo[@"reasonName"];
    NSLog(@"%@  ",self.reasonString.text);
    NSLog(@"－－－－－ 接收到通知------");
    
}

- (void)agreementButtonClick {
    RefundAgreementVC *vc = [RefundAgreementVC new];
    [self.navigationController pushViewController:vc animated:YES];
    [self setDefaultNavBackButtonWithoutTitle];
}

- (void)refundReasonControlClick {
    NSArray *listInfoArr = self.resultDic[@"list_info"];
    RefundReasonVC*vc = [RefundReasonVC new];
    vc.listArr = listInfoArr;
    [self.navigationController pushViewController:vc animated:YES];
    [self setDefaultNavBackButtonWithoutTitle];
}

- (void)selectButtonClick:(UIButton*)button {
    self.selectButton.selected = !self.selectButton.selected;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:@"最多150字"]) {
        textView.text = @"";
    }
    else{
        self.refundReasonTextView.text = textView.text;
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:@"最多150字"]) {
        self.refundReasonTextView.text = @"";
    }
    else{
        self.refundReasonTextView.text = textView.text;
    }
}
//关闭提示框
- (IBAction)wainingButtonClick:(id)sender {
    self.warningView.hidden = YES;
    self.wainingLayoutConstraint.constant = -27;
}

- (void)submitApplicationButtonClick {
    
    [SupportingClass showAlertViewWithTitle:nil message:@"您要退款吗？" isShowImmediate:YES cancelButtonTitle:@"取消" otherButtonTitles:@"确定" clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
        if (btnIdx.integerValue>0) {
            if ([self.reasonString.text isEqualToString:@"请选择退款原因"]) {
                [SupportingClass showAlertViewWithTitle:@"" message:@"请选择退款原因！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                }];
                return;
            }

//            if ([self.refundReasonTextView.text isEqualToString:@"最多150字"]) {
//                [SupportingClass showAlertViewWithTitle:@"" message:@"请填写退款描述！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
//                }];
//                return;
//            }
            
            if (!self.selectButton.selected) {
                [SupportingClass showAlertViewWithTitle:nil message:@"你必须同意《车队长退款协议》才能使用退款服务" isShowImmediate:YES cancelButtonTitle:nil otherButtonTitles:nil clickedButtonAtIndexWithBlock:nil];
                return;
            }
            
            if (!self.accessToken) {
                [self handleMissingTokenAction];
                return;
            }
            [ProgressHUDHandler showHUD];
            [[APIsConnection shareConnection] personalCenterAPIsPostSubApplyRefundByorderWithAccessToken:self.accessToken keyID:self.orderID productID:self.resultDic[@"product_id"] refundNum:self.productNumStr refundPrice:self.refundAmount refundReason:self.reasonString.text refundDes:self.refundReasonTextView.text  success:^(NSURLSessionDataTask *operation, id responseObject) {
                
                [self requestResultHandle:operation responseObject:responseObject withError:nil];
            } failure:^(NSURLSessionDataTask *operation, NSError *error) {
                [self requestResultHandle:operation responseObject:nil withError:error];
            }];
            
        }
    }];
}

- (void)applyRefund {
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    [ProgressHUDHandler showHUD];
    [[APIsConnection shareConnection] personalCenterAPIsPostApplyRefundByorderWithAccessToken:self.accessToken keyID:self.orderID productID:self.productID success:^(NSURLSessionDataTask *operation, id responseObject) {
        operation.userInfo = @{@"ident":@"applyRefund"};
        [self requestResultHandle:operation responseObject:responseObject withError:nil];
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        operation.userInfo = @{@"ident":@"applyRefund"};
        [self requestResultHandle:operation responseObject:nil withError:error];
    }];
    
}

- (void)requestResultHandle:(NSURLSessionDataTask *)operation responseObject:(id)responseObject withError:(NSError *)error {
    
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
        
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        self.resultDic = [responseObject objectForKey:CDZKeyOfResultKey];
        NSLog(@"%@---%@",message,operation);
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        
        if (errorCode!= 0) {
            [ProgressHUDHandler dismissHUD];
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
            return;
        }
        if (operation.userInfo&&[operation.userInfo[@"ident"] isEqualToString:@"applyRefund"]) {
            [self viewDateUI];
            [ProgressHUDHandler dismissHUD];
        }else{
            
            [ProgressHUDHandler showSuccessWithStatus:message onView:nil completion:^{
                
            }];
            if (self.successBlock) {
                self.successBlock(self.idxID);
            }
            [self.navigationController popViewControllerAnimated:YES];
            
        }
    }
    
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

//expr ((UIView *)0x20c05b10).backgroundColor = [UIColor redColor]

@end
