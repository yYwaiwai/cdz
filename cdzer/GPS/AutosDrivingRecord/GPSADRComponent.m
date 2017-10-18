//
//  GPSADRComponent.m
//  cdzer
//
//  Created by KEns0nLau on 6/24/16.
//  Copyright © 2016 CDZER. All rights reserved.
//
#define vPhone4ContentViewYOffset 20
#import "GPSADRComponent.h"

@interface GPSADRDateTimeSelectionView ()

@property (nonatomic, weak) IBOutlet UIView *contentView;

@property (nonatomic, weak) IBOutlet UITextField *dateTimeTextField;

@property (nonatomic, weak) IBOutlet UIButton *startDateTimeButton;

@property (nonatomic, weak) IBOutlet UIButton *endDateTimeButton;

@property (nonatomic, strong) UILabel *toolBarTitleLabel;

@property (nonatomic, strong) NSDate *tmpDateTime;

@property (nonatomic, strong) UIDatePicker *datePicker;


@end

@implementation GPSADRDateTimeSelectionView
- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
    self.startDateTime = nil;
    self.endDateTime = nil;
    self.dateFormatter = nil;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    @autoreleasepool {
        [self.contentView setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:5.0f];
        
        [self.contentView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull view, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([view isKindOfClass:[UIButton class]]) {
                [view setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:5.0f];
            }
            if (view.tag>=900) {
                [view setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:0.5 withColor:[UIColor colorWithRed:0.839 green:0.843 blue:0.863 alpha:1.00] withBroderOffset:nil];
            }
        }];
        
        self.startDateTimeButton.titleLabel.numberOfLines = 0;
        self.endDateTimeButton.titleLabel.numberOfLines = 0;
        self.startDateTimeButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.endDateTimeButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        
        self.dateFormatter = [NSDateFormatter new];
        [_dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        
        self.toolBarTitleLabel = [UILabel new];
        self.toolBarTitleLabel.textAlignment = NSTextAlignmentCenter;
        self.toolBarTitleLabel.textColor = [UIColor colorWithHexString:@"323232"];
        self.toolBarTitleLabel.font = [self.toolBarTitleLabel.font fontWithSize:17];
        self.toolBarTitleLabel.text = @"完成";
        [self.toolBarTitleLabel sizeToFit];
        
        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.frame), 44.0f)];
        [toolbar setBarStyle:UIBarStyleDefault];
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]initWithTitle:getLocalizationString(@"cancel")
                                                                        style:UIBarButtonItemStylePlain
                                                                       target:self
                                                                       action:@selector(hiddenKeyboard)];
        cancelButton.tintColor = CDZColorOfDeepGray;
        UIBarButtonItem *spaceButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                    target:self
                                                                                    action:nil];
        UIBarButtonItem *toolBarTitleView = [[UIBarButtonItem alloc]initWithCustomView:self.toolBarTitleLabel];
        
        
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]initWithTitle:getLocalizationString(@"finish")
                                                                      style:UIBarButtonItemStyleDone
                                                                     target:self
                                                                     action:@selector(confimSelection)];
        NSArray * buttonsArray = @[cancelButton, spaceButton, toolBarTitleView, spaceButton ,doneButton ];
        [toolbar setItems:buttonsArray];
        
        
        self.datePicker = [UIDatePicker new];
        self.datePicker.backgroundColor = CDZColorOfWhite;
        [self.datePicker addTarget:self action:@selector(datePickerValueChange:) forControlEvents:UIControlEventValueChanged];
        self.dateTimeTextField.inputView = self.datePicker;
        self.dateTimeTextField.inputAccessoryView = toolbar;
        
    }
}

- (void)setStartDateTime:(NSDate *)startDateTime {
    _startDateTime = startDateTime;
}

- (void)setEndDateTime:(NSDate *)endDateTime {
    _endDateTime = endDateTime;
}

- (void)hiddenKeyboard {
    [self.dateTimeTextField resignFirstResponder];
    self.dateTimeTextField.userInteractionEnabled = NO;
    
    
    self.tmpDateTime = nil;
    self.startDateTimeButton.enabled = YES;
    self.endDateTimeButton.enabled = YES;
    if (IS_IPHONE_4_OR_LESS) {
        @weakify(self);
        [UIView animateWithDuration:0.25 animations:^{
            @strongify(self);
            CGRect frame = self.contentView.frame;
            frame.origin.y += vPhone4ContentViewYOffset;
            self.contentView.frame = frame;
        }];
    }
}

