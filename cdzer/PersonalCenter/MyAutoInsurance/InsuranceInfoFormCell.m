//
//  InsuranceInfoFormCell.m
//  cdzer
//
//  Created by KEns0n on 10/12/15.
//  Copyright © 2015 CDZER. All rights reserved.
//

#define vSegmentedControlFont vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 13.0f, NO)

#import "InsuranceInfoFormCell.h"
#import "InsetsLabel.h"
#import "InsetsTextField.h"
#import "IQDropDownTextField.h"
#import "KeyCityDTO.h"
@interface InsuranceInfoFormCell() <IQDropDownTextFieldDelegate>

@property (nonatomic, strong) InsetsLabel *titleLabel;

@property (nonatomic, strong) UIControl *inputContentView;

@property (nonatomic, strong) InsetsLabel *extLabel;

@property (nonatomic, strong) InsetsLabel *contentLabel;

@property (nonatomic, strong) InsetsTextField *inputTextField;

@property (nonatomic, strong) UISegmentedControl *segmentedControl;

@property (nonatomic, strong) UISwitch *switchControl;

@property (nonatomic, strong) UIImageView *arrowImageView;

@property (nonatomic, strong) IQDropDownTextField *dateTimeTextField;

@property (nonatomic, assign) MAIIFType type;

@property (nonatomic, assign) CGRect keyboardRect;

@property (nonatomic, assign) CGPoint lastPoint;

@property (nonatomic) SEL responseAction;

@property (nonatomic, assign) NSUInteger textLimit;

@end

@implementation InsuranceInfoFormCell

- (void)dealloc {
    self.scrollView = nil;
    self.actionTarget = nil;
    self.indexPath = nil;
    self.responseAction = NULL;
    [NSNotificationCenter.defaultCenter removeObserver:self];
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initializationUI];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    
    if (!_arrowImageView.hidden) {
        self.accessoryView = _arrowImageView;
    }
    
    if (!_switchControl.hidden) {
        self.accessoryView = _switchControl;
    }
    
    if (!_segmentedControl.hidden&&_segmentedControl.numberOfSegments>0) {
        CGFloat totalWidth = 0.0f;
        for (NSUInteger i=0; i<_segmentedControl.numberOfSegments; i++) {
            NSString *string = [_segmentedControl titleForSegmentAtIndex:i];
            CGFloat width = [SupportingClass getStringSizeWithString:string font:vSegmentedControlFont widthOfView:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)].width+5.0f;
            [_segmentedControl setWidth:width forSegmentAtIndex:i];
            totalWidth +=width;
        }
        CGRect segmentedFrame = _segmentedControl.frame;
        segmentedFrame.size = CGSizeMake(totalWidth, 32.0f);
        _segmentedControl.frame = segmentedFrame;
        self.accessoryView = _segmentedControl;
    }
    
    if (self.accessoryView) {
        CGRect theFrame = self.accessoryView.frame;
        theFrame.origin.x = CGRectGetWidth(self.frame)-CGRectGetWidth(theFrame)-15.0f;
        self.accessoryView.frame = theFrame;
        
        CGRect contentViewFrame = self.contentView.frame;
        contentViewFrame.size.width = CGRectGetWidth(self.frame);
        self.contentView.frame = contentViewFrame;
        
        self.contentLabel.edgeInsets = UIEdgeInsetsMake(0.0f, 5.0f, 0.0f, CGRectGetWidth(self.accessoryView.frame)+15.0f);
    }
    
    
    CGFloat titleWidth = [SupportingClass getStringSizeWithString:_titleLabel.text font:_titleLabel.font widthOfView:CGSizeMake(CGFLOAT_MAX, CGRectGetHeight(_titleLabel.frame))].width;
    CGRect titleFrame = _titleLabel.frame;
    titleFrame.size.width = _titleLabel.edgeInsets.left+titleWidth;
    _titleLabel.frame = titleFrame;
    
    CGRect contentViewframe = _inputContentView.frame;
    contentViewframe.origin.x = CGRectGetMaxX(_titleLabel.frame);
    contentViewframe.size.width = CGRectGetWidth(self.contentView.frame)-CGRectGetMaxX(_titleLabel.frame);
    _inputContentView.frame = contentViewframe;
    
    if (!_inputContentView.hidden) {
        BOOL extLabelShow = (!_extLabel.hidden&&_extLabel.text&&![_extLabel.text isEqualToString:@""]);

        if (extLabelShow) {
            CGFloat width = [SupportingClass getStringSizeWithString:_extLabel.text font:_extLabel.font widthOfView:CGSizeMake(CGFLOAT_MAX, CGRectGetHeight(_extLabel.frame))].width;
            CGRect frame = _extLabel.frame;
            frame.size.width = _extLabel.edgeInsets.left+_extLabel.edgeInsets.right+width;
            frame.origin.x = CGRectGetWidth(_inputContentView.frame)-CGRectGetWidth(frame);
            _extLabel.frame = frame;
        }
        
        if (!_contentLabel) {
            CGRect frame = _inputContentView.bounds;
            _contentLabel.frame = frame;
        }
        
        if (!_inputTextField.hidden) {
            _inputTextField.textAlignment = NSTextAlignmentCenter;
            CGRect frame = _inputTextField.frame;
            frame.size.width = CGRectGetWidth(_inputContentView.frame)-(extLabelShow?CGRectGetWidth(_extLabel.frame):0);
            _inputTextField.frame = frame;
        }
        
        if (!_dateTimeTextField.hidden) {
            _dateTimeTextField.textAlignment = NSTextAlignmentCenter;
            CGRect frame = _dateTimeTextField.frame;
            frame.size.width = CGRectGetWidth(_inputContentView.frame)-(extLabelShow?CGRectGetWidth(_extLabel.frame):0);
            _dateTimeTextField.frame = frame;
        }
    }
    
    if (_type!=MAIIFTypeOfSpace) {
        UIRectBorder border = UIRectBorderBottom;
        
        if (_indexPath.row==0) {
            border = UIRectBorderBottom|UIRectBorderTop;
        }

        [self.contentView setViewBorderWithRectBorder:border borderSize:0.5f withColor:CDZColorOfSeperateLineDeepColor withBroderOffset:nil];
    }
    
}

