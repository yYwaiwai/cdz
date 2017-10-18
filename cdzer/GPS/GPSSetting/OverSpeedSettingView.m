//
//  OverSpeedSettingView.m
//  cdzer
//
//  Created by KEns0n on 6/5/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#import "InsetsLabel.h"
#import "InsetsTextField.h"
#import "UIView+Borders.h"
#import "OverSpeedSettingView.h"
@interface OverSpeedSettingView() <UITextFieldDelegate>
@property (nonatomic, assign) BOOL lastSpeedSwitchValue;

@property (nonatomic, assign) BOOL lastVoiceSwitchValue;

@property (nonatomic, strong) UIView *contentsView;

@property (nonatomic, strong) UISwitch *speedSwitcher;

@property (nonatomic, strong) UISwitch *voiceSwitcher;

@property (nonatomic, strong) UIButton *confirmButton;

@property (nonatomic, strong) NSString *lastLimitedSpeedSetting;

@property (nonatomic, strong) InsetsTextField *speedTextField;

@end

@implementation OverSpeedSettingView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (instancetype)init {
    if (self = [self initWithFrame:CGRectZero]) {
        
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initializationUI];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
}

- (void)initializationUI {
    @autoreleasepool {
        self.alpha = 0.0f;
        self.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.65f];
        self.contentsView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 250.0f, 250.0f)];
        _contentsView.center = CGPointMake(CGRectGetWidth(self.frame)/2.0f, CGRectGetHeight(self.frame)/2.0f);
        _contentsView.backgroundColor = CDZColorOfWhite;
        _contentsView.layer.cornerRadius = 5.0f;
        _contentsView.layer.masksToBounds = YES;
        [self addSubview:_contentsView];
        
        CGFloat size = 40.0f;
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
        cancelButton.frame = CGRectMake(CGRectGetWidth(self.frame)-size, 0.0f, size, size);
        cancelButton.titleLabel.font = systemFontBoldWithoutRatio(45.0f);
        [cancelButton setTitle:@"X" forState:UIControlStateNormal];
        [cancelButton setTitleColor:CDZColorOfWhite forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(hiddenSelfView) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:cancelButton];
        
        InsetsLabel *titleLabel = [[InsetsLabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f,
                                                                                CGRectGetWidth(_contentsView.frame), 40.0f)
                                                           andEdgeInsetsValue:UIEdgeInsetsMake(0.0f, 12.0f, 0.0f, 12.0f)];
        titleLabel.font = systemFontBoldWithoutRatio(22.0f);
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.text = getLocalizationString(@"over_speed_setting");
        [titleLabel addBottomBorderWithHeight:1.0f color:CDZColorOfDeepGray leftOffset:5.0f rightOffset:5.0f andBottomOffset:0.0f];
        [_contentsView addSubview:titleLabel];
        
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        UIImage *image = [UIImage imageNamed:@"security_setting_speed_setting.png"];
        InsetsLabel *itemTitleLabel = [[InsetsLabel alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(titleLabel.frame),
                                                                                CGRectGetWidth(_contentsView.frame), 50.0f)
                                                           andEdgeInsetsValue:UIEdgeInsetsMake(0.0f, image.size.width+17.0f, 0.0f, 0.0f)];
        itemTitleLabel.font = systemFontWithoutRatio(18.0f);
        itemTitleLabel.text = getLocalizationString(@"speed_setup");
        itemTitleLabel.userInteractionEnabled = YES;
        [_contentsView addSubview:itemTitleLabel];
        UIImageView *logoIV = [[UIImageView alloc] initWithImage:image];
        CGRect logoIVRect = logoIV.frame;
        logoIVRect.origin.x = 12.0f;
        logoIV.frame = logoIVRect;
        logoIV.center = CGPointMake(logoIV.center.x, CGRectGetHeight(itemTitleLabel.frame)/2.0f);
        [itemTitleLabel addSubview:logoIV];
        
        self.speedSwitcher = [[UISwitch alloc]init];
        _speedSwitcher.center = CGPointMake(_speedSwitcher.center.x,  CGRectGetHeight(itemTitleLabel.frame)/2.0f);
        CGRect switcherRect = _speedSwitcher.frame;
        switcherRect.origin.x = CGRectGetWidth(itemTitleLabel.frame)-CGRectGetWidth(_speedSwitcher.frame)-10.0f;
        _speedSwitcher.frame = switcherRect;
        _speedSwitcher.on = NO;
        self.lastSpeedSwitchValue = NO;
        [_speedSwitcher addTarget:self action:@selector(switcherValueChange:) forControlEvents:UIControlEventValueChanged];
        [itemTitleLabel addSubview:_speedSwitcher];
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
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

        
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        self.speedTextField = [[InsetsTextField alloc] initWithFrame:CGRectMake(12.0f, CGRectGetMaxY(itemTitleLabel.frame),
                                                                               CGRectGetWidth(_contentsView.frame)-(12.0f*2.0f), 36.0f)
                               andEdgeInsetsValue:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 45.0f)];
        _speedTextField.borderStyle = UITextBorderStyleRoundedRect;
        _speedTextField.font = itemTitleLabel.font;
        _speedTextField.placeholder = @"请输入限制车速";
        _speedTextField.textAlignment = NSTextAlignmentCenter;
        _speedTextField.layer.masksToBounds = YES;
        _speedTextField.delegate = self;
        _speedTextField.layer.cornerRadius = 5.0f;
        _speedTextField.returnKeyType = UIReturnKeyDone;
        _speedTextField.keyboardType = UIKeyboardTypeNumberPad;
        _speedTextField.enabled = _speedSwitcher.on;
        _speedTextField.inputAccessoryView = toolbar;
        [_contentsView addSubview:_speedTextField];
        UILabel *kmLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetWidth(_speedTextField.frame)-36.0f, 0.0, 36.0f, 36.0f)];
        kmLabel.font = _speedTextField.font;
        kmLabel.textColor = CDZColorOfDeepGray;
        kmLabel.backgroundColor = CDZColorOfLightGray;
        kmLabel.text = @"KM";
        kmLabel.textAlignment = NSTextAlignmentCenter;
        [_speedTextField addSubview:kmLabel];
        
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        UIImage *voiceImage = [UIImage imageNamed:@"security_setting_voice"];
        InsetsLabel *voiceItemTitleLabel = [[InsetsLabel alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(_speedTextField.frame),
                                                                                    CGRectGetWidth(_contentsView.frame), 50.0f)
                                                               andEdgeInsetsValue:UIEdgeInsetsMake(0.0f, voiceImage.size.width+17.0f, 0.0f, 0.0f)];
        voiceItemTitleLabel.font = systemFontWithoutRatio(18.0f);
        voiceItemTitleLabel.text = getLocalizationString(@"voice_reminder");
        voiceItemTitleLabel.userInteractionEnabled = YES;
        [_contentsView addSubview:voiceItemTitleLabel];
        UIImageView *voiceLogoIV = [[UIImageView alloc] initWithImage:voiceImage];
        CGRect voiceLogoIVRect = voiceLogoIV.frame;
        voiceLogoIVRect.origin.x = 12.0f;
        voiceLogoIV.frame = voiceLogoIVRect;
        voiceLogoIV.center = CGPointMake(voiceLogoIV.center.x, CGRectGetHeight(voiceItemTitleLabel.frame)/2.0f);
        [voiceItemTitleLabel addSubview:voiceLogoIV];
        
        self.voiceSwitcher = [[UISwitch alloc]init];
        _voiceSwitcher.center = CGPointMake(_speedSwitcher.center.x,  CGRectGetHeight(itemTitleLabel.frame)/2.0f);
        CGRect voiceSwitcherRect = _speedSwitcher.frame;
        voiceSwitcherRect.origin.x = CGRectGetWidth(itemTitleLabel.frame)-CGRectGetWidth(_speedSwitcher.frame)-10.0f;
        _voiceSwitcher.frame = voiceSwitcherRect;
        _voiceSwitcher.on = NO;
        self.lastVoiceSwitchValue = NO;
        [voiceItemTitleLabel addSubview:_voiceSwitcher];
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

        
        self.confirmButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _confirmButton.frame = CGRectMake(0.0, CGRectGetHeight(_contentsView.frame)-55.0f, CGRectGetWidth(_contentsView.frame)*0.8, 45.0f);
        _confirmButton.layer.cornerRadius = 5.0f;
        _confirmButton.layer.masksToBounds = YES;
        _confirmButton.backgroundColor = CDZColorOfDefaultColor;
        _confirmButton.titleLabel.font = systemFontWithoutRatio(16.0f);
        _confirmButton.center = CGPointMake(CGRectGetWidth(_contentsView.frame)/2.0f, _confirmButton.center.y);
        [_confirmButton setTitle:getLocalizationString(@"ok") forState:UIControlStateNormal];
        [_confirmButton setTitleColor:CDZColorOfWhite forState:UIControlStateNormal];
        [_confirmButton addTarget:self action:@selector(confirmSetting) forControlEvents:UIControlEventTouchUpInside];
        [_contentsView addSubview:_confirmButton];
    }
}

