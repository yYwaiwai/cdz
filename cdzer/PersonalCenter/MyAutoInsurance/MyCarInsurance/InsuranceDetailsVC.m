//
//  InsuranceDetailsVC.m
//  cdzer
//
//  Created by 车队长 on 16/12/30.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "InsuranceDetailsVC.h"
#import "DocumentPhotoDisplayView.h"
#import "TypeOfInsuranceCell.h"
#import "MyCarInsuranceApplyFormVC.h"
#import "PaymentCenterVC.h"
#import "MyCarInsuranceVC.h"

@interface InsuranceDetailsVC ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *headTitleLabel;

@property (weak, nonatomic) IBOutlet UIView *insuranceCompanyBGView;
@property (weak, nonatomic) IBOutlet UILabel *insuranceCompanyLabel;//保险公司

@property (weak, nonatomic) IBOutlet UILabel *insuranceCityLabel;//投保城市

@property (weak, nonatomic) IBOutlet UITableView *insuranceTabelView;//险

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *insuranceTabelViewLayoutConstraint;

////////
@property (weak, nonatomic) IBOutlet UIView *ownerMessageBGView;
@property (weak, nonatomic) IBOutlet UILabel *ownerNameLabel;//车主姓名

@property (weak, nonatomic) IBOutlet UIView *contactNumberBGView;
@property (weak, nonatomic) IBOutlet UILabel *contactNumberLabel;//联系电话

@property (weak, nonatomic) IBOutlet UIView *carMessageBGView;
@property (weak, nonatomic) IBOutlet UILabel *vehicleSystemLabel;//车型车系

@property (weak, nonatomic) IBOutlet UILabel *carNumberLabel;//车牌号

@property (weak, nonatomic) IBOutlet UILabel *frameNumberLabel;//车架号

@property (weak, nonatomic) IBOutlet UILabel *engineNumberLabel;//发动机号

@property (weak, nonatomic) IBOutlet UIView *dateOfRegistrationBGView;
@property (weak, nonatomic) IBOutlet UILabel *dateOfRegistrationLabel;//注册登记日期

@property (weak, nonatomic) IBOutlet UIControl *IDPhotoControl;// 身份证照片

@property (weak, nonatomic) IBOutlet UIControl *drivingLicensePhotoControl;//行驶证照片

@property (strong, nonatomic) IBOutlet DocumentPhotoDisplayView *documentPhotoDisplayView;


@property (weak, nonatomic) IBOutlet UIView *orderNumberBGView;
@property (weak, nonatomic) IBOutlet UILabel *orderNumberLabel;//订单号

@property (weak, nonatomic) IBOutlet UIView *orderTimeBGView;
@property (weak, nonatomic) IBOutlet UILabel *orderTimeLabel;//下单时间


@property (nonatomic, strong) UIView *buttonBGView;
@property (nonatomic, strong) UIButton *deatilsButton;

@property (nonatomic, strong) NSMutableArray *strongInsuranceArr;//交强险 险种

@property (nonatomic, strong) NSMutableArray *commercialInsuranceArr;//商业险  险种

@property (nonatomic, strong) NSDictionary *reAppointDic;

@end

@implementation InsuranceDetailsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title=@"保险详情";
    [[UINib nibWithNibName:@"DocumentPhotoDisplayView" bundle:nil] instantiateWithOwner:self options:nil];
    [self initializationUI];
    [self componentSetting];
}

- (void)handleNavBackBtnPopOtherAction {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.class == %@", MyCarInsuranceVC.class];
    NSArray *result = [self.navigationController.viewControllers filteredArrayUsingPredicate:predicate];
    if (result&&result.count>0) {
        [self.navigationController popToViewController:result.lastObject animated:YES];
        return;
    }
    
    MyCarInsuranceVC *vc = MyCarInsuranceVC.new;
    [self setDefaultNavBackButtonWithoutTitle];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)componentSetting {
    @autoreleasepool {
        self.navShouldPopOtherVC = YES;
    }
}

