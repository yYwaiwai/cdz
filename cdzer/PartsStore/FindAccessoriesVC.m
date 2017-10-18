//
//  FindAccessoriesVC.m
//  cdzer
//
//  Created by 车队长 on 16/9/7.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#define kObjKeyName @"name"
#define kObjKeyID @"id"

#import "FindAccessoriesVC.h"
#import "FindAccessoriesWithProductCell.h"
#import "FindAccessoriesCategoryVC.h"
#import "PartsDetailVC.h"
#import "QueryPriceView.h"
#import "MyEnquiryVC.h"
#import "UserAutosSelectonVC.h"
#import "UISearchBarWithReturnKey.h"
#import <ODRefreshControl/ODRefreshControl.h>
#import <MJRefresh/MJRefresh.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>



@interface FindAccessoriesVC ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,UITextFieldDelegate,UIPickerViewDelegate,UIPickerViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, UISearchBarWithReturnKeyDelegate>
@property (weak, nonatomic) IBOutlet UIControl *headControl;

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;

@property (weak, nonatomic) IBOutlet UILabel *carLabel;

@property (weak, nonatomic) IBOutlet UIButton *allButton;

@property (nonatomic, strong) NSString *carLabelText;

@property (nonatomic, strong) NSString *headImageUrl;

@property (weak, nonatomic) IBOutlet UIButton *scoreButton;//评分

@property (weak, nonatomic) IBOutlet UIButton *scoreButtonUP;//

@property (weak, nonatomic) IBOutlet UIButton *scoreButtonDown;

@property (weak, nonatomic) IBOutlet UIButton *salesVolumeButton;//销量

@property (weak, nonatomic) IBOutlet UIButton *salesVolumeButtonUP;

@property (weak, nonatomic) IBOutlet UIButton *salesVolumeButtonDown;


@property (weak, nonatomic) IBOutlet UIButton *priceButton;//价格

@property (weak, nonatomic) IBOutlet UIButton *priceButtonUP;

@property (weak, nonatomic) IBOutlet UIButton *priceButtonDown;


@property (nonatomic, strong) ODRefreshControl *refreshControl;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIView *buttonBgView;

@property (nonatomic, strong) UISearchBarWithReturnKey *searchBar;

/// 维修订单列表
@property (nonatomic, strong) NSMutableArray *productList;

@property (nonatomic, strong) NSNumber *sortNumber;

@property (nonatomic, strong) NSString *autopartInfo;

@property (nonatomic, strong) NSString *productionID;

@property (nonatomic, strong) NSString *keyWords;

@property (strong, nonatomic) IBOutlet QueryPriceView *queryPriceView;

@property (nonatomic, strong) NSMutableArray *provinceInfoArr;

@property (nonatomic, strong) NSMutableArray *cityInfoArr;

@property (nonatomic, strong) NSMutableArray *centerInfoArr;

@property (nonatomic, strong) UIPickerView *cityPickerView;

@property (nonatomic, strong) UIPickerView *centerPickerView;


@property (nonatomic, strong) NSDictionary *provinceInfoDic;
@property (nonatomic, strong) NSDictionary *cityInfoDic;
@property (nonatomic, strong) NSDictionary *centerInfoDic;


@property (nonatomic, strong) UIToolbar *toolBar;
@property (nonatomic, assign) NSInteger indexPath;

@property (nonatomic, strong) UserSelectedAutosInfoDTO *autosData;

@property (nonatomic, assign) BOOL iSscore;
@property (nonatomic, assign) BOOL iSsalesVolume;
@property (nonatomic, assign) BOOL iSprice;

@end

