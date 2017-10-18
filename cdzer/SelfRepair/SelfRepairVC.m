//
//  SelfRepairVC.m
//  cdzer
//
//  Created by KEns0n on 3/18/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//
#define vDateStartFrom @"1990-01-01"
#define vLblTitleColor [UIColor colorWithRed:0.290f green:0.286f blue:0.271f alpha:1.00f]
#define vLblFont [UIFont systemFontOfSize:vAdjustByScreenRatio(14.0f)]

#import "SelfRepairVC.h"
#import "AutosSelectedView.h"
#import "SelfRepairResultVC.h"
#import "InsetsLabel.h"
#import "InsetsTextField.h"
#import "IQDropDownTextField.h"

@interface SelfRepairVC ()<IQDropDownTextFieldDelegate, UITextFieldDelegate>

@property (nonatomic, strong) AutosSelectedView *ASView;

@property (nonatomic, strong) InsetsLabel *mileageLabel;

@property (nonatomic, strong) InsetsLabel *dateLabel;

@property (nonatomic, strong) InsetsTextField *mileTextField;

@property (nonatomic, strong) IQDropDownTextField *dateBuyTextField;

@property (nonatomic, assign) CGRect keyboardRect;

@end

@implementation SelfRepairVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.contentView.backgroundColor = CDZColorOfWhite;
    [self setTitle:@"自助保养"];
    [self initializationUI];
    // Do any additional setup after loading the view, typically from a nib.
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_ASView reloadUIData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
}
// private functions
- (void)nextStepToResultViewWithMaintanceData:(NSDictionary *)maintanceData {
    [self resignKeyboard];
    @autoreleasepool {
        if (!maintanceData) {
            NSLog(@"maintanceData is Missing");
            return;
        }
        SelfRepairResultVC *resultVC = [[SelfRepairResultVC alloc] init];
        [resultVC setMaintanceData:maintanceData];
        [self.navigationController pushViewController:resultVC animated:YES];
    }
}

- (void)pushAutoSelectionView {
    [self pushToAutosSelectionViewWithBackTitle:nil animated:YES onlyForSelection:NO andSelectionResultBlock:nil];
}