-(void)viewDidLayoutSubviews
{
    BorderOffsetObject *offset = [BorderOffsetObject new];
    offset.rightUpperOffset = 8;
    offset.rightBottomOffset = offset.rightUpperOffset;
    [self.insuranceCompanyLabel setViewBorderWithRectBorder:UIRectBorderRight borderSize:0.5 withColor:nil withBroderOffset:offset];
    
    [self.insuranceCompanyBGView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self.ownerMessageBGView setViewBorderWithRectBorder:UIRectBorderBottom|UIRectBorderTop borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self.contactNumberBGView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self.carMessageBGView setViewBorderWithRectBorder:UIRectBorderBottom|UIRectBorderTop borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self.dateOfRegistrationBGView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self.IDPhotoControl setViewBorderWithRectBorder:UIRectBorderBottom|UIRectBorderTop borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self.drivingLicensePhotoControl setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self.orderNumberBGView setViewBorderWithRectBorder:UIRectBorderTop borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self.orderTimeBGView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self.buttonBGView setViewBorderWithRectBorder:UIRectBorderTop borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self.deatilsButton setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:4.0f];
    
    self.buttonBGView.frame=CGRectMake(0, CGRectGetHeight(self.view.frame)-66, CGRectGetWidth(self.view.frame), 66);
    self.deatilsButton.frame=CGRectMake(12, 11, CGRectGetWidth(self.view.frame)-24, 43);
//    NSLog(@"%@", NSStringFromCGRect(self.buttonBGView.frame));
}

