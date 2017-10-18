//
//  SelfRepairShortcutPayVC.m
//  cdzer
//
//  Created by KEns0n on 8/5/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#import "SelfRepairShortcutPayVC.h"
#import "SelfRepairResultCell.h"
#import "PartsDetailVC.h"
#import "InsetsLabel.h"
#import "QuantityControlView.h"
#import "UserSelectedAutosInfoDTO.h"
//#import "MyCartSubmitConfirmVC.h"
#import <SDWebImage/UIImageView+WebCache.h>
@interface SRSPCell : UITableViewCell

@property (nonatomic, strong) UIImageView *checkMarkIV;

@property (nonatomic, strong) UIImageView *uncheckCheckMarkIV;

@property (nonatomic, assign) BOOL showCheckMark;

@property (nonatomic, strong) QuantityControlView *countView;

@end

@implementation SRSPCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        if (!_checkMarkIV) {
            UIImage *checkMarkImage = [ImageHandler getImageFromCacheWithByFixdeRatioFileRootPath:kSysImageCaches fileName:@"checkmark" type:FMImageTypeOfPNG needToUpdate:YES];
            self.checkMarkIV = [[UIImageView alloc] initWithImage:checkMarkImage];
            self.checkMarkIV.hidden = YES;
            [self.contentView addSubview:self.checkMarkIV];
        }
        if (!_uncheckCheckMarkIV) {
            UIImage *uncheckCheckMarkImage = [ImageHandler getImageFromCacheWithByFixdeRatioFileRootPath:kSysImageCaches fileName:@"checkmark_unchecked" type:FMImageTypeOfPNG needToUpdate:YES];
            self.uncheckCheckMarkIV = [[UIImageView alloc] initWithImage:uncheckCheckMarkImage];
            self.uncheckCheckMarkIV.hidden = YES;
            [self.contentView addSubview:self.uncheckCheckMarkIV];
        }
        self.countView = [QuantityControlView new];
        [self.contentView addSubview:_countView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    self.accessoryView = nil;
    self.checkMarkIV.hidden = !(_showCheckMark&&selected);
    self.uncheckCheckMarkIV.hidden = !(_showCheckMark&&!selected);
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
    self.checkMarkIV.hidden = !(_showCheckMark&&selected);
    self.uncheckCheckMarkIV.hidden = !(_showCheckMark&&!selected);
    [self.contentView bringSubviewToFront:self.countView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.contentView.frame = self.bounds;
    
    
    self.checkMarkIV.center = CGPointMake(CGRectGetWidth(self.checkMarkIV.frame)/2.0+10.0f, CGRectGetHeight(self.contentView.frame)/2.0f);
    self.uncheckCheckMarkIV.center = CGPointMake(CGRectGetWidth(self.uncheckCheckMarkIV.frame)/2.0+10.0f, CGRectGetHeight(self.contentView.frame)/2.0f);
    
    self.imageView.frame = CGRectMake(_showCheckMark?CGRectGetMaxX(self.checkMarkIV.frame):15.0f , 0.0f, 70.0f, 70.0f);
    self.imageView.center = CGPointMake(self.imageView.center.x, CGRectGetHeight(self.frame)/2.0f);
    self.imageView.autoresizingMask = UIViewAutoresizingNone;
    
    
    CGRect textLabelRect = self.textLabel.frame;
    textLabelRect.origin.x = CGRectGetMaxX(self.imageView.frame);
    textLabelRect.size.width = CGRectGetWidth(self.frame)-CGRectGetMaxX(self.imageView.frame)-10.0f;
    self.textLabel.frame = textLabelRect;
    
    CGRect detailLabelRect = self.detailTextLabel.frame;
    detailLabelRect.origin.x = CGRectGetMaxX(self.imageView.frame);
    detailLabelRect.origin.y = CGRectGetMaxY(self.textLabel.frame);
    detailLabelRect.size.width = CGRectGetWidth(self.frame)-CGRectGetMaxX(self.imageView.frame)-10.0f;
    self.detailTextLabel.frame = detailLabelRect;
    
    CGPoint countCenter = self.countView.center;
    countCenter.x = CGRectGetWidth(self.frame)-CGRectGetWidth(self.countView.frame)/2.0f-15.0f;
    countCenter.y = CGRectGetHeight(self.frame)-CGRectGetHeight(self.countView.frame)/2.0f-10.0f;
    self.countView.center = countCenter;
    
    BorderOffsetObject *offset = BorderOffsetObject.new;
    offset.bottomLeftOffset = CGRectGetMinX(self.textLabel.frame);
    [self.contentView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5f withColor:CDZColorOfSeperateLineColor withBroderOffset:offset];
}

@end

@interface SelfRepairShortcutPayVC () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIView *resultView;

@property (nonatomic, strong) InsetsLabel *totalPriceLabel;

@property (nonatomic, strong) UIButton *submitBtn;

@property (nonatomic, strong) NSMutableSet *indexPathsForSelectedRows;

@property (nonatomic, strong) NSMutableArray *countingList;

@end

@implementation SelfRepairShortcutPayVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"选购保养配件";
    [self componentSetting];
    [self initializationUI];
    [self setReactiveRules];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)componentSetting {
    @autoreleasepool {
        self.countingList = [@[] mutableCopy];
        for (int i=0; i<_purchaseList.count; i++) {
            [self.countingList addObject:@1];
        }
        self.indexPathsForSelectedRows = NSMutableSet.set;
        [self setRightNavButtonWithTitleOrImage:@"购买" style:UIBarButtonItemStyleDone target:self action:@selector(showBuyMode) titleColor:nil isNeedToSet:YES];
    }
}

