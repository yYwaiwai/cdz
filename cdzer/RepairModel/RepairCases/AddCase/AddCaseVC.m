//
//  AddCaseVC.m
//  cdzer
//
//  Created by 车队长 on 16/11/18.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "AddCaseVC.h"
#import "MaterialScienceCell.h"
#import "UserAutosSelectonVC.h"
#import "MyCaseVC.h"
#import "MyCaseResultDTO.h"
#import "LicensePlateSelectionView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <RegexKitLite/RegexKitLite.h>

@interface AddCaseVC ()<UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIControl *headViewControl;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;//添加车辆label

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;//车型图片

@property (weak, nonatomic) IBOutlet UILabel *headCarLabel;//车型车系

@property (weak, nonatomic) IBOutlet UIImageView *arrowImageView;//

@property (weak, nonatomic) IBOutlet LicensePlateSelectionView *lpSelectionView;

@property (weak, nonatomic) IBOutlet UIView *carNumberView;//车牌号码

@property (weak, nonatomic) IBOutlet UITextField *carNumberTF;

@property (weak, nonatomic) IBOutlet UIView *shopView;//维修店铺

@property (weak, nonatomic) IBOutlet UITextField *shopTF;

@property (weak, nonatomic) IBOutlet UIView *addressView;//维修地址

@property (weak, nonatomic) IBOutlet UITextField *addressTF;

@property (weak, nonatomic) IBOutlet UIView *phoneView;//维修电话

@property (weak, nonatomic) IBOutlet UITextField *phoneTF;

@property (weak, nonatomic) IBOutlet UIControl *timeView;//维修时间

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UITextField *timeTF;

@property (weak, nonatomic) IBOutlet UIControl *projectView;//维修项目

@property (weak, nonatomic) IBOutlet UITextField *projectTF;

@property (weak, nonatomic) IBOutlet UIView *workingHoursView;//维修工时

@property (weak, nonatomic) IBOutlet UITextField *workingHoursTF;

@property (weak, nonatomic) IBOutlet UIView *workingHoursFeeView;//工时费

@property (weak, nonatomic) IBOutlet UITextField *workingHoursFeeTF;

@property (weak, nonatomic) IBOutlet UIView *materialScienceView;//维修材料

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeightConstraint;

@property (weak, nonatomic) IBOutlet UIControl *addAccessoriesView;//添加配件View

@property (weak, nonatomic) IBOutlet UIButton *addAccessoriesButton;//添加配件按钮

@property (weak, nonatomic) IBOutlet UIControl *uploadPhotosControl;//上传结算单control

@property (weak, nonatomic) IBOutlet UIImageView *uploadPhotosImageView;


@property (weak, nonatomic) IBOutlet UIView *uploadPhotosView;

@property (weak, nonatomic) IBOutlet UIButton *submitCase;//提交案例

@property (nonatomic, strong) NSMutableArray <MyCasePartDetailDTO *> *partList;


@property (nonatomic, strong) NSString *url;

@property (nonatomic, strong) UIImage *needUploadImg;

@property (nonatomic, assign) BOOL needReuploadImg;

@property (nonatomic, strong) UIDatePicker *datePicker;

@property (nonatomic, strong) UIToolbar *toolbar;

@property (nonatomic, strong) NSString *start2DriveDateTime;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic, strong) MyCaseAutosInfoDTO *caseAutosInfoDTO;

//案例编辑
@property (nonatomic, assign) BOOL wasCaseEditing;

@property (nonatomic, assign) BOOL wasUserAutosExist;

@property (nonatomic) CGRect keyboardRect;

@end

@implementation AddCaseVC

