//
//  MaintenanceItemDispalyView.m
//  cdzer
//
//  Created by KEns0nLau on 9/12/16.
//  Copyright © 2016 CDZER. All rights reserved.
//


#define kHeaderViewDefaultIdent @"headerView"

#import "MaintenanceItemDispalyView.h"
#import "UIView+LayoutConstraintHelper.h"
#import "MaintenanceItemDispalyViewCell.h"
#import "MaintenanceItemDispalyViewEmptyCell.h"
#import "ReplacementOfGoodsVC.h"
#import "MaintenanceItemDispalyViewHeaderCell.h"
#import "UserAutosSelectonVC.h"
#import "PartsDetailVC.h"

@interface MaintenanceItemDispalyView () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSLayoutConstraint *tableViewHeightConstraint;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray <MaintenanceTypeDTO *> *maintenanceItemInnerList;

@end

@implementation MaintenanceItemDispalyView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)reloadDataSource:(NSMutableArray<MaintenanceTypeDTO *> *)maintenanceItemList {
    self.maintenanceItemInnerList = maintenanceItemList;
    [self reloadTableDataNTotalPrice];
}

- (void)reloadTableDataNTotalPrice {
    [self.tableView reloadData];
    if (self.reloadResponsBlock) {
        self.reloadResponsBlock();
    }
}

- (float)getTotalPrice {
    __block float totalPrice = 0;
    [self.maintenanceItemInnerList enumerateObjectsUsingBlock:^(MaintenanceTypeDTO * _Nonnull typeDTO, NSUInteger idx, BOOL * _Nonnull stop) {
        if (typeDTO.isSelectedItem) {
            [typeDTO.maintenanceProductItemList enumerateObjectsUsingBlock:^(MaintenanceProductItemDTO * _Nonnull productItemDTO, NSUInteger idx, BOOL * _Nonnull stop) {
                float itemPrice = (productItemDTO.currentSelectedCount*productItemDTO.productPrice.floatValue);
                totalPrice += itemPrice;
            }];
        }
    }];
    return totalPrice;
}

- (NSArray <MaintenanceTypeDTO *> *)maintenanceItemList {
    return [NSArray arrayWithArray:self.maintenanceItemInnerList];
}

- (NSArray <MaintenanceTypeDTO *> *)selelctedMaintenanceItemList {
    NSMutableArray <MaintenanceTypeDTO *> *selectedList = [@[] mutableCopy];
    [self.maintenanceItemInnerList enumerateObjectsUsingBlock:^(MaintenanceTypeDTO * _Nonnull typeDTO, NSUInteger idx, BOOL * _Nonnull stop) {
        if (typeDTO.isSelectedItem) {
            [selectedList addObject:typeDTO];
        }
    }];
    return [NSArray arrayWithArray:selectedList];
}

- (void)setIsDeepMaintenanceItem:(BOOL)isDeepMaintenanceItem {
    _isDeepMaintenanceItem = isDeepMaintenanceItem;
    self.titleLabel.text = isDeepMaintenanceItem?@"深度保养项目":@"常规保养项目";
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self componentSetting];
    [self initializationUI];
    [self setReactiveRules];
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];    
    [[self viewWithTag:909] setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
}

- (void)componentSetting {
    @autoreleasepool {
        
    }
}