- (void)setReactiveRules {
//    @weakify(self);
//    [RACObserve(self, indexPathsForSelectedRows) subscribeNext:^(NSMutableSet *indexPathsForSelectedRows) {
//        @strongify(self);
//        if (self.editing) {
//            BOOL isHaveData = (indexPathsForSelectedRows&&indexPathsForSelectedRows.count>0);
//            self.submitBtn.backgroundColor = isHaveData?CDZColorOfDefaultColor:CDZColorOfDeepGray;
//            self.submitBtn.enabled = isHaveData;
//        }
//    }];
}

- (void)updateSubmitButtonStatus {
    if (self.editing) {
        BOOL isHaveData = (self.indexPathsForSelectedRows&&self.indexPathsForSelectedRows.count>0);
        self.submitBtn.backgroundColor = isHaveData?CDZColorOfDefaultColor:CDZColorOfDeepGray;
        self.submitBtn.enabled = isHaveData;
    }
}

- (void)showBuyMode {
    @autoreleasepool {
        
//        NSMutableSet *indexPathsForSelectedRows = [self mutableSetValueForKey:@"indexPathsForSelectedRows"];
        [self.indexPathsForSelectedRows removeAllObjects];
        [self updateSubmitButtonStatus];
        [self setEditing:!self.editing animated:YES];
        self.navigationItem.rightBarButtonItem.title = self.editing?@"取消":@"购买";
        self.resultView.hidden = !self.editing;
        self.tableView.frame = self.editing?CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tableView.frame), CGRectGetMinY(self.resultView.frame)):self.contentView.bounds;
        [self.tableView reloadData];
        [self updateTotalPriceDisplayView];
    }
}

- (void)initializationUI {
    self.tableView = [[UITableView alloc] initWithFrame:self.contentView.bounds];
    _tableView.backgroundColor = CDZColorOfBackgroudColor;
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
    [self.contentView addSubview:_tableView];
    
    self.resultView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetHeight(self.contentView.frame)-50.0f,
                                                               CGRectGetWidth(self.contentView.frame), 50.0f)];
    _resultView.hidden = YES;
    _resultView.backgroundColor = CDZColorOfWhite;
    [self.contentView addSubview:_resultView];
    
    self.totalPriceLabel = [[InsetsLabel alloc] initWithFrame:_resultView.bounds andEdgeInsetsValue:DefaultEdgeInsets];
    _totalPriceLabel.numberOfLines = 0;
    [_resultView addSubview:_totalPriceLabel];
    
    self.submitBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    _submitBtn.backgroundColor = CDZColorOfDeepGray;
    _submitBtn.enabled = NO;
    _submitBtn.frame = CGRectMake(CGRectGetWidth(_resultView.frame)*0.6f-15.0f,
                                   CGRectGetHeight(_resultView.frame)*0.15f,
                                   CGRectGetWidth(_resultView.frame)*0.4f,
                                   CGRectGetHeight(_resultView.frame)*0.7f);
    [_submitBtn setTitle:@"购买产品" forState:UIControlStateNormal];
    [_submitBtn setTitleColor:CDZColorOfWhite forState:UIControlStateNormal];
    [_submitBtn addTarget:self action:@selector(submitOrder) forControlEvents:UIControlEventTouchUpInside];
    [_resultView addSubview:_submitBtn];
    
}

