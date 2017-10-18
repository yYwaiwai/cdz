//
//  RepairServiceItemSelectionVC.m
//  cdzer
//
//  Created by KEns0nLau on 9/19/16.
//  Copyright © 2016 CDZER. All rights reserved.
//
#define kCellIdentSpaceKey @"spaceCell"
#import "RepairServiceItemSelectionVC.h"
#import "RepairServiceItemImage.h"
#import "RepairServiceItemCell.h"
#import "UIView+LayoutConstraintHelper.h"
#import "RepairAppiontmentVC.h"
#import "SMSLResultDTO.h"
#import <M13BadgeView/M13BadgeView.h>

@interface RepairServiceItemSelectionVC () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIView *typeButtonContainerView;

@property (weak, nonatomic) IBOutlet UIView *bottomInfoContainerView;

@property (weak, nonatomic) IBOutlet UIImageView *selectedIconIV;

@property (weak, nonatomic) IBOutlet UILabel *selectedItemCountLabel;

@property (weak, nonatomic) IBOutlet UITableView *selectedTableView;

@property (weak, nonatomic) IBOutlet UIView *selectedTableViewMaskView;

@property (weak, nonatomic) IBOutlet UIView *selectedTableViewContainView;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *selectedTVHeightConstraint;



@property (nonatomic, strong) NSArray <NSString *> *repairItem;

@property (nonatomic, strong) NSArray <NSString *> *maintainItem;

@property (nonatomic, strong) M13BadgeView *badgeView;

@property (nonatomic) BOOL isMaintainOption;

@end

@implementation RepairServiceItemSelectionVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"选择预约项目";
    self.edgesForExtendedLayout = UIRectEdgeTop;
    // Do any additional setup after loading the view from its nib.
    [self componentSetting];
    [self initializationUI];
    [self setReactiveRules];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self.typeButtonContainerView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self.bottomInfoContainerView setViewBorderWithRectBorder:UIRectBorderTop borderSize:0.5 withColor:nil withBroderOffset:nil];
}

- (void)handleNavBackBtnPopOtherAction {
    @autoreleasepool {
        
    }
}

- (void)componentSetting {
    @autoreleasepool {
        self.repairItem = [self.shopDetail[@"repair_item"] valueForKey:@"name"];
        if (!self.repairSelectedIndexPath) self.repairSelectedIndexPath = [NSMutableSet set];
        
        self.maintainItem = [self.shopDetail[@"maintain_item"] valueForKey:@"name"];
        if (!self.maintainSelectedIndexPath) self.maintainSelectedIndexPath = [NSMutableSet set];
        
        
        [self.tableView registerNib:[UINib nibWithNibName:@"RepairServiceItemCell" bundle:nil] forCellReuseIdentifier:CDZKeyOfCellIdentKey];
        self.tableView.tableFooterView = [UIView new];
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 44;
        
        
        [self.selectedTableView registerNib:[UINib nibWithNibName:@"RepairServiceItemSpaceCell" bundle:nil] forCellReuseIdentifier:kCellIdentSpaceKey];
        [self.selectedTableView registerNib:[UINib nibWithNibName:@"RepairServiceItemCell" bundle:nil] forCellReuseIdentifier:CDZKeyOfCellIdentKey];
        self.selectedTableView.rowHeight = UITableViewAutomaticDimension;
        self.selectedTableView.estimatedRowHeight = 44;
        self.selectedTableView.tableFooterView = [UIView new];
        
        BorderOffsetObject *offsetObject = [BorderOffsetObject new];
        offsetObject.bottomLeftOffset = -8;
        offsetObject.bottomRightOffset = offsetObject.bottomLeftOffset;
        self.isMaintainOption = NO;
        UILabel *leftLabel = (UILabel *)[[self.typeButtonContainerView viewWithTag:2] viewWithTag:1];
        leftLabel.highlighted = YES;
        [leftLabel setViewBorderWithRectBorder:UIRectBorderBottom borderSize:1 withColor:[UIColor colorWithHexString:@"49C7F5"] withBroderOffset:offsetObject];
    }
}