- (void)setResultData:(MyCaseResultDTO *)resultData {
    _wasCaseEditing = NO;
    if (resultData) _wasCaseEditing = YES;
    _resultData = resultData;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self componentSetting];
    [self initializationUI];
    [self setReactiveRules];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateAutosDisplayDetail];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillAppear:) name:UIKeyboardWillShowNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillDisappear:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [NSNotificationCenter.defaultCenter removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [NSNotificationCenter.defaultCenter removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

-(void)dealloc
{
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    [self.headImageView setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:self.headImageView.frame.size.width/2];
    [self.headImageView setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:3.0f withColor:[UIColor colorWithHexString:@"82d5f7"] withBroderOffset:nil];
    
    BorderOffsetObject *offset = [BorderOffsetObject new];
    offset.leftUpperOffset = 20;
    offset.leftBottomOffset = offset.leftUpperOffset;
    [self.carNumberView setViewBorderWithRectBorder:UIRectBorderTop|UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:offset];
    [self.shopView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:offset];
    [self.addressView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:offset];
    [self.phoneView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:offset];
    [self.timeView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:offset];
    [self.projectView setViewBorderWithRectBorder:UIRectBorderTop|UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:offset];
    [self.workingHoursView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:offset];
    [self.workingHoursFeeView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self.materialScienceView setViewBorderWithRectBorder:UIRectBorderTop|UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self.tableView setViewBorderWithRectBorder:UIRectBorderTop borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self.addAccessoriesButton setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:0.5 withColor:[UIColor colorWithHexString:@"49c7f5"] withBroderOffset:nil];
    [self.addAccessoriesButton setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:5.0f];
    [self.submitCase setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:3.0f];
    [self.addAccessoriesView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self.uploadPhotosView setViewBorderWithRectBorder:UIRectBorderTop|UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    
}

- (void)componentSetting {
    @autoreleasepool {
        
        self.partList = [@[] mutableCopy];
        if (self.wasCaseEditing&&self.resultData&&
            self.resultData.repairPartsList.count>0) {
            [self.partList addObjectsFromArray:self.resultData.repairPartsList];
        }else {
            [self.partList addObject:[MyCasePartDetailDTO new]];
        }
        
        self.dateFormatter = [NSDateFormatter new];
        [self.dateFormatter setDateFormat:@"yyyy-MM-dd"];
        
        self.datePicker = [UIDatePicker new];
        self.datePicker.backgroundColor = CDZColorOfWhite;
        [self.datePicker addTarget:self action:@selector(dateChangeFromDatePicker:) forControlEvents:UIControlEventValueChanged];
        self.datePicker.datePickerMode = UIDatePickerModeDate;
        
        
        
        UIImage *image = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"shangchuanjiesuandanzp@3x" ofType:@"png"]];
        self.uploadPhotosImageView.image = image;
        self.uploadPhotosImageView.contentMode = UIViewContentModeCenter;
        if (self.wasCaseEditing) {
            self.title = @"编辑案例";
            [self updateMyCaseDetil];
        }else {
            self.title = @"添加案例";
        }
        
        
        self.wasUserAutosExist = NO;
        UserSelectedAutosInfoDTO *selectedAutosData = [DBHandler.shareInstance getSelectedAutoData];
        if (selectedAutosData&&![selectedAutosData.brandID isEqualToString:@""]&&selectedAutosData.brandID&&
            ![selectedAutosData.dealershipID isEqualToString:@""]&&selectedAutosData.dealershipID&&
            ![selectedAutosData.seriesID isEqualToString:@""]&&selectedAutosData.seriesID&&
            ![selectedAutosData.modelID isEqualToString:@""]&&selectedAutosData.modelID) {
            self.wasUserAutosExist = YES;
        }
        if (self.wasCaseEditing) {
            self.caseAutosInfoDTO = self.resultData.autosInfo;
        }else {
            if (self.wasUserAutosExist) {
                self.caseAutosInfoDTO = [MyCaseAutosInfoDTO createAutoDataObjectFromUserSelectedAutosInfoDTO:selectedAutosData];
            }else {
                self.caseAutosInfoDTO = nil;
            }
        }
        
        [self updateAutosDisplayDetail];
    }
}

- (void)initializationUI {
    
    
    self.scrollView.bounces = NO;
    self.tableView.bounces = NO;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 33.0f;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = self.view.backgroundColor;
    UINib * nib = [UINib nibWithNibName:@"MaterialScienceCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:CDZKeyOfCellIdentKey];
    
    self.toolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth([UIScreen mainScreen].bounds), 40.0f)];
    [self.toolbar setBarStyle:UIBarStyleDefault];
    UIBarButtonItem *spaceButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                target:self
                                                                                action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]initWithTitle:getLocalizationString(@"finish")
                                                                  style:UIBarButtonItemStyleDone
                                                                 target:self
                                                                 action:@selector(hiddenKeyboard)];
    doneButton.tintColor = [UIColor colorWithHexString:@"6DD2F7"];
    NSArray * buttonsArray = [NSArray arrayWithObjects:spaceButton,doneButton,nil];
    [self.toolbar setItems:buttonsArray];
    self.timeTF.inputView = self.datePicker;
    self.timeTF.inputAccessoryView = self.toolbar;
    
    [self.lpSelectionView setTitleColor:[UIColor colorWithHexString:@"49c7f5"]];
}