- (void)initializationUI {
    @autoreleasepool {
        
        UIToolbar *toolBar =  [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), 40.0f)];
        [toolBar setBarStyle:UIBarStyleDefault];
        UIBarButtonItem *spaceButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                    target:self
                                                                                    action:nil];
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]initWithTitle:getLocalizationString(@"finish")
                                                                      style:UIBarButtonItemStyleDone
                                                                     target:self
                                                                     action:@selector(hiddenKeyboard)];
        NSArray * buttonsArray = [NSArray arrayWithObjects:spaceButton,doneButton,nil];
        [toolBar setItems:buttonsArray];

        
        self.titleLabel = InsetsLabel.new;
        _titleLabel.frame = self.contentView.bounds;
        _titleLabel.edgeInsets = UIEdgeInsetsMake(0.0f, 15.0f, 0.0f, 0.0f);
        _titleLabel.numberOfLines = 0;
        [self.contentView addSubview:_titleLabel];
        
        self.inputContentView = UIControl.new;
        _inputContentView.frame = self.contentView.bounds;
        [self.contentView addSubview:_inputContentView];
        
        self.contentLabel = InsetsLabel.new;
        _contentLabel.numberOfLines = 0;
        _contentLabel.frame = self.contentView.bounds;
        _contentLabel.edgeInsets = UIEdgeInsetsMake(0.0f, 5.0f, 0.0f, 15.0f);
        [_inputContentView addSubview:_contentLabel];
        
        self.extLabel = InsetsLabel.new;
        _extLabel.numberOfLines = 0;
        _extLabel.frame = self.contentView.bounds;
        _extLabel.edgeInsets = UIEdgeInsetsMake(0.0f, 5.0f, 0.0f, 15.0f);
        [_inputContentView addSubview:_extLabel];
        
        self.inputTextField = InsetsTextField.new;
        _inputTextField.frame = self.contentView.bounds;
        _inputTextField.delegate = self;
        _inputTextField.inputAccessoryView = toolBar;
        _inputTextField.keyboardType = UIKeyboardTypeDefault;
        [_inputContentView addSubview:_inputTextField];
        
        self.dateTimeTextField = IQDropDownTextField.new;
        _dateTimeTextField.frame = self.contentView.bounds;
        _dateTimeTextField.delegate = self;
        _dateTimeTextField.inputAccessoryView = toolBar;
        _dateTimeTextField.dropDownMode = IQDropDownModeDatePicker;
        _dateTimeTextField.datePickerMode = UIDatePickerModeDate;
        [_dateTimeTextField.dateFormatter setDateFormat:@"yyyy-MM-dd"];
        [_inputContentView addSubview:_dateTimeTextField];
        
        self.switchControl = UISwitch.new;
        [_switchControl addTarget:self action:@selector(controlValueChange:) forControlEvents:UIControlEventValueChanged];
        _switchControl.on = NO;
        
        
        self.segmentedControl = UISegmentedControl.new;
        _segmentedControl.apportionsSegmentWidthsByContent = YES;
        _segmentedControl.tintColor = CDZColorOfDefaultColor;
        [_segmentedControl addTarget:self action:@selector(controlValueChange:) forControlEvents:UIControlEventValueChanged];
        
        NSDictionary *selectedFont = @{NSFontAttributeName:vSegmentedControlFont};
        
        [_segmentedControl setTitleTextAttributes:selectedFont forState:UIControlStateSelected];
        [_segmentedControl setTitleTextAttributes:selectedFont forState:UIControlStateNormal];
        
        self.arrowImageView = [UIImageView.alloc initWithImage:ImageHandler.getRightArrow];
        
        [self clearAllsetting];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)clearAllsetting {
    self.contentView.backgroundColor = CDZColorOfWhite;
    self.accessoryType = UITableViewCellAccessoryNone;
    self.accessoryView = nil;
    self.titleLabel.text = @"";
    
    self.inputContentView.hidden = YES;
    [self.inputContentView removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];

    self.contentLabel.text = @"";
    self.contentLabel.textColor = CDZColorOfBlack;
    self.contentLabel.hidden = YES;
    self.contentLabel.edgeInsets = UIEdgeInsetsMake(0.0f, 5.0f, 0.0f, 15.0f);
    
    self.extLabel.text = @"";
    self.extLabel.hidden = YES;
    
    self.inputTextField.text = @"";
    self.inputTextField.placeholder = @"";
    self.inputTextField.keyboardType = UIKeyboardTypeDefault;
    self.inputTextField.hidden = YES;
    self.inputTextField.textAlignment = NSTextAlignmentLeft;
    
    self.dateTimeTextField.text = @"";
//    self.dateTimeTextField.date = NSDate.date;
    self.dateTimeTextField.hidden = YES;
    self.dateTimeTextField.textAlignment = NSTextAlignmentLeft;
    
    self.switchControl.hidden = YES;
    self.switchControl.on = NO;
    
    [self.segmentedControl removeAllSegments];
    self.segmentedControl.hidden = YES;
    
    self.arrowImageView.hidden = YES;
    
    [self.contentView setViewBorderWithRectBorder:UIRectBorderNone borderSize:0.0f withColor:nil withBroderOffset:nil];
}

