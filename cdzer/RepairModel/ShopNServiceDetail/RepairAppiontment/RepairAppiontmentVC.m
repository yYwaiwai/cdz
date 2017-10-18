//
//  RepairAppiontmentVC.m
//  cdzer
//
//  Created by KEns0nLau on 9/18/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "RepairAppiontmentVC.h"
#import "UserSelectedAutosInfoDTO.h"
#import "ShopMechanicSearchListVC.h"
#import "UserAutosSelectonVC.h"
#import "MaintenanceDetailsVC.h"
#import "UITextField+ShareAction.h"
#import "RepairServiceItemSelectionVC.h"
#import "SMSLResultDTO.h"
#import <SDWebImage/UIImageView+WebCache.h>


@interface RepairAppiontmentVC () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) UIImage *autosBrandLogoImage;

@property (weak, nonatomic) IBOutlet UIImageView *autosBrandLogoIV;

@property (weak, nonatomic) IBOutlet UILabel *autosInfoLabel;

@property (weak, nonatomic) IBOutlet UIView *autosInfoContainerView;

@property (weak, nonatomic) IBOutlet UIButton *autoSelectionBtn;

@property (weak, nonatomic) IBOutlet UILabel *selectedRemindLabel;



@property (weak, nonatomic) IBOutlet UIImageView *repairShopBrandIV;

@property (weak, nonatomic) IBOutlet UILabel *repairShopNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *repairShopAddressLabel;

@property (weak, nonatomic) IBOutlet UILabel *repairShopTypeLabel;

@property (weak, nonatomic) IBOutlet UIButton *telBtn;


@property (strong, nonatomic) UIToolbar *toolBar;
@property (strong, nonatomic) UIDatePicker *datePicker;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@property (weak, nonatomic) IBOutlet UITextField *userNameTF;

@property (weak, nonatomic) IBOutlet UITextField *userPhoneNumTF;

@property (strong, nonatomic) NSString *appointmentTimeString;
@property (weak, nonatomic) IBOutlet UITextField *appointmentTimeTF;

@property (weak, nonatomic) IBOutlet UILabel *technicianNameLabel;

@property (weak, nonatomic) IBOutlet UISwitch *technicianChangeAgreementSwitch;

@property (weak, nonatomic) IBOutlet UILabel *repairTitleLabel;

@property (weak, nonatomic) IBOutlet UILabel *repairItemsLabel;

@property (weak, nonatomic) IBOutlet UIImageView *repairItemSelectionIndicatorView;


@property (weak, nonatomic) IBOutlet UIButton *submitBtn;

@property (strong, nonatomic) UserSelectedAutosInfoDTO *selectedAutosDto;

@property (nonatomic) CGRect keyboardRect;

@property (nonatomic, strong) NSArray <NSString *> *repairItem;

@property (nonatomic, strong) NSArray <NSString *> *maintainItem;

@property (nonatomic, strong) NSString *shopID;

@property (nonatomic, strong) NSMutableArray *selectItemList;


@property (weak, nonatomic) IBOutlet UIImageView *mechanicSelectIndicatorIV;

@property (nonatomic, assign) BOOL isLockMechanicSelection;


@end

