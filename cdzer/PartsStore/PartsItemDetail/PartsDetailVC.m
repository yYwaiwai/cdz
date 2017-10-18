//
//  PartsDetailVC.m
//  cdzer
//
//  Created by KEns0nLau on 6/27/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "PartsDetailVC.h"
#import "HCSStarRatingView.h"
#import "ImageFallsTV.h"
#import "MyCarVC.h"
#import "GPSApplicationFormVC.h"
#import "ShopNItemPartsCommentListVC.h"
#import <M13BadgeView/M13BadgeView.h>
#import "MyShoppingCartVC.h"
#import "CDZOrderPaymentClearanceVC.h"
#import "CustomerServiceVC.h"

@interface PartsDetailVC ()

@property (nonatomic, strong) M13BadgeView *badgeView;


@property (nonatomic, weak) IBOutlet UIImageView *partsImageView;

@property (nonatomic, weak) IBOutlet UILabel *partsNameLabel;

@property (nonatomic, weak) IBOutlet UILabel *partsManufacturerLabel;

@property (nonatomic, weak) IBOutlet UILabel *partsDiscountPriceLabel;

@property (nonatomic, weak) IBOutlet UILabel *partsSoldRecordCountLabel;

@property (nonatomic, weak) IBOutlet UILabel *partsStockCountLabel;

@property (nonatomic, weak) IBOutlet UILabel *partsCommentCountLabel;

@property (nonatomic, weak) IBOutlet UIView *partsUpperInfoView;

@property (weak, nonatomic) IBOutlet UILabel *selectedCountLabel;

@property (weak, nonatomic) IBOutlet UIView *selectedCountLabelContainerView;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *countLabelViewTopConstraint;


@property (nonatomic, weak) IBOutlet UIImageView *commenterImageView;

@property (nonatomic, weak) IBOutlet UILabel *commenterPhoneLabel;

@property (nonatomic, weak) IBOutlet HCSStarRatingView *commenterRatingView;

@property (nonatomic, weak) IBOutlet UILabel *commentDateTimeLabel;

@property (nonatomic, weak) IBOutlet UILabel *commentContentLabel;

@property (nonatomic, weak) IBOutlet UIControl *partsCommentTitleView;

@property (nonatomic, weak) IBOutlet UIView *partsCommentContainerView;

@property (nonatomic, strong) IBOutlet NSLayoutConstraint *partsCommentHeightConstraint;

@property (nonatomic, strong) IBOutlet NSLayoutConstraint *partsCommentMoreHeightConstraint;



@property (nonatomic, weak) IBOutlet UIButton *partsInfoButton;

@property (nonatomic, weak) IBOutlet UIButton *partsImagesInfoButton;

@property (nonatomic, weak) IBOutlet UILabel *partsTypeTitleLabel;

@property (nonatomic, weak) IBOutlet UILabel *partsTypeContentLabel;

@property (nonatomic, weak) IBOutlet UILabel *partsPurchasingCenterLabel;

@property (nonatomic, weak) IBOutlet UILabel *partsDealershipNameLabel;

@property (nonatomic, weak) IBOutlet UILabel *partsCompatibilityLabel;

@property (nonatomic, weak) IBOutlet UIView *partsBottomButtonsView;

@property (nonatomic, weak) IBOutlet UIView *partsBottomInfoView;

@property (nonatomic, weak) IBOutlet ImageFallsTV *tableView;

@property (nonatomic, weak) IBOutlet UIView *nonImagesInfoView;

@property (nonatomic, weak) IBOutlet UIScrollView *infoScrollView;

@property (nonatomic, strong) IBOutlet NSLayoutConstraint *partsInfoScrollViewHeightConstraint;

@property (nonatomic, strong) IBOutlet NSLayoutConstraint *tableViewHeightConstraint;

@property (nonatomic, assign) BOOL wasInfoViewWithImages;




@property (nonatomic, weak) IBOutlet UIButton *addCartButton;

@property (nonatomic, weak) IBOutlet UIButton *buyNowButton;

@property (nonatomic, weak) IBOutlet UIButton *GPSAppiontmentButton;

@property (nonatomic, weak) IBOutlet UIView *bottomBannerView;

@property (weak, nonatomic) IBOutlet UIImageView *favoriteImageView;

@property (weak, nonatomic) IBOutlet UILabel *favoriteLabel;