- (void)initializationUI {
    @autoreleasepool {
        
        
        self.scrollView.hidden = NO;
        self.scrollView.scrollEnabled = NO;
        
        UIColor *color = [UIColor colorWithRed:0.984f green:0.420f blue:0.133f alpha:1.00f];

        
        CGFloat startPointY = vAdjustByScreenRatio(8.0f);
        CGRect alertIconRect = CGRectZero;
        alertIconRect.origin.y = startPointY;
        alertIconRect.origin.x = vAdjustByScreenRatio(15.0f);
        UIImage *alertIconImage = [ImageHandler getImageFromCacheByScreenRatioWithFileRootPath:kSysImageCaches fileName:@"alert_icon" type:FMImageTypeOfPNG scaleWithPhone4:NO
                                                                                   offsetRatioForP4:1.0f needToUpdate:YES];
        alertIconRect.size = alertIconImage.size;
        UIImageView *alertIconView = [[UIImageView alloc] initWithFrame:alertIconRect];
        [alertIconView setImage:alertIconImage];
        [self.scrollView addSubview:alertIconView];
        
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        InsetsLabel *alertLabel = [[InsetsLabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(alertIconRect)+vAdjustByScreenRatio(4.0f), startPointY, vAdjustByScreenRatio(266.0f), vAdjustByScreenRatio(30.0f))];
        alertLabel.textColor = color;
        [alertLabel setText:getLocalizationString(@"alert_description")];
        [alertLabel setNumberOfLines:2];
        [alertLabel setFont:[UIFont systemFontOfSize:vAdjustByScreenRatio(12.0f)]];
        [self.scrollView addSubview:alertLabel];
        
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

        NSMutableAttributedString* title1 = [NSMutableAttributedString new];
        [title1 appendAttributedString:[[NSAttributedString alloc]
                                        initWithString:@"第1步："
                                        attributes:@{NSForegroundColorAttributeName:CDZColorOfBlack,
                                                     NSFontAttributeName:vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 14.0f, YES)
                                                     }]];
        [title1 appendAttributedString:[[NSAttributedString alloc]
                                        initWithString:@"\n自主保养服务－选择车辆信息"
                                        attributes:@{NSForegroundColorAttributeName:color,
                                                     NSFontAttributeName:vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 14.0f, YES)
                                                     }]];
        
        
        InsetsLabel *stepOneTitle = [[InsetsLabel alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(alertLabel.frame)+startPointY,
                                                                                  CGRectGetWidth(self.contentView.frame), vAdjustByScreenRatio(50.0f))
                                                    andEdgeInsetsValue:DefaultEdgeInsets];
        stepOneTitle.attributedText = title1;
        stepOneTitle.numberOfLines = 0;
        stepOneTitle.backgroundColor = [UIColor colorWithRed:0.953f green:0.953f blue:0.953f alpha:1.00f];
        [stepOneTitle setViewBorderWithRectBorder:UIRectBorderTop borderSize:0.5f withColor:[UIColor colorWithRed:0.882f green:0.882f blue:0.882f alpha:1.00f] withBroderOffset:nil];
        [self.scrollView addSubview:stepOneTitle];
        
        
        
        self.ASView = [[AutosSelectedView alloc] initWithOrigin:CGPointMake(0.0f, CGRectGetMaxY(stepOneTitle.frame)) showMoreDeatil:NO onlyForSelection:NO];
        [self.scrollView addSubview:_ASView];
        [_ASView addTarget:self action:@selector(pushAutoSelectionView) forControlEvents:UIControlEventTouchUpInside];
        
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

        NSMutableAttributedString* title2 = [NSMutableAttributedString new];
        [title2 appendAttributedString:[[NSAttributedString alloc]
                                        initWithString:@"第2步："
                                        attributes:@{NSForegroundColorAttributeName:CDZColorOfBlack,
                                                     NSFontAttributeName:vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 14.0f, YES)
                                                     }]];
        [title2 appendAttributedString:[[NSAttributedString alloc]
                                        initWithString:@"\n自助保养服务－填写行驶里程和购车日期后 点击提交可以查询已有车辆的官方保养信息"
                                        attributes:@{NSForegroundColorAttributeName:color,
                                                     NSFontAttributeName:vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 14.0f, YES)
                                                     }]];
        
        
        InsetsLabel *stepTwoTitle = [[InsetsLabel alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(_ASView.frame), CGRectGetWidth(self.contentView.frame), vAdjustByScreenRatio(70.0f))
                                                    andEdgeInsetsValue:DefaultEdgeInsets];
        stepTwoTitle.attributedText = title2;
        stepTwoTitle.numberOfLines = 0;
        stepTwoTitle.backgroundColor = [UIColor colorWithRed:0.953f green:0.953f blue:0.953f alpha:1.00f];
        [stepTwoTitle setViewBorderWithRectBorder:UIRectBorderTop borderSize:0.5f withColor:[UIColor colorWithRed:0.882f green:0.882f blue:0.882f alpha:1.00f] withBroderOffset:nil];
        [self.scrollView addSubview:stepTwoTitle];
        
        
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

        UIToolbar *toolBar =  [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), 40.0f)];
        [toolBar setBarStyle:UIBarStyleDefault];
        UIBarButtonItem *spaceButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                    target:self
                                                                                    action:nil];
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]initWithTitle:getLocalizationString(@"finish")
                                                                      style:UIBarButtonItemStyleDone
                                                                     target:self
                                                                     action:@selector(resignKeyboard)];
        NSArray * buttonsArray = [NSArray arrayWithObjects:spaceButton,doneButton,nil];
        [toolBar setItems:buttonsArray];
        
        UIView *mileView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(stepTwoTitle.frame), CGRectGetWidth(self.contentView.frame), 50.0f)];
        [mileView setViewBorderWithRectBorder:UIRectBorderTop|UIRectBorderBottom borderSize:0.5f
                                    withColor:[UIColor colorWithRed:0.882f green:0.882f blue:0.882f alpha:1.00f] withBroderOffset:nil];
        [self.scrollView addSubview:mileView];
        
        
        UIFont *theFont = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 14, NO);
        NSString *mileTitle = getLocalizationString(@"mileage_txt_prefix");
        CGSize mileTitleSize = [SupportingClass getStringSizeWithString:mileTitle font:theFont widthOfView:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
        InsetsLabel *mileTitleLabel = [[InsetsLabel alloc] initWithFrame:CGRectMake(0.0, 0.0f, mileTitleSize.width+DefaultEdgeInsets.left, CGRectGetHeight(mileView.frame))
                                                      andEdgeInsetsValue:UIEdgeInsetsMake(0.0f, DefaultEdgeInsets.left, 0.0f, 0.0f)];
        mileTitleLabel.text = mileTitle;
        mileTitleLabel.font = theFont;
        [mileView addSubview:mileTitleLabel];
        
        NSString *kmTitle = @"KM";
        CGSize kmTitleSize = [SupportingClass getStringSizeWithString:kmTitle font:theFont widthOfView:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
        InsetsLabel *kmTitleLabel = [[InsetsLabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.scrollView.frame)-kmTitleSize.width-DefaultEdgeInsets.right-5.0f, 0.0f,
                                                                                  kmTitleSize.width+DefaultEdgeInsets.right+5.0f, CGRectGetHeight(mileView.frame))
                                                      andEdgeInsetsValue:UIEdgeInsetsMake(0.0f, 5.0f, 0.0f, DefaultEdgeInsets.left)];
        kmTitleLabel.text = kmTitle;
        kmTitleLabel.font = theFont;
        [mileView addSubview:kmTitleLabel];

        
        
        NSAttributedString *milePlaceholderText = [[NSAttributedString alloc] initWithString:getLocalizationString(@"km_label_hints")
                                                                                  attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:0.984f green:0.420f blue:0.133f alpha:0.5f]}];
        self.mileTextField = [[InsetsTextField alloc]initWithFrame:CGRectMake(CGRectGetMaxX(mileTitleLabel.frame), 0.0f,
                                                                              CGRectGetMinX(kmTitleLabel.frame)-CGRectGetMaxX(mileTitleLabel.frame),
                                                                              36.0f)
                                                andEdgeInsetsValue:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 5.0f)];
        _mileTextField.center = CGPointMake(_mileTextField.center.x, CGRectGetHeight(mileView.frame)/2.0f);
        _mileTextField.delegate = self;
        _mileTextField.font = theFont;
        _mileTextField.attributedPlaceholder = milePlaceholderText;
        _mileTextField.inputAccessoryView = toolBar;
        _mileTextField.textAlignment = NSTextAlignmentCenter;
        _mileTextField.borderStyle = UITextBorderStyleRoundedRect;
        _mileTextField.keyboardType = UIKeyboardTypeNumberPad;
        [mileView addSubview:_mileTextField];
        
        
        
        UIView *purchaseDateView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(mileView.frame), CGRectGetWidth(self.contentView.frame), 50.0f)];
        [purchaseDateView setViewBorderWithRectBorder:UIRectBorderTop|UIRectBorderBottom borderSize:0.5f
                                    withColor:[UIColor colorWithRed:0.882f green:0.882f blue:0.882f alpha:1.00f] withBroderOffset:nil];
        [self.scrollView addSubview:purchaseDateView];
        
        NSString *purchaseDateTitle = getLocalizationString(@"date_txt_prefix");
        CGSize purchaseDateTitleSize = [SupportingClass getStringSizeWithString:purchaseDateTitle font:theFont widthOfView:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
        InsetsLabel *purchaseDateTitleLabel = [[InsetsLabel alloc] initWithFrame:CGRectMake(0.0, 0.0f, purchaseDateTitleSize.width+DefaultEdgeInsets.left,
                                                                                            CGRectGetHeight(purchaseDateView.frame))
                                                      andEdgeInsetsValue:UIEdgeInsetsMake(0.0f, DefaultEdgeInsets.left, 0.0f, 0.0f)];
        purchaseDateTitleLabel.text = purchaseDateTitle;
        purchaseDateTitleLabel.font = theFont;
        [purchaseDateView addSubview:purchaseDateTitleLabel];
        
        self.dateBuyTextField = [[IQDropDownTextField alloc]initWithFrame:CGRectMake(CGRectGetMaxX(purchaseDateTitleLabel.frame), 0.0f,
                                                                                     CGRectGetWidth(self.contentView.frame)-CGRectGetMaxX(purchaseDateTitleLabel.frame)-DefaultEdgeInsets.right, 36.0f)
                                                       andEdgeInsetsValue:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 5.0f)];
        _dateBuyTextField.placeholder = @"请选择日期";
        _dateBuyTextField.dropDownMode = IQDropDownModeDatePicker;
        _dateBuyTextField.datePickerMode = UIDatePickerModeDate;
        _dateBuyTextField.center = CGPointMake(_dateBuyTextField.center.x, CGRectGetHeight(purchaseDateView.frame)/2.0f);
        _dateBuyTextField.delegate = self;
        _dateBuyTextField.font = theFont;
        _dateBuyTextField.inputAccessoryView = toolBar;
        _dateBuyTextField.textAlignment = NSTextAlignmentCenter;
        _dateBuyTextField.borderStyle = UITextBorderStyleRoundedRect;
        _dateBuyTextField.dateFormatter.dateFormat = @"yyyy-MM-dd";
        _dateBuyTextField.minimumDate = [_dateBuyTextField.dateFormatter dateFromString:vDateStartFrom];
        [purchaseDateView addSubview:_dateBuyTextField];
        
        
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.frame = CGRectMake(CGRectGetWidth(self.scrollView.frame)*0.1, CGRectGetMaxY(purchaseDateView.frame)+10.0f, CGRectGetWidth(self.scrollView.frame)*0.8, 36.0f);
        button.backgroundColor = CDZColorOfDefaultColor;
        [button setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:5.0f];
        [button setTitle:getLocalizationString(@"submit") forState:UIControlStateNormal];
        [button setTitleColor:CDZColorOfWhite forState:UIControlStateNormal];
        [button addTarget:self action:@selector(getSelfMaintenanceGetInfo) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:button];

    }
}

