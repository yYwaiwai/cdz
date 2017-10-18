//
//  MaintenanceRecordInsertEditVC.m
//  cdzer
//
//  Created by KEns0nLau on 10/13/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "MaintenanceRecordInsertEditVC.h"
#import "UIView+LayoutConstraintHelper.h"
#import "MaintenanceRecordInsertEditCell.h"


@interface MaintenanceRecordInsertEditVC ()<UITextFieldDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UILabel *mileageLabel;

@property (weak, nonatomic) IBOutlet UILabel *dateTimeLabel;
@property (weak, nonatomic) IBOutlet UITextField *dateTimeTF;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;


@property (nonatomic, strong) UIDatePicker *datePicker;

@property (nonatomic, strong) NSString *dateTime;

@property (nonatomic, strong) NSString *totalMileage;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic, strong) NSMutableArray *maintainList;

@property (nonatomic, strong) NSMutableArray <NSLayoutConstraint *> *constraintList;

@property (nonatomic, strong) NSString *recordID;

@property (nonatomic, strong) UserAutosInfoDTO *userAutosData;

@property (nonatomic, strong) UIToolbar *datePickerToolbar;

@property (nonatomic, strong) UIView *mileageBGView;

@property (nonatomic, strong) UITextField *mileageTF;

@property (weak, nonatomic) IBOutlet UIView *maintenanceRecordView;

@end

@implementation MaintenanceRecordInsertEditVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)viewDidLoad {
    self.title = @"快速保养";
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self componentSetting];
    [self initializationUI];
    [self setReactiveRules];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    UICollectionViewFlowLayout *collectionViewFlowLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    UIEdgeInsets sectionInset = collectionViewFlowLayout.sectionInset;
    sectionInset.bottom = roundf(CGRectGetHeight(self.confirmBtn.superview.frame))+13;
    collectionViewFlowLayout.sectionInset = sectionInset;
//    [self.collectionView reloadData];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self borderSetting];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self borderSetting];
}

- (void)borderSetting {
    
    UIColor *borderColor = [UIColor colorWithRed:0.839 green:0.843 blue:0.863 alpha:1.00];
    [self.collectionView.superview setViewCornerWithRectCorner:UIRectCornerTopLeft|UIRectCornerTopRight cornerSize:3.0f];
    
    [self.collectionView setViewBorderWithRectBorder:UIRectBorderTop borderSize:0.5 withColor:borderColor withBroderOffset:nil];
    
    [self.mileageLabel.superview setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:0.5 withColor:borderColor withBroderOffset:nil];
    [self.mileageLabel.superview setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:1.0f];
    
    [self.dateTimeTF.superview setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:0.5 withColor:borderColor withBroderOffset:nil];
    [self.dateTimeTF.superview setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:1.0f];
    
    [self.confirmBtn setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:5.0f];
    [self.confirmBtn.superview setViewBorderWithRectBorder:UIRectBorderTop borderSize:0.5 withColor:borderColor withBroderOffset:nil];
}

- (void)componentSetting {
    @autoreleasepool {
        
        NSDictionary *serviceDetail = DBHandler.shareInstance.getMaintenanceServiceList;
        self.maintainList = [serviceDetail[CDZObjectKeyOfConventionMaintain] mutableCopy];
        [self.maintainList addObjectsFromArray:serviceDetail[CDZObjectKeyOfDeepnessMaintain]];
        self.userAutosData = [DBHandler.shareInstance getUserAutosDetail];
        
        self.collectionView.allowsMultipleSelection = YES;
        [self.collectionView registerNib:[UINib nibWithNibName:@"MaintenanceRecordInsertEditCell" bundle:nil] forCellWithReuseIdentifier:CDZKeyOfCellIdentKey];
    }
}

- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [NSDateFormatter new];
        [_dateFormatter setDateFormat:@"yyyy-MM-dd"];
    }
    return _dateFormatter;
}


