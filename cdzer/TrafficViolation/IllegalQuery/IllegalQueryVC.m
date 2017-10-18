//
//  IllegalQueryVC.m
//  cdzer
//
//  Created by 车队长 on 16/12/6.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "IllegalQueryVC.h"
#import "MyCarVC.h"
#import "MyIllegalCell.h"
#import "UserLocationHandler.h"
#import "UserAutosSelectonVC.h"
#import "EngineFrameNumberView.h"
#import "ViolationDetailsVC.h"
#import "LicensePlateSelectionView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>

#import <CoreLocation/CoreLocation.h>

@interface IllegalQueryVC ()<UITableViewDelegate,UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate,CLLocationManagerDelegate>
{
    CLLocationManager *_locationManager;//定位服务管理类
    CLGeocoder * _geocoder;//初始化地理编码器
}

@property (weak, nonatomic) IBOutlet UIView *queryView;//查询View

@property (strong, nonatomic) IBOutlet EngineFrameNumberView *engineFrameNumberView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *warningViewHeightLayoutConstraint;//提示view高

@property (weak, nonatomic) IBOutlet UIButton *warningViewButton;//提示关闭button

@property (weak, nonatomic) IBOutlet UIControl *carMessageControl;//车的control

@property (weak, nonatomic) IBOutlet UIImageView *carImageView;

@property (weak, nonatomic) IBOutlet UILabel *carMessageLabel;

@property (weak, nonatomic) IBOutlet UIImageView *carArrowImageview;

@property (weak, nonatomic) IBOutlet UILabel *addCarMessageLabel;//添加车信息label

@property (weak, nonatomic) IBOutlet UILabel *carNumberLabel;

@property (weak, nonatomic) IBOutlet UIView *engineNumberBGView;

@property (weak, nonatomic) IBOutlet UILabel *engineNumberLabel;

@property (weak, nonatomic) IBOutlet UIView *frameNumberBGView;

@property (weak, nonatomic) IBOutlet UILabel *frameNumberLabel;

@property (weak, nonatomic) IBOutlet UIButton *queryImmediatelyButton;//立即查询button

@property (nonatomic, strong) UserSelectedAutosInfoDTO *autosSelectedData;
//
//@property (nonatomic, strong) UserAutosInfoDTO *userAutosInfoDTO;

@property (weak, nonatomic) IBOutlet UIView *resultView;

@property (weak, nonatomic) IBOutlet UIImageView *resultCarImageView;

@property (weak, nonatomic) IBOutlet UILabel *resultCarNumberLabel;

@property (weak, nonatomic) IBOutlet UILabel *numberOfViolationsLabel;//违章次数

@property (weak, nonatomic) IBOutlet UILabel *finesLabel;//罚款金额

@property (weak, nonatomic) IBOutlet UILabel *pointsLabel;//扣分

@property (weak, nonatomic) IBOutlet UIControl *untreatedControl;//未处理control

@property (weak, nonatomic) IBOutlet UILabel *untreatedLabel;//未处理的Label

@property (weak, nonatomic) IBOutlet UIControl *alreadyProcessedControl;//已处理的control

@property (weak, nonatomic) IBOutlet UILabel *alreadyProcessedLabel;//已处理的label

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UILabel *messageLabel;


@property (nonatomic, strong) NSMutableArray *veList;

@property (nonatomic, strong) NSMutableDictionary *userAutosInfoData;

@property (nonatomic, assign) NSInteger isType;


@end

