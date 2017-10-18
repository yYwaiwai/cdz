//
//  EServicePaymentVC.m
//  cdzer
//
//  Created by KEns0n on 16/4/8.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "EServicePaymentVC.h"
#import "OrderForm.h"
#import "WXPaymentObject.h"
#import "WXApi.h"
#import "EServiceDataCell.h"
#import "EServiceServiceDetailVC.h"
#import "HCSStarRatingView.h"
#import "EServicePaymentCreditView.h"
#import "EServiceAutoCancelApointmentObject.h"
#import <AlipaySDK/AlipaySDK.h>
#import <BEMCheckBox/BEMCheckBox.h>
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>


@interface EServicePaymentVC ()<BEMCheckBoxDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UIImageView *clockIV;

@property (nonatomic, weak) IBOutlet UIView *consultantContainerView;

@property (nonatomic, strong) IBOutlet NSLayoutConstraint *consultantContainerViewHeightConstraint;

@property (nonatomic, weak) IBOutlet UIImageView *consultantPortrait;

@property (nonatomic, weak) IBOutlet UILabel *consultantNameLabel;

@property (nonatomic, weak) IBOutlet UILabel *consultantPhoneLabel;

@property (nonatomic, weak) IBOutlet UILabel *consultantWorkingNumLabel;

@property (nonatomic, weak) IBOutlet UILabel *consultantServiceNumLabel;

@property (nonatomic, weak) IBOutlet UILabel *consultantTimeLabel;

@property (nonatomic, weak) IBOutlet UILabel *consultantDistanceLabel;

@property (nonatomic, weak) IBOutlet UILabel *creditsTitleLabel;

@property (nonatomic, weak) IBOutlet UILabel *creditsSubtitleLabel;

@property (nonatomic, weak) IBOutlet HCSStarRatingView *consultantRatingView;

@property (nonatomic, strong) NSString *consultantID;

@property (nonatomic, strong) NSDictionary *consultantDetail;


@property (nonatomic, strong) NSDictionary *paymentInfoDetail;



@property (nonatomic, strong) IBOutlet NSLayoutConstraint *tableViewHeightConstraint;

@property (nonatomic, weak) IBOutlet UILabel *orderInfoTitleLabel;

@property (nonatomic, weak) IBOutlet UIButton *payButton;

@property (nonatomic, weak) IBOutlet UILabel *countDownLabel;

@property (nonatomic, weak) IBOutlet UILabel *priceLabel;

@property (nonatomic, weak) IBOutlet UIControl *creditsCheckBoxView;

@property (nonatomic, weak) IBOutlet UIControl *aliCheckBoxView;

@property (nonatomic, weak) IBOutlet UIControl *wxCheckBoxView;

@property (nonatomic, weak) IBOutlet UIImageView *creditsImageView;

@property (nonatomic, weak) IBOutlet UIImageView *aliImageView;

@property (nonatomic, weak) IBOutlet UIImageView *wxImageView;


@property (nonatomic, strong) IBOutlet EServicePaymentCreditView *creditView;

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSString *appointmentTime;

@property (nonatomic, strong) NSString *orderPrice;

@property (nonatomic, strong) NSString *repiarMainType;

@property (nonatomic, strong) NSString *wxsName;

@property (nonatomic, strong) NSString *credits;

@property (nonatomic, strong) NSArray *dataList;


@property (nonatomic, strong) NSString *serviceName;

@property (nonatomic, strong) BEMCheckBox *creditsCheckBox;

@property (nonatomic, strong) BEMCheckBox *aliCheckBox;

@property (nonatomic, strong) BEMCheckBox *wxCheckBox;

@property (nonatomic, strong) OrderForm *orderForm;

@property (nonatomic, strong) NSString *signType;

@property (nonatomic, strong) NSString *signedString;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, assign) NSTimeInterval currentCountDown;


@end

