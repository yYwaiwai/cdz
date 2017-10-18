//
//  EServiceServiceDetailVC.m
//  cdzer
//
//  Created by KEns0nLau on 6/12/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "EServiceServiceDetailVC.h"
#import "HCSStarRatingView.h"
#import "EServicePaymentVC.h"
#import "MyEServiceComment.h"
#import "EServiceServiceListVC.h"
#import "EServiceDataCell.h"
#import "EServiceAutoCancelApointmentObject.h"

@interface EServiceServiceDetailVC ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, assign) BOOL orderWasPaid;

@property (nonatomic, assign) BOOL orderWasRefunding;

@property (nonatomic, assign) BOOL wasCommented;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, assign) NSTimeInterval currentCountDown;


@property (nonatomic, weak) IBOutlet NSLayoutConstraint *countDownViewHeightConstraint;

@property (nonatomic, weak) IBOutlet UIImageView *clockIV;

@property (nonatomic, weak) IBOutlet UILabel *timeLabel;

@property (nonatomic, weak) IBOutlet UIImageView *statusIV;

@property (nonatomic, weak) IBOutlet UILabel *statusLabel;


@property (nonatomic, weak) IBOutlet UIView *consultantDetailView;

@property (nonatomic, weak) IBOutlet UIImageView *consultantPortrait;

@property (nonatomic, weak) IBOutlet UILabel *consultantNameLabel;

@property (nonatomic, weak) IBOutlet UILabel *consultantPhoneLabel;

@property (nonatomic, weak) IBOutlet UILabel *consultantWorkingNumLabel;

@property (nonatomic, weak) IBOutlet UILabel *consultantServiceNumLabel;

@property (nonatomic, weak) IBOutlet UILabel *consultantTimeLabel;

@property (nonatomic, weak) IBOutlet UILabel *consultantDistanceLabel;

@property (nonatomic, weak) IBOutlet HCSStarRatingView *consultantRatingView;

@property (weak, nonatomic) IBOutlet UIView *consultantDetailContainerView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *consultantDetailContainerViewTopConstraint;


@property (nonatomic, weak) IBOutlet UIView *userDetailView;

@property (nonatomic, weak) IBOutlet UILabel *userDetailTitleLabel;

@property (nonatomic, weak) IBOutlet UILabel *userNameLabel;

@property (nonatomic, weak) IBOutlet UILabel *userPhoneLabel;

@property (nonatomic, weak) IBOutlet UILabel *userAutosLabel;


@property (nonatomic, weak) IBOutlet UIView *serviceDetailView;

@property (nonatomic, weak) IBOutlet UILabel *serviceDetailTitleLabel;

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *tableViewHeight;

@property (nonatomic, strong) NSArray *dataList;

@property (nonatomic, strong) NSString *dropOffAddress;

@property (nonatomic, strong) NSString *appointmentTime;

@property (nonatomic, strong) NSString *serviceName;

@property (nonatomic, strong) NSString *wxsName;

@property (nonatomic, strong) NSString *wxsAddress;




@property (nonatomic, strong) IBOutlet NSLayoutConstraint *scrollViewLastViewBottomConstraint;

@property (nonatomic, weak) IBOutlet UIView *bottomButtonsContainer;

@property (nonatomic, weak) IBOutlet UIView *appiontmentButtonsContainer;

@property (nonatomic, weak) IBOutlet UIView *allButtonsContainer;

@property (nonatomic, weak) IBOutlet UIButton *confirmAutosReturnBtn;

@property (nonatomic, weak) IBOutlet UIButton *cancelOrderBtn;

@property (nonatomic, weak) IBOutlet UIButton *commentOrderBtn;

@property (nonatomic, weak) IBOutlet UIButton *reviewCommentBtn;

@end

@implementation EServiceServiceDetailVC


- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"服务详情";
    // Do any additional setup after loading the view from its nib.
    [self componentSetting];
    [self initializationUI];
    [self setReactiveRules];
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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.shouldReloadData||self.serviceDetail) {
        [self getEServiceDetail];
        self.shouldReloadData = NO;
    }
    
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    [self.userDetailTitleLabel setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5f withColor:[UIColor colorWithRed:0.839 green:0.843 blue:0.863 alpha:1.00] withBroderOffset:nil];
    
    [self.serviceDetailTitleLabel setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5f withColor:[UIColor colorWithRed:0.839 green:0.843 blue:0.863 alpha:1.00] withBroderOffset:nil];
    
    BorderOffsetObject *offset = [BorderOffsetObject new];
    offset.bottomLeftOffset = 12;
    [self.userDetailTitleLabel setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5f withColor:[UIColor colorWithRed:0.839 green:0.843 blue:0.863 alpha:1.00] withBroderOffset:offset];
    
    [self.consultantDetailView setBorderWithColor:[UIColor colorWithRed:0.851 green:0.851 blue:0.851 alpha:1.00] borderWidth:0.5];
    [self.consultantDetailView setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:5.0f];
    
    [self.userDetailView setViewBorderWithRectBorder:UIRectBorderTop|UIRectBorderBottom borderSize:0.5f withColor:[UIColor colorWithRed:0.839 green:0.843 blue:0.863 alpha:1.00] withBroderOffset:nil];
    
    [self.serviceDetailView setViewBorderWithRectBorder:UIRectBorderTop|UIRectBorderBottom borderSize:0.5f withColor:[UIColor colorWithRed:0.839 green:0.843 blue:0.863 alpha:1.00] withBroderOffset:nil];
    [self.bottomButtonsContainer setViewBorderWithRectBorder:UIRectBorderTop|UIRectBorderBottom borderSize:0.5f withColor:[UIColor colorWithRed:0.839 green:0.843 blue:0.863 alpha:1.00] withBroderOffset:nil];
    
    BorderOffsetObject *theOffset = [BorderOffsetObject new];
    theOffset.rightUpperOffset = 8.0f;
    theOffset.rightBottomOffset = 8.0f;
    
    theOffset.leftUpperOffset = 8.0f;
    theOffset.leftBottomOffset = 8.0f;
    [self.consultantTimeLabel setViewBorderWithRectBorder:UIRectBorderLeft|UIRectBorderRight borderSize:0.5f withColor:nil withBroderOffset:theOffset];
}

- (void)initializationUI {
    @autoreleasepool {
        if (self.serviceDetail&&self.serviceDetail.count>0) {
            [self updateAllUIData];
        }
    }
}

