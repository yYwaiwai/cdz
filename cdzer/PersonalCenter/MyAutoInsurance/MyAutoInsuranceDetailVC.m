//
//  MyAutoInsuranceDetailVC.m
//  cdzer
//
//  Created by KEns0n on 10/26/15.
//  Copyright © 2015 CDZER. All rights reserved.
//  保险详情VC

#define kList @"list"
#define kTitle @"title"

#import "MyAutoInsuranceDetailVC.h"
#import "MAIDetailCell.h"
#import "InsetsLabel.h"

@interface CompanyDisplayView : UITableViewCell

@end

@implementation CompanyDisplayView

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}


- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect detailTextLabelFrame = self.detailTextLabel.frame;
    detailTextLabelFrame.origin.x = CGRectGetMaxX(self.textLabel.frame);
    detailTextLabelFrame.size.width = CGRectGetWidth(self.frame)-CGRectGetMaxX(self.textLabel.frame);
    if (self.accessoryView) {
        detailTextLabelFrame.size.width = CGRectGetMinX(self.accessoryView.frame)-CGRectGetMaxX(self.textLabel.frame);
    }
    self.detailTextLabel.frame = detailTextLabelFrame;
}

@end

@interface MyAutoInsuranceDetailVC () <UITableViewDataSource, UITableViewDelegate>
/// 数据列表
@property (nonatomic, strong) NSMutableArray *dataList;
/// 表格视图
@property (nonatomic, strong) UITableView *tableView;
/// 表格头部视图
@property (nonatomic, strong) UIView *tableHeaderView;
/// 汽车牌照号码
@property (nonatomic, strong) InsetsLabel *autosLicenseNumLabel;
/// 汽车型号
@property (nonatomic, strong) InsetsLabel *autosModelLabel;
/// 汽车车主
@property (nonatomic, strong) InsetsLabel *autosOwnerLabel;
/// 投保的城市
@property (nonatomic, strong) InsetsLabel *cityLabel;
/// 保险公司
@property (nonatomic, strong) CompanyDisplayView *companyView;

@end

@implementation MyAutoInsuranceDetailVC

