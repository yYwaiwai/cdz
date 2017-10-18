//
//  EServicePaymentCreditView.m
//  cdzer
//
//  Created by KEns0nLau on 6/14/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#define kDefaultTitleSize 13
#define kDefaultTitle @"获取验证码"
#define kCountDownTitle(count) [NSString stringWithFormat:@"%d秒后再获取",count]
#define kLastEServieCreditValidCodeDate @"LastEServieCreditValidCodeDate"
#import "EServicePaymentCreditView.h"
#import "AFViewShaker.h"
#import "UserInfosDTO.h"

@interface EServicePaymentCreditView () {
    NSTimer *_timer;
    NSTimeInterval _timeInterval;
    NSInteger _totalCount;
}

@property (nonatomic, weak) IBOutlet UIView *reminderLabel;

@property (nonatomic, weak) IBOutlet UIView *verifyView;

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;

@property (nonatomic, weak) IBOutlet UITextField *textField;

@property (nonatomic, weak) IBOutlet UIButton *verifyCodeBtn;

@property (nonatomic, weak) IBOutlet UIButton *cancelBtn;

@property (nonatomic, weak) IBOutlet UIButton *confimBtn;

@property (nonatomic, strong) AFViewShaker *viewShaker;

@property (nonatomic, assign) BOOL isRequested;

@end

@implementation EServicePaymentCreditView

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
    
    if ([_timer isValid]) {
        [_timer invalidate];
    }
    _timer = nil;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.verifyView setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:5.0f];
    [self.verifyCodeBtn setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:5.0f];
    
    [self.cancelBtn setViewBorderWithRectBorder:UIRectBorderTop|UIRectBorderRight borderSize:0.5 withColor:nil withBroderOffset:nil];
     [self.confimBtn setViewBorderWithRectBorder:UIRectBorderTop|UIRectBorderLeft borderSize:0.5 withColor:nil withBroderOffset:nil];
     self.viewShaker = [[AFViewShaker alloc] initWithView:self.textField];
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    self.isRequested = NO;
    
    NSDictionary *ntAttrDict = @{NSFontAttributeName:[self.verifyCodeBtn.titleLabel.font fontWithSize:12]};
    NSMutableAttributedString *normalTitle = [[NSMutableAttributedString alloc] initWithString:kDefaultTitle attributes:ntAttrDict];
    [self.verifyCodeBtn setAttributedTitle:normalTitle forState:UIControlStateNormal];
    [self.verifyCodeBtn setAttributedTitle:normalTitle forState:UIControlStateHighlighted];
    
    NSDictionary *attrDict = @{NSFontAttributeName:[self.verifyCodeBtn.titleLabel.font fontWithSize:11]};
    NSMutableAttributedString *disableTitle = [[NSMutableAttributedString alloc] initWithString:kDefaultTitle attributes:attrDict];
    [self.verifyCodeBtn setAttributedTitle:disableTitle forState:UIControlStateDisabled];
    self.verifyCodeBtn.backgroundColor = [UIColor colorWithRed:0.314 green:0.780 blue:0.953 alpha:1.00];
    UIControlContentHorizontalAlignment contentAlignment = UIControlContentHorizontalAlignmentCenter;
    self.verifyCodeBtn.contentHorizontalAlignment = contentAlignment;
    NSNumber *timeNumber = [NSUserDefaults.standardUserDefaults objectForKey:kLastEServieCreditValidCodeDate];
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
    [self.verifyCodeBtn addTarget:self action:@selector(startCountDown) forControlEvents:UIControlEventTouchUpInside];
}