- (void)setReactiveRules {
    @autoreleasepool {
        @weakify(self);
        [RACObserve(self, tableView.contentSize) subscribeNext:^(id size) {
            @strongify(self);
            CGSize contentSize = [size CGSizeValue];
            self.tableViewHeightConstraint.constant = contentSize.height;
        }];
    }
    
}

- (IBAction)pushToAutosSelection {
    @weakify(self);
    [self pushToAutosSelectionViewWithBackTitle:nil animated:YES onlyForSelection:(self.wasUserAutosExist&&!self.wasCaseEditing) andSelectionResultBlock:^(UserSelectedAutosInfoDTO *selectedAutosDto) {
        @strongify(self);
        self.caseAutosInfoDTO = [MyCaseAutosInfoDTO createAutoDataObjectFromUserSelectedAutosInfoDTO:selectedAutosDto];
    }];
}

- (void)updateMyCaseDetil{
    if (!self.wasCaseEditing) return;
    
    self.carNumberTF.text = self.resultData.licensePlate;
    if (self.resultData.licensePlate.length>3) {
        self.carNumberTF.text = [self.resultData.licensePlate substringFromIndex:2];
        [self.lpSelectionView initializeSettingFromLicensePlate:self.resultData.licensePlate];
    }
    self.shopTF.text = self.resultData.repairShopName;
    self.addressTF.text = self.resultData.repairShopAddress;
    self.phoneTF.text = self.resultData.repairShopPhone;
    self.timeTF.text = self.resultData.repairDateTime;
    self.projectTF.text = self.resultData.theCaseReason;
    self.workingHoursTF.text = self.resultData.workingHrs;
    self.workingHoursFeeTF.text = self.resultData.workingPrice;

    
    UIImage *image = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"shangchuanjiesuandanzp@3x" ofType:@"png"]];
    self.uploadPhotosImageView.image = image;
    self.uploadPhotosImageView.contentMode = UIViewContentModeCenter;
    self.url = self.resultData.caseRepairReceiptsImg;
    if (self.url&&[self.url isContainsString:@"http"]) {
        self.uploadPhotosImageView.contentMode = UIViewContentModeScaleAspectFit;
        @weakify(self);
        [self.uploadPhotosImageView sd_setImageWithURL:[NSURL URLWithString:self.url] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            @strongify(self)
            self.needUploadImg = image;
        }];
    }
}

- (void)updateAutosDisplayDetail {
    if (self.caseAutosInfoDTO) {
        [self.headImageView sd_setImageWithURL:[NSURL URLWithString:self.caseAutosInfoDTO.brandImgURL] placeholderImage:[ImageHandler getDefaultWhiteLogo]];
        self.headCarLabel.text = [NSString stringWithFormat:@"%@ %@",self.caseAutosInfoDTO.seriesName, self.caseAutosInfoDTO.modelName];
        self.headImageView.hidden = NO;
        self.headCarLabel.hidden = NO;
        self.titleLabel.hidden = YES;
    }else {
        self.headImageView.hidden = YES;
        self.headCarLabel.hidden = YES;
        self.titleLabel.hidden = NO;
    }
}