@implementation FindAccessoriesVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!self.autosData) {
        self.autosData = [DBHandler.shareInstance getSelectedAutoData];
    }
    
    UserSelectedAutosInfoDTO *autosData = [DBHandler.shareInstance getSelectedAutoData];
    if (self.autosData&&autosData&&![autosData.modelID isEqualToString:self.autosData.modelID]) {
        self.autosData = [DBHandler.shareInstance getSelectedAutoData];
        self.autopartInfo = @"";
    }
    
    self.headImageView.image = [ImageHandler getDefaultWhiteLogo];
    if (self.autosData.brandID&&self.autosData.dealershipID&&
        self.autosData.seriesID&&self.autosData.modelID) {
        NSString*seriesName = self.autosData.seriesName;
        NSString*modelName = self.autosData.modelName;
        NSString *imgURL = self.autosData.brandImgURL;
        if ([imgURL containsString:@"http"]) {
            [self.headImageView sd_setImageWithURL:[NSURL URLWithString:imgURL] placeholderImage:[ImageHandler getDefaultWhiteLogo]];
        }
        self.carLabel.text = [NSString stringWithFormat:@"%@ %@",seriesName,modelName];
        self.carLabelText = self.carLabel.text;
        self.headImageUrl = imgURL;
    }
    
    
    if(self.autosData) {
        if (self.productList.count==0||self.shouldReloadData) {
            [self getProductListWithRefreshView:nil isAllReload:YES];
            self.shouldReloadData = NO;
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
    [self.searchBar resignFirstResponder];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.buttonBgView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5f withColor:nil withBroderOffset:nil];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tongzhi:) name:@"czpjTongZhi" object:nil];
    [[UINib nibWithNibName:@"QueryPriceView" bundle:nil] instantiateWithOwner:self options:nil];
    [self componentSetting];
    [self setReactiveRules];
    
    UIButton*rightButton = [[UIButton alloc]initWithFrame:CGRectMake(0,0,30,30)];
    [rightButton setImage:[UIImage imageNamed:@"fenlei@3x"]forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(classification)forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem*rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem= rightItem;
    
    
    [self.headImageView.layer setCornerRadius:22.5];
    [self.headImageView.layer setMasksToBounds:YES];
    [self.headImageView setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:3.0f withColor:[UIColor colorWithHexString:@"82d5f7"] withBroderOffset:nil];
    [self.headControl addTarget:self action:@selector(headControlClick) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 110.0f;
    self.tableView.tableFooterView = [UIView new];
    UINib*nib = [UINib nibWithNibName:@"FindAccessoriesWithProductCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"FindAccessoriesWithProductCell"];
    
    self.refreshControl = [[ODRefreshControl alloc] initInScrollView:_tableView];
    [self.refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl.hidden = YES;
    
    _tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(refreshView:)];
    _tableView.mj_footer.automaticallyHidden = NO;
    _tableView.mj_footer.hidden = YES;
    
    [self.queryPriceView.submitButton addTarget:self action:@selector(submitButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
}

#pragma mark - UISearchBarWithReturnKeyDelegate
- (void)searchBarReturnKey:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    self.keyWords = self.searchBar.text;
    [self getProductListWithRefreshView:nil isAllReload:YES];
}

- (void)resignKeyboard {
    if (self.queryPriceView.cityTF.isFirstResponder) {
        NSInteger provinceObjIdx = [self.cityPickerView selectedRowInComponent:0];
        NSInteger cityObjIdx = [self.cityPickerView selectedRowInComponent:1];
        self.provinceInfoDic = self.provinceInfoArr[provinceObjIdx];
        self.cityInfoDic = self.cityInfoArr[cityObjIdx];
        self.queryPriceView.cityTF.text=[NSString stringWithFormat:@"%@%@",
                                         self.provinceInfoDic[kObjKeyName],
                                         self.cityInfoDic[kObjKeyName]];
    }
    
    if (self.queryPriceView.cgzxTF.isFirstResponder&&self.centerInfoArr.count>0) {
        NSInteger centerObjIdx = [self.centerPickerView selectedRowInComponent:0];
        self.centerInfoDic = self.centerInfoArr[centerObjIdx];
        self.queryPriceView.cgzxTF.text=self.centerInfoDic[kObjKeyName];
    }
    
    
    [self.queryPriceView.cityTF resignFirstResponder];
    [self.queryPriceView.cgzxTF resignFirstResponder];
}

- (void)tongzhi:(NSNotification *)text{
    self.autopartInfo=text.userInfo[@"id"];
    NSLog(@"%@  ",self.autopartInfo);
    NSLog(@"－－－－－ 接收到通知------");
    [self getProductListWithRefreshView:nil isAllReload:YES];
}
//选择车型
- (void)headControlClick {
    @autoreleasepool {
        UserAutosSelectonVC *vc = [UserAutosSelectonVC new];
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)setReactiveRules {

}

- (void)filterAction {
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    [self pageObjectToDefault];
    self.sortNumber=@(0);
    [self getProductListWithRefreshView:nil isAllReload:YES];
}

- (void)submitButtonClick {
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    
    NSString *centerInfoIDStr = self.centerInfoDic[kObjKeyID];
    if (self.queryPriceView.nameTF.text.length==0||self.queryPriceView.phoneTF.text.length==0||centerInfoIDStr.length==0) {
        if (self.queryPriceView.nameTF.text.length==0) {
            [SupportingClass showAlertViewWithTitle:@"" message:@"请将信息填写完整！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            }];
            return;
        }
    }
    
    [ProgressHUDHandler showHUD];
    NSLog(@"%@--%@--%@--%@--%@--%@--%@",self.autosData.modelID, self.autosData.dealershipID, self.autosData.seriesID, self.autosData.modelID, centerInfoIDStr, self.queryPriceView.phoneTF.text, self.queryPriceView.nameTF.text);
    
    [[APIsConnection shareConnection] personalCenterAPIsPostSelfEnquireProductsPriceWithAccessToken:self.accessToken brandID:self.autosData.brandID brandDealershipID:self.autosData.dealershipID seriesID:self.autosData.seriesID modelID:self.autosData.modelID centerID:centerInfoIDStr mobileNumber:self.queryPriceView.phoneTF.text userName:self.queryPriceView.nameTF.text productionID:self.productionID success:^(NSURLSessionDataTask *operation, id responseObject) {
        operation.userInfo = @{@"ident":@"inquiryRequestSubmit"};
        [self requestResultHandle:operation responseObject:responseObject withError:nil];
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        operation.userInfo = @{@"ident":@"inquiryRequestSubmit"};
        [self requestResultHandle:operation responseObject:nil withError:error];
    }];
    
}

- (void)componentSetting {
    self.sortNumber=@(0);
    self.productList = [NSMutableArray array];
    self.centerInfoArr = [NSMutableArray array];
    self.cityInfoArr = [NSMutableArray array];
    self.provinceInfoArr = [NSMutableArray array];
    [self pageObjectToDefault];
    
    
    
    self.toolBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), 40)];
    UIBarButtonItem *spaceButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                target:self
                                                                                action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]initWithTitle:getLocalizationString(@"finish")
                                                                  style:UIBarButtonItemStyleDone
                                                                 target:self
                                                                 action:@selector(resignKeyboard)];
    NSArray * buttonsArray = [NSArray arrayWithObjects:spaceButton,doneButton,nil];
    [_toolBar setItems:buttonsArray];
    
    self.cityPickerView = [UIPickerView new];
    self.cityPickerView.dataSource = self;
    self.cityPickerView.delegate = self;
    self.cityPickerView.backgroundColor=CDZColorOfWhite;
    self.queryPriceView.cityTF.inputAccessoryView=self.toolBar;
    self.queryPriceView.cityTF.inputView=self.cityPickerView;
    
    self.centerPickerView = [UIPickerView new];
    self.centerPickerView.dataSource = self;
    self.centerPickerView.delegate = self;
    self.centerPickerView.backgroundColor=CDZColorOfWhite;
    self.queryPriceView.cgzxTF.inputView=self.centerPickerView;
    self.queryPriceView.cgzxTF.inputAccessoryView=self.toolBar;
    
    
    CGRect searchBarRect = CGRectZero;
    searchBarRect.size = CGSizeMake(CGRectGetWidth(self.view.frame), 40.0f);
    self.searchBar = [[UISearchBarWithReturnKey alloc] initWithFrame:searchBarRect];
    self.searchBar.barTintColor = self.navigationController.navigationBar.barTintColor;
    self.searchBar.placeholder = @"请输入关键词/配件名称";
    self.searchBar.contentMode = UIViewContentModeLeft;
    self.searchBar.delegate = self;
    [self.searchBar setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:1.0f withColor:self.searchBar.barTintColor withBroderOffset:nil];
    [self.navigationItem setTitleView:self.searchBar];
    
    UIToolbar *toolBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), 40)];
    UIBarButtonItem *tfDoneButton = [[UIBarButtonItem alloc]initWithTitle:getLocalizationString(@"cancel")
                                                                  style:UIBarButtonItemStyleDone
                                                                 target:self.searchBar
                                                                 action:@selector(resignFirstResponder)];
    [toolBar setItems:@[spaceButton,tfDoneButton]];
    self.searchBar.inputAccessoryView = toolBar;
}