@end

@implementation PartsDetailVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"产品详情";
    // Do any additional setup after loading the view.
    [self componentSetting];
    [self initializationUI];
    [self setReactiveRules];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self borderLineSetting];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)borderLineSetting {
    [self.selectedCountLabel.superview setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:0.5 withColor:[UIColor colorWithHexString:@"646464"] withBroderOffset:nil];
    [self.selectedCountLabel.superview setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:3.0f];
    [self.selectedCountLabel setViewBorderWithRectBorder:UIRectBorderLeft|UIRectBorderRight borderSize:0.5 withColor:[UIColor colorWithHexString:@"646464"] withBroderOffset:nil];
    [self.partsUpperInfoView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5
                                               withColor:[UIColor colorWithRed:0.839 green:0.843 blue:0.863 alpha:1.00]
                                        withBroderOffset:nil];
    [self.partsCommentContainerView setViewBorderWithRectBorder:UIRectBorderBottom|UIRectBorderTop borderSize:0.5
                                                      withColor:[UIColor colorWithRed:0.839 green:0.843 blue:0.863 alpha:1.00]
                                               withBroderOffset:nil];
    
    [self.partsCommentTitleView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5
                                                  withColor:[UIColor colorWithRed:0.839 green:0.843 blue:0.863 alpha:1.00]
                                           withBroderOffset:nil];
    
    [self.partsBottomInfoView setViewBorderWithRectBorder:UIRectBorderBottom|UIRectBorderTop borderSize:0.5
                                                withColor:[UIColor colorWithRed:0.839 green:0.843 blue:0.863 alpha:1.00]
                                         withBroderOffset:nil];
    
    [self.partsBottomButtonsView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5
                                                  withColor:[UIColor colorWithRed:0.839 green:0.843 blue:0.863 alpha:1.00]
                                           withBroderOffset:nil];
    
    [self.bottomBannerView setViewBorderWithRectBorder:UIRectBorderTop borderSize:0.5
                                             withColor:[UIColor colorWithRed:0.839 green:0.843 blue:0.863 alpha:1.00]
                                      withBroderOffset:nil];
}

- (void)setReactiveRules {
    @autoreleasepool {
        @weakify(self);
        [RACObserve(self, tableView.contentSize) subscribeNext:^(id size) {
            @strongify(self);
            CGSize contentSize = [size CGSizeValue];
            if (contentSize.height<=0) {
                contentSize.height = 126.0f;
            }
            self.tableViewHeightConstraint.constant = contentSize.height;
            if (self.wasInfoViewWithImages) {
                self.partsInfoScrollViewHeightConstraint.constant = contentSize.height;
            }
        }];
        
        [RACObserve(self, nonImagesInfoView.frame) subscribeNext:^(id rect) {
            @strongify(self);
            CGRect frame = [rect CGRectValue];
            if (!self.wasInfoViewWithImages) {
                self.partsInfoScrollViewHeightConstraint.constant = CGRectGetHeight(frame);
            }
        }];
    }
    
}

- (void)componentSetting {
    @autoreleasepool {
        if (!self.productID||[self.productID isEqualToString:@""]) {
           self.productID = self.itemDetail[@"id"];
        }
        [self.partsBottomButtonsView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull firstView, NSUInteger firstIdx, BOOL * _Nonnull firstStop) {
            if ([firstView isKindOfClass:UIControl.class]&&firstView.tag==1) {
                [firstView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull secondView, NSUInteger secondIdx, BOOL * _Nonnull secondStop) {
                    if ([secondView isKindOfClass:UIButton.class]) {
                        [secondView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:2
                                                      withColor:[(UIButton *)secondView titleColorForState:UIControlStateSelected]
                                               withBroderOffset:nil];
                        
                    }
                }];
            }
        }];
        
    }
}

- (IBAction)selectedCountAction:(UIButton *)sender {
    NSInteger currentSelectedCount = self.selectedCountLabel.text.integerValue;
    if (sender.tag==1) currentSelectedCount--;
    if (sender.tag==2) currentSelectedCount++;
    if (currentSelectedCount<1) currentSelectedCount=1;
    if (currentSelectedCount>50) currentSelectedCount=50;
    self.selectedCountLabel.text = @(currentSelectedCount).stringValue;
}

