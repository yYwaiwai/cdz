//
//  SNSSLViewFilterComponent.m
//  cdzer
//
//  Created by KEns0nLau on 8/10/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#define vMainTypeHeight 316.0f
#define vSubTypeHeight 165.0f
#import "SNSSLViewFilterComponent.h"
#import "UserSelectedAutosInfoDTO.h"
#import "SNSSLVFItemBrandListComponent.h"
#import "AutosBrandDTO.h"

@interface SNSSLViewFilterView () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UIView *backgroundMaskView;//背景视图
@property (nonatomic, weak) IBOutlet UIControl *mainTypeBtnControlView;//主选项按钮
@property (nonatomic, weak) IBOutlet UIControl *subTypeBtnControlView;//次选项按钮
@property (nonatomic, weak) IBOutlet UIControl *itemBrandTypeBtnControlView;//次选项按钮
@property (nonatomic, weak) IBOutlet UIView *filterBtnsContainerView;//按钮主视图
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *itemBrandControlViewWidthConstraint;


@property (nonatomic, weak) IBOutlet UIView *mainTypeContainerView;//主选项主视图
@property (nonatomic, weak) IBOutlet UIControl *mainTypeOfAllBtnControlView;//主选项全部按钮
@property (nonatomic, weak) IBOutlet UIControl *mainTypeOfBrandBtnControlView;//主选项品牌店按钮
@property (nonatomic, weak) IBOutlet UIControl *mainTypeOfSpcRepairBtnControlView;//主选项专修店按钮
@property (nonatomic, weak) IBOutlet UIView *mainTypeBtnsContainerView;//主选项按钮主视图


@property (nonatomic, weak) IBOutlet UITableView *mainTypeTableView;//主选项TableView
@property (nonatomic, strong) NSMutableArray <NSArray <AutosBrandDTO *> *> *mainTypeBrandSelectionList;//主选项据
@property (nonatomic, strong) NSMutableArray <NSDictionary *> *mainTypeServiceSelectionList;//主选项数据
@property (nonatomic, assign) SNSSLVFilterType mainTypeCurrentSelection;
@property (nonatomic, strong) NSIndexPath *mainTypeCurrentSubSelection;
@property (nonatomic, assign) SNSSLVFilterType lastMainTypeSelectedTagIdx;
@property (nonatomic, strong) NSString *mainTypeSelectedID;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *mainTypeContainerViewHeightConstraint;


@property (nonatomic, weak) IBOutlet UITableView *subTypeTableView;//次选项TableView
@property (nonatomic, strong) NSArray <NSString *> *subTypeSelectionList;//次选项数据
@property (nonatomic, strong) NSIndexPath *subTypeCurrentSelection;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *subTypeTableViewHeightConstraint;


@property (nonatomic, strong) IBOutlet SNSSLVFItemBrandListComponent *itemBrandListView;


@property (nonatomic, strong) NSLayoutConstraint *bottomToSuperviewBottomConstraint;
@property (nonatomic, assign) BOOL wasFilterViewExpand;//选项是否打开
@property (nonatomic, assign) NSInteger lastSelectedBtnTag;//上次主次选项按钮的TagID
@property (nonatomic, strong) NSArray <NSString *> *keyArray;

@end

@implementation SNSSLViewFilterView