- (void)initializationUI
{
    
    self.strongInsuranceArr=[NSMutableArray new];
    self.commercialInsuranceArr=[NSMutableArray new];
    
    self.insuranceTabelView.rowHeight = UITableViewAutomaticDimension;
    self.insuranceTabelView.estimatedRowHeight = 31.0f;
    self.insuranceTabelView.tableFooterView=[UIView new];
    self.insuranceTabelView.backgroundColor=self.view.backgroundColor;
    self.insuranceTabelView.showsVerticalScrollIndicator = NO;
    
    self.buttonBGView=[[UIView alloc]init];
    self.buttonBGView.backgroundColor=CDZColorOfWhite;
    [self.view insertSubview:self.buttonBGView atIndex:10];
    self.deatilsButton=[[UIButton alloc]init];
    self.deatilsButton.backgroundColor=[UIColor colorWithHexString:@"49c7f5"];
    self.deatilsButton.titleLabel.textColor=CDZColorOfWhite;
    self.deatilsButton.titleLabel.font=[UIFont systemFontOfSize:14];
    [self.buttonBGView addSubview:self.deatilsButton];
    
    
    UINib*nib=[UINib nibWithNibName:@"TypeOfInsuranceCell" bundle:nil];
    [self.insuranceTabelView registerNib:nib forCellReuseIdentifier:@"TypeOfInsuranceCell"];
    
    
    
    if ([self.detailDic[@"state"] isEqualToString:@"预约失败"]||[self.detailDic[@"state"] isEqualToString:@"已预约"]||[self.detailDic[@"state"] isEqualToString:@"已过期"]) {
        if ([self.detailDic[@"state"] isEqualToString:@"已过期"]) {
            self.headTitleLabel.text=[NSString stringWithFormat:@"%@\n%@",self.detailDic[@"sum"],self.detailDic[@"state"]];
        }
         self.headTitleLabel.text=[NSString stringWithFormat:@"%@\n%@",self.detailDic[@"state"],self.detailDic[@"hint"]];
        if ([self.detailDic[@"state"] isEqualToString:@"预约失败"]) {
            self.headTitleLabel.text=[NSString stringWithFormat:@"%@\n点击查看原因",self.detailDic[@"state"]];
             UITapGestureRecognizer *labelTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelClick)];
            [self.headTitleLabel addGestureRecognizer:labelTapGestureRecognizer];
            
        }
    }else{

        self.headTitleLabel.text=[NSString stringWithFormat:@"%@\n%@\n%@",[NSString stringWithFormat:@"￥%@",self.detailDic[@"sum"]],self.detailDic[@"state"],self.detailDic[@"hint"]];
        if ([self.detailDic[@"state"] isEqualToString:@"等待出单"]) {
            self.headTitleLabel.text=[NSString stringWithFormat:@"%@\n%@\n支付成功",[NSString stringWithFormat:@"￥%@",self.detailDic[@"sum"]],self.detailDic[@"state"]];
        }
    }
    self.insuranceCompanyLabel.text=self.detailDic[@"company"];
    self.insuranceCityLabel.text=self.detailDic[@"city"];
    self.ownerNameLabel.text=self.detailDic[@"real_name"];
    self.contactNumberLabel.text=self.detailDic[@"phone_no"];
    self.orderNumberLabel.text=self.detailDic[@"pid"];
    self.orderTimeLabel.text=self.detailDic[@"appoint_time"];
    
    NSDictionary *carInfo=self.detailDic[@"car_info"];
    self.vehicleSystemLabel.text=carInfo[@"speci_name"];
    self.carNumberLabel.text=carInfo[@"car_number"];
    self.frameNumberLabel.text=carInfo[@"frame_no"];
    self.engineNumberLabel.text=carInfo[@"engine_code"];
    self.dateOfRegistrationLabel.text=carInfo[@"register_time"];
    
    NSArray *insureInfoArr=self.detailDic[@"insure_info"];
    NSMutableArray *strongInsuranceArr=[NSMutableArray new];
    NSMutableArray *commercialInsuranceArr=[NSMutableArray new];
    for (NSDictionary *obj in insureInfoArr) {
        NSString *mainType=obj[@"main_type"];
        if ([mainType isEqualToString:@"交强险"]) {
            [strongInsuranceArr addObject:obj];
            }
        if ([mainType isEqualToString:@"商业险"]) {
            [commercialInsuranceArr addObject:obj];


        }
    }
    self.strongInsuranceArr=[NSMutableArray arrayWithArray:strongInsuranceArr];
    self.commercialInsuranceArr=[NSMutableArray arrayWithArray:commercialInsuranceArr];
    if (self.strongInsuranceArr.count>0&&self.commercialInsuranceArr.count==0) {
        if ([self.detailDic[@"state"] isEqualToString:@"预约失败"]||[self.detailDic[@"state"] isEqualToString:@"已预约"]) {
            self.insuranceTabelViewLayoutConstraint.constant=self.strongInsuranceArr.count*31+43;
        }else{
            self.insuranceTabelViewLayoutConstraint.constant=self.strongInsuranceArr.count*31+76;
        }
     }
    if (self.commercialInsuranceArr.count>0&&self.strongInsuranceArr.count==0) {
        
        if ([self.detailDic[@"state"] isEqualToString:@"预约失败"]||[self.detailDic[@"state"] isEqualToString:@"已预约"]) {
            self.insuranceTabelViewLayoutConstraint.constant=self.commercialInsuranceArr.count*31+43;
        }else{
            self.insuranceTabelViewLayoutConstraint.constant=self.commercialInsuranceArr.count*31+76;
        }
    }
    if (self.commercialInsuranceArr.count>0&&self.strongInsuranceArr.count>0) {
        if ([self.detailDic[@"state"] isEqualToString:@"预约失败"]||[self.detailDic[@"state"] isEqualToString:@"已预约"]) {
            self.insuranceTabelViewLayoutConstraint.constant=(self.commercialInsuranceArr.count+self.strongInsuranceArr.count)*31+86;
        }else{
            self.insuranceTabelViewLayoutConstraint.constant=(self.commercialInsuranceArr.count+self.strongInsuranceArr.count)*31+86+66;
        }
        
    }
    if ([self.detailDic[@"state"] isEqualToString:@"预约失败"]||[self.detailDic[@"state"] isEqualToString:@"预约成功"]) {
        self.buttonBGView.hidden=NO;
        self.deatilsButton.hidden=NO;
        if ([self.detailDic[@"state"] isEqualToString:@"预约失败"]) {
            [self.deatilsButton setTitle:@"重新预约" forState:UIControlStateNormal];
            [self.deatilsButton addTarget:self action:@selector(reAppointmentClick) forControlEvents:UIControlEventTouchUpInside];
        }
        if ([self.detailDic[@"state"] isEqualToString:@"预约成功"]) {
            [self.deatilsButton setTitle:@"立即支付" forState:UIControlStateNormal];
            [self.deatilsButton addTarget:self action:@selector(payImmediatelyClick) forControlEvents:UIControlEventTouchUpInside];
        }
    }else{
        self.buttonBGView.hidden=YES;
        self.deatilsButton.hidden=YES;
    }

 }

