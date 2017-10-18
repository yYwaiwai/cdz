//
//  ViolationEnquiryVC.m
//  cdzer
//
//  Created by KEns0n on 12/30/15.
//  Copyright © 2015 CDZER. All rights reserved.
//

#import "ViolationEnquiryVC.h"
#import "InsetsLabel.h"
#import "InsetsTextField.h"
#import "UserAutosInfoDTO.h"
#import "MyCarVC.h"
#import "VEVCTopView.h"
#import "VEVCTableViewCell.h"
#import "TrafficViolationDetailVC.h"
#import <RegexKitLite/RegexKitLite.h>

@interface ViolationEnquiryVC ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) UserAutosInfoDTO *autoDTO;

@property (nonatomic, strong) UIButton *loginBtn;

@property (nonatomic, strong) UIButton *editAutoInfoBtn;

@property (nonatomic, strong) VEVCTopView *upperView;

@property (nonatomic, strong) NSMutableDictionary *userVEInfo;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIButton *unsolvedBtn;

@property (nonatomic, strong) UIButton *solvedBtn;

@property (nonatomic, strong) NSMutableArray *veList;

@property (nonatomic, strong) UIView *submitEngCodeView;

@property (nonatomic, strong) InsetsTextField *engTextField;

@property (nonatomic, strong) NSString *emtpyMessage;

@property (nonatomic, assign) CGRect keyboardRect;

@end

@implementation ViolationEnquiryVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"违章查询";
    [self componentSetting];
    [self initializationUI];
    [self setReactiveRules];
}