- (void)awakeFromNib {
    [super awakeFromNib];
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [self getSpecServiceList];
    [self getAutoBrandList];
    self.itemBrandControlViewWidthConstraint.constant = 0;
    self.subTypeSelectionList = @[@"距离最近", @"好评优先", @"销量最高", @"价格最低", @"价格最高"];
//    self.subTypeSelectionList = @[@"距离最近", @"好评优先", @"销量最高", @"工时最低", @"工时最高"];
    self.mainTypeCurrentSelection = SNSSLVFilterTypeOfAll;
    self.lastMainTypeSelectedTagIdx = self.mainTypeCurrentSelection;
    self.mainTypeCurrentSubSelection = nil;
    self.mainTypeSelectedID = @"";
    self.mainTypeContainerView.hidden = YES;
    self.mainTypeTableView.hidden = YES;
    self.mainTypeContainerViewHeightConstraint.constant = 0;
    [self.mainTypeBtnsContainerView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull view, NSUInteger idx, BOOL * _Nonnull stop) {
        BOOL selected = (view.tag==1);
        view.backgroundColor = selected?CDZColorOfWhite:CDZColorOfClearColor;
        [(UIImageView *)[view viewWithTag:4] setHighlighted:selected];
        [(UILabel *)[view viewWithTag:5] setHighlighted:selected];
        UIColor *borderColor = [UIColor colorWithRed:0.839 green:0.843 blue:0.863 alpha:1.00];
        
        UIRectBorder borderOption = selected?(view.tag==1?UIRectBorderBottom:(UIRectBorderTop|UIRectBorderBottom)):UIRectBorderRight;
        [view setViewBorderWithRectBorder:borderOption borderSize:0.5 withColor:borderColor withBroderOffset:nil];
    }];
    self.mainTypeTableView.rowHeight = 42;
    [self.mainTypeTableView registerNib:[UINib nibWithNibName:@"SNSSLViewFilterMainTypeCell" bundle:nil]
                 forCellReuseIdentifier:@"mainTypeCell"];
    
    self.subTypeCurrentSelection = [NSIndexPath indexPathForRow:0 inSection:0];
    self.subTypeTableView.hidden = YES;
    self.subTypeTableViewHeightConstraint.constant = 0;
    self.subTypeTableView.rowHeight = 33;
    [self.subTypeTableView registerNib:[UINib nibWithNibName:@"SNSSLViewFilterSubTypeCell" bundle:nil]
                forCellReuseIdentifier:@"subTypeCell"];
    
    [self.mainTypeTableView reloadData];
    [self.subTypeTableView reloadData];
    [self.subTypeTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
    
    [[UINib nibWithNibName:@"SNSSLVFItemBrandListComponent" bundle:nil] instantiateWithOwner:self options:nil];
    
    if (self.itemBrandListView&&!self.itemBrandListView.resultBlock) {
        @weakify(self);
        self.itemBrandListView.resultBlock = ^{
            @strongify(self);
            if (self.resultBlock) {
                self.resultBlock();
            }
            [self showFilterViewByBtns:self.itemBrandTypeBtnControlView];
        };
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    UIColor *borderColor = [UIColor colorWithRed:0.839 green:0.843 blue:0.863 alpha:1.00];
    BorderOffsetObject *offset = [BorderOffsetObject new];
    offset.leftUpperOffset = 10;
    offset.leftBottomOffset = 10;
    offset.rightUpperOffset = 10;
    offset.rightBottomOffset = 10;
    [self.mainTypeBtnControlView setViewBorderWithRectBorder:UIRectBorderRight borderSize:0.5 withColor:borderColor withBroderOffset:offset];
    [self.itemBrandTypeBtnControlView setViewBorderWithRectBorder:UIRectBorderLeft borderSize:0.5 withColor:borderColor withBroderOffset:offset];
    [self.filterBtnsContainerView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:borderColor withBroderOffset:nil];
    
    CGFloat height = CGRectGetHeight(self.superview.frame);
    CGFloat constant = (self.wasFilterViewExpand?0:(height-CGRectGetHeight(self.filterBtnsContainerView.frame)));
    self.bottomToSuperviewBottomConstraint.constant = constant;
    
}

- (IBAction)showFilterViewByBtns:(UIControl *)sender {
    BOOL isMainTypeBtn = (sender.tag==1);
    BOOL isSubTypeBtn = (sender.tag==2);
    BOOL isItemBrandTypeBtn = (sender.tag==3);
    if (self.wasFilterViewExpand&&
        self.lastSelectedBtnTag==sender.tag) {
        self.lastSelectedBtnTag = -1;
        [self updateMainTypeStatus:NO andSubTypeStatus:NO itemBrandTypeStatus:NO];
        self.wasFilterViewExpand = NO;
    }else {
        self.lastSelectedBtnTag = sender.tag;
        [self updateMainTypeStatus:isMainTypeBtn andSubTypeStatus:isSubTypeBtn itemBrandTypeStatus:isItemBrandTypeBtn];
        self.wasFilterViewExpand = YES;
    }
    if (self.wasFilterViewExpand) {
        [self showFilterView];
    }else {
        [self hideFilterView];
    }
}

- (void)updateMainTypeStatus:(BOOL)mainTypeSelected andSubTypeStatus:(BOOL)subTypeSelected itemBrandTypeStatus:(BOOL)itemBrandTypeSelected {
    [self.mainTypeBtnControlView.subviews.lastObject.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:UILabel.class]) [(UILabel *)obj setHighlighted:mainTypeSelected];
        if ([obj isKindOfClass:UIImageView.class]) [(UIImageView *)obj setHighlighted:mainTypeSelected];
    }];
    
    [self.subTypeBtnControlView.subviews.lastObject.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:UILabel.class]) [(UILabel *)obj setHighlighted:subTypeSelected];
        if ([obj isKindOfClass:UIImageView.class]) [(UIImageView *)obj setHighlighted:subTypeSelected];
    }];
    
    [self.itemBrandTypeBtnControlView.subviews.lastObject.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:UILabel.class]) [(UILabel *)obj setHighlighted:itemBrandTypeSelected];
        if ([obj isKindOfClass:UIImageView.class]) [(UIImageView *)obj setHighlighted:itemBrandTypeSelected];
    }];
    
    CGFloat mainTypeHeight = mainTypeSelected?vMainTypeHeight:0;
    CGFloat subTypeHeight = subTypeSelected?vSubTypeHeight:0;
    if (mainTypeSelected) {
        self.mainTypeContainerViewHeightConstraint.constant = mainTypeHeight;
        self.mainTypeContainerView.hidden = NO;
        self.subTypeTableView.hidden = YES;
    }
    if (subTypeSelected) {
        self.subTypeTableViewHeightConstraint.constant = subTypeHeight;
        self.subTypeTableView.hidden = NO;
        self.mainTypeContainerView.hidden = YES;
    }
    
    if (itemBrandTypeSelected) {
        self.subTypeTableView.hidden = YES;
        self.mainTypeContainerView.hidden = YES;
        [self.itemBrandListView showItemBrandListView];
    }
    @weakify(self);
    [UIView animateWithDuration:0.25 animations:^{
        @strongify(self)
        CGRect mainTypeFrame = self.mainTypeContainerView.frame;
        mainTypeFrame.size.height = mainTypeHeight;
        self.mainTypeContainerView.frame = mainTypeFrame;
        
        CGRect subTypeFrame = self.subTypeTableView.frame;
        subTypeFrame.size.height = subTypeHeight;
        self.subTypeTableView.frame = subTypeFrame;
        
    } completion:^(BOOL finished) {
        @strongify(self)
        if (!mainTypeSelected) {
            self.mainTypeContainerView.hidden = YES;
            self.mainTypeContainerViewHeightConstraint.constant = mainTypeHeight;
        }
        if (!subTypeSelected) {
            self.subTypeTableView.hidden = YES;
            self.subTypeTableViewHeightConstraint.constant = subTypeHeight;
        }
        
        if (!itemBrandTypeSelected) {
            [self.itemBrandListView hideItemBrandListView];
        }
    }];
}