@implementation EServicePaymentVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)viewDidLoad {
    self.title = @"确认订单";
    self.navShouldPopOtherVC = YES;
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self componentSetting];
    [self initializationUI];
    [self setReactiveRules];
    [self getEServicePaymentInfo];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupCountDown];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.timer) {
        if ([self.timer isValid]) {
            [self.timer invalidate];
        }
        self.timer = nil;
    }
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    BorderOffsetObject * offset = [BorderOffsetObject new];
    offset.leftBottomOffset = 12;
    offset.rightBottomOffset = -12;
    [self.orderInfoTitleLabel setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:offset];
    
    BorderOffsetObject *theOffset = [BorderOffsetObject new];
    theOffset.rightUpperOffset = 8.0f;
    theOffset.rightBottomOffset = 8.0f;
    
    theOffset.leftUpperOffset = 8.0f;
    theOffset.leftBottomOffset = 8.0f;
    [self.consultantTimeLabel setViewBorderWithRectBorder:UIRectBorderLeft|UIRectBorderRight borderSize:0.5f withColor:nil withBroderOffset:theOffset];
}

- (void)handleNavBackBtnPopOtherAction {
    @autoreleasepool {
        [self.view setNeedsDisplay];
        [self.view setNeedsLayout];
        [self.view setNeedsUpdateConstraints];
        
        if (self.showPushBackLastView) {
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.class == %@", EServiceServiceDetailVC.class];
        NSArray *result = [self.navigationController.viewControllers filteredArrayUsingPredicate:predicate];
        if (result&&result.count>0) {
            [(EServiceServiceDetailVC *)result.lastObject setShouldReloadData:YES];
            [self.navigationController popToViewController:result.lastObject animated:YES];
            return;
        }
        
        EServiceServiceDetailVC *vc = EServiceServiceDetailVC.new;
        vc.serviceType = _serviceType;
        vc.eServiceID = self.eServiceID;
        vc.creditsRatio = self.creditsRatio;
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
        
    }
}

- (void)componentSetting {
    
    self.clockIV.image = [self.clockIV.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    if (!self.creditsRatio||[self.creditsRatio isEqualToString:@""]) {
        self.creditsRatio = @"0.01";
    }
    
    UINib *theNib = [UINib nibWithNibName:@"EServicePaymentCreditView" bundle:nil];
    [theNib instantiateWithOwner:self options:nil];
    
    UINib *nib = [UINib nibWithNibName:@"EServiceDataCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"cell"];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 44;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.creditsImageView setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:CGRectGetHeight(self.creditsImageView.frame)/2.0f];
    [self.aliImageView setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:CGRectGetHeight(self.aliImageView.frame)/2.0f];
    [self.wxImageView setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:CGRectGetHeight(self.wxImageView.frame)/2.0f];
}

- (void)initializationUI {
    @autoreleasepool {
        self.creditsCheckBox = [[BEMCheckBox alloc] initWithFrame:self.creditsCheckBoxView.bounds];
        _creditsCheckBox.on = YES;
        _creditsCheckBox.onTintColor = [UIColor colorWithRed:0.314 green:0.784 blue:0.953 alpha:1.00];
        _creditsCheckBox.onFillColor = [UIColor colorWithRed:0.314 green:0.784 blue:0.953 alpha:1.00];
        _creditsCheckBox.onCheckColor = CDZColorOfWhite;
        _creditsCheckBox.boxType = BEMBoxTypeCircle;
        _creditsCheckBox.lineWidth = 1.0f;
        _creditsCheckBox.animationDuration = 0.1f;
        _creditsCheckBox.onAnimationType = BEMAnimationTypeFill;
        _creditsCheckBox.offAnimationType = BEMAnimationTypeFill;
        _creditsCheckBox.delegate = self;
        [self.creditsCheckBoxView addSubview:_creditsCheckBox];
        
        self.aliCheckBox = [[BEMCheckBox alloc] initWithFrame:self.aliCheckBoxView.bounds];
        _aliCheckBox.onTintColor = _creditsCheckBox.onTintColor;
        _aliCheckBox.onFillColor = _creditsCheckBox.onFillColor;
        _aliCheckBox.onCheckColor = _creditsCheckBox.onCheckColor;
        _aliCheckBox.boxType = _creditsCheckBox.boxType;
        _aliCheckBox.lineWidth = _creditsCheckBox.lineWidth;
        _aliCheckBox.animationDuration = 0.1f;
        _aliCheckBox.onAnimationType = BEMAnimationTypeFill;
        _aliCheckBox.offAnimationType = BEMAnimationTypeFill;
        _aliCheckBox.delegate = self;
        [self.aliCheckBoxView addSubview:_aliCheckBox];
        
        self.wxCheckBox = [[BEMCheckBox alloc] initWithFrame:self.wxCheckBoxView.bounds];
        _wxCheckBox.onTintColor = _creditsCheckBox.onTintColor;
        _wxCheckBox.onFillColor =  _creditsCheckBox.onFillColor;
        _wxCheckBox.onCheckColor = _creditsCheckBox.onCheckColor;
        _wxCheckBox.boxType = _aliCheckBox.boxType;
        _wxCheckBox.lineWidth = _aliCheckBox.lineWidth;
        _wxCheckBox.animationDuration = _aliCheckBox.animationDuration;
        _wxCheckBox.onAnimationType = _aliCheckBox.onAnimationType;
        _wxCheckBox.offAnimationType = _aliCheckBox.offAnimationType;
        _wxCheckBox.delegate = self;
        [self.wxCheckBoxView addSubview:_wxCheckBox];
    }
}

- (void)setReactiveRules {
    @weakify(self);
    [RACObserve(self, tableView.contentSize) subscribeNext:^(id size) {
        @strongify(self);
        CGSize contentSize = [size CGSizeValue];
        self.tableViewHeightConstraint.constant = contentSize.height;
        [self.tableView setNeedsUpdateConstraints];
        [self.view setNeedsLayout];
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellWithIdentifier = @"cell";
    EServiceDataCell *cell = [tableView dequeueReusableCellWithIdentifier:cellWithIdentifier forIndexPath:indexPath];
    NSDictionary *detail = self.dataList[indexPath.row];
    cell.titleLabel.text = detail[@"title"];
    
    NSString *contentKey = detail[@"value"];
    cell.contentLabel.text = [self valueForKeyPath:contentKey];
    return cell;
}

- (void)setupCountDown {
    self.currentCountDown = (round([EServiceAutoCancelApointmentObject getCurrentCountDownTimeByServiceType:self.serviceType])-1);
    if (self.timer) {
        if ([self.timer isValid]) {
            [self.timer invalidate];
        }
        self.timer = nil;
    }
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countDown) userInfo:nil repeats:YES];
    [self.timer fire];
}

- (void)countDown {
    if (self.currentCountDown<=0) {
        if ([self.timer isValid]) {
            [self.timer invalidate];
        }
        self.timer = nil;
        [self autoCancelEService:self.eServiceID];
        [EServiceAutoCancelApointmentObject cancelServiceCancelRecordByServiceType:self.serviceType];
        [self handleNavBackBtnPopOtherAction];
        return;
    }
    self.currentCountDown--;
    NSInteger minute = self.currentCountDown/60;
    NSInteger secound = (NSInteger)self.currentCountDown%60;
    self.countDownLabel.text = [NSString stringWithFormat:@"%02d:%02d", minute, secound];
}

- (void)didTapCheckBox:(BEMCheckBox *)checkBox {
    if (_creditsCheckBox==checkBox) {
        _creditsCheckBox.on = YES;
        [_aliCheckBox setOn:NO animated:YES];
        [_wxCheckBox setOn:NO animated:YES];
    }
    if (_aliCheckBox==checkBox) {
        _aliCheckBox.on = YES;
        [_creditsCheckBox setOn:NO animated:YES];
        [_wxCheckBox setOn:NO animated:YES];
    }
    if (_wxCheckBox==checkBox) {
        _wxCheckBox.on = YES;
        [_creditsCheckBox setOn:NO animated:YES];
        [_aliCheckBox setOn:NO animated:YES];
    }
}

- (IBAction)didTapCheckBoxSuperView:(UIControl *)superView {
    if (_creditsCheckBox.superview.superview==superView) {
        _creditsCheckBox.on = YES;
        [_aliCheckBox setOn:NO animated:YES];
        [_wxCheckBox setOn:NO animated:YES];
    }
    if (_aliCheckBox.superview.superview==superView) {
        _aliCheckBox.on = YES;
        [_creditsCheckBox setOn:NO animated:YES];
        [_wxCheckBox setOn:NO animated:YES];
    }
    if (_wxCheckBox.superview.superview==superView) {
        _wxCheckBox.on = YES;
        [_creditsCheckBox setOn:NO animated:YES];
        [_aliCheckBox setOn:NO animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getEServicePaymentInfo {
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    @weakify(self);
    [ProgressHUDHandler showHUD];
    
    if ([_eServiceID isEqualToString:@""]) {
        NSLog(@"missing eServiceID ");
        return;
    }
    
    [self getConsultantDetail];
    
    [APIsConnection.shareConnection personalCenterAPIsGetEServicePaymentConfirmInfoWithAccessToken:self.accessToken eServiceID:_eServiceID success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        if (![message isContainsString:@"返回成功"]){
            if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {return;};
            [ProgressHUDHandler dismissHUD];
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
            return;
        }
        
        [ProgressHUDHandler dismissHUD];
        //        "id": "ER160408133752532029",
        //        "repairTime": "2016-04-08 15:37",
        //        "project": "车身及附件",
        //        "phone": "13713713714",
        //        "service_fee": "0.01",
        //        "e_type": "e代修",
        //        "name": "还好纠结啊大师大师大",
        //        "wxsName": "湖南兰天君天汽车销售有限公司",
        //        "type": "1",
        //        "addTime": "2016-04-08 13:37:52"
        
        //        "id": "ER160408135712926109",
        //        "repairTime": "2016-04-08 15:56",
        //        "project": "领取环保标识",
        //        "phone": "13713713714",
        //        "service_fee": "0.01",
        //        "e_type": "e代检",
        //        "name": "萨德大使",
        //        "wxsName": "暂无",
        //        "type": "暂无",
        //        "addTime": "2016-04-08 13:57:12"
        
        //        id": "ER160408132544405370",
        //        "repairTime": "暂无",
        //        "project": "单人事故",
        //        "phone": "13713713714",
        //        "service_fee": "0.01",
        //        "e_type": "e代赔",
        //        "name": "12？我2？我们都市报 你",
        //        "wxsName": "暂无",
        //        "type": "暂无",
        //        "addTime": "2016-04-08 13:25:44"
        self.paymentInfoDetail = responseObject[CDZKeyOfResultKey];
        self.consultantID = self.paymentInfoDetail[@"commissioner_id"];
        self.appointmentTime = self.paymentInfoDetail[@"repairTime"];
        self.serviceName = self.paymentInfoDetail[@"project"];
        
        self.wxsName = self.paymentInfoDetail[@"wxsName"];
        NSString *orderPriceString = [SupportingClass verifyAndConvertDataToString:self.paymentInfoDetail[@"service_fee"]];
        self.orderPrice = [NSString stringWithFormat:@"¥%@", orderPriceString];
        self.priceLabel.text = self.orderPrice;
        
        self.credits = [SupportingClass verifyAndConvertDataToString:self.paymentInfoDetail[@"credit"]];
        self.creditsSubtitleLabel.text = [NSString stringWithFormat:@"(总积分：%@)",self.credits];
        
        NSMutableAttributedString *creditsTitleText = [NSMutableAttributedString new];
        [creditsTitleText appendAttributedString:[[NSAttributedString alloc]
                                                initWithString:@"积分支付 "
                                                  attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"323232"],
                                                               NSFontAttributeName:[UIFont systemFontOfSize:11]}]];
        NSInteger creditResult = roundf(orderPriceString.floatValue/self.creditsRatio.floatValue);
        [creditsTitleText appendAttributedString:[[NSAttributedString alloc]
                                                initWithString:[NSString stringWithFormat:@"%@分",@(creditResult)]
                                                attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"f8af30"],
                                                             NSFontAttributeName:[UIFont systemFontOfSize:15]}]];
        self.creditsTitleLabel.attributedText = creditsTitleText;

        
        
        NSString *tmpTypeStr = self.paymentInfoDetail[@"type"];
        self.repiarMainType = tmpTypeStr;
//        if ([tmpTypeStr isContainsString:@"0"]) self.repiarMainType = @"保养";
//        if ([tmpTypeStr isContainsString:@"1"]) {
//            if ([self.repiarMainType isEqualToString:@""]) {
//                self.repiarMainType = @"维修";
//            }else {
//                self.repiarMainType = [self.repiarMainType stringByAppendingString:@"，维修"];
//            }
//        }
//        
//        if ([tmpTypeStr isContainsString:@"2"]) {
//            if ([self.repiarMainType isEqualToString:@""]) {
//                self.repiarMainType = @"钣喷";
//            }else {
//                self.repiarMainType = [self.repiarMainType stringByAppendingString:@"，钣喷"];
//            }
//        }
        
        switch (self.serviceType) {
            case EServiceTypeOfERepair:
                if ([self.appointmentTime isEqualToString:@"暂无"]) {
                self.dataList = @[@{@"title":@"项目总类：", @"value":@"repiarMainType"},
                                  @{@"title":@"待修项目：", @"value":@"serviceName"},
                                  @{@"title":@"维修商：", @"value":@"wxsName"},];
                }else {
                    self.dataList = @[@{@"title":@"预约时间：", @"value":@"appointmentTime"},
                                      @{@"title":@"项目总类：", @"value":@"repiarMainType"},
                                      @{@"title":@"待修项目：", @"value":@"serviceName"},
                                      @{@"title":@"维修商：", @"value":@"wxsName"},];
                }
                
                break;
            case EServiceTypeOfEInspect:
                if ([self.appointmentTime isEqualToString:@"暂无"]) {
                    self.dataList = @[@{@"title":@"待检项目：", @"value":@"serviceName"}];
                }else {
                    self.dataList = @[@{@"title":@"预约时间：", @"value":@"appointmentTime"},
                                      @{@"title":@"待检项目：", @"value":@"serviceName"}];
                }
                
                break;
            case EServiceTypeOfEInsurance:
                self.dataList = @[@{@"title":@"事故种类：", @"value":@"serviceName"}];
                break;
                
                
            default:
                break;
        }
        [self.tableView reloadData];
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        NSLog(@"%@",error);
        @strongify(self);
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
    
    
    [APIsConnection.shareConnection personalCenterAPIsGetEServicePaymentInitInfoWithAccessToken:self.accessToken eServiceID:_eServiceID success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        if (errorCode!=0){
            if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {return;};
            [ProgressHUDHandler dismissHUD];
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
            return;
        }
        
        [ProgressHUDHandler dismissHUD];
        
        NSDictionary *dataDetail = responseObject[CDZKeyOfResultKey];
        self.orderForm = [[OrderForm alloc] init];
        self.orderForm.partner = dataDetail[@"partner"];
        self.orderForm.seller = dataDetail[@"seller_id"];
        self.orderForm.tradeNO = dataDetail[@"out_trade_no"];//[self generateTradeNO]; //订单ID（由商家自行制定）
        self.orderForm.productName = dataDetail[@"subject"]; //商品标题
        self.orderForm.productDescription = dataDetail[@"body"]; //商品描述
        self.orderForm.amount = dataDetail[@"total_fee"]; //商品价格
        self.orderForm.notifyURL = dataDetail[@"notify_url"]; //回调URL
        
        self.orderForm.service = dataDetail[@"service"];
        self.orderForm.paymentType = dataDetail[@"payment_type"];
        self.orderForm.inputCharset = dataDetail[@"_input_charset"];
        self.orderForm.itBPay = dataDetail[@"it_b_pay"];
        self.orderForm.showUrl = dataDetail[@"show_url"];
        self.orderForm.appID = dataDetail[@"app_id"];
        self.signType = dataDetail[@"sign_type"];
        self.signedString = dataDetail[@"sign"];
       
     
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

- (void)getConsultantDetail {
    
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    @weakify(self);
    [ProgressHUDHandler showHUD];
    
    if ([self.eServiceID isEqualToString:@""]) {
        NSLog(@"missing eServiceID ");
        return;
    }
    
    
    [APIsConnection.shareConnection personalCenterAPIsGetEServiceConsultantDetailWithAccessToken:self.accessToken eServiceID:self.eServiceID success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSString *sing = responseObject[@"sing"];
        NSLog(@"%@",message);
        if (![message isContainsString:@"返回成功"]||errorCode!=0){
            if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {return;};
            [ProgressHUDHandler dismissHUD];
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
            return;
        }
        
        if ([sing isEqualToString:@"没有改专员"]) {
            [SupportingClass showToast:@"没有找到该专员(或者该专员没有上班)，以下是车队长为您推荐的专员！"];
        }
        
        [ProgressHUDHandler dismissHUD];
        self.consultantDetail = responseObject[CDZKeyOfResultKey];
        NSString *imgURLStr = self.consultantDetail[@"face_img"];
        self.consultantNameLabel.text = self.consultantDetail[@"commissionerName"];
        self.consultantPhoneLabel.text = self.consultantDetail[@"commissionerPhone"];
        NSString *staffNum = [SupportingClass verifyAndConvertDataToString:self.consultantDetail[@"contract_no"]];
        if (!staffNum||[staffNum isEqualToString:@""]) staffNum = @"--";
        self.consultantWorkingNumLabel.text = staffNum;
        if ([imgURLStr isContainsString:@"http"]) {
            [self.consultantPortrait setImageWithURL:[NSURL URLWithString:imgURLStr] placeholderImage:self.consultantPortrait.image usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        }
        
        NSNumber *starNum = [SupportingClass verifyAndConvertDataToNumber:self.consultantDetail[@"star"]];
        self.consultantRatingView.value = starNum.floatValue;
        
        NSMutableAttributedString *serviceNumText = [NSMutableAttributedString new];
        [serviceNumText appendAttributedString:[[NSAttributedString alloc]
                                                initWithString:@"服务次数\n"
                                                attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"646464"],
                                                             NSFontAttributeName:[UIFont systemFontOfSize:9]}]];
        [serviceNumText appendAttributedString:[[NSAttributedString alloc]
                                                initWithString:[NSString stringWithFormat:@"%@次", [SupportingClass verifyAndConvertDataToString:self.consultantDetail[@"serve_num"]]]
                                                attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"323232"],
                                                             NSFontAttributeName:[UIFont systemFontOfSize:11]}]];
        self.consultantServiceNumLabel.attributedText = serviceNumText;
        
        
        NSMutableAttributedString *timeText = [NSMutableAttributedString new];
        [timeText appendAttributedString:[[NSAttributedString alloc]
                                          initWithString:@"时间\n"
                                          attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"646464"],
                                                       NSFontAttributeName:[UIFont systemFontOfSize:9]}]];
        [timeText appendAttributedString:[[NSAttributedString alloc]
                                          initWithString:[NSString stringWithFormat:@"%@分钟", [SupportingClass verifyAndConvertDataToString:self.consultantDetail[@"car_time"]]]
                                          attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"323232"],
                                                       NSFontAttributeName:[UIFont systemFontOfSize:11]}]];
        self.consultantTimeLabel.attributedText = timeText;
        
        
        NSMutableAttributedString *distanceText = [NSMutableAttributedString new];
        [distanceText appendAttributedString:[[NSAttributedString alloc]
                                              initWithString:@"距离\n"
                                              attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"646464"],
                                                           NSFontAttributeName:[UIFont systemFontOfSize:9]}]];
        [distanceText appendAttributedString:[[NSAttributedString alloc]
                                              initWithString:[NSString stringWithFormat:@"%@KM", [SupportingClass verifyAndConvertDataToString:self.consultantDetail[@"distance"]]]
                                              attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"323232"],
                                                           NSFontAttributeName:[UIFont systemFontOfSize:11]}]];
        self.consultantDistanceLabel.attributedText = distanceText;
        
        if ([self.consultantNameLabel.text isEqualToString:@""]&&[self.consultantPhoneLabel.text isEqualToString:@""]) {
            self.consultantContainerView.hidden = YES;
            self.consultantContainerViewHeightConstraint.constant = 0;
        }
        
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