@implementation IllegalQueryVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.automaticallyAdjustsScrollViewInsets = YES;
    self.extendedLayoutIncludesOpaqueBars = NO;
    self.modalPresentationCapturesStatusBarAppearance = NO;
    self.navigationController.navigationBar.translucent = NO;

    
       if (self.accessToken) {
//        [self handleMissingTokenAction];
//        return;
           [self getUserViolationEnquiryInfo];
    }
    self.isType=1;
    
    NSLog(@"%@", NSStringFromCGRect(self.view.frame));
    
    
    UserSelectedAutosInfoDTO *autosData = [DBHandler.shareInstance getSelectedAutoData];
    if (!self.autosSelectedData||
        [self.autosSelectedData.brandID isEqualToString:@""]||
        [self.autosSelectedData.dealershipID isEqualToString:@""]||
        [self.autosSelectedData.seriesID isEqualToString:@""]||
        [self.autosSelectedData.modelID isEqualToString:@""]) {
        self.autosSelectedData = autosData;
    }
    NSMutableString *string = [NSMutableString string];
    [string appendFormat:@"%@ %@",self.autosSelectedData.seriesName, self.autosSelectedData.modelName];
    self.carMessageLabel.text = string;
    
    
    
    [self.untreatedLabel setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5f withColor:[UIColor colorWithHexString:@"49c7f5" alpha:1.0] withBroderOffset:nil];
    self.untreatedLabel.textColor=[UIColor colorWithHexString:@"49c7f5" alpha:1.0];

    
    _locationManager = [[CLLocationManager alloc] init];
    [_locationManager requestWhenInUseAuthorization];
    //[_locationManager requestAlwaysAuthorization];//iOS8必须，这两行必须有一行执行，否则无法获取位置信息，和定位
    // 设置代理
    _locationManager.delegate = self;
    // 设置定位精确度到米
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    // 设置过滤器为无
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    // 开始定位
    [_locationManager startUpdatingLocation];//开始定位之后会不断的执行代理方法更新位置会比较费电所以建议获取完位置即时关闭更新位置服务
    //初始化地理编码器
    _geocoder = [[CLGeocoder alloc] init];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self removewAllhandleControlEdges];
    [_locationManager stopUpdatingLocation];
    _locationManager.delegate = nil;
    _geocoder=nil;
    [self setRightNavButtonWithTitleOrImage:@"" style:UIBarButtonItemStylePlain target:self action:nil titleColor:nil isNeedToSet:NO];
    
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    self.tabBarController.title=@"违章查询";
    [self componentSetting];
    [self initializationUI];
    [[UINib nibWithNibName:@"EngineFrameNumberView" bundle:nil] instantiateWithOwner:self options:nil];


}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)componentSetting {
    self.veList = [@[] mutableCopy];
    
    
    
    
    CGFloat carImageViewHeight=CGRectGetWidth(self.carImageView.frame)/2;
    [self.carImageView.layer setCornerRadius:carImageViewHeight];
    [self.carImageView.layer setMasksToBounds:YES];
    [self.carImageView setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:3.0f withColor:[UIColor colorWithHexString:@"82d5f7"] withBroderOffset:nil];

    
    [self.queryImmediatelyButton.layer setCornerRadius:3];
    [self.queryImmediatelyButton.layer setMasksToBounds:YES];
    
    [self.engineNumberBGView setViewBorderWithRectBorder:UIRectBorderTop borderSize:0.5f withColor:nil withBroderOffset:nil];
    [self.frameNumberBGView setViewBorderWithRectBorder:UIRectBorderTop|UIRectBorderBottom borderSize:0.5f withColor:nil withBroderOffset:nil];

    [self.resultCarImageView.layer setCornerRadius:carImageViewHeight];
    [self.resultCarImageView.layer setMasksToBounds:YES];
    [self.resultCarImageView setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:3.0f withColor:[UIColor colorWithHexString:@"82d5f7"] withBroderOffset:nil];
}

- (void)initializationUI {
    @autoreleasepool {
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 126.0f;
        self.tableView.tableFooterView = [UIView new];
        self.tableView.backgroundColor = self.view.backgroundColor;
        UINib * nib = [UINib nibWithNibName:@"MyIllegalCell" bundle:nil];
        [self.tableView registerNib:nib forCellReuseIdentifier:CDZKeyOfCellIdentKey];

        self.queryImmediatelyButton.userInteractionEnabled=NO;
        
       
    }
}
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    
    NSLog(@"%lu",(unsigned long)locations.count);
    CLLocation * location = locations.lastObject;
    // 纬度