- (void)showFilterView {
//    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
//    UIView *firstResponder = [keyWindow performSelector:@selector(firstResponder)];
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    self.filterBtnsContainerView.userInteractionEnabled = NO;
    self.bottomToSuperviewBottomConstraint.constant = 0;
    CGRect frame = self.frame;
    frame.size.height = CGRectGetHeight(self.superview.frame);
    self.frame = frame;
    
    @weakify(self);
    [UIView animateWithDuration:0.25 animations:^{
        @strongify(self);
        if (self.lastSelectedBtnTag==3) {
            self.backgroundMaskView.alpha = 0;
        }else {
            self.backgroundMaskView.alpha = self.wasFilterViewExpand;
        }
    } completion:^(BOOL finished) {
        self.filterBtnsContainerView.userInteractionEnabled = YES;
    }];
    
}

- (void)hideFilterView {
    self.filterBtnsContainerView.userInteractionEnabled = NO;
    @weakify(self);
    [UIView animateWithDuration:0.25 animations:^{
        @strongify(self);
        self.backgroundMaskView.alpha = self.wasFilterViewExpand;
    } completion:^(BOOL finished) {
        @strongify(self);
        CGRect frame = self.frame;
        frame.size.height = CGRectGetHeight(self.filterBtnsContainerView.frame);
        self.frame = frame;
        
        CGFloat constant = CGRectGetHeight(self.superview.frame)-CGRectGetHeight(self.filterBtnsContainerView.frame);
        self.bottomToSuperviewBottomConstraint.constant = constant;
        self.filterBtnsContainerView.userInteractionEnabled = YES;
    }];
    
}

