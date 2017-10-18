//
//  QueryPriceView.m
//  cdzer
//
//  Created by 车队长 on 16/9/14.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "QueryPriceView.h"
#import "UIView+LayoutConstraintHelper.h"
@interface QueryPriceView() <UITextFieldDelegate>
@property (nonatomic, strong) NSArray *constraints;

@end

@implementation QueryPriceView

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.nameTF.shouldStopPCDAction = YES;
    self.phoneTF.shouldStopPCDAction = YES;
    self.cityTF.shouldStopPCDAction = YES;
    self.cgzxTF.shouldStopPCDAction = YES;
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(textFieldTextDidChange:) name:UITextFieldTextDidChangeNotification object:self.nameTF];
    
    
   
    
    
    UIToolbar *toolBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), 40)];
    UIBarButtonItem *spaceButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                target:self
                                                                                action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]initWithTitle:getLocalizationString(@"finish")
                                                                  style:UIBarButtonItemStyleDone
                                                                 target:self
                                                                 action:@selector(resignKeyboard)];
    [toolBar setItems:@[spaceButton, doneButton]];
    self.nameTF.inputAccessoryView = toolBar;
    self.phoneTF.inputAccessoryView = toolBar;
}

- (void)resignKeyboard {
    [self endEditing:YES];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.xjBgView.layer setCornerRadius:3.0];
    [self.xjBgView.layer setMasksToBounds:YES];
    
    [self.view1 setViewBorderWithRectBorder:UIRectBorderTop borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self.mView setViewBorderWithRectBorder:UIRectBorderTop borderSize:0.5 withColor:nil withBroderOffset:nil];
}

- (void)showView {
    [self removeFromSuperview];
    UIWindow *window = UIApplication.sharedApplication.keyWindow;
    [window addSubview:self];
    if (!self.constraints) {
        self.constraints = [self addSelfByFourMarginToSuperview:window];
    }else {
        [window addConstraints:self.constraints];
    }
    @weakify(self);
    [UIView animateWithDuration:0.25 animations:^{
        @strongify(self);
        self.alpha = 1;
        
    }];
    [self setNeedsUpdateConstraints];
    [self setNeedsDisplay];
    [self setNeedsLayout];
    
}

- (IBAction)hiddenView {
    @weakify(self);
    [UIView animateWithDuration:0.25 animations:^{
        @strongify(self);
        self.alpha = 0;
        self.nameTF.text=@"";
        self.phoneTF.text=@"";
        self.cityTF.text=@"";
        self.cgzxTF.text=@"";
        
    } completion:^(BOOL finished) {
        @strongify(self);
        [self removeFromSuperview];
    }];
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([textField isFirstResponder]) {
        if ([[[textField textInputMode] primaryLanguage] isEqualToString:@"emoji"] || ![[textField textInputMode] primaryLanguage]) {
            return NO;
        }
    }
    if (textField==self.nameTF) {
        if ([string stringByTrimmingCharactersInSet:NSCharacterSet.symbolCharacterSet.invertedSet].length>0) {
            return NO;
        }
    }
    
    if (textField==self.phoneTF) {
        if (textField.text.length==0&&![string isEqualToString:@"1"]) {
            return NO;
        }
        if (textField.text.length>=11&&![string isEqualToString:@""]) {
            return NO;
        }
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
}

- (void)textFieldTextDidChange:(NSNotification *)notiObj {
    NSUInteger maxLenght = 20;
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
}

@end