- (void)initializationUI {
    @autoreleasepool {
        UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), 34)];
        titleView.tag = 909;
        titleView.translatesAutoresizingMaskIntoConstraints = NO;
        [titleView addSelfByFourMarginToSuperview:self withEdgeConstant:UIEdgeInsetsZero andLayoutAttribute:LayoutHelperAttributeTop|LayoutHelperAttributeLeading|LayoutHelperAttributeTrailing];
        
        [titleView addConstraint:[NSLayoutConstraint constraintWithItem:titleView
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                             multiplier:1
                                                               constant:34]];
        [titleView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
        
        UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 3, 12)];
        iconView.translatesAutoresizingMaskIntoConstraints = NO;
        iconView.backgroundColor = CDZColorByHexString(@"49c7f5");
        [iconView addSelfByFourMarginToSuperview:titleView withEdgeConstant:UIEdgeInsetsMake(0.0f, 12.0f, 0.0f, 0.0f) andLayoutAttribute:LayoutHelperAttributeLeading];
        
        [titleView addConstraint:[NSLayoutConstraint constraintWithItem:iconView
                                                              attribute:NSLayoutAttributeCenterY
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:titleView
                                                              attribute:NSLayoutAttributeCenterY
                                                             multiplier:1
                                                               constant:0]];
        
        [iconView addConstraint:[NSLayoutConstraint constraintWithItem:iconView
                                                             attribute:NSLayoutAttributeWidth
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:nil
                                                             attribute:NSLayoutAttributeNotAnAttribute
                                                            multiplier:1
                                                              constant:3]];
        
        [iconView addConstraint:[NSLayoutConstraint constraintWithItem:iconView
                                                             attribute:NSLayoutAttributeHeight
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:nil
                                                             attribute:NSLayoutAttributeNotAnAttribute
                                                            multiplier:1
                                                              constant:14]];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), 34)];
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.titleLabel.font = [self.titleLabel.font fontWithSize:13];
        self.titleLabel.textColor = CDZColorByHexString(@"646464");
        [self.titleLabel addSelfByFourMarginToSuperview:titleView withEdgeConstant:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 12.0f) andLayoutAttribute:LayoutHelperAttributeTop|LayoutHelperAttributeBottom|LayoutHelperAttributeTrailing];
        
        [titleView addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel
                                                              attribute:NSLayoutAttributeLeading
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:iconView
                                                              attribute:NSLayoutAttributeTrailing
                                                             multiplier:1
                                                               constant:10]];
        
        
        self.tableView = [[UITableView alloc] initWithFrame:self.bounds];
        self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 100;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.bounces = NO;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        [self.tableView registerNib:[UINib nibWithNibName:@"MaintenanceItemDispalyViewCell" bundle:nil] forCellReuseIdentifier:CDZKeyOfCellIdentKey];
        [self.tableView registerNib:[UINib nibWithNibName:@"MaintenanceItemDispalyViewEmptyCell" bundle:nil] forCellReuseIdentifier:@"MIDVEmptyCell"];
        [self.tableView registerClass:MaintenanceItemDispalyViewHeaderCell.class forHeaderFooterViewReuseIdentifier:kHeaderViewDefaultIdent];
        [self.tableView addSelfByFourMarginToSuperview:self withEdgeConstant:UIEdgeInsetsZero andLayoutAttribute:LayoutHelperAttributeLeading|LayoutHelperAttributeBottom|LayoutHelperAttributeTrailing];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:titleView
                                                         attribute:NSLayoutAttributeBottom
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.tableView
                                                         attribute:NSLayoutAttributeTop
                                                        multiplier:1
                                                          constant:0]];
        self.tableViewHeightConstraint = [NSLayoutConstraint constraintWithItem:self.tableView
                                                                      attribute:NSLayoutAttributeHeight
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:nil
                                                                      attribute:NSLayoutAttributeNotAnAttribute
                                                                     multiplier:1
                                                                       constant:0];
        [self.tableView addConstraint:self.tableViewHeightConstraint];
        
        
        __block NSLayoutConstraint *superviewHeightConstraint = nil;
        @weakify(self);
        [self.constraints enumerateObjectsUsingBlock:^(__kindof NSLayoutConstraint * _Nonnull constraint, NSUInteger idx, BOOL * _Nonnull stop) {
            @strongify(self);
            if (constraint.firstItem==self&&constraint.firstAttribute==NSLayoutAttributeHeight) {
                superviewHeightConstraint = constraint;
            }
        }];
        if (superviewHeightConstraint) {
            [self removeConstraint:superviewHeightConstraint];
            superviewHeightConstraint = nil;
        }

        self.isDeepMaintenanceItem = NO;
        [self setNeedsLayout];
    }
}