- (void)pushToMyAutosInfoVC {
    @autoreleasepool {
        MyCarVC *vc = [MyCarVC new];
        vc.wasSubmitAfterLeave = YES;
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.title = self.title;
    self.autoDTO = DBHandler.shareInstance.getUserAutosDetail;
    _editAutoInfoBtn.hidden = YES;
    _loginBtn.hidden = YES;
    if (!self.accessToken) {
        _loginBtn.hidden = NO;
        return;
    }
    
    if ([_autoDTO.brandID isEqualToString:@""]||[_autoDTO.dealershipID isEqualToString:@""]||
        [_autoDTO.seriesID isEqualToString:@""]||[_autoDTO.modelID isEqualToString:@""]||
        !_autoDTO.engineCode||[_autoDTO.engineCode isEqualToString:@""]||
        !_autoDTO.licensePlate||[_autoDTO.licensePlate isEqualToString:@""]) {
        
        _editAutoInfoBtn.frame = self.contentView.bounds;
        _editAutoInfoBtn.hidden = NO;
        return;
    }
    
    if (_veList.count==0) {
        [self getUserViolationEnquiryInfo];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (_engTextField.isFirstResponder) {
        [_engTextField resignFirstResponder];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setReactiveRules {
    @autoreleasepool {
        
    }
    
}

- (void)componentSetting {
    @autoreleasepool {
        self.veList = [@[] mutableCopy];
        self.userVEInfo = [@{} mutableCopy];
    }
}

- (void)presentLoginView {
    [self presentLoginViewWithBackTitle:nil animated:YES completion:nil];
}

- (void)initializationUI {
    @autoreleasepool {
        self.contentView.backgroundColor = [UIColor colorWithRed:0.953f green:0.953f blue:0.953f alpha:1.00f];
        
        NSMutableAttributedString *remindString = NSMutableAttributedString.new;
        
        [remindString appendAttributedString:[[NSAttributedString alloc] initWithString:@"使用服务前，\n需要完善你个人车辆信息方能使用！\n请"
                                                                             attributes:@{NSForegroundColorAttributeName:CDZColorOfBlack,
                                                                                          NSFontAttributeName:vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 16.0f, NO)}]];
        [remindString appendAttributedString:[[NSAttributedString alloc] initWithString:@"点击"
                                                                             attributes:@{NSForegroundColorAttributeName:CDZColorOfDefaultColor,
                                                                                          NSFontAttributeName:vGetHelveticaNeueFont(HelveticaNeueFontTypeOfBold, 20.0f, NO)}]];
        [remindString appendAttributedString:[[NSAttributedString alloc] initWithString:@"此处完善个人车辆信息！"
                                                                             attributes:@{NSForegroundColorAttributeName:CDZColorOfBlack,
                                                                                          NSFontAttributeName:vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 16.0f, NO)}]];
        self.editAutoInfoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _editAutoInfoBtn.frame = self.contentView.bounds;
        _editAutoInfoBtn.backgroundColor = CDZColorOfWhite;
        _editAutoInfoBtn.hidden = YES;
        _editAutoInfoBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        _editAutoInfoBtn.titleLabel.numberOfLines = 0;
        [_editAutoInfoBtn setAttributedTitle:remindString forState:UIControlStateNormal];
        [_editAutoInfoBtn addTarget:self action:@selector(pushToMyAutosInfoVC) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_editAutoInfoBtn];
        
        NSMutableAttributedString *loginRemindString = NSMutableAttributedString.new;
        
        [loginRemindString appendAttributedString:[[NSAttributedString alloc] initWithString:@"使用服务前，请登录个人帐号！\n"
                                                                             attributes:@{NSForegroundColorAttributeName:CDZColorOfBlack,
                                                                                          NSFontAttributeName:vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 16.0f, NO)}]];
        [loginRemindString appendAttributedString:[[NSAttributedString alloc] initWithString:@"点击登录"
                                                                             attributes:@{NSForegroundColorAttributeName:CDZColorOfDefaultColor,
                                                                                          NSFontAttributeName:vGetHelveticaNeueFont(HelveticaNeueFontTypeOfBold, 20.0f, NO)}]];

        self.loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _loginBtn.frame = self.contentView.bounds;
        _loginBtn.backgroundColor = CDZColorOfWhite;
        _loginBtn.hidden = YES;
        _loginBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        _loginBtn.titleLabel.numberOfLines = 0;
        [_loginBtn setAttributedTitle:loginRemindString forState:UIControlStateNormal];
        [_loginBtn addTarget:self action:@selector(presentLoginView) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_loginBtn];
        
        CGFloat offsetX = 15.0f;
        self.upperView = [[VEVCTopView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        _upperView.frame = CGRectMake(offsetX, 10.0f, CGRectGetWidth(self.contentView.frame)-offsetX*2.0f, 120.0f);
        [self.contentView addSubview:_upperView];
        
        
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        InsetsLabel *titleLabel = [[InsetsLabel alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(_upperView.frame)+6.0f, CGRectGetWidth(self.contentView.frame), 30.0f)
                                                  andEdgeInsetsValue:DefaultEdgeInsets];
        titleLabel.text = @"我的违章";
        [titleLabel setViewBorderWithRectBorder:UIRectBorderTop borderSize:0.5 withColor:nil withBroderOffset:nil];
        [self.contentView addSubview:titleLabel];
        
        self.unsolvedBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        _unsolvedBtn.frame = CGRectMake(0.0f, CGRectGetMaxY(titleLabel.frame), CGRectGetWidth(self.contentView.frame)/2.0f, 40.0f);
        _unsolvedBtn.enabled = NO;
        _unsolvedBtn.backgroundColor = CDZColorOfDefaultColor;
        [_unsolvedBtn setTitle:@"未处理" forState:UIControlStateNormal];
        [_unsolvedBtn setTitleColor:CDZColorOfBlack forState:UIControlStateNormal];
        [_unsolvedBtn addTarget:self action:@selector(handleVEList:) forControlEvents:UIControlEventTouchUpInside];
        [_unsolvedBtn setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:CDZColorOfDeepGray withBroderOffset:nil];
        [self.contentView addSubview:_unsolvedBtn];
        
        self.solvedBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        _solvedBtn.backgroundColor = CDZColorOfWhite;
        _solvedBtn.frame = CGRectMake(CGRectGetMaxX(_unsolvedBtn.frame), CGRectGetMaxY(titleLabel.frame), CGRectGetWidth(self.contentView.frame)/2.0f, 40.0f);
        [_solvedBtn setTitle:@"已处理" forState:UIControlStateNormal];
        [_solvedBtn setTitleColor:CDZColorOfBlack forState:UIControlStateNormal];
        [_solvedBtn addTarget:self action:@selector(handleVEList:) forControlEvents:UIControlEventTouchUpInside];
        [_solvedBtn setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:CDZColorOfDeepGray withBroderOffset:nil];
        [self.contentView addSubview:_solvedBtn];
        
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(_unsolvedBtn.frame), CGRectGetWidth(self.contentView.frame),
                                                                       CGRectGetHeight(self.contentView.frame)-CGRectGetMaxY(_unsolvedBtn.frame))];
        _tableView.backgroundColor = self.contentView.backgroundColor;
        _tableView.bounces = NO;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.hidden = YES;
        [self.contentView addSubview:_tableView];

        
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        self.submitEngCodeView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMinY(titleLabel.frame),
                                                                          CGRectGetWidth(self.contentView.frame),
                                                                          CGRectGetHeight(self.contentView.frame)-CGRectGetMinY(titleLabel.frame))];
        _submitEngCodeView.hidden = YES;
        _submitEngCodeView.backgroundColor = self.contentView.backgroundColor;
        [_submitEngCodeView setViewBorderWithRectBorder:UIRectBorderTop borderSize:0.5 withColor:nil withBroderOffset:nil];
        [self.contentView addSubview:_submitEngCodeView];
        
        UIView *tfContainerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 15.0f, CGRectGetWidth(_submitEngCodeView.frame), 40.0f)];
        [_submitEngCodeView addSubview:tfContainerView];
        
        UIEdgeInsets insetsValue = UIEdgeInsetsMake(0.0f, 15.0f, 0.0f, 4.0f);
        UIFont *font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfBold, 17, NO);
        NSString *tfTitleStr = @"发动机号";
        CGFloat width = [SupportingClass getStringSizeWithString:tfTitleStr font:font widthOfView:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                                   withEdgeInset:insetsValue].width;
        width +=(insetsValue.left+insetsValue.right);
        InsetsTextField *tfTitleLbl = [[InsetsTextField alloc] initWithFrame:CGRectMake(0.0f, 0.0f, width, CGRectGetHeight(tfContainerView.frame))
                                                          andEdgeInsetsValue:insetsValue];
        tfTitleLbl.text = tfTitleStr;
        tfTitleLbl.font = font;
        [tfContainerView addSubview:tfTitleLbl];
        
        InsetsTextField *tfQuestionMark = [[InsetsTextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(tfTitleLbl.frame), CGRectGetHeight(tfContainerView.frame)*0.2,
                                                                                            CGRectGetHeight(tfContainerView.frame)*0.6, CGRectGetHeight(tfContainerView.frame)*0.6)];
        tfQuestionMark.text = @"?";
        tfQuestionMark.textAlignment = NSTextAlignmentCenter;
        tfQuestionMark.textColor = CDZColorOfDefaultColor;
        tfQuestionMark.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfBold, 18, NO);
        [tfQuestionMark setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:CGRectGetHeight(tfQuestionMark.frame)/2.0f];
        [tfQuestionMark setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:2.0f withColor:CDZColorOfDefaultColor withBroderOffset:nil];
        [tfContainerView addSubview:tfQuestionMark];
        
        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.contentView.frame), 44.0f)];
        [toolbar setBarStyle:UIBarStyleDefault];
        UIBarButtonItem *spaceButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                    target:self
                                                                                    action:nil];
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]initWithTitle:getLocalizationString(@"finish")
                                                                      style:UIBarButtonItemStyleDone
                                                                     target:self
                                                                     action:@selector(hiddenKeyboard)];
        NSArray * buttonsArray = [NSArray arrayWithObjects:spaceButton,doneButton,nil];
        [toolbar setItems:buttonsArray];

        
        self.engTextField = [[InsetsTextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(tfQuestionMark.frame)+8.0f, CGRectGetHeight(tfContainerView.frame)*0.1,
                                                                              CGRectGetWidth(tfContainerView.frame)-CGRectGetMaxX(tfQuestionMark.frame)-16.0f,
                                                                              CGRectGetHeight(tfContainerView.frame)*0.8)];
        _engTextField.shouldStopPCDAction = NO;
        _engTextField.delegate = self;
        _engTextField.inputAccessoryView = toolbar;
        _engTextField.borderStyle = UITextBorderStyleRoundedRect;
        _engTextField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
        [tfContainerView addSubview:_engTextField];
        
        @weakify(self);
        [_engTextField.rac_textSignal subscribeNext:^(NSString *textSignal) {
            @strongify(self);
            NSString *regex = @"[^0-9A-Z]";
            NSMutableString *replacementString = textSignal.mutableCopy;
            [replacementString replaceOccurrencesOfRegex:regex withString:@""];
            self.engTextField.text = replacementString;
        }];
        
        UIImage *submitBtnImg = [ImageHandler getImageFromCacheByScreenRatioWithFileRootPath:nil fileName:@"sub_btn" type:FMImageTypeOfPNG scaleWithPhone4:NO offsetRatioForP4:0 needToUpdate:YES];
        
        UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeSystem];
        submitButton.frame = CGRectMake(0.0f, CGRectGetMaxY(tfContainerView.frame)+10.0f,
                                        CGRectGetWidth(_submitEngCodeView.frame)*0.8f, submitBtnImg.size.height+10.0f);
        submitButton.center = CGPointMake(CGRectGetWidth(_submitEngCodeView.frame)/2.0f, submitButton.center.y);
        submitButton.backgroundColor = [UIColor colorWithRed:0.243 green:0.435 blue:0.816 alpha:1.00];
        submitButton.tintColor = CDZColorOfWhite;
        [submitButton setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:5.0f];
        [submitButton setTitle:@"点击查询" forState:UIControlStateNormal];
        [submitButton setTitleColor:CDZColorOfWhite forState:UIControlStateNormal];
        [submitButton setImage:submitBtnImg forState:UIControlStateNormal];
        [submitButton addTarget:self action:@selector(submitEnquiryRequest) forControlEvents:UIControlEventTouchUpInside];
        [_submitEngCodeView addSubview:submitButton];
    }
}

