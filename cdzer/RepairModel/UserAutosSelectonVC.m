//
//  UserAutosSelectonVC.m
//  cdzer
//
//  Created by KEns0nLau on 8/27/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#define vLeadingOffset 64.0f
#define vAnimationDuration 0.18f

#define kObjNameKey @"name"
#define kObjIDKey @"id"
#define kObjIconKey @"icon"
#define kAutosSeriesListKey @"seriesList"


#define kHeaderViewDefaultIdent @"headerView"

#import "UserAutosSelectonVC.h"
#import "UIView+LayoutConstraintHelper.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>

@interface AutosSelectionHeaderView : UITableViewHeaderFooterView
@property (readonly, strong, nonatomic) UILabel *titleLabel;
@end
@implementation AutosSelectionHeaderView
- (void)setTitleLabel:(UILabel *)titleLabel {
    _titleLabel = titleLabel;
}

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self=[super initWithReuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = [UIColor colorWithHexString:@"f2f5f7"];
        self.titleLabel = [[UILabel alloc] initWithFrame:self.bounds];
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.titleLabel.textColor = [UIColor colorWithHexString:@"646464"];
        self.titleLabel.font = [self.titleLabel.font fontWithSize:12];
        [self.titleLabel addSelfByFourMarginToSuperview:self.contentView withEdgeConstant:UIEdgeInsetsMake(0.0f, 15.0f, 0.0f, 15.0f)];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    UIColor *borderColor = [UIColor colorWithHexString:@"cccccc"];
    [self.contentView setViewBorderWithRectBorder:UIRectBorderBottom|UIRectBorderTop borderSize:0.5 withColor:borderColor withBroderOffset:nil];
}

@end

@interface AutosSelectionCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *selectedIndicatorView;

@property (weak, nonatomic) IBOutlet UIImageView *brandLogoIV;

@property (weak, nonatomic) IBOutlet UILabel *currentSpecName;

@property (nonatomic, strong) UIImage *defaultImage;


@end

@implementation AutosSelectionCell

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.brandLogoIV) {
        UIColor *borderColor = [UIColor colorWithHexString:@"cccccc"];
        [self.brandLogoIV.superview setViewBorderWithRectBorder:UIRectBorderRight borderSize:0.5 withColor:borderColor withBroderOffset:nil];
        [self.contentView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:borderColor withBroderOffset:nil];
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.defaultImage = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"white_logo_small@3x" ofType:@"png"]];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if (self.selectedIndicatorView) {
        self.selectedIndicatorView.hidden = !selected;
    }
    // Configure the view for the selected state
}

@end

@interface UserAutosSelectonVC () <UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIButton *seriesTVCloseBtn;
@property (weak, nonatomic) IBOutlet UITableView *seriesTableView;
@property (weak, nonatomic) IBOutlet UIView *seriesTVContainerView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *seriesTableViewCVWidthConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tv2StvcvHorizontalConstraint;

@property (weak, nonatomic) IBOutlet UIButton *modelTVCloseBtn;
@property (weak, nonatomic) IBOutlet UITableView *modelTableView;
@property (weak, nonatomic) IBOutlet UIView *modelTVContainerView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *modelTableViewCVWidthConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tv2MtvcvHorizontalConstraint;

@property (weak, nonatomic) IBOutlet UIButton *backIndicatorBtn;

@property (nonatomic, strong) NSArray *keyArray;

@property (nonatomic, strong) NSArray <NSArray <AutosBrandDTO *> *> *autoBrandList;

@property (nonatomic, strong) NSArray <NSDictionary *> *autosDealershipList;

@property (nonatomic, strong) NSMutableArray <NSMutableDictionary *> *autosDealershipSeriesCombineList;

@property (nonatomic, strong) NSArray <NSDictionary *> *autosModelList;

@property (nonatomic, strong) NSIndexPath *selectedBrandIndexPath;

@property (nonatomic, strong) NSIndexPath *selectedDealershipSeriesIndexPath;

@property (nonatomic, strong) NSIndexPath *selectedModelIndexPath;

@end

