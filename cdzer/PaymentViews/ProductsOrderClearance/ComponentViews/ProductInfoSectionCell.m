//
//  ProductInfoSectionCell.m
//  cdzer
//
//  Created by KEns0nLau on 9/22/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "ProductInfoSectionCell.h"
#import "MultiProductInfoDetailVC.h"
#import "UIView+LayoutConstraintHelper.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface ProductInfoSectionTextView : UIView

@property (weak, nonatomic) IBOutlet UITextView *commentTextView;

@property (strong, nonatomic) NSArray <NSLayoutConstraint *> *constraintList;

@property (strong, nonatomic) NSLayoutConstraint *bottomConstraint;

@end

@implementation ProductInfoSectionTextView


- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
    [NSNotificationCenter.defaultCenter removeObserver:self];
//    UIWindow *keyWindow = UIApplication.sharedApplication.keyWindow;
//    [keyWindow removeConstraints:self.constraintList];
    [self removeFromSuperview];
    self.constraintList = nil;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.commentTextView.inputAccessoryView = [[UIView alloc] init];
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillAppear:) name:UIKeyboardWillShowNotification object:nil];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self setViewBorderWithRectBorder:UIRectBorderTop borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self.commentTextView setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self.commentTextView setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:3.0f];
}

- (void)keyboardWillAppear:(NSNotification *)notiObj {
    if ([self.commentTextView isFirstResponder]) {
        CGRect keyboardFrame = [notiObj.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
        @weakify(self);
        self.bottomConstraint.constant = CGRectGetHeight(keyboardFrame);
        [UIView animateWithDuration:0.25 animations:^{
            @strongify(self);
            CGRect frame = self.frame;
            frame.origin.y = CGRectGetMinY(keyboardFrame)-CGRectGetHeight(frame);
            self.frame = frame;
        }];
    }
}

- (void)showTextView {
    UIWindow *keyWindow = UIApplication.sharedApplication.keyWindow;
    if (!self.constraintList){
        self.constraintList = [self addSelfByFourMarginToSuperview:keyWindow withEdgeConstant:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f) andLayoutAttribute:LayoutHelperAttributeBottom|LayoutHelperAttributeLeading|LayoutHelperAttributeTrailing];
    }else {
        [keyWindow addSubview:self];
        [keyWindow addConstraints:self.constraintList];
    }
        
        
    if (!self.bottomConstraint) {
        @weakify(self);
        [self.constraintList enumerateObjectsUsingBlock:^(NSLayoutConstraint * _Nonnull constraint, NSUInteger idx, BOOL * _Nonnull stop) {
           @strongify(self);
            if (constraint.firstAttribute==NSLayoutAttributeBottom&&
                constraint.secondAttribute==NSLayoutAttributeBottom) {
                self.bottomConstraint = constraint;
            }
        }];
    }
    CGRect frame = self.frame;
    frame.origin.y = SCREEN_HEIGHT-CGRectGetHeight(frame);
    self.frame = frame;
    self.hidden = NO;
    NSLog(@"rfActive:%d", [self.commentTextView becomeFirstResponder]);
    
}

- (IBAction)hideTextView {
    UIWindow *keyWindow = UIApplication.sharedApplication.keyWindow;
    @weakify(self);
    [self.commentTextView resignFirstResponder];
    [UIView animateWithDuration:0.25 animations:^{
        @strongify(self);
        CGRect frame = self.frame;
        frame.origin.y = CGRectGetHeight(keyWindow.frame);
        self.frame = self.frame;
    } completion:^(BOOL finished) {
        @strongify(self);
        self.bottomConstraint.constant = -CGRectGetHeight(self.frame);
        self.hidden = YES;
        [self removeFromSuperview];
    }];
    
}

@end

@interface ProductInfoSectionCell ()<UITextFieldDelegate, UITextViewDelegate>