- (IBAction)hideFilterViewFromItemBrandList {
    [self showFilterViewByBtns:self.itemBrandTypeBtnControlView];
}

- (IBAction)changeMainTypeSelection:(UIControl *)sender {
    [self updateMainTypeUIStatus:sender];
    self.mainTypeCurrentSelection = sender.tag;
    self.mainTypeTableView.hidden = YES;
    [self.mainTypeTableView reloadData];
    if (sender==self.mainTypeOfAllBtnControlView) {
        self.mainTypeCurrentSubSelection = nil;
        self.mainTypeSelectedID = @"";
        self.itemBrandControlViewWidthConstraint.constant = 0;
        [self.subTypeTableView reloadData];
        self.subTypeCurrentSelection = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.subTypeTableView selectRowAtIndexPath:self.subTypeCurrentSelection animated:NO scrollPosition:UITableViewScrollPositionNone];
        [self showFilterViewByBtns:self.mainTypeBtnControlView];
        if (self.resultBlock) {
            self.resultBlock();
        }
        return;
    }
    
    if (sender==self.mainTypeOfSpcRepairBtnControlView){
        
    }else if(sender==self.mainTypeOfSpcRepairBtnControlView){
        
    }
    self.mainTypeTableView.hidden = NO;
    [self.mainTypeTableView reloadData];
    
}