- (void)updateTotalPriceDisplayView {
    NSMutableIndexSet *indicesOfItems = [NSMutableIndexSet new];
    for (NSIndexPath *selectionIndex in self.indexPathsForSelectedRows.allObjects)
    {
        [indicesOfItems addIndex:selectionIndex.row];
    }
    NSArray *priceList = [[_purchaseList valueForKey:@"memberprice"] objectsAtIndexes:indicesOfItems];
    __block double totalPrice = 0;
    [priceList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSNumber *price = [SupportingClass verifyAndConvertDataToNumber:obj];
        NSNumber *count = [SupportingClass verifyAndConvertDataToNumber:self.countingList[idx]];
        totalPrice += price.doubleValue * count.doubleValue;
    }];
    
    UIFont *font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 15, NO);
    NSDictionary *redColorAttributes = @{NSForegroundColorAttributeName:CDZColorOfRed, NSFontAttributeName:font};
    NSDictionary *blackColorAttributes = @{NSForegroundColorAttributeName:CDZColorOfBlack, NSFontAttributeName:font};
    NSMutableAttributedString* totalPriceStr = [NSMutableAttributedString new];
    [totalPriceStr appendAttributedString:[[NSAttributedString alloc]
                                           initWithString:@"总计："
                                           attributes:blackColorAttributes]];
    [totalPriceStr appendAttributedString:[[NSAttributedString alloc]
                                           initWithString:[NSString stringWithFormat:@"¥%0.2f",totalPrice]
                                           attributes:redColorAttributes]];
    
    [totalPriceStr appendAttributedString:[[NSAttributedString alloc]
                                           initWithString:@"\n共（"
                                           attributes:blackColorAttributes]];
    [totalPriceStr appendAttributedString:[[NSAttributedString alloc]
                                           initWithString:[NSString stringWithFormat:@"%d件，不含运费",self.indexPathsForSelectedRows.count]
                                           attributes:redColorAttributes]];
    [totalPriceStr appendAttributedString:[[NSAttributedString alloc]
                                           initWithString:@"）"
                                           attributes:blackColorAttributes]];
    self.totalPriceLabel.attributedText = totalPriceStr;
}