- (IBAction)changeInfoViewNUpdateButtonStatus:(UIControl *)sender {
    [self.partsBottomButtonsView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull firstView, NSUInteger firstIdx, BOOL * _Nonnull firstStop) {
        if ([firstView isKindOfClass:UIControl.class]) {
            [firstView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull secondView, NSUInteger secondIdx, BOOL * _Nonnull secondStop) {
                if ([secondView isKindOfClass:UIButton.class]) {
                    [secondView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0
                                                  withColor:CDZColorOfClearColor
                                           withBroderOffset:nil];
                    [(UIButton *)secondView setSelected:NO];
                    
                }
            }];
        }
    }];
    
    [sender.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull secondView, NSUInteger secondIdx, BOOL * _Nonnull secondStop) {
        if ([secondView isKindOfClass:UIButton.class]) {
            [secondView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:2
                                          withColor:[(UIButton *)secondView titleColorForState:UIControlStateSelected]
                                   withBroderOffset:nil];
            [(UIButton *)secondView setSelected:YES];
            
        }
    }];
    NSUInteger tag = (sender.tag-1);
    self.wasInfoViewWithImages = tag;
    [self.infoScrollView setContentOffset:CGPointMake(CGRectGetWidth(self.infoScrollView.frame)*tag, 0.0f) animated:NO];
    
    if (self.wasInfoViewWithImages) {
        CGSize contentSize = self.tableView.contentSize;
        if (contentSize.height<=0) {
            contentSize.height = 126.0f;
        }
        self.partsInfoScrollViewHeightConstraint.constant = contentSize.height;
    }else {
        self.partsInfoScrollViewHeightConstraint.constant = CGRectGetHeight(self.nonImagesInfoView.frame);
    }
}

- (void)initializationUI {
    @autoreleasepool {
        if (!self.badgeView) {
            self.badgeView = [[M13BadgeView alloc] initWithFrame:CGRectMake(0, 0, 14.0, 14.0)];
            self.badgeView.text = @"0";
            self.badgeView.font = [UIFont systemFontOfSize:11.0];
            self.badgeView.textColor = [UIColor colorWithRed:0.961 green:0.404 blue:0.412 alpha:1.00];
            self.badgeView.badgeBackgroundColor = CDZColorOfWhite;
            self.badgeView.borderColor = self.badgeView.textColor;
            self.badgeView.hidesWhenZero = YES;
            self.badgeView.borderWidth = 1.0f;
            self.badgeView.cornerRadius = ceilf(CGRectGetHeight(self.badgeView.frame)/2.0f);
            self.badgeView.horizontalAlignment = M13BadgeViewHorizontalAlignmentRight;
            self.badgeView.verticalAlignment = M13BadgeViewVerticalAlignmentTop;
        }
        [self updateUIData];
    }
}

