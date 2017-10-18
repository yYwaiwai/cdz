//
//  DateTimeSelectionView.m
//  cdzer
//
//  Created by KEns0n on 5/28/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//
#define vTextFieldTag 100
#define vSCBtnsTag 110

#import "DateTimeSelectionView.h"
#import "IQDropDownTextField.h"
#import "InsetsLabel.h"
@interface DateTimeSelectionView ()<IQDropDownTextFieldDelegate>

@property (nonatomic, strong) UIView *bulrView;

@property (nonatomic, strong) IQDropDownTextField *startDateTime;

@property (nonatomic, strong) IQDropDownTextField *endDateTime;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic, strong) UIButton *confirmBtn;

@property (nonatomic, copy) DRSResponseBlock completionBlock;
@end

@implementation DateTimeSelectionView

- (void)dealloc {
    self.startDateTime.delegate = nil;
    [_startDateTime removeFromSuperview];
    self.startDateTime = nil;
    
    self.endDateTime.delegate = nil;
    [_endDateTime removeFromSuperview];
    self.endDateTime = nil;
    self.completionBlock = nil;
    self.dateFormatter = nil;
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (instancetype)init {
    if ((self = [self initWithFrame:CGRectZero])) {
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self initializationUI];
        [self setReactiveRules];
    }
    
    return self;
}

- (void)setReactiveRules {
    [_startDateTime sendActionsForControlEvents:UIControlEventEditingChanged];
    [_endDateTime sendActionsForControlEvents:UIControlEventEditingChanged];
    RACSignal *startDateTimeSignal = [_startDateTime.rac_textSignal map:^id(NSString *string) {
        return @(![string isEqualToString:@""]||string);
    }];
    
    RACSignal *endDateTimeSignal = [_endDateTime.rac_textSignal map:^id(NSString *string) {
        return @(![string isEqualToString:@""]||string);
    }];
    @weakify(self);
    [[RACSignal combineLatest:@[startDateTimeSignal, endDateTimeSignal] reduce:^id(NSNumber *startSignal, NSNumber *endSignal){
        return @(startSignal.boolValue&&endSignal.boolValue);
    }] subscribeNext:^(NSNumber *isOn) {
        @strongify(self);
        self.confirmBtn.enabled = isOn.boolValue;
    }];
}

- (CGFloat)setupDatePickerWithIdent:(NSInteger)ident andToolbar:(UIToolbar *)toolbar lastOriginY:(CGFloat)originY{
    
    @autoreleasepool {
        
        CGRect dateTimeTitleRect = _bulrView.bounds;
        dateTimeTitleRect.size.height = vAdjustByScreenRatio(40.f);
        dateTimeTitleRect.size.width = vAdjustByScreenRatio(100.0f);
        InsetsLabel *dateTimeTitle = [[InsetsLabel alloc] initWithFrame:dateTimeTitleRect andEdgeInsetsValue:UIEdgeInsetsMake(0.0f, vAdjustByScreenRatio(10.0f), 0.0f, 0.0f)];
        
        
        UIEdgeInsets insetsValue = UIEdgeInsetsMake(0.0f, dateTimeTitleRect.size.width, 0.0f, 0.0f);
        CGRect dateTimeRect = CGRectZero;
        dateTimeRect.origin.y = originY;
        dateTimeRect.size = CGSizeMake(CGRectGetWidth(_bulrView.bounds), CGRectGetHeight(dateTimeTitleRect));
        IQDropDownTextField *dateTime = [[IQDropDownTextField alloc] initWithFrame:dateTimeRect andEdgeInsetsValue:insetsValue];
        dateTime.dropDownMode = IQDropDownModeDatePicker;
        dateTime.textAlignment = NSTextAlignmentCenter;
        dateTime.datePickerMode = UIDatePickerModeDateAndTime;
        dateTime.inputAccessoryView = toolbar;
        dateTime.delegate = self;
        dateTime.dateFormatter = _dateFormatter;
        dateTime.tag = vTextFieldTag+ident;
        [_bulrView addSubview:dateTime];
        [dateTime addSubview:dateTimeTitle];
        
        
        switch (ident) {
            case 0:
                self.startDateTime = dateTime;
                dateTimeTitle.text = [getLocalizationString(@"start_time") stringByAppendingString:@"："];
                dateTime.placeholder = getLocalizationString(@"start_time");
                break;
            case 1:
                self.endDateTime = dateTime;
                dateTimeTitle.text = [getLocalizationString(@"end_time") stringByAppendingString:@"："];
                dateTime.placeholder = getLocalizationString(@"end_time");
                break;
                
            default:
                break;
        }
        return CGRectGetMaxY(dateTimeRect);
    }
    
    
}