//上传结算单按钮提示
- (IBAction)uploadSettlementSheetClick:(id)sender {
    [SupportingClass showAlertViewWithTitle:@"照片要求" message:@"请上传有效的结算单照片，非维修结算单图片不予受理。照片必须是彩色原件电子版，可以是扫描件后者数码拍摄照片。仅支持jpg、bmp、png、gif的图片格式。图片大小不超过2M。" isShowImmediate:YES cancelButtonTitle:@"我知道了" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MaterialScienceCell *cell = [tableView dequeueReusableCellWithIdentifier:CDZKeyOfCellIdentKey forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.indexPath = indexPath;
    if (!cell.actionBlock) {
        @weakify(self);
        cell.actionBlock = ^(MSCellAction action, NSString *value, NSIndexPath *indexPath) {
            @strongify(self);
            if (action==MSCellActionOfDeleteRow) {
                [self deletePartRecord:indexPath];
            }else {
                MyCasePartDetailDTO *dto = self.partList[indexPath.row];
                switch (action) {
                    case MSCellActionOfUpdatePartName:
                        dto.partName = value;
                        break;
                    case MSCellActionOfUpdateCounting:
                        dto.counting = value;
                        break;
                    case MSCellActionOfUpdatePartPrice:
                        dto.partPrice = value;
                        break;
                    default:
                        break;
                }
                [self.tableView reloadData];
            }
            
        };
    }
    MyCasePartDetailDTO *dto = self.partList[indexPath.row];
    cell.partsTF.text = dto.partName;
    cell.numberTF.text = dto.counting;
    cell.unitPriceTF.text = dto.partPrice;
    
    return cell;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.partList.count;
}

//添加配件 行
- (IBAction)addAccessoriesClick:(id)sender  event:(id)event {
    [self.view endEditing:YES];
    MyCasePartDetailDTO *dto = self.partList.lastObject;
    if ([dto.partName isEqualToString:@""]||dto.counting==0||
        [dto.partPrice isEqualToString:@""]) {
        return;
    }
    [self.partList addObject:[MyCasePartDetailDTO new]];
    [_tableView reloadData];
}
// 删除一组控件
- (void)deletePartRecord:(NSIndexPath *)indexPath {
    // 多于1条记录才可以有删除操作
    if (self.partList.count > 1&&indexPath) {
        [self.partList removeObjectAtIndex:indexPath.row];
        [self.tableView reloadData];
    }
}


//维修时间
- (void)hiddenKeyboard {
    self.start2DriveDateTime = self.timeTF.text;
    [self.timeTF resignFirstResponder];
}

- (void)keyboardWillAppear:(NSNotification *)notiObj {
    self.keyboardRect = [notiObj.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    UITextField *textField = nil;
    if (self.shopTF.isFirstResponder) {
        textField = self.shopTF;
    }
    if (self.carNumberTF.isFirstResponder) {
        textField = self.carNumberTF;
    }
    if (self.phoneTF.isFirstResponder) {
        textField = self.phoneTF;
    }
    if (self.addressTF.isFirstResponder) {
        textField = self.addressTF;
    }
    if (self.projectTF.isFirstResponder) {
        textField = self.projectTF;
    }
    if (self.timeTF.isFirstResponder) {
        textField = self.timeTF;
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
    self.timeTF.text = [self.dateFormatter stringFromDate:datePicker.date];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (self.timeTF==textField){
        NSDate *date = NSDate.date;
        if (!self.timeTF.text||[self.timeTF.text isEqualToString:@""]) {
            self.start2DriveDateTime = [self.dateFormatter stringFromDate:date];
            self.timeTF.text = self.start2DriveDateTime;
        }
        if (self.wasCaseEditing) {
            textField.text = self.resultData.repairDateTime;
            if (![self.resultData.repairDateTime isEqualToString:self.timeTF.text]) {
                textField.text =self.timeTF.text;
            }
            self.datePicker.date = [self.dateFormatter dateFromString:textField.text];
        }else{
            textField.text = [self.dateFormatter stringFromDate:self.datePicker.date];
            self.datePicker.date = [self.dateFormatter dateFromString:self.start2DriveDateTime];
        }
        self.datePicker.maximumDate = date;
        
        
    }
}


#pragma mark -- UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (textField==self.phoneTF) {
        if (textField.text.length==0&&![string isEqualToString:@"1"]) {
            return NO;
        }
        
        NSUInteger length = textField.text.length;
        if (length==11&&![string isEqualToString:@""]) {
            return NO;
        }
    }
    if (textField==self.carNumberTF) {
        NSUInteger length = textField.text.length;
        if (length==5&&![string isEqualToString:@""]) {
            return NO;
        }
    }
    if (textField==self.shopTF) {
        NSUInteger length = textField.text.length;
        if (length==30&&![string isEqualToString:@""]) {
            return NO;
        }
    }
    if (textField==self.addressTF) {
        NSUInteger length = textField.text.length;
        if (length==30&&![string isEqualToString:@""]) {
            return NO;
        }
    }
    if (textField==self.phoneTF) {
        NSUInteger length = textField.text.length;
        if (length==11&&![string isEqualToString:@""]) {
            return NO;
        }
    }
    if (textField==self.projectTF) {
        NSUInteger length = textField.text.length;
        if (length==20&&![string isEqualToString:@""]) {
            return NO;
        }
    }
    if (textField==self.workingHoursTF) {
        NSUInteger length = textField.text.length;
        if (length==4&&![string isEqualToString:@""]) {
            return NO;
        }
    }
    if (textField==self.workingHoursFeeTF) {
        NSUInteger length = textField.text.length;
        if (length==7&&![string isEqualToString:@""]) {
            return NO;
        }
    }
    if (![string isEqualToString:@""]) {
        if ([self stringContainsEmoji:string]) {
            return NO;
        }
            }
    return YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (self.carNumberTF.text.length>5) {
        [ProgressHUDHandler showErrorWithStatus:[NSString stringWithFormat:@"车牌号不可超过5位"] onView:self.view completion:nil];
        self.carNumberTF.text=textField.text;
        return NO;
    }
    if (self.shopTF.text.length>30) {
        [ProgressHUDHandler showErrorWithStatus:[NSString stringWithFormat:@"店铺名称不可超过30位"] onView:self.view completion:nil];
        return NO;
    }
    if (self.addressTF.text.length>30) {
        [ProgressHUDHandler showErrorWithStatus:[NSString stringWithFormat:@"维修地址不可超过30位"] onView:self.view completion:nil];
        return NO;
    }
    if (self.phoneTF.text.length>11) {
        [ProgressHUDHandler showErrorWithStatus:[NSString stringWithFormat:@"维修电话不可超过11位"] onView:self.view completion:nil];
        return NO;
    }
    if (self.projectTF.text.length>20) {
        [ProgressHUDHandler showErrorWithStatus:[NSString stringWithFormat:@"维修项目不可超过20位"] onView:self.view completion:nil];
        return NO;
    }
    if (self.workingHoursTF.text.length>4) {
        [ProgressHUDHandler showErrorWithStatus:[NSString stringWithFormat:@"维修工时不可超过4位"] onView:self.view completion:nil];
        return NO;
    }
    if (self.workingHoursFeeTF.text.length>7) {
        [ProgressHUDHandler showErrorWithStatus:[NSString stringWithFormat:@"工时费不可超过7位"] onView:self.view completion:nil];
        return NO;
    }
    return YES;
}

- (void)textFieldTextDidChange:(NSNotification *)notiObj {
    UITextField *textField = (UITextField *)notiObj.object;
    NSUInteger maxLenght = 17;
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
    if ([textField.text isContainsString:@" "]){
        textField.text = [textField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
//    NSUInteger maxLenght = 5;
//    if (textField==self.carNumberTF&&textField.isFirstResponder) {
//        maxLenght = 5;
//    }
//    if (textField==self.shopTF&&textField.isFirstResponder) {
//        maxLenght = 20;
//    }
//    if (textField==self.addressTF&&textField.isFirstResponder) {
//        maxLenght = 25;
//    }
//    if (textField==self.phoneTF&&textField.isFirstResponder) {
//        maxLenght = 12;
//    }
//    if (textField==self.projectTF&&textField.isFirstResponder) {
//        maxLenght = 20;
//    }
//    if (textField==self.workingHoursTF&&textField.isFirstResponder) {
//        maxLenght = 4;
//    }
//    if (textField==self.workingHoursFeeTF&&textField.isFirstResponder) {
//        maxLenght = 7;
//    }
//    if (self.timeTF==textField) {
//        self.timeTF.text = self.start2DriveDateTime;
//    }

//    if (textField.isFirstResponder) {
//        NSString *toBeString = textField.text;
//        NSString *lang = [[textField textInputMode] primaryLanguage];
//        if ([lang isContainsString:@"zh-Hans"]) {
//            UITextRange *selectedRange = [textField markedTextRange];
//            UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
//            if (!position) {
//                if (toBeString.length>maxLenght) {
//                    textField.text = [toBeString substringToIndex:maxLenght];
//                }
//            }else {
//                
//            }
//        }else {
//            if (toBeString.length>maxLenght) {
//                textField.text = [toBeString substringToIndex:maxLenght];
//            }
//        }
    
//    }
}

//点击上传照片
- (IBAction)uploadPhotosClick:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"请选择图片来源"
                                  delegate:nil
                                  cancelButtonTitle:getLocalizationString(@"cancel")
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"拍照", @"相册",nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [actionSheet showInView:self.view];
    [actionSheet.rac_buttonClickedSignal subscribeNext:^(NSNumber *buttonIndex) {
        if (buttonIndex.integerValue==1) {
            [self photoLibraryButtonCicked];
        }if (buttonIndex.integerValue==0){
            [self cameraButtonCicked];
        }
    }];

}

- (void)photoLibraryButtonCicked {
    
    UIImagePickerController *imagePickVC = [[UIImagePickerController alloc] init];
    imagePickVC.delegate = self;
    imagePickVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickVC.mediaTypes = @[@"public.image"];
    [self presentViewController:imagePickVC animated:YES completion:nil];
}

- (void)cameraButtonCicked {
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *imagePickVC = [[UIImagePickerController alloc] init];
        imagePickVC.delegate = self;
        imagePickVC.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePickVC.mediaTypes = @[@"public.image"];
        [self presentViewController:imagePickVC animated:YES completion:nil];
    } else {
        
        [SupportingClass showAlertViewWithTitle:@"alert_remind" message:@"照相机不可用!" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];

    }
    
   }

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:^() {
        UIImage *portraitImg = [info objectForKey:UIImagePickerControllerEditedImage];
        if (portraitImg == nil) portraitImg = [info objectForKey:UIImagePickerControllerOriginalImage];
        portraitImg = [UIImage imageWithCGImage:portraitImg.CGImage
                                          scale:UIScreen.mainScreen.scale
                                    orientation:UIImageOrientationUp];
        self.needUploadImg = portraitImg;
        self.uploadPhotosImageView.image = portraitImg;
        self.uploadPhotosImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.needReuploadImg = YES;
    }];
}

