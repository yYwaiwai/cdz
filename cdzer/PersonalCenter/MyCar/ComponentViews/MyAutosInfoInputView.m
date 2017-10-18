//
//  MyAutosInfoInputView.m
//  cdzer
//
//  Created by KEns0n on 4/25/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//
#define vSelectionTypeContentHeight 310.0f
#define vNormalTypeContentHeight 160.0f
#define vNoneTypeContentHeight 110.0f
#define vBaseTagForTF 200
#define kObjBrandName @"brandName"
#define kObjNameKey @"name"
#define kObjIDKey @"id"
#define kObjIconKey @"icon"
#import "MyAutosInfoInputView.h"
#import "InsetsTextField.h"
#import "InsetsLabel.h"
#import "UIView+ShareAction.h"
#import "AFViewShaker.h"
#import "UIView+Borders.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface MyAutosInfoInputView () <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>//, UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, strong) AFViewShaker *viewShaker;

@property (nonatomic, assign) CGRect keyboardRect;

@property (nonatomic, strong) InsetsLabel *titleLabel;

@property (nonatomic, strong) InsetsTextField *commonTextField;

@property (nonatomic, strong) InsetsTextField *autosDealershipTextField;

@property (nonatomic, strong) InsetsTextField *autosSeriesTextField;

@property (nonatomic, strong) InsetsTextField *autosModelTextField;

@property (nonatomic, strong) InsetsTextField *licenceProvincesTF;

@property (nonatomic, strong) InsetsTextField *licenceCityTF;

@property (nonatomic, copy) MAICompletionBlock completionBlock;

@property (nonatomic, strong) UIButton *cancelButton;

@property (nonatomic, strong) UIButton *confirmButton;

@property (nonatomic, strong) UIView *contentsView;

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UIDatePicker *datePicker;

//@property (nonatomic, strong) UIPickerView *autosPicker;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic, strong) NSMutableArray *autosDataList, *defaultAutosDataList;

@property (nonatomic, strong) NSMutableArray <NSIndexPath *> *selectedIndex, *defaultSelectedIndex;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *keyArray;

@property (nonatomic, strong) NSArray *theIDsList;

@property (nonatomic, strong) NSArray *autosColorList;

@property (nonatomic, strong) NSMutableArray *tvList;

@property (nonatomic, strong) NSArray *autosProvincesList;

@property (nonatomic, strong) NSArray *autosCityList;

@property (nonatomic, assign) NSInteger currentIdx;

@property (nonatomic, assign) NSInteger initialUpdate;

@property (nonatomic, assign) BOOL wouldNotShowHub;

@property (nonatomic, assign) MAIInputType inputType;

@end

@interface  MyAutosIIVCell :UITableViewCell

@end

@implementation MyAutosIIVCell

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.imageView.frame = CGRectMake(DefaultEdgeInsets.left, 0.0f, 30.0f, 30.0f);
    CGPoint ivCenter = self.imageView.center;
    ivCenter.y = CGRectGetHeight(self.frame)/2.0f;
    self.imageView.center = ivCenter;
    
    self.imageView.autoresizingMask = UIViewAutoresizingNone;
    
}

@end

@implementation MyAutosInfoInputView

- (void)layoutSubviews {
    [super layoutSubviews];
    self.contentsView.center = CGPointMake(CGRectGetWidth(self.bounds)/2.0f, CGRectGetHeight(self.bounds)/2.0f);
    NSLog(@"%@", NSStringFromCGPoint(self.contentsView.center));
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (instancetype)init {
    if (self = [self initWithFrame:CGRectZero]) {
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.dateFormatter = [NSDateFormatter new];
        [_dateFormatter setDateFormat:@"yyyy-MM-dd"];
        
        self.currentIdx = 0;
        self.autosDataList = [@[@[], @[], @[], @[]] mutableCopy];
        self.selectedIndex = [@[NSNull.null, NSNull.null, NSNull.null, NSNull.null] mutableCopy];
        self.inputType = MAIInputTypeOfNone;
        [self initializationUI];
        [self getAutoBrandListAndInitialLoading:NO];
        self.autosCityList = @[];
        self.autosColorList = @[];
        self.autosProvincesList = @[];
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
        
        UIEdgeInsets insetValueLeft = UIEdgeInsetsMake(0.0f, 12.0f, 0.0f, 0.0f);
//        UIEdgeInsets insetValueRight = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 12.0f);
        UIEdgeInsets insetValueCenter = UIEdgeInsetsMake(0.0f, 12.0f, 0.0f, 12.0f);
        
        self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.scrollEnabled = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.backgroundColor = CDZColorOfClearColor;
        [self addSubview:_scrollView];
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        _scrollView.translatesAutoresizingMaskIntoConstraints = YES;
        self.contentsView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 300.0f, 260.0f)];
        _contentsView.center = CGPointMake(CGRectGetWidth(self.frame)/2.0f, CGRectGetHeight(self.frame)/2.0f);
        _contentsView.backgroundColor = CDZColorOfWhite;
        [_contentsView setViewCornerWithRectCorner:UIRectCornerAllCorners
                                        cornerSize:5.0f];
        [_scrollView addSubview:_contentsView];
        
        self.titleLabel = [[InsetsLabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f,
                                                                                CGRectGetWidth(_contentsView.frame), 50.0f)
                                                           andEdgeInsetsValue:UIEdgeInsetsMake(0.0f, 12.0f, 0.0f, 12.0f)];
        _titleLabel.font = systemFontBoldWithoutRatio(19.0f);
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.text = getLocalizationString(@"over_speed_setting");
        [_contentsView addSubview:_titleLabel];
        
        
        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *dateComponents = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:[NSDate date]];
        dateComponents.year -= 100;
        self.datePicker = [[UIDatePicker alloc] init];
        self.datePicker.backgroundColor = UIColor.whiteColor;
        _datePicker.datePickerMode = UIDatePickerModeDate;
        [_datePicker addTarget:self action:@selector(datePickerValeChange:) forControlEvents:UIControlEventValueChanged];
        
        