- (void)setReactiveRules {
    @weakify(self);
    [RACObserve(self, tableView.contentSize) subscribeNext:^(id size) {
        @strongify(self);
        CGSize contentSize = [size CGSizeValue];
        self.tableViewHeightConstraint.constant = contentSize.height;
        [self setNeedsDisplay];
        [self setNeedsLayout];
        [self setNeedsUpdateConstraints];
    }];
}

//- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
//    NSString *text = @"暂无更多数据！";
//    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0f],
//                                 NSForegroundColorAttributeName: [UIColor darkGrayColor]};
//    
//    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
//}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return self.maintenanceItemList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (self.maintenanceItemList.count>0) {
        MaintenanceTypeDTO *dto = self.maintenanceItemList[section];
        if (dto.maintenanceProductItemList.count==0) return 1;
        if (dto.isSelectedItem) return dto.maintenanceProductItemList.count;   
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 34.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    MaintenanceItemDispalyViewHeaderCell *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kHeaderViewDefaultIdent];
    headerView.sectionIdx = section;
    MaintenanceTypeDTO *dto = self.maintenanceItemInnerList[section];
    [headerView updateUIData:dto];
    if (!headerView.actionBlock) {
        @weakify(self);
        headerView.actionBlock = ^(MIDVHCButtonAction buttonAction, NSUInteger sectionIdx) {
            @strongify(self);
            MaintenanceTypeDTO *theDto = self.maintenanceItemList[sectionIdx];
            switch (buttonAction) {
                case MIDVHCButtonActionOfEditing:
                    theDto.isEditing = YES;
                    theDto.isSelectedItem = YES;
                    break;
                case MIDVHCButtonActionOfUpdateChange:
                    theDto.isEditing = NO;
                    break;
                case MIDVHCButtonActionOfDetailExpand:
                    theDto.isSelectedItem = !theDto.isSelectedItem;
                    break;
                    
                default:
                    break;
            }
            [self reloadTableDataNTotalPrice];
        };
    }
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MaintenanceTypeDTO *mainDto = self.maintenanceItemInnerList[indexPath.section];
    if (mainDto.maintenanceProductItemList.count==0) {
        MaintenanceItemDispalyViewEmptyCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MIDVEmptyCell" forIndexPath:indexPath];
        return cell;
    }
    MaintenanceProductItemDTO *productItemDTO = mainDto.maintenanceProductItemList[indexPath.row];
    MaintenanceItemDispalyViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CDZKeyOfCellIdentKey forIndexPath:indexPath];
    cell.indexPath = indexPath;
    [cell updateUIData:productItemDTO wasEditingMode:mainDto.isEditing];
    if (!cell.actionBlock) {
        @weakify(self);
        cell.actionBlock = ^(MIDVCButtonAction buttonAction, NSIndexPath *indexPath) {
            @strongify(self);
            MaintenanceTypeDTO *mainDto = self.maintenanceItemInnerList[indexPath.section];
            MaintenanceProductItemDTO *productItemDTO = mainDto.maintenanceProductItemList[indexPath.row];
            switch (buttonAction) {
                case MIDVCButtonActionOfProductCountMinus:{
                    productItemDTO.currentSelectedCount--;
                }
                    break;
                case MIDVCButtonActionOfProductCountPlus:{
                    productItemDTO.currentSelectedCount++;
                }
                    break;
                case MIDVCButtonActionOfProductDelete:
                    productItemDTO = nil;
                    NSUInteger currentCount = 0;
                    for (int count=0; count<self.maintenanceItemInnerList.count; count++) {
                        currentCount += self.maintenanceItemInnerList[count].maintenanceProductItemList.count;
                    }
                    if (self.otherSourceCountingBlock) {
                        __weak MaintenanceItemDispalyView *weakSelf = self;
                        currentCount += self.otherSourceCountingBlock(weakSelf);
                    }
                    if (currentCount<=1) {
                        [SupportingClass showAlertViewWithTitle:nil message:@"请保留至少一项" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:nil];
                        return;
                    }
                    [mainDto removeProductItemFormByIndex:indexPath.row];
                    if (mainDto.maintenanceProductItemList.count==0) {
                        [self.maintenanceItemInnerList removeObjectAtIndex:indexPath.section];
                    }
                    [self reloadTableDataNTotalPrice];
                    break;
                case MIDVCButtonActionOfProductExchange:
                    [self pushToGoodsReplaceVC:indexPath];
                    break;
                    
                default:
                    break;
            }
        };
    }
    return cell;
}