@implementation RepairAppiontmentVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"立即预约";
    self.edgesForExtendedLayout = UIRectEdgeTop;
    // Do any additional setup after loading the view from its nib.
    [self componentSetting];
    [self initializationUI];
    [self setReactiveRules];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateAutosData];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillAppear:) name:UIKeyboardWillShowNotification object:nil];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(textFieldTextDidChange:) name:UITextFieldTextDidChangeNotification object:self.userNameTF];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillDisappear:) name:UIKeyboardWillHideNotification object:nil];
    
    
    self.navigationController.navigationBar.translucent = NO;
    [UIApplication.sharedApplication setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
    UIColor *barBKC = [UIColor colorWithHexString:@"FAFAFA"];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"323232"]};
    self.navigationController.navigationBar.barTintColor = barBKC;
    self.navigationController.navigationBar.backgroundColor = barBKC;
    self.navigationController.navigationBar.tintColor = [UIColor colorWithHexString:@"323232"];
    [self.navigationController.navigationBar setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:[UIColor colorWithRed:0.698 green:0.698 blue:0.698 alpha:1.00] withBroderOffset:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [NSNotificationCenter.defaultCenter removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [NSNotificationCenter.defaultCenter removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    BorderOffsetObject *offset = [BorderOffsetObject new];
    offset.leftUpperOffset = 10;
    offset.leftBottomOffset = offset.leftUpperOffset;
    [self.repairShopTypeLabel setViewBorderWithRectBorder:UIRectBorderLeft borderSize:0.5 withColor:[UIColor colorWithRed:0.839 green:0.843 blue:0.863 alpha:1.00] withBroderOffset:offset];
    
    [self.repairShopTypeLabel setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:3.0f];
    
    [self.repairShopBrandIV.superview setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:3.0f];
    [self.repairShopBrandIV.superview setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:0.5 withColor:[UIColor colorWithRed:0.839 green:0.843 blue:0.863 alpha:1.00] withBroderOffset:nil];
    
    [self.repairShopBrandIV.superview.superview setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    
    [self.userNameTF.superview setViewBorderWithRectBorder:UIRectBorderTop borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self.userPhoneNumTF.superview setViewBorderWithRectBorder:UIRectBorderTop borderSize:0.5 withColor:nil withBroderOffset:nil];
    
    [self.appointmentTimeTF.superview setViewBorderWithRectBorder:UIRectBorderTop borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self.technicianNameLabel.superview.superview setViewBorderWithRectBorder:UIRectBorderTop borderSize:0.5 withColor:nil withBroderOffset:nil];
    
    [self.technicianChangeAgreementSwitch.superview setViewBorderWithRectBorder:UIRectBorderTop borderSize:0.5 withColor:nil withBroderOffset:nil];
    
    [self.repairItemsLabel.superview.superview setViewBorderWithRectBorder:UIRectBorderTop|UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    
    [self.submitBtn setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:4.0f];
    
    [self.autosBrandLogoIV setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:CGRectGetHeight(self.autosBrandLogoIV.frame)/2.0f];
    [self.autosBrandLogoIV.superview setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:CGRectGetHeight(self.autosBrandLogoIV.superview.frame)/2.0f];
}

- (void)handleNavBackBtnPopOtherAction {
    @autoreleasepool {
        
    }
}

- (void)componentSetting {
    @autoreleasepool {
        
        self.dateFormatter = [NSDateFormatter new];
        [self.dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        self.selectItemList = [@[] mutableCopy];
        
        self.shopID = [SupportingClass verifyAndConvertDataToString:self.shopDetail[@"id"]];
        if (!self.isSpecServiceShop) {
            self.repairItem = [self.shopDetail[@"repair_item"] valueForKey:@"name"];
            self.maintainItem = [self.shopDetail[@"maintain_item"] valueForKey:@"name"];
        }
        
        self.autosBrandLogoImage = self.autosBrandLogoIV.image;
        self.repairTitleLabel.text = self.isSpecServiceShop?@"专修项目":@"预约项目";
        
        self.repairShopTypeLabel.text = self.isSpecServiceShop?@"专 修 店":@"品 牌 店";
        self.repairShopTypeLabel.backgroundColor = [UIColor colorWithHexString:self.isSpecServiceShop?@"F8AF30":@"49C7F5"];
        self.repairShopNameLabel.text = self.shopDetail[@"wxs_name"];
        self.repairShopAddressLabel.text = self.shopDetail[@"wxs_address"];
        
        UIColor *attributedTextColor = [UIColor colorWithHexString:@"909090"];
        NSMutableAttributedString *attributedText = [NSMutableAttributedString new];
        [attributedText appendAttributedString:[[NSAttributedString alloc]
                                                initWithString:@"请选择技师\n"
                                                attributes:@{NSForegroundColorAttributeName:attributedTextColor,
                                                             NSFontAttributeName:[UIFont systemFontOfSize:14]}]];
        [attributedText appendAttributedString:[[NSAttributedString alloc]
                                                initWithString:@"(不选择系统会自动指派)"
                                                attributes:@{NSForegroundColorAttributeName:attributedTextColor,
                                                             NSFontAttributeName:[UIFont systemFontOfSize:10]}]];
        
        self.technicianNameLabel.attributedText = attributedText;
        
        UIImage *image = self.repairShopBrandIV.image;
        NSString *shopLogoURLString = self.shopDetail[@"wxs_logo"];
        if ([shopLogoURLString isContainsString:@"http"]) {
            [self.repairShopBrandIV sd_setImageWithURL:[NSURL URLWithString:shopLogoURLString] placeholderImage:image];
        }
        
        if (self.selectedMechanicDetail) {
            self.isLockMechanicSelection = YES;
            self.mechanicSelectIndicatorIV.hidden = YES;
            self.technicianNameLabel.text = self.selectedMechanicDetail.mechanicName;
        }
        
        [self updateRepairItemDisplay];
    }
}

- (void)initializationUI {
    @autoreleasepool {
        self.toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.view.frame), 44.0f)];
        [self.toolBar setBarStyle:UIBarStyleDefault];
        UIBarButtonItem *spaceButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                    target:self
                                                                                    action:nil];
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]initWithTitle:getLocalizationString(@"finish")
                                                                      style:UIBarButtonItemStyleDone
                                                                     target:self
                                                                     action:@selector(hiddenKeyboard)];
        NSArray * buttonsArray = [NSArray arrayWithObjects:spaceButton,doneButton,nil];
        [self.toolBar setItems:buttonsArray];
        
        self.userNameTF.inputAccessoryView = self.toolBar;
        self.userPhoneNumTF.inputAccessoryView = self.toolBar;
        self.userNameTF.shouldStopPCDAction = YES;
        self.userPhoneNumTF.shouldStopPCDAction = YES;
        self.appointmentTimeTF.shouldStopPCDAction = YES;
        
        self.datePicker = [UIDatePicker new];
        self.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
        [self.datePicker addTarget:self action:@selector(dateChangeFromDatePicker:) forControlEvents:UIControlEventValueChanged];
        self.appointmentTimeTF.inputView = self.datePicker;
        self.appointmentTimeTF.inputAccessoryView = self.toolBar;
    }
}

