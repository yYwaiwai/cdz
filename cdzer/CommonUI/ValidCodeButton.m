//
//  ValidCodeButton.m
//  cdzer
//
//  Created by KEns0n on 7/10/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#define kDefaultTitle @"获取验证码"
#define kDefaultTitleSize 16
#define kCountDownTitle(count) [NSString stringWithFormat:@"%d秒后再获取",count]
#define kLastRegisterValidCodeDate @"LastRegisterValidCodeDate"
#define kLastForgetPWValidCodeDate @"LastForgetPWValidCodeDate"
#define kLastOrderCreditValidCodeDate @"LastOrderCreditValidCodeDate"

#import "ValidCodeButton.h"

@interface ValidCodeButton ()
{
    NSTimer *_timer;
    NSTimeInterval _timeInterval;
    NSInteger _totalCount;
    BOOL _isRequested;
}
@property (nonatomic, assign) VCBType VCBButtonType;

@property (nonatomic, assign) BOOL wasError;

@end

@implementation ValidCodeButton
@synthesize requestedValidCode = _isRequested;


- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
    
    if ([_timer isValid]) {
        [_timer invalidate];
    }
    _timer = nil;
}

- (void)buttonSettingWithType:(VCBType)buttonType {
    self.VCBButtonType = buttonType;
    self.isRequested = NO;
    
    NSDictionary *ntAttrDict = @{NSFontAttributeName:[UIFont systemFontOfSize:10.0f],
                                 NSForegroundColorAttributeName:CDZColorOfWhite};
    NSMutableAttributedString *normalTitle = [[NSMutableAttributedString alloc] initWithString:kDefaultTitle attributes:ntAttrDict];
    [self setAttributedTitle:normalTitle forState:UIControlStateNormal];
    [self setAttributedTitle:normalTitle forState:UIControlStateHighlighted];
    
    NSDictionary *attrDict = @{NSFontAttributeName:[UIFont systemFontOfSize:10.0f],
                               NSForegroundColorAttributeName:CDZColorOfDeepGray};
    NSMutableAttributedString *disableTitle = [[NSMutableAttributedString alloc] initWithString:kDefaultTitle attributes:attrDict];
    [self setAttributedTitle:disableTitle forState:UIControlStateDisabled];
    
    UIControlContentHorizontalAlignment contentAlignment = UIControlContentHorizontalAlignmentCenter;
    self.contentHorizontalAlignment = contentAlignment;
    NSNumber *timeNumber = [NSUserDefaults.standardUserDefaults objectForKey:self.getObjKey];
    _totalCount = -1;
    if (timeNumber) {
        _timeInterval = timeNumber.doubleValue;
        NSTimeInterval newInterval = [[NSDate date] timeIntervalSince1970];
        NSInteger result = newInterval-_timeInterval;
        if (result<60) {
            [self changeTimeDisplayStatus];
        }else {
            _timeInterval = 0;
        }
    }
    [self addTarget:self action:@selector(startCountDown) forControlEvents:UIControlEventTouchUpInside];
    [self addTarget:self action:@selector(getValidCode) forControlEvents:UIControlEventTouchUpInside];
    
}

- (NSString *)getObjKey {
    if (_VCBButtonType==VCBTypeOfPWForgetValid) return kLastForgetPWValidCodeDate;
    
    if (_VCBButtonType==VCBTypeOfOrderCreditValid) return kLastOrderCreditValidCodeDate;
    
    return kLastRegisterValidCodeDate;
}

- (void)changeTimeDisplayStatus {
    if ([_timer isValid]) {
        [_timer invalidate];
    }
    _timer = nil;
    _totalCount = 60;
    if (_timeInterval!=0) {
        NSTimeInterval newInterval = [[NSDate date] timeIntervalSince1970];
        NSTimeInterval result = newInterval-_timeInterval;
        if (result<60) {
            _totalCount = 60-result;
        }
    }else {
        NSTimeInterval newInterval = [[NSDate date] timeIntervalSince1970];
        _timeInterval = newInterval;
        [NSUserDefaults.standardUserDefaults setObject:@(newInterval) forKey:self.getObjKey];
        [NSUserDefaults.standardUserDefaults synchronize];
    }
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateCountDown) userInfo:nil repeats:YES];
    NSDictionary *attrDict = @{NSFontAttributeName:[UIFont systemFontOfSize:10.0f],
                               NSForegroundColorAttributeName:CDZColorOfDeepGray};
    NSMutableAttributedString *disableTitle = [[NSMutableAttributedString alloc] initWithString:kCountDownTitle(_totalCount) attributes:attrDict];
    [self setAttributedTitle:disableTitle forState:UIControlStateDisabled];
    
    self.enabled = NO;
    self.isRequested = YES;
}