- (void)setVoiceSwitchValue:(BOOL)value {
    _voiceSwitcher.on = value;
    self.lastVoiceSwitchValue = value;
}

- (void)setSpeedSwitchValue:(BOOL)value {
    _speedSwitcher.on = value;
    self.lastVoiceSwitchValue = value;
    _speedTextField.enabled = value;
    
}

- (void)setLimitSpeed:(NSString *)speedString {
    _speedTextField.text = speedString;
    self.lastLimitedSpeedSetting = speedString;
}

- (void)switcherValueChange:(UISwitch *)switcher {
    [self hiddenKeyboard];
    _speedTextField.enabled = switcher.on;
}

- (void)confirmSetting {
    
    if (_speedSwitcher.on&&(!_speedTextField.text||[_speedTextField.text isEqualToString:@""])) {
        [SupportingClass showAlertViewWithTitle:@"alert_remind"
                                        message:@"请填写限制速度！"
                                isShowImmediate:YES
                              cancelButtonTitle:@"ok"
                              otherButtonTitles:nil clickedButtonAtIndexWithBlock:nil];
        return;
    }
    [self updateLimitSpeedSettingWithSpeedStatus:_speedSwitcher.on speed:_speedTextField.text voiceStatus:_voiceSwitcher.on];
}

- (void)hiddenSelfAndSuccess:(BOOL)isSuccess {
    @weakify(self);
    [UIView animateWithDuration:0.25 animations:^{
        @strongify(self);
        self.alpha = 0.0f;
        [self hiddenKeyboard];
    }completion:^(BOOL finished) {
        @strongify(self);
        if (isSuccess) {
            self.lastSpeedSwitchValue = self.speedSwitcher.on;
            self.lastVoiceSwitchValue = self.voiceSwitcher.on;
            self.lastLimitedSpeedSetting = self.speedTextField.text;
            [NSNotificationCenter.defaultCenter postNotificationName:@"updateAllSettingStatus" object:nil];
        }else {
            self.speedSwitcher.on = self.lastSpeedSwitchValue;
            self.voiceSwitcher.on = self.lastVoiceSwitchValue;
            self.speedTextField.text = self.lastLimitedSpeedSetting;
        }
    }];
}

