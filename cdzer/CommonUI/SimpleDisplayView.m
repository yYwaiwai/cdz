//
//  SimpleDisplayView.m
//  cdzer
//
//  Created by KEns0n on 3/4/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#define vMinWidthRatio 232.0f/vMinPhoneWidth
#define vMinHeight vAdjustByScreenRatio(36.0f)
#define vStartOffSetX   vAdjustByScreenRatio(25.0f)

#import "SimpleDisplayView.h"

@interface SimpleDisplayView () <UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, strong) NSString *placeHolder;

@property (nonatomic, strong) UITextField *textField;

@property (nonatomic, strong) UIPickerView *pickerView;

@property (nonatomic, assign) SimpleDisplayView *psdvtf;

@property (nonatomic, assign) SimpleDisplayView *nsdvtf;

@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation SimpleDisplayView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setBackgroundColor:CDZColorOfWhite];
        self.layer.borderColor = [[UIColor colorWithRed:0.882f green:0.882f blue:0.882f alpha:1.00f] CGColor];
        self.layer.borderWidth = 1.0f;
        self.textString = @"";
        self.placeHolder = @"";
    }
    
    return self;
}

- (void)initializationUIWithType:(SDVType)type iConImage:(NSString *)imageName imageType:(FMImageType)imageType placeHolder:(NSString *)placeHolder {
    _sdvType = type;
    @autoreleasepool {
        self.placeHolder = placeHolder;
        UIImageView *iConImageView = nil;
        if (imageName) {
            UIImage *iConImage = [ImageHandler getImageFromCacheByScreenRatioWithFileRootPath:kSysImageCaches
                                                                                     fileName:imageName
                                                                                         type:imageType
                                                                              scaleWithPhone4:NO
                                                                                  offsetRatioForP4:1.0f
                                                                                 needToUpdate:YES];
            if (iConImage) {
                CGFloat offSetY = (CGRectGetHeight(self.frame)-iConImage.size.height)/2;
                iConImageView = [[UIImageView alloc] initWithFrame:CGRectMake(vStartOffSetX, offSetY, iConImage.size.width, iConImage.size.width)];
                [iConImageView setImage:iConImage];
                [self addSubview:iConImageView];
            }
        }
        CGFloat viewStartOffsetX = vStartOffSetX;
        if (iConImageView) viewStartOffsetX = CGRectGetMaxX(iConImageView.frame)+10.0f*vWidthRatio;
        CGRect commonRect = CGRectMake(viewStartOffsetX, 0.0f, CGRectGetWidth(self.frame)-viewStartOffsetX, CGRectGetHeight(self.frame));
        
        if (type==SDVTypePickerView) {
            if (!_dataArray) self.dataArray = [NSMutableArray array];
            if (_dataArray.count>=1) [_dataArray replaceObjectAtIndex:0 withObject:getLocalizationString(placeHolder)];
            if (_dataArray.count==0) [_dataArray addObject:getLocalizationString(placeHolder)];
            
            self.pickerView = [UIPickerView new];
            [_pickerView setTag:903];
            [_pickerView setDelegate:self];
            [_pickerView setDataSource:self];
        }
        
        if (type==SDVTypeTextField||type==SDVTypePickerView) {
            self.textField = [[UITextField alloc] initWithFrame:commonRect];
            [_textField setTag:901];
            [_textField setDelegate:self];
            [_textField setPlaceholder:getLocalizationString(placeHolder)];
            [self addSubview:_textField];
            if(type==SDVTypePickerView){
                [_textField setInputView:self.pickerView];
            }
        }
        
        if (type==SDVTypeButtonTouch||type==SDVTypePickerView) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setFrame:commonRect];
            [button.titleLabel setFont:systemFont(17.0f)];
            [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [button setTag:902];
            if(type==SDVTypeButtonTouch){
                [button setTitle:getLocalizationString(placeHolder) forState:UIControlStateNormal];
            }else {
                [button addTarget:_textField action:@selector(becomeFirstResponder) forControlEvents:UIControlEventTouchUpInside];
            }
            [self addSubview:button];
        }
    }
}

