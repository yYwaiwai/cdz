//
//  OBDDiagnosisVC.m
//  cdzer
//
//  Created by KEns0n on 6/1/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//
#import "OBDCell.h"
#import "OBDDiagnosisVC.h"
#import "FaultDto.h"
#import "OBDDto.h"

@interface OBDDiagnosisVC ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *arry_menu;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, assign) NSInteger position;

@property (nonatomic, assign) BOOL isFinish;


@property (nonatomic, strong) UIView *headView;
@property (nonatomic, strong) UIView *tagView;
@property (nonatomic, strong) UIImageView *tagImg;

@property (nonatomic, strong) UIView *reConView;
@property (nonatomic, strong) UILabel *reConLa;

@property (nonatomic, strong) NSTimer *obdCheckTimer;
@property (nonatomic, strong) NSTimer *bdCheckViewTimer;

@end

@implementation OBDDiagnosisVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"故障检测";
    [self setReactiveRules];
    [self componentSetting];
    [self initializationUI];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self getOBDDiagnosisResult];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setReactiveRules {
    
}

- (void)componentSetting {
    self.position = 0 ;
    self.arry_menu = @[@"燃油和进气相关系统",@"点火相关系统",@"排放控制相关系统",@"车速及怠速控制相关系统",@"发动机或控制电脑相关系统",@"变速箱相关系统",@"其它动力相关系统",@"车辆实况"];
}

- (void)initializationUI {
    CGRect viewRect = self.contentView.bounds;
    viewRect.size.height = 340;
    UIView *viewContainer = [[UIView alloc] initWithFrame:viewRect];
    viewContainer.center = CGPointMake(CGRectGetWidth(self.contentView.frame)/2.0f, viewContainer.center.y);
    viewContainer.clipsToBounds = YES;
    [self.contentView addSubview:viewContainer];
    
    CGRect reConViewRect = self.contentView.bounds;;
    reConViewRect.size.height = 305;
    reConViewRect.origin.y = -250;
    self.reConView = [[UIView alloc] initWithFrame:reConViewRect];
    [viewContainer addSubview:_reConView];
    
    UIImageView *reContentImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(viewRect), 304)];
    [reContentImg setImage:[UIImage imageNamed:@"c_result_content.png"]];
    [_reConView addSubview:reContentImg];
    
    self.reConLa = [[UILabel alloc] initWithFrame:CGRectMake(37, 199, 246, 21)];
    _reConLa.text = @"检测无异常现象,建议定期检测";
    _reConLa.font = systemFontBoldWithoutRatio(15.0f);
    _reConLa.textAlignment = NSTextAlignmentCenter;
    [_reConView addSubview:_reConLa];
    
    UIButton *recheckBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    recheckBtn.frame = CGRectMake(47, 236, 226, 35);
    recheckBtn.tag = 100;
    recheckBtn.layer.cornerRadius = 6.0f;
    recheckBtn.layer.masksToBounds = YES;
    [recheckBtn setTitle:@"重新检测" forState:UIControlStateNormal];
    [recheckBtn setBackgroundImage:[ImageHandler createImageWithColor:[UIColor colorWithRed:0.992f green:0.620f blue:0.216f alpha:1.00f]
                                                             withSize:recheckBtn.bounds.size] forState:UIControlStateNormal];
    [recheckBtn addTarget:self action:@selector(menuClickEvent:) forControlEvents:UIControlEventTouchUpInside];
    [_reConView addSubview:recheckBtn];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(22, 5, 280, 21)];
    title.text = @"检测结果";
    title.font = systemFontBoldWithoutRatio(15.0f);
    title.textColor = [UIColor colorWithRed:0.169f green:0.678f blue:0.925f alpha:1.00f];
    [title setViewBorderWithRectBorder:UIRectBorderBottom borderSize:1 withColor:title.textColor withBroderOffset:nil];
    [_reConView addSubview:title];
    
    
    UIView *cResultImgView = [[UIView alloc] initWithFrame:CGRectMake(0, 11, CGRectGetWidth(viewRect), 30)];
    [cResultImgView setBackgroundImageByCALayerWithImage:[UIImage imageNamed:@"c_result_bg.png"]];
    [viewContainer addSubview:cResultImgView];
    UIView *maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(viewRect), 15)];
    maskView.backgroundColor = CDZColorOfWhite;
    [viewContainer addSubview:maskView];
    
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    CGRect scanViewRect = self.contentView.bounds;
    scanViewRect.size.height = 130;
    self.headView = [[UIView alloc] initWithFrame:scanViewRect];
    [_headView setBackgroundImageByCALayerWithImage:[UIImage imageNamed:@"c_bg.png"]];
    _headView.center = CGPointMake(CGRectGetWidth(self.contentView.frame)/2.0f, _headView.center.y);
    [self.contentView addSubview:_headView];
    
    UIImageView *carImg = [[UIImageView alloc] initWithFrame:CGRectMake(46, 28, 228, 76)];
    [carImg setImage:[UIImage imageNamed:@"c_car_n.png"]];
    [_headView addSubview:carImg];
    
    
    self.tagView = [[UIView alloc] initWithFrame:CGRectMake(45, 20, 1, 91)];
    _tagView.clipsToBounds = YES;
    [_headView addSubview:_tagView];
    
    UIImageView *tagInsideImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 8, 229, 76)];
    [tagInsideImg setImage:[UIImage imageNamed:@"c_car_r.png"]];
    [_tagView addSubview:tagInsideImg];
    
    self.tagImg = [[UIImageView alloc] initWithFrame:CGRectMake(31, 0.0, 20, CGRectGetHeight(scanViewRect))];
    [_tagImg setImage:[UIImage imageNamed:@"c_check_tag.png"]];
    [_headView addSubview:_tagImg];

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    CGRect tbRect = self.contentView.bounds;
    tbRect.origin.y = CGRectGetMaxY(scanViewRect);
    tbRect.size.height = CGRectGetHeight(tbRect)-CGRectGetMaxY(scanViewRect);//*0.5875f;
    self.tableView = [[UITableView alloc] initWithFrame:tbRect];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.userInteractionEnabled = NO;
    [self.contentView addSubview:_tableView];
}