- (void)initializationUI {
    @autoreleasepool {
        
        if (!self.badgeView) {
            self.badgeView = [[M13BadgeView alloc] initWithFrame:CGRectMake(0, 0, 14.0, 14.0)];
            self.badgeView.text = @"0";
            self.badgeView.font = [UIFont systemFontOfSize:11.0];
            self.badgeView.textColor = CDZColorOfWhite;
            self.badgeView.badgeBackgroundColor = CDZColorOfWeiboColor;
            self.badgeView.borderColor = self.badgeView.textColor;
            self.badgeView.hidesWhenZero = YES;
            self.badgeView.borderWidth = 0.5f;
            self.badgeView.alignmentShift = CGSizeMake(-4, 4);
            self.badgeView.cornerRadius = ceilf(CGRectGetHeight(self.badgeView.frame)/2.0f);
            self.badgeView.horizontalAlignment = M13BadgeViewHorizontalAlignmentRight;
            self.badgeView.verticalAlignment = M13BadgeViewVerticalAlignmentTop;
        }
        
        [self.selectedIconIV addSubview:self.badgeView];
        self.badgeView.horizontalAlignment = M13BadgeViewHorizontalAlignmentRight;
        self.badgeView.verticalAlignment = M13BadgeViewVerticalAlignmentTop;
        self.badgeView.text = @"0";
        
        [self.selectedTableView reloadData];
        [self repairTypeSelection:[self.typeButtonContainerView viewWithTag:(self.isMaintainOption+2)]];
        [self updateSelectedItemCount];
    }
}

