//
//  RepairSubGuideVC.m
//  cdzer
//
//  Created by KEns0n on 16/3/31.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#define DefaultBtnTag 100

#import "RepairSubGuideVC.h"
#import "RepairGudieProcedureVC.h"
#import <MJRefresh/MJRefresh.h>
@interface RepairSubGuideCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *iconIV;

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;

@end

@implementation RepairSubGuideCell

@end

@interface RepairSubGuideVC ()

@property (nonatomic, weak) IBOutlet UIView *upperBtnsView;

@property (nonatomic, strong) NSMutableArray *dataList;

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, assign) NSUInteger currentSubTypeIdx;

@property (nonatomic, strong) UIImage *defaultImage;


@end

@implementation RepairSubGuideVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self componentSetting];
    [self initializationUI];
    [self setReactiveRules];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)setReactiveRules {
    @autoreleasepool {
        
    }
    
}

- (void)componentSetting {
    @autoreleasepool {
        self.dataList = [NSMutableArray array];
        [self pageObjectToDefault];
        self.defaultImage = [ImageHandler getImageFromCacheWithByFixdeRatioFileRootPath:nil fileName:@"shop_photo_frame" type:FMImageTypeOfPNG needToUpdate:YES];
    }
}

- (void)initializationUI {
    @autoreleasepool {
        
        _tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(refreshView:)];
        _tableView.mj_footer.automaticallyHidden = NO;
        _tableView.mj_footer.hidden = YES;
        UINib *nib = [UINib nibWithNibName:@"RepairSubGuideCell" bundle:nil];
        [self.tableView registerNib:nib forCellReuseIdentifier:@"RepairSubGuideCell"];
        
        
        CGFloat width = (IS_IPHONE_4_OR_LESS&&IS_IPHONE_5&&_subTypeList.count>3)?70.0f:80.f;
        CGFloat offset = (SCREEN_WIDTH-(_subTypeList.count*width))/(_subTypeList.count+1);
        @weakify(self);
        [_subTypeList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            @strongify(self);
            NSString *title = obj[@"name"];
            NSString *imageName = [NSString stringWithFormat:@"type%d_stype%d", self.currentIdex, (idx+1)];
            UIImage *image = [ImageHandler getImageFromCacheWithByFixdeRatioFileRootPath:nil fileName:imageName type:FMImageTypeOfPNG needToUpdate:YES];
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(offset+(width+offset)*idx, 0.0f, width, CGRectGetHeight(self.upperBtnsView.frame));
            button.tag = DefaultBtnTag+idx;
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            [button setImage:image forState:UIControlStateNormal];
            if ([title isEqualToString:@"室内、暖气、空调"]) {
                title = @"室内及空调";
            }
            if ([title isEqualToString:@"机械 润滑和冷却"]) {
                title = @"机械和冷却";
            }
            if ([title isEqualToString:@"启动 充电和电器"]) {
                title = @"电源和电器";
            }
            if ([title isEqualToString:@"传动轴和差速器"]) {
                title = @"传动和差速器";
            }
            [button setTitle:title forState:UIControlStateNormal];
            [button setTitleColor:CDZColorOfBlack forState:UIControlStateNormal];
            [button setTitleColor:CDZColorOfOrangeColor forState:UIControlStateDisabled];
            UIFont *font = button.titleLabel.font;
            button.titleLabel.font = [font fontWithSize:12.0f];
            button.titleLabel.numberOfLines = 0;
            button.titleLabel.textAlignment = NSTextAlignmentCenter;
            CGSize fontSize = [SupportingClass getStringSizeWithString:button.titleLabel.text font:button.titleLabel.font widthOfView:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
            fontSize.height +=15.0f;
            button.imageEdgeInsets = UIEdgeInsetsMake(0.0f, (CGRectGetWidth(button.frame)-CGRectGetWidth(button.imageView.frame))/2.0f, fontSize.height, 0.0f);
            button.titleEdgeInsets = UIEdgeInsetsMake(image.size.height, -image.size.width, 0.0f, 0.0f);
            [self.upperBtnsView addSubview:button];
            if (idx==0) {
                button.enabled = NO;
                self.currentSubTypeIdx = 0;
                NSString *subTypeID = obj[@"id"];
                [self getGuideSolutionResultList:subTypeID wasReloadAll:YES];
            }
            [button addTarget:self action:@selector(typeSelection:) forControlEvents:UIControlEventTouchUpInside];
        }];
    }
}

- (void)stopRefresh {
    [_tableView.mj_footer endRefreshing];
}

- (void)handleData {
    NSDictionary *detail = _subTypeList[_currentSubTypeIdx];
    NSString *subTYpeID = detail[@"id"];
    [self getGuideSolutionResultList:subTYpeID wasReloadAll:NO];
}

- (void)refreshView:(id)refresh {
    BOOL isRefreshing = NO;
    if ([refresh isKindOfClass:[MJRefreshAutoNormalFooter class]]) {
        isRefreshing = [(MJRefreshAutoNormalFooter *)refresh isRefreshing];
        self.pageNums = @(self.pageNums.integerValue+1);
    }
    if (isRefreshing) {
        [self performSelector:@selector(handleData) withObject:refresh afterDelay:1.5];
    }
}