#pragma mark -检测结果菜单按钮
- (void)menuClickEvent:(id)sender {
    UIButton *btn = (UIButton *)sender ;
    NSInteger tagValue = btn.tag ;
    /*
     * 100 重新检测
     * 101 查看详情
     */
    switch (tagValue) {
        case 100:{
            //进行视图的隐藏
            self.tableView.contentOffset = CGPointMake(0.0f, 0.0f);
            self.tableView.hidden = NO ;
            self.headView.hidden = NO ;
            self.position = 0 ;
            [self.tableView reloadData];
            self.reConView.frame = CGRectMake(0, -250, self.reConView.frame.size.width, self.reConView.frame.size.height);
            [self getOBDDiagnosisResult];
        }
            break;
            
        case 101:{
//            SecurityInfoViewController *secInfoCon = [[SecurityInfoViewController alloc] init];
//            [self.navigationController pushViewController:secInfoCon animated:YES];
        }
            break;
    }
}

#pragma mark -数据内容的清空
- (void)clearTableViewData {
    self.arry_menu = @[];
    [self.tableView reloadData];
    self.arry_menu = @[@"燃油和进气相关系统",@"点火相关系统",@"排放控制相关系统",@"车速及怠速控制相关系统",@"发动机或控制电脑相关系统",@"变速箱相关系统",@"其它动力相关系统",@"车辆实况"];
}

#pragma mark -启动检测功能
- (void)startCheckOBD {
    //启动一个定时器来进行检测的效果
    self.obdCheckTimer = [NSTimer scheduledTimerWithTimeInterval:0.8 target:self selector:@selector(obdCheck:) userInfo:nil repeats:YES];
    
    //启动一个定时器控制检测效果
    self.bdCheckViewTimer = [NSTimer scheduledTimerWithTimeInterval:0.009 target:self selector:@selector(obdCheckView:) userInfo:nil repeats:YES];
}

