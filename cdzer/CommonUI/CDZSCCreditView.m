//
//  CDZSCCreditView.m
//  cdzer
//
//  Created by KEns0n on 7/21/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//
#define vMinHeight 120
#define vExtHeight 10
#import "CDZSCCreditView.h"
#import "InsetsLabel.h"
#import "InsetsTextField.h"
#import "AFViewShaker.h"
#import "ValidCodeButton.h"
#import "UserInfosDTO.h"


@interface CDZSCCreditView ()<UITextFieldDelegate>

@property (nonatomic, assign) CGRect keyboardRect;

@property (nonatomic, strong) InsetsTextField *textField;

@property (nonatomic, strong) InsetsTextField *validNumTextField;

@property (nonatomic, strong) InsetsLabel *titleLabel;

@property (nonatomic, strong) UISwitch *theSwitch;

@property (nonatomic, strong) NSString *totalPrice;

@property (nonatomic, strong) NSString *credit;

@property (nonatomic, strong) NSString *maxValue;

@property (nonatomic, strong) NSString *ratio;

@property (nonatomic, strong) AFViewShaker *viewShaker;

@property (nonatomic, strong) ValidCodeButton *validCodeBtn;

@end

@implementation CDZSCCreditView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
    CGRect frame = UIScreen.mainScreen.bounds;
    self = [self initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (NSString *)convertedCredit {
    if (_isUseCredit&&_usedCredit&&![_usedCredit isEqualToString:@""]&&![_usedCredit isEqualToString:@"0"]) {
        return [NSString stringWithFormat:@"%0.2f", [SupportingClass roundToLastTwoFloatValue:_usedCredit.doubleValue*_ratio.doubleValue]];
    }
    return @"0";
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = CDZColorOfWhite;
        self.ratio = @"0";
        [self initializationUI];
        [self setViewBorderWithRectBorder:UIRectBorderTop borderSize:1.0f withColor:CDZColorOfLightGray withBroderOffset:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    CGFloat halfHeight = (_theSwitch.on)?1.0f:3.0f;
    if (frame.size.height<vMinHeight/3.0f||frame.size.height>vMinHeight) {
        frame.size.height = vMinHeight/halfHeight;
    }
    if (_theSwitch.on) {
        frame.size.height += vExtHeight;
    }
    [super setFrame:frame];
}

- (void)turnOffTheOption {
    [self.theSwitch setOn:NO animated:YES];
    [self theSwitchValueUpdate:_theSwitch];
}

- (void)setTotalPrice:(NSString *)totalPrice currenCredit:(NSString *)credit withRatio:(NSString *)ratio {
    @autoreleasepool {
        if (!ratio||[ratio isEqualToString:@""]) ratio = @"0";
        self.ratio = ratio;
        NSNumberFormatter *formatter = [NSNumberFormatter new];
        self.credit = credit;
        if ([credit isKindOfClass:NSNumber.class]) {
            self.credit = [formatter stringFromNumber:(NSNumber *)credit];
        }
        if (!_credit||[_credit isEqualToString:@""]) {
            self.credit = @"0";
        }
        if ([_credit isEqualToString:@"0"]) {
            self.theSwitch.enabled = NO;
        }
        
        self.totalPrice = [SupportingClass verifyAndConvertDataToString:totalPrice];
        
        self.maxValue = @((long)(_totalPrice.doubleValue/ratio.floatValue)).stringValue;
        if (_totalPrice.longLongValue/ratio.floatValue>_credit.longLongValue) {
            self.maxValue = @(_credit.longLongValue).stringValue;
        }
        _textField.text = _maxValue;
        [_textField sendActionsForControlEvents:UIControlEventEditingChanged];
        
        NSMutableAttributedString *string = [NSMutableAttributedString new];
        [string appendAttributedString:[[NSAttributedString alloc]
                                        initWithString:@"积分 "
                                        attributes:@{NSForegroundColorAttributeName:CDZColorOfBlack}]];
        [string appendAttributedString:[[NSAttributedString alloc]
                                        initWithString:[NSString stringWithFormat:@"（总积分：%@）",_credit]
                                        attributes:@{NSForegroundColorAttributeName:CDZColorOfDeepGray}]];
        _titleLabel.attributedText = string;
    }
}

- (void)shakeView {
    if (_usedCredit.longLongValue <= 0) {
        [_viewShaker shake];
    }
}

- (InsetsLabel *)insetLabelInitialWithFrame:(CGRect)frame {
    UIEdgeInsets insetValue = DefaultEdgeInsets;
    UIFont *font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 17.0f, NO);
    InsetsLabel *label = [[InsetsLabel alloc] initWithFrame:frame andEdgeInsetsValue:insetValue];
    label.font = font;
    [self addSubview:label];
    return label;
}

- (void)initializationUI {
    self.clipsToBounds = YES;
    self.backgroundColor = CDZColorOfWhite;
    CGFloat height = vMinHeight/3.0f;
    
    self.titleLabel = [self insetLabelInitialWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.frame), height)];
    _titleLabel.text = @"积分：";
    
    self.theSwitch = [UISwitch new];
    _theSwitch.center = CGPointMake(_theSwitch.center.x, CGRectGetHeight(_titleLabel.frame)/2.0f);
    CGRect theSwitchFrame = _theSwitch.frame;
    theSwitchFrame.origin.x = CGRectGetWidth(self.frame)-CGRectGetWidth(theSwitchFrame)-15.0f;
    _theSwitch.frame = theSwitchFrame;
    _theSwitch.on = NO;
    [_theSwitch addTarget:self action:@selector(theSwitchValueUpdate:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:_theSwitch];
    
    
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

    
    NSString *title = @"积分数目：";
    UIFont *font = _titleLabel.font;
    CGFloat width = [SupportingClass getStringSizeWithString:title font:font widthOfView:CGSizeMake(CGFLOAT_MAX, height)].width;
    
    
    InsetsLabel *textFieldTitleLabel = [self insetLabelInitialWithFrame:CGRectMake(0.0f, CGRectGetMaxY(_titleLabel.frame)+vExtHeight/2.0f, width+15.0f, height)];
    textFieldTitleLabel.edgeInsets = UIEdgeInsetsMake(0.0f, 15.0f, 0.0f, 0.0f);
    textFieldTitleLabel.text = title;
    
    self.textField = [[InsetsTextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(textFieldTitleLabel.frame), CGRectGetMinY(textFieldTitleLabel.frame),
                                                                        CGRectGetWidth(self.frame)-CGRectGetMaxX(textFieldTitleLabel.frame)-15.0f, height)
                                         andEdgeInsetsValue:UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 0.0f)];
    _textField.shouldStopPCDAction = NO;
    _textField.font = font;
    _textField.placeholder = @"请填入积分";
    _textField.keyboardType = UIKeyboardTypeNumberPad;
    _textField.returnKeyType = UIReturnKeyDone;
    _textField.inputAccessoryView = toolbar;
    _textField.text = @"0";
    _textField.delegate = self;
    [_textField setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:5.0f];
    [_textField setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:0.5f withColor:CDZColorOfBlack withBroderOffset:nil];
    [self addSubview:_textField];
    
    
    self.viewShaker = [[AFViewShaker alloc] initWithView:_textField];
    
    @weakify(self);
    [_textField.rac_textSignal subscribeNext:^(NSString *text) {
        @strongify(self);
        self.usedCredit = text;
    }];
    
    
    UIImage *validCodeImage = [ImageHandler getImageFromCacheByScreenRatioWithFileRootPath:kSysImageCaches
                                                                                  fileName:@"validCode"
                                                                                      type:FMImageTypeOfPNG
                                                                           scaleWithPhone4:NO
                                                                               offsetRatioForP4:1.0f
                                                                              needToUpdate:YES];
    NSAttributedString * placeholderStringVCO = [[NSAttributedString alloc] initWithString:[getLocalizationString(@"valid_code") stringByReplacingOccurrencesOfString:@"：" withString:@""] attributes:@{NSForegroundColorAttributeName:[UIColor darkGrayColor]}];
    self.validNumTextField = [[InsetsTextField alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(_textField.frame)+vExtHeight/2.0f, CGRectGetWidth(self.frame), height)
                                                 andEdgeInsetsValue:UIEdgeInsetsMake(0.0f, 55.0f, 0.0f, 105.0f)];
    _validNumTextField.backgroundColor = CDZColorOfClearColor;
     _validNumTextField.textAlignment = NSTextAlignmentCenter;
    _validNumTextField.keyboardType = UIKeyboardTypeNumberPad;
    _validNumTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _validNumTextField.returnKeyType = UIReturnKeyNext;
    _validNumTextField.enablesReturnKeyAutomatically = YES;
    _validNumTextField.attributedPlaceholder = placeholderStringVCO;
    _validNumTextField.inputAccessoryView = toolbar;
    _validNumTextField.delegate = self;
    BorderOffsetObject *offset = [BorderOffsetObject new];
    offset.bottomOffset = 5.0f;
    offset.bottomRightOffset = _validNumTextField.edgeInsets.right;
    offset.bottomLeftOffset = _validNumTextField.edgeInsets.left;
    [_validNumTextField setViewBorderWithRectBorder:UIRectBorderBottom borderSize:1 withColor:CDZColorOfDeepGray withBroderOffset:offset];
    [self addSubview:_validNumTextField];
    
    [_validNumTextField.rac_textSignal subscribeNext:^(NSString *text) {
        @strongify(self);
        if ([text isEqualToString:@""]) text = nil;
        self.verifyCode = text;
    }];
    
    UIImageView *validCodeIcon = [[UIImageView alloc] initWithFrame:CGRectMake(15.0f, 0.0f, 40.0f, 40.0f)];
    validCodeIcon.image = [validCodeImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    validCodeIcon.tintColor = CDZColorOfYellow;
    [_validNumTextField addSubview:validCodeIcon];
    
    UserInfosDTO *dto = [DBHandler.shareInstance getUserInfo];
    self.validCodeBtn = [ValidCodeButton buttonWithType:UIButtonTypeCustom];
    _validCodeBtn.frame = CGRectMake(CGRectGetWidth(_validNumTextField.frame)-105.0f, 0.0f, 90.0f, CGRectGetHeight(_validNumTextField.frame));
    _validCodeBtn.userPhone = @(dto.telphone.longLongValue);
    [_validCodeBtn buttonSettingWithType:VCBTypeOfOrderCreditValid];
    [_validNumTextField addSubview:_validCodeBtn];
}