- (void)initializationUI {
    @autoreleasepool {
        self.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.6f];
        self.dateFormatter = [NSDateFormatter new];
        [_dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        self.bulrView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, vAdjustByScreenRatio(300.0f), vAdjustByScreenRatio(345.0f))];
        _bulrView.backgroundColor = [UIColor colorWithWhite:10.f alpha:0.89];
        _bulrView.center = CGPointMake(CGRectGetWidth(self.frame)/2.0f, CGRectGetHeight(self.frame)/2.0f);
        _bulrView.layer.cornerRadius = 6.0f;
        _bulrView.layer.masksToBounds = YES;
        [self addSubview:_bulrView];
        
        UIEdgeInsets insetsValue = UIEdgeInsetsMake(0.0f, vAdjustByScreenRatio(10.0f), 0.0f, 0.0f);
        CGRect customTitleRect = _bulrView.bounds;
        customTitleRect.size.height = vAdjustByScreenRatio(30.0f);
        InsetsLabel *customTitle = [[InsetsLabel alloc] initWithFrame:customTitleRect andEdgeInsetsValue:insetsValue];
        customTitle.text = getLocalizationString(@"plx_select_time_range");
        customTitle.backgroundColor = [UIColor colorWithRed:0.588f green:0.588f blue:0.588f alpha:1.00f];
        [_bulrView addSubview:customTitle];

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

        
        CGFloat lastOriginY = CGRectGetMaxY(customTitleRect)+vAdjustByScreenRatio(5.0f);
        for (int i=0; i<2; i++) {
            lastOriginY = [self setupDatePickerWithIdent:i andToolbar:toolBar lastOriginY:lastOriginY]+vAdjustByScreenRatio(5.0f);
        }
        
        UIColor *disableColor = [UIColor colorWithRed:0.600f green:0.600f blue:0.600f alpha:1.00f];
        UIColor *normalColor = CDZColorOfRed;
        
        self.confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _confirmBtn.frame = CGRectMake(0.0f, lastOriginY+vAdjustByScreenRatio(5.0f), CGRectGetWidth(_bulrView.frame)*0.8f, vAdjustByScreenRatio(35.0f));
        _confirmBtn.center = CGPointMake(CGRectGetWidth(_bulrView.frame)/2.0f, _confirmBtn.center.y);
        [_confirmBtn setTitle:getLocalizationString(@"ok") forState:UIControlStateNormal];
        [_confirmBtn setTitleColor:CDZColorOfWhite forState:UIControlStateNormal];
        [_confirmBtn setBackgroundImage:[ImageHandler createImageWithColor:normalColor withSize:_confirmBtn.bounds.size] forState:UIControlStateNormal];
        [_confirmBtn setTitleColor:CDZColorOfWhite forState:UIControlStateDisabled];
        [_confirmBtn setTitle:getLocalizationString(@"ok") forState:UIControlStateDisabled];
        [_confirmBtn setBackgroundImage:[ImageHandler createImageWithColor:disableColor withSize:_confirmBtn.bounds.size] forState:UIControlStateDisabled];
        [_confirmBtn addTarget:self action:@selector(timeSelectSubmit) forControlEvents:UIControlEventTouchUpInside];
        [_bulrView addSubview:_confirmBtn];
        
        
        CGRect shortcutBtnsTitleRect = customTitleRect;
        shortcutBtnsTitleRect.origin.y = CGRectGetMaxY(_confirmBtn.frame)+vAdjustByScreenRatio(10.0f);
        InsetsLabel *shortcutBtnsTitle = [[InsetsLabel alloc] initWithFrame:shortcutBtnsTitleRect andEdgeInsetsValue:insetsValue];
        shortcutBtnsTitle.text = getLocalizationString(@"shortcut_time_range");
        shortcutBtnsTitle.backgroundColor = [UIColor colorWithRed:0.588f green:0.588f blue:0.588f alpha:1.00f];
        [_bulrView addSubview:shortcutBtnsTitle];
        
        NSArray *titeList = @[@"2h",@"4h",@"6h",@"8h",
                              @"10h",@"16h",@"18h",@"24h"];
        
        __block CGRect btnsRect = CGRectZero;
        btnsRect.size = CGSizeMake(vAdjustByScreenRatio(60.0f), vAdjustByScreenRatio(40.0f));
        CGFloat columnSpace = (CGRectGetWidth(_bulrView.frame)-CGRectGetWidth(btnsRect)*4)/5;
        CGFloat rowSpace = (CGRectGetHeight(_bulrView.frame)-CGRectGetMaxY(shortcutBtnsTitleRect)-CGRectGetHeight(btnsRect)*2)/3;
        [titeList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            CGFloat column = idx%4;
            CGFloat row = idx/4;
            btnsRect.origin.x = columnSpace+(columnSpace+CGRectGetWidth(btnsRect))*column;
            btnsRect.origin.y = CGRectGetMaxY(shortcutBtnsTitleRect)+rowSpace+(rowSpace+CGRectGetHeight(btnsRect))*row;
            UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
            button.frame = btnsRect;
            [button setTitle:obj forState:UIControlStateNormal];
            [self.bulrView addSubview:button];
            [button setTag:vSCBtnsTag+idx];
            [button addTarget:self action:@selector(shortCutBtnsAction:) forControlEvents:UIControlEventTouchUpInside];
            button.backgroundColor = CDZColorOfLightGray;
        }];
        
    }
    
    
}