//        self.autosPicker = [[UIPickerView alloc] init];
//        _autosPicker.delegate = self;
//        _autosPicker.dataSource = self;
        
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        CGFloat textFieldHeight = 50.0f;
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
        [toolbar setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:CDZColorOfSeperateLineColor withBroderOffset:nil];
        [toolbar setItems:buttonsArray];

        
        self.tvList = [@[] mutableCopy];
        self.tableView = [UITableView.alloc initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(UIScreen.mainScreen.bounds), 260.f)];
        _tableView.backgroundColor = CDZColorOfWhite;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.bounces = NO;
        _tableView.allowsMultipleSelection = NO;
        _tableView.allowsMultipleSelectionDuringEditing = NO;
        _tableView.allowsSelection = YES;
        _tableView.allowsSelectionDuringEditing = NO;

        self.commonTextField = [[InsetsTextField alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(_titleLabel.frame), CGRectGetWidth(_contentsView.frame), textFieldHeight)
                                                           andEdgeInsetsValue:insetValueCenter];
        _commonTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _commonTextField.textAlignment = NSTextAlignmentLeft;
        _commonTextField.returnKeyType = UIReturnKeyDone;
        _commonTextField.delegate = self;
        _commonTextField.tag = vBaseTagForTF;
        
        _commonTextField.inputAccessoryView = toolbar;
        _autosModelTextField.placeholder = getLocalizationString(@"please_select_auto_brand");
        [_contentsView addSubview:_commonTextField];
        
        
        
        UIEdgeInsets insetsValue = UIEdgeInsetsMake(0.0f, 2.0f, 0.0f, 2.0f);
        NSDictionary *attrDict = @{NSFontAttributeName:vGetHelveticaNeueFont(HelveticaNeueFontTypeOfBold, 14.0f, NO),
                                   NSForegroundColorAttributeName:CDZColorOfDeepGray};
        NSMutableAttributedString *placeholderStr = [[NSMutableAttributedString alloc] initWithString:@"省份" attributes:attrDict];
        
        self.licenceProvincesTF = [[InsetsTextField alloc] initWithFrame:CGRectMake(vAdjustByScreenRatio(60.0f), CGRectGetMinY(_commonTextField.frame), 30.0f, textFieldHeight)
                                                   andEdgeInsetsValue:insetsValue];
        _licenceProvincesTF.textAlignment = NSTextAlignmentCenter;
        _licenceProvincesTF.delegate = self;
        _licenceProvincesTF.inputView = _tableView;
        _licenceProvincesTF.attributedPlaceholder = placeholderStr;
        _licenceProvincesTF.hidden = YES;
        _licenceProvincesTF.inputAccessoryView = toolbar;
        [_contentsView addSubview:_licenceProvincesTF];

        
        [placeholderStr deleteCharactersInRange:NSMakeRange(0, placeholderStr.length)];
        [placeholderStr appendAttributedString:[[NSAttributedString alloc] initWithString:@"市号" attributes:attrDict]];
        self.licenceCityTF = [[InsetsTextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_licenceProvincesTF.frame), CGRectGetMinY(_commonTextField.frame),
                                                                               CGRectGetWidth(_licenceProvincesTF.frame), textFieldHeight)
                                                      andEdgeInsetsValue:insetsValue];
        _licenceCityTF.textAlignment = NSTextAlignmentCenter;
        _licenceCityTF.delegate = self;
        _licenceCityTF.inputView = _tableView;
        _licenceCityTF.attributedPlaceholder = placeholderStr;
        _licenceCityTF.hidden = YES;
        _licenceCityTF.inputAccessoryView = toolbar;
        [_contentsView addSubview:_licenceCityTF];
        
        
        self.autosDealershipTextField = [[InsetsTextField alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(_commonTextField.frame), CGRectGetWidth(_contentsView.frame), textFieldHeight)
                                                           andEdgeInsetsValue:insetValueCenter];
        _autosDealershipTextField.textAlignment = NSTextAlignmentCenter;
        _autosDealershipTextField.delegate = self;
        _autosDealershipTextField.shouldStopPCDAction = NO;
        _autosDealershipTextField.inputView = _tableView;
        _autosDealershipTextField.inputAccessoryView = toolbar;
        _autosDealershipTextField.keyboardType = UIKeyboardTypeASCIICapable;
        _autosDealershipTextField.placeholder = getLocalizationString(@"please_select_auto_dealership");
        _autosDealershipTextField.tag = vBaseTagForTF+1;
        [_autosDealershipTextField addTopBorderWithHeight:1 color:CDZColorOfDeepGray
                                      leftOffset:insetValueLeft.left
                                     rightOffset:0.0f andTopOffset:0.0f];
        [_contentsView addSubview:_autosDealershipTextField];
        
        
        
        self.autosSeriesTextField = [[InsetsTextField alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(_autosDealershipTextField.frame), CGRectGetWidth(_contentsView.frame), textFieldHeight)
                                                           andEdgeInsetsValue:insetValueCenter];
        _autosSeriesTextField.textAlignment = NSTextAlignmentCenter;
        _autosSeriesTextField.delegate = self;
        _autosSeriesTextField.shouldStopPCDAction = NO;
        _autosSeriesTextField.inputView = _tableView;
        _autosSeriesTextField.inputAccessoryView = toolbar;
        _autosSeriesTextField.keyboardType = UIKeyboardTypeASCIICapable;
        _autosSeriesTextField.placeholder = getLocalizationString(@"please_select_auto_series");
        _autosSeriesTextField.tag = vBaseTagForTF+2;
        [_autosSeriesTextField addTopBorderWithHeight:1 color:CDZColorOfDeepGray
                                      leftOffset:insetValueLeft.left
                                     rightOffset:0.0f andTopOffset:0.0f];
        [_contentsView addSubview:_autosSeriesTextField];
        
        
   
        self.autosModelTextField = [[InsetsTextField alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(_autosSeriesTextField.frame), CGRectGetWidth(_contentsView.frame), textFieldHeight)
                                                        andEdgeInsetsValue:insetValueCenter];
        _autosModelTextField.textAlignment = NSTextAlignmentCenter;
        _autosModelTextField.delegate = self;
        _autosModelTextField.shouldStopPCDAction = NO;
        _autosModelTextField.inputView = _tableView;
        _autosModelTextField.inputAccessoryView = toolbar;
        _autosModelTextField.keyboardType = UIKeyboardTypeASCIICapable;
        _autosModelTextField.placeholder = getLocalizationString(@"please_select_auto_model");
        _autosModelTextField.tag = vBaseTagForTF+3;
        [_autosModelTextField addTopBorderWithHeight:1 color:CDZColorOfDeepGray
                                           leftOffset:insetValueLeft.left
                                          rightOffset:0.0f andTopOffset:0.0f];
        [_contentsView addSubview:_autosModelTextField];
        
        
        
        self.viewShaker = [[AFViewShaker alloc] initWithView:_contentsView];
        
        
        self.cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _cancelButton.frame = CGRectMake(0, CGRectGetHeight(_contentsView.frame)-50.0f, CGRectGetWidth(_contentsView.frame)/2.0f, 50.0f);
        _cancelButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        _cancelButton.titleLabel.font = systemFontWithoutRatio(16.0f);
        [_cancelButton setTitle:getLocalizationString(@"cancel") forState:UIControlStateNormal];
        [_cancelButton setTitleColor:CDZColorOfDefaultColor forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(hiddenSelfView) forControlEvents:UIControlEventTouchUpInside];
        [_cancelButton addTopBorderWithHeight:1 andColor:CDZColorOfDeepGray];
        [_cancelButton addRightBorderWithWidth:0.5 andColor:CDZColorOfDeepGray];
        [_contentsView addSubview:_cancelButton];
        
        self.confirmButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _confirmButton.frame = CGRectMake(CGRectGetWidth(_contentsView.frame)/2.0f, CGRectGetHeight(_contentsView.frame)-50.0f, CGRectGetWidth(_contentsView.frame)/2.0f, 50.0f);
        _confirmButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        _confirmButton.titleLabel.font = systemFontBoldWithoutRatio(16.0f);
        [_confirmButton setTitle:getLocalizationString(@"ok") forState:UIControlStateNormal];
        [_confirmButton setTitleColor:CDZColorOfDefaultColor forState:UIControlStateNormal];
        [_confirmButton addTarget:self action:@selector(confirmSetting) forControlEvents:UIControlEventTouchUpInside];
        [_confirmButton addTopBorderWithHeight:1 andColor:CDZColorOfDeepGray];
        [_confirmButton addLeftBorderWithWidth:0.5 andColor:CDZColorOfDeepGray];
        [_contentsView addSubview:_confirmButton];
    }
    
    [self setReactiveRules];
}

- (void)setInputType:(MAIInputType)inputType {
    [self setInputType:inputType withOriginalValue:nil];
}

