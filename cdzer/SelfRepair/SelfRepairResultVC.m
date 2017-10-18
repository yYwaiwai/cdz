//
//  SelfRepairResultVC.m
//  cdzer
//
//  Created by KEns0n on 3/19/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//
#define startPointX (14.0f)
#define startPointY (8.0f)
#import "SelfRepairResultVC.h"
#import "PNChart.h"
#import "InsetsLabel.h"
#import "SelfRepairResultCell.h"
#import "UserSelectedAutosInfoDTO.h"
#import "RepairShopSearchResultVC.h"
#import "SelfRepairShortcutPayVC.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface SelfRepairResultVC ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) PNCircleChart *circleChart;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *partsList;


@end

@implementation SelfRepairResultVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.contentView setBackgroundColor:[UIColor colorWithRed:0.953f green:0.953f blue:0.953f alpha:1.00f]];
    self.title = getLocalizationString(@"self_repair_result");
    [self componentSetting];
    [self initializationUI];
    // Do any additional setup after loading the view, typically from a nib.
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)componentSetting {
    self.partsList = _maintanceData[CDZKeyOfResultKey];
    if (!_partsList) {
        self.partsList = @[];
    }
}

- (void)initializationUI {
    UIView *selectedCarView = [[UIView alloc] initWithFrame:CGRectMake(startPointX,
                                                                       startPointY,
                                                                       CGRectGetWidth(self.contentView.frame)-startPointX*2.0f,
                                                                       45.0f)];
    [selectedCarView setBackgroundColor:[UIColor colorWithRed:0.933f green:0.933f blue:0.933f alpha:1.00f]];
    [selectedCarView setBorderWithColor:[UIColor colorWithRed:0.882f green:0.882f blue:0.882f alpha:1.00f] borderWidth:(1.0f)];
    [self.contentView addSubview:selectedCarView];
    
    UserSelectedAutosInfoDTO *autosData = [[DBHandler shareInstance] getSelectedAutoData];
    CGFloat borderWidth = 4.0f;
    CGRect selectedCarLblRect = selectedCarView.bounds;
    selectedCarLblRect.origin.x = borderWidth;
    selectedCarLblRect.origin.y = borderWidth;
    selectedCarLblRect.size.width -= borderWidth*2.0f;
    selectedCarLblRect.size.height -= borderWidth*2.0f;
    InsetsLabel *selectedCarLabel = [[InsetsLabel alloc] initWithFrame:selectedCarLblRect andEdgeInsetsValue:UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 10.0f)];
    [selectedCarLabel setBackgroundColor:CDZColorOfWhite];
    [selectedCarLabel setBorderWithColor:[UIColor colorWithRed:0.906f green:0.906f blue:0.906f alpha:1.00f] borderWidth:(1.0f)];
    [selectedCarLabel setFont:systemFontWithoutRatio(14.0f)];
    [selectedCarLabel setText:[NSString stringWithFormat:@"%@\n%@", autosData.seriesName, autosData.modelName]];
    selectedCarLabel.numberOfLines = 2;
    selectedCarLabel.textAlignment = NSTextAlignmentCenter;
    [selectedCarView addSubview:selectedCarLabel];
    
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    NSNumber *mileNum = [NSNumber numberWithInteger:[_maintanceData[@"miles"] integerValue] ];
    self.circleChart = [[PNCircleChart alloc] initWithFrame:CGRectMake(startPointX, CGRectGetMaxY(selectedCarView.frame)+10.0f, 100.0f, 100.0f)
                                                      total:@200000 current:mileNum clockwise:NO shadow:NO shadowColor:CDZColorOfLightGray displayCountingLabel:NO];
    
    [_circleChart setLineWidth:[NSNumber numberWithFloat:(9.0f)]];
    [_circleChart setStrokeColor:CDZColorOfDefaultColor];
    [_circleChart setStrokeColorGradientStart:CDZColorOfDefaultColor];
    [_circleChart strokeChart];
    [self.view addSubview:_circleChart];
    
    CGRect chartInsideLabelRect = _circleChart.bounds;
    chartInsideLabelRect.size.height = (30.f);
    UILabel *chartInsideLabel = [[UILabel alloc] initWithFrame:chartInsideLabelRect];
    [chartInsideLabel setBackgroundColor:[UIColor clearColor]];
    [chartInsideLabel setCenter:CGPointMake(CGRectGetMidX(_circleChart.bounds), CGRectGetMidY(_circleChart.bounds))];
    [chartInsideLabel setTextColor:CDZColorOfDefaultColor];
    [chartInsideLabel setFont:systemFontWithoutRatio(14.0f)];
    [chartInsideLabel setTextAlignment:NSTextAlignmentCenter];
    [chartInsideLabel setText:[NSString stringWithFormat:@"%ld KM",(long)mileNum.integerValue]];
    [self.circleChart addSubview:chartInsideLabel];
    
    
    
    

    if (_maintanceData[@"notes"]) {
        
        CGRect noteRect = _circleChart.frame;
        noteRect.origin.x = CGRectGetMaxX(_circleChart.frame);
        noteRect.size.width = CGRectGetWidth(self.contentView.frame)-CGRectGetMaxX(_circleChart.frame);
        NSString *notesString = _maintanceData[@"notes"];
        NSString *remarkString = _maintanceData[@"remark"];
        if (remarkString) {
            notesString = [notesString stringByAppendingFormat:@"\n* %@",remarkString];
        }
        
        InsetsLabel *noteLabel = [[InsetsLabel alloc] initWithFrame:noteRect andEdgeInsetsValue:UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 10.0f)];
        [noteLabel setTextColor:UIColor.orangeColor];
        [noteLabel setBackgroundColor:[UIColor clearColor]];
        [noteLabel setNumberOfLines:0];
        [noteLabel setFont:systemFontWithoutRatio(13.0f)];
        [noteLabel setText:notesString];
        [self.contentView addSubview:noteLabel];
    }

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
//    UIButton *moreInfoBtn = [UIButton buttonWithType:UIButtonTypeSystem];
//    [moreInfoBtn setBackgroundColor:CDZColorOfDefaultColor];
//    [moreInfoBtn setTitleColor:CDZColorOfWhite forState:UIControlStateNormal];
//    [moreInfoBtn setFrame:CGRectMake(CGRectGetMaxX(_circleChart.frame)+(10.0f),
//                                     CGRectGetMaxY(selectedCarView.frame)+(50.0f),
//                                     (66.0f),
//                                     (30.0f))];
//    [moreInfoBtn.layer setCornerRadius:(6.0f)];
//    [moreInfoBtn.layer setMasksToBounds:YES];
//    [moreInfoBtn addTarget:self action:@selector(confirmBtnActionGetResult) forControlEvents:UIControlEventTouchUpInside];
//    [moreInfoBtn setTitle:getLocalizationString(@"next_step") forState:UIControlStateNormal];
//    [self.contentView addSubview:moreInfoBtn];
    
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    UIEdgeInsets insertValue = DefaultEdgeInsets;
    
    CGRect dataRemindRect = self.contentView.bounds;
    dataRemindRect.origin.y = CGRectGetMaxY(self.circleChart.frame)+(vO2OSpaceSpace);
    dataRemindRect.size.height = 20.0f;
    InsetsLabel *dataRemindLabel = [[InsetsLabel alloc] initWithFrame:dataRemindRect andEdgeInsetsValue:insertValue];
    [dataRemindLabel setBackgroundColor:[UIColor clearColor]];
    [dataRemindLabel setTextColor:[UIColor colorWithRed:0.376f green:0.376f blue:0.376f alpha:1.00f]];
    [dataRemindLabel setFont:systemFontWithoutRatio(12.0f)];
    dataRemindLabel.numberOfLines = 2;
    dataRemindLabel.textAlignment = NSTextAlignmentLeft;
    dataRemindLabel.text = getLocalizationString(@"sr_data_remind");
    [self.contentView addSubview:dataRemindLabel];
    
    CGRect remindTitleRect = CGRectZero;
    remindTitleRect.origin.y = CGRectGetMaxY(dataRemindLabel.frame);
    remindTitleRect.size.width = CGRectGetWidth(self.contentView.frame);
    remindTitleRect.size.height = 22.f;
    InsetsLabel *remindTitle = [[InsetsLabel alloc] initWithFrame:remindTitleRect andEdgeInsetsValue:insertValue];
    [remindTitle setBackgroundColor:[UIColor clearColor]];
    [remindTitle setTextColor:CDZColorOfDefaultColor];
    [remindTitle setFont:systemFontWithoutRatio(16.0f)];
    [remindTitle setText:getLocalizationString(@"sr_analyze_remind")];
    [self.contentView addSubview:remindTitle];
    
    
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    UIView *bottomBtnView = [UIView.alloc initWithFrame:CGRectMake(0.0f, CGRectGetHeight(self.contentView.frame)-50.0f, CGRectGetWidth(self.contentView.frame), 50.0f)];
    bottomBtnView.backgroundColor = CDZColorOfWhite;
    [self.contentView addSubview:bottomBtnView];
    
    UIButton *storeSearchBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    storeSearchBtn.backgroundColor = CDZColorOfDefaultColor;
    storeSearchBtn.frame = CGRectMake(CGRectGetWidth(bottomBtnView.frame)*0.06, 7.0f, CGRectGetWidth(bottomBtnView.frame)*0.41, 36.0f);
    [storeSearchBtn setTitle:@"查找商家" forState:UIControlStateNormal];
    [storeSearchBtn setTitleColor:CDZColorOfWhite forState:UIControlStateNormal];
    [storeSearchBtn addTarget:self action:@selector(pushToPartStoreSearchVC) forControlEvents:UIControlEventTouchUpInside];
    [bottomBtnView addSubview:storeSearchBtn];
    
    UIButton *purchaseBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    purchaseBtn.backgroundColor = CDZColorOfDefaultColor;
    purchaseBtn.frame = CGRectMake(CGRectGetWidth(bottomBtnView.frame)*0.53,
                                   CGRectGetMinY(storeSearchBtn.frame),
                                   CGRectGetWidth(storeSearchBtn.frame),
                                   CGRectGetHeight(storeSearchBtn.frame));
    [purchaseBtn setTitle:@"购买产品" forState:UIControlStateNormal];
    [purchaseBtn setTitleColor:CDZColorOfWhite forState:UIControlStateNormal];
    [purchaseBtn addTarget:self action:@selector(getPurchaseList) forControlEvents:UIControlEventTouchUpInside];
    [bottomBtnView addSubview:purchaseBtn];
    
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(remindTitle.frame),
                                                                   CGRectGetWidth(self.contentView.frame),
                                                                   CGRectGetMinY(bottomBtnView.frame)-CGRectGetMaxY(remindTitle.frame))];
    _tableView.bounces = NO;
    _tableView.showsHorizontalScrollIndicator = YES;
    _tableView.showsVerticalScrollIndicator = YES;
    _tableView.allowsSelection = YES;
    _tableView.allowsMultipleSelection = YES;
    _tableView.allowsSelectionDuringEditing = NO;
    _tableView.allowsMultipleSelectionDuringEditing = NO;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(_tableView.frame), 20.0f)];
    [self.contentView addSubview:_tableView];
}