- (IBAction)buttonClick:(UIButton *)button {
    [self.searchBar resignFirstResponder];
    [self removeAllBtnsTitleColor];
    [button setTitleColor:[UIColor colorWithHexString:@"f8af30"] forState:UIControlStateNormal];
    if (button.tag==1) {
        self.sortNumber =@(0);
    }
    if (button.tag==2) {
        if (self.iSscore==NO) {
            self.sortNumber =@(6);
            self.iSscore=YES;
            [self.scoreButtonUP setBackgroundImage:[UIImage imageNamed:@"kjby-genghuanshangping-UP@3x"] forState:UIControlStateNormal];
        }else{
            self.sortNumber =@(5);
            self.iSscore=NO;
            [self.scoreButtonDown setBackgroundImage:[UIImage imageNamed:@"kjby-genghuanshangping-Down@3x"] forState:UIControlStateNormal];
        }
    }
    if (button.tag==3) {
        if (self.iSsalesVolume==NO) {
            self.sortNumber =@(2);
            self.iSsalesVolume=YES;
            [self.salesVolumeButtonUP setBackgroundImage:[UIImage imageNamed:@"kjby-genghuanshangping-UP@3x"] forState:UIControlStateNormal];
            
        }else{
            self.sortNumber =@(1);
            self.iSsalesVolume=NO;
            [self.salesVolumeButtonDown setBackgroundImage:[UIImage imageNamed:@"kjby-genghuanshangping-Down@3x"] forState:UIControlStateNormal];
        }
    }
    if (button.tag==4) {
        if (self.iSprice==NO) {
            self.sortNumber =@(4);
            self.iSprice=YES;
            [self.priceButtonUP setBackgroundImage:[UIImage imageNamed:@"kjby-genghuanshangping-UP@3x"] forState:UIControlStateNormal];
        }else{
            self.sortNumber =@(3);
            self.iSprice=NO;
            [self.priceButtonDown setBackgroundImage:[UIImage imageNamed:@"kjby-genghuanshangping-Down@3x"] forState:UIControlStateNormal];
        }
    }

    [self getProductListWithRefreshView:nil isAllReload:YES];
}