- (IBAction)submitPayment {
    if (self.creditsCheckBox.on) {
        [self creditsPay];
    }
    if (self.aliCheckBox.on) {
        [self aliPay];
    }
    if (self.wxCheckBox.on) {
        [self wxPay];
    }
}

- (void)creditsPay {
    if (!self.creditView.responseBlock) {
        @weakify(self);
        self.creditView.responseBlock = ^() {
            @strongify(self);
            [self submitCreditPayment];
        };
    }
    [self.creditView showView];
}

- (void)submitCreditPayment {
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    @weakify(self);
    [ProgressHUDHandler showHUD];
    
    [APIsConnection.shareConnection personalCenterAPIsPostEServiceCreditsPaymentWithAccessToken:self.accessToken eServiceID:self.eServiceID verifyCode:self.creditView.getVerifyCode success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        if (![message isContainsString:@"返回成功"]||errorCode!=0){
            if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {return;};
            [ProgressHUDHandler dismissHUD];
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
            return;
        }
        [self.creditView dismissSelf];
        [ProgressHUDHandler dismissHUD];
        EServiceCancelRecordDTO *dto = [DBHandler.shareInstance getEServiceCancelRecordByEServiceID:self.eServiceID];
        [EServiceAutoCancelApointmentObject cancelServiceCancelRecordWithDto:dto];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.class == %@", EServiceServiceDetailVC.class];
        NSArray *result = [self.navigationController.viewControllers filteredArrayUsingPredicate:predicate];
        if (result&&result.count>0) {
            [(EServiceServiceDetailVC *)result.lastObject setShouldReloadData:YES];
            [self.navigationController popToViewController:result.lastObject animated:YES];
            return;
        }
        
        EServiceServiceDetailVC *vc = EServiceServiceDetailVC.new;
        vc.serviceType = self.serviceType;
        vc.eServiceID = self.eServiceID;
        vc.creditsRatio = self.creditsRatio;
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];

        
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

- (void)aliPay {
    //应用注册scheme,在Info.plist定义URL types
    NSString *appScheme = @"cdzerpersonal";
    
    NSString *orderBodyString = _orderForm.description;
    
    //将签名成功字符串格式化为订单字符串,请严格按照该格式
    NSString *orderString = nil;
    if (_signedString) {
        [ProgressHUDHandler dismissHUD];
        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                       orderBodyString, _signedString, _signType];
        
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            
            NSLog(@"reslut = %@",resultDic);
            NSNumber *status = [SupportingClass verifyAndConvertDataToNumber:resultDic[@"resultStatus"]];
            NSString *message = @"支付失败！";
            NSString *title = @"error";
            switch (status.integerValue) {
                case 4000:
                    message = @"系统繁忙，请稍后再试";
                    title = nil;
                case 9000:
                    message = @"支付成功！";
                    title = nil;
                    break;
                case 8000:
                    message = @"支付成功，处理中！";
                    title = nil;
                    break;
                case 3:
                case 6001:
                    message = @"你已取消该次支付！";
                    title = nil;
                    break;
                    
                default:
                    break;
            }
            [self handleAliPayMessage:message andErrorCode:status.integerValue];
        }];
        
    }else {
        [ProgressHUDHandler showErrorWithStatus:@"遗失交易信息，支付失败！" onView:nil completion:nil];
        [self handleAliPayMessage:@"遗失交易信息，支付失败！" andErrorCode:4000];
    }
}