//    CLLocationDegrees latitude = location.coordinate.latitude;
//    // 经度
//    CLLocationDegrees longitude = location.coordinate.longitude;
    NSLog(@"%@",[NSString stringWithFormat:@"%lf", location.coordinate.longitude]);
        NSLog(@"经度：%f,纬度：%f,海拔：%f,航向：%f,行走速度：%f", location.coordinate.longitude, location.coordinate.latitude,location.altitude,location.course,location.speed);
    
    [_geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (placemarks.count > 0) {
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            NSLog(@"%@",placemark.name);
            //获取城市
            NSString *city = placemark.locality;
            
            if (!city) {
                //四大直辖市的城市信息无法通过locality获得，只能通过获取省份的方法来获得（如果city为空，则可知为直辖市）
                city = placemark.administrativeArea;
            }
            
                [self setRightNavButtonWithTitleOrImage:city style:UIBarButtonItemStylePlain target:self action:nil titleColor:nil isNeedToSet:YES];
            
            // 位置名
//            　　NSLog(@"name,%@",placemark.name);
//            　　// 街道
//            　　NSLog(@"thoroughfare,%@",placemark.thoroughfare);
//            　　// 子街道
//            　　NSLog(@"subThoroughfare,%@",placemark.subThoroughfare);
//            　　// 市
//            　　NSLog(@"locality,%@",placemark.locality);
//            　　// 区
//            　　NSLog(@"subLocality,%@",placemark.subLocality);
//            　　// 国家
//            　　NSLog(@"country,%@",placemark.country);
        }else if (error == nil && [placemarks count] == 0) {
            NSLog(@"No results were returned.");
        } else if (error != nil){
            NSLog(@"An error occurred = %@", error);
        }
    }];
    //    [manager stopUpdatingLocation];不用的时候关闭更新位置服务
}

//提示View关闭
- (IBAction)warningCloseButtonClick:(id)sender {
    self.warningViewHeightLayoutConstraint.constant=0;
    
}
//提示
- (IBAction)promptClick:(id)sender {
    
    [self.engineFrameNumberView setNeedsUpdateConstraints];
    [self.engineFrameNumberView setNeedsDisplay];
    [self.engineFrameNumberView setNeedsLayout];
    [self.engineFrameNumberView showView];
}

//立即查询
- (IBAction)queryImmediatelyButtonClick:(id)sender {

    [self getViolationEnquiryListAndIsShowRequested:NO showHub:YES];
    
}

#pragma mark---结果View   展示内容

- (IBAction)handleControlClick:(UIControl*)sender {
    [self removewAllhandleControlEdges];
    [self getUserViolationEnquiryInfo];
    if (sender.tag==1) {
        [self.untreatedLabel setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5f withColor:[UIColor colorWithHexString:@"49c7f5" alpha:1.0] withBroderOffset:nil];
        self.untreatedLabel.textColor=[UIColor colorWithHexString:@"49c7f5" alpha:1.0];
        [self getViolationEnquiryListAndIsShowRequested:NO showHub:YES];
        
    }
    if (sender.tag==2) {
        
        [self.alreadyProcessedLabel setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5f withColor:[UIColor colorWithHexString:@"49c7f5" alpha:1.0] withBroderOffset:nil];
        self.alreadyProcessedLabel.textColor=[UIColor colorWithHexString:@"49c7f5" alpha:1.0];
        
        [self getViolationEnquiryListAndIsShowRequested:YES showHub:YES];
        
    }
    self.isType=sender.tag;
}

- (void)removewAllhandleControlEdges{
    [self.untreatedLabel setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.0f withColor:nil withBroderOffset:nil];
    [self.alreadyProcessedLabel setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.0f withColor:nil withBroderOffset:nil];
    self.untreatedLabel.textColor=[UIColor colorWithHexString:@"323232" alpha:1.0];
    self.alreadyProcessedLabel.textColor=[UIColor colorWithHexString:@"323232" alpha:1.0];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MyIllegalCell *cell = [tableView dequeueReusableCellWithIdentifier:CDZKeyOfCellIdentKey forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    if (_veList.count!=0) {
        
        NSDictionary *detail = _veList[indexPath.row];
        [cell updateUIData:detail];
        if (self.isType==1) {
            cell.isHandleImageView.highlighted=NO;
        }else{
            cell.isHandleImageView.highlighted=YES;
        }
    }
    
    return cell;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.self.veList.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    @autoreleasepool {
        if (_veList.count>0) {
            NSString *address = [_veList[indexPath.row] objectForKey:@"violation_place"];
            [self getHVDetailDataWithAddress:address withIndexPath:indexPath.row];
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *text = @"";
    if (self.carNumberLabel.text.length>0) {
        text = @"没有违章信息，请继续保持！";
    }
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0f],
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    UIImage *image =nil;
    if (self.carNumberLabel.text.length>0) {
        
    image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"weizhangchaxun-wuweizhang@3x" ofType:@"png"]];
    }
    return image;
}



