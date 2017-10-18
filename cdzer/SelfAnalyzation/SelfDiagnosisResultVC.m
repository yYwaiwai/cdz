//
//  SelfDiagnosisResultVC.m
//  cdzer
//
//  Created by KEns0n on 3/17/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#define startPointX 15.0f
#define startPointY 8.0f

#import "SelfDiagnosisResultVC.h"
#import "SelectedAutosDispalyView.h"
#import "RepairShopSearchResultVC.h"
#import "SelfDiagnosisResultCell.h"
#import "InsetsLabel.h"
#import "RepairShopDetailVC.h"
#import "RepairShopSearchResultVC.h"

@interface SelfDiagnosisResultVC ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) SelectedAutosDispalyView *sadv;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *shopList;

@end

@implementation SelfDiagnosisResultVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.contentView setBackgroundColor:[UIColor colorWithRed:0.953f green:0.953f blue:0.953f alpha:1.00f]];
    [self setTitle:getLocalizationString(@"analyzation_result")];
    self.shopList = _resultData[@"wxs_list"];
    if (!_shopList) {
        self.shopList = @[];
    }
    [self initializationUI];
    // Do any additional setup after loading the view, typically from a nib.
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (NSString *)separateText {
    @autoreleasepool {
        NSString *string = @"-------你可点击下处取得更多维修商-------";
        CGFloat currentWidth = 0.0f;
        CGFloat limitedWidth = CGRectGetWidth(self.contentView.frame);
        UIFont *font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 14, NO);
        while (currentWidth<limitedWidth) {
            NSString *tmpString = [NSString stringWithFormat:@"-%@-",string];
            currentWidth = [SupportingClass getStringSizeWithString:tmpString font:font widthOfView:CGSizeMake(CGFLOAT_MAX, 25.0f)].width;
            if (currentWidth<limitedWidth) {
                string = tmpString;
            }
        }
        return string;
    }
}

- (void)initializationUI {
    
    UIEdgeInsets insetsValue = UIEdgeInsetsMake(0.0f, startPointX, 0.0f, startPointX);
    self.sadv = [[SelectedAutosDispalyView alloc] initWithFrame:CGRectMake(startPointX, startPointY,
                                                                           CGRectGetWidth(self.contentView.frame)-startPointX*2.0f, 48.0f)];
    [self.contentView addSubview:_sadv];
    
    
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    CGRect mrsbRect = _sadv.frame;
    mrsbRect.size.height = 40.0f;
    mrsbRect.origin.y = CGRectGetHeight(self.contentView.frame)-CGRectGetHeight(mrsbRect)-startPointY*2.0f;
    UIButton *moreRepairShopButton = [UIButton buttonWithType:UIButtonTypeSystem];
    moreRepairShopButton.frame = mrsbRect;
    moreRepairShopButton.backgroundColor = CDZColorOfDefaultColor;
    [moreRepairShopButton setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:5.0f];
    [moreRepairShopButton setTitle:@"更多维修商" forState:UIControlStateNormal];
    [moreRepairShopButton setTitleColor:CDZColorOfWhite forState:UIControlStateNormal];
    [moreRepairShopButton addTarget:self action:@selector(getMoreRepairShop) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:moreRepairShopButton];
    
    
    
    InsetsLabel *separatorLabels = [[InsetsLabel alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMinY(moreRepairShopButton.frame)-startPointY-25.0f,
                                                                       CGRectGetWidth(self.contentView.frame), 25.0f)];
    separatorLabels.text = [self separateText];
    separatorLabels.textAlignment = NSTextAlignmentCenter;
    separatorLabels.textColor = CDZColorOfDeepGray;
    separatorLabels.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 14, NO);
    [self.contentView addSubview:separatorLabels];
    
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    InsetsLabel *titleLabel = [[InsetsLabel alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(_sadv.frame)+startPointY,
                                                                       CGRectGetWidth(self.contentView.frame), 30)
                                                  andEdgeInsetsValue:insetsValue];
    titleLabel.text = @"推荐的维修商：";
    titleLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 17, NO);
    [self.contentView addSubview:titleLabel];

    NSLog(@"%@",_resultData);
    
    CGRect tvRect = self.contentView.bounds;
    tvRect.origin.y = CGRectGetMaxY(titleLabel.frame)+startPointY;
    tvRect.size.height = CGRectGetMinY(separatorLabels.frame)-startPointY-CGRectGetMinY(tvRect);
    self.tableView = [[UITableView alloc] initWithFrame:tvRect];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.bounces = NO;
    _tableView.backgroundColor = CDZColorOfWhite;
    [self.contentView addSubview:_tableView];
}

- (void)getMoreRepairShop {
    @autoreleasepool {
        NSString *keywordString = _resultData[@"reason_name"];
        
        RepairShopSearchResultVC *vc = [RepairShopSearchResultVC new];
        vc.keywordString = keywordString;
        vc.diagnosisResultReason = keywordString;
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
    return _shopList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SelfDiagnosisResultCell *cell = [tableView dequeueReusableCellWithIdentifier:CDZKeyOfCellIdentKey];
    if (!cell) {
        cell = [[SelfDiagnosisResultCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CDZKeyOfCellIdentKey];
        [cell initializationUI];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    }
    // Configure the cell...    
    [cell setUIDataWithDetailData:_shopList[indexPath.row]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return 0.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    return 120.0f;
}

//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//    [cell.layer.sublayers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        if ([obj isKindOfClass:[CALayer class]]) {
//            CALayer *oldLayer = (CALayer *)obj;
//            if ([oldLayer.name isEqualToString:@"bottomBorder"]) {
//                [oldLayer removeFromSuperlayer];
//                *stop = YES;
//            }
//        }
//    }];
//    
//    CALayer *layer = [cell createBottomBorderWithHeight:1.0f andColor:[UIColor colorWithRed:0.882f green:0.882f blue:0.882f alpha:1.00f]];
//    layer.name = @"bottomBorder";
//    [cell.layer addSublayer:layer];
//    
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Update the delete button's title based on how many items are selected.
    NSLog(@"%@",[tableView indexPathsForSelectedRows]);
    [ProgressHUDHandler showHUD];
    [self getShopDetailDataWithShopID:[_shopList[indexPath.row] objectForKey:@"id"]];
}


#pragma mark- API Access Code Section
- (void)getShopDetailDataWithShopID:(NSString *)shopID {
    if (!shopID) return;
    [[APIsConnection shareConnection] maintenanceShopsAPIsGetMaintenanceShopsDetailWithShopID:shopID success:^(NSURLSessionDataTask *operation, id responseObject) {
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        [ProgressHUDHandler dismissHUD];
        if (errorCode!=0) {
            [SupportingClass showAlertViewWithTitle:@"error" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                
            }];
            return ;
        }
        
        @autoreleasepool {
            NSString *keywordString = self.resultData[@"reason_name"];
            RepairShopDetailVC *rsdvc = [[RepairShopDetailVC alloc] init];
            rsdvc.detailData = responseObject[CDZKeyOfResultKey];
            rsdvc.diagnosisResultReason = keywordString;
            [self setDefaultNavBackButtonWithoutTitle];
            [[self navigationController] pushViewController:rsdvc animated:YES];
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

@end