- (void)updateAllUIData {
    @autoreleasepool {
//        "address":湖南省长沙市岳麓区麓天路14号",
//        "carNumber":湘AJD858",
//        "car_time":0",
//        "commissionerName":张三",
//        "commissionerPhone":13142249956",
//        "contract_no":",
//        "distance":0,
//        "name":u 宿舍就是",
//        "phone":13713713713",
//        "project":单人事故",
//        "repairTime":暂无",
//        "serve_num":0,
//        "service_fee":u 宿舍就是",
//        "specName":2014款 30 TFSI 时尚型",
//        "star":5,
//        "state":代赔完成",
//        "wxsName":暂无",
//        "wxs_address":""
//        "fctName":""
        
        
        NSString *paymentStatusName = self.serviceDetail[@"order_state"];
        self.orderWasPaid = ([paymentStatusName isContainsString:@"已付款"]||[paymentStatusName isContainsString:@"免费"]);
        self.wasCommented = [SupportingClass verifyAndConvertDataToNumber:self.serviceDetail[@"reg_tag"]].boolValue;
        self.orderWasRefunding = [paymentStatusName isContainsString:@"申请退款中"];

        
        NSString *statusName = self.serviceDetail[@"state"];
        NSString *imageName = @"eservice_service_appointment_paid@3x";
        if ([statusName isContainsString:@"预约成功"]&&!self.orderWasPaid) {
            imageName = @"eservice_service_appointment_unpaid@3x";
        }
        if ([statusName isContainsString:@"取消"]) {
            imageName = self.orderWasPaid?@"eservice_service_cancel_paid@3x":@"eservice_service_cancel_unpaid@3x";
        }
        if ([statusName isContainsString:@"等待接车"]) {
            imageName = @"eservice_service_wait_4_pickup_paid@3x";
        }
        if ([statusName isContainsString:@"中"]) {
            imageName = @"eservice_service_in_progress_paid@3x";
        }
        if ([statusName isContainsString:@"完成"]) {
            imageName = @"eservice_service_finish_paid@3x";
        }
        self.countDownViewHeightConstraint.constant = 0;
        self.scrollViewLastViewBottomConstraint.constant = 26;
        self.bottomButtonsContainer.hidden = YES;
        self.allButtonsContainer.hidden = YES;
        self.appiontmentButtonsContainer.hidden = YES;
        self.confirmAutosReturnBtn.hidden = YES;
        self.cancelOrderBtn.hidden = YES;
        self.reviewCommentBtn.hidden = YES;
        self.commentOrderBtn.hidden = YES;
        
        
        if (![statusName isContainsString:@"取消"]) {
            self.bottomButtonsContainer.hidden = NO;
            self.scrollViewLastViewBottomConstraint.constant = 66;
            self.confirmAutosReturnBtn.hidden = YES;
            self.cancelOrderBtn.hidden = YES;
            self.reviewCommentBtn.hidden = YES;
            self.commentOrderBtn.hidden = YES;
            
            if ([statusName isContainsString:@"中"]) {
                self.allButtonsContainer.hidden = NO;
                self.confirmAutosReturnBtn.hidden = NO;
            }
            if ([statusName isContainsString:@"预约成功"]||[statusName isContainsString:@"接车"]) {
                self.allButtonsContainer.hidden = !self.orderWasPaid;
                self.appiontmentButtonsContainer.hidden = self.orderWasPaid;
                self.cancelOrderBtn.hidden = !self.orderWasPaid;
                self.countDownViewHeightConstraint.constant = (self.orderWasPaid?0:30);
            }
            if ([statusName isContainsString:@"完成"]) {
                self.allButtonsContainer.hidden = NO;
                self.commentOrderBtn.hidden = self.wasCommented;
                self.reviewCommentBtn.hidden = !self.wasCommented;
            }
        }
        
        UIImage *image = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:imageName ofType:@"png"]];
        self.statusIV.image = image;
//        NSString *statusPerfix = (self.orderWasRefunding?@"申请退款中":((self.orderWasPaid?@"已付款":@"未付款")));
        self.statusLabel.text = [paymentStatusName stringByAppendingFormat:@"-%@", statusName];
        
        
        [self updateConsultantDetail];
        
        [self updateUserDetail];
        
        [self updateServiceDetail];
        
        [self setupCountDown];
    }
}