- (void)initializationUI {
    @autoreleasepool {
        
        if (self.dateTime) {
            self.dateTimeTF.text = self.dateTime;
        }
        
        if (self.totalMileage) {
            self.mileageLabel.text = self.totalMileage;
        }
        
        
        self.datePicker = [UIDatePicker new];
        self.datePicker.backgroundColor = CDZColorOfWhite;
        [self.datePicker addTarget:self action:@selector(dateChangeFromDatePicker:) forControlEvents:UIControlEventValueChanged];
        self.datePicker.datePickerMode = UIDatePickerModeDate;
        
        
        self.datePickerToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth([UIScreen mainScreen].bounds), 40.0f)];
        [self.datePickerToolbar setBarStyle:UIBarStyleDefault];
        UIBarButtonItem *dateSpaceButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                    target:self
                                                                                    action:nil];
        UIBarButtonItem *dateDoneButton = [[UIBarButtonItem alloc]initWithTitle:getLocalizationString(@"finish")
                                                                      style:UIBarButtonItemStyleDone
                                                                     target:self
                                                                     action:@selector(hiddenKeyboard)];
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]initWithTitle:@"取消"
                                                                        style:UIBarButtonItemStyleDone
                                                                       target:self
                                                                       action:@selector(cancelKeyboard)];
        dateDoneButton.tintColor = [UIColor colorWithHexString:@"6DD2F7"];
        cancelButton.tintColor = [UIColor colorWithHexString:@"6DD2F7"];
        NSArray * dateButtonsArray = [NSArray arrayWithObjects:cancelButton,dateSpaceButton,dateDoneButton,nil];
        [self.datePickerToolbar setItems:dateButtonsArray];
        
        self.dateTimeTF.inputView = self.datePicker;
        self.dateTimeTF.inputAccessoryView = self.datePickerToolbar;
    }
}

- (void)setReactiveRules {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)hiddenKeyboard {
    self.dateTime = self.dateTimeTF.text;
    [self.dateTimeTF resignFirstResponder];
}

-(void)cancelKeyboard
{
    [self.dateTimeTF resignFirstResponder];
}

- (void)dateChangeFromDatePicker:(UIDatePicker *)datePicker {
    self.dateTimeTF.text = [self.dateFormatter stringFromDate:datePicker.date];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (self.dateTimeTF==textField){
        NSDate *date = NSDate.date;
        if (!self.dateTimeTF.text||[self.dateTimeTF.text isEqualToString:@"请选择保养时间"]) {
            self.dateTime = [self.dateFormatter stringFromDate:date];
            self.dateTimeTF.text = self.dateTime;
        }
        if (![self.dateTimeTF.text isEqualToString:@"请选择保养时间"]) {
            textField.text =self.dateTimeTF.text;
            date=[self.dateFormatter dateFromString:textField.text];
            self.datePicker.date = [self.dateFormatter dateFromString:textField.text];
        }
        textField.text = [self.dateFormatter stringFromDate:self.datePicker.date];
        self.datePicker.date = [self.dateFormatter dateFromString:self.dateTime];
        self.datePicker.minimumDate = date;
        
        
    }
}


- (void)addSelfToWindow {
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    UIWindow *keyWindow = UIApplication.sharedApplication.keyWindow;
    [keyWindow addSubview:self.view];
    if (!self.constraintList) {
        self.constraintList = [self.view addSelfByFourMarginToSuperview:keyWindow];
    }
    [keyWindow addConstraints:self.constraintList];
    [self borderSetting];
}

- (void)showInsertModeView {
    [self addSelfToWindow];
}

- (void)showEditModeViewWithRecordID:(NSString *)recordID selectedItemList:(NSArray <NSString *> *)itemList dateTime:(NSString *)dateTime mileageRecord:(NSString *)mileage {
    if (!recordID||[recordID isEqualToString:@""]) {
        NSLog(@"Missing recordID at %@", NSStringFromClass(self.class));
        return;
    }
    
    if (dateTime&&[self.dateFormatter dateFromString:dateTime]) {
        self.dateTime = dateTime;
        self.dateTimeTF.text = self.dateTime;
    }
    
    if (mileage&&mileage.integerValue>0) {
        self.totalMileage = mileage;
        self.mileageLabel.text = self.totalMileage;
    }
    
    [self addSelfToWindow];
    self.recordID = recordID;
    @weakify(self);
    NSArray <NSString *> *itemNameList = [self.maintainList valueForKey:@"name"];
    [itemList enumerateObjectsUsingBlock:^(NSString * _Nonnull name, NSUInteger idx, BOOL * _Nonnull stop) {
        @strongify(self);
        name = [name stringByReplacingOccurrencesOfString:@" " withString:@""];
        [itemNameList enumerateObjectsUsingBlock:^(NSString * _Nonnull compareName, NSUInteger row, BOOL * _Nonnull subStop) {
            compareName = [compareName stringByReplacingOccurrencesOfString:@" " withString:@""];
            if ([name isContainsString:compareName]) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:row inSection:0];
                [self.collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
                *subStop = YES;
            }
        }];
    }];
}