- (void)setReactiveRules {
    @autoreleasepool {
        @weakify(self);
        [RACObserve(self, selectedTableView.contentSize) subscribeNext:^(id size) {
            @strongify(self);
            CGSize contentSize = [size CGSizeValue];
            CGFloat maxHeight = CGRectGetHeight(self.selectedTableViewMaskView.frame)*(IS_IPHONE_4_OR_LESS?0.7:0.5);
            if (contentSize.height>maxHeight) {
                contentSize.height = maxHeight;
            }
            self.selectedTVHeightConstraint.constant = contentSize.height;
        }];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView==self.selectedTableView) return 2;
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (tableView==self.selectedTableView) {
        NSUInteger count = self.maintainSelectedIndexPath.count;
        if (section==0) {
            count = self.repairSelectedIndexPath.count;
            count++;
        }
        return count;
    }
    
    
    if (self.isMaintainOption) {
        return self.maintainItem.count;
    }
    return self.repairItem.count;;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView==self.selectedTableView) {
        return 34;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (tableView==self.tableView) {
        return nil;
    }
    static NSString *ident = @"headerView";
    UITableViewHeaderFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:ident];
    if (!headerView) {
        headerView = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:ident];
        headerView.contentView.backgroundColor = CDZColorOfWhite;
        
        UIImageView *indicatorView = [[UIImageView alloc] initWithFrame:CGRectMake(12.0f, 0.0f, 3, 14)];
        indicatorView.translatesAutoresizingMaskIntoConstraints = NO;
        indicatorView.backgroundColor = [UIColor colorWithHexString:@"49C7F5"];
        [indicatorView addSelfByFourMarginToSuperview:headerView.contentView withEdgeConstant:UIEdgeInsetsMake(0.0f, 12.0f, 0.0f, 0.0)andLayoutAttribute:LayoutHelperAttributeLeading];
        [indicatorView addSelfByCenterOffsetToSuperview:headerView.contentView withOffsetPoint:CGPointMake(0, 0) multiplierPoint:CGPointMake(0, 0) andLayoutAttribute:LayoutHelperAttributeCenterY];
        [indicatorView addSelfViewSize:CGSizeMake(3, 14)];
        
        UILabel *titleLabel = [UILabel new];
        titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        titleLabel.tag = 1010;
        titleLabel.font = [UIFont systemFontOfSize:14];
        titleLabel.textColor = [UIColor colorWithHexString:@"323232"];
        [titleLabel addSelfByFourMarginToSuperview:headerView.contentView withEdgeConstant:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0)andLayoutAttribute:LayoutHelperAttributeTop|LayoutHelperAttributeBottom];
        [headerView.contentView addConstraint:[NSLayoutConstraint constraintWithItem:titleLabel
                                                                           attribute:NSLayoutAttributeLeading
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:indicatorView
                                                                           attribute:NSLayoutAttributeTrailing
                                                                          multiplier:1
                                                                            constant:12]];
        
        UILabel *reminderLabel = [UILabel new];
        reminderLabel.translatesAutoresizingMaskIntoConstraints = NO;
        reminderLabel.tag = 1011;
        reminderLabel.text = @"服务建议：维修请到店诊断";
        reminderLabel.font = [UIFont systemFontOfSize:11];
        reminderLabel.textColor = [UIColor colorWithHexString:@"909090"];
        [reminderLabel addSelfByFourMarginToSuperview:headerView.contentView withEdgeConstant:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0)andLayoutAttribute:LayoutHelperAttributeTop|LayoutHelperAttributeBottom];
        [headerView.contentView addConstraint:[NSLayoutConstraint constraintWithItem:reminderLabel
                                                                           attribute:NSLayoutAttributeLeading
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:titleLabel
                                                                           attribute:NSLayoutAttributeTrailing
                                                                          multiplier:1
                                                                            constant:12]];

        
    }
    UILabel *titleLabel = (UILabel *)[headerView viewWithTag:1010];
    titleLabel.text = (section==0)?@"维修项目":@"保养项目";
    [headerView viewWithTag:1011].hidden = (section==1);
    
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView==self.selectedTableView&&
        ((indexPath.row==self.repairSelectedIndexPath.count)||self.repairSelectedIndexPath.count==0)&&
        indexPath.section==0) {
        RepairServiceItemSpaceCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentSpaceKey forIndexPath:indexPath];
        return cell;
    }
    
    RepairServiceItemCell *cell = [tableView dequeueReusableCellWithIdentifier:CDZKeyOfCellIdentKey forIndexPath:indexPath];
    cell.workingPriceContainerView.hidden = YES;
    cell.workingPriceLabel.text = @"0";
    cell.rectBorder = UIRectBorderNone;
    cell.allIVHighlighted = NO;
    
    
    if (tableView==self.selectedTableView) {
        cell.rectBorder = UIRectBorderTop;
        cell.allIVHighlighted = YES;
        NSArray <NSString *> *itemArray = self.repairItem;
        NSArray <NSIndexPath *> *itemIdxArray = self.repairSelectedIndexPath.allObjects;
        if (indexPath.section==1) {
            itemArray = self.maintainItem;
            itemIdxArray = self.maintainSelectedIndexPath.allObjects;
        }
        NSIndexPath *theIndexPath = itemIdxArray[indexPath.row];
        [cell updateItemName:itemArray[theIndexPath.row]];
//        cell.workingPriceContainerView.hidden = YES;
//        cell.workingPriceLabel.text = @"0";
    }else {
        NSArray <NSString *> *itemArray = self.repairItem;
        if (self.isMaintainOption) itemArray = self.maintainItem;
        [cell updateItemName:itemArray[indexPath.row]];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView==self.tableView) {
        if (self.isMaintainOption) {
            [self.maintainSelectedIndexPath addObject:indexPath];
        }else {
            [self.repairSelectedIndexPath addObject:indexPath];
        }
        [self updateSelectedItemCount];
    }else {
        NSArray <NSString *> *itemArray = self.repairItem;
        NSMutableSet <NSIndexPath *> *itemIdxArray = self.repairSelectedIndexPath;
        if (indexPath.section==1) {
            itemArray = self.maintainItem;
            itemIdxArray = self.maintainSelectedIndexPath;
        }
        NSIndexPath *theIndexPath = itemIdxArray.allObjects[indexPath.row];
        [itemIdxArray removeObject:theIndexPath];
        [self.selectedTableView reloadData];
        [self repairTypeSelection:[self.typeButtonContainerView viewWithTag:(self.isMaintainOption+2)]];
        [self updateSelectedItemCount];
        NSUInteger count = self.repairSelectedIndexPath.count+self.maintainSelectedIndexPath.count;
        if (count==0) [self showOrHideSelectedDisplayView];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (tableView==self.tableView) {
        if (self.isMaintainOption) {
            [self.maintainSelectedIndexPath removeObject:indexPath];
        }else {
            [self.repairSelectedIndexPath removeObject:indexPath];
        }
        [self updateSelectedItemCount];
    }
}

- (IBAction)removeAllSelection {
    [self.repairSelectedIndexPath removeAllObjects];
    [self.maintainSelectedIndexPath removeAllObjects];
    [self.selectedTableView reloadData];
    [self repairTypeSelection:[self.typeButtonContainerView viewWithTag:(self.isMaintainOption+2)]];
    [self updateSelectedItemCount];
    [self showOrHideSelectedDisplayView];
}