- (void)uploadImage {
    @weakify(self);
    [ProgressHUDHandler showHUD];
    [[APIsConnection shareConnection] casesHistoryAPIsGetStatementPicWithImage:self.uploadPhotosImageView.image imageName:@"use" imageType:ConnectionImageTypeOfJPEG success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        if (errorCode!=0||!responseObject) {
            [ProgressHUDHandler dismissHUD];
            [SupportingClass showAlertViewWithTitle:@"" message:@"上传失败，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                
            }];
            return;
        }
        self.url = responseObject[@"url"];
        NSLog(@"--------%@",self.url);
        self.needReuploadImg = NO;
        [self getAddCase];
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
        
        [SupportingClass showAlertViewWithTitle:@"error" message:@"上传失败，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            
        }];
    }];
    
}

//提交案例
- (IBAction)submitCaseClick:(id)sender {
    [self.tableView reloadData];
    [self getAddCase];
}

- (BOOL)partsListDataWasNotSatisfied {
    NSString *partsNameStr=[[self.partList valueForKeyPath:@"partName"] componentsJoinedByString:@"-"];
    NSString *partsNumStr=[[self.partList valueForKeyPath:@"counting"] componentsJoinedByString:@"-"];
    NSString *partsPriceStr=[[self.partList valueForKeyPath:@"partPrice"] componentsJoinedByString:@"-"];


    BOOL wasNotSatisfied = ([partsNameStr isMatchedByRegex:@"^-|—-|-$"]||
                            [partsNumStr isMatchedByRegex:@"^-|—-|-$"]||
                            [partsPriceStr isMatchedByRegex:@"^-|—-|-$"]);
    return wasNotSatisfied;
}