- (NSString *)getVerifyCode {
    return self.textField.text;
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
        [NSUserDefaults.standardUserDefaults setObject:@(newInterval) forKey:kLastEServieCreditValidCodeDate];
        [NSUserDefaults.standardUserDefaults synchronize];
    }
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateCountDown) userInfo:nil repeats:YES];
    NSDictionary *attrDict = @{NSFontAttributeName:[self.verifyCodeBtn.titleLabel.font fontWithSize:11]};
    self.verifyCodeBtn.backgroundColor = CDZColorOfDeepGray;
    NSMutableAttributedString *disableTitle = [[NSMutableAttributedString alloc] initWithString:kCountDownTitle(_totalCount) attributes:attrDict];
    [self.verifyCodeBtn setAttributedTitle:disableTitle forState:UIControlStateDisabled];
    
    [self setVerifyCodeBtnEnable:NO];
    self.isRequested = YES;
}

- (void)startCountDown {
    [self changeTimeDisplayStatus];
}

- (void)updateCountDown {
    _totalCount--;
    if (_totalCount<0) {
        [self stopCountDown];
        return;
    }
    NSDictionary *attrDict = @{NSFontAttributeName:[self.verifyCodeBtn.titleLabel.font fontWithSize:11]};
    self.verifyCodeBtn.backgroundColor = CDZColorOfDeepGray;
    NSMutableAttributedString *disableTitle = [[NSMutableAttributedString alloc] initWithString:kCountDownTitle(_totalCount) attributes:attrDict];
    [self.verifyCodeBtn setAttributedTitle:disableTitle forState:UIControlStateDisabled];
}

- (void)stopCountDown{
    if ([_timer isValid]) {
        [_timer invalidate];
    }
    _timer = nil;
    _totalCount = -1;
    _timeInterval = 0;
    
    NSDictionary *attrDict = @{NSFontAttributeName:[self.verifyCodeBtn.titleLabel.font fontWithSize:11]};
    NSMutableAttributedString *disableTitle = [[NSMutableAttributedString alloc] initWithString:kDefaultTitle attributes:attrDict];
    [self.verifyCodeBtn setAttributedTitle:disableTitle forState:UIControlStateDisabled];
    [NSUserDefaults.standardUserDefaults removeObjectForKey:kLastEServieCreditValidCodeDate];
    self.verifyCodeBtn.enabled = YES;
    self.verifyCodeBtn.backgroundColor = [UIColor colorWithRed:0.314 green:0.780 blue:0.953 alpha:1.00];
}

- (void)setVerifyCodeBtnEnable:(BOOL)enabled {
    if (_totalCount>=0) {
        enabled = NO;
    }
    self.verifyCodeBtn.enabled = enabled;
}

- (void)excuteError {
    [self stopCountDown];
    self.isRequested = NO;
    self.verifyCodeBtn.enabled = YES;
}

- (void)showView {
    UIWindow *window = UIApplication.sharedApplication.keyWindow;
    self.frame = window.bounds;
    self.translatesAutoresizingMaskIntoConstraints = YES;
    [window addSubview:self];
}

- (IBAction)dismissSelf {
    [self removeFromSuperview];
}

- (IBAction)confirmBtn {
    if (self.textField.text.length<4) {
        [self.viewShaker shake];
        self.reminderLabel.alpha = 1;
        @weakify(self);
        [UIView animateWithDuration:0.25 delay:2.5 options:UIViewAnimationOptionCurveEaseOut animations:^{
            @strongify(self);
            self.reminderLabel.alpha = 0;
        } completion:nil];
        return;
    }
    if (self.responseBlock) {
        self.responseBlock ();
    }
}

#pragma mark - 请求验证码
- (IBAction)requestVerifyCode {
    @weakify(self);
    [UserBehaviorHandler.shareInstance userRequestEserviceVerifyCodeWithSuccess:^(){
        UserInfosDTO *dto = [DBHandler.shareInstance getUserInfo];
        NSString *userPhone = dto.telphone;
        if (userPhone.length!=11) {
            userPhone = @"***********";
        }else {
            userPhone = [userPhone stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
        }
        self.titleLabel.text = [NSString stringWithFormat:@"已向绑定的手机%@发送验证码，请输入", userPhone];
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
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
