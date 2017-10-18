//
//  FeedbackVC.m
//  cdzer
//
//  Created by 车队长 on 16/8/22.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "FeedbackVC.h"
#import "FeedbackCell.h"
#import "Result.h"
#import <MJRefresh/MJRefresh.h>
#import "UITextField+ShareAction.h"

@interface FeedbackVC ()<UITextViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UITextField *nameFT;

@property (weak, nonatomic) IBOutlet UITextField *telephoneTF;

@property (weak, nonatomic) IBOutlet UITextView *feedbackInformationTextView;

@property (weak, nonatomic) IBOutlet UIButton *submitButton;

@property (nonatomic, strong) NSMutableArray *dataList; ///<数据列表

@property (weak, nonatomic) IBOutlet UIView *headView;

@property (weak, nonatomic) IBOutlet UIView *nameView;

@property (weak, nonatomic) IBOutlet UIView *feedbackView;

@property (weak, nonatomic) IBOutlet UIView *telephoneView;

@property (nonatomic, strong) UIToolbar *toolBar; ///<工具条

@property (nonatomic, assign) CGRect keyboardRect; ///<键盘坐标组

@end

@implementation FeedbackVC

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [self componentSetting];
}

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"意见反馈";
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardDidShowNotification object:nil];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(textFieldTextDidChange:) name:UITextFieldTextDidChangeNotification object:self.nameFT];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(textFieldTextDidChange:) name:UITextFieldTextDidChangeNotification object:self.telephoneTF];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(textViewTextDidChange:) name:UITextViewTextDidChangeNotification object:nil];
    [self initializationUI];
    
}