- (void)setReactiveRules {
    @autoreleasepool {
        
    }
}

- (void)updateAutosData {
    self.selectedAutosDto = [DBHandler.shareInstance getSelectedAutoData];
    BOOL needToAutosInfo = (!self.selectedAutosDto.brandID||[self.selectedAutosDto.brandID isEqualToString:@""]||
                            !self.selectedAutosDto.dealershipID||[self.selectedAutosDto.dealershipID isEqualToString:@""]||
                            !self.selectedAutosDto.seriesID||[self.selectedAutosDto.seriesID isEqualToString:@""]||
                            !self.selectedAutosDto.modelID||[self.selectedAutosDto.modelID isEqualToString:@""]);
    self.selectedRemindLabel.hidden = !needToAutosInfo;
    self.autosInfoContainerView.hidden = needToAutosInfo;
    if (!needToAutosInfo) {
        [self.autosBrandLogoIV sd_setImageWithURL:[NSURL URLWithString:self.selectedAutosDto.brandImgURL] placeholderImage:self.autosBrandLogoImage];
        self.autosInfoLabel.text = [NSString stringWithFormat:@"%@%@", self.selectedAutosDto.seriesName, self.selectedAutosDto.modelName];
    }
}

- (IBAction)pushToAutosSelection {
    @autoreleasepool {
        
        UserAutosSelectonVC *vc = [UserAutosSelectonVC new];
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)pushToReselectServiceItem {
    @autoreleasepool {
        if (self.isSpecServiceShop) return;
        
        RepairServiceItemSelectionVC *vc = [RepairServiceItemSelectionVC new];
        vc.isSpecServiceShop = self.isSpecServiceShop;
        vc.shopDetail = self.shopDetail;
        vc.repairSelectedIndexPath = self.repairSelectedIndexPath;
        vc.maintainSelectedIndexPath = self.maintainSelectedIndexPath;
        @weakify(self);
        vc.resultBlock = ^(NSMutableSet <NSIndexPath *> *repairSelectedIndexPath, NSMutableSet <NSIndexPath *> *maintainSelectedIndexPath){
            @strongify(self);
            self.repairSelectedIndexPath = repairSelectedIndexPath;
            self.maintainSelectedIndexPath = maintainSelectedIndexPath;
            [self updateRepairItemDisplay];
        };
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)updateRepairItemDisplay {
    self.repairItemSelectionIndicatorView.hidden = self.isSpecServiceShop;
    if (self.isSpecServiceShop) {
        [self.selectItemList removeAllObjects];
        [self.selectItemList addObject:self.shopDetail[@"major_item"]];
        self.repairItemsLabel.text = self.shopDetail[@"major_item"];
    }else {
        [self.selectItemList removeAllObjects];
        @weakify(self);
        if (self.repairSelectedIndexPath.count>0&&self.repairItem.count>0) {
            [self.repairSelectedIndexPath enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull indexPath, BOOL * _Nonnull stop) {
                @strongify(self);
                NSString *itemName = self.repairItem[indexPath.row];
                [self.selectItemList addObject:itemName];
            }];
        }
        if (self.maintainSelectedIndexPath.count>0&&self.maintainItem.count>0) {
            [self.maintainSelectedIndexPath enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull indexPath, BOOL * _Nonnull stop) {
                @strongify(self);
                NSString *itemName = self.maintainItem[indexPath.row];
                [self.selectItemList addObject:itemName];
            }];
        }
        self.repairItemsLabel.text = [self.selectItemList componentsJoinedByString:@" "];
    }
}