- (void)pushToGoodsReplaceVC:(NSIndexPath *)indexPath {
    @autoreleasepool {
        UIViewController *rootVC = UIApplication.sharedApplication.keyWindow.rootViewController;
        if (rootVC) {
            MaintenanceTypeDTO *mainDto = self.maintenanceItemInnerList[indexPath.section];
            MaintenanceProductItemDTO *productItemDTO = mainDto.maintenanceProductItemList[indexPath.row];
            UserSelectedAutosInfoDTO *autosData = [DBHandler.shareInstance getSelectedAutoData];
            
            ReplacementOfGoodsVC *vc = [ReplacementOfGoodsVC new];
            vc.productItemDTO = productItemDTO;
            vc.carModels = autosData.modelID;
            if (!vc.selectedResultBlock) {
                @weakify(self);
                vc.selectedResultBlock = ^(MaintenanceProductItemDTO *productItemDTO){
                    @strongify(self);
                    MaintenanceTypeDTO *theMainDto = self.maintenanceItemInnerList[indexPath.section];
                    [theMainDto replaceProductItemFormByIndex:indexPath.row withProductItemDTO:productItemDTO];
                    [self reloadTableDataNTotalPrice];
                };
            }
            vc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            [rootVC presentViewController:vc animated:YES completion:nil];
        }
        
        
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MaintenanceTypeDTO *mainDto = self.maintenanceItemInnerList[indexPath.section];
    BOOL partsIsEmpty = (mainDto.maintenanceProductItemList.count==0);
    if (!mainDto.isEditing&&!partsIsEmpty) {
        MaintenanceProductItemDTO *productItemDTO = mainDto.maintenanceProductItemList[indexPath.row];
        [self getPartsDetailWithPartsID:productItemDTO.productID];
    }
}



- (void)pushPartItemDetailViewWithItemDetail:(id)detail {
    if (!detail||![detail isKindOfClass:[NSDictionary class]]) {
        return;
    }
    
    @autoreleasepool {
        UINavigationController *nav = (UINavigationController *)UIApplication.sharedApplication.keyWindow.rootViewController;
        PartsDetailVC *vc = [PartsDetailVC new];
        vc.itemDetail = detail;
        vc.hiddenExpressBtnNCartAddBtnNGPSBtn = YES;
        [nav.visibleViewController setDefaultNavBackButtonWithoutTitle];
        [nav pushViewController:vc animated:YES];
    }
}
/* 配件详情 */
- (void)getPartsDetailWithPartsID:(NSString *)partsID {
    [ProgressHUDHandler showHUDWithTitle:getLocalizationString(@"loading") onView:nil];
    [[APIsConnection shareConnection] theSelfMaintenanceAPIsGetItemDetailWithWithAccessToken:vGetUserToken productID:partsID success:^(NSURLSessionDataTask *operation, id responseObject) {
        
        
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"2%@",message);
        if(errorCode!=0){
            [ProgressHUDHandler dismissHUD];
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                
            }];
            return;
        }
        [ProgressHUDHandler dismissHUDWithCompletion:^{
            [self pushPartItemDetailViewWithItemDetail:responseObject[CDZKeyOfResultKey]];
        }];
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        
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


@end