- (void)setFrame:(CGRect)frame {
    
    frame.origin.y += (IS_IPHONE_6||IS_IPHONE_6P)?vO2OSpaceSpace:vO2OSpaceSpace*0.5f;
    
    if (CGRectGetWidth(frame) < CGRectGetWidth([UIScreen mainScreen].bounds)*vMinWidthRatio){
        frame.size.width = CGRectGetWidth([UIScreen mainScreen].bounds)*vMinWidthRatio;
    }
    
    if (CGRectGetHeight(frame) != vMinHeight) {
        frame.size.height = vMinHeight;
    }
    [super setFrame:frame];
}

- (BOOL)textFieldGetFirstResponder {
    if (![self viewWithTag:901]) return NO;
    return [[self viewWithTag:901] becomeFirstResponder];
}

- (BOOL)textFieldResignFirstResponder {
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect rect = self.superview.frame;
        rect.origin.y = 0;
        [self.superview setFrame:rect];
    }];
    if (![self viewWithTag:901]) return NO;
    return [[self viewWithTag:901] resignFirstResponder];
}

- (void)buttonTouchAddTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents {
    UIButton *button = (UIButton *)[self viewWithTag:902];
    if (!button) return;
    [button addTarget:target action:action forControlEvents:controlEvents];
}

- (void)setPreviousSDVTF:(SimpleDisplayView *)psdvtf andNextSDVTF:(SimpleDisplayView *)nsdvtf {
    _psdvtf = psdvtf;
    _nsdvtf = nsdvtf;
}

- (void)setTFInputAccessoryView:(UIView *)accessoryView {
    if (!_textField) return;
    [_textField setInputAccessoryView:accessoryView];
}

- (void)setPickerViewData:(NSArray *)dataArray {
    if (!dataArray) return;
    if (!_dataArray) self.dataArray = [NSMutableArray array];
    if (_dataArray.count == 0) [_dataArray insertObject:_placeHolder atIndex:0];
    if (_dataArray.count == 1) [_dataArray replaceObjectAtIndex:0 withObject:_placeHolder];
    if (_dataArray.count > 1) [_dataArray removeObjectsInRange:NSMakeRange(1, [_dataArray count]-1)];
    [_dataArray addObjectsFromArray:dataArray];
    if (_pickerView) [_pickerView reloadComponent:0];
}

- (void)setAccessibilityIdentifierByID:(NSInteger)theIdenID {
    if (_sdvType != SDVTypeTextField) return;
    
    NSString *accessibilityIdentifier = [@"SDVTextField:" stringByAppendingFormat:@"%02ld",(long)theIdenID];
    
    [super setAccessibilityIdentifier:accessibilityIdentifier];
}

#pragma mark- UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField {
    _textString = textField.text;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    CGFloat keyboardOffsetY = CGRectGetHeight([UIScreen mainScreen].bounds)-[SupportingClass getKeyboardHeight];
    CGFloat extHeight = vO2OSpaceSpace*1.25*vWidthRatio+vMinHeight;
    CGFloat maxYofSelfView = CGRectGetMaxY(self.frame)+vNavBarHeight+extHeight;
    if (maxYofSelfView > keyboardOffsetY) {
        CGRect rect = self.superview.frame;
        rect.origin.y = keyboardOffsetY - maxYofSelfView;
        [UIView animateWithDuration:0.3 animations:^{
            self.superview.frame = rect;
        }];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (_nsdvtf) {
        return [_nsdvtf textFieldGetFirstResponder];
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect rect = self.superview.frame;
        rect.origin.y = 0;
        [self.superview setFrame:rect];
    }];
    
    return [textField resignFirstResponder];
}

#pragma mark- UIPickerViewDelegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if (!_dataArray) return 0;
    return _dataArray.count;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    @autoreleasepool {
        UILabel *labelText = [UILabel new];
        [labelText setTextAlignment:NSTextAlignmentCenter];
        labelText.backgroundColor = [UIColor clearColor];
        labelText.font = [UIFont boldSystemFontOfSize:20.0];
        labelText.textColor = [UIColor blackColor];
        [labelText setText:_dataArray[row]];
        
        if (row == 0)
        {
            labelText.font = [UIFont boldSystemFontOfSize:30.0];
            labelText.textColor = [UIColor lightGrayColor];
        }
        return labelText;
    }
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.selectedIndex = row;
    _textField.text = @"";
    if (row != 0) {
        _textField.text = _dataArray[row];
    }
    
}
@end