- (void)hiddenSelfView {
    [self hiddenSelfAndSuccess:NO];
}

- (void)showView {
    @weakify(self);
    [UIView animateWithDuration:0.25 animations:^{
        @strongify(self);
        self.alpha = 1.0f;
        [self hiddenKeyboard];
    }];
}

- (void)hiddenKeyboard {
    @weakify(self);
    [UIView animateWithDuration:0.25 animations:^{
        @strongify(self);
        [self.speedTextField resignFirstResponder];
        self.contentsView.center = CGPointMake(self.contentsView.center.x, CGRectGetHeight(self.frame)/2.0f);
    }];
}

#pragma mark- UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self hiddenKeyboard];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    @weakify(self);
    [UIView animateWithDuration:0.25 animations:^{
        @strongify(self);
        CGRect frame = self.contentsView.frame;
        frame.origin.y -= 50.0f;
        self.contentsView.frame = frame;
    }];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [self hiddenKeyboard];
    return YES;
}

#pragma mark- APIs Access Request
/* 修改超速设置 */
- (void)updateLimitSpeedSettingWithSpeedStatus:(BOOL)speedStatus speed:(NSString *)speed voiceStatus:(BOOL)voiceStatus {
    NSNumber *accStatus = [[[DBHandler shareInstance] getAutoRealtimeDataWithDataID:0] objectForKey:@"acc"];
    if (![SupportingClass analyseCarStatus:accStatus.stringValue withParentView:self.superview]){
        return;
    }
    
    if (!vGetUserToken) return;
    [ProgressHUDHandler showHUDWithTitle:@"更新设置中...." onView:nil];
        @weakify(self);
    [[APIsConnection shareConnection] personalGPSAPIsPostAutoOverSpeedSettingUpdateWithAccessToken:vGetUserToken speedStatus:speedStatus speed:@(speed.integerValue) voiceStatus:voiceStatus success:^(NSURLSessionDataTask *operation, id responseObject) {
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        if (errorCode!=0) {
            [ProgressHUDHandler showErrorWithStatus:message onView:nil completion:^{
                
            }];
            return;
        }
        [ProgressHUDHandler showSuccessWithStatus:@"更新成功！" onView:nil completion:^{
            [self hiddenSelfAndSuccess:YES];
        }];
        
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        [ProgressHUDHandler showErrorWithStatus:@"更新失败！" onView:nil completion:^{
        }];
    }];
}

@end