- (void)updateUIDataWithDate:(NSDictionary *)configDetail {
    @autoreleasepool {
        [self clearAllsetting];
        MAIIFType type = [configDetail[kMAIIFType] integerValue];
        self.type = type;
        if (type == MAIIFTypeOfSpace) {
            self.contentView.backgroundColor = CDZColorOfDeepGray;
            return;
        }
        
        NSString *title = configDetail[kTitle];
        self.titleLabel.text = title;
        NSString *placeholder= configDetail[kPlaceholder];
        id value = configDetail[kValue];
        self.inputContentView.hidden = NO;
        self.textLimit = [configDetail[kTextLimit] unsignedIntegerValue];
        
        switch (type) {
            case MAIIFTypeOfFixInfoDisplay:
                self.contentLabel.hidden = NO;
                self.contentLabel.text = @"";
                if ([value isKindOfClass:NSString.class]) {
                    self.contentLabel.text = value;
                }
                break;
                
            case MAIIFTypeOfFixInfoDisplayWithSelection:
                self.arrowImageView.hidden = NO;
                self.contentLabel.hidden = NO;
                if ([value isKindOfClass:NSNull.class]) {
                    self.contentLabel.textColor = CDZColorOfLightGray;
                    self.contentLabel.text = placeholder;
                }else if ([value isKindOfClass:KeyCityDTO.class]){
                    self.contentLabel.text = [(KeyCityDTO *)value cityName];
                }else if ([value isKindOfClass:NSString.class]){
                    self.contentLabel.text = value;
                }
                
                if (configDetail[kPopAction]&&_actionTarget) {
                    SEL action = NSSelectorFromString(configDetail[kPopAction]);
                    if ([_actionTarget respondsToSelector:action]) {
                        [_inputContentView addTarget:_actionTarget action:action forControlEvents:UIControlEventTouchUpInside];
                    }
                }
                break;
                
            case MAIIFTypeOfTextField:
                if (configDetail[kExtraString]) {
                    self.extLabel.hidden = NO;
                    self.extLabel.text = configDetail[kExtraString];
                }
                self.inputTextField.hidden = NO;
                self.inputTextField.keyboardType = [configDetail[kKeyboardType] unsignedIntegerValue];
                self.inputTextField.placeholder = placeholder;
                if ([value isKindOfClass:NSString.class]) {
                    self.inputTextField.text = configDetail[kValue];
                }
                break;
                
            case MAIIFTypeOfSegmentedControl:{
                id object = configDetail[kTitleList];
                if (![object isKindOfClass:NSArray.class]||[(NSArray *)object count]==0) {
                    return;
                }
                self.segmentedControl.hidden = NO;
                @weakify(self);
                [(NSArray *)object enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    @strongify(self);
                    [self.segmentedControl insertSegmentWithTitle:obj atIndex:idx animated:NO];
                }];
                if (![value isKindOfClass:NSNumber.class]) {
                    value = @(0);
                }
                self.segmentedControl.selectedSegmentIndex = [value boolValue];
            }
                break;
                
            case MAIIFTypeOfSwitch:
                self.switchControl.hidden = NO;
                if (![value isKindOfClass:NSNumber.class]) {
                    value = @(0);
                }
                self.switchControl.on = [value boolValue];
                break;
                
            case MAIIFTypeOfSpace:
                break;
                
            case MAIIFTypeOfDate:
                if (configDetail[kExtraString]) {
                    self.extLabel.hidden = NO;
                    self.extLabel.text = configDetail[kExtraString];
                }
                self.dateTimeTextField.hidden = NO;
                self.dateTimeTextField.placeholder = placeholder;
                if ([value isKindOfClass:NSString.class]) {
                    NSDate *date = [self.dateTimeTextField.dateFormatter dateFromString:value];
                    [self.dateTimeTextField setDate:date animated:YES];
                }
                break;
                
            default:
                break;
        }
    }
    
}