- (void)setInputType:(MAIInputType)inputType withOriginalValue:(NSString *)originalValue {
    if (!originalValue||[originalValue isEqualToString:@"--"]) originalValue = @"";
    self.initialUpdate = NO;
    CGRect contentRect = _contentsView.frame;
    _datePicker.minimumDate = nil;
    _datePicker.maximumDate = nil;
    _commonTextField.text = @"";
    _commonTextField.edgeInsets = UIEdgeInsetsMake(0.0f, 12.0f, 0.0f, 12.0f);
    _commonTextField.textAlignment = NSTextAlignmentCenter;
    _commonTextField.inputView = nil;
    _commonTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _commonTextField.hidden = NO;
    _commonTextField.shouldStopPCDAction = YES;
    _commonTextField.secureTextEntry = NO;
    _commonTextField.keyboardType = UIKeyboardTypeASCIICapable;
    if (inputType!=MAIInputTypeOfAutosSelection) {
        _commonTextField.text = originalValue;
    }
    _autosDealershipTextField.hidden = YES;
    _autosDealershipTextField.text = @"";
    _autosSeriesTextField.hidden = YES;
    _autosSeriesTextField.text = @"";
    _autosModelTextField.hidden = YES;
    _autosModelTextField.text = @"";
    
    _licenceCityTF.hidden = YES;
    _licenceCityTF.text = @"";
    _licenceProvincesTF.hidden = YES;
    _licenceProvincesTF.text = @"";
    
    contentRect.size.height = vNormalTypeContentHeight;
    _inputType = inputType;
    [_tvList removeAllObjects];
    
    switch (inputType) {
        case MAIInputTypeOfLicensePlate:{
            [self setTitle:@"myautos_number"];
            _commonTextField.placeholder = getLocalizationString(@"input_autos_licence");
            _licenceCityTF.hidden = NO;
            _licenceProvincesTF.hidden = NO;
            if(originalValue&&![originalValue isEqualToString:@""]&&originalValue.length>=7){
                _licenceProvincesTF.text = [originalValue substringToIndex:1];
                _licenceCityTF.text = [originalValue substringWithRange:NSMakeRange(1, 1)];
                _commonTextField.text = [originalValue substringFromIndex:2];
                
            }else {
                _licenceProvincesTF.text = @"湘";
                _licenceCityTF.text = @"A";
            }
            _commonTextField.textAlignment = NSTextAlignmentLeft;
            _commonTextField.edgeInsets = UIEdgeInsetsMake(0.0f, CGRectGetMaxX(_licenceCityTF.frame), 0.0f, 12.0f);
            if (_autosProvincesList.count==0) {
                [self getTheAutosProvincesList];
            }
        }
            break;
        case MAIInputTypeOfAutosBodyColor:
            [self setTitle:@"myautos_color"];
            _commonTextField.placeholder = getLocalizationString(@"input_autos_body_color");
            _commonTextField.inputView = _tableView;
            if (_autosColorList.count==0) {
                [self getTheAutosColorList];
            }
            break;
        case MAIInputTypeOfAutosFrameNumber:
            [self setTitle:@"myautos_frame_no"];
            _commonTextField.keyboardType = UIKeyboardTypeASCIICapable;
            _commonTextField.placeholder = getLocalizationString(@"input_autos_frame");
            break;
        case MAIInputTypeOfAutosEngineNumber:
            [self setTitle:@"myautos_engine_code"];
            _commonTextField.keyboardType = UIKeyboardTypeASCIICapable;
            _commonTextField.placeholder = getLocalizationString(@"input_autos_engine");
            break;
        case MAIInputTypeOfInitialMileage:
            [self setTitle:@"myautos_start_mile"];
            _commonTextField.keyboardType = UIKeyboardTypeNumberPad;
            _commonTextField.placeholder = getLocalizationString(@"input_autos_initial_mileage");
            break;
        case MAIInputTypeOfAutosInsuranceNumber:
            [self setTitle:@"myautos_insurance_num"];
            _commonTextField.placeholder = getLocalizationString(@"input_next_insurance_number");
            _commonTextField.keyboardType = UIKeyboardTypeNumberPad;
            break;
        case MAIInputTypeOfAutosInsuranceDate:{
            _datePicker.minimumDate = [NSDate date];
            _datePicker.date = _datePicker.minimumDate;
            if (originalValue) {
                NSDate *date = nil;
                date = [_dateFormatter dateFromString:originalValue];
                NSLog(@"%@",date);
                if (date) {
                    _datePicker.date = date;
                }
            }
            [self setTitle:@"myautos_insure_date"];
            _commonTextField.inputView = _datePicker;
            _commonTextField.clearButtonMode = UITextFieldViewModeNever;
            _commonTextField.placeholder = getLocalizationString(@"input_next_insurance_date");
        }
            break;
        case MAIInputTypeOfAutosAnniversaryCheckDate:{
            _datePicker.minimumDate = [NSDate date];
            _datePicker.date = _datePicker.minimumDate;
            if (originalValue) {
                NSDate *date = nil;
                date = [_dateFormatter dateFromString:originalValue];
                NSLog(@"%@",date);
                if (date) {
                    _datePicker.date = date;
                }
            }
            [self setTitle:@"myautos_annual_date"];
            _commonTextField.inputView = _datePicker;
            _commonTextField.clearButtonMode = UITextFieldViewModeNever;
            _commonTextField.placeholder = getLocalizationString(@"input_next_anniversary_check_date");
        }
            break;
        case MAIInputTypeOfAutosMaintenanceDate:{
            _datePicker.maximumDate = [NSDate date];
            _datePicker.date = _datePicker.maximumDate;
            if (originalValue) {
                NSDate *date = nil;
                date = [_dateFormatter dateFromString:originalValue];
                NSLog(@"%@",date);
                if (date) {
                    _datePicker.date = date;
                }
            }
            [self setTitle:@"myautos_maintenance_date"];
            _commonTextField.inputView = _datePicker;
            _commonTextField.clearButtonMode = UITextFieldViewModeNever;
            _commonTextField.placeholder = getLocalizationString(@"input_next_maintenance_date");
        }
            break;
        case MAIInputTypeOfAutosRegisterDate:{
            _datePicker.maximumDate = [NSDate date];
            _datePicker.date = _datePicker.maximumDate;
            if (originalValue) {
                NSDate *date = nil;
                date = [_dateFormatter dateFromString:originalValue];
                NSLog(@"%@",date);
                if (date) {
                    _datePicker.date = date;
                }
            }
            [self setTitle:@"myautos_register_date"];
            _commonTextField.inputView = _datePicker;
            _commonTextField.clearButtonMode = UITextFieldViewModeNever;
            _commonTextField.placeholder = getLocalizationString(@"input_register_date");
        }
            break;
        case MAIInputTypeOfAutosSelection:
            self.currentIdx = 0;
            [self setTitle:@"input_select_auto"];
            _commonTextField.clearButtonMode = UITextFieldViewModeNever;
            _commonTextField.placeholder = getLocalizationString(@"please_select_auto_brand");
            _commonTextField.textAlignment = NSTextAlignmentCenter;
            _commonTextField.hidden = NO;
            _commonTextField.shouldStopPCDAction = NO;
            _commonTextField.inputView = _tableView;
            _commonTextField.keyboardType = UIKeyboardTypeASCIICapable;
            _autosDealershipTextField.hidden = NO;
            _autosSeriesTextField.hidden = NO;
            _autosModelTextField.hidden = NO;
            contentRect.size.height = vSelectionTypeContentHeight;
            [self handleTFValueWith:originalValue];
            break;
            
            
        default:
            break;
    }
    
    _contentsView.frame = contentRect;
    _contentsView.center = CGPointMake(_contentsView.center.x, CGRectGetHeight(_scrollView.frame)/2.0f);
}