- (void)initializationUI {
    self.nameFT.shouldStopPCDAction = YES;
    self.telephoneTF.shouldStopPCDAction = YES;
    
    self.toolBar =  [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(UIScreen.mainScreen.bounds), 40)];
    [_toolBar setBarStyle:UIBarStyleDefault];
    UIBarButtonItem * spaceButton = [[UIBarButtonItem  alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                  target:self
                                                                                  action:nil];
    UIBarButtonItem * doneButton = [[UIBarButtonItem alloc]initWithTitle:getLocalizationString(@"finish")
                                                                   style:UIBarButtonItemStyleDone
                                                                  target:self
                                                                  action:@selector(hiddenKeyboard)];
    NSArray * buttonsArray = [NSArray arrayWithObjects:spaceButton,doneButton,nil];
    [_toolBar setItems:buttonsArray];
    
    [_nameFT setInputAccessoryView:_toolBar];
    [_telephoneTF setInputAccessoryView:_toolBar];
    [_feedbackInformationTextView setInputAccessoryView:_toolBar];
    
    [self.headView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5f withColor:[UIColor colorWithHexString:@"CDCED4"] withBroderOffset:nil];
    [self.nameView setViewBorderWithRectBorder:UIRectBorderBottom|UIRectBorderTop borderSize:0.5f withColor:[UIColor colorWithHexString:@"CDCED4"] withBroderOffset:nil];
    [self.feedbackView setViewBorderWithRectBorder:UIRectBorderBottom|UIRectBorderTop borderSize:0.5f withColor:[UIColor colorWithHexString:@"CDCED4"] withBroderOffset:nil];
    [self.telephoneView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5f withColor:[UIColor colorWithHexString:@"CDCED4"] withBroderOffset:nil];
    
    self.submitButton.layer.cornerRadius=3.0;
    self.submitButton.layer.masksToBounds=YES;
    [self.submitButton addTarget:self action:@selector(submitBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 137.0f;
    _tableView.tableFooterView=[UIView new];
    _tableView.backgroundColor=self.view.backgroundColor;
    UINib*nib=[UINib nibWithNibName:@"FeedbackCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"FeedbackCell"];
    
    

}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ident=@"FeedbackCell";
    FeedbackCell *cell=[tableView dequeueReusableCellWithIdentifier:ident];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    if (!cell) {
        cell=[[FeedbackCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CDZKeyOfCellIdentKey];
    }
    if (self.dataList.count>0) {
        NSDictionary*resultDic=self.dataList[indexPath.row];
        cell.userTelephone.text=resultDic[@"tel"];
        cell.userContentLabel.text=resultDic[@"content"];
        cell.cdzerContentLabel.text=resultDic[@"reply"];
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (void)keyboardWillShow:(NSNotification *)notifyObject {
    CGRect keyboardRect = [[notifyObject.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    if (!CGRectEqualToRect(keyboardRect, _keyboardRect)) {
        self.keyboardRect = keyboardRect;
        if ([_nameFT isFirstResponder]) {
            [self shiftScrollViewWithAnimation:_nameFT];
        }else if ([_telephoneTF isFirstResponder]) {
            [self shiftScrollViewWithAnimation:_telephoneTF];
        }else if ([_feedbackInformationTextView isFirstResponder]) {
            [self shiftScrollViewWithAnimationForTextView];
        }
    }
    
}

- (void)shiftScrollViewWithAnimationForTextView {
    UIView *theView = self.scrollView;
    CGPoint point = CGPointZero;
    CGFloat contanierViewMaxY = CGRectGetMidY([_feedbackInformationTextView.superview convertRect:_feedbackInformationTextView.frame toView:theView]);
    CGFloat visibleContentsHeight = (CGRectGetHeight(theView.frame)-CGRectGetHeight(_keyboardRect))/2.0f;
    if (contanierViewMaxY > visibleContentsHeight) {
        CGFloat offsetY = contanierViewMaxY-visibleContentsHeight;
        point.y = offsetY;
    }
    [self.scrollView setContentOffset:point animated:NO];
    self.scrollView.scrollEnabled = NO;
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
    self.scrollView.scrollEnabled = NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (!CGRectEqualToRect(CGRectZero, _keyboardRect)) {
        [self shiftScrollViewWithAnimation:textField];
    }
}

- (void)hiddenKeyboard {
    [_nameFT resignFirstResponder];
    [_telephoneTF resignFirstResponder];
    [_feedbackInformationTextView resignFirstResponder];
     self.keyboardRect = CGRectZero;
    CGPoint point = CGPointZero;
    [self.scrollView setContentOffset:point animated:NO];
    self.scrollView.scrollEnabled = YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([[[textView textInputMode] primaryLanguage] isEqualToString:@"emoji"] || ![[textView textInputMode] primaryLanguage]) {
        return NO;
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([[[textField textInputMode] primaryLanguage] isEqualToString:@"emoji"] || ![[textField textInputMode] primaryLanguage]) {
        return NO;
    }
    NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string]; //得到输入框的内容
    
    if (_nameFT==textField)  //判断是否是我们想要限定的那个输入框
    {
        NSUInteger length = ((textField.text.length-1)==-1)?0:textField.text.length-1;
        NSString *lastString = [textField.text substringFromIndex:length];
        if (([textField.text isEqualToString:@""]||[lastString isEqualToString:@" "])&&[string isEqualToString:@" "]) {
            return NO;
        }
        if ([toBeString length] > 8) { //限制输入框的内容在20个以内
            textField.text = [toBeString substringToIndex:8];
            
            return NO;
        }
    }
    if (_telephoneTF== textField)  //判断是否是我们想要限定的那个输入框
    {
        if (textField.text.length==0&&![string isEqualToString:@"1"]) {
            return NO;
        }
        if ([toBeString length] > 11) { //限制输入框的内容在11个以内
            textField.text = [toBeString substringToIndex:11];
            
            return NO;
        }
    }
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:@"请留下你的宝贵意见，您的意见是我们进步的源泉"]) {
        textView.text=@"";
    }
    
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:@""]) {
        textView.text=@"请留下你的宝贵意见，您的意见是我们进步的源泉";
    }
}

- (void)textViewTextDidChange:(NSNotification *)notiObj {
    UITextView *textView = (UITextView *)notiObj.object;
    NSUInteger maxLenght = 60;
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

- (void)textFieldTextDidChange:(NSNotification *)notiObj {
    NSUInteger maxLenght = 11;
    UITextField *textField = (UITextField *)notiObj.object;
    if (self.nameFT==textField) {
        maxLenght = 8;
    }
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

#pragma mark - 提交用户填写的反馈信息
- (void)submitBtnClick {
    NSLog(@"发送请求");
    [self hiddenKeyboard];
    if ([_nameFT.text isEqualToString:@""]) {
        [ProgressHUDHandler showErrorWithStatus:@"请输入姓名" onView:nil completion:nil];
        return;
    }else if([_telephoneTF.text isEqualToString:@""] ){
        [ProgressHUDHandler showErrorWithStatus:@"请输入联系方式" onView:nil completion:nil];
        return;
    }else if ([_feedbackInformationTextView.text isEqualToString:@""]||[_feedbackInformationTextView.text isEqualToString:@"请留下你的宝贵意见，您的意见是我们进步的源泉"] ){
        [ProgressHUDHandler showErrorWithStatus:@"请输入反馈意见" onView:nil completion:nil];
        return;
    }
    [self postFeedBackRequest];
}

- (void)postFeedBackRequest {
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    
    @weakify(self);
    NSString *url = nil;
    [ProgressHUDHandler showHUD];
//    if (_imageUrl&&[_imageUrl isContainsString:@"http"]) url = _imageUrl;
    [[APIsConnection shareConnection] personalSettingsAPIsPostUserFeedback:_nameFT.text tel:_telephoneTF.text token:self.accessToken content:_feedbackInformationTextView.text imageUrl:url success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        if (errorCode!=0) {
            if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {return;};
            [ProgressHUDHandler dismissHUD];
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
            return;
        }
        [ProgressHUDHandler showSuccessWithStatus:@"提交成功"  onView:nil completion:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
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
        
        [SupportingClass showAlertViewWithTitle:@"error" message:@"提交反馈信息失败，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            
        }];
    }];
}

- (void)componentSetting {
    @weakify(self);
    [ProgressHUDHandler showHUD];
    
    [APIsConnection.shareConnection personalCenterAPIsGetMyPFeedbackToShowWithSuccessBlock:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        [ProgressHUDHandler dismissHUD];
        self.dataList=responseObject[CDZKeyOfResultKey];
             [self.tableView reloadData];
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        [ProgressHUDHandler dismissHUD];
        NSLog(@" componentSetting error =%@",error);
    }];
    
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