- (void)clearSettting {
    self.recordID = nil;
    self.totalMileage = nil;
    self.dateTime = nil;
    self.mileageLabel.text = @"请输入行驶里程";
    self.dateTimeTF.text = @"请选择保养时间";
    [self.collectionView reloadData];
    self.collectionView.contentOffset = CGPointZero;
}

- (IBAction)dismissView {
    UIWindow *keyWindow = UIApplication.sharedApplication.keyWindow;
    [keyWindow removeConstraints:self.constraintList];
    [self.view removeFromSuperview];
    [self clearSettting];
}

- (void)commitSuccess {
    if (self.successBlock) {
        self.successBlock();
    }
    [self dismissView];
}

- (IBAction)changeMileage {
    
    self.mileageBGView=[[UIView alloc]init];
    self.mileageBGView.frame=self.view.bounds;
    self.mileageBGView.backgroundColor=[UIColor colorWithHexString:@"676767" alpha:0.6];
    [self.view addSubview:self.mileageBGView];
    
    UIView *alertBGView=[[UIView alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.bounds)/6, CGRectGetMinY(self.maintenanceRecordView.frame)-110, CGRectGetWidth(self.view.bounds)*0.72, 100)];
    [self.mileageBGView addSubview:alertBGView];
    alertBGView.backgroundColor=[UIColor colorWithHexString:@"e2e2e2"];
    [alertBGView setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:10];
    
    self.mileageTF=[[UITextField alloc]initWithFrame:CGRectMake(12, 24, CGRectGetWidth(alertBGView.frame)-24, 28)];
    alertBGView.backgroundColor=CDZColorOfWhite;
    self.mileageTF.keyboardType =UIKeyboardTypeNumberPad;
    self.mileageTF.borderStyle=UITextBorderStyleNone;
    self.mileageTF.delegate = self;
    [alertBGView addSubview:self.mileageTF];
    [self.mileageTF setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:5];
    [self.mileageTF setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:0.5 withColor:nil withBroderOffset:nil];
    if (![self.mileageTF.text isEqualToString:@"0"]) {
        self.mileageTF.text=self.totalMileage;
    }
    @weakify(self);
    [self.mileageTF.rac_textSignal subscribeNext:^(NSString * _Nullable text) {
        @strongify(self);
        if (![text isEqualToString:@""]) {
            NSDecimalNumber *number = [NSDecimalNumber decimalNumberWithString:text];
            if ([number.stringValue isEqualToString:@"NaN"]) {
                self.mileageTF.text = @"";
            }else if(text.length!=number.stringValue.length) {
                self.mileageTF.text = number.stringValue;
            }
            if (self.mileageTF.text.length>11) {
                self.mileageTF.text = [self.mileageTF.text substringToIndex:self.mileageTF.text.length-1];
            }
        }
    }];
    
    
    UIButton *cancelButton=[[UIButton alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.mileageTF.frame)+13, CGRectGetWidth(alertBGView.bounds)/2, 35)];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [alertBGView addSubview:cancelButton];
    [cancelButton setTitleColor:CDZColorOfBlue forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton setViewBorderWithRectBorder:UIRectBorderRight|UIRectBorderTop borderSize:0.5 withColor:nil withBroderOffset:nil];
    
    UIButton *ensureButton=[[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(alertBGView.bounds)/2, CGRectGetMaxY(self.mileageTF.frame)+13, CGRectGetWidth(alertBGView.bounds)/2, 35)];
    [ensureButton setTitle:@"确定" forState:UIControlStateNormal];
    [alertBGView addSubview:ensureButton];
    [ensureButton setTitleColor:CDZColorOfBlue forState:UIControlStateNormal];
    [ensureButton setViewBorderWithRectBorder:UIRectBorderRight|UIRectBorderTop borderSize:0.5 withColor:nil withBroderOffset:nil];
    [ensureButton addTarget:self action:@selector(ensureButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
}

-(void)cancelButtonClick{
    [self.mileageTF resignFirstResponder];
    [self.mileageBGView removeFromSuperview];
}

-(void)ensureButtonClick{
    [self.mileageTF resignFirstResponder];
    [self.mileageBGView removeFromSuperview];
    self.totalMileage=self.mileageTF.text;
    self.mileageLabel.text = self.totalMileage;
}

#pragma -mark UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.maintainList.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewFlowLayout *collectionViewFlowLayout = (UICollectionViewFlowLayout *)collectionViewLayout;
    CGSize size = CGSizeMake(96, 30);
    collectionViewFlowLayout.minimumInteritemSpacing = (CGRectGetWidth(collectionView.frame)-size.width*3)/2;
    if(IS_IPHONE_4_OR_LESS||IS_IPHONE_5) {
        collectionViewFlowLayout.minimumInteritemSpacing = 22;
        size = CGSizeMake((CGRectGetWidth(collectionView.frame)-collectionViewFlowLayout.minimumInteritemSpacing)/2, 30);
    }
    return size;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    MaintenanceRecordInsertEditCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CDZKeyOfCellIdentKey forIndexPath:indexPath];
    NSString *name = [self.maintainList[indexPath.item] objectForKey:@"name"];
    cell.maintainNameLabel.text = name;
    return cell;
}