- (void)handleTFValueWith:(NSString* )originalValue {
    
    @autoreleasepool {
        if ([originalValue rangeOfString:kNullString].location!=NSNotFound) {
            _commonTextField.text = @"";
            _autosDealershipTextField.text = @"";
            _autosSeriesTextField.text = @"";
            _autosModelTextField.text = @"";
        }else {
            NSIndexPath *brandSelectIdx = _selectedIndex[0];
            NSIndexPath *dealershipSelectIdx = _selectedIndex[1];
            NSIndexPath *seriesSelectIdx = _selectedIndex[2];
            NSIndexPath *modelSelectIdx = _selectedIndex[3];
            
            _commonTextField.text = @"";
            if ([_autosDataList[0] count]!=0&&[brandSelectIdx isKindOfClass:NSIndexPath.class]) {
                AutosBrandDTO *dto = [[_autosDataList[0] objectAtIndex:brandSelectIdx.section] objectAtIndex:brandSelectIdx.row];
                _commonTextField.text = dto.brandName;
            }
            
            _autosDealershipTextField.text = @"";
            if ([_autosDataList[1] count]!=0&&[dealershipSelectIdx isKindOfClass:NSIndexPath.class]) {
                _autosDealershipTextField.text = [[_autosDataList[1] objectAtIndex:dealershipSelectIdx.row] objectForKey:kObjNameKey];
            }
            
            _autosSeriesTextField.text = @"";
            if ([_autosDataList[2] count]!=0&&[seriesSelectIdx isKindOfClass:NSIndexPath.class]) {
                _autosSeriesTextField.text = [[_autosDataList[2] objectAtIndex:seriesSelectIdx.row] objectForKey:kObjNameKey];
            }
            
            _autosModelTextField.text = @"";
            if ([_autosDataList[3] count]!=0&&[modelSelectIdx isKindOfClass:NSIndexPath.class]) {
                _autosModelTextField.text = [[_autosDataList[3] objectAtIndex:modelSelectIdx.row] objectForKey:kObjNameKey];
            }
        }
    }
}

- (void)setReactiveRules {
    @weakify(self)
    [RACObserve(self, autosDataList) subscribeNext:^(NSArray *autosDataList) {
        @strongify(self)
        if ((self.inputType==MAIInputTypeOfAutosSelection||self.initialUpdate)&&autosDataList.count==4) {
            self.autosDealershipTextField.enabled = ([autosDataList[1] count]!=0);
            self.autosSeriesTextField.enabled = ([autosDataList[2] count]!=0);
            self.autosModelTextField.enabled = ([autosDataList[3] count]!=0);
        }
    
    }];
    
    
    [RACObserve(self, selectedIndex) subscribeNext:^(NSArray *selectedIndex) {
        @strongify(self)
        if ((self.inputType==MAIInputTypeOfAutosSelection||self.initialUpdate)&&selectedIndex.count==4) {
            NSIndexPath *brandSelectIdx = selectedIndex[0];
            NSIndexPath *dealershipSelectIdx = selectedIndex[1];
            NSIndexPath *seriesSelectIdx = selectedIndex[2];
            NSIndexPath *modelSelectIdx = selectedIndex[3];
            
            self.commonTextField.text = @"";
            if (![self.autosDataList[0] isKindOfClass:NSNull.class]&&
                [self.autosDataList[0] count]!=0&&[brandSelectIdx isKindOfClass:NSIndexPath.class]) {
                AutosBrandDTO *dto = [[self.autosDataList[0] objectAtIndex:brandSelectIdx.section] objectAtIndex:brandSelectIdx.row];
                self.commonTextField.text = dto.brandName;
            }
            
            self.autosDealershipTextField.text = @"";
            if (![self.autosDataList[1] isKindOfClass:NSNull.class]&&
                [self.autosDataList[1] count]!=0&&[dealershipSelectIdx isKindOfClass:NSIndexPath.class]) {
                self.autosDealershipTextField.text = [[self.autosDataList[1] objectAtIndex:dealershipSelectIdx.row] objectForKey:kObjNameKey];
            }
            
            self.autosSeriesTextField.text = @"";
            if (![self.autosDataList[2] isKindOfClass:NSNull.class]&&
                [self.autosDataList[2] count]!=0&&[seriesSelectIdx isKindOfClass:NSIndexPath.class]) {
                self.autosSeriesTextField.text = [[self.autosDataList[2] objectAtIndex:seriesSelectIdx.row] objectForKey:kObjNameKey];
            }
            
            self.autosModelTextField.text = @"";
            if (![self.autosDataList[3] isKindOfClass:NSNull.class]&&
                [self.autosDataList[3] count]!=0&&[modelSelectIdx isKindOfClass:NSIndexPath.class]) {
                self.autosModelTextField.text = [[self.autosDataList[3] objectAtIndex:modelSelectIdx.row] objectForKey:kObjNameKey];
            }

        }
    }];
    
    [RACObserve(self, defaultAutosDataList) subscribeNext:^(NSArray *defaultAutosDataList) {
        @strongify(self)
        if (self.initialUpdate) {
            NSMutableArray *array = [self mutableArrayValueForKey:@"autosDataList"];
            [array removeAllObjects];
            [array addObjectsFromArray:defaultAutosDataList];
        }
        
    }];
    
    [RACObserve(self, defaultSelectedIndex) subscribeNext:^(NSArray *defaultSelectedIndex) {
        @strongify(self)
        if (self.initialUpdate) {
            NSMutableArray *array = [self mutableArrayValueForKey:@"selectedIndex"];
            [array removeAllObjects];
            [array addObjectsFromArray:defaultSelectedIndex];
        }
        
    }];
    
}

- (void)setTitle:(NSString *)title {
    if (!title||[title isEqualToString:@""]){
        _titleLabel.text = @"未命名";
        return;
    }
    _titleLabel.text = [getLocalizationString(title) stringByReplacingOccurrencesOfString:@"：" withString:@""];
}

- (void)hiddenSelfAndSuccess:(BOOL)isSuccess {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    @weakify(self)
    [UIView animateWithDuration:0.25 animations:^{
        @strongify(self)
        self.alpha = 0.0f;
        [self hiddenKeyboard];
    }];
}

- (void)hiddenSelfView {
    if (_inputType==MAIInputTypeOfAutosSelection) {
        [_autosDataList removeAllObjects];
        [_autosDataList addObjectsFromArray:_defaultAutosDataList];
        [_selectedIndex removeAllObjects];
        [_selectedIndex addObjectsFromArray:_defaultSelectedIndex];
    }
    [self hiddenSelfAndSuccess:NO];
}

- (void)showView {
//    if (_inputType==MAIInputTypeOfNone) return;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAppear:) name:UIKeyboardWillShowNotification object:nil];
    @weakify(self)
    [UIView animateWithDuration:0.25 animations:^{
        @strongify(self)
        self.alpha = 1.0f;
        [self hiddenKeyboard];
    }];
}

- (void)setMAICompletionBlock:(MAICompletionBlock)completionBlock {
    self.completionBlock = completionBlock;
}

- (void)datePickerValeChange:(UIDatePicker *)datePicker {
    self.commonTextField.text = [_dateFormatter stringFromDate:datePicker.date];
}