- (void)handleAliPayMessage:(NSString *)resultMessage andErrorCode:(NSInteger)errorCode {
    NSString *message = @"支付失败！";
    NSString *title = @"error";
    switch (errorCode) {
        case 9000:
            message = @"支付成功！";
            title = nil;
            break;
        case 8000:
            message = @"支付成功，处理中！";
            title = nil;
            break;
        case 6001:
        case 3:
            message = @"你已取消该次支付！";
            title = nil;
            break;
        case 6002:
            message = @"网络错误，无法支付！";
            break;
            
        default:
            break;
    }
    @weakify(self);
    [SupportingClass showAlertViewWithTitle:title  message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil    clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
        @strongify(self);
        if (errorCode>=8000) {
            EServiceCancelRecordDTO *dto = [DBHandler.shareInstance getEServiceCancelRecordByEServiceID:self.eServiceID];
            [EServiceAutoCancelApointmentObject cancelServiceCancelRecordWithDto:dto];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.class == %@", EServiceServiceDetailVC.class];
            NSArray *result = [self.navigationController.viewControllers filteredArrayUsingPredicate:predicate];
            if (result&&result.count>0) {
                [(EServiceServiceDetailVC *)result.lastObject setShouldReloadData:YES];
                [self.navigationController popToViewController:result.lastObject animated:YES];
                return;
            }
            
            EServiceServiceDetailVC *vc = EServiceServiceDetailVC.new;
            vc.serviceType = self.serviceType;
            vc.eServiceID = self.eServiceID;
            vc.creditsRatio = self.creditsRatio;
            [self setDefaultNavBackButtonWithoutTitle];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }];

}