- (void)hiddenKeyboard {
    [_inputTextField resignFirstResponder];
    [_dateTimeTextField resignFirstResponder];
    if (_lastPoint.y+CGRectGetHeight(_scrollView.frame)>_scrollView.contentSize.height) {
        _lastPoint.y = _scrollView.contentSize.height-CGRectGetHeight(_scrollView.frame);
    }
    NSValue *offset = [NSValue valueWithCGPoint:_lastPoint];
    [NSNotificationCenter.defaultCenter postNotificationName:CDZNotiKeyOfUpdateScrollViewOffset object:nil userInfo:@{@"offset":offset, @"scrollEnabled":@YES}];
}

- (void)keyboardWillShow:(NSNotification *)notifyObject {
    CGRect keyboardRect = [[notifyObject.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    if (!CGRectEqualToRect(keyboardRect, _keyboardRect)) {
        self.keyboardRect = keyboardRect;
    }
    if ([_inputTextField isFirstResponder]) {
        [self shiftScrollViewWithAnimation:_inputTextField];
        NSLog(@"Step _inputTextField");
    }
    
    if ([_dateTimeTextField isFirstResponder]) {
        [self shiftScrollViewWithAnimation:_dateTimeTextField];
        NSLog(@"Step _dateTimeTextField");
    }
}

- (void)shiftScrollViewWithAnimation:(UITextField *)textField {
    CGPoint point = CGPointZero;
    if (!textField.isFirstResponder) return;
    CGFloat contanierViewMaxY = CGRectGetMidY(self.frame);
    CGFloat visibleContentsHeight = (CGRectGetHeight(_scrollView.frame)-CGRectGetHeight(_keyboardRect))/2.0f;
//    NSLog(@"%@",NSStringFromCGRect(self.frame));
//    NSLog(@"%@",NSStringFromCGRect(_scrollView.frame));
//    NSLog(@"%@",NSStringFromCGRect(_scrollView.superview.frame));
//    NSLog(@"%f, %f",contanierViewMaxY, visibleContentsHeight);
    if (contanierViewMaxY > visibleContentsHeight) {
        CGFloat offsetY = contanierViewMaxY-visibleContentsHeight;
        point.y = offsetY;
    }
    _lastPoint = _scrollView.contentOffset;
    NSValue *offset = [NSValue valueWithCGPoint:point];
    [NSNotificationCenter.defaultCenter postNotificationName:CDZNotiKeyOfUpdateScrollViewOffset object:nil userInfo:@{@"offset":offset, @"scrollEnabled":@NO}];
}

#pragma mark- segmentedControl && switchControl
- (void)controlValueChange:(id)controller {
    NSUInteger integer = 0;
    if (controller==_segmentedControl) {
        integer = _segmentedControl.selectedSegmentIndex;
    }
    if (controller==_switchControl) {
        integer = _switchControl.on;
    }
    
    if (_resultBlock) {
        _resultBlock(_type, @(integer), _indexPath);
    }
}

#pragma mark- UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField==_dateTimeTextField&&!_dateTimeTextField.date) {
        [self.dateTimeTextField setDate:NSDate.date animated:YES];
        [self.dateTimeTextField setMaximumDate:NSDate.date];
    }
    if (!CGRectEqualToRect(_keyboardRect, CGRectZero)) {
        [self shiftScrollViewWithAnimation:textField];
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (_resultBlock) {
        _resultBlock(_type, textField.text, _indexPath);
    }
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
//    if (_validNumTextField==textField) {
//        return YES;
//    }
//    if (textField.text.length==1) {
//        if ([string isEqualToString:@""]) {
//            textField.text = @"0";
//            return NO;
//        }
//        if ([textField.text isEqualToString:@"0"]) {
//            textField.text = string;
//            return NO;
//        }
//    }
//    
//    if ([textField.text stringByAppendingString:string].longLongValue>_maxValue.longLongValue) {
//        textField.text = _maxValue;
//        return NO;
//    }
//    
//    
//    if ([textField.text isEqualToString:_maxValue]&&![string isEqualToString:@""]) {
//        return NO;
//    }
    if (![string isEqualToString:@""]) {
        NSLog(@"字符长度%lu", textField.text.length);
        if (textField.text.length>=_textLimit&&_textLimit!=0) {
            return NO;
        }
    }
    
    return YES;
}


@end