- (void)updateUIData {
//    "all":1,
//    "allstar":"5.0",
//    "autopartinfoName":"机油",
//    "car_shop_num":"0",
//    "center_name":"长沙市麓谷配件超市",
//    "description":[
//     "",
//     "http://www.cdzer.net:80/imgUpload/demo/common/product/1605201151058s7Qc9kVxt.jpg",
//     "http://www.cdzer.net:80/imgUpload/demo/common/product/16052011510528FLcUrzp4.jpg",
//     "http://www.cdzer.net:80/imgUpload/demo/common/product/160520115105Z3wKYG34O5.jpg",
//     "http://www.cdzer.net:80/imgUpload/demo/common/product/160520115105F3May1rv3b.jpg",
//     "http://www.cdzer.net:80/imgUpload/demo/common/product/160520115105tZFUC5etxD.jpg"
//     ],
//    "factory":"16052010233090601795",
//    "factoryName":"壳牌",
//    "id":"16052011510885781950",
//    "img":"http://www.cdzer.net:80/imgUpload/demo/common/product/1605201150511rBsyLDTqF.png",
//    "len":1,
//    "leng":22,
//    "marketprice":"130",
//    "memberprice":"124",
//    "name":"壳牌（Shell）黄喜力Helix HX5 10W-40 (测试)",
//    "number":"PD160520115108471290",
//    "pjsId":"16052009455658482298",
//    "pjs_logo":"http://www.cdzer.net:80/imgUpload/demo/common/logo/1605201615500g2qglee23.jpg",
//    "sendcostName":"",
//    "speci_speci_name":[
//    {
//        "speci_name_str":    "适用所有车型",
//        "speci_str":    "适用所有车型id"
//    }
//     ],
//    "stocknum":"978",
//    "store_name":"长沙市麓谷配件商"
    
    //商品图片
    NSString *partsImageString = self.itemDetail[@"img"];
    self.partsImageView.image = [ImageHandler getWhiteLogo];
    if ([partsImageString isContainsString:@"http"]) {
        @weakify(self);
        [self.partsImageView setImageWithURL:[NSURL URLWithString:partsImageString]completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            @strongify(self);
            if (image) {
                UIImage *scaledImage = [UIImage imageWithCGImage:image.CGImage
                                                           scale:2.0f
                                                     orientation:image.imageOrientation];
                self.partsImageView.image = scaledImage;
            }
            
        } usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    //商品名称
    self.partsNameLabel.text = self.itemDetail[@"name"];
    //生产商名称
    self.partsManufacturerLabel.text = self.itemDetail[@"factoryName"];
    //商品优惠价
    self.partsDiscountPriceLabel.text = [NSString stringWithFormat:@"¥%@", [SupportingClass verifyAndConvertDataToString:self.itemDetail[@"memberprice"]]];
    //商品销售量
    self.partsSoldRecordCountLabel.text = [SupportingClass verifyAndConvertDataToString:self.itemDetail[@"leng"]];
    //商品库存
    self.partsStockCountLabel.text = [SupportingClass verifyAndConvertDataToString:self.itemDetail[@"stocknum"]];
    //商品评价总人数
    self.partsCommentCountLabel.text = [SupportingClass verifyAndConvertDataToString:self.itemDetail[@"all"]];
    self.partsCommentMoreHeightConstraint.active = YES;
    self.partsCommentHeightConstraint.active = NO;
    if ([self.partsCommentCountLabel.text isEqualToString:@"0"]) {
        self.partsCommentMoreHeightConstraint.active = NO;
        self.partsCommentHeightConstraint.active = YES;
        self.partsCommentHeightConstraint.constant = 43.0f;
    }
    
    [self.view setNeedsUpdateConstraints];
    [self.view setNeedsLayout];
    //是否收藏
    if ([self.itemDetail[@"is_favor"] isEqualToString:@"yes"]) {
        self.favoriteImageView.highlighted=YES;
        self.favoriteLabel.text=@"已收藏";
    }else{
        self.favoriteLabel.text=@"收藏";
    }
    
    BOOL wasCDZProducts = [self.itemDetail[@"factoryName"] isContainsString:@"车队长"];
    
    self.selectedCountLabelContainerView.hidden = wasCDZProducts;
    self.countLabelViewTopConstraint.constant = wasCDZProducts?-CGRectGetHeight(self.selectedCountLabelContainerView.frame):10;
    //商品类型标题
    self.partsTypeTitleLabel.text = wasCDZProducts?@"产品名称：":@"商品种类：";
    
    
    //商品类型
    NSString *partsTypeContentString = [SupportingClass verifyAndConvertDataToString:self.itemDetail[@"autopartinfoName"]] ;
    if (wasCDZProducts) {
        partsTypeContentString = self.itemDetail[@"name"];
    }
    if ([partsTypeContentString isKindOfClass:NSNull.class]||[partsTypeContentString isEqualToString:@""]) {
        partsTypeContentString = @"--";
    }
    self.partsTypeContentLabel.text = partsTypeContentString;
    
    
    //商品经销商
    NSString *partsDealershipString = self.itemDetail[@"store_name"];
    if (wasCDZProducts) {
        partsDealershipString = self.itemDetail[@"factoryName"];
    }
    if ([partsDealershipString isKindOfClass:NSNull.class]||[partsDealershipString isEqualToString:@""]) {
        partsDealershipString = @"--";
    }
    self.partsDealershipNameLabel.text = partsDealershipString;
    
    
    //采购中心
    NSString *centerNameString = [SupportingClass verifyAndConvertDataToString:self.itemDetail[@"center_name"]];
    if (wasCDZProducts&&[centerNameString isEqualToString:@""]) {
        centerNameString = self.itemDetail[@"factoryName"];
    }
    if ([centerNameString isKindOfClass:NSNull.class]||[centerNameString isEqualToString:@""]) {
        centerNameString = @"--";
    }
    self.partsPurchasingCenterLabel.text = centerNameString;
    
    //商品适配
    NSString *partsCompatibilityString = self.itemDetail[@"store_name"];
    if ([partsCompatibilityString isKindOfClass:NSNull.class]||[partsCompatibilityString isEqualToString:@""]) {
        partsCompatibilityString = @"--";
    }
    
    NSArray *array = [self.itemDetail[@"speci_speci_name"] valueForKey:@"speci_name_str"];
    NSString *partCompatibility = [array componentsJoinedByString:@"，"];
    
    if (!partCompatibility||[partCompatibility isEqualToString:@""]) {
        partCompatibility = @"--";
    }
    UserSelectedAutosInfoDTO *autosData = [[DBHandler shareInstance] getSelectedAutoData];
    self.partsCompatibilityLabel.text = partCompatibility;
    
    
    
    if (autosData&&[partCompatibility isContainsString:autosData.modelName]) {
        self.partsCompatibilityLabel.text = autosData.modelName;
    }
    
    
    NSArray *imageList = self.itemDetail[@"description"];
    if ([self.itemDetail[@"description"] isKindOfClass:NSArray.class]) {
        [self.tableView setupImageList:imageList];
    }
    
    
    NSUInteger commentCount = [SupportingClass verifyAndConvertDataToString:_itemDetail[@"all"]].integerValue;
    if (commentCount>0) {
        [self getPartsCommentList];
    }
    
    BOOL wasGPSDevice = NO;
    NSString *partsID = self.itemDetail[@"number"];
    if ([partsID isContainsString:@"PD141120094853302030"]||[partsID isContainsString:@"PD141120094853302029"]) {
        wasGPSDevice = YES;
    }
    
    self.GPSAppiontmentButton.hidden = !(!self.hiddenExpressBtnNCartAddBtnNGPSBtn&&wasGPSDevice);
    self.addCartButton.hidden = !(!self.hiddenExpressBtnNCartAddBtnNGPSBtn&&!wasGPSDevice);
    self.buyNowButton.hidden = !(!self.hiddenExpressBtnNCartAddBtnNGPSBtn&&!wasGPSDevice);
    self.navigationItem.rightBarButtonItem = nil;
    [self.badgeView removeFromSuperview];
    if (!self.hiddenExpressBtnNCartAddBtnNGPSBtn) {
        UIImage *cartImage = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"parts_detail_cart_icon@3x" ofType:@"png"]];
        UIButton *cartButton = [UIButton buttonWithType:UIButtonTypeCustom];
        cartButton.bounds = CGRectMake(0.0f, 0.0f, 30.0f, 18.0f);
        [cartButton setImage:cartImage forState:UIControlStateNormal];
        [cartButton addTarget:self action:@selector(hidehide) forControlEvents:UIControlEventTouchUpInside];
        [cartButton addSubview:self.badgeView];
        self.badgeView.horizontalAlignment = M13BadgeViewHorizontalAlignmentRight;
        self.badgeView.verticalAlignment = M13BadgeViewVerticalAlignmentTop;
        self.badgeView.text = @"0";
        UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithCustomView:cartButton];
        self.navigationItem.rightBarButtonItem = rightBarItem;
    }
    self.badgeView.text = [SupportingClass verifyAndConvertDataToString:self.itemDetail[@"car_shop_num"]];
    
    [self changeInfoViewNUpdateButtonStatus:(UIControl *)[self.partsBottomButtonsView viewWithTag:self.wasInfoViewWithImages+1]];
    [self.view setNeedsUpdateConstraints];
    [self.view setNeedsDisplay];
    [self.view setNeedsLayout];
}