- (void)pushToPartStoreSearchVC {
    @autoreleasepool {
        RepairShopSearchResultVC *vc = RepairShopSearchResultVC.new;
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma -mark UITableViewDelgate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return _partsList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    SelfRepairResultCell *cell = [tableView dequeueReusableCellWithIdentifier:CDZKeyOfCellIdentKey];
    if (!cell) {
        cell = [[SelfRepairResultCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CDZKeyOfCellIdentKey];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 16.0f, NO);
        cell.detailTextLabel.textColor = CDZColorOfRed;
        
    }
//    [cell updateUIDataWithData:_partsList[indexPath.row]];
    cell.accessoryView.hidden = NO;
    NSDictionary *detail = _partsList[indexPath.row];
    NSString *partsName = [SupportingClass verifyAndConvertDataToString:detail[@"name"]];
    if (!partsName||[partsName isEqualToString:@""]||[partsName isKindOfClass:NSNull.class]) partsName = [SupportingClass verifyAndConvertDataToString:detail[@"project"]];
    cell.textLabel.text = [@"建议配件：" stringByAppendingString:partsName];
    
    NSString *priceName = [SupportingClass verifyAndConvertDataToString:detail[@"price"]];
    
    if (!priceName||[priceName isEqualToString:@""]||[priceName isEqualToString:@"-"]) {
        cell.detailTextLabel.text = @"单价：--（暂无配件）";
        cell.accessoryView.hidden = YES;
    }else {
        cell.detailTextLabel.text = [@"单价：¥" stringByAppendingString:priceName];
    }
    
    cell.imageView.image = ImageHandler.getWhiteLogo;
    NSString *picURLStr = detail[@"description"];
    if (![picURLStr isKindOfClass:NSNull.class]&&picURLStr&&[picURLStr rangeOfString:@"http"].location!=NSNotFound) {
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:picURLStr] placeholderImage:ImageHandler.getWhiteLogo];
    }
    

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    @autoreleasepool {
//        //    wxs_name: "湖南百城网络科技有限公司",
//        //    project: "发动机不能启动，且无着车征兆",
//        //    real_name: "小贺",
//        //    fee: "295.0",
//        //    add_time: "2015-06-16 11:14:32 ",
//        //    address: "湖南省长沙市"
//        NSDictionary *detail = _partsList[indexPath.row];
//        NSString *projectName = detail[@"project"];
//        NSString *partsName = detail[@"name"];
//        NSString *projectDescription = @"没有更多的资讯！";
//        if (![detail[@"description"] isKindOfClass:NSNull.class]&&!detail[@"description"]&&[detail[@"description"] isEqualToString:@""]) {
//            projectDescription = detail[@"description"];
//        }
//        UIFont *commonFont = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 15.0f, NO);
//        CGFloat fullWidth = CGRectGetWidth(tableView.frame)-15.0f*2.0f;
//        
//        CGFloat projectNameHeight = [SupportingClass getStringSizeWithString:projectName font:commonFont widthOfView:CGSizeMake(fullWidth, CGFLOAT_MAX)].height;
//        CGFloat partsNameHeight = [SupportingClass getStringSizeWithString:partsName font:commonFont widthOfView:CGSizeMake(fullWidth, CGFLOAT_MAX)].height;
//        CGFloat projectDescriptionHeight = [SupportingClass getStringSizeWithString:projectDescription font:commonFont widthOfView:CGSizeMake(fullWidth, CGFLOAT_MAX)].height;
//        CGFloat totalHeight = projectDescriptionHeight+projectNameHeight+partsNameHeight+14.0f;
//        return totalHeight;
//        
//    }
    
    return 90.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *detail = _partsList[indexPath.row];
    NSString *priceName = [SupportingClass verifyAndConvertDataToString:detail[@"price"]];
    if (!priceName||[priceName isEqualToString:@""]||[priceName isEqualToString:@"-"]) {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}

- (void)getPurchaseList {
    @autoreleasepool {
        NSArray *selectList = nil;
        NSMutableIndexSet *indicesOfItems = [NSMutableIndexSet new];
        for (NSIndexPath *selectionIndex in _tableView.indexPathsForSelectedRows)
        {
            [indicesOfItems addIndex:selectionIndex.row];
        }
        selectList = [[_partsList valueForKey:@"id"] objectsAtIndexes:indicesOfItems];
        [self getPurchaseListWithPartsIDList:selectList];
    }
    
}

- (void)pushToExpressPurchaseVC:(id)responseObject {
    @autoreleasepool {
        [ProgressHUDHandler dismissHUD];
        if (!responseObject||![responseObject isKindOfClass:NSArray.class]||[responseObject count]==0) {
            return;
        }
        SelfRepairShortcutPayVC *vc = SelfRepairShortcutPayVC.new;
        vc.purchaseList = responseObject;
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    
    }
}

#pragma mark- API Access Code Section
- (void)getPurchaseListWithPartsIDList:(NSArray *)partsIDList {
    if (!partsIDList||partsIDList.count==0) {
        [SupportingClass showAlertViewWithTitle:nil message:@"请选择要购买的配件" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            
        }];
        return;
    }
    @weakify(self);
    [ProgressHUDHandler showHUD];
    [[APIsConnection shareConnection] theSelfMaintenanceAPIsGetMaintenanceServiceListWithPartsIDList:partsIDList success:^(NSURLSessionDataTask *operation, id responseObject) {
        NSLog(@"%@",responseObject);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        if(errorCode!=0){
            [ProgressHUDHandler dismissHUD];
            [SupportingClass showAlertViewWithTitle:nil message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                
            }];
            return;
        }
        @strongify(self);
        [self pushToExpressPurchaseVC:responseObject[CDZKeyOfResultKey]];
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        [ProgressHUDHandler dismissHUD];
    }];
}

@end