#pragma mark- UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (!CGRectEqualToRect(_keyboardRect, CGRectZero)) {
        [self shiftScrollViewWithAnimation:textField];
    }
    if ((!textField.text||[textField.text isEqualToString:@""])&&textField==_dateBuyTextField) {
        _dateBuyTextField.date = [_dateBuyTextField.dateFormatter dateFromString:@"2005-01-01"];
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField==_mileTextField) {
        NSMutableString *finalString = textField.text.mutableCopy;
        if (range.length==0&&range.location>(textField.text.length-1)) {
            [finalString appendString:string];
        }else if(range.length>0&&[string isEqualToString:@""]){
            [finalString deleteCharactersInRange:range];
        }else if(range.length>0&&![string isEqualToString:@""]){
            [finalString replaceCharactersInRange:range withString:string];
        }else {
            [finalString insertString:string atIndex:range.location];
        }
        if (finalString.integerValue>200000) {
            textField.text = @"200000";
            return NO;
        }
    }
    return YES;
}

- (void)keyboardWillShow:(NSNotification *)notifyObject {
    CGRect keyboardRect = [[notifyObject.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    if (!CGRectEqualToRect(keyboardRect, _keyboardRect)) {
        self.keyboardRect = keyboardRect;
    }
    
    if ([_mileTextField isFirstResponder]) {
        [self shiftScrollViewWithAnimation:_mileTextField];
        NSLog(@"mileTextField");
    }
    
    if ([_dateBuyTextField isFirstResponder]) {
        [self shiftScrollViewWithAnimation:_mileTextField];
        NSLog(@"dateBuyTextField");
    }
    NSLog(@"Step One");
}

- (void)resignKeyboard{
    [_mileTextField resignFirstResponder];
    [_dateBuyTextField resignFirstResponder];
    @weakify(self);
    [UIView animateWithDuration:0.25 animations:^{
        @strongify(self);
        self.scrollView.contentOffset = CGPointZero;
    }];
}

- (void)shiftScrollViewWithAnimation:(UITextField *)textField{
    CGPoint point = CGPointZero;
    CGFloat contanierViewMaxY = CGRectGetMidY(textField.superview.frame);
    CGFloat visibleContentsHeight = (CGRectGetHeight(self.scrollView.frame)-CGRectGetHeight(_keyboardRect))/2.0f;
    if (contanierViewMaxY > visibleContentsHeight) {
        CGFloat offsetY = contanierViewMaxY-visibleContentsHeight;
        point.y = offsetY;
    }
    @weakify(self);
    [UIView animateWithDuration:0.25 animations:^{
        @strongify(self);
        self.scrollView.contentOffset = point;
    }];
    
}


- (void)showAlertDidNotSelectAutos {
    [SupportingClass showAlertViewWithTitle:@"alert_remind" message:@"请先选择车系车型" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
        
    }];
}

//if (!_ASView.autoData.modelID) {
//    [self showAlertDidNotSelectAutos];
//    return;
//}

#pragma mark- APIs Access Request
- (void)getSelfMaintenanceGetInfo {
    if (_mileTextField.text.length==0) {
        [SupportingClass showAlertViewWithTitle:@"alert_remind" message:getLocalizationString(@"mile_alert_message") isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
        }];
        return;
    }
    if (_dateBuyTextField.text.length==0) {
        [SupportingClass showAlertViewWithTitle:@"alert_remind" message:getLocalizationString(@"date_selection_alert_message") isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
        }];
        return;
    }
    [ProgressHUDHandler showHUD];
    NSString *autoModelID = _ASView.autoData.modelID;
    [[APIsConnection shareConnection] theSelfMaintenanceAPIsGetMaintenanceInfoWithAutoModelID:autoModelID autoTotalMileage:_mileTextField.text purchaseDate:_dateBuyTextField.text  success:^(NSURLSessionDataTask *operation, id responseObject) {
        [self requestResultHandle:operation responseObject:responseObject withError:nil];
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
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
        NSLog(@"%@",message);
        [ProgressHUDHandler dismissHUD];
        if (errorCode!=0) {
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                [ProgressHUDHandler dismissHUD];
            }];
            return;
        }
        NSMutableDictionary *maintanceData = [NSMutableDictionary dictionaryWithDictionary:responseObject];
        [maintanceData setObject:_mileTextField.text forKey:@"miles"];
        [self nextStepToResultViewWithMaintanceData:maintanceData];
    }
    
}

@end