- (void)wxPay {
    if (![WXApi isWXAppInstalled]) {
        [SupportingClass showAlertViewWithTitle:@"" message:@"无法发起支付请求，本系统还没安装微信客户端，支付前请先安装微信客户端或者使用另外支付方式！" isShowImmediate:YES cancelButtonTitle:@"cancel" otherButtonTitles:@"前往下载" clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            if (btnIdx.integerValue>0) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/cn/app/id414478124?mt=8"]];
            }
        }];
        return;
    }
    
    if (![WXApi isWXAppSupportApi]) {
        [SupportingClass showAlertViewWithTitle:@"" message:@"无法发起支付请求，本系统不支援微信客户端！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            
        }];
        return;
    }
    

    NSString *amount = @(_orderForm.amount.doubleValue*100).stringValue;
    
    @weakify(self);
    [WXPaymentManager.defaultManager sendWeChatPrePayAndPaymentRequestWithOrderID:_orderForm.tradeNO orderTitle:_orderForm.productName price:amount completion:^(NSError *error, id requestObject, id responseObject) {
        @strongify(self);
        if ([error.domain isEqualToString:PAYMENT_ERROR_DOMAIN_WX_PAY_RESULT_SUCCESS]) {
            EServiceCancelRecordDTO *dto = [DBHandler.shareInstance getEServiceCancelRecordByEServiceID:self.eServiceID];
            [EServiceAutoCancelApointmentObject cancelServiceCancelRecordWithDto:dto];
            
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.class == %@", EServiceServiceDetailVC.class];
            NSArray *result = [self.navigationController.viewControllers filteredArrayUsingPredicate:predicate];
            if (result&&result.count>0) {
                [(EServiceServiceDetailVC *)result.lastObject setShouldReloadData:YES];
                [self.navigationController popToViewController:result.lastObject animated:YES];
                return;
            }
            
            EServiceServiceDetailVC *vc = EServiceServiceDetailVC.new;
            vc.serviceType = self.serviceType;
            vc.eServiceID = self.eServiceID;
            vc.creditsRatio = self.creditsRatio;
            [self setDefaultNavBackButtonWithoutTitle];
            [self.navigationController pushViewController:vc animated:YES];

        }else {
            if (error) {
                [SupportingClass showToast:error.userInfo[NSLocalizedDescriptionKey]];
            }else {
                [SupportingClass showToast:@"无法发起支付请求，请稍后再试！"];
            }
        }
    }];
}

- (void)autoCancelEService:(NSString *)eServiceID {
    if (!self.accessToken) {
        return;
    }
    [APIsConnection.shareConnection personalCenterAPIsPostEServiceCancelServiceWithAccessToken:self.accessToken eServiceID:eServiceID isAutoCancel:YES success:^(NSURLSessionDataTask *operation, id responseObject) {
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        NSLog(@"%@",error);
    }];
    
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