@implementation UserAutosSelectonVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self componentSetting];
    [self initializationUI];
    [self setReactiveRules];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    UIColor *borderColor = [UIColor colorWithHexString:@"cccccc"];
    [self.backIndicatorBtn.superview setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:borderColor withBroderOffset:nil];
    
    [self.seriesTVContainerView setViewBorderWithRectBorder:UIRectBorderLeft borderSize:0.5 withColor:borderColor withBroderOffset:nil];
    [[self.seriesTVContainerView viewWithTag:11] setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:borderColor withBroderOffset:nil];
    
    
    [self.modelTVContainerView setViewBorderWithRectBorder:UIRectBorderLeft borderSize:0.5 withColor:borderColor withBroderOffset:nil];
    [[self.modelTVContainerView viewWithTag:11] setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:borderColor withBroderOffset:nil];
}

- (void)componentSetting {
    @autoreleasepool {
        UIImage *image = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"BackIndicatorDefault@3x" ofType:@"png"]];
        [self.backIndicatorBtn setImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        self.backIndicatorBtn.tintColor = [UIColor colorWithHexString:@"323232"];
        self.edgesForExtendedLayout = UIRectEdgeTop;
        
        
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 100.0;
        self.view.backgroundColor = UIColor.whiteColor;
        [self.tableView registerClass:AutosSelectionHeaderView.class forHeaderFooterViewReuseIdentifier:kHeaderViewDefaultIdent];
        self.tableView.sectionIndexColor = [UIColor colorWithHexString:@"49C7F5"];
        self.tableView.sectionIndexBackgroundColor = CDZColorOfClearColor;
        self.tableView.sectionIndexTrackingBackgroundColor = [UIColor colorWithWhite:1.0f alpha:0.7f];
        [self.tableView registerNib:[UINib nibWithNibName:@"AutosSelectionWithImageCell" bundle:nil] forCellReuseIdentifier:CDZKeyOfCellIdentKey];
        
        self.seriesTableView.rowHeight = UITableViewAutomaticDimension;
        self.seriesTableView.estimatedRowHeight = 100.0;
        self.view.backgroundColor = UIColor.whiteColor;
        [self.seriesTableView registerClass:AutosSelectionHeaderView.class forHeaderFooterViewReuseIdentifier:kHeaderViewDefaultIdent];
        self.seriesTableView.sectionIndexColor = [UIColor colorWithHexString:@"49C7F5"];
        self.seriesTableView.sectionIndexBackgroundColor = CDZColorOfClearColor;
        self.seriesTableView.sectionIndexTrackingBackgroundColor = [UIColor colorWithWhite:1.0f alpha:0.7f];
        [self.seriesTableView registerNib:[UINib nibWithNibName:@"AutosSelectionDefaultCell" bundle:nil] forCellReuseIdentifier:CDZKeyOfCellIdentKey];
        
        self.modelTableView.rowHeight = UITableViewAutomaticDimension;
        self.modelTableView.estimatedRowHeight = 100.0;
        self.view.backgroundColor = UIColor.whiteColor;
        [self.modelTableView registerClass:AutosSelectionHeaderView.class forHeaderFooterViewReuseIdentifier:kHeaderViewDefaultIdent];
        self.modelTableView.sectionIndexColor = [UIColor colorWithHexString:@"49C7F5"];
        self.modelTableView.sectionIndexBackgroundColor = CDZColorOfClearColor;
        self.modelTableView.sectionIndexTrackingBackgroundColor = [UIColor colorWithWhite:1.0f alpha:0.7f];
        [self.modelTableView registerNib:[UINib nibWithNibName:@"AutosSelectionDefaultCell" bundle:nil] forCellReuseIdentifier:CDZKeyOfCellIdentKey];
        
        UIImage *closeImage = [self getCrossImage];
        [self.seriesTVCloseBtn setImage:closeImage forState:UIControlStateNormal];
        [self.modelTVCloseBtn setImage:closeImage forState:UIControlStateNormal];
        
        [self getAutoBrandList];
        
    }
}

- (UIImage *)getCrossImage {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(20.0f, 20.0f), NO, UIScreen.mainScreen.scale);
    
    UIColor *strokeColor = [UIColor colorWithHexString:@"49C7F5"];
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(0.0f, 0.0f)];
    [bezierPath addLineToPoint: CGPointMake(20.0f, 20.0f)];
    
    [bezierPath moveToPoint: CGPointMake(0.0f, 20.0f)];
    [bezierPath addLineToPoint: CGPointMake(20.0f, 0.0f)];
    
    [strokeColor setStroke];
    bezierPath.lineWidth = 1;
    [bezierPath stroke];
    
    UIImage *image = [UIGraphicsGetImageFromCurrentImageContext() imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIGraphicsEndImageContext();
    return image;
}