- (IBAction)submitRecordInfo {
    
    if (!self.totalMileage) {
        [SupportingClass showAlertViewWithTitle:nil message:@"请输入里程" isShowImmediate:YES cancelButtonTitle:nil otherButtonTitles:nil clickedButtonAtIndexWithBlock:nil];
        return;
    }
    
    if (!self.dateTime) {
        [SupportingClass showAlertViewWithTitle:nil message:@"请选择保养时间" isShowImmediate:YES cancelButtonTitle:nil otherButtonTitles:nil clickedButtonAtIndexWithBlock:nil];
        return;
    }
    
    if (self.collectionView.indexPathsForSelectedItems.count==0) {
        [SupportingClass showAlertViewWithTitle:nil message:@"请选择保养项目" isShowImmediate:YES cancelButtonTitle:nil otherButtonTitles:nil clickedButtonAtIndexWithBlock:nil];
        return;
    }
    NSArray *maintenanceItemIDList = [self.maintainList valueForKey:@"id"];
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    [self.collectionView.indexPathsForSelectedItems enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull indexPath, NSUInteger idx, BOOL * _Nonnull stop) {
        [indexSet addIndex:indexPath.item];
    }];
    maintenanceItemIDList = [maintenanceItemIDList objectsAtIndexes:indexSet];
    
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    @weakify(self);
    [ProgressHUDHandler showHUD];
    if (self.recordID) {
        [APIsConnection.shareConnection maintenanceRecordAPIsPostEditMaintenanceRecordWithAccessToken:self.accessToken recordID:self.recordID brandID:self.userAutosData.brandID dealershipID:self.userAutosData.dealershipID seriesID:self.userAutosData.seriesID modelID:self.userAutosData.modelID totalMileage:self.totalMileage maintenanceDateTime:self.dateTime maintenanceItemIDList:maintenanceItemIDList success:^(NSURLSessionDataTask *operation, id responseObject) {
            @strongify(self);
            NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
            NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
            NSLog(@"%@",message);
            [ProgressHUDHandler dismissHUD];
            if (errorCode!=0) {
                if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {return;};
                [SupportingClass showAlertViewWithTitle:nil message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
                return;
            }
            [self commitSuccess];
            
        } failure:^(NSURLSessionDataTask *operation, NSError *error) {
            [ProgressHUDHandler showError];
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
        
    }else {
        [APIsConnection.shareConnection maintenanceRecordAPIsPostAddMaintenanceRecordWithAccessToken:self.accessToken brandID:self.userAutosData.brandID dealershipID:self.userAutosData.dealershipID seriesID:self.userAutosData.seriesID modelID:self.userAutosData.modelID totalMileage:self.totalMileage maintenanceDateTime:self.dateTime maintenanceItemIDList:maintenanceItemIDList success:^(NSURLSessionDataTask *operation, id responseObject) {
            @strongify(self);
            NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
            NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
            NSLog(@"%@",message);
            [ProgressHUDHandler dismissHUD];
            if (errorCode!=0) {
                if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {return;};
                [SupportingClass showAlertViewWithTitle:nil message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
                return;
            }
            [self commitSuccess];
        } failure:^(NSURLSessionDataTask *operation, NSError *error) {
            [ProgressHUDHandler showError];
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
    
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