- (void)obdCheck:(id)sender {
    self.position ++ ;
    [self.tableView reloadData];
    if (_position!=_arry_menu.count) {
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_position inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
    if((self.position+1) >[self.arry_menu count]){
        NSTimer *timer = (NSTimer *)sender;
        [timer invalidate];
        //进行视图的隐藏
        self.tableView.hidden = YES ;
        self.headView.hidden = YES ;
        @weakify(self);
        [UIView animateWithDuration:1 animations:^{
            self.reConView.frame = CGRectMake(0, 40, self.reConView.frame.size.width, self.reConView.frame.size.height);
        }completion:^(BOOL finished) {
            @strongify(self);
            if ([self.obdCheckTimer isValid]) {
                [self.obdCheckTimer invalidate];
                self.obdCheckTimer = nil;
            }
            if ([self.bdCheckViewTimer isValid]) {
                [self.bdCheckViewTimer invalidate];
                self.bdCheckViewTimer = nil;
            }
            
        }];
    }
}

- (void)obdCheckView:(id)sender {
    NSInteger width = self.tagView.frame.size.width ;
    if(width>=228){
        self.isFinish = YES ;
    }else if(width == 0){
        self.isFinish = NO ;
    }
    if(self.isFinish){
        width -- ;
        self.tagImg.frame = CGRectMake(self.tagImg.frame.origin.x-1 , self.tagImg.frame.origin.y, self.tagImg.frame.size.width, self.tagImg.frame.size.height);
    }else{
        width ++ ;
        self.tagImg.frame = CGRectMake(self.tagImg.frame.origin.x+1 , self.tagImg.frame.origin.y, self.tagImg.frame.size.width, self.tagImg.frame.size.height);
    }
    
    self.tagView.frame = CGRectMake(self.tagView.frame.origin.x, self.tagView.frame.origin.y, width, self.tagView.frame.size.height);
}

#pragma -mark UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return _arry_menu.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    OBDCell *cell = [tableView dequeueReusableCellWithIdentifier:CDZKeyOfCellIdentKey];
    if(cell == nil){
        cell = [[OBDCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CDZKeyOfCellIdentKey];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.textLabel.text = [self.arry_menu objectAtIndex:indexPath.row];
    cell.textLabel.font = [SupportingClass boldAndSizeFont:15];
    cell.isChecked = (self.position > indexPath.row);
    
    return cell ;
}

#pragma mark- APIs Access Request
- (void)getOBDDiagnosisResult {
    if (!self.accessToken) {return;}
    [self setReloadFuncWithAction:_cmd parametersList:nil];
    [ProgressHUDHandler showHUDWithTitle:@"系统初始化中..." onView:nil];
    [[APIsConnection shareConnection] personalGPSAPIsGetAutoOBDDiagnosisWithAccessToken:self.accessToken success:^(NSURLSessionDataTask *operation, id responseObject) {
        [self requestResultHandle:operation responseObject:responseObject withError:nil];
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        [self requestResultHandle:operation responseObject:nil withError:error];
    }];
    
}

#pragma mark -网络请求OBD数据内容
- (void)handleResponseData:(id)responseObject {
    @autoreleasepool {
        if (!responseObject||[responseObject count]==0) {
            NSLog(@"data Error");
            return;
        }
        [ProgressHUDHandler dismissHUD];
        [self startCheckOBD];
        NSString* j_score = [responseObject objectForKey:@"score"];
        OBDDto* dto = [OBDDto new];
        dto.score=j_score;
        
        NSMutableArray* faults = [NSMutableArray new];
        NSArray* resultArray = [responseObject objectForKey:CDZKeyOfResultKey];
        for (NSDictionary* tmp in resultArray) {
            NSString* j_code = [tmp objectForKey:@"code"];
            NSString* j_type = [tmp objectForKey:@"type"];
            NSString* j_analyse = [tmp objectForKey:@"analyse"];
            NSString* j_suggest = [tmp objectForKey:@"suggest"];
            NSString* j_remark = [tmp objectForKey:@"remark"];
            
            FaultDto* fdto = [FaultDto new];
            fdto.itemCode=j_code;
            fdto.itemType=j_type;
            fdto.itemAnayse=j_analyse;
            fdto.itemAdvice=j_suggest;
            fdto.itemName=j_remark;
            fdto.remark=j_remark;
            [faults addObject:fdto];
        }
        dto.faults = faults;

        if(dto.faults != nil && [dto.faults count]>0){
            self.reConLa.textColor = [UIColor redColor];
            self.reConLa.text = [[dto.faults objectAtIndex:0] remark];
        }else{
            self.reConLa.textColor = [UIColor blackColor];
            self.reConLa.text = @"检测无异常现象,建议定期检测";
        }
        
    }
}

- (void)requestResultHandle:(NSURLSessionDataTask *)operation responseObject:(id)responseObject withError:(NSError *)error {
    
    if (error&&!responseObject) {
        NSLog(@"%@",error);
        [ProgressHUDHandler showErrorWithStatus:@"系统初始化失败" onView:nil completion:^{
            
        }];
    }else if (!error&&responseObject) {
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        switch (errorCode) {
            case 0:
                [self handleResponseData:responseObject[CDZKeyOfResultKey]];
                break;
            case 1:
            case 2:{
                [SupportingClass showAlertViewWithTitle:@"error" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                    if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {return;}
                }];
            }
                break;
                
            default:
                break;
        }
        
    }
    
}

- (void)handleUserLoginResult:(BOOL)isSuccess fromAlert:(BOOL)fromAlert{
    if (isSuccess) {
        if (UserBehaviorHandler.shareInstance.getUserType!=CDZUserTypeOfGPSWithODBUser) {
            [SupportingClass showAlertViewWithTitle:nil message:@"登陆的账号并没有绑定GPS或不ODB功能，请重新登录已绑定含ODB功能的GPS账号" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                [self.navigationController popToRootViewControllerAnimated:YES];
            }];
            return;
        }
        NSLog(@"success reload function %d", [self executeReloadFunction]);
    }else {
        [self.navigationController popToRootViewControllerAnimated:YES];
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