- (void)typeSelection:(UIButton *)button {
    [_upperBtnsView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *button = (UIButton *)obj;
        button.enabled = YES;
    }];
    button.enabled = NO;
    NSUInteger index = (button.tag-DefaultBtnTag);
    self.currentSubTypeIdx = index;
    NSDictionary *detail = _subTypeList[index];
    NSString *subTYpeID = detail[@"id"];
    [self getGuideSolutionResultList:subTYpeID wasReloadAll:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return _dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *ident = @"RepairSubGuideCell";
    RepairSubGuideCell *cell = [tableView dequeueReusableCellWithIdentifier:ident forIndexPath:indexPath];
    
//    "id": "15111715182810114888",
//    "des": "如果长时间未更换空调滤芯，灰尘和污垢会聚集在滤芯上，产生难闻的气味。\r\n",
//    "name": "如何更换驾驶室空气过滤器",
//    "image": "",
//    "video": ""
    cell.titleLabel.text = nil;
    cell.titleLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfMedium, 15, NO);
    cell.titleLabel.attributedText = nil;
    cell.iconIV.image = _defaultImage;
    cell.iconIV.contentMode = UIViewContentModeScaleAspectFill;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    NSDictionary *detail = _dataList[indexPath.row];
    NSString *title = detail[@"name"];
    NSString *description = detail[@"des"];
    NSString *imageURL = detail[@"image"];
    if (description&&![description isEqualToString:@""]) {
        description = [description stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        description = [description stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        NSMutableAttributedString *string = [NSMutableAttributedString new];
        [string appendAttributedString:[[NSAttributedString alloc] initWithString:[@"\n" stringByAppendingFormat:@"%@\n",title]
                                                                       attributes:@{NSFontAttributeName:vGetHelveticaNeueFont(HelveticaNeueFontTypeOfMedium, 15, NO), NSForegroundColorAttributeName:CDZColorOfBlack}]];
        
        [string appendAttributedString:[[NSAttributedString alloc] initWithString:[description stringByAppendingString:@"\n"]
                                                                       attributes:@{NSFontAttributeName:vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 13, NO), NSForegroundColorAttributeName:CDZColorOfDeepGray}]];
        cell.titleLabel.attributedText = string;
    }else {
        cell.titleLabel.text = title;
    }
    if ([imageURL isContainsString:@"http"]) {
        cell.iconIV.contentMode = UIViewContentModeScaleAspectFit;
        [cell.iconIV setImageWithURL:[NSURL URLWithString:imageURL] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NSDictionary *detail = _dataList[indexPath.row];
    NSString *procedureDetailID = detail[@"id"];
    NSString *title = detail[@"name"];
    [self getRepairGuideProcedureDetail:procedureDetailID withTitle:title];
}

- (void)getGuideSolutionResultList:(NSString *)subTypeID wasReloadAll:(BOOL)reloadAll {
    
    if (!subTypeID||[subTypeID isEqualToString:@""]) {
        NSLog(@"subTypeID missing");
        return;
    }
    
    if (reloadAll) {
        [self.dataList removeAllObjects];
        [self pageObjectToDefault];
        [ProgressHUDHandler showHUD];
    }
    
    @weakify(self);
    [APIsConnection.shareConnection repairGuideAPIsGetRepairGuideResultListWithSubTypeID:subTypeID pageNums:self.pageNums pageSizes:self.pageSizes success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        if (errorCode!=0&&![message isEqualToString:@"返回成功"]) {
            if (reloadAll) {
                [ProgressHUDHandler dismissHUD];
            }else {
                [self stopRefresh];
                if (!reloadAll) self.pageNums = @(self.pageNums.integerValue-1);
            }
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
            return;
        }
        if (reloadAll) {
            [ProgressHUDHandler dismissHUD];
        }else {
            [self stopRefresh];
        }
        self.totalPageSizes = [SupportingClass verifyAndConvertDataToNumber:responseObject[CDZKeyOfTotalPageSizesKey]];
        self.pageNums = [SupportingClass verifyAndConvertDataToNumber:responseObject[CDZKeyOfPageNumsKey]];
        self.pageSizes = [SupportingClass verifyAndConvertDataToNumber:responseObject[CDZKeyOfPageSizesKey]];
        
        self.tableView.mj_footer.hidden = ((self.pageNums.intValue*self.pageSizes.intValue)>=self.totalPageSizes.intValue);
        [self.dataList addObjectsFromArray:responseObject[CDZKeyOfResultKey]];
        [self.tableView reloadData];
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        NSLog(@"%@",error);
        @strongify(self);
        if (reloadAll) {
            [ProgressHUDHandler showError];
        }else {
            [self stopRefresh];
            if (!reloadAll) self.pageNums = @(self.pageNums.integerValue-1);
        }
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
        return;
    }];
}

- (void)getRepairGuideProcedureDetail:(NSString *)procedureDetailID withTitle:(NSString *)title {
    if (!procedureDetailID||[procedureDetailID isEqualToString:@""]) {
        return;
    }
    [ProgressHUDHandler showHUD];
    @weakify(self);
    [APIsConnection.shareConnection repairGuideAPIsGetRepairGuideProcedureDetailWithProcedureDetailID:procedureDetailID success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        [ProgressHUDHandler dismissHUD];
        if (errorCode!=0&&![message isEqualToString:@"返回成功"]) {
            [ProgressHUDHandler dismissHUD];
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
            return;
        }
        NSDictionary *procedureDetail = responseObject[CDZKeyOfResultKey];
        if (procedureDetail.count>0&&procedureDetail) {
            RepairGudieProcedureVC *vc = [RepairGudieProcedureVC new];
            vc.procedureDetail = procedureDetail;
            vc.title = title;
            [self setDefaultNavBackButtonWithoutTitle];
            [self.navigationController pushViewController:vc animated:YES];
        }
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        NSLog(@"%@",error);
        [ProgressHUDHandler showError];
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
        return;
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