/* 违章查询界面，车辆及违章次数界面 */
- (void)getUserViolationEnquiryInfo {
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    [ProgressHUDHandler showHUD];
    @weakify(self);
    [APIsConnection.shareConnection personalCenterAPIsGetUserViolationEnquiryInfoWithAccessToken:self.accessToken success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@=====%@", message, operation.currentRequest.URL.absoluteString);
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {return;};
        if (errorCode!=0&&![message isEqualToString:@"返回成功"]) {
            [ProgressHUDHandler dismissHUD];
            if ([message isEqualToString:@"请完善车牌号"]||[message isEqualToString:@"请完善发动机号"]) {
                [SupportingClass showAlertViewWithTitle:@"系统提示" message:@"您还没有完善个人车辆信息，现在去完善吗？" isShowImmediate:YES cancelButtonTitle:@"取消" otherButtonTitles:@"立即完善" clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                    
                    if (btnIdx.integerValue>0) {
                        MyCarVC*vc = [MyCarVC new];
                        vc.wasSubmitAfterLeave = YES;
                        vc.showTrafficViolationReminder = YES;
                        [self setDefaultNavBackButtonWithoutTitle];
                        [self.navigationController pushViewController:vc animated:YES];
                    }else{
                        self.queryImmediatelyButton.userInteractionEnabled=NO;
                        self.queryImmediatelyButton.alpha=0.4;
                    }
                }];
                return;
            }
            
                [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
            return;
        }
        [ProgressHUDHandler dismissHUD];
        if ([message isEqualToString:@"返回成功"]) {
            
            NSMutableDictionary *userVEInfo = [@{} mutableCopy];;
            userVEInfo = responseObject[CDZKeyOfResultKey];
            self.resultCarNumberLabel.text=[NSString stringWithFormat:@"%@",userVEInfo[@"carNumber"]];
            self.numberOfViolationsLabel.text=[NSString stringWithFormat:@"%@",userVEInfo[@"num"]];
            self.finesLabel.text=[NSString stringWithFormat:@"%@",userVEInfo[@"price"]];
            self.pointsLabel.text=[NSString stringWithFormat:@"%@",userVEInfo[@"points"]];
            self.carNumberLabel.text=[NSString stringWithFormat:@"%@",userVEInfo[@"carNumber"]];
            self.engineNumberLabel.text=[NSString stringWithFormat:@"%@",userVEInfo[@"engineNo"]];
            self.frameNumberLabel.text=[NSString stringWithFormat:@"%@",userVEInfo[@"frameNo"]];
            if (self.frameNumberLabel.text.length==0) {
                self.frameNumberLabel.text=@"暂未填写";
            }
            NSString *imgURLString = userVEInfo[@"img"];
            self.carImageView.image = [ImageHandler getDefaultWhiteLogo];
            if ([imgURLString rangeOfString:@"http"].location!=NSNotFound) {
                [self.carImageView sd_setImageWithURL:[NSURL URLWithString:imgURLString] placeholderImage:[ImageHandler getDefaultWhiteLogo]];
                [self.resultCarImageView sd_setImageWithURL:[NSURL URLWithString:userVEInfo[@"img"]] placeholderImage:[ImageHandler getDefaultWhiteLogo]];
            }
            if (self.carNumberLabel.text.length>0&&self.engineNumberLabel.text.length>0) {
                self.queryImmediatelyButton.userInteractionEnabled=YES;
                self.queryImmediatelyButton.alpha=1.0;
            }else{
                self.queryImmediatelyButton.userInteractionEnabled=NO;
                self.queryImmediatelyButton.alpha=0.4;
            }
            
            if ([userVEInfo[@"mark"] isEqualToString:@"0"]) {
                self.queryView.hidden=NO;
                self.resultView.hidden=YES;
                self.tabBarController.title=@"违章查询";
            }
            if ([userVEInfo[@"mark"] isEqualToString:@"1"]&&self.isType==1) {
                self.queryView.hidden=YES;
                self.resultView.hidden=NO;
                self.tabBarController.title=@"我的违章";
                
                [self getViolationEnquiryListAndIsShowRequested:NO showHub:NO];
            }
            return;
        }

        
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
        
        [SupportingClass showAlertViewWithTitle:@"error" message:@"网络错误，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
        }];
    }];
}