- (void)confirmSetting {
    if (_inputType==MAIInputTypeOfNone) return;
    
    if(!_commonTextField.text||[_commonTextField.text isEqualToString:@""]){
        [_viewShaker shake];
        return;
    }
    
    if (_inputType==MAIInputTypeOfLicensePlate&&(!_commonTextField.text||_commonTextField.text.length!=5||
                                                 [_commonTextField.text isEqualToString:@""]||
                                                 !_licenceCityTF.text||[_licenceCityTF.text isEqualToString:@""]||
                                                 !_licenceProvincesTF.text||[_licenceProvincesTF.text isEqualToString:@""])){
        [SupportingClass showToast:@"请输入正确车牌号"];
        [_viewShaker shake];
        return;
    }
    
    if (_inputType==MAIInputTypeOfAutosSelection) {
       if(!_autosDealershipTextField.text||[_autosDealershipTextField.text isEqualToString:@""]){
            [_viewShaker shake];
            return;
        }else if(!_autosSeriesTextField.text||[_autosSeriesTextField.text isEqualToString:@""]){
            [_viewShaker shake];
            return;
        }else if(!_autosModelTextField.text||[_autosModelTextField.text isEqualToString:@""]){
            [_viewShaker shake];
            return;
        }
    }
    NSDictionary *result = nil;
    if (_inputType==MAIInputTypeOfAutosSelection) {
        NSString *brandID = @"";
        NSString *brandIcon = @"";
        NSString *dealershipID = @"";
        NSString *seriesID = @"";
        NSString *modelID = @"";
        
        NSIndexPath *brandIdx = _selectedIndex[0];
        AutosBrandDTO *dto = [[_autosDataList[0] objectAtIndex:brandIdx.section] objectAtIndex:brandIdx.row] ;
        brandID = dto.brandID;
        brandIcon = dto.brandImg;
        
        NSIndexPath *dealershipIdx = _selectedIndex[1];
        dealershipID = [[_autosDataList[1] objectAtIndex:dealershipIdx.row] objectForKey:kObjIDKey];
        
        NSIndexPath *seriesIdx = _selectedIndex[2];
        seriesID = [[_autosDataList[2] objectAtIndex:seriesIdx.row] objectForKey:kObjIDKey];
        
        NSIndexPath *modelIdx = _selectedIndex[3];;
        modelID = [[_autosDataList[3] objectAtIndex:modelIdx.row] objectForKey:kObjIDKey];
        
        result = @{MAIInputKeyFirstValue:@{@"title":_commonTextField.text, @"keyID":brandID, @"icon":brandIcon},
                   MAIInputKeySecondValue:@{@"title":_autosDealershipTextField.text, @"keyID":dealershipID},
                   MAIInputKeyThirdValue:@{@"title":_autosSeriesTextField.text, @"keyID":seriesID},
                   MAIInputKeyFourthValue:@{@"title":_autosModelTextField.text, @"keyID":modelID}};
        
        [_defaultAutosDataList removeAllObjects];
        [_defaultAutosDataList addObjectsFromArray:_autosDataList];
        [_defaultSelectedIndex removeAllObjects];
        [_defaultSelectedIndex addObjectsFromArray:_selectedIndex];
    }else if (_inputType==MAIInputTypeOfLicensePlate) {
        result = @{MAIInputKeyFirstValue:[NSString stringWithFormat:@"%@%@%@",_licenceProvincesTF.text, _licenceCityTF.text, _commonTextField.text]};
    }else {
        result = @{MAIInputKeyFirstValue:_commonTextField.text};
        
    }
    
    _completionBlock(_inputType, result);
    [self hiddenSelfView];
    
}

//Handle Keyboard Appear
- (void)hiddenKeyboard {
    @weakify(self)
    [UIView animateWithDuration:0.25 animations:^{
        @strongify(self)
        [self.commonTextField resignFirstResponder];
        [self.autosDealershipTextField resignFirstResponder];
        [self.autosSeriesTextField resignFirstResponder];
        [self.autosModelTextField resignFirstResponder];
        [self.licenceCityTF resignFirstResponder];
        [self.licenceProvincesTF resignFirstResponder];

        self.scrollView.contentOffset = CGPointMake(0.0f, 0.0f);

    }];
}

- (void)shiftScrollViewWithAnimation:(UITextField *)textField {
    if (!textField) return;
    CGPoint point = CGPointZero;
    CGFloat contanierViewMaxY = CGRectGetMinY(_contentsView.frame)+CGRectGetMidY(textField.frame);
    CGFloat visibleContentsHeight = (CGRectGetHeight(_scrollView.frame)-CGRectGetHeight(_keyboardRect))/2.0f;
    if (contanierViewMaxY > visibleContentsHeight) {
        CGFloat offsetY = contanierViewMaxY-visibleContentsHeight;
        point.y = offsetY;
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        self.scrollView.contentOffset = point;
    }];
    
}
    