@property (strong, nonatomic) UIImage *titleDefaultImage;
@property (weak, nonatomic) IBOutlet UIImageView *titleArrowIndicatorView;
@property (weak, nonatomic) IBOutlet UIImageView *titleImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *productInfoMainViewTopConstraint;

@property (weak, nonatomic) IBOutlet UIView *productInfoContainerView;
@property (weak, nonatomic) IBOutlet UIImageView *productImageView;
@property (weak, nonatomic) IBOutlet UILabel *productNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *productPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *productPurchaseCountLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *productInfoViewBottomSpaceConstraint;


@property (strong, nonatomic) IBOutlet UIControl *multiProductInfoContainerView;
@property (weak, nonatomic) IBOutlet UIImageView *multiProductImageView;
@property (weak, nonatomic) IBOutlet UILabel *multiProductInfoLabel;



@property (weak, nonatomic) IBOutlet NSLayoutConstraint *expressPriceInfoTopConstaint;
@property (weak, nonatomic) IBOutlet UILabel *expressPriceInfoLabel;

@property (weak, nonatomic) IBOutlet UISwitch *invoiceSwitch;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *payeeNameViewTopConstraint;
@property (weak, nonatomic) IBOutlet UITextField *payeeNameTF;
@property (weak, nonatomic) IBOutlet UIView *payeeNameContainerView;


@property (strong, nonatomic) IBOutlet NSLayoutConstraint *userRemarkViewConstraint;
@property (weak, nonatomic) IBOutlet UIView *userRemarkView;
@property (weak, nonatomic) IBOutlet UILabel *userRemarkLabel;


@property (strong, nonatomic) IBOutlet NSLayoutConstraint *totalPriceViewTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *totalPriceLabel;
@property (weak, nonatomic) IBOutlet UIView *totalPriceContainerView;


@property (strong, nonatomic) IBOutlet ProductInfoSectionTextView *commentTextView;
@property (weak, nonatomic) PISCConfigObject *configObject;

@end

@implementation ProductInfoSectionCell

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)dismissAllKeyboard {
    [self.commentTextView hideTextView];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.titleDefaultImage = self.titleImageView.image;
    [[UINib nibWithNibName:@"ProductInfoSectionTextView" bundle:nil] instantiateWithOwner:self options:nil];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(dismissAllKeyboard) name:PISCTextViewDidEndNotification object:nil];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(textFieldTextDidChange:) name:UITextFieldTextDidChangeNotification object:self.payeeNameTF];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(textViewTextDidChange:) name:UITextViewTextDidChangeNotification object:self.commentTextView.commentTextView];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillAppear:) name:UIKeyboardWillShowNotification object:nil];
    
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
    self.payeeNameTF.inputAccessoryView = toolbar;
}

- (void)hiddenKeyboard {
    [self.payeeNameTF resignFirstResponder];
}