- (void)updateConsultantDetail {
    [self.consultantDetailView setBorderWithColor:[UIColor colorWithRed:0.851 green:0.851 blue:0.851 alpha:1.00] borderWidth:0.5];
    [self.consultantDetailView setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:5.0f];
    
    
//        "car_time":0",
//        "commissionerName":张三",
//        "commissionerPhone":13142249956",
//        "distance":0,
//        "serve_num":0,
//        "service_fee":u 宿舍就是",
//        "star":5,
    
    self.consultantNameLabel.text = self.serviceDetail[@"commissionerName"];
    self.consultantPhoneLabel.text = [SupportingClass verifyAndConvertDataToString:self.serviceDetail[@"commissionerPhone"]];
    
    self.consultantDetailContainerView.hidden = NO;
    self.consultantDetailContainerViewTopConstraint.constant = 0;
    if ([self.consultantNameLabel.text isEqualToString:@""]&&
        [self.consultantPhoneLabel.text isEqualToString:@""]) {
        self.consultantDetailContainerView.hidden = YES;
        self.consultantDetailContainerViewTopConstraint.constant = -(CGRectGetHeight(self.consultantDetailContainerView.frame)-12.0f);
    }
    NSString *workingNum = [SupportingClass verifyAndConvertDataToString:self.serviceDetail[@"contract_no"]];
    if (!workingNum||[workingNum isEqualToString:@""]) workingNum = @"--";
    
    self.consultantWorkingNumLabel.text = [NSString stringWithFormat:@"工号 %@", workingNum];
    self.consultantRatingView.value = [SupportingClass verifyAndConvertDataToString:self.serviceDetail[@"star"]].floatValue;
    
    
    NSMutableAttributedString *serviceNumText = [NSMutableAttributedString new];
    [serviceNumText appendAttributedString:[[NSAttributedString alloc]
                                            initWithString:@"服务次数\n"
                                            attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"646464"],
                                                         NSFontAttributeName:[UIFont systemFontOfSize:9]}]];
    [serviceNumText appendAttributedString:[[NSAttributedString alloc]
                                            initWithString:[NSString stringWithFormat:@"%@次", [SupportingClass verifyAndConvertDataToString:self.serviceDetail[@"serve_num"]]]
                                            attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"323232"],
                                                         NSFontAttributeName:[UIFont systemFontOfSize:11]}]];
    self.consultantServiceNumLabel.attributedText = serviceNumText;
    
    
    NSMutableAttributedString *timeText = [NSMutableAttributedString new];
    [timeText appendAttributedString:[[NSAttributedString alloc]
                                            initWithString:@"时间\n"
                                            attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"646464"],
                                                         NSFontAttributeName:[UIFont systemFontOfSize:9]}]];
    [timeText appendAttributedString:[[NSAttributedString alloc]
                                            initWithString:[NSString stringWithFormat:@"%@分钟", [SupportingClass verifyAndConvertDataToString:self.serviceDetail[@"car_time"]]]
                                            attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"323232"],
                                                         NSFontAttributeName:[UIFont systemFontOfSize:11]}]];
    self.consultantTimeLabel.attributedText = timeText;
    
    
    NSMutableAttributedString *distanceText = [NSMutableAttributedString new];
    [distanceText appendAttributedString:[[NSAttributedString alloc]
                                            initWithString:@"距离\n"
                                            attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"646464"],
                                                         NSFontAttributeName:[UIFont systemFontOfSize:9]}]];
    [distanceText appendAttributedString:[[NSAttributedString alloc]
                                            initWithString:[NSString stringWithFormat:@"%@KM", [SupportingClass verifyAndConvertDataToString:self.serviceDetail[@"distance"]]]
                                            attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"323232"],
                                                         NSFontAttributeName:[UIFont systemFontOfSize:11]}]];
    self.consultantDistanceLabel.attributedText = distanceText;
    
    NSString *consultantImgURL = self.serviceDetail[@"face_img"];
    
    if ([consultantImgURL isContainsString:@"http"]) {
        [self.consultantPortrait setImageWithURL:[NSURL URLWithString:consultantImgURL] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    

}

- (void)updateUserDetail {
    [self.userDetailView setViewBorderWithRectBorder:UIRectBorderTop|UIRectBorderBottom borderSize:0.5f withColor:[UIColor colorWithRed:0.839 green:0.843 blue:0.863 alpha:1.00] withBroderOffset:nil];
    
    BorderOffsetObject *offset = [BorderOffsetObject new];
    offset.bottomLeftOffset = 12;
    [self.userDetailTitleLabel setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5f withColor:[UIColor colorWithRed:0.839 green:0.843 blue:0.863 alpha:1.00] withBroderOffset:offset];
    
    self.userNameLabel.text = self.serviceDetail[@"name"];
    self.userPhoneLabel.text = [SupportingClass verifyAndConvertDataToString:self.serviceDetail[@"phone"]];
    NSString *seriesName = self.serviceDetail[@"fctName"];
    NSString *modelName = self.serviceDetail[@"specName"];
    NSString *finalName = [seriesName stringByAppendingFormat:@" %@", modelName];
    if ([modelName isContainsString:seriesName]) {
        finalName = modelName;
    }
    self.userAutosLabel.text = finalName;
    
}

- (void)updateServiceDetail {
    switch (_serviceType) {
        case EServiceTypeOfERepair:
            self.dataList = @[@{@"title":@"接车地点：", @"contentKey":@"dropOffAddress", },
                              @{@"title":@"预约时间：", @"contentKey":@"appointmentTime"},
                              @{@"title":@"维修项目：", @"contentKey":@"serviceName"},
                              @{@"title":@"维修商：", @"contentKey":@"wxsName"},
                              @{@"title":@"维修商地址：", @"contentKey":@"wxsAddress"},];
            break;
            
        case EServiceTypeOfEInspect:
            self.dataList = @[@{@"title":@"接车地点：", @"contentKey":@"dropOffAddress", },
                              @{@"title":@"预约时间：", @"contentKey":@"appointmentTime"},
                              @{@"title":@"代检项目：", @"contentKey":@"serviceName"}];
            
            break;
            
        case EServiceTypeOfEInsurance:
            self.dataList = @[@{@"title":@"接车地点：", @"contentKey":@"dropOffAddress", },
                              @{@"title":@"事故类型：", @"contentKey":@"serviceName"}];
            
            break;
            
        default:
            break;
    }
    self.dropOffAddress = _serviceDetail[@"address"];
    if ([self.dropOffAddress isEqualToString:@""]||[self.dropOffAddress isEqualToString:@"暂无"]) self.dropOffAddress = @"--";
    self.appointmentTime = _serviceDetail[@"repairTime"];
    if ([self.appointmentTime isEqualToString:@""]||[self.appointmentTime isEqualToString:@"暂无"]) self.appointmentTime = @"--";
    
    self.serviceName = _serviceDetail[@"project"];
    if ([self.serviceName isEqualToString:@""]||[self.serviceName isEqualToString:@"暂无"]) self.serviceName = @"--";
    
    self.wxsName = _serviceDetail[@"wxsName"];
    if ([self.wxsName isEqualToString:@""]||[self.wxsName isEqualToString:@"暂无"]) self.wxsName = @"--";
    
    self.wxsAddress = _serviceDetail[@"wxs_address"];
    if ([self.wxsAddress isEqualToString:@""]||[self.wxsAddress isEqualToString:@"暂无"]) self.wxsAddress = @"--";
    
    [self.tableView reloadData];
}

- (void)componentSetting {
    @autoreleasepool {
        self.navShouldPopOtherVC = YES;
        
        UINib *nib = [UINib nibWithNibName:@"EServiceDataCell" bundle:nil];
        [self.tableView registerNib:nib forCellReuseIdentifier:@"cell"];
        self.clockIV.image = [self.clockIV.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 30;
        
        if (!self.serviceDetail||self.serviceDetail.count==0) {
            [self getEServiceDetail];
        }
        
        [self.bottomButtonsContainer.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull firstView, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([firstView isKindOfClass:UIButton.class]) {
                [firstView setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:5.0f];
            }
            if ([firstView isKindOfClass:UIView.class]) {
                [firstView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull secondView, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([secondView isKindOfClass:UIButton.class]) {
                        [secondView setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:5.0f];
                    }
                }];
            }

        }];
    }
    
}