- (void)hidehide {
    
    MyShoppingCartVC*vc=[MyShoppingCartVC new];
    [self.navigationController pushViewController:vc animated:YES];
    [self setDefaultNavBackButtonWithoutTitle];
    NSLog(@"hidehide");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pushToGPSAppointmentVC {
    @autoreleasepool {
        GPSApplicationFormVC *vc = GPSApplicationFormVC.new;
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)pushToCommentView {
    NSUInteger commentCount = [SupportingClass verifyAndConvertDataToString:_itemDetail[@"all"]].integerValue;
    if (commentCount==0) {
        [SupportingClass showAlertViewWithTitle:@"alert_remind" message:@"没有更多的评论" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:nil];
        return;
    }
    NSString *partsID = [SupportingClass verifyAndConvertDataToString:_itemDetail[@"id"]];
    if (!partsID) return;
    NSLog(@"%@ accessing network change parts favorite request",NSStringFromClass(self.class));
    
    ShopNItemPartsCommentListVC *vc = [ShopNItemPartsCommentListVC new];
    vc.commentTypeID = partsID;
    vc.commentType = SNIPCLCommentTypeOfParts;
    [self setDefaultNavBackButtonWithoutTitle];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)pushToAutosInfoVC {
    @autoreleasepool {
        MyCarVC *vc = MyCarVC.new;
        vc.wasBackRootView = NO;
        vc.wasSubmitAfterLeave = YES;
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)addPartsToCart {
    
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    
    UserSelectedAutosInfoDTO *autosData = [[DBHandler shareInstance] getSelectedAutoData];
    NSString *brandID = autosData.brandID;
    NSString *brandDealershipID = autosData.dealershipID;
    NSString *seriesID = autosData.seriesID;
    NSString *modelID = autosData.modelID;
    
    if (!brandID||[autosData.brandID isEqualToString:@""]||
        !brandDealershipID||[autosData.dealershipID isEqualToString:@""]||
        !seriesID||[autosData.seriesID isEqualToString:@""]||
        !modelID||[autosData.modelID isEqualToString:@""]) {
        @weakify(self);
        [SupportingClass showAlertViewWithTitle:nil message:@"预约前，需要完善个人车辆信息，现在去完善吗？" isShowImmediate:YES cancelButtonTitle:@"cancel" otherButtonTitles:@"ok" clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            @strongify(self);
            if (btnIdx.integerValue>0) {
                [self pushToAutosInfoVC];
            }
        }];
        return;
    }
    
    [ProgressHUDHandler showHUD];
    NSString *theID = _itemDetail[@"id"];
    @weakify(self);
    NSLog(@"%@ accessing network add parts to cart request",NSStringFromClass(self.class));
    [[APIsConnection shareConnection] personalCenterAPIsPostInsertProductToTheCartWithAccessToken:self.accessToken productID:theID brandID:brandID brandDealershipID:brandDealershipID seriesID:seriesID modelID:modelID success:^(NSURLSessionDataTask *operation, id responseObject) {
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        [ProgressHUDHandler dismissHUD];
        NSString *title = getLocalizationString(@"alert_remind");
        if (errorCode!=0) title = getLocalizationString(@"error");
        [SupportingClass showAlertViewWithTitle:title message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            
        }];
        @strongify(self);
        if (!self) return;
        if (errorCode==0)[self getPartsDetail];
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        @strongify(self);
        if (!self) return;
        [ProgressHUDHandler dismissHUD];
        [SupportingClass showAlertViewWithTitle:@"error" message:@"连接逾时！请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            
        }];
    }];
    
}