- (void)keyboardWillAppear:(NSNotification *)notiObj {
    if ([self.payeeNameTF isFirstResponder]) {
        NSMutableDictionary *userInfo = [notiObj.userInfo mutableCopy];
        userInfo[@"tf"] = self.payeeNameTF;
        [NSNotificationCenter.defaultCenter postNotificationName:PISCTextViewAdjustPositionNotification object:nil userInfo:userInfo];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self setViewBorderWithRectBorder:UIRectBorderTop borderSize:0.5 withColor:nil withBroderOffset:nil];
    
    [self.titleLabel.superview setViewBorderWithRectBorder:UIRectBorderNone borderSize:0.5 withColor:nil withBroderOffset:nil];
    if (!self.configObject.isMultiProduct) {
        [self.titleLabel.superview setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    }
    
    [self.titleImageView setViewBorderWithRectBorder:UIRectBorderNone borderSize:0.5 withColor:nil withBroderOffset:nil];
    if (self.configObject.orderClearanceType==CDZOrderPaymentClearanceTypeOfSpecRepair) {
        [self.titleImageView setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:0.5 withColor:nil withBroderOffset:nil];
        [self.titleImageView setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:2.0f];
        
    }
   
    CGRect frame = self.productInfoContainerView.frame;
    frame.size.height = 100;
    self.productInfoContainerView.frame = frame;
    [self.productInfoContainerView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    
    [[self.multiProductInfoContainerView viewWithTag:10] setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:0.5 withColor:[UIColor colorWithHexString:@"909090"] withBroderOffset:nil];
    [self.multiProductImageView.superview setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:0.5 withColor:[UIColor colorWithHexString:@"909090"] withBroderOffset:nil];
    
    [self.expressPriceInfoLabel.superview setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    
    
    [self.invoiceSwitch.superview setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self.payeeNameContainerView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self.userRemarkView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self.totalPriceContainerView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
}

- (void)updateUIDataConfig:(PISCConfigObject *)configObject {
    self.configObject = configObject;
    BOOL isMultiProduct = configObject.isMultiProduct;
    self.titleArrowIndicatorView.hidden = YES;
    self.titleImageView.image = self.titleDefaultImage;
    self.userRemarkLabel.text = self.configObject.userRemarkString;
    
    CGFloat constant = isMultiProduct?-18:0;
    self.productInfoMainViewTopConstraint.constant = constant;
    self.productInfoViewBottomSpaceConstraint.constant = 0;
    self.productInfoContainerView.hidden = isMultiProduct;
    self.productImageView.image = [ImageHandler getDefaultWhiteLogo];
    self.productPurchaseCountLabel.text = @"1";
    self.productPriceLabel.text = @"0.00";
    
    
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    self.multiProductInfoContainerView.hidden = !isMultiProduct;
    self.multiProductInfoLabel.text = @"--";
    self.multiProductImageView.image = [ImageHandler getDefaultWhiteLogo];
    
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    self.expressPriceInfoTopConstaint.constant = configObject.showExpressPriceInfoView?0:-CGRectGetHeight(self.expressPriceInfoLabel.superview.frame);
    self.expressPriceInfoLabel.text = @"--";
    self.expressPriceInfoLabel.hidden = !configObject.showExpressPriceInfoView;
    
    
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    self.totalPriceViewTopConstraint.constant = configObject.showTotalPriceView?0:-CGRectGetHeight(self.totalPriceContainerView.frame);
    self.totalPriceContainerView.hidden = !configObject.showTotalPriceView;
    self.totalPriceLabel.text = @"0.00";
    
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    self.userRemarkViewConstraint.constant = configObject.showUserRemarkView?0:-CGRectGetHeight(self.userRemarkView.frame);
    self.userRemarkView.hidden = !configObject.showUserRemarkView;
    
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    self.payeeNameViewTopConstraint.constant = configObject.showPayeeNameLabel?0:-CGRectGetHeight(self.payeeNameContainerView.frame);
    self.payeeNameContainerView.hidden = !configObject.showPayeeNameLabel;
    self.payeeNameTF.text = configObject.payeeNameString;
    self.invoiceSwitch.on = configObject.showPayeeNameLabel;
    
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    CGFloat totalPrice = [SupportingClass verifyAndConvertDataToString:configObject.dataConfigDetail[@"sum_price"]].floatValue;
    if (self.configObject.orderClearanceType==CDZOrderPaymentClearanceTypeOfRegularParts) {
        self.titleLabel.text = configObject.dataConfigDetail[@"center_name"];
        NSArray *productList = configObject.dataConfigDetail[@"product_info"];
        NSString *firstProductImageURL = productList.firstObject[@"product_img"];
        if (isMultiProduct) {
            self.multiProductInfoLabel.text = [NSString stringWithFormat:@"共%d个商品", productList.count];
            if ([firstProductImageURL isContainsString:@"http"]) {
                [self.multiProductImageView sd_setImageWithURL:[NSURL URLWithString:firstProductImageURL] placeholderImage:[ImageHandler getDefaultWhiteLogo]];
            }
        }else {
            self.productNameLabel.text = productList.firstObject[@"product_name"];
            self.productPurchaseCountLabel.text = [SupportingClass verifyAndConvertDataToString:productList.firstObject[@"buy_count"]];
            CGFloat productTotalPrice = [SupportingClass verifyAndConvertDataToString:productList.firstObject[@"product_price"]].floatValue*self.productPurchaseCountLabel.text.floatValue;
            
            self.productPriceLabel.text = [NSString stringWithFormat:@"%.02f", productTotalPrice];
            if ([firstProductImageURL isContainsString:@"http"]) {
                [self.productImageView sd_setImageWithURL:[NSURL URLWithString:firstProductImageURL] placeholderImage:[ImageHandler getDefaultWhiteLogo]];
            }
            if (!configObject.dataConfigDetail[@"sum_price"]) {
                totalPrice = self.productPriceLabel.text.floatValue;
            }
        }
        
        CGFloat expressPrice = [SupportingClass verifyAndConvertDataToString:configObject.dataConfigDetail[@"send_cost"]].floatValue;
        self.expressPriceInfoLabel.text = [NSString stringWithFormat:@"普通运费 %.02f元", expressPrice];
        self.totalPriceLabel.text = [NSString stringWithFormat:@"%.02f", totalPrice+expressPrice];
        
    }else if (self.configObject.orderClearanceType==CDZOrderPaymentClearanceTypeOfSpecRepair) {        
//        self.productInfoMainViewTopConstraint.constant = 0;
        //        self.productInfoViewBottomSpaceConstraint.constant = 12;
//        self.titleArrowIndicatorView.hidden = NO;
        if (configObject.dataConfigDetail[@"wxs_logo"]) {
            self.titleImageView.image = configObject.dataConfigDetail[@"wxs_logo"];
        }
        self.productNameLabel.text = configObject.dataConfigDetail[@"product_name"];
        self.titleLabel.text = configObject.dataConfigDetail[@"wxs_name"];
        NSString *productImageURL = configObject.dataConfigDetail[@"product_img"];
        if ([productImageURL isContainsString:@"http"]) {
            [self.productImageView sd_setImageWithURL:[NSURL URLWithString:productImageURL] placeholderImage:[ImageHandler getDefaultWhiteLogo]];
        }
        self.productPurchaseCountLabel.text = [SupportingClass verifyAndConvertDataToString:configObject.dataConfigDetail[@"product_number"]];
        self.productPriceLabel.text = [NSString stringWithFormat:@"%.02f", [SupportingClass verifyAndConvertDataToString:configObject.dataConfigDetail[@"product_price"]].floatValue];
        
    }else if (self.configObject.orderClearanceType==CDZOrderPaymentClearanceTypeOfMaintainExpress) {
        self.titleLabel.text = configObject.dataConfigDetail[@"center_name"];
        NSArray *productList = configObject.dataConfigDetail[@"product_info"];
        NSArray *workingHoursList = configObject.dataConfigDetail[@"work_info"];
        NSString *firstProductImageURL = productList.firstObject[@"product_img"];
        if (isMultiProduct) {
            self.multiProductInfoLabel.text = [NSString stringWithFormat:@"共%d个商品，%d项工时费", productList.count, workingHoursList.count];
            if ([firstProductImageURL isContainsString:@"http"]) {
                [self.multiProductImageView sd_setImageWithURL:[NSURL URLWithString:firstProductImageURL] placeholderImage:[ImageHandler getDefaultWhiteLogo]];
            }
        }else {
            self.productNameLabel.text = productList.firstObject[@"product_name"];
            self.productPurchaseCountLabel.text = [SupportingClass verifyAndConvertDataToString:productList.firstObject[@"buy_count"]];
            self.productPriceLabel.text = [NSString stringWithFormat:@"%.02f", [SupportingClass verifyAndConvertDataToString:productList.firstObject[@"product_price"]].floatValue];
            if ([firstProductImageURL isContainsString:@"http"]) {
                [self.productImageView sd_setImageWithURL:[NSURL URLWithString:firstProductImageURL] placeholderImage:[ImageHandler getDefaultWhiteLogo]];
            }
        }
        
        
        CGFloat expressPrice = [SupportingClass verifyAndConvertDataToString:configObject.dataConfigDetail[@"send_cost"]].floatValue;
        self.expressPriceInfoLabel.text = [NSString stringWithFormat:@"普通运费 %.02f元", expressPrice];
        self.totalPriceLabel.text = [NSString stringWithFormat:@"%.02f", [SupportingClass verifyAndConvertDataToString:configObject.dataConfigDetail[@"sum_price"]].floatValue+expressPrice];
        
    }

    
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    
}

- (IBAction)showRemarkCommentView {
    [self.commentTextView showTextView];
}

- (IBAction)showPayeeNameTF:(UISwitch *)theSwitch {
    self.payeeNameViewTopConstraint.constant = (theSwitch.on?0:-(CGRectGetHeight(self.payeeNameContainerView.frame)));
    self.payeeNameContainerView.hidden = !theSwitch.on;
    if (self.tvContainerView) {
        self.configObject.showPayeeNameLabel = theSwitch.on;
        [self.tvContainerView reloadData];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if ([textField isFirstResponder]) {
        if ([[[textField textInputMode] primaryLanguage] isEqualToString:@"emoji"] || ![[textField textInputMode] primaryLanguage]) {
            return NO;
        }
    }
    return YES;
}

- (void)textFieldTextDidChange:(NSNotification *)notiObj {
    NSUInteger maxLenght = 8;
    UITextField *textField = (UITextField *)notiObj.object;
    NSString *toBeString = textField.text;
    NSString *lang = [[textField textInputMode] primaryLanguage];
    if ([lang isContainsString:@"zh-Hans"]) {
        UITextRange *selectedRange = [textField markedTextRange];
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        if (!position) {
            if (toBeString.length>maxLenght) {
                textField.text = [toBeString substringToIndex:maxLenght];
            }
        }else {
            
        }
    }else {
        if (toBeString.length>maxLenght) {
            textField.text = [toBeString substringToIndex:maxLenght];
        }
    }
    if (textField==self.payeeNameTF) {
        self.configObject.payeeNameString = textField.text;
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if ([textView isFirstResponder]) {
        if ([[[textView textInputMode] primaryLanguage] isEqualToString:@"emoji"] ||
            ![[textView textInputMode] primaryLanguage]) {
            return NO;
        }
    }
    return YES;
}

- (void)textViewTextDidChange:(NSNotification *)notiObj {
    UITextView *textView = (UITextView *)notiObj.object;
    NSUInteger maxLenght = 60;
    NSString *toBeString = textView.text;
    NSString *lang = [[textView textInputMode] primaryLanguage];
    if ([lang isContainsString:@"zh-Hans"]) {
        UITextRange *selectedRange = [textView markedTextRange];
        UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
        if (!position) {
            if (toBeString.length>maxLenght) {
                textView.text = [toBeString substringToIndex:maxLenght];
            }
        }else {
            
        }
    }else {
        if (toBeString.length>maxLenght) {
            textView.text = [toBeString substringToIndex:maxLenght];
        }
    }

}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if (textView==self.commentTextView.commentTextView) {
        self.configObject.userRemarkString = textView.text;
        self.userRemarkLabel.text = textView.text;
    }
}

- (IBAction)pushToMultiProductInfoDetailVC {
    @autoreleasepool {
        UIViewController *rootVC = UIApplication.sharedApplication.keyWindow.rootViewController;
        if (rootVC) {
            MultiProductInfoDetailVC *vc = [MultiProductInfoDetailVC new];
            vc.infoDetail = self.configObject.dataConfigDetail;
            vc.hiddenWorkingInfo = (self.configObject.orderClearanceType==CDZOrderPaymentClearanceTypeOfRegularParts);
            vc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            [rootVC presentViewController:vc animated:YES completion:^{
                
            }];
    
        }
    }
}


@end