- (IBAction)dailupTheTel {
    NSString *shopTelNumber = self.shopDetail[@"wxs_tel"];
    if (shopTelNumber&&![shopTelNumber isEqualToString:@""]) {
        [SupportingClass makeACall:shopTelNumber andContents:[@"系统将会拨打以下号码：\n" stringByAppendingString:shopTelNumber] withTitle:@"温馨提示"];
    }else {
        [SupportingClass showAlertViewWithTitle:nil message:@"暂无维修商号码提供！" isShowImmediate:YES cancelButtonTitle:nil otherButtonTitles:nil clickedButtonAtIndexWithBlock:nil];
    }
}

- (IBAction)pushToSelectTechnician {
    if (self.isLockMechanicSelection) return;
    
    @autoreleasepool {
        ShopMechanicSearchListVC *vc = [ShopMechanicSearchListVC new];
        vc.fromStr=@"立即预约";
        vc.repairShopID = self.shopID;
        vc.onlyForSelection = YES;
        vc.selectedMechanicDetail = self.selectedMechanicDetail;
        @weakify(self);
        vc.resultBlock = ^(SMSLResultDTO* selectedMechanicDetail) {
            @strongify(self);
            self.selectedMechanicDetail = selectedMechanicDetail;
            self.technicianNameLabel.text = self.selectedMechanicDetail.mechanicName;
        };
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)hiddenKeyboard {
    self.appointmentTimeString = self.appointmentTimeTF.text;
    [self.userNameTF resignFirstResponder];
    [self.userPhoneNumTF resignFirstResponder];
    [self.appointmentTimeTF resignFirstResponder];
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

- (void)keyboardWillAppear:(NSNotification *)notiObj {
    self.keyboardRect = [notiObj.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    UITextField *textField = nil;
    if (self.userNameTF.isFirstResponder) {
        textField = self.userNameTF;
    }
    if (self.userPhoneNumTF.isFirstResponder) {
        textField = self.userPhoneNumTF;
    }
    if (self.appointmentTimeTF.isFirstResponder) {
        textField = self.appointmentTimeTF;
    }
    if (textField) {
        [self shiftScrollViewWithAnimation:textField];
    }
}

- (void)keyboardWillDisappear:(NSNotification *)notiObj {
    [self.scrollView setContentOffset:CGPointZero animated:NO];
}

- (void)shiftScrollViewWithAnimation:(UITextField *)textField {
    UIView *theView = self.scrollView;
    CGPoint point = CGPointZero;
    CGFloat contanierViewMaxY = CGRectGetMidY([textField.superview convertRect:textField.frame toView:theView]);
    CGFloat visibleContentsHeight = (CGRectGetHeight(theView.frame)-CGRectGetHeight(_keyboardRect))/2.0f;
    if (contanierViewMaxY > visibleContentsHeight) {
        CGFloat offsetY = contanierViewMaxY-visibleContentsHeight;
        point.y = offsetY;
    }
    [self.scrollView setContentOffset:point animated:NO];
}

- (void)dateChangeFromDatePicker:(UIDatePicker *)datePicker {
    self.appointmentTimeTF.text = [self.dateFormatter stringFromDate:datePicker.date];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (self.appointmentTimeTF==textField){
        NSDate *date = NSDate.date;//[NSDate dateWithTimeInterval:(2*60*60) sinceDate:NSDate.date];
        if (!self.appointmentTimeTF.text||[self.appointmentTimeTF.text isEqualToString:@""]) {
            self.appointmentTimeString = [self.dateFormatter stringFromDate:date];
            self.appointmentTimeTF.text = self.appointmentTimeString;
        }
        self.datePicker.minimumDate = date;
        self.datePicker.date = [self.dateFormatter dateFromString:self.appointmentTimeString];
        
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([textField isFirstResponder]) {
        if ([[[textField textInputMode] primaryLanguage] isEqualToString:@"emoji"] || ![[textField textInputMode] primaryLanguage]) {
            return NO;
        }
    }
    if (textField==self.userPhoneNumTF) {
        if (textField.text.length==0&&![string isEqualToString:@"1"]) {
            return NO;
        }
        
        NSUInteger length = textField.text.length;
        if (length==11&&![string isEqualToString:@""]) {
            return NO;
        }
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (self.appointmentTimeTF==textField) {
        self.appointmentTimeTF.text = self.appointmentTimeString;
    }
}

- (IBAction)submitAppointment {
    
    if (!self.selectedAutosDto.brandID||[self.selectedAutosDto.brandID isEqualToString:@""]||
        !self.selectedAutosDto.dealershipID||[self.selectedAutosDto.dealershipID isEqualToString:@""]||
        !self.selectedAutosDto.seriesID||[self.selectedAutosDto.seriesID isEqualToString:@""]||
        !self.selectedAutosDto.modelID||[self.selectedAutosDto.modelID isEqualToString:@""]) {
        [SupportingClass showAlertViewWithTitle:nil message:@"请选择预约车辆型号！" isShowImmediate:YES cancelButtonTitle:nil otherButtonTitles:nil clickedButtonAtIndexWithBlock:nil];
        return;
    }
    
    if (!self.userNameTF.text||[self.userNameTF.text isEqualToString:@""]) {
        [SupportingClass showAlertViewWithTitle:nil message:@"请输入预约人姓名" isShowImmediate:YES cancelButtonTitle:nil otherButtonTitles:nil clickedButtonAtIndexWithBlock:nil];;
        return;
    }
    
    if (!self.userPhoneNumTF.text||[self.userPhoneNumTF.text isEqualToString:@""]) {
        [SupportingClass showAlertViewWithTitle:nil message:@"请输入预约人电话" isShowImmediate:YES cancelButtonTitle:nil otherButtonTitles:nil clickedButtonAtIndexWithBlock:nil];
        return;
    }else if (self.userPhoneNumTF.text.length!=11) {
        [SupportingClass showAlertViewWithTitle:nil message:@"请输入正确的电话号码" isShowImmediate:YES cancelButtonTitle:nil otherButtonTitles:nil clickedButtonAtIndexWithBlock:nil];
        return;
    }
    
    
    if (!self.appointmentTimeTF.text||[self.appointmentTimeTF.text isEqualToString:@""]) {
        [SupportingClass showAlertViewWithTitle:nil message:@"选择预约时间" isShowImmediate:YES cancelButtonTitle:nil otherButtonTitles:nil clickedButtonAtIndexWithBlock:nil];
        return;
    }
    
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    
    @autoreleasepool {
        NSString *serviceItem = [self.selectItemList componentsJoinedByString:@"-"];
        NSString *contactName = self.userNameTF.text;
        NSString *contactNumber = self.userPhoneNumTF.text;
        NSString *dateTime = self.appointmentTimeTF.text;
        NSString *technicianID = self.selectedMechanicDetail.mechanicID;
        if(!technicianID) technicianID = @"";
        NSString *brandID = self.selectedAutosDto.brandID;
        NSString *brandDealershipID = self.selectedAutosDto.dealershipID;
        NSString *seriesID = self.selectedAutosDto.seriesID;
        NSString *modelID = self.selectedAutosDto.modelID;
        
        [ProgressHUDHandler showHUDWithTitle:getLocalizationString(@"send_appointment") onView:nil];
        @weakify(self);
        
        [[APIsConnection shareConnection] maintenanceShopsAPIsPostConfirmAppointmentMaintenanceServieWithAccessToken:self.accessToken shopID:self.shopID serviceItem:serviceItem contactName:contactName contactNumber:contactNumber approveToChange:self.technicianChangeAgreementSwitch.on dateTime:dateTime technicianID:technicianID brandID:brandID brandDealershipID:brandDealershipID seriesID:seriesID modelID:modelID success:^(NSURLSessionDataTask *operation, id responseObject) {
            NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
            NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
            NSLog(@"%@",message);
            if (errorCode!=0) {
                if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {return;};
                [ProgressHUDHandler dismissHUD];
                [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
                return;
            }
            [ProgressHUDHandler dismissHUDWithCompletion:^{
                [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                    @strongify(self);
                    NSString *signString = responseObject[@"sign"];
                    [self getMaintenanceDetail:signString];
                }];
                
            }];
            
        } failure:^(NSURLSessionDataTask *operation, NSError *error) {
            NSLog(@"%@",error);
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
}

/* 查询维修详情由维修类型 */
NSUInteger theCount = 0;
- (void)getMaintenanceDetail:(NSString *)repairID {
    
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    
    [ProgressHUDHandler showHUD];
    NSString *processID = @"0";
    @weakify(self);
    [[APIsConnection shareConnection] personalCenterAPIsGetrepairOrderDetailByStatusType:CDZMaintenanceStatusTypeOfAppointment accessToken:self.accessToken keyID:repairID success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"详情%@-----%@",message,operation.currentRequest.URL.absoluteString);
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        [ProgressHUDHandler dismissHUD];
        
        if (errorCode!=0) {
            [SupportingClass showAlertViewWithTitle:@"error" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                
            }];
            return;
        }
        
        MaintenanceDetailsVC *vc = [MaintenanceDetailsVC new];
        vc.repairID = repairID;
        vc.currentStatusType = CDZMaintenanceStatusTypeOfAppointment;
        vc.processID = processID;
        vc.contentDetail = responseObject[CDZKeyOfResultKey];
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        @strongify(self);
        [ProgressHUDHandler dismissHUD];
        if (theCount<=10) {
            theCount++;
            [self getMaintenanceDetail:repairID];
        }else {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
        return;
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

@end