- (void)submitEnquiryRequest {
    [self hiddenKeyboard];
    NSString *engineCode = _userVEInfo[@"engineNo"];
    if (![[self.autoDTO.engineCode substringFromIndex:self.autoDTO.engineCode.length-5] isEqualToString:engineCode]) {
        [self updateUserAutosEngineLast5DigiCode];
        return;
    }
    [self getViolationEnquiryListAndIsShowRequested:NO showHub:YES];
}

- (void)handleVEList:(UIButton *)button {
    _unsolvedBtn.enabled = YES;
    _solvedBtn.enabled = YES;
    _unsolvedBtn.backgroundColor = CDZColorOfWhite;
    _solvedBtn.backgroundColor = CDZColorOfWhite;
    button.enabled = NO;
    button.backgroundColor = CDZColorOfDefaultColor;
    if (button==_unsolvedBtn) {
        [self getViolationEnquiryListAndIsShowRequested:NO showHub:YES];
    }
    if (button==_solvedBtn) {
        [self getViolationEnquiryListAndIsShowRequested:YES showHub:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateUIViewData {
    @autoreleasepool {
        [_upperView updateUIDataWithDetailData:_userVEInfo];
        if ([SupportingClass verifyAndConvertDataToNumber:_userVEInfo[@"mark"]].integerValue<=0) {
            self.submitEngCodeView.hidden = NO;
            self.tableView.hidden = YES;
            self.engTextField.text = _userVEInfo[@"engineNo"];
        }else {
            self.submitEngCodeView.hidden = YES;
            self.tableView.hidden = NO;
            [self getViolationEnquiryListAndIsShowRequested:NO showHub:YES];
        }
    }
}

- (void)keyboardWillShow:(NSNotification *)notifyObject {
    CGRect keyboardRect = [[notifyObject.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    if (!CGRectEqualToRect(keyboardRect, _keyboardRect)) {
        self.keyboardRect = keyboardRect;
    }
    
    [self shiftScrollViewWithAnimation];
}

- (void)shiftScrollViewWithAnimation {
    UIView *theView = self.contentView;
    CGPoint point = CGPointZero;
    CGFloat contanierViewMaxY = CGRectGetMidY([_engTextField.superview convertRect:_engTextField.frame toView:theView]);
    CGFloat visibleContentsHeight = (CGRectGetHeight(theView.frame)-CGRectGetHeight(_keyboardRect))/2.0f;
    if (contanierViewMaxY > visibleContentsHeight) {
        CGFloat offsetY = contanierViewMaxY-visibleContentsHeight;
        point.y = offsetY;
    }
    [UIView animateWithDuration:0.25 animations:^{
        CGRect frame = theView.frame;
        frame.origin.y = 0.0f - point.y;
        theView.frame = frame;
    }];
    
}

- (void)hiddenKeyboard {
    [_engTextField resignFirstResponder];
    [UIView animateWithDuration:0.25 animations:^{
        CGRect frame = self.contentView.frame;
        frame.origin.y = 0.0f;
        self.contentView.frame = frame;
    }];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (!CGRectEqualToRect(_keyboardRect, CGRectZero)) {
        [self shiftScrollViewWithAnimation];
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self hiddenKeyboard];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString:@""]) return YES;
    
    if (textField.text.length>=5) {
        return NO;
    }
    
    NSString *regex = @"[0-9A-Z]";
    return [string isMatchedByRegex:regex];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (_veList.count==0) return 1;
    return _veList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    VEVCTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CDZKeyOfCellIdentKey];
    if (!cell) {
        cell = [[VEVCTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CDZKeyOfCellIdentKey];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    if (_veList.count==0) {
        [cell updateUIData:nil withWarningLabel:self.emtpyMessage];
    }else {
        NSDictionary *detail = _veList[indexPath.row];
        [cell updateUIData:detail withWarningLabel:self.emtpyMessage];
    }
    // Configure the cell...
   
    return cell;
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
//at least iOS 8 code here
#else
//lower than iOS 8 code here
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return 60;
}
#endif

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return 44.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    @autoreleasepool {
        if (_veList.count>0) {
            NSString *address = [_veList[indexPath.row] objectForKey:@"violation_place"];
            [self getHVDetailDataWithAddress:address];
        }
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

- (void)getViolationEnquiryListAndIsShowRequested:(BOOL)isShowRequested showHub:(BOOL)showHub {
    
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    NSString *engineCode = [SupportingClass verifyAndConvertDataToString:_userVEInfo[@"engineNo"]];
    NSString *licensePlate = [SupportingClass verifyAndConvertDataToString:_userVEInfo[@"carNumber"]];
    if (engineCode.length<=0||licensePlate.length<=0) {
        return;
    }
    
    self.submitEngCodeView.hidden = YES;
    self.tableView.hidden = NO;
    
    @weakify(self);
    if (showHub) {
        [ProgressHUDHandler showHUD];
    }else {
        [ProgressHUDHandler updateProgressStatusWithTitle:@"更新中。。。"];
    }
    [[APIsConnection shareConnection] personalCenterAPIsGetUserViolationEnquiryRequestWithAccessToken:self.accessToken myAutoEngineNum:engineCode licensePlate:licensePlate isShowRequested:isShowRequested  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {return;};
        [ProgressHUDHandler dismissHUD];
        if (errorCode!=0&&![message isEqualToString:@"返回成功"]) {
            self.emtpyMessage = @"加载失败！";
            if ([message isContainsString:@"等待查询"]) {
                [self.veList removeAllObjects];
                [self.tableView reloadData];
                self.emtpyMessage = @"系统繁忙，我们会在24小时内返回你的查询结果，请耐心等待！";
                return;
            }
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
            return;
        }
        [self.veList removeAllObjects];
        [self.veList addObjectsFromArray:responseObject[CDZKeyOfResultKey]];
        [self.tableView reloadData];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
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

- (void)updateUserAutosEngineLast5DigiCode {
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    if (_engTextField.text.length!=5) {
        [SupportingClass showAlertViewWithTitle:nil message:@"请输入发动机号后5位" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:nil];
        return;
    }
    @weakify(self);
    NSString *engineCode = _autoDTO.engineCode;
    engineCode = [engineCode stringByReplacingCharactersInRange:NSMakeRange(engineCode.length-5, 5) withString:_engTextField.text];
    [[APIsConnection shareConnection] personalCenterAPIsPatchMyAutoWithAccessToken:self.accessToken myAutoID:nil myAutoNumber:nil myAutoBodyColor:nil myAutoMileage:nil myAutoFrameNum:nil myAutoEngineNum:engineCode insuranceDate:nil annualCheckDate:nil maintenanceDate:nil registrDate:nil brandID:nil brandDealershipID:nil seriesID:nil modelID:nil insuranceNum:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {return;};
        if (errorCode!=0) {
            [ProgressHUDHandler dismissHUD];
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
            return;
        }
        [self updateLocalMyAutoData];
        [self.userVEInfo setObject:self.engTextField.text forKey:@"engineNo"];
        [self getViolationEnquiryListAndIsShowRequested:NO showHub:NO];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [ProgressHUDHandler dismissHUD];
        NSLog(@"%@",error.domain);
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

- (void)updateLocalMyAutoData {
    if (!self.accessToken) {
        return;
    }
    [[APIsConnection shareConnection] personalCenterAPIsGetMyAutoListWithAccessToken:self.accessToken success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        if (errorCode!=0) {
            [SupportingClass showAlertViewWithTitle:@"error" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
            return;
        }
        NSDictionary *autosDataDetail = responseObject[CDZKeyOfResultKey];
        UserAutosInfoDTO *dto = [UserAutosInfoDTO new];
        [dto processDataToObject:autosDataDetail optionWithUID:[UserBehaviorHandler.shareInstance getUserID]];
        [DBHandler.shareInstance updateUserAutosDetailData:dto.processObjectToDBData];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error);
    }];
    
}

- (void)getUserViolationEnquiryInfo {
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    [ProgressHUDHandler showHUD];
    @weakify(self);
    [APIsConnection.shareConnection personalCenterAPIsGetUserViolationEnquiryInfoWithAccessToken:self.accessToken success:^(AFHTTPRequestOperation *operation, id responseObject) {
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {return;};
        if (errorCode!=0&&![message isEqualToString:@"返回成功"]) {
            [ProgressHUDHandler dismissHUD];
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
            return;
        }
        [ProgressHUDHandler dismissHUD];
        self.userVEInfo = nil;
        self.userVEInfo = responseObject[CDZKeyOfResultKey];
        [self updateUIViewData];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
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

- (void)handleUserLoginResult:(BOOL)isSuccess fromAlert:(BOOL)fromAlert {
    if (isSuccess) {
        NSLog(@"success reload function %d", [self executeReloadFunction]);
    }else {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)getHVDetailDataWithAddress:(NSString *)address {
    if (!address||[address isEqualToString:@""]) {
        return ;
    }
    [ProgressHUDHandler showHUD];
    @weakify(self);
    [[APIsConnection shareConnection] personalCenterAPIsGetViolationDetailWithBlacksiteAddress:address success:^(AFHTTPRequestOperation *operation, id responseObject) {
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        [ProgressHUDHandler dismissHUD];
        if (errorCode!=0&&![message isEqualToString:@"返回成功"]) {
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
            return;
        }
        TrafficViolationDetailVC *vc = TrafficViolationDetailVC.new;
        vc.tvDetail = responseObject[CDZKeyOfResultKey];
        vc.address = address;
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
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


@end