- (void)setReactiveRules {
    @weakify(self);
    [RACObserve(self, tableView.contentSize) subscribeNext:^(id size) {
        @strongify(self);
        CGSize contentSize = [size CGSizeValue];
        self.tableViewHeight.constant = contentSize.height;
        [self.tableView setNeedsUpdateConstraints];
        [self.view setNeedsLayout];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupCountDown {
    NSString *statusName = self.serviceDetail[@"state"];
    if (!self.orderWasPaid&&!self.orderWasRefunding&&self.serviceDetail.count>0&&![statusName isContainsString:@"取消"]) {
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
}

- (void)countDown {
    if (self.currentCountDown<=0) {
        if ([self.timer isValid]) {
            [self.timer invalidate];
        }
        self.timer = nil;
        [EServiceAutoCancelApointmentObject cancelServiceCancelRecordByServiceType:self.serviceType];
        [self autoCancelEService:self.eServiceID];
        return;
    }
    self.currentCountDown--;
    NSInteger minute = self.currentCountDown/60;
    NSInteger secound = (NSInteger)self.currentCountDown%60;
    self.timeLabel.text = [NSString stringWithFormat:@"%02d:%02d", minute, secound];
}

- (void)autoCancelEService:(NSString *)eServiceID {
    if (!self.accessToken) {
        return;
    }
    [APIsConnection.shareConnection personalCenterAPIsPostEServiceCancelServiceWithAccessToken:self.accessToken eServiceID:eServiceID isAutoCancel:YES success:^(NSURLSessionDataTask *operation, id responseObject) {
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        [self getEServiceDetail];
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        NSLog(@"%@",error);
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
    
    NSString *contentKey = detail[@"contentKey"];
    cell.contentLabel.text = [self valueForKeyPath:contentKey];
    [cell layoutIfNeeded];
    return cell;
}

- (IBAction)dailACall {
    if ([self.serviceDetail[@"commissionerPhone"] isEqualToString:@""]||!self.serviceDetail[@"commissionerPhone"]) {
        [SupportingClass showAlertViewWithTitle:@"" message:@"此案例暂无提供维修商电话" isShowImmediate:YES cancelButtonTitle:nil otherButtonTitles:nil clickedButtonAtIndexWithBlock:nil];
    }else {
        [SupportingClass makeACall:self.serviceDetail[@"commissionerPhone"]];
    }
}

- (IBAction)pushToPaymentVC {
    @autoreleasepool {
        EServicePaymentVC *vc = [EServicePaymentVC new];
        vc.serviceType = self.serviceType;
        vc.eServiceID = self.eServiceID;
        vc.creditsRatio = self.creditsRatio;
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)pushToWriteComment {
    [self pushToCommentViewAndCommentDisplayOnly:NO withFaceImgStr:self.serviceDetail[@"face_img"]];
}

- (IBAction)pushToDisplayComment {
    [self pushToCommentViewAndCommentDisplayOnly:YES withFaceImgStr:self.serviceDetail[@"face_img"]];
}

- (void)pushToCommentViewAndCommentDisplayOnly:(BOOL)commentDisplayOnly withFaceImgStr:(NSString *)faceImg{
    @autoreleasepool {
        MyEServiceComment *vc = [MyEServiceComment new];
        vc.commentDisplayOnly = commentDisplayOnly;
        vc.eServiceID = self.eServiceID;
        vc.carImagString=faceImg;
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)cancelEService {
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    @weakify(self);
    [ProgressHUDHandler showHUD];
    
    [APIsConnection.shareConnection personalCenterAPIsPostEServiceCancelServiceWithAccessToken:self.accessToken eServiceID:self.eServiceID isAutoCancel:NO success:^(NSURLSessionDataTask *operation, id responseObject) {
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
        
        [ProgressHUDHandler dismissHUD];
        [self getEServiceDetail];
        
        
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

- (IBAction)confirmVehiceDropOff {
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    @weakify(self);
    [ProgressHUDHandler showHUD];
    
    [APIsConnection.shareConnection personalCenterAPIsPostEServiceConfirmVehicleWasReturnWithAccessToken:self.accessToken eServiceID:self.eServiceID success:^(NSURLSessionDataTask *operation, id responseObject) {
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
        
        [ProgressHUDHandler dismissHUD];
        [self getEServiceDetail];
        
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

- (void)getEServiceDetail {
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    @weakify(self);
    [ProgressHUDHandler showHUD];
    
    [APIsConnection.shareConnection personalCenterAPIsGetEServiceDetailWithAccessToken:self.accessToken eServiceID:self.eServiceID success:^(NSURLSessionDataTask *operation, id responseObject) {
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
        
        [ProgressHUDHandler dismissHUD];
        self.serviceDetail = responseObject[CDZKeyOfResultKey];
        [self updateAllUIData];
        
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

- (void)handleNavBackBtnPopOtherAction {
    @autoreleasepool {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.class == %@", EServiceServiceListVC.class];
        NSArray *result = [self.navigationController.viewControllers filteredArrayUsingPredicate:predicate];
        if (result&&result.count>0) {
            [self.navigationController popToViewController:result.lastObject animated:YES];
            return;
        }
        
        EServiceServiceListVC *vc = EServiceServiceListVC.new;
        vc.serviceType = self.serviceType;
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
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