- (void)updateProductQuantityCount:(QuantityControlView *)countView {
    @autoreleasepool {
        NSIndexPath *indexPath = countView.identifierIndexPath;
        if (![self.indexPathsForSelectedRows containsObject:indexPath]) {
            [_tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            [self.indexPathsForSelectedRows addObject:indexPath];
        }
        [self.countingList replaceObjectAtIndex:indexPath.row withObject:@(countView.value)];
        [self updateTotalPriceDisplayView];
        
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return _purchaseList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    SRSPCell *cell = [tableView dequeueReusableCellWithIdentifier:CDZKeyOfCellIdentKey];
    if (!cell) {
        cell = [[SRSPCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CDZKeyOfCellIdentKey];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = CDZColorOfWhite;
        cell.contentView.backgroundColor = CDZColorOfWhite;
        cell.textLabel.numberOfLines = 0;
        cell.detailTextLabel.numberOfLines = 0;
        [cell.countView addTarget:self action:@selector(updateProductQuantityCount:) forControlEvents:UIControlEventValueChanged];
        
    }
    @autoreleasepool {
        
        cell.countView.identifierIndexPath = indexPath;
        NSInteger value = [_countingList[indexPath.row] unsignedIntegerValue];
        NSInteger maxValue = 50;
        [cell.countView setValue:value withMaxValue:maxValue];
        NSDictionary *detail = _purchaseList[indexPath.row];
        NSString *partsName = [SupportingClass verifyAndConvertDataToString:detail[@"name"]];
        NSString *partsType = [SupportingClass verifyAndConvertDataToString:detail[@"autopartinfo_name"]];
        NSString *partsPrice = [SupportingClass verifyAndConvertDataToString:detail[@"memberprice"]];

        NSMutableAttributedString *textString = NSMutableAttributedString.new;
        [textString appendAttributedString:[[NSAttributedString alloc]
                                         initWithString:[partsName stringByAppendingString:@"\n"]
                                         attributes:@{NSForegroundColorAttributeName:CDZColorOfBlack,
                                                      NSFontAttributeName:vGetHelveticaNeueFont(HelveticaNeueFontTypeOfBold, 18.0f, NO)}]];
        
        [textString appendAttributedString:[[NSAttributedString alloc]
                                            initWithString:[partsType stringByAppendingString:@"\n"]
                                            attributes:@{NSForegroundColorAttributeName:CDZColorOfBlack,
                                                         NSFontAttributeName:vGetHelveticaNeueFont(HelveticaNeueFontTypeOfBold, 14.0f, NO)}]];
        
        [textString appendAttributedString:[[NSAttributedString alloc]
                                            initWithString:@"价格："
                                            attributes:@{NSForegroundColorAttributeName:CDZColorOfBlack,
                                                         NSFontAttributeName:vGetHelveticaNeueFont(HelveticaNeueFontTypeOfBold, 14.0f, NO)}]];
        
        [textString appendAttributedString:[[NSAttributedString alloc]
                                            initWithString:[@"¥" stringByAppendingString:partsPrice]
                                            attributes:@{NSForegroundColorAttributeName:CDZColorOfRed,
                                                         NSFontAttributeName:vGetHelveticaNeueFont(HelveticaNeueFontTypeOfBold, 14.0f, NO)}]];
        cell.textLabel.attributedText = textString;
        
        cell.imageView.image = ImageHandler.getWhiteLogo;
        NSString *picURLStr = detail[@"img"];
        if (![picURLStr isKindOfClass:NSNull.class]&&picURLStr&&[picURLStr rangeOfString:@"http"].location!=NSNotFound) {
            [cell.imageView sd_setImageWithURL:[NSURL URLWithString:picURLStr] placeholderImage:ImageHandler.getWhiteLogo];
        }
        
        
        cell.showCheckMark = self.editing;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100.0f;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.editing) {
        @autoreleasepool {
//            NSMutableSet *indexPathsForSelectedRows = [self mutableSetValueForKey:@"indexPathsForSelectedRows"];
            [self.indexPathsForSelectedRows removeObject:indexPath];
            [self updateSubmitButtonStatus];
            [self updateTotalPriceDisplayView];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.editing) {
        @autoreleasepool {
//            NSMutableSet *indexPathsForSelectedRows = [self mutableSetValueForKey:@"indexPathsForSelectedRows"];
            [self.indexPathsForSelectedRows addObject:indexPath];
            [self updateSubmitButtonStatus];
            [self updateTotalPriceDisplayView];
        }
    }else {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}

- (void)pushPartItemDetailViewWithItemDetail:(id)detail {
    if (!detail||![detail isKindOfClass:[NSDictionary class]]) {
        return;
    }
    @autoreleasepool {
        PartsDetailVC *vc = [PartsDetailVC new];
        vc.itemDetail = detail;
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)pushSubmitViewWithConfirmDetail:(id)detail andStockCount:(NSArray *)stockCountList{
    if (!detail||![detail isKindOfClass:[NSDictionary class]]) {
        return;
    }
    @autoreleasepool {
//        MyCartSubmitConfirmVC *vc = [MyCartSubmitConfirmVC new];
//        vc.infoConfirmData = detail;
//        vc.stockCountList = stockCountList;
//        [self setDefaultNavBackButtonWithoutTitle];
//        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark- API Access Code Section
- (void)getPartsDetailWithPartsID:(NSString *)partsID {
    [ProgressHUDHandler showHUD];
    [[APIsConnection shareConnection] theSelfMaintenanceAPIsGetItemDetailWithWithAccessToken:self.accessToken productID:partsID success:^(NSURLSessionDataTask *operation, id responseObject) {
        NSLog(@"%@",responseObject);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        if(errorCode!=0){
            [ProgressHUDHandler dismissHUD];
            [SupportingClass showAlertViewWithTitle:@"error" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                
            }];
            return;
        }
        [self pushPartItemDetailViewWithItemDetail:responseObject[CDZKeyOfResultKey]];
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

- (void)submitOrder {
    
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    UserSelectedAutosInfoDTO *dto = DBHandler.shareInstance.getSelectedAutoData;
    if (!dto||!dto.modelID||!dto.seriesID||[dto.modelID isEqualToString:@""]||[dto.seriesID isEqualToString:@""]) return;
    
    NSMutableIndexSet *indicesOfItems = [NSMutableIndexSet new];
    for (NSIndexPath *selectionIndex in self.indexPathsForSelectedRows.allObjects)
    {
        [indicesOfItems addIndex:selectionIndex.row];
    }
    NSArray *productIDList = [[_purchaseList valueForKey:@"id"] objectsAtIndexes:indicesOfItems];
    NSArray *stockCountList = [_purchaseList objectsAtIndexes:indicesOfItems];
    NSArray *productCountList = [_countingList objectsAtIndexes:indicesOfItems];
    [ProgressHUDHandler showHUD];
    [[APIsConnection shareConnection] personalCenterAPIsPostOrderExpressSubmitWithAccessToken:self.accessToken
                                                                                productIDList:productIDList
                                                                             productCountList:productCountList
                                                                                      brandID:dto.brandID
                                                                            brandDealershipID:dto.dealershipID
                                                                                     seriesID:dto.seriesID
                                                                                      modelID:dto.modelID
    success:^(NSURLSessionDataTask *operation, id responseObject) {
        NSLog(@"%@",responseObject);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        if(errorCode!=0){
            [ProgressHUDHandler dismissHUD];
            [SupportingClass showAlertViewWithTitle:nil message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                
            }];
            return;
        }
        [ProgressHUDHandler dismissHUD];
        [self pushSubmitViewWithConfirmDetail:responseObject[CDZKeyOfResultKey] andStockCount:stockCountList];
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

- (void)handleUserLoginResult:(BOOL)isSuccess fromAlert:(BOOL)fromAlert{
    if (isSuccess) {
        NSLog(@"success reload function %d", [self executeReloadFunction]);
    }else {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
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