- (void)keyboardWillAppear:(NSNotification *)notiObject {
    CGRect rect = [notiObject.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    if (CGRectEqualToRect(_keyboardRect, CGRectZero)) {
        self.keyboardRect = rect;
        UITextField *textField = _commonTextField;
        if ([_autosDealershipTextField isFirstResponder]) textField = _autosDealershipTextField;
        if ([_autosSeriesTextField isFirstResponder]) textField = _autosSeriesTextField;
        if ([_autosModelTextField isFirstResponder]) textField = _autosModelTextField;
//        [self shiftScrollViewWithAnimation:textField];
    }
}


#pragma -mark UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    if (_inputType==MAIInputTypeOfAutosSelection&&_currentIdx==0) {
        return _tvList.count;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (_inputType==MAIInputTypeOfAutosSelection&&_currentIdx==0) {
        return [_tvList[section] count];
    }
    return _tvList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *ident = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ident];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ident];
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
        [cell setBackgroundColor:CDZColorOfWhite];
        cell.textLabel.text = @"";
        
    }
    // Configure the cell...
    NSString *title = @"";
    NSString *brandImg = @"";
    if (_inputType==MAIInputTypeOfAutosSelection&&_currentIdx==0) {
        AutosBrandDTO *dto = [_tvList[indexPath.section] objectAtIndex:indexPath.row];
        title = dto.brandName;
        brandImg = dto.brandImg;
    }else {
        NSDictionary *detail = _tvList[indexPath.row];
        title = detail[kObjNameKey];
    }
    cell.textLabel.text = title;
    cell.imageView.image = nil;
    if (_inputType==MAIInputTypeOfAutosSelection&&_commonTextField.isFirstResponder) {
        if ([brandImg isContainsString:@"http"]) {
            [cell.imageView sd_setImageWithURL:[NSURL URLWithString:brandImg] placeholderImage:[ImageHandler getWhiteLogo]];
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_inputType==MAIInputTypeOfAutosBodyColor) {
        NSDictionary *detail = _tvList[indexPath.row];
        _commonTextField.text = detail[kObjNameKey];
    }
    if ([_licenceCityTF isFirstResponder]) {
        NSDictionary *detail = _tvList[indexPath.row];
        _licenceCityTF.text = detail[kObjNameKey];
    }
    if ([_licenceProvincesTF isFirstResponder]) {
        NSDictionary *detail = _tvList[indexPath.row];
        _licenceProvincesTF.text = detail[kObjNameKey];
        NSString *autosProvincesID = detail[kObjIDKey];
        _licenceCityTF.text = @"";
        [self getTheAutosCityListWithAutosProvincesID:autosProvincesID];
    }
    
    if (_inputType==MAIInputTypeOfAutosSelection) {
        @autoreleasepool {
            NSMutableArray *selectedIndex = [self mutableArrayValueForKey:@"selectedIndex"];
            [selectedIndex replaceObjectAtIndex:_currentIdx withObject:indexPath];
            
            NSDictionary *detail = nil;
            NSString *theID = @"";
            if (_currentIdx==0) {
                AutosBrandDTO *dto = [[_autosDataList[_currentIdx]  objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
                theID = dto.brandID;
            }else {
                detail = [_autosDataList[_currentIdx] objectAtIndex:indexPath.row];
                theID = detail[kObjIDKey];
            }
            if (_currentIdx==0) {
                [self getAutoDealershipListWith:theID isInitialLoading:NO];
            }else if (_currentIdx==1) {
                [self getAutoSeriesListWith:theID isInitialLoading:NO];
            }else if (_currentIdx==2) {
                [self getAutoModelListWith:theID isInitialLoading:NO];
            }
//            return;
//            if (indexPath.row!=0) {
//                NSDictionary *detail = [_autosDataList[_currentIdx] objectAtIndex:indexPath.row];
//                NSString *theID = detail[kObjIDKey];
//                if (_currentIdx==0) {
//                    [self getAutoDealershipListWith:theID isInitialLoading:NO];
//                }else if (_currentIdx==1) {
//                    [self getAutoSeriesListWith:theID isInitialLoading:NO];
//                }else if (_currentIdx==2) {
//                    [self getAutoModelListWith:theID isInitialLoading:NO];
//                }
//            }else {
//                [tableView deselectRowAtIndexPath:indexPath animated:NO];
//            }
        }

    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (_inputType==MAIInputTypeOfAutosSelection&&_commonTextField.isFirstResponder) {
//        return 70.0f;
//    }
    return 44.0f;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (_inputType==MAIInputTypeOfAutosSelection&&_currentIdx==0) {
        return _keyArray;
    }
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (_inputType==MAIInputTypeOfAutosSelection&&_currentIdx==0) {
        return _keyArray[section];
    }
    return nil;
}

#pragma mark- UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self hiddenKeyboard];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString:@" "]) return NO;
    
    if (self.inputType==MAIInputTypeOfInitialMileage&&textField.text.length==0&&[string isEqualToString:@"0"]) {
        return NO;
    }
    
    if (self.inputType==MAIInputTypeOfInitialMileage&&textField.text.length==7&&![string isEqualToString:@""]) {
        return NO;
    }
    
    if (_inputType==MAIInputTypeOfAutosFrameNumber) {
        return !(textField.text.length>=17&&![string isEqualToString:@""]);
    }
    if (_inputType==MAIInputTypeOfAutosEngineNumber) {
        return !(textField.text.length>=10&&![string isEqualToString:@""]);
    }
    
    if (_inputType==MAIInputTypeOfLicensePlate) {
        return !(textField.text.length>=5&&![string isEqualToString:@""]);
    }
    
    if (![[string stringByTrimmingCharactersInSet:NSCharacterSet.symbolCharacterSet.invertedSet] isEqualToString:@""]) {
        return NO;
    }
    if (![[string stringByTrimmingCharactersInSet:NSCharacterSet.lowercaseLetterCharacterSet.invertedSet] isEqualToString:@""]) {
        textField.text = [textField.text stringByReplacingCharactersInRange:range withString:string.uppercaseString];
        return NO;
    }
    
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (!CGRectEqualToRect(_keyboardRect, CGRectZero)) {
//        [self shiftScrollViewWithAnimation:textField];
    }
    if (_inputType==MAIInputTypeOfAutosSelection&&textField.tag>=vBaseTagForTF) {
        [self reloadTableViewData:textField];
        return YES;
    }
    if (_inputType==MAIInputTypeOfAutosInsuranceDate||
        _inputType==MAIInputTypeOfAutosAnniversaryCheckDate||
        _inputType==MAIInputTypeOfAutosMaintenanceDate||
        _inputType==MAIInputTypeOfAutosRegisterDate) {
        textField.text = [_dateFormatter stringFromDate:_datePicker.date];
    }
    if (textField.inputView==_tableView&&_inputType==MAIInputTypeOfAutosBodyColor){
        [_tvList removeAllObjects];
        [_tvList addObjectsFromArray:_autosColorList];
        [_tableView reloadData];
        if (textField.text&&![textField.text isEqualToString:@""]&&_inputType==MAIInputTypeOfAutosBodyColor) {
            @weakify(self)
            [_tvList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *name = obj[kObjNameKey];
                if ([textField.text isEqualToString:name]) {
                    @strongify(self)
                    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
                    *stop = YES;
                }
                
            }];
        }
    }
    if (_inputType==MAIInputTypeOfLicensePlate) {
        if (textField==_licenceProvincesTF&&_licenceProvincesTF.isFirstResponder){
            
            [_tvList removeAllObjects];
            [_tvList addObjectsFromArray:_autosProvincesList];
            [_tableView reloadData];
            if (textField.text&&![textField.text isEqualToString:@""]) {
                @weakify(self)
                [_tvList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSString *name = obj[kObjNameKey];
                    if ([textField.text isEqualToString:name]) {
                        @strongify(self)
                        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
                        *stop = YES;
                    }
                    
                }];
            }
        }
        
        if (textField==_licenceCityTF&&_licenceCityTF.isFirstResponder) {
            [_tvList removeAllObjects];
            [_tvList addObjectsFromArray:_autosCityList];
            [_tableView reloadData];
            
            if (textField.text&&![textField.text isEqualToString:@""]) {
                @weakify(self)
                [_tvList removeAllObjects];
                [_tvList addObjectsFromArray:_autosCityList];
                [_tableView reloadData];
                [_tvList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSString *name = obj[kObjNameKey];
                    if ([textField.text isEqualToString:name]) {
                        @strongify(self)
                        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
                        *stop = YES;
                    }
                    
                }];
            }
        }
    }
    return YES;
}

- (void)reloadTableViewData:(UITextField *)textField {
    if (!textField.isFirstResponder) return;
    self.currentIdx = textField.tag-vBaseTagForTF;
    id index = _selectedIndex[_currentIdx];
    [_tvList removeAllObjects];
    [_tvList addObjectsFromArray:_autosDataList[self.currentIdx]];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView reloadData];
    if ([index isKindOfClass:NSNull.class])return;
    NSIndexPath *indexPath = index;
    [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionTop];
    
}

- (void)showLoadingInPickerSuperview {
    @autoreleasepool {
        UIView *view = _tableView.superview.superview;
        if (view) {
            [ProgressHUDHandler showHUDWithTitle:nil onView:view];
        }else {
            [ProgressHUDHandler showHUD];
        }
    }
}

- (void)initAutoDataAndSelect:(NSString *)theIDsString {
    self.defaultAutosDataList = [@[@[], @[], @[], @[]] mutableCopy];
    self.defaultSelectedIndex = [@[NSNull.null, NSNull.null, NSNull.null, NSNull.null] mutableCopy];
    if ([theIDsString rangeOfString:@"-1"].location==NSNotFound||
        [theIDsString rangeOfString:@"<null>"].location==NSNotFound) {
        self.initialUpdate = YES;
        self.defaultAutosDataList = [@[@[], @[], @[], @[]] mutableCopy];
        self.defaultSelectedIndex = [@[NSNull.null, NSNull.null, NSNull.null, NSNull.null] mutableCopy];
        self.theIDsList = [theIDsString componentsSeparatedByString:@","];
        [self getAutoBrandListAndInitialLoading:YES];
        [self getAutoDealershipListWith:_theIDsList[0] isInitialLoading:YES];
        [self getAutoSeriesListWith:_theIDsList[1] isInitialLoading:YES];
        [self getAutoModelListWith:_theIDsList[2] isInitialLoading:YES];
    }
}