- (void)labelClick {
    NSString *hintStr=self.detailDic[@"hint"];
    [SupportingClass showAlertViewWithTitle:@"失败原因" message:hintStr isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:nil];
    
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ident=@"TypeOfInsuranceCell";
    TypeOfInsuranceCell*cell=(TypeOfInsuranceCell*)[tableView dequeueReusableCellWithIdentifier:ident];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    NSDictionary *detail;
    if (indexPath.section==0) {
        if (self.strongInsuranceArr.count>0) {
            detail=self.strongInsuranceArr[indexPath.row];
            cell.titleLabel.text=detail[@"coverage_type"];
        }
    }
    
    else {
        if (self.commercialInsuranceArr.count>0) {
            
            NSMutableArray*allTypeArr=[NSMutableArray new];
            NSMutableArray*bujiTypeArr=[NSMutableArray new];
            NSMutableArray*unBujiTypeArr=[NSMutableArray new];
            for (NSDictionary *dic in self.commercialInsuranceArr) {
                NSString *coverageType=dic[@"coverage_type"];
                if ([coverageType containsString:@"不计免赔"]) {
                    [bujiTypeArr addObject:dic];
                    
                }
                else{
                    [unBujiTypeArr addObject:dic];
                }
            }
            
            [allTypeArr addObjectsFromArray:unBujiTypeArr];
            [allTypeArr addObjectsFromArray:bujiTypeArr];
            detail=allTypeArr[indexPath.row];
            
        }
        cell.titleLabel.text=detail[@"coverage_type"];
    }
    
    
    [cell upDataUIDetail:detail];
    return cell;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section==0) {
        if (self.strongInsuranceArr.count>0) {
            return self.strongInsuranceArr.count;
        }else{
            return 0;
        }
    }else  {
        if (self.commercialInsuranceArr.count>0) {
            return self.commercialInsuranceArr.count;
        }else{
            return 0;
        }
        
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section==0) {
        if (self.strongInsuranceArr.count>0) {
            return 43;
        }else{
            return 0;
        }
    }else  {
        if (self.commercialInsuranceArr.count>0) {
            return 43;
        }else{
            return 0;
        }
        
    }
    
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *insuranceHeadView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 43)];
    insuranceHeadView.backgroundColor=[UIColor colorWithHexString:@"f5f5f5"];
    UIView *insuranceTitleView=[[UIView alloc]initWithFrame:CGRectMake(0, 10, CGRectGetWidth(self.view.frame), 33)];
    insuranceTitleView.backgroundColor=CDZColorOfWhite;
    [insuranceHeadView addSubview:insuranceTitleView];
    [insuranceTitleView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    UIView *lineView=[[UIView alloc]initWithFrame:CGRectMake(12, 9, 2, 16)];
    lineView.backgroundColor=[UIColor colorWithHexString:@"50c8f3"];
    [insuranceTitleView addSubview:lineView];
    
    UILabel *titleLabel=[[UILabel alloc]initWithFrame:CGRectMake(24, 0, 44, 33)];
    titleLabel.textColor=[UIColor colorWithHexString:@"323232"];
    titleLabel.font=[UIFont systemFontOfSize:14];
    [insuranceTitleView addSubview:titleLabel];
    
    UILabel *timeLabel=[[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(titleLabel.frame), 0, 98, 33)];
    timeLabel.textColor=[UIColor colorWithHexString:@"646464"];
    timeLabel.font=[UIFont systemFontOfSize:13];
    [insuranceTitleView addSubview:timeLabel];
    
    UILabel *commercialInsuranceWithpolicyNumberLabel=[[UILabel alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)-170, 0, 165, 33)];
    commercialInsuranceWithpolicyNumberLabel.textColor=[UIColor colorWithHexString:@"646464"];
    commercialInsuranceWithpolicyNumberLabel.font=[UIFont systemFontOfSize:13];
    [insuranceTitleView addSubview:commercialInsuranceWithpolicyNumberLabel];
    commercialInsuranceWithpolicyNumberLabel.textAlignment=NSTextAlignmentRight;
    if (section==0) {
        titleLabel.text=@"交强险";
        timeLabel.text=[NSString stringWithFormat:@"(%@)",self.strongInsuranceArr.lastObject[@"start_time"]];
        if (![self.strongInsuranceArr.lastObject[@"insurance_no"] isEqualToString:@""]) {
            commercialInsuranceWithpolicyNumberLabel.text=[NSString stringWithFormat:@"保单号%@",self.strongInsuranceArr.lastObject[@"insurance_no"]];
        }
        
    }else{
        titleLabel.text=@"商业险";
        timeLabel.text=[NSString stringWithFormat:@"(%@)",self.commercialInsuranceArr.lastObject[@"start_time"]];
        if (![self.commercialInsuranceArr.lastObject[@"insurance_no"] isEqualToString:@""]) {
            commercialInsuranceWithpolicyNumberLabel.text=[NSString stringWithFormat:@"保单号%@",self.commercialInsuranceArr.lastObject[@"insurance_no"]];
        }
        
    }
    
    return insuranceHeadView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if ([self.detailDic[@"state"] isEqualToString:@"预约失败"]||[self.detailDic[@"state"] isEqualToString:@"已预约"]) {
        return 0;
    }else{
        if (section==0) {
            if (self.strongInsuranceArr.count>0) {
                return 33;
            }else{
                return 0;
            }
        }else  {
            if (self.commercialInsuranceArr.count>0) {
                return 33;
            }else{
                return 0;
            }
            
        }
    }

    
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *insuranceFootView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 33)];
    insuranceFootView.backgroundColor=CDZColorOfWhite;
    [insuranceFootView setViewBorderWithRectBorder:UIRectBorderBottom|UIRectBorderTop borderSize:0.5 withColor:nil withBroderOffset:nil];
    NSString *priceStr;
    if (section==0) {
        priceStr=[NSString stringWithFormat:@"￥%@",self.detailDic[@"s_price"]];
    }else{
        priceStr=[NSString stringWithFormat:@"￥%@",self.detailDic[@"b_price"]];
    }
    UILabel *priceLabel=[[UILabel alloc]init];
    NSDictionary *attrs = @{NSFontAttributeName : [UIFont boldSystemFontOfSize:16]};
    CGSize size=[priceStr sizeWithAttributes:attrs];
    [priceLabel setFrame:CGRectMake(CGRectGetWidth(self.view.frame)-size.width-12, 0, size.width, 33)];
    priceLabel.textColor=[UIColor colorWithHexString:@"f8Af30"];
    priceLabel.font=[UIFont systemFontOfSize:15];
    [insuranceFootView addSubview:priceLabel];
    
    UILabel *hejiLabel=[[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(priceLabel.frame)-45, 0, 42, 33)];
    hejiLabel.textColor=[UIColor colorWithHexString:@"323232"];
    hejiLabel.font=[UIFont systemFontOfSize:13];
    hejiLabel.text=@"合计：";
    [insuranceFootView addSubview:hejiLabel];
    
    if (section==0) {
        priceLabel.text=[NSString stringWithFormat:@"￥%@",self.detailDic[@"s_price"]];
    }else{
        priceLabel.text=[NSString stringWithFormat:@"￥%@",self.detailDic[@"b_price"]];
    }
    
    return insuranceFootView;
}