/* 违章查询 */
- (void)getViolationEnquiryListAndIsShowRequested:(BOOL)isShowRequested showHub:(BOOL)showHub {
    
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }

    if (self.engineNumberLabel.text.length<5) {
        [SupportingClass showAlertViewWithTitle:@"系统提示" message:@"您还没有完善个人车辆信息，现在去完善吗？" isShowImmediate:YES cancelButtonTitle:@"取消" otherButtonTitles:@"立即完善" clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            
            if (btnIdx.integerValue>0) {
                MyCarVC*vc = [MyCarVC new];
                vc.wasSubmitAfterLeave = YES;
                vc.showTrafficViolationReminder = YES;
                [self setDefaultNavBackButtonWithoutTitle];
                [self.navigationController pushViewController:vc animated:YES];
            }else{
                self.queryImmediatelyButton.userInteractionEnabled=NO;
                self.queryImmediatelyButton.alpha=0.4;
            }
        }];
        return;    }
    NSString * engineCode = [self.engineNumberLabel.text substringFromIndex:self.engineNumberLabel.text.length-5];
    NSString *licensePlate =[NSString stringWithFormat:@"%@",self.carNumberLabel.text];
    
    @weakify(self);
    if (showHub) {
        [ProgressHUDHandler showHUD];
    }else {
        [ProgressHUDHandler updateProgressStatusWithTitle:@"更新中。。。"];
    }
    [[APIsConnection shareConnection] personalCenterAPIsGetUserViolationEnquiryRequestWithAccessToken:self.accessToken myAutoEngineNum:engineCode licensePlate:licensePlate isShowRequested:isShowRequested  success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@----%@",message,operation.currentRequest.URL.absoluteString);
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {return;};
        [ProgressHUDHandler dismissHUD];
        if (errorCode!=0&&![message isEqualToString:@"返回成功"]) {
            if ([message isContainsString:@"等待查询"]) {
                UserInfosDTO *dto= [DBHandler.shareInstance getUserInfo];
                NSUserDefaults *accountDefaults = [NSUserDefaults standardUserDefaults];
                [accountDefaults setObject:dto.telphone forKey:@"isIllegalQuery"];
                [NSUserDefaults.standardUserDefaults synchronize];
                self.queryView.hidden=YES;
                self.resultView.hidden=NO;
                [self.veList removeAllObjects];
                [self.tableView reloadData];
                if (isShowRequested==NO) {
                    self.tableView.hidden=YES;
                    self.messageLabel.hidden=NO;
                }else
                {
                    self.tableView.hidden=NO;
                    self.messageLabel.hidden=YES;
                    return;
                }
                
                return;
            }
            if (errorCode==2&&[message isEqualToString:@"没有数据"]) {
                self.tableView.hidden=YES;
                [self.veList removeAllObjects];
                [self.tableView reloadData];
                self.tableView.hidden=NO;
                self.messageLabel.hidden=YES;
                return;
            }
            if (errorCode==6) {
                [SupportingClass showAlertViewWithTitle:@"alert_remind" message:@"发动机号与车牌号不匹配请确认后再查询！点击跳转个人中心进行查看或修改..." isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
                return;
            }
            
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
            return;
        }

        [self.veList removeAllObjects];
        [self.veList addObjectsFromArray:responseObject[CDZKeyOfResultKey]];
        [self.tableView reloadData];
        if ([message isEqualToString:@"返回成功"]) {
            self.queryView.hidden=YES;
            self.resultView.hidden=NO;
            self.tableView.hidden=NO;
            self.messageLabel.hidden=YES;
            if (isShowRequested==NO) {
                self.isType=1;
            }
        }
       
        
        
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        NSLog(@"%@",operation.currentRequest.URL.absoluteString);
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

/* 违章详情 */
- (void)getHVDetailDataWithAddress:(NSString *)address withIndexPath:(NSInteger)indexPathRow{
    if (!address||[address isEqualToString:@""]) {
        return ;
    }
    
    [ProgressHUDHandler showHUD];
    @weakify(self);
    [[APIsConnection shareConnection] personalCenterAPIsGetViolationDetailWithBlacksiteAddress:address success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"违章详情   %@----%@",message,operation.currentRequest.URL.absoluteString);
        [ProgressHUDHandler dismissHUD];
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        if (errorCode!=0&&![message isEqualToString:@"返回成功"]) {
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
            return;
        }
        ViolationDetailsVC *vc = ViolationDetailsVC.new;
        vc.tvDetail = responseObject[CDZKeyOfResultKey];
        vc.address = address;
        vc.violationDetail = self.veList[indexPathRow];
        vc.isType = self.isType;
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
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
        
        [SupportingClass showAlertViewWithTitle:@"error" message:@"网络错误，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
        }];
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