- (void)initialRequestResultHandle:(NSURLSessionDataTask *)operation responseObject:(id)responseObject withError:(NSError *)error {
    @autoreleasepool {
        
        if (error&&!responseObject) {
            NSLog(@"Error:::>%@",error);
            [ProgressHUDHandler dismissHUD];
            if (error.code==-1009) {
                [SupportingClass showAlertViewWithTitle:@"error" message:@"网络连接失败，请检查网络设置！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                }];
                return;
            }
            
            
            if (error.code==-1001) {
                [SupportingClass showAlertViewWithTitle:@"error" message:@"网络连接逾时，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                }];
                return;
            }
            
            [SupportingClass showAlertViewWithTitle:@"error" message:@"网络错误，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            }];

        }else if (!error&&responseObject) {
            NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
            NSInteger identID = [[operation.userInfo objectForKey:@"ident"] integerValue];
            if (errorCode==0) {
                
                NSMutableArray *objectList = [NSMutableArray arrayWithArray:responseObject[CDZKeyOfResultKey]];
                
                NSMutableArray *autosDataList = [self mutableArrayValueForKey:@"defaultAutosDataList"];
                autosDataList[identID] = objectList;
                if (_theIDsList&&_theIDsList.count!=0) {
                    
                    NSMutableArray *selectedIndex = [self mutableArrayValueForKey:@"defaultSelectedIndex"];
                    NSString *componentID = _theIDsList[identID];
                    
                    [objectList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        NSString *thComponentID = obj[kObjIDKey];
                        if ([thComponentID isEqualToString:componentID]) {
                            [selectedIndex replaceObjectAtIndex:identID withObject:[NSIndexPath indexPathForRow:idx inSection:0]];
                            *stop = YES;
                        }
                    }];
                }
            }
            
        }
    }
}

- (void)delayLoading:(NSArray *)responseObject withError:(NSError *)error isInitialLoading:(BOOL)isInitialLoading{
    NSUInteger identID = 0;
    if (responseObject.count>0) {
        
        
        NSOrderedSet *keySet = [NSOrderedSet orderedSetWithArray:[responseObject valueForKeyPath:@"sortedKey"]];
        self.keyArray = [keySet sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            return [obj1 compare:obj2 options:NSForcedOrderingSearch];
        }];
        NSMutableArray *tmpArray = [NSMutableArray array];
        [_keyArray enumerateObjectsUsingBlock:^(NSString * sortedKey, NSUInteger section, BOOL *sectionStop) {
            NSPredicate * predicate = [NSPredicate predicateWithFormat:@"SELF.sortedKey LIKE[cd] %@", sortedKey];
            NSArray *result = [responseObject filteredArrayUsingPredicate:predicate];
            if (result.count>0) {
                [tmpArray addObject:result];
            }
            
        }];
        
        if (isInitialLoading) {
            NSMutableArray *objectList = [NSMutableArray arrayWithArray:tmpArray];
            NSMutableArray *autosDataList = [self mutableArrayValueForKey:@"defaultAutosDataList"];
            autosDataList[identID] = objectList;
            if (self.theIDsList&&self.theIDsList.count!=0) {
                
                NSMutableArray *selectedIndex = [self mutableArrayValueForKey:@"defaultSelectedIndex"];
                NSString *componentID = self.theIDsList[identID];
                
                [objectList enumerateObjectsUsingBlock:^(id sectionList, NSUInteger section, BOOL *sectionStop) {
                    [sectionList enumerateObjectsUsingBlock:^(id  _Nonnull rowObj, NSUInteger row, BOOL * _Nonnull rowStop) {
                        AutosBrandDTO *dto = rowObj;
                        NSString *thComponentID = dto.brandID;
                        if ([thComponentID isEqualToString:componentID]) {
                            [selectedIndex replaceObjectAtIndex:identID withObject:[NSIndexPath indexPathForRow:row inSection:section]];
                            *rowStop = YES;
                            *sectionStop = YES;
                        }
                    }];
                }];
            }
        }else {
            [self handleResponseData:tmpArray withIdent:identID];
        }
    }else if (error) {
        if (isInitialLoading) {
            [self initialRequestResultHandle:nil responseObject:nil withError:error];
        }else {
            [self requestResultHandle:nil responseObject:nil withError:error];
        }
    }

}

#pragma mark- APIs Access Request
- (void)getAutoBrandListAndInitialLoading:(BOOL)isInitialLoading {
    
    if ([_autosDataList[0] count]>0&&isInitialLoading) {
        NSUInteger identID =0;
        NSArray *tmpArray = _autosDataList[0];
        NSMutableArray *objectList = [NSMutableArray arrayWithArray:tmpArray];
        NSMutableArray *autosDataList = [self mutableArrayValueForKey:@"defaultAutosDataList"];
        autosDataList[identID] = objectList;
        if (self.theIDsList&&self.theIDsList.count!=0) {
            
            NSMutableArray *selectedIndex = [self mutableArrayValueForKey:@"defaultSelectedIndex"];
            NSString *componentID = self.theIDsList[identID];
            
            [objectList enumerateObjectsUsingBlock:^(id sectionList, NSUInteger section, BOOL *sectionStop) {
                [sectionList enumerateObjectsUsingBlock:^(id  _Nonnull rowObj, NSUInteger row, BOOL * _Nonnull rowStop) {
                    AutosBrandDTO *dto = rowObj;
                    NSString *thComponentID = dto.brandID;
                    if ([thComponentID isEqualToString:componentID]) {
                        [selectedIndex replaceObjectAtIndex:identID withObject:[NSIndexPath indexPathForRow:section inSection:row]];
                        *sectionStop = YES;
                        *rowStop = YES;
                    }
                }];
            }];
        }
        return;
    }
    [SupportingClass getAutosBrandList:^(NSArray *resultList, NSError *error) {
        [self delayLoading:resultList withError:error isInitialLoading:isInitialLoading];
    }];
    
    
//    [[APIsConnection shareConnection] commonAPIsGetAutoBrandListWithSuccessBlock:^(NSURLSessionDataTask *operation, id responseObject) {
//        operation.userInfo = @{@"ident":@(0)};
//        if (isInitialLoading) {
//            [self initialRequestResultHandle:operation responseObject:responseObject withError:nil];
//            return;
//        }
//        [self requestResultHandle:operation responseObject:responseObject withError:nil];
//        
//    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
//        if (isInitialLoading) {
//            [self initialRequestResultHandle:operation responseObject:nil withError:error];
//            return;
//        }
//        [self requestResultHandle:operation responseObject:nil withError:error];
//    }];
    
}

- (void)getAutoDealershipListWith:(NSString *)autoBrandID isInitialLoading:(BOOL)isInitialLoading {
    if (!isInitialLoading) {
         [self showLoadingInPickerSuperview];
    }
    [[APIsConnection shareConnection] commonAPIsGetAutoBrandDealershipListWithBrandID:autoBrandID success:^(NSURLSessionDataTask *operation, id responseObject) {
        operation.userInfo = @{@"ident":@(1)};
        if (isInitialLoading) {
            [self initialRequestResultHandle:operation responseObject:responseObject withError:nil];
            return;
        }
        [self requestResultHandle:operation responseObject:responseObject withError:nil];
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        if (isInitialLoading) {
            [self initialRequestResultHandle:operation responseObject:nil withError:error];
            return;
        }
        [self requestResultHandle:operation responseObject:nil withError:error];
    }];
}

- (void)getAutoSeriesListWith:(NSString *)autoDealershipID isInitialLoading:(BOOL)isInitialLoading {
    if (!isInitialLoading) {
        [self showLoadingInPickerSuperview];
    }
    [[APIsConnection shareConnection] commonAPIsGetAutoSeriesListWithBrandDealershipID:autoDealershipID success:^(NSURLSessionDataTask *operation, id responseObject) {
        operation.userInfo = @{@"ident":@(2)};
        if (isInitialLoading) {
            [self initialRequestResultHandle:operation responseObject:responseObject withError:nil];
            return;
        }
        [self requestResultHandle:operation responseObject:responseObject withError:nil];
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        if (isInitialLoading) {
            [self initialRequestResultHandle:operation responseObject:nil withError:error];
            return;
        }
        [self requestResultHandle:operation responseObject:nil withError:error];
    }];
}

- (void)getAutoModelListWith:(NSString *)autoSeriesID isInitialLoading:(BOOL)isInitialLoading {
    if (!isInitialLoading) {
        [self showLoadingInPickerSuperview];
    }
    [[APIsConnection shareConnection] commonAPIsGetAutoModelListWithAutoSeriesID:autoSeriesID success:^(NSURLSessionDataTask *operation, id responseObject) {
        operation.userInfo = @{@"ident":@(3)};
        if (isInitialLoading) {
            [self initialRequestResultHandle:operation responseObject:responseObject withError:nil];
            return;
        }
        [self requestResultHandle:operation responseObject:responseObject withError:nil];
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        if (isInitialLoading) {
            [self initialRequestResultHandle:operation responseObject:nil withError:error];
            return;
        }
        [self requestResultHandle:operation responseObject:nil withError:error];
    }];
}

- (void)requestResultHandle:(NSURLSessionDataTask *)operation responseObject:(id)responseObject withError:(NSError *)error {
    [ProgressHUDHandler dismissHUD];
    if (error&&!responseObject) {
        NSLog(@"Error:::>%@",error);
        [ProgressHUDHandler dismissHUD];
        if (error.code==-1009) {
            [SupportingClass showAlertViewWithTitle:@"error" message:@"网络连接失败，请检查网络设置！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            }];
            return;
        }
        
        
        if (error.code==-1001) {
            [SupportingClass showAlertViewWithTitle:@"error" message:@"网络连接逾时，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            }];
            return;
        }
        
        [SupportingClass showAlertViewWithTitle:@"error" message:@"网络错误，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
        }];

    }else if (!error&&responseObject) {
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSInteger identID = [[operation.userInfo objectForKey:@"ident"] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"requestResultHandle-%d:%@",identID, message);
        if (errorCode!=0) {
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:nil];
            [self handleResponseData:@[] withIdent:identID];
            return;
        }
        [self handleResponseData:[responseObject objectForKey:CDZKeyOfResultKey] withIdent:identID];
       
    }
}

- (void)handleResponseData:(NSArray *)responseObject withIdent:(NSInteger)ident{
    @autoreleasepool {
        if (!responseObject) {
            NSString *messageKey = [NSString stringWithFormat:@"auto_data_error_%ld",(long)ident];
            NSString *errorStr = getLocalizationString(messageKey);
            NSLog(@"%@",errorStr);
            return;
        }
        
        NSMutableArray *objectList = [NSMutableArray arrayWithArray:responseObject];

        NSMutableArray *autosDataList = [self mutableArrayValueForKey:@"autosDataList"];
        autosDataList[ident] = objectList;
        
        NSMutableArray *selectedIndex = [self mutableArrayValueForKey:@"selectedIndex"];
        if (_currentIdx==0) {
            selectedIndex[1] = NSNull.null;
            selectedIndex[2] = NSNull.null;
            selectedIndex[3] = NSNull.null;
            autosDataList[2] = @[];
            autosDataList[3] = @[];
            
        }
        if (_currentIdx==1) {
            selectedIndex[2] = NSNull.null;
            selectedIndex[3] = NSNull.null;
            autosDataList[3] = @[];
        }
        
        if (_currentIdx==2) {
            selectedIndex[3] = NSNull.null;
        }
    }
}

- (void)getTheAutosColorList {
    @weakify(self)
    [ProgressHUDHandler showHUD];
    [APIsConnection.shareConnection personalCenterAPIsGetMyAutoColorListWithSuccess:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self)
        [ProgressHUDHandler dismissHUD];
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"getTheAutosColorList:%@",message);
        if (errorCode!=0) {
            self.autosProvincesList = @[];
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:nil];
            return;
        }
        self.autosColorList = responseObject[CDZKeyOfResultKey];
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        @strongify(self)
        self.autosProvincesList = @[];
        [ProgressHUDHandler dismissHUD];
        if (error.code==-1009) {
            [SupportingClass showAlertViewWithTitle:@"error" message:@"网络连接失败，请检查网络设置！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            }];
            return;
        }
        
        
        if (error.code==-1001) {
            [SupportingClass showAlertViewWithTitle:@"error" message:@"网络连接逾时，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            }];
            return;
        }
        
        [SupportingClass showAlertViewWithTitle:@"error" message:@"网络错误，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
        }];

    }];
}