- (void)dealloc {
    
    [NSNotificationCenter.defaultCenter removeObserver:self];
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (void)viewDidLoad {
    self.title = getLocalizationString(@"my_insurance_detail");
    [super viewDidLoad];
    [self componentSetting];
    [self initializationUI];
    [self setReactiveRules];

    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}


- (void)componentSetting {
    @autoreleasepool {
        if (self.insuranceDetail[@"buy"]&&[self.insuranceDetail[@"buy"] count]>0) {
            NSArray *titleList = @[@"交强险",
                                   @"车船税",
                                   @"车辆损失险",
                                   @"商业第三者责任保险",
                                   @"全车盗抢险",
                                   @"驾驶人责任险",
                                   @"乘客责任险",
                                   @"玻璃单独破碎险",
                                   @"自燃损失险",
                                   @"车身划痕损失险",
                                   @"指定专修厂特约险",
                                   @"倒车镜与车灯单独损坏险",
                                   @"涉水行驶损失险",
                                   @"不计免赔特约险-车损",
                                   @"不计免赔特约险-盗抢",
                                   @"不计免赔特约险-三者",
                                   @"不计免赔特约险-司机乘客",
                                   @"不计免赔特约险-附加险",];
            
            self.dataList = [@[] mutableCopy];
            NSArray *list = self.insuranceDetail[@"buy"];
            NSMutableArray *tiList = [@[] mutableCopy];
            NSMutableArray *ciList = [@[] mutableCopy];
            NSMutableArray *oiList = [@[] mutableCopy];
            [titleList enumerateObjectsUsingBlock:^(NSString * _Nonnull title, NSUInteger tIdx, BOOL * _Nonnull tStop) {
                [list enumerateObjectsUsingBlock:^(NSDictionary *  _Nonnull detail, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSString *mainTitle = detail[@"mainType"];
                    NSString *subtitle = detail[@"coverageType"];
                    if ([subtitle isEqualToString:title]) {
                        if ([mainTitle rangeOfString:@"交强险"].location!=NSNotFound) {
                            [tiList addObject:detail];
                        }else if ([mainTitle rangeOfString:@"商业险"].location!=NSNotFound&&
                                  ([subtitle rangeOfString:@"车辆损失险"].location!=NSNotFound||
                                   [subtitle rangeOfString:@"商业第三者责任保险"].location!=NSNotFound||
                                   [subtitle rangeOfString:@"全车盗抢险"].location!=NSNotFound||
                                   [subtitle rangeOfString:@"驾驶人责任险"].location!=NSNotFound||
                                   [subtitle rangeOfString:@"乘客责任险"].location!=NSNotFound)) {

                            [ciList addObject:detail];
                        }
                        else {
                            [oiList addObject:detail];
                        }
                        *stop = YES;
                    }
                }];
            }];
            
            
            if (tiList.count>0) {
                [_dataList addObject:@{kTitle:@"交强险", kList:tiList}];
            }
            
            if (ciList.count>0) {
                [_dataList addObject:@{kTitle:@"商业险", kList:ciList}];
            }
            
            if (oiList.count>0) {
                [_dataList addObject:@{kTitle:@"更多附加保险保障", kList:oiList}];
            }
            
        }
    }
    
}

- (void)initializationUI {
    @autoreleasepool {
        NSDictionary *insuredDetail = _insuranceDetail[@"carInfo"];
        
        self.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.contentView.frame), 144.0f)];
        
        UIView *autosDetailView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.contentView.frame), 100.0f)];
        autosDetailView.backgroundColor = [UIColor colorWithRed:0.129f green:0.796f blue:0.604f alpha:1.00f];
        [_tableHeaderView addSubview:autosDetailView];
        
        UIFont *font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfBold, 15.0f, NO);
        NSString *licenseNumString = insuredDetail[@"licenseNo"];
        if (!licenseNumString) licenseNumString = @"--";
        self.autosLicenseNumLabel = [[InsetsLabel alloc] initWithFrame:CGRectMake(0.0f, 5.0f, CGRectGetWidth(autosDetailView.frame), 30.0f)
                                                    andEdgeInsetsValue:DefaultEdgeInsets];
        _autosLicenseNumLabel.text = [@"车牌号：" stringByAppendingString:licenseNumString];
        _autosLicenseNumLabel.font = font;
        _autosLicenseNumLabel.textColor = CDZColorOfWhite;
        [autosDetailView addSubview:_autosLicenseNumLabel];
        
        
        
        NSString *autosOwnerString = [SupportingClass verifyAndConvertDataToString:insuredDetail[@"carUserName"]];
        if (!autosOwnerString) autosOwnerString = @"--";
        self.autosOwnerLabel = [[InsetsLabel alloc] initWithFrame:_autosLicenseNumLabel.frame
                                               andEdgeInsetsValue:DefaultEdgeInsets];
        _autosOwnerLabel.font = font;
        _autosOwnerLabel.text = [@"车主：" stringByAppendingString:autosOwnerString];
        _autosOwnerLabel.textColor = CDZColorOfWhite;
        _autosOwnerLabel.textAlignment = NSTextAlignmentRight;
        [autosDetailView addSubview:_autosOwnerLabel];
        
        
        
        NSString *autosModelString = [NSString stringWithFormat:@"%@ %@",insuredDetail[@"fctName"], insuredDetail[@"speciName"]];
        if (!autosModelString) autosModelString = @"--";
        self.autosModelLabel = [[InsetsLabel alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(_autosLicenseNumLabel.frame), CGRectGetWidth(autosDetailView.frame), 30.0f)
                                               andEdgeInsetsValue:DefaultEdgeInsets];
        _autosModelLabel.font = font;
        _autosModelLabel.text = [@"车型：" stringByAppendingString:autosModelString];
        _autosModelLabel.textColor = CDZColorOfWhite;
        [autosDetailView addSubview:_autosModelLabel];
        
        
        NSString *cityString = insuredDetail[@"city"];
        if (!cityString) cityString = @"--";
        self.cityLabel = [[InsetsLabel alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(_autosModelLabel.frame), CGRectGetWidth(autosDetailView.frame), 30.0f)
                                         andEdgeInsetsValue:DefaultEdgeInsets];
        _cityLabel.font = font;
        _cityLabel.text = [@"投保城市：" stringByAppendingString:cityString];
        _cityLabel.textColor = CDZColorOfWhite;
        [autosDetailView addSubview:_cityLabel];
        
        NSSet *companySet = [NSSet setWithArray:[_insuranceDetail[@"buy"] valueForKey:@"company"]];
        NSString *companyString = companySet.allObjects.lastObject;
        if (!companyString) companyString = @"--";
        self.companyView = [[CompanyDisplayView alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
        _companyView.frame = CGRectMake(0.0f, CGRectGetMaxY(autosDetailView.frame), CGRectGetWidth(self.contentView.frame), 44.0f);
        _companyView.textLabel.textColor = CDZColorOfOrangeColor;
        _companyView.textLabel.text = @"保险公司：";
        _companyView.textLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfBold, 18.0f, NO);
        _companyView.detailTextLabel.textColor = CDZColorOfBlack;
        _companyView.detailTextLabel.text = companyString;
        _companyView.detailTextLabel.textAlignment = NSTextAlignmentCenter;
        _companyView.detailTextLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 18.0f, NO);
        [_tableHeaderView addSubview:_companyView];
        
        self.tableView = [[UITableView alloc] initWithFrame:self.contentView.bounds];
        _tableView.bounces = NO;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableHeaderView = _tableHeaderView;
        _tableView.allowsSelection = NO;
        _tableView.allowsMultipleSelection = NO;