#pragma TextField Delegate
- (void)textField:(IQDropDownTextField*)textField didSelectItem:(NSString*)item {
    NSLog(@"%@",item);
    if (textField) {
        
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [(IQDropDownTextField *)textField setMaximumDate:[NSDate date]];
    if ([textField.text isEqualToString:@""]) {
            [(IQDropDownTextField *)textField setDate:[NSDate date]];
    }
    if (IS_IPHONE_4_OR_LESS) {
        [UIView animateWithDuration:0.25 animations:^{
            CGPoint point = self.bulrView.center;
            point.y -=CGRectGetMinY(self.bulrView.frame);
            self.bulrView.center = point;
        }];
    }
    return YES;
}

- (void)resignKeyboard{
    [self.startDateTime resignFirstResponder];
    [self.endDateTime resignFirstResponder];
    [UIView animateWithDuration:0.25 animations:^{
        CGPoint point = self.bulrView.center;
        point.y = CGRectGetHeight(self.frame)/2.0f;
        self.bulrView.center = point;
    }];
}

#pragma Pirvate Actions
- (void)timeSelectSubmit {
    [self resignKeyboard];
    if ([_startDateTime.text isEqualToString:@""]) {
        [SupportingClass showAlertViewWithTitle:nil message:@"请选择开始时间" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:nil];
        return;
    }
    if ([_endDateTime.text isEqualToString:@""]) {
        [SupportingClass showAlertViewWithTitle:nil message:@"请选择结束时间" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:nil];
        return;
    }
    self.completionBlock(_startDateTime.text, _endDateTime.text);
}

- (void)setDateSelectedResponseBlock:(DRSResponseBlock)block{
    self.completionBlock = block;
}

- (void)shortCutBtnsAction:(UIButton *)button {
    @autoreleasepool {
        NSInteger value = button.titleLabel.text.integerValue;
        NSDate *nowDate = [NSDate date];
        NSDate *minusDate = [self getMinusDate:nowDate withValue:value];
        NSLog(@"nowDate::::%@",[_dateFormatter stringFromDate:nowDate]);
        NSLog(@"minusDate::::%@",[_dateFormatter stringFromDate:minusDate]);
        
        if (self.completionBlock) {   
            self.completionBlock([_dateFormatter stringFromDate:minusDate], [_dateFormatter stringFromDate:nowDate]);
        }
    }
}

- (NSDate *)getMinusDate:(NSDate *)date withValue:(NSInteger)value {
    @autoreleasepool {
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
        [offsetComponents setHour:-(value)];
        // Calculate when, according to Tom Lehrer, World War III will end
        NSDate *theDate = [gregorian dateByAddingComponents:offsetComponents toDate:date options:0];
        return theDate;
    }
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    if (_bulrView) {
        _bulrView.center = CGPointMake(CGRectGetWidth(self.frame)/2.0f, CGRectGetHeight(self.frame)/2.0f);
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