- (void)getTheAutosProvincesList {
    @weakify(self)
    [ProgressHUDHandler showHUD];
    [APIsConnection.shareConnection personalCenterAPIsGetMyAutoProvincesListWithSuccess:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self)
        
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"TheAutosProvincesList:%@",message);
        if (errorCode!=0) {
            [ProgressHUDHandler dismissHUD];
            self.autosProvincesList = @[];
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:nil];
            return;
        }
        self.autosProvincesList = responseObject[CDZKeyOfResultKey];
        if (self.licenceCityTF.text&&![self.licenceCityTF.text isEqualToString:@""]) {
            __block NSString *autosProvincesID = @"";
            [self.autosProvincesList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *name = obj[kObjNameKey];
                @strongify(self)
                if ([self.licenceProvincesTF.text isEqualToString:name]) {
                    autosProvincesID = obj[@"id"];
                    *stop = YES;
                }
                
            }];
            self.wouldNotShowHub = YES;
            [self getTheAutosCityListWithAutosProvincesID:autosProvincesID];
            
        }else {
            [ProgressHUDHandler dismissHUD];
        }
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        @strongify(self)
        self.autosProvincesList = @[];
        [ProgressHUDHandler dismissHUD];
        if (error.code==-1009) {
            [SupportingClass showAlertViewWithTitle:@"error" message:@"网络连接失败，请检查网络设置！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            }];
            return;
        }
        
        
        if (error.code==-1001) {
            [SupportingClass showAlertViewWithTitle:@"error" message:@"网络连接逾时，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            }];
            return;
        }
        
        [SupportingClass showAlertViewWithTitle:@"error" message:@"网络错误，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
        }];

    }];
}

- (void)getTheAutosCityListWithAutosProvincesID:(NSString *)autosProvincesID {
    if (!autosProvincesID||[autosProvincesID isEqualToString:@""]) return;
    if (!_wouldNotShowHub) {
        [ProgressHUDHandler showHUD];
    }
    _wouldNotShowHub = NO;
    @weakify(self)
    [APIsConnection.shareConnection personalCenterAPIsGetMyAutoCityListWithAutoProvincesID:autosProvincesID success:^(NSURLSessionDataTask *operation, id responseObject) {
        [ProgressHUDHandler dismissHUD];
        @strongify(self)
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        if (errorCode!=0) {
            NSLog(@"TheAutosCityListWithAutosProvincesID:%@",message);
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:nil];
            return;
        }
        self.autosCityList = responseObject[CDZKeyOfResultKey];
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        //        @strongify(self) [ProgressHUDHandler dismissHUD];
        if (error.code==-1009) {
            [SupportingClass showAlertViewWithTitle:@"error" message:@"网络连接失败，请检查网络设置！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            }];
            return;
        }
        
        
        if (error.code==-1001) {
            [SupportingClass showAlertViewWithTitle:@"error" message:@"网络连接逾时，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            }];
            return;
        }
        
        [SupportingClass showAlertViewWithTitle:@"error" message:@"网络错误，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
        }];

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