//        _tableView.allowsSelectionDuringEditing = NO;
//        _tableView.allowsMultipleSelectionDuringEditing = NO;
        [self.contentView addSubview:_tableView];
    }

}

- (void)setReactiveRules {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma -mark UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return _dataList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSDictionary *detail = _dataList[section];
    
    return [detail[kList] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MAIDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:CDZKeyOfCellIdentKey];
    if (!cell) {
        cell = [[MAIDetailCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CDZKeyOfCellIdentKey];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    // Configure the cell...
    NSDictionary *data = _dataList[indexPath.section];
    NSDictionary *detail = [data[kList] objectAtIndex:indexPath.row];
    NSString *title = detail[@"coverageType"];
    NSString *coverageCost = [SupportingClass verifyAndConvertDataToString:detail[@"coverageNo"]];
    NSNumber *premiumCost = [SupportingClass verifyAndConvertDataToNumber:detail[@"price"]];
    BOOL isTitle = NO;
    if ([title rangeOfString:@"倒车镜与车灯单独损坏"].location!=NSNotFound||[title rangeOfString:@"玻璃单独破碎"].location!=NSNotFound) {
        isTitle = YES;
        if ([coverageCost isEqualToString:@""]||!coverageCost) coverageCost = @"--";
    }
    cell.isShowFinalResult = YES;
    [cell updateUIDataWithTitle:title isSelected:YES coverageCost:coverageCost coverageCostIsTitle:isTitle premiumCost:premiumCost];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 54.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    static NSString *headerIdentifier = @"header";
    UITableViewCell *myHeader = [tableView dequeueReusableCellWithIdentifier:headerIdentifier];
    if(!myHeader) {
        myHeader = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:headerIdentifier];
        myHeader.contentView.backgroundColor = [UIColor colorWithWhite:0.3 alpha:1];
        myHeader.textLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfBold, 17.5f, NO);
        myHeader.textLabel.textColor = CDZColorOfWhite;
        myHeader.textLabel.textAlignment = NSTextAlignmentLeft;
    }
    myHeader.backgroundColor = tableView.backgroundColor;
    NSDictionary *detail = _dataList[section];
    NSString *title = detail[kTitle];
    myHeader.textLabel.text = title;
    return myHeader;
    
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