- (void)confimSelection {
    [self.dateTimeTextField resignFirstResponder];
    self.dateTimeTextField.userInteractionEnabled = NO;
    
    if (!self.tmpDateTime) self.tmpDateTime = self.datePicker.date;
    
    if (!self.startDateTimeButton.enabled) {
        self.startDateTime = self.tmpDateTime;
        self.startDateTimeButton.selected = YES;
        NSString *dateString = [[self.dateFormatter stringFromDate:self.tmpDateTime] stringByReplacingOccurrencesOfString:@" " withString:@"\n"];
        [self.startDateTimeButton setTitle:dateString forState:UIControlStateSelected];
        [self.startDateTimeButton setTitle:dateString forState:UIControlStateDisabled];
    }
    
    if (!self.endDateTimeButton.enabled) {
        self.endDateTime = self.tmpDateTime;
        self.endDateTimeButton.selected = YES;
        NSString *dateString = [[self.dateFormatter stringFromDate:self.tmpDateTime] stringByReplacingOccurrencesOfString:@" " withString:@"\n"];
        [self.endDateTimeButton setTitle:dateString forState:UIControlStateSelected];
        [self.endDateTimeButton setTitle:dateString forState:UIControlStateDisabled];
    }
    
    self.tmpDateTime = nil;
    self.startDateTimeButton.enabled = YES;
    self.endDateTimeButton.enabled = YES;
    if (IS_IPHONE_4_OR_LESS) {
        @weakify(self);
        [UIView animateWithDuration:0.25 animations:^{
            @strongify(self);
            CGRect frame = self.contentView.frame;
            frame.origin.y += vPhone4ContentViewYOffset;
            self.contentView.frame = frame;
        }];
    }
    
}

- (void)datePickerValueChange:(UIDatePicker *)datePicker {
    self.tmpDateTime = datePicker.date;
}

- (IBAction)showUpDateTimePicker:(UIButton *)button {
    button.enabled = NO;
    if (button==self.startDateTimeButton) {
        self.endDateTimeButton.enabled = YES;
        self.toolBarTitleLabel.text = @"请选择开始时间";
        [self.toolBarTitleLabel sizeToFit];
    }
    if (button==self.endDateTimeButton) {
        self.startDateTimeButton.enabled = YES;
        self.toolBarTitleLabel.text = @"请选择结束时间";
        [self.toolBarTitleLabel sizeToFit];
    }
    self.datePicker.maximumDate = NSDate.date;
    if (self.endDateTime&&button==self.startDateTimeButton) {
        self.datePicker.maximumDate = self.endDateTime;
    }
    if (self.startDateTime) {
        self.datePicker.date = self.startDateTime;
    }
    
    if (self.endDateTime) {
        self.datePicker.date = self.endDateTime;
    }
    
    if (IS_IPHONE_4_OR_LESS&&![self.dateTimeTextField isFirstResponder]) {
        @weakify(self);
        [UIView animateWithDuration:0.25 animations:^{
            @strongify(self);
            CGRect frame = self.contentView.frame;
            frame.origin.y -= vPhone4ContentViewYOffset;
            self.contentView.frame = frame;
        }];
    }
    self.dateTimeTextField.userInteractionEnabled = YES;
    [self.dateTimeTextField becomeFirstResponder];
}

- (IBAction)submitDateTime {
    if (self.responseBlock&&self.startDateTime&&self.endDateTime){
        self.responseBlock ([self.dateFormatter stringFromDate:self.startDateTime], [self.dateFormatter stringFromDate:self.endDateTime]);
    }
}


- (IBAction)dateTimeRangleSelection:(UIButton *)sender {
    NSUInteger timeRange = 2;
    self.endDateTime = NSDate.date;
    switch (sender.tag) {
        case 900:
            timeRange = 2;
            break;
            
        case 901:
            timeRange = 4;
            break;
            
        case 902:
            timeRange = 6;
            break;
            
        case 903:
            timeRange = 8;
            break;
            
        case 904:
            timeRange = 12;
            break;
            
        case 905:
            timeRange = 24;
            break;
            
        default:
            timeRange = 2;
            break;
    }
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setHour:-(timeRange)];
    self.startDateTime = [gregorian dateByAddingComponents:offsetComponents toDate:self.endDateTime options:0];
    if (self.responseBlock&&self.startDateTime&&self.endDateTime){
        self.responseBlock ([self.dateFormatter stringFromDate:self.startDateTime], [self.dateFormatter stringFromDate:self.endDateTime]);
    }
}


@end