- (BOOL)stringContainsEmoji:(NSString *)string {
    __block BOOL returnValue = NO;
    
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length])
                               options:NSStringEnumerationByComposedCharacterSequences
                            usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                const unichar hs = [substring characterAtIndex:0];
                                if (0xd800 <= hs && hs <= 0xdbff) {
                                    if (substring.length > 1) {
                                        const unichar ls = [substring characterAtIndex:1];
                                        const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                                        if (0x1d000 <= uc && uc <= 0x1f77f) {
                                            returnValue = YES;
                                        }
                                    }
                                } else if (substring.length > 1) {
                                    const unichar ls = [substring characterAtIndex:1];
                                    if (ls == 0x20e3) {
                                        returnValue = YES;
                                    }
                                } else {
                                    if (0x2100 <= hs && hs <= 0x27ff) {
                                        returnValue = YES;
                                    } else if (0x2B05 <= hs && hs <= 0x2b07) {
                                        returnValue = YES;
                                    } else if (0x2934 <= hs && hs <= 0x2935) {
                                        returnValue = YES;
                                    } else if (0x3297 <= hs && hs <= 0x3299) {
                                        returnValue = YES;
                                    } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                                        returnValue = YES;
                                    }
                                }
                            }];
    
    return returnValue;
}

/*手机号和固网电话验证*/
- (BOOL)isValidateMobile:(NSString *)mobile {
    NSString *phoneNFixLineRegex = @"^(((0\\d{2,3}|\\d{2,3})(-\\d{7,8}|\\d{7,8}))|(1[34578]\\d{9}))$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneNFixLineRegex];
    return [phoneTest evaluateWithObject:mobile];
}