- (void)removeAllBtnsTitleColor {
    [self.salesVolumeButtonUP setBackgroundImage:[UIImage imageNamed:@"kjby_genghuanshangping_notSelect@3x"] forState:UIControlStateNormal];
    [self.salesVolumeButtonDown setBackgroundImage:[UIImage imageNamed:@"kjby_genghuanshangping_notSelectDown@3x"] forState:UIControlStateNormal];
    [self.priceButtonUP setBackgroundImage:[UIImage imageNamed:@"kjby_genghuanshangping_notSelect@3x"] forState:UIControlStateNormal];
    [self.priceButtonDown setBackgroundImage:[UIImage imageNamed:@"kjby_genghuanshangping_notSelectDown@3x"] forState:UIControlStateNormal];
    [self.scoreButtonUP setBackgroundImage:[UIImage imageNamed:@"kjby_genghuanshangping_notSelect@3x"] forState:UIControlStateNormal];
    [self.scoreButtonDown setBackgroundImage:[UIImage imageNamed:@"kjby_genghuanshangping_notSelectDown@3x"] forState:UIControlStateNormal];
    [self.allButton setTitleColor:[UIColor colorWithHexString:@"646464"] forState:UIControlStateNormal];
    [self.scoreButton setTitleColor:[UIColor colorWithHexString:@"646464"] forState:UIControlStateNormal];
    [self.salesVolumeButton setTitleColor:[UIColor colorWithHexString:@"646464"] forState:UIControlStateNormal];
    [self.priceButton setTitleColor:[UIColor colorWithHexString:@"646464"] forState:UIControlStateNormal];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ident = @"FindAccessoriesWithProductCell";
    FindAccessoriesWithProductCell *cell = [tableView dequeueReusableCellWithIdentifier:ident forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    self.indexPath=indexPath.row;
    if (self.productList.count>0) {
        
        
        NSDictionary*deatil=self.productList[indexPath.row];
        NSString *imgURL = [deatil objectForKey:@"product_img"];
        if ([imgURL containsString:@"http"]&&imgURL.length!=0) {
            [cell.productImageView sd_setImageWithURL:[NSURL URLWithString:imgURL] placeholderImage:[ImageHandler getDefaultWhiteLogo]];
        }
        cell.productNameLabel.text=deatil[@"product_name"];
        if ([[deatil objectForKey:@"no_yes"] isEqualToString:@"1"]) {
            cell.productPriceLabel.text=[NSString stringWithFormat:@"￥%@",deatil[@"product_price"]];
        }else{
            cell.productPriceLabel.text=[NSString stringWithFormat:@"暂时缺货"];
        }
        
        cell.dateLabel.text=[NSString stringWithFormat:@"%@人购买|%@人评价",deatil[@"sales"],deatil[@"comment_len"]];
        cell.starLabel.text=[NSString stringWithFormat:@"%@分",deatil[@"star"]];
        self.productionID=[deatil objectForKey:@"id"];
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _productList.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.view endEditing:YES];
    [self.searchBar resignFirstResponder];
    NSString *noOrYesStr = [self.productList[indexPath.row] objectForKey:@"no_yes"];
    if ([noOrYesStr isEqualToString:@"0"]) {
        [self getInquiryInfo];
        [self.queryPriceView setNeedsUpdateConstraints];
        [self.queryPriceView setNeedsDisplay];
        [self.queryPriceView setNeedsLayout];
        [self.queryPriceView showView];
    }else{
        NSString *string = [self.productList[indexPath.row] objectForKey:@"id"];
        [self getPartsDetailWithPartsID:string];
        
    }
    
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    if (pickerView==self.cityPickerView) {
        return 2;
    }
    else{
        return 1;
    }
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (pickerView==self.cityPickerView) {
        if (component==0) {
            return self.provinceInfoArr.count;
        }else{
            return self.cityInfoArr.count;
        }
    }else{
        return self.centerInfoArr.count;
    }
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSMutableArray*provinceInfoArr=[NSMutableArray array];
    NSMutableArray*cityInfoArr=[NSMutableArray array];
    NSMutableArray*centerInfoArr=[NSMutableArray array];
    for (NSDictionary *dic in self.provinceInfoArr) {
        [provinceInfoArr addObject:dic[@"name"]];
    }
    for (NSDictionary *dic in self.cityInfoArr) {
        [cityInfoArr addObject:dic[@"name"]];
    }
    for (NSDictionary *dic in self.centerInfoArr) {
        
        [centerInfoArr addObject:dic[@"name"]];
    }
    
    if (pickerView==self.cityPickerView) {
        if (component==0) {
            return [provinceInfoArr objectAtIndex:row];
        }else{
            return [cityInfoArr objectAtIndex:row];
        }
    }else{
        return [centerInfoArr objectAtIndex:row];
    }
    
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (pickerView==self.cityPickerView) {
        if (component==0) {
            self.cityInfoDic = nil;
            self.provinceInfoDic = self.provinceInfoArr[row];
            [self getInquiryInfo];
        }else{
            self.cityInfoDic = self.cityInfoArr[row];
            self.centerInfoDic = nil;
            [self.centerInfoArr removeAllObjects];
        }
        
    }else{
        if (self.centerInfoArr.count>0) {
            self.centerInfoDic = self.centerInfoArr[row];
        }else{
            
        }
        
    }
    
    
    
    
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    
    if (pickerView==self.centerPickerView) {
        return self.view.frame.size.width;
        
    }else {
        return self.view.frame.size.width/2;
    }
    
}


//分类
- (void)classification {
    if (!self.autosData.modelID||[self.autosData.modelID isEqualToString:@""]) {
        [SupportingClass showAlertViewWithTitle:@"" message:@"请选择车辆信息" isShowImmediate:YES cancelButtonTitle:nil otherButtonTitles:nil clickedButtonAtIndexWithBlock:nil];
        [ProgressHUDHandler dismissHUD];
        return;
    }
    FindAccessoriesCategoryVC *vc=[FindAccessoriesCategoryVC new];
    vc.carLabelText= self.carLabelText;
    vc.headImageUrl= self.headImageUrl;
    [self.navigationController pushViewController:vc animated:YES];
    [self setDefaultNavBackButtonWithoutTitle];
}
#pragma mark- Data Receive Handle
- (void)handleReceivedData:(id)responseObject withRefreshView:(id)refreshView isAllReload:(BOOL)isAllReload {
    if(!refreshView){
        [ProgressHUDHandler dismissHUD];
    }else{
        [self stopRefresh:refreshView];
    }
    if (!responseObject||![responseObject isKindOfClass:[NSDictionary class]]) {
        NSLog(@"Data Error!");
        return;
    }
    
    @autoreleasepool {
        if (isAllReload){
            [_productList removeAllObjects];
        }
        
        [_productList addObjectsFromArray:responseObject[CDZKeyOfResultKey]];
        
        if (self.productList.count>0) {
            self.refreshControl.hidden = NO;
            _tableView.mj_footer.hidden = NO;
            NSDictionary*deatil=self.productList.firstObject;
            if ([[deatil objectForKey:@"no_yes"] isEqualToString:@"0"]) {
                self.refreshControl.hidden = YES;
                _tableView.mj_footer.hidden = YES;
            }
        }else {
            self.refreshControl.hidden = YES;
            _tableView.mj_footer.hidden = YES;
        }
        
        
        self.totalPageSizes = @([responseObject[CDZKeyOfTotalPageSizesKey] integerValue]);
        self.pageNums = responseObject[CDZKeyOfPageNumsKey];
        self.pageSizes = responseObject[CDZKeyOfPageSizesKey];
        _tableView.mj_footer.hidden = ((self.pageNums.intValue*self.pageSizes.intValue)>self.totalPageSizes.intValue);
        [_tableView reloadData];
        
        
       
    }
}

- (void)stopRefresh:(id)refresh {
    [refresh endRefreshing];
}

- (void)delayHandleData:(id)refresh {
    
    if ([refresh isKindOfClass:[ODRefreshControl class]]) {
        if ([(ODRefreshControl *)refresh refreshing]) {
            [self getProductListWithRefreshView:refresh isAllReload:YES];
        }
        
    }else if ([refresh isKindOfClass:[MJRefreshAutoNormalFooter class]]){
        if ([(MJRefreshAutoNormalFooter *)refresh isRefreshing]) {
            self.pageNums = @(self.pageNums.integerValue+1);
            [self getProductListWithRefreshView:refresh isAllReload:NO];
        }
    }
}

- (void)refreshView:(id)refresh {
    if (!self.accessToken) {
        [self stopRefresh:refresh];
        return;
    }
    
    
    [self performSelector:@selector(delayHandleData:) withObject:refresh afterDelay:1.5];
    
}


#pragma -mark UITableViewDelgate
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *text = [NSString stringWithFormat:@"抱歉，暂无更多信息"];
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0f],
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (void)emptyDataSet:(UIScrollView *)scrollView didTapView:(UIView *)view {
    [self getProductListWithRefreshView:nil isAllReload:YES];
}