- (void)initializationUI {
    @autoreleasepool {
        
    }
}

- (void)setReactiveRules {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backToPreviousPage {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showSeriesTableViewSection {
    self.seriesTableViewCVWidthConstraint.constant = CGRectGetWidth(self.view.frame)-vLeadingOffset;
    self.tv2StvcvHorizontalConstraint.constant = -(self.seriesTableViewCVWidthConstraint.constant);
    @weakify(self);
    [UIView animateWithDuration:vAnimationDuration animations:^{
        @strongify(self);
        CGRect frame = self.seriesTVContainerView.frame;
        frame.origin.x = vLeadingOffset;
        frame.size.width = self.seriesTableViewCVWidthConstraint.constant;
        self.seriesTVContainerView.frame = frame;
    }];
}

- (IBAction)hiddenSeriesTableViewSection {
    @weakify(self);
    [UIView animateWithDuration:vAnimationDuration animations:^{
        @strongify(self);
        CGRect frame = self.seriesTVContainerView.frame;
        frame.origin.x = CGRectGetWidth(self.view.frame);
        self.seriesTVContainerView.frame = frame;
    } completion:^(BOOL finished) {
        @strongify(self);
        self.tv2StvcvHorizontalConstraint.constant = 0.0f;
    }];

}

- (void)showModelTableViewSection {
    self.modelTableViewCVWidthConstraint.constant = CGRectGetWidth(self.view.frame)-vLeadingOffset;
    self.tv2MtvcvHorizontalConstraint.constant = -(self.modelTableViewCVWidthConstraint.constant);
    @weakify(self);
    [UIView animateWithDuration:vAnimationDuration animations:^{
        @strongify(self);
        CGRect frame = self.modelTVContainerView.frame;
        frame.origin.x = vLeadingOffset;
        frame.size.width = self.modelTableViewCVWidthConstraint.constant;
        self.modelTVContainerView.frame = frame;
    }];
}

- (IBAction)hiddenModelTableViewSection {
    @weakify(self);
    [UIView animateWithDuration:vAnimationDuration animations:^{
        @strongify(self);
        CGRect frame = self.modelTVContainerView.frame;
        frame.origin.x = CGRectGetWidth(self.view.frame);
        self.modelTVContainerView.frame = frame;
    } completion:^(BOOL finished) {
        @strongify(self);
        self.tv2MtvcvHorizontalConstraint.constant = 0.0f;
    }];
}


#pragma -mark UITableViewDelegate
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *text = @"暂无更多数据！";
    if (scrollView==self.seriesTableView) {
        AutosBrandDTO *dto = [self.autoBrandList[self.selectedBrandIndexPath.section] objectAtIndex:self.selectedBrandIndexPath.row];
        text = [NSString stringWithFormat:@"暂无%@车系数据！", dto.brandName];
    }else if (scrollView==self.seriesTableView) {
        NSDictionary *detail = self.autosDealershipSeriesCombineList[self.selectedDealershipSeriesIndexPath.section];
        text = [NSString stringWithFormat:@"暂无%@车型数据！", detail[kObjNameKey]];
    }
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0f],
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    if (tableView==self.tableView) {
        return self.autoBrandList.count;
    }
    
    if (tableView==self.seriesTableView) {
        return self.autosDealershipSeriesCombineList.count;
    }
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (tableView==self.tableView) {
        return [self.autoBrandList[section] count];
    }
    
    if (tableView==self.seriesTableView) {
        NSMutableArray *seriesList = [self.autosDealershipSeriesCombineList[section] objectForKey:kAutosSeriesListKey];
        return seriesList.count;
    }
    
    return self.autosModelList.count;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (tableView==self.tableView) {
        return self.keyArray;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section {
    return 26;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    AutosSelectionHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kHeaderViewDefaultIdent];
    headerView.textLabel.text = @"";
    if (tableView==self.tableView) {
        headerView.titleLabel.text = self.keyArray[section];
    }else if (tableView==self.seriesTableView) {
        NSDictionary *detail = self.autosDealershipSeriesCombineList[section];
        headerView.titleLabel.text = detail[kObjNameKey];
    }else if (tableView==self.modelTableView) {
        NSDictionary *detail = self.autosDealershipSeriesCombineList[self.selectedDealershipSeriesIndexPath.section];
        NSArray *autosSeriesList = detail[kAutosSeriesListKey];
        if (autosSeriesList.count>0) {
            NSDictionary *subDetail = autosSeriesList[self.selectedDealershipSeriesIndexPath.row];
            headerView.titleLabel.text = subDetail[kObjNameKey];
        }
    }
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AutosSelectionCell *cell = [tableView dequeueReusableCellWithIdentifier:CDZKeyOfCellIdentKey forIndexPath:indexPath];
    if (tableView==self.tableView) {
        AutosBrandDTO *dto = [self.autoBrandList[indexPath.section] objectAtIndex:indexPath.row];
        if ([dto.brandImg isContainsString:@"http"]) {
            [cell.brandLogoIV setImageWithURL:[NSURL URLWithString:dto.brandImg] placeholderImage:cell.defaultImage usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        }
        cell.currentSpecName.text = dto.brandName;
    }else if (tableView==self.seriesTableView) {
        NSDictionary *detail = self.autosDealershipSeriesCombineList[indexPath.section];
        NSArray *autosSeriesList = detail[kAutosSeriesListKey];
        if (autosSeriesList.count>0) {
            NSDictionary *subDetail = autosSeriesList[indexPath.row];
            cell.currentSpecName.text = subDetail[kObjNameKey];
        }else {
            cell.currentSpecName.text = @"该汽车商暂无更多车系数据";
        }
    }else if (tableView==self.modelTableView) {
        NSDictionary *detail = self.autosModelList[indexPath.row];
        cell.currentSpecName.text = detail[kObjNameKey];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView==self.tableView) {
        self.selectedBrandIndexPath = indexPath;
        self.selectedDealershipSeriesIndexPath = nil;
        self.selectedModelIndexPath = nil;
        
        AutosBrandDTO *dto = [self.autoBrandList[indexPath.section] objectAtIndex:indexPath.row];
        [self hiddenModelTableViewSection];
        [self getAutosDealershipSpecListWithBrandID:dto.brandID];
    }else if (tableView==self.seriesTableView) {
        self.selectedDealershipSeriesIndexPath = indexPath;
        self.selectedModelIndexPath = nil;
        NSDictionary *detail = self.autosDealershipSeriesCombineList[indexPath.section];
        NSArray *autosSeriesList = detail[kAutosSeriesListKey];
        if (autosSeriesList.count>0) {
            NSDictionary *subDetail = autosSeriesList[indexPath.row];
            [self getAutosModelSpecListWithSeriesID:subDetail[kObjIDKey] withSeriesName:subDetail[kObjNameKey]];
        }else {
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
        }
    }else if (tableView==self.modelTableView) {
        self.selectedModelIndexPath = indexPath;
        NSDictionary *detail = self.autosModelList[indexPath.row];
        NSString *message = [NSString stringWithFormat:@"%@是否你所选？", detail[kObjNameKey]];
        @weakify(self);
        [SupportingClass showAlertViewWithTitle:nil message:message isShowImmediate:YES cancelButtonTitle:@"重选" otherButtonTitles:@"ok" clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            @strongify(self);
            if (btnIdx.integerValue>0) {
                [self updateSelectedAutosDetail];
            }
        }];
    }

    
}

#pragma mark- Access Net Data
- (void)getAutoBrandList {
    @weakify(self);
    [SupportingClass getAutosBrandList:^(NSArray *resultList, NSError *error) {
        @strongify(self);
        if (resultList.count>0) {
            [self delayLoading:resultList];
        }
    }];
}

- (void)delayLoading:(NSArray *)responseObject {
    NSOrderedSet *keySet = [NSOrderedSet orderedSetWithArray:[responseObject valueForKeyPath:@"sortedKey"]];
    self.keyArray = [keySet sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2 options:NSForcedOrderingSearch];
    }];
    NSMutableArray *tmpArray = [NSMutableArray array];
    [_keyArray enumerateObjectsUsingBlock:^(NSString * sortedKey, NSUInteger section, BOOL *sectionStop) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"SELF.sortedKey LIKE[cd] %@", sortedKey];
        NSArray *result = [responseObject filteredArrayUsingPredicate:predicate];
        if (result.count>0) {
            [tmpArray addObject:result];
        }
        
    }];
    self.autoBrandList = tmpArray;
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
}

