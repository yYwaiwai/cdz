//
//  EServiceSubmitionFormCell.m
//  cdzer
//
//  Created by KEns0nLau on 6/7/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "EServiceSubmitionFormCell.h"
#import "MultiSelectSegmentedControl.h"
#import "InsetsLabel.h"
#import "UITextField+ShareAction.h"

#define vTailSpace 15.0f

@interface EServiceSubmitionFormCell ()<UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
@property (nonatomic, weak) IBOutlet UIView *displayView;

@property (nonatomic, strong) IBOutlet NSLayoutConstraint *spaceBottomConstraint;

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;

@property (nonatomic, weak) IBOutlet UIView *segmentedControlContainer;

@property (nonatomic, weak) IBOutlet MultiSelectSegmentedControl *segmentedControl;

@property (nonatomic, weak) IBOutlet UIView *contentTextFieldContainer;

@property (nonatomic, weak) IBOutlet UITextField *contentTextField;

@property (nonatomic, strong) IBOutlet UIToolbar *tfToolBar;


@property (nonatomic, weak) IBOutlet UIButton *selectorActionBtn;


@property (nonatomic, strong) IBOutlet NSLayoutConstraint *rightContentViewTailConstraint;

@property (nonatomic, strong) IBOutlet UIDatePicker *datePicker;

@property (nonatomic, strong) IBOutlet UIPickerView *pickerView;



@property (nonatomic, strong) IBOutlet UIToolbar *toolBar;

@property (nonatomic, strong) IBOutlet UILabel *contentTextLabel;

@property (nonatomic, strong) UIColor *placeholderColor;

@property (nonatomic, strong) NSMutableArray *pickerDataList;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic, assign) EServiceFormAction formAction;

@property (nonatomic, assign) NSUInteger maxStringLength;
@end

@implementation EServiceSubmitionFormCell

- (void)setShowDisplayView:(BOOL)showDisplayView {
    _showDisplayView = showDisplayView;
    self.spaceBottomConstraint.active = !showDisplayView;
    self.displayView.hidden = !showDisplayView;
    [self setNeedsUpdateConstraints];
    [self setNeedsLayout];
}

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.pickerDataList = [NSMutableArray array];
    
    UINib *nib = [UINib nibWithNibName:@"EServiceCellFormComponent" bundle:nil];
    [nib instantiateWithOwner:self options:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(textFieldTextDidChange:) name:UITextFieldTextDidChangeNotification object:self.contentTextField];
}

- (void)keyboardWillShow:(NSNotification *)notifiObject {
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)setAccessoryType:(UITableViewCellAccessoryType)accessoryType {
    [super setAccessoryType:accessoryType];
    self.rightContentViewTailConstraint.constant = (accessoryType==UITableViewCellAccessoryNone)?vTailSpace:0;
    [self.contentView setNeedsUpdateConstraints];
    [self.contentView setNeedsLayout];
}

- (void)setAccessoryView:(UIView *)accessoryView {
    [super setAccessoryView:accessoryView];
    self.rightContentViewTailConstraint.constant = (!accessoryView)?0:vTailSpace;
    [self.contentView setNeedsUpdateConstraints];
    [self.contentView setNeedsLayout];
}