- (void)theSwitchValueUpdate:(UISwitch *)theSwitch {
    
    @weakify(self);
    if ([_credit isEqualToString:@"0"]) {
        [theSwitch setOn:NO animated:YES];
        return;
    }
    CGFloat halfHeight = (theSwitch.on)?1.0f:3.0f;
    [UIView animateWithDuration:0.25 animations:^{
        @strongify(self);
        CGRect frame = self.frame;
        frame.size.height = vMinHeight/halfHeight;
        self.frame = frame;
        self.textField.alpha = theSwitch.on;
    }];
    if (!theSwitch.on) {
        [self hiddenKeyboard];
    }
    
    self.isUseCredit = theSwitch.on;
}

- (void)setIsUseCredit:(BOOL)isUseCredit {
    _isUseCredit = isUseCredit;
}

- (void)setUsedCredit:(NSString *)usedCredit {
    _usedCredit = usedCredit;
}

- (void)setVerifyCode:(NSString *)verifyCode {
    _verifyCode = verifyCode;
}

- (void)hiddenKeyboard {
    [_textField resignFirstResponder];
    [_validNumTextField resignFirstResponder];
    [UIView animateWithDuration:0.25 animations:^{
        UIView *theView = self.superview;
        if (self.theScrollView) theView = self.theScrollView;
        if ([theView isKindOfClass:UIScrollView.class]) {
            [(UIScrollView *)theView setScrollEnabled:YES];
            [(UIScrollView *)theView setContentOffset:CGPointZero];
        }else {
            CGRect frame = theView.frame;
            frame.origin.y = 0.0f;
            theView.frame = frame;
        }
    }];
}