- (IBAction)documentPhotoDisplayControlClick:(UIControl *)sender {
    
    NSString *imgURL;
    if (sender.tag==20) {
        imgURL = self.detailDic[@"identity_img"];
    }else{
        imgURL = self.detailDic[@"license_img"];
    }
    if (imgURL.length>0) {
        if ([imgURL containsString:@"http"]) {
            [self.documentPhotoDisplayView setNeedsUpdateConstraints];
            [self.documentPhotoDisplayView setNeedsDisplay];
            [self.documentPhotoDisplayView setNeedsLayout];
            [self.documentPhotoDisplayView showView];
            [self.documentPhotoDisplayView.certificatesImageView sd_setImageWithURL:[NSURL URLWithString:imgURL] placeholderImage:[ImageHandler getDefaultWhiteLogo]];
        }

    }else{
        [SupportingClass showAlertViewWithTitle:@"" message:@"暂无照片" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:nil];
    }
}
//重新预约
- (void)reAppointmentClick {
    [self getAppInsuranceReAppoint];
}
//立即支付
- (void)payImmediatelyClick {
     @weakify(self);
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    [APIsConnection.shareConnection personalCenterAPIsPaymentMethodByAlipayWithAccessToken:self.accessToken orderMainID:self.pidStr success:^(NSURLSessionDataTask *operation, id responseObject) {
        NSLog(@"%@", operation.currentRequest.URL.absoluteString);
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
        
//        NSDictionary *dataDetail = responseObject[CDZKeyOfResultKey];
        PaymentCenterVC *vc = [PaymentCenterVC new];
        vc.orderClearanceType = CDZOrderPaymentClearanceTypeOfInsurance;
        vc.paymentDetail = responseObject[CDZKeyOfResultKey];
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        NSLog(@"%@",error);
        NSLog(@"%@", operation.currentRequest.URL.absoluteString);
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

-(void)getAppInsuranceReAppoint
{
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    @weakify(self);
    [APIsConnection.shareConnection personalCenterAPIsPostUserAutosInsurancekCDZUserAutosInsuranceAppInsuranceReAppointWithAccessToken:self.accessToken pid:self.pidStr success:^(NSURLSessionDataTask *operation, id responseObject) {
        [ProgressHUDHandler dismissHUD];
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@---%@",message,operation.currentRequest.URL.absoluteString);
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        if (errorCode==0) {
            self.reAppointDic=responseObject;
            MyCarInsuranceApplyFormVC *vc=[MyCarInsuranceApplyFormVC new];
            vc.reAppoimtResultDic=self.reAppointDic;
            vc.fromStr=@"保险详情";
            [self setDefaultNavBackButtonWithoutTitle];
            [self.navigationController pushViewController:vc animated:YES];
        }else{
            
        }
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        NSLog(@"%@-",error);
        @strongify(self);
        if (error.code==-1009) {
            [SupportingClass showAlertViewWithTitle:@"error" message:@"网络连接失败，请检查网络设置！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                [ProgressHUDHandler dismissHUD];
            }];
            return;
        }
        
        
        if (error.code==-1001) {
            [SupportingClass showAlertViewWithTitle:@"error" message:@"网络连接逾时，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                [ProgressHUDHandler dismissHUD];
            }];
            return;
        }
        
        [SupportingClass showAlertViewWithTitle:@"error" message:@"网络错误，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            [ProgressHUDHandler dismissHUD];
        }];
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