- (void)pushPartItemDetailViewWithItemDetail:(id)detail withPartsID:(NSString *)partsID {
    if (!detail||![detail isKindOfClass:[NSDictionary class]]) {
        return;
    }
    @autoreleasepool {
        PartsDetailVC *vc = [PartsDetailVC new];
        vc.productID = partsID;
        vc.itemDetail = detail;
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark- API Access Code Section
///* 配件详情 */
- (void)getPartsDetailWithPartsID:(NSString *)partsID {
    [ProgressHUDHandler showHUD];
    [[APIsConnection shareConnection] theSelfMaintenanceAPIsGetItemDetailWithWithAccessToken:self.accessToken productID:partsID success:^(NSURLSessionDataTask *operation, id responseObject) {
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        if(errorCode!=0){
            [ProgressHUDHandler dismissHUD];
            [SupportingClass showAlertViewWithTitle:@"error" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                
            }];
            return;
        }
        [ProgressHUDHandler dismissHUDWithCompletion:^{
            [self pushPartItemDetailViewWithItemDetail:responseObject[CDZKeyOfResultKey] withPartsID:partsID];
        }];
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

//查找配件
- (void)getProductListWithRefreshView:(id)refreshView isAllReload:(BOOL)isAllReload {
    //    [_searchTextField resignFirstResponder];
    
//    if (!self.accessToken) {
//        [self handleMissingTokenAction];
//        return;
//    }
    if (!refreshView) {
        [ProgressHUDHandler showHUD];
    }
    if (isAllReload) {
        [self pageObjectToDefault];
    }
    
    if (self.autopartInfo.length==0||self.keyWords==0) {
        self.autopartInfo=@"";
        self.keyWords=@"";
        
    }
    if (!self.autosData.modelID||[self.autosData.modelID isEqualToString:@""]) {
        [SupportingClass showAlertViewWithTitle:@"" message:@"请选择车辆信息" isShowImmediate:YES cancelButtonTitle:nil otherButtonTitles:nil clickedButtonAtIndexWithBlock:nil];
        [ProgressHUDHandler dismissHUD];
        return;
    }
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObject:@(isAllReload) forKey:@"isAllReload"];
    if (refreshView) {
        [userInfo addEntriesFromDictionary:@{@"refreshView":refreshView}];
    }
    
    [[APIsConnection shareConnection] personalCenterAPIsGetProductListBysortType:self.sortNumber autopartInfo:self.autopartInfo pageNums:self.pageNums pageSizes:self.pageSizes keyWords:self.keyWords speci:self.autosData.modelID success:^(NSURLSessionDataTask *operation, id responseObject) {
        operation.userInfo = userInfo;
        [self requestResultHandle:operation responseObject:responseObject withError:nil];
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        operation.userInfo = userInfo;
        [self requestResultHandle:operation responseObject:nil withError:error];
    }];
}
////、询价省份、城市、采购中心信息
- (void)getInquiryInfo {
    
    NSString *provinceInfoIDStr = self.provinceInfoDic[kObjKeyID];
    if (provinceInfoIDStr.length==0) {
        provinceInfoIDStr=@"";
    }
    NSString *cityIDStr = self.cityInfoDic[kObjKeyID];
    if (cityIDStr.length==0) {
        cityIDStr=@"";
    }
    NSLog(@"%@---%@",provinceInfoIDStr,cityIDStr);
    [[APIsConnection shareConnection] personalCenterAPIsGetInquiryInfoByprovinceID:provinceInfoIDStr cityID:cityIDStr success:^(NSURLSessionDataTask *operation, id responseObject) {
        
        operation.userInfo = @{@"ident":@"inquiryInfo"};
        [self requestResultHandle:operation responseObject:responseObject withError:nil];
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        operation.userInfo = @{@"ident":@"inquiryInfo"};
        [self requestResultHandle:operation responseObject:nil withError:error];
    }];
}

- (void)requestResultHandle:(NSURLSessionDataTask *)operation responseObject:(id)responseObject withError:(NSError *)error {
    id refreshView = operation.userInfo[@"refreshView"];
    BOOL isAllReload = [operation.userInfo[@"isAllReload"] boolValue];
    //    CDZMaintenanceStatusType currentStatusType = [operation.userInfo[@"MaintenanceStatusType"] integerValue];
    
    if (error&&!responseObject) {
        NSLog(@"%@",error);
        if(!refreshView){
            [ProgressHUDHandler dismissHUD];
        }else{
            [self stopRefresh:refreshView];
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
        [SupportingClass showAlertViewWithTitle:@"error" message:@"连接超时，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
        }];
        [_productList removeAllObjects];
        [_tableView reloadData];
    }else if (!error&&responseObject) {
        
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@-----%@",message,operation.currentRequest.URL.absoluteString);
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:(!refreshView)]) {
            return;
        }
        
        if (errorCode!=0) {
            if(!refreshView){
                [ProgressHUDHandler dismissHUD];
            }else{
                [self stopRefresh:refreshView];
            }
            [SupportingClass showAlertViewWithTitle:@"error" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                
            }];
            return;
        }
        if (operation.userInfo&&[operation.userInfo[@"ident"] isEqualToString:@"inquiryInfo"]) {
            NSDictionary *result = responseObject[CDZKeyOfResultKey];
            NSArray *provinceInfoArr = result[@"province_info"];
            NSArray *cityInfoArr = result[@"city_info"];
            NSArray *centerInfoArr = result[@"center_info"];
            
            if (provinceInfoArr.count>0) {
                [self.provinceInfoArr removeAllObjects];
                [self.provinceInfoArr addObjectsFromArray:provinceInfoArr];
                [self.cityPickerView reloadComponent:0];
                @weakify(self);
                [self.provinceInfoArr enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull detail, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([detail[kObjKeyName] isContainsString:@"湖南"]) {
                        @strongify(self);
                        [self.cityPickerView selectRow:idx inComponent:0 animated:NO];
                        *stop = YES;
                    }
                }];
            }
            
            if (cityInfoArr.count>0) {
                [self.cityInfoArr removeAllObjects];
                [self.cityInfoArr addObjectsFromArray:cityInfoArr];
                [self.cityPickerView reloadComponent:1];
            }
            if (centerInfoArr.count>0) {
                [self.centerInfoArr removeAllObjects];
                [self.centerInfoArr addObjectsFromArray:centerInfoArr];
                [self.centerPickerView reloadComponent:0];
            }else{
                [self.centerInfoArr removeAllObjects];
                self.queryPriceView.cgzxTF.text=@"";
                
                
            }
            [ProgressHUDHandler dismissHUD];
        }else if (operation.userInfo&&[operation.userInfo[@"ident"] isEqualToString:@"inquiryRequestSubmit"]) {
            [ProgressHUDHandler dismissHUD];
            @autoreleasepool {
                [self.queryPriceView hiddenView];
            
                MyEnquiryVC *vc = [MyEnquiryVC new];
                [self setDefaultNavBackButtonWithoutTitle];
                [self.navigationController pushViewController:vc animated:YES];
            }
        }else {
            [self handleReceivedData:responseObject withRefreshView:refreshView isAllReload:isAllReload];
        }
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