- (void)updateMainTypeUIStatus:(UIControl *)sender {
    [self.mainTypeBtnsContainerView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull view, NSUInteger idx, BOOL * _Nonnull stop) {
        BOOL selected = (sender==view);
        view.backgroundColor = selected?CDZColorOfWhite:CDZColorOfClearColor;
        [(UIImageView *)[view viewWithTag:4] setHighlighted:selected];
        [(UILabel *)[view viewWithTag:5] setHighlighted:selected];
        UIColor *borderColor = [UIColor colorWithRed:0.839 green:0.843 blue:0.863 alpha:1.00];
        
        UIRectBorder borderOption = selected?(sender.tag==1?UIRectBorderBottom:(UIRectBorderTop|UIRectBorderBottom)):UIRectBorderRight;
        [view setViewBorderWithRectBorder:borderOption borderSize:0.5 withColor:borderColor withBroderOffset:nil];
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.mainTypeCurrentSelection==SNSSLVFilterTypeOfBrandOption&&self.mainTypeTableView==tableView) return self.mainTypeBrandSelectionList.count;
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView==self.subTypeTableView) {
        return self.subTypeSelectionList.count;
    }
    NSUInteger count = 0;
    if (self.mainTypeCurrentSelection==SNSSLVFilterTypeOfBrandOption) {
        count = [self.mainTypeBrandSelectionList[section] count];
    }else if (self.mainTypeCurrentSelection==SNSSLVFilterTypeOfSpecRepairOption) {
        count = self.mainTypeServiceSelectionList.count;
    }
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.mainTypeCurrentSelection==SNSSLVFilterTypeOfBrandOption&&self.mainTypeTableView==tableView) {
        return 30.0f;
    }
    return 0.0f;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.mainTypeCurrentSelection==SNSSLVFilterTypeOfBrandOption&&self.mainTypeTableView==tableView) {
        return self.keyArray[section];
    }
    return nil;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (self.mainTypeCurrentSelection==SNSSLVFilterTypeOfBrandOption&&self.mainTypeTableView==tableView) {
        return self.keyArray;
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView==self.subTypeTableView) {
        static NSString *ident = @"subTypeCell";
        SNSSLViewFilterSubTypeCell *cell = [tableView dequeueReusableCellWithIdentifier:ident forIndexPath:indexPath];
        // Configure the cell...
        cell.indexPath = indexPath;
        cell.textLabel.text = self.subTypeSelectionList[indexPath.row];
        return cell;
    }
    static NSString *ident = @"mainTypeCell";
    SNSSLViewFilterMainTypeCell *cell = [tableView dequeueReusableCellWithIdentifier:ident forIndexPath:indexPath];
    // Configure the cell...
    cell.textLabel.text = @"";
    if (self.mainTypeCurrentSelection==SNSSLVFilterTypeOfBrandOption) {
        NSArray <AutosBrandDTO *> *suBrandList = self.mainTypeBrandSelectionList[indexPath.section];
        AutosBrandDTO *dto = suBrandList[indexPath.row];
        cell.textLabel.text = dto.brandName;
    }else if (self.mainTypeCurrentSelection==SNSSLVFilterTypeOfSpecRepairOption){
        NSDictionary *detail = self.mainTypeServiceSelectionList[indexPath.row];
        cell.textLabel.text = detail[@"name"];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView==self.mainTypeTableView) {
        if (self.mainTypeCurrentSelection==SNSSLVFilterTypeOfBrandOption) {
            AutosBrandDTO *dtoDetail = [self.mainTypeBrandSelectionList[indexPath.section] objectAtIndex:indexPath.row];
            self.mainTypeSelectedID = dtoDetail.brandID;
        }else if (self.mainTypeCurrentSelection==SNSSLVFilterTypeOfSpecRepairOption) {
            NSDictionary *detail = self.mainTypeServiceSelectionList[indexPath.row];
            self.mainTypeSelectedID = [SupportingClass verifyAndConvertDataToString:detail[@"id"]];
            NSString *serviceName = detail[@"name"];
            NSArray *specCheckList = @[@"轮胎", @"玻璃", @"电瓶"];
            if ([specCheckList containsObject:serviceName]) {
                if ([serviceName isEqualToString:@"轮胎"]) {
                    self.itemBrandListView.itemBrandType = SNSSLVFItemBrandTypeOfTire;
                }
                if ([serviceName isEqualToString:@"玻璃"]) {
                    self.itemBrandListView.itemBrandType = SNSSLVFItemBrandTypeOfWindshield;
                }
                if ([serviceName isEqualToString:@"电瓶"]) {
                    self.itemBrandListView.itemBrandType = SNSSLVFItemBrandTypeOfStorageBattery;
                }
                self.itemBrandControlViewWidthConstraint.constant = roundf(CGRectGetWidth(self.frame)/3.0f);
            }else {
                self.itemBrandListView.itemBrandType = SNSSLVFItemBrandTypeOfNone;
                self.itemBrandControlViewWidthConstraint.constant = 0;
            }
        }
        [self.subTypeTableView reloadData];
        self.subTypeCurrentSelection = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.subTypeTableView selectRowAtIndexPath:self.subTypeCurrentSelection animated:NO scrollPosition:UITableViewScrollPositionNone];
        [self showFilterViewByBtns:self.mainTypeBtnControlView];
        if (self.resultBlock) {
            self.resultBlock();
        }
    }else {
        self.subTypeCurrentSelection = indexPath;
        [self showFilterViewByBtns:self.subTypeBtnControlView];
        if (self.resultBlock) {
            self.resultBlock();
        }
    }
}