- (void)getAutosDealershipSpecListWithBrandID:(NSString *)brandID {
    NSDictionary *userInfo = @{@"ident":@1};
    [ProgressHUDHandler showHUD];
    @weakify(self);
    [[APIsConnection shareConnection] commonAPIsGetAutoBrandDealershipListWithBrandID:brandID success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        operation.userInfo = userInfo;
        [self requestResultHandle:operation responseObject:responseObject withError:nil];
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        @strongify(self);
        operation.userInfo = userInfo;
        [self requestResultHandle:operation responseObject:nil withError:error];
    }];
}

- (void)getAutosModelSpecListWithSeriesID:(NSString *)seriesID withSeriesName:(NSString *)seriesName {
    if (!seriesName) seriesName = @"";
    NSDictionary *userInfo = @{@"ident":@3,
                               @"seriesName":seriesName};
    [ProgressHUDHandler showHUD];
    @weakify(self);
    [[APIsConnection shareConnection] commonAPIsGetAutoModelListWithAutoSeriesID:seriesID success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        operation.userInfo = userInfo;
        [self requestResultHandle:operation responseObject:responseObject withError:nil];
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        @strongify(self);
        operation.userInfo = userInfo;
        [self requestResultHandle:operation responseObject:nil withError:error];
    }];
}