- (void)startCountDown{
    if (!_userPhone&&self.VCBButtonType!=VCBTypeOfOrderCreditValid) {
        return;
    }
    [self changeTimeDisplayStatus];
}

- (void)updateCountDown {
    _totalCount--;
    if (_totalCount<0) {
        [self stopCountDown];
        return;
    }
    NSDictionary *attrDict = @{NSFontAttributeName:[UIFont systemFontOfSize:10.0f],
                               NSForegroundColorAttributeName:CDZColorOfDeepGray};
    NSMutableAttributedString *disableTitle = [[NSMutableAttributedString alloc] initWithString:kCountDownTitle(_totalCount) attributes:attrDict];
    [self setAttributedTitle:disableTitle forState:UIControlStateDisabled];
    if (self.shouldChangBGColor) {
        self.backgroundColor = [UIColor lightGrayColor];
    }
}

- (void)stopCountDown{
    if ([_timer isValid]) {
        [_timer invalidate];
    }
    _timer = nil;
    _totalCount = -1;
    _timeInterval = 0;
    
    NSDictionary *attrDict = @{NSFontAttributeName:[UIFont systemFontOfSize:10.0f],
                               NSForegroundColorAttributeName:CDZColorOfDeepGray};
    NSMutableAttributedString *disableTitle = [[NSMutableAttributedString alloc] initWithString:kDefaultTitle attributes:attrDict];
    [self setAttributedTitle:disableTitle forState:UIControlStateDisabled];
    
    if (self.shouldChangBGColor) {
        self.backgroundColor = [UIColor colorWithHexString:@"49C7F5"];
    }
    
    [NSUserDefaults.standardUserDefaults removeObjectForKey:self.getObjKey];
    if (_VCBButtonType==VCBTypeOfOrderCreditValid) {
        self.isReady = YES;
    }
    self.enabled = YES;
}

- (void)setIsRequested:(BOOL)isRequested {
    _isRequested = isRequested;
}

- (BOOL)isRequested {
    return _isRequested;
}

- (void)setEnabled:(BOOL)enabled {
    if (_totalCount>=0||!_isReady) {
        enabled = NO;
    }
    [super setEnabled:enabled];
}

- (void)excuteError {
    self.wasError = YES;
    [self stopCountDown];
    self.isRequested = NO;
    self.enabled = YES;
}

#pragma mark - 请求验证码
- (void)getValidCode {
    if (!_userPhone&&_VCBButtonType!=VCBTypeOfOrderCreditValid) {
        return;
    }
    self.wasError = NO;
    @weakify(self);
    if (_VCBButtonType==VCBTypeOfRegisterValid) {
        
        [UserBehaviorHandler.shareInstance userRequestRegisterValidCodeWithUserPhone:_userPhone.stringValue success:^(NSString *code){
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:@"验证码请求成功"
                                    isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil
                      clickedButtonAtIndexWithBlock:nil];
            
        } failure:^(NSString *errorMessage, NSError *error) {
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:errorMessage
                                    isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil
                      clickedButtonAtIndexWithBlock:nil];
            @strongify(self);
            [self excuteError];
        }];
        
    }else if(_VCBButtonType==VCBTypeOfPWForgetValid) {
        
        [UserBehaviorHandler.shareInstance userRequestForgotPasswordValidCodeWithUserPhone:_userPhone.stringValue success:^(NSString *code){
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:@"验证码请求成功"
                                    isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil
                      clickedButtonAtIndexWithBlock:nil];
            
        } failure:^(NSString *errorMessage, NSError *error) {
            
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:errorMessage
                                    isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil
                      clickedButtonAtIndexWithBlock:nil];
            @strongify(self);
            [self excuteError];
        }];
        
    }else if(_VCBButtonType==VCBTypeOfOrderCreditValid){
        
        [UserBehaviorHandler.shareInstance userRequestCreditValidCodeWithSuccessBlock:^(NSString *code){
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:@"验证码请求成功"
                                    isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil
                      clickedButtonAtIndexWithBlock:nil];
            
        } failure:^(NSString *errorMessage, NSError *error) {
            
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:errorMessage
                                    isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil
                      clickedButtonAtIndexWithBlock:nil];
            @strongify(self);
            [self excuteError];
        }];
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