- (void)configViewDisplay:(NSDictionary *)dataConfig withValue:(NSString *)valueString {
    @autoreleasepool {
        if (dataConfig) {
            self.formAction = [dataConfig[kType] unsignedIntegerValue];
            self.titleLabel.text = dataConfig[kTitle];
            self.selectorActionBtn.hidden = YES;
            self.contentTextLabel.text = valueString;
            self.contentTextLabel.hidden = YES;
            self.contentTextFieldContainer.hidden = YES;
            self.contentTextField.hidden = NO;
            self.contentTextField.placeholder = dataConfig[kPlaceHolder];
            self.contentTextField.keyboardType = UIKeyboardTypeDefault;
            self.contentTextField.inputView = nil;
            self.contentTextField.inputAccessoryView = nil;
            self.accessoryType = UITableViewCellAccessoryNone;
            self.maxStringLength = 0;
            switch (self.formAction) {
                case EServiceFormActionOfTextField:
                    self.contentTextLabel.hidden = YES;
                    self.contentTextFieldContainer.hidden = NO;
                    self.contentTextField.text = valueString;
                    self.contentTextField.inputAccessoryView = self.tfToolBar;
                    self.contentTextField.keyboardType = [dataConfig[vKeyboardType] unsignedIntegerValue];
                    if (dataConfig[kMaxStringLength]) self.maxStringLength = [dataConfig[kMaxStringLength] unsignedIntegerValue];
            
                    break;
                    
                case EServiceFormActionOfDateTime:{
                    self.contentTextLabel.hidden = YES;
                    self.contentTextFieldContainer.hidden = NO;
                    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
                    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
                    [offsetComponents setHour:+2];
                    NSDate *theDate = [gregorian dateByAddingComponents:offsetComponents toDate:NSDate.date options:NSCalendarWrapComponents];
                    self.contentTextField.text = valueString;
                    self.datePicker.minimumDate = theDate;
                    self.contentTextField.inputView = self.datePicker;
                    self.contentTextField.inputAccessoryView = self.toolBar;
                }
                    break;

                case EServiceFormActionOfSelector:
                    if ([valueString isEqualToString:@""]) {
                        self.contentTextLabel.text = self.contentTextField.placeholder;
                    }
                    self.selectorActionBtn.hidden = NO;
                    self.contentTextLabel.hidden = NO;
                    self.contentTextField.hidden = YES;
                    self.contentTextFieldContainer.hidden = NO;
                    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                    
                case EServiceFormActionOfPickerSelection:
                    self.contentTextLabel.hidden = YES;
                    self.contentTextFieldContainer.hidden = NO;
                    self.contentTextField.text = valueString;
                    self.contentTextField.inputView = self.pickerView;
                    self.contentTextField.inputAccessoryView = self.toolBar;
                    [self.pickerDataList removeAllObjects];
                    [self.pickerDataList addObjectsFromArray:dataConfig[kSelectionList]];
                    [self.pickerView reloadAllComponents];
                    
                    if (valueString&&![valueString isEqualToString:@""]) {
                        NSUInteger valueIndex = [self.pickerDataList indexOfObject:valueString];
                        if (valueString>=0&&valueIndex<=self.pickerDataList.count-1) {
                            [self.pickerView selectRow:valueIndex inComponent:0 animated:NO];
                        }
                    }
                    break;
                    
                case EServiceFormActionOfSegmentedControl:{
                    self.segmentedControlContainer.hidden = NO;
                    NSArray *selectedTitle = [valueString componentsSeparatedByString:@","];
                    if (selectedTitle.count>0) {
                        NSArray *selectionList = dataConfig[kSelectionList];
                        NSIndexSet *indexSet = [selectionList indexesOfObjectsPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                            return [selectedTitle containsObject:obj];
                        }];
                        self.segmentedControl.selectedSegmentIndexes = indexSet;
                    }
                    self.contentTextLabel.hidden = YES;
                    self.contentTextFieldContainer.hidden = YES;
                }
                    break;

                    
                default:
                case EServiceFormActionOfDisplayOnly:
                    self.contentTextLabel.hidden = NO;
                    self.contentTextFieldContainer.hidden = YES;
                    self.contentTextField.text = @"";
                    self.contentTextField.placeholder = @"";
                    break;
            }
        }
    }
}

- (IBAction)selecorAction{
    if (self.responseBlock) {
        self.responseBlock (self.indexPath, @"selectorAction");
    }
}

- (IBAction)finishToFieldTheText {
    [self.contentTextField resignFirstResponder];
    if (self.responseBlock) {
        self.responseBlock (self.indexPath, self.contentTextField.text);
    }
}

- (IBAction)segmentedControlValueChange:(MultiSelectSegmentedControl *)segmentedControl {
    if (self.responseBlock) {
        NSString *result = @"";
        if (segmentedControl.selectedSegmentTitles.count>0) {
            result = [segmentedControl.selectedSegmentTitles componentsJoinedByString:@","];
        }
        self.responseBlock(self.indexPath, result);
    }
}