- (void)requestResultHandle:(NSURLSessionDataTask *)operation responseObject:(id)responseObject withError:(NSError *)error {
    NSDictionary *userInfo = operation.userInfo;
    if (error&&!responseObject) {
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
        
    }else if (!error&&responseObject) {
        NSUInteger ident = [userInfo[@"ident"] unsignedIntegerValue];
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        if (errorCode!=0) {
            [ProgressHUDHandler dismissHUD];
            NSString *seriesName = userInfo[@"seriesName"];
            if (ident==3&&seriesName&&![seriesName isEqualToString:@""]) {
                message = [NSString stringWithFormat:@"暂无%@系列车型数据！", seriesName];
            }
            [SupportingClass showAlertViewWithTitle:@"" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            }];
            return ;
        }
        if (ident==1) {
            self.autosDealershipList = responseObject[CDZKeyOfResultKey];
            if (!self.autosDealershipSeriesCombineList) self.autosDealershipSeriesCombineList = [NSMutableArray array];
            [self.autosDealershipSeriesCombineList removeAllObjects];
            [self.autosDealershipSeriesCombineList addObjectsFromArray:responseObject[CDZKeyOfResultKey]];
            if (self.autosDealershipList.count>0) {
                @weakify(self);
                [self.autosDealershipList enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull detail, NSUInteger idx, BOOL * _Nonnull stop) {
                    @strongify(self);
                    NSString *specID = [SupportingClass verifyAndConvertDataToString:detail[kObjIDKey]];
                    [self getAutosSeriesSpecListWithDealershipID:specID andDealershipDataIdx:idx reloadDownloadCount:0];

                }];
            }
        }else if (ident==3) {
            [ProgressHUDHandler dismissHUD];
            self.autosModelList = responseObject[CDZKeyOfResultKey];
            [self showModelTableViewSection];
            [self.modelTableView reloadData];
        }
        
    }
    
}

- (void)getAutosSeriesSpecListWithDealershipID:(NSString *)dealershipID andDealershipDataIdx:(NSInteger)dataIdx reloadDownloadCount:(NSUInteger)reloadDownloadCount {
    reloadDownloadCount++;
    if (reloadDownloadCount<=5) {
        @weakify(self);
        [[APIsConnection shareConnection] commonAPIsGetAutoSeriesListWithBrandDealershipID:dealershipID success:^(NSURLSessionDataTask *operation, id responseObject) {
            @strongify(self);
            NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
            NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
            NSLog(@"%@",message);
            [self updateAutosDealershipWithSeriesResulit:responseObject andDealershipDataIdx:dataIdx];
        } failure:^(NSURLSessionDataTask *operation, NSError *error) {
            @strongify(self);
            [self getAutosSeriesSpecListWithDealershipID:dealershipID andDealershipDataIdx:reloadDownloadCount reloadDownloadCount:reloadDownloadCount];
        }];
    }else {
        [self updateAutosDealershipWithSeriesResulit:nil andDealershipDataIdx:dataIdx];
    }

}