- (IBAction)showOrHideSelectedDisplayView {
    BOOL isShow = !self.selectedTableViewMaskView.alpha;
    self.selectedTableViewMaskView.superview.hidden = !isShow;
    @weakify(self);
    [UIView animateWithDuration:0.25 animations:^{
        @strongify(self);
        self.selectedTableViewMaskView.alpha = isShow;
    }];
    if (isShow) [self.selectedTableView reloadData];
}

- (IBAction)repairTypeSelection:(UIControl *)sender {
    
    BorderOffsetObject *offsetObject = [BorderOffsetObject new];
    offsetObject.bottomLeftOffset = -8;
    offsetObject.bottomRightOffset = offsetObject.bottomLeftOffset;

    if (sender.tag==2) {
        self.isMaintainOption = NO;
        UILabel *leftLabel = (UILabel *)[sender viewWithTag:1];
        leftLabel.highlighted = YES;
        [leftLabel setViewBorderWithRectBorder:UIRectBorderBottom borderSize:1 withColor:[UIColor colorWithHexString:@"49C7F5"] withBroderOffset:offsetObject];
        
        UILabel *rightLabel = (UILabel *)[[self.typeButtonContainerView viewWithTag:3] viewWithTag:1];
        rightLabel.highlighted = NO;
        [rightLabel setViewBorderWithRectBorder:UIRectBorderNone borderSize:1 withColor:nil withBroderOffset:nil];
        [self.tableView reloadData];
        [self.repairSelectedIndexPath enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, BOOL * _Nonnull stop) {
            [self.tableView selectRowAtIndexPath:obj animated:NO scrollPosition:UITableViewScrollPositionNone];
        }];
    }else if(sender.tag==3) {
        self.isMaintainOption = YES;
        UILabel *rightLabel = (UILabel *)[sender viewWithTag:1];
        rightLabel.highlighted = YES;
        [rightLabel setViewBorderWithRectBorder:UIRectBorderBottom borderSize:1 withColor:[UIColor colorWithHexString:@"49C7F5"] withBroderOffset:offsetObject];
        
        UILabel *leftLabel = (UILabel *)[[self.typeButtonContainerView viewWithTag:2] viewWithTag:1];
        leftLabel.highlighted = NO;
        [leftLabel setViewBorderWithRectBorder:UIRectBorderNone borderSize:1 withColor:nil withBroderOffset:nil];
        [self.tableView reloadData];
        [self.maintainSelectedIndexPath enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, BOOL * _Nonnull stop) {
            [self.tableView selectRowAtIndexPath:obj animated:NO scrollPosition:UITableViewScrollPositionNone];
        }];
    }
}

- (void)updateSelectedItemCount {
    NSUInteger count = self.repairSelectedIndexPath.count+self.maintainSelectedIndexPath.count;
    self.badgeView.text = @(count).stringValue;
    self.selectedItemCountLabel.text = self.badgeView.text;
    self.selectedIconIV.highlighted = (count>0);
}

- (IBAction)submitSelectedServiceItems {
    NSUInteger count = self.repairSelectedIndexPath.count+self.maintainSelectedIndexPath.count;
    if (count==0) {
        [SupportingClass showAlertViewWithTitle:@"" message:@"请选择维修项目" isShowImmediate:YES cancelButtonTitle:nil otherButtonTitles:nil clickedButtonAtIndexWithBlock:nil];
        return;
    }
    RepairAppiontmentVC *vc = nil;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.class == %@", RepairAppiontmentVC.class];
    NSArray *result = [self.navigationController.viewControllers filteredArrayUsingPredicate:predicate];
    if (result&&result.count>0) {
        if (self.resultBlock) {
            self.resultBlock (self.repairSelectedIndexPath, self.maintainSelectedIndexPath);
        }
        [self.navigationController popToViewController:result.lastObject animated:YES];
        return;
    }
    
    vc = [RepairAppiontmentVC new];
    vc.isSpecServiceShop = self.isSpecServiceShop;
    vc.shopDetail = self.shopDetail;
    vc.selectedMechanicDetail = self.selectedMechanicDetail;
    vc.repairSelectedIndexPath = [self.repairSelectedIndexPath mutableCopy];
    vc.maintainSelectedIndexPath = [self.maintainSelectedIndexPath mutableCopy];
    [self setDefaultNavBackButtonWithoutTitle];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