- (IBAction)cancelPickerViewSelection:(id)sender {
    [self.contentTextField resignFirstResponder];
    if (self.responseBlock) {
        self.responseBlock (self.indexPath, self.contentTextLabel.text);
    }
}

- (IBAction)submitPickerViewSelection:(id)sender {
    [self.contentTextField resignFirstResponder];
    if (self.formAction==EServiceFormActionOfPickerSelection) {
        NSString *result = self.pickerDataList[[self.pickerView selectedRowInComponent:0]];
        self.contentTextLabel.text = result;
        self.contentTextField.text = result;
        if (self.responseBlock) {
            self.responseBlock (self.indexPath, result);
        }
    }else if (self.formAction==EServiceFormActionOfDateTime) {
        if (!self.dateFormatter) {
            self.dateFormatter = [NSDateFormatter new];
            self.dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm";
        }
        NSString *dateString = [self.dateFormatter stringFromDate:self.datePicker.date];
        self.contentTextLabel.text = dateString;
        self.contentTextField.text = dateString;
        if (self.responseBlock) {
            self.responseBlock (self.indexPath, dateString);
        }
    }
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField==self.contentTextField&&self.formAction==EServiceFormActionOfTextField) {
        [self finishToFieldTheText];
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (![string isEqualToString:@""]) {
        if (textField.keyboardType==UIKeyboardTypeNumberPad&&self.maxStringLength==11) {
            if (textField.text.length==0&&![string isEqualToString:@"1"]) return NO;
        }
        if ([string isEqualToString:@"\n"]) return NO;
        if ([string isContainsString:@" "]) string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        if ([toBeString length]>self.maxStringLength) {
            textField.text = [toBeString substringToIndex:self.maxStringLength];
            return NO;
        }else {
            return YES;
        }
    }
    return YES;
}

- (void)textFieldTextDidChange:(NSNotification *)notiObj {
    UITextField *textView = (UITextField *)notiObj.object;
    if (self.contentTextField==textView) {
        
        NSUInteger maxLenght = self.maxStringLength;
        NSString *toBeString = textView.text;
        NSString *lang = [[textView textInputMode] primaryLanguage];
        if ([lang isContainsString:@"zh-Hans"]) {
            UITextRange *selectedRange = [textView markedTextRange];
            UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
            if (!position) {
                if (toBeString.length>maxLenght) {
                    textView.text = [toBeString substringToIndex:maxLenght];
                }
            }else {
                
            }
        }else {
            if (toBeString.length>maxLenght) {
                textView.text = [toBeString substringToIndex:maxLenght];
            }
        }
        if ([textView.text isContainsString:@" "]){
            textView.text = [textView.text stringByReplacingOccurrencesOfString:@" " withString:@""];
        }
        
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (self.formAction==EServiceFormActionOfPickerSelection||
        self.formAction==EServiceFormActionOfDateTime) {
        textField.text = [self.dateFormatter stringFromDate:self.datePicker.date];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (self.contentTextField==textField) {
        [self finishToFieldTheText];
    }
}

#pragma UIPickerViewDataSource & UIPickerViewDelegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.pickerDataList.count;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    if (!view||![view isKindOfClass:UILabel.class]) {
        InsetsLabel *label = [[InsetsLabel alloc] initWithEdgeInsetsValue:UIEdgeInsetsMake(0.0f, 12.0f, 0.0f, 12.0f)];
        label.textAlignment = NSTextAlignmentCenter;
        label.numberOfLines = 0;
        label.font = [label.font fontWithSize:15];
        label.textColor = [UIColor colorWithHexString:@"323232"];
        view = label;
    }
    if ([view isKindOfClass:UILabel.class]) {
        InsetsLabel *label = (InsetsLabel *)view;
        label.text = self.pickerDataList[row];
    }
    return view;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.contentTextField.text = self.pickerDataList[row];
}

@end