- (void)keyboardWillShow:(NSNotification *)notifyObject {
    CGRect keyboardRect = [[notifyObject.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    if (!CGRectEqualToRect(keyboardRect, _keyboardRect)) {
        self.keyboardRect = keyboardRect;
    }
    if ([_textField isFirstResponder]) {
        [self shiftScrollViewWithAnimation:_textField];
        NSLog(@"Step _textField");
    }
    
    if ([_validNumTextField isFirstResponder]) {
        [self shiftScrollViewWithAnimation:_validNumTextField];
        NSLog(@"Step _validNumTextField");
    }
}

- (void)shiftScrollViewWithAnimation:(UITextField *)textField {
    UIView *theView = self.superview;
    if (self.theScrollView) theView = self.theScrollView;
    CGPoint point = CGPointZero;
    CGFloat contanierViewMaxY = CGRectGetMidY([self convertRect:textField.frame toView:theView]);
    CGFloat visibleContentsHeight = (CGRectGetHeight(theView.frame)-CGRectGetHeight(_keyboardRect))/2.0f;
    if (contanierViewMaxY > visibleContentsHeight) {
        CGFloat offsetY = contanierViewMaxY-visibleContentsHeight;
        point.y = offsetY;
    }
    [UIView animateWithDuration:0.25 animations:^{
        if ([theView isKindOfClass:UIScrollView.class]) {
            [(UIScrollView *)theView setContentOffset:point];
        }else {
            CGRect frame = theView.frame;
            frame.origin.y = 0.0f - point.y;
            theView.frame = frame;
        }
    }];
    
}

#pragma mark- UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    UIView *theView = self.superview;
    if (self.theScrollView) theView = self.theScrollView;
    if ([theView isKindOfClass:UIScrollView.class]) {
        [(UIScrollView *)theView setScrollEnabled:NO];
    }
    if (!CGRectEqualToRect(_keyboardRect, CGRectZero)) {
        [self shiftScrollViewWithAnimation:textField];
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (_validNumTextField==textField) {
        return YES;
    }
    if (textField.text.length==1) {
        if ([string isEqualToString:@""]) {
            textField.text = @"0";
            [textField sendActionsForControlEvents:UIControlEventEditingChanged];
            return NO;
        }
        if ([textField.text isEqualToString:@"0"]) {
            textField.text = string;
            [textField sendActionsForControlEvents:UIControlEventEditingChanged];
            return NO;
        }
    }
    
    if ([textField.text stringByAppendingString:string].longLongValue>_maxValue.longLongValue) {
        textField.text = _maxValue;
        [textField sendActionsForControlEvents:UIControlEventEditingChanged];
        return NO;
    }
    
    
    if ([textField.text isEqualToString:_maxValue]&&![string isEqualToString:@""]) {
        return NO;
    }
    
    return YES;
}


@end