- (IBAction)customerService {
    CustomerServiceVC *vc = [CustomerServiceVC new];
    [self setDefaultNavBackButtonWithoutTitle];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)changeFavorite {
    
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    [ProgressHUDHandler showHUD];
    @weakify(self)
    NSLog(@"%@ accessing network change parts favorite request",NSStringFromClass(self.class));
    NSString *theID = _itemDetail[@"number"];
    [[APIsConnection shareConnection] personalCenterAPIsPostInsertProductCollectionWithAccessToken:self.accessToken productIDList:@[theID] success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self)
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        
        [ProgressHUDHandler dismissHUD];
        if (errorCode!=0) {
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                
            }];
            return;
        }
        [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            self.favoriteImageView.highlighted=YES;
            self.favoriteLabel.text=@"已收藏";
        }];
//        self.addFavorite.selected = YES;
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        @strongify(self);
        if (!self) return;
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
    
    //    if (_addFavorite.selected) {
    //        [[APIsConnection shareConnection] personalCenterAPIsPostDeleteProductsCollectionWithAccessToken:self.accessToken collectionIDList:@[theID] success:^(NSURLSessionDataTask *operation, id responseObject) {
    //            @strongify(self)
    //            [ProgressHUDHandler dismissHUD];
    //            NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
    //            NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
    //            if (errorCode!=0) {
    //                [SupportingClass showAlertViewWithTitle:@"error" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
    //
    //                }];
    //                return;
    //            }
    //            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
    //
    //            }];
    //            self.addFavorite.selected = NO;
    //
    //        } failure:^(NSURLSessionDataTask *operation, NSError *error) {
    //            [ProgressHUDHandler dismissHUD];
    //        }];
    //    }else {
    //        [[APIsConnection shareConnection] personalCenterAPIsPostInsertProductCollectionWithAccessToken:self.accessToken productIDList:@[theID] success:^(NSURLSessionDataTask *operation, id responseObject) {
    //            @strongify(self)
    //            [ProgressHUDHandler dismissHUD];
    //            NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
    //            NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
    //            if (errorCode!=0) {
    //                [SupportingClass showAlertViewWithTitle:@"error" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
    //
    //                }];
    //                return;
    //            }
    //            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
    //
    //            }];
    //            self.addFavorite.selected = YES;
    //        } failure:^(NSURLSessionDataTask *operation, NSError *error) {
    //            [ProgressHUDHandler dismissHUD];
    //        }];
    //    }
    
}