- (void)updateAutosDealershipWithSeriesResulit:(id)responseObject andDealershipDataIdx:(NSInteger)dataIdx {
    NSMutableDictionary *detail = [self.autosDealershipList[dataIdx] mutableCopy];
    [detail setObject:@[] forKey:kAutosSeriesListKey];
    if (responseObject&&responseObject[CDZKeyOfResultKey]&&
        [responseObject[CDZKeyOfResultKey] isKindOfClass:NSArray.class]) {
        [detail setObject:responseObject[CDZKeyOfResultKey] forKey:kAutosSeriesListKey];
    }
    [self.autosDealershipSeriesCombineList replaceObjectAtIndex:dataIdx withObject:detail];
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id  _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        if (evaluatedObject[kAutosSeriesListKey]) return YES;
        return NO;
    }];
    NSArray *result = [self.autosDealershipSeriesCombineList filteredArrayUsingPredicate:predicate];
    if (result.count==self.autosDealershipSeriesCombineList.count) {
        [ProgressHUDHandler dismissHUD];
        [self.seriesTableView reloadData];
        [self showSeriesTableViewSection];
        NSLog(@"Ready");
    }else {
        NSLog(@"Not Ready");
    }
}

- (void)updateSelectedAutosDetail {
    
    AutosBrandDTO *dto = [self.autoBrandList[self.selectedBrandIndexPath.section] objectAtIndex:self.selectedBrandIndexPath.row];
    
    NSDictionary *dealershipDetail = self.autosDealershipSeriesCombineList[self.selectedDealershipSeriesIndexPath.section];
    
    NSDictionary *seriesDetail = [dealershipDetail[kAutosSeriesListKey] objectAtIndex:self.selectedDealershipSeriesIndexPath.row];
    
    NSDictionary *modelDetail = self.autosModelList[self.selectedModelIndexPath.row];
    
    
    UserAutosInfoDTO *userAutosDto = [DBHandler.shareInstance getUserAutosDetail];
    BOOL selectFromOnline = (userAutosDto&&self.accessToken&&[userAutosDto.brandID isEqualToString:dto.brandID]&&
                             [userAutosDto.dealershipID isEqualToString:dealershipDetail[kObjIDKey]]&&
                             [userAutosDto.seriesID isEqualToString:seriesDetail[kObjIDKey]]&&
                             [userAutosDto.modelID isEqualToString:modelDetail[kObjIDKey]]);
    NSDictionary *dataDetil = @{@"id":UserBehaviorHandler.shareInstance.getUserID,
                                @"select_from_online":@(selectFromOnline),
                                CDZAutosKeyOfBrandName:dto.brandName,
                                CDZAutosKeyOfBrandIcon:dto.brandImg,
                                CDZAutosKeyOfDealershipName:dealershipDetail[kObjNameKey],
                                CDZAutosKeyOfSeriesName:seriesDetail[kObjNameKey],
                                CDZAutosKeyOfModelName:modelDetail[kObjNameKey],
                                
                                CDZAutosKeyOfBrandID:dto.brandID,
                                CDZAutosKeyOfDealershipID:dealershipDetail[kObjIDKey],
                                CDZAutosKeyOfSeriesID:seriesDetail[kObjIDKey],
                                CDZAutosKeyOfModelID:modelDetail[kObjIDKey],
                                CDZAutosKeyOfTireDefaultName:modelDetail[CDZAutosKeyOfTireSourceName],
                                CDZAutosKeyOfTireDidSelectedName:@""};
    UserSelectedAutosInfoDTO *selectedAutosDto = [UserSelectedAutosInfoDTO new];
    [selectedAutosDto processDBDataToObjectWithDBData:dataDetil];
    if (selectFromOnline&&selectedAutosDto.tireDefaultSpec&&![selectedAutosDto.tireDefaultSpec isEqualToString:@""]) {
        selectedAutosDto.selectedTireSpec = selectedAutosDto.tireDefaultSpec;
    }
    
    if (self.accessToken) {
        if (selectFromOnline) {
            if (!self.onlyForSelection) {
                [DBHandler.shareInstance updateSelectedAutoData:selectedAutosDto];
            }
            if (self.resultBlock) {
                self.resultBlock(selectedAutosDto);
            }
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
        [ProgressHUDHandler showHUD];
        @weakify(self);
        [APIsConnection.shareConnection personalCenterAPIsPostLiteUpdateUserAutosDataWithAccessToken:self.accessToken brandID:selectedAutosDto.brandID brandDealershipID:selectedAutosDto.dealershipID seriesID:selectedAutosDto.seriesID modelID:selectedAutosDto.modelID success:^(NSURLSessionDataTask *operation, id responseObject) {
            @strongify(self);
            NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
            NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
            NSLog(@"%@",message);
            [ProgressHUDHandler dismissHUD];
            if (errorCode!=0) {
                [ProgressHUDHandler dismissHUD];
                
                [SupportingClass showAlertViewWithTitle:@"" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                }];
                return ;
            }
            if (responseObject[@"sign"]&&![responseObject[@"sign"] isEqualToString:@""]) {
                selectedAutosDto.tireDefaultSpec = responseObject[@"sign"];
            }
            if (!self.onlyForSelection) {
                [self reloadMyAutoData];
                [DBHandler.shareInstance updateSelectedAutoData:selectedAutosDto];
            }
            if (self.resultBlock) {
                self.resultBlock(selectedAutosDto);
            }
            
            [self.navigationController popViewControllerAnimated:YES];
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
    }else {
        if (!self.onlyForSelection) {
            [DBHandler.shareInstance updateSelectedAutoData:selectedAutosDto];
        }
        if (self.resultBlock) {
            self.resultBlock(selectedAutosDto);
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)commitSelectionWithUpdateDB {
    
    AutosBrandDTO *dto = [self.autoBrandList[self.selectedBrandIndexPath.section] objectAtIndex:self.selectedBrandIndexPath.row];
    
    NSDictionary *dealershipDetail = self.autosDealershipSeriesCombineList[self.selectedDealershipSeriesIndexPath.section];
    
    NSDictionary *seriesDetail = [dealershipDetail[kAutosSeriesListKey] objectAtIndex:self.selectedDealershipSeriesIndexPath.row];
    
    NSDictionary *modelDetail = self.autosModelList[self.selectedDealershipSeriesIndexPath.row];
    
    
    NSString *userID = UserBehaviorHandler.shareInstance.getUserID;
    NSDictionary *dataDetil = @{@"id":userID,
                                @"select_from_online":@NO,
                                CDZAutosKeyOfBrandName:dto.brandName,
                                CDZAutosKeyOfBrandIcon:dto.brandImg,
                                CDZAutosKeyOfDealershipName:dealershipDetail[kObjNameKey],
                                CDZAutosKeyOfSeriesName:seriesDetail[kObjNameKey],
                                CDZAutosKeyOfModelName:modelDetail[kObjNameKey],
                                
                                CDZAutosKeyOfBrandID:dto.brandID,
                                CDZAutosKeyOfDealershipID:dealershipDetail[kObjIDKey],
                                CDZAutosKeyOfSeriesID:seriesDetail[kObjIDKey],
                                CDZAutosKeyOfModelID:modelDetail[kObjIDKey],
                                CDZAutosKeyOfTireDefaultName:modelDetail[CDZAutosKeyOfTireSourceName]};
    UserSelectedAutosInfoDTO *selectedDto = [UserSelectedAutosInfoDTO new];
    [selectedDto processDBDataToObjectWithDBData:dataDetil];
    [DBHandler.shareInstance updateSelectedAutoData:selectedDto];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)reloadMyAutoData {
    if (!self.accessToken) {
        return;
    }
    [[APIsConnection shareConnection] personalCenterAPIsGetMyAutoListWithAccessToken:self.accessToken success:^(NSURLSessionDataTask *operation, id responseObject) {
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        [ProgressHUDHandler dismissHUD];
        if (errorCode==0) {
            NSDictionary *autosData = responseObject[CDZKeyOfResultKey];
            UserAutosInfoDTO *dto = [UserAutosInfoDTO new];
            [dto processDataToObject:autosData optionWithUID:UserBehaviorHandler.shareInstance.getUserID];
            [DBHandler.shareInstance updateUserAutosDetailData:dto.processObjectToDBData];
        }
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        
    }];
    
}

@end