- (NSMutableArray <NSLayoutConstraint *> *)addSelfByFourMarginToSuperview:(UIView *)superview {
    NSMutableArray <NSLayoutConstraint *> *constraintsList = [super addSelfByFourMarginToSuperview:superview];
    @weakify(self);
    [constraintsList enumerateObjectsUsingBlock:^(NSLayoutConstraint * _Nonnull constraint, NSUInteger idx, BOOL * _Nonnull stop) {
        @strongify(self);
        if (constraint.firstAttribute==NSLayoutAttributeBottom&&
            constraint.secondAttribute==NSLayoutAttributeBottom) {
            self.bottomToSuperviewBottomConstraint = constraint;
        }
    }];
    return constraintsList;
}

- (void)getAutoBrandList {
    @weakify(self)
    [SupportingClass getAutosBrandList:^(NSArray *resultList, NSError *error) {
        @strongify(self)
        if (resultList.count>0) {
            [self delayLoading:resultList];
        }
    }];
}

- (void)delayLoading:(NSArray <AutosBrandDTO *> *)responseObject {
    NSOrderedSet *keySet = [NSOrderedSet orderedSetWithArray:[responseObject valueForKeyPath:@"sortedKey"]];
    self.keyArray = [keySet sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2 options:NSForcedOrderingSearch];
    }];
    NSMutableArray <NSArray <AutosBrandDTO *> *> *tmpArray = [NSMutableArray array];
    [_keyArray enumerateObjectsUsingBlock:^(NSString * sortedKey, NSUInteger section, BOOL *sectionStop) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"SELF.sortedKey LIKE[cd] %@", sortedKey];
        NSArray <AutosBrandDTO *> *result = [responseObject filteredArrayUsingPredicate:predicate];
        if (result.count>0) {
            [tmpArray addObject:result];
        }
        
    }];
    
    self.mainTypeBrandSelectionList = tmpArray;
}

- (void)getSpecServiceList {
    @weakify(self)
    [APIsConnection.shareConnection rapidRepairSpecServiceListWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        @strongify(self)
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        if (errorCode==0) {
            self.mainTypeServiceSelectionList = responseObject[CDZKeyOfResultKey];
            if (self.mainTypeCurrentSelection==SNSSLVFilterTypeOfSpecRepairOption&&
                self.mainTypeContainerViewHeightConstraint.constant>0) {
                [self.mainTypeTableView reloadData];
            }
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
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

- (SNSSLVFilterType)currentFilterTypeIdx {
    return self.mainTypeCurrentSelection;
}

- (NSNumber *)subTypeFilterSequence {
    return @(self.subTypeCurrentSelection.row);
}

- (SNSSLVFItemBrandType)itemBrandType {
    return self.itemBrandListView.itemBrandType;
}

- (NSString *)itemBrandName {
    return self.itemBrandListView.itemBrandName;
}

- (NSString *)mainFilterSelectedID {
    return self.mainTypeSelectedID;
}

@end


@implementation SNSSLViewFilterMainTypeCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.contentView.backgroundColor = CDZColorOfWhite;
    [self updateSeletedUIConfig];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    [self updateSeletedUIConfig];
}

- (void)updateSeletedUIConfig {
    self.textLabel.highlighted = self.selected;
}

@end

@implementation SNSSLViewFilterSubTypeCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.contentView.backgroundColor = CDZColorOfClearColor;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    [self updateSeletedUIConfig];
}

- (void)updateSeletedUIConfig {
    
    self.textLabel.highlighted = self.selected;
    self.backgroundColor = self.selected?CDZColorOfWhite:[UIColor colorWithRed:0.980 green:0.980 blue:0.980 alpha:1.00];
    UIRectBorder rectBorder = self.selected?(UIRectBorderTop|UIRectBorderBottom):UIRectBorderNone;
    if (self.indexPath.row==0) rectBorder = self.selected?UIRectBorderBottom:UIRectBorderNone;
    [self setViewBorderWithRectBorder:rectBorder borderSize:0.5 withColor:nil withBroderOffset:nil];
}
@end