- (void)handleUserLoginResult:(BOOL)isSuccess fromAlert:(BOOL)fromAlert{
    if (isSuccess) {
        NSLog(@"success reload function %d", [self executeReloadFunction]);
    }else {
        //        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)getPartsCommentList {
    
    NSString *partsID = [SupportingClass verifyAndConvertDataToString:_itemDetail[@"id"]];
    @weakify(self)
    [[APIsConnection shareConnection] autosPartsAPIsGetAutosPartsCommnetListWithProductID:partsID pageNums:nil pageSizes:nil success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self)
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        if(errorCode!=0){
            [SupportingClass showAlertViewWithTitle:@"error" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                
            }];
            return;
        }
        
//        "content": "bxncjncjd",
//        "face_img": "http://cdz.cdzer.com:80/imgUpload/demo/basic/faceImg/150914163436gWgtHsGurl.jpg",
//        "create_time": "2015-09-16 16:28:15 ",
//        "userName": "181****7163",
//        "autopart_name": "嘉实多ATF多用途自动变速箱油/波箱油/排档液4L",
//        "star": "1.0",
//        "id": "15091616281597383050",
//        "repply_content": ""
        if ([responseObject[CDZKeyOfResultKey] count]>0&&[responseObject[CDZKeyOfResultKey] isKindOfClass:NSArray.class]) {
            NSDictionary *firstDetail = [responseObject[CDZKeyOfResultKey] firstObject];
            NSString *partsImageString = firstDetail[@"face_img"];
            self.commenterImageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"eservice_default_img@3x.png" ofType:nil]];
            if ([partsImageString isContainsString:@"http"]) {
                @strongify(self);
                [self.commenterImageView setImageWithURL:[NSURL URLWithString:partsImageString] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            }
            
            self.commentDateTimeLabel.text = firstDetail[@"create_time"];
            self.commenterPhoneLabel.text = firstDetail[@"userName"];
            self.commenterRatingView.value = [firstDetail[@"star"] floatValue];
            self.commentContentLabel.text = firstDetail[@"content"];

            
        }
        
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        @strongify(self);
        if (!self) return;
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

/* 快速购买*/
- (IBAction)confirmCartOrder {
    @autoreleasepool {
        NSString *productID = self.itemDetail[@"id"];
        NSMutableArray *productslist = [@[productID] mutableCopy];
        NSMutableArray *countingList = [@[self.selectedCountLabel.text] mutableCopy];
        CDZOrderPaymentClearanceVC *vc = [CDZOrderPaymentClearanceVC new];
        vc.orderClearanceType = CDZOrderPaymentClearanceTypeOfRegularParts;
        vc.isBuyNow = YES;
        vc.productList = productslist;
        vc.productCountList = countingList;
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

///* 配件详情 */
- (void)getPartsDetail {
    @weakify(self);
    [ProgressHUDHandler showHUD];
    [[APIsConnection shareConnection] theSelfMaintenanceAPIsGetItemDetailWithWithAccessToken:self.accessToken productID:self.productID success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        if(errorCode!=0){
            [ProgressHUDHandler dismissHUD];
            [SupportingClass showAlertViewWithTitle:@"error" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                
            }];
            return;
        }
        [ProgressHUDHandler dismissHUD];
        self.itemDetail = responseObject[CDZKeyOfResultKey];
        [self updateUIData];
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        @strongify(self);
        if (!self) return;
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