/*车牌号验证*/
- (BOOL)validateCarNo:(NSString*)carNo {
    NSString *carRegex=@"^[京津沪渝冀豫云辽黑湘皖鲁新苏浙赣鄂桂甘晋蒙陕吉闽贵粤青藏川宁琼使领A-Z]{1}[A-Z]{1}[A-Z0-9]{4}[A-Z0-9挂学警港澳]{1}$";
    NSPredicate *carTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",carRegex];
    return [carTest evaluateWithObject:carNo];
}

- (void)getAddCase {
    if (!self.caseAutosInfoDTO) {
        [SupportingClass showAlertViewWithTitle:@"alert_remind" message:@"请先选择车辆信息" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
        }];
        return;
    }
    [ProgressHUDHandler showHUD];
    if (self.carNumberTF.text.length==0||self.shopTF.text.length==0||self.addressTF.text.length==0||self.phoneTF.text.length==0||self.timeTF.text.length==0||self.projectTF.text.length==0||self.workingHoursTF.text.length==0||self.workingHoursFeeTF.text.length==0) {
        NSString*mess;
        if (self.carNumberTF.text.length==0) {
            mess=@"车牌号码";
            [ProgressHUDHandler showErrorWithStatus:[NSString stringWithFormat:@"请输入%@",mess] onView:self.view completion:nil];
            return;
        }
        if (self.shopTF.text.length==0) {
            mess=@"维修商店";
            [ProgressHUDHandler showErrorWithStatus:[NSString stringWithFormat:@"请输入%@",mess] onView:self.view completion:nil];
            return;
        }
        if (self.addressTF.text.length==0) {
            mess=@"维修地址";
            [ProgressHUDHandler showErrorWithStatus:[NSString stringWithFormat:@"请输入%@",mess] onView:self.view completion:nil];
            return;
        }
        if (self.phoneTF.text.length==0) {
            mess=@"维修电话";
            [ProgressHUDHandler showErrorWithStatus:[NSString stringWithFormat:@"请输入%@",mess] onView:self.view completion:nil];
            return;
        }if (self.timeTF.text.length==0) {
            mess=@"维修时间";
            [ProgressHUDHandler showErrorWithStatus:[NSString stringWithFormat:@"请输入%@",mess] onView:self.view completion:nil];
            return;
        }if (self.projectTF.text.length==0) {
            mess=@"维修项目";
            [ProgressHUDHandler showErrorWithStatus:[NSString stringWithFormat:@"请输入%@",mess] onView:self.view completion:nil];
            return;
        }if (self.workingHoursTF.text.length==0) {
            mess=@"维修工时";
            [ProgressHUDHandler showErrorWithStatus:[NSString stringWithFormat:@"请输入%@",mess] onView:self.view completion:nil];
            return;
        }
        if (self.workingHoursFeeTF.text.length==0) {
            mess=@"工时费";
            [ProgressHUDHandler showErrorWithStatus:[NSString stringWithFormat:@"请输入%@",mess] onView:self.view completion:nil];
            return;
        }
        
        
        if ([self partsListDataWasNotSatisfied]) {
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:@"请将维修材料信息添加完整" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            }];
            return;
        }
        
        
    }
    NSString *licensePlate = [self.lpSelectionView.combineString stringByAppendingString:self.carNumberTF.text];
    if (![self validateCarNo:licensePlate]) {
        [ProgressHUDHandler showErrorWithStatus:[NSString stringWithFormat:@"请输入正确的车牌号码"] onView:self.view completion:nil];
        return;
    }
    if (![self isValidateMobile:self.phoneTF.text]) {
        [ProgressHUDHandler showErrorWithStatus:[NSString stringWithFormat:@"请输入正确的电话号码"] onView:self.view completion:nil];
        return;
    }
    if ([self stringContainsEmoji:self.shopTF.text]||
        [self stringContainsEmoji:self.addressTF.text]||
        [self stringContainsEmoji:self.projectTF.text]) {
        [ProgressHUDHandler showErrorWithStatus:[NSString stringWithFormat:@"对不起，您的使用了特殊字符不能提交"] onView:self.view completion:nil];
        }
    
    NSString *partsNameStr=[[self.partList valueForKeyPath:@"partName"] componentsJoinedByString:@"-"];
    NSString *partsNumStr=[[self.partList valueForKeyPath:@"counting"] componentsJoinedByString:@"-"];
    NSString *partsPriceStr=[[self.partList valueForKeyPath:@"partPrice"] componentsJoinedByString:@"-"];
    
    
    
    
    if (self.needReuploadImg) {
        [self uploadImage];
        return;
    }
    
    if (self.wasCaseEditing) {
        @weakify(self);
        [[APIsConnection shareConnection] casesHistoryAPIsGetEditCaseWithAccessToken:self.accessToken idStr:self.resultData.theCaseID brand:self.caseAutosInfoDTO.brandID factory:self.caseAutosInfoDTO.dealershipID fct:self.caseAutosInfoDTO.seriesID autosModelID:self.caseAutosInfoDTO.modelID carNumber:licensePlate wsxName:self.shopTF.text address:self.addressTF.text wxsTel:self.phoneTF.text addTime:self.timeTF.text project:self.projectTF.text hour:self.workingHoursTF.text fee:self.workingHoursFeeTF.text partsName:partsNameStr partsNum:partsNumStr partsPrice:partsPriceStr img:self.url success:^(NSURLSessionDataTask *operation, id responseObject) {
            NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
            NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
            NSLog(@"%@--%@",message,operation);
            [ProgressHUDHandler dismissHUD];
            if (errorCode!=0) {
                [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                }];
                return ;
            }
            @strongify(self);
            
            [self.navigationController popViewControllerAnimated:YES];
        } failure:^(NSURLSessionDataTask *operation, NSError *error) {
            NSLog(@"编辑 我的案例%@",error);
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
    }else{

//////////////////////////////////////////
        
    @weakify(self);
    [[APIsConnection shareConnection] casesHistoryAPIsGetAddCaseWithWithAccessToken:self.accessToken brand:self.caseAutosInfoDTO.brandID factory:self.caseAutosInfoDTO.dealershipID fct:self.caseAutosInfoDTO.seriesID autosModelID:self.caseAutosInfoDTO.modelID carNumber:licensePlate wsxName:self.shopTF.text address:self.addressTF.text wxsTel:self.phoneTF.text addTime:self.timeTF.text project:self.projectTF.text hour:self.workingHoursTF.text fee:self.workingHoursFeeTF.text partsName:partsNameStr partsNum:partsNumStr partsPrice:partsPriceStr img:self.url success:^(NSURLSessionDataTask *operation, id responseObject) {
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@--%@",message,operation);
        [ProgressHUDHandler dismissHUD];
        if (errorCode!=0) {
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            }];
            return ;
        }
        @strongify(self);
        MyCaseVC *vc=[MyCaseVC new];
        [self.navigationController pushViewController:vc animated:YES];
        [self setDefaultNavBackButtonWithoutTitle];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
