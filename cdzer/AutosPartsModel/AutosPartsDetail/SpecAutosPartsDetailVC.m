//
//  SpecAutosPartsDetailVC.m
//  cdzer
//
//  Created by KEns0nLau on 9/3/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "SpecAutosPartsDetailVC.h"
#import "HCSStarRatingView.h"
#import "ImageFallsTV.h"
#import "ShopNItemPartsCommentListVC.h"
#import "ShopNServiceDetailVC.h"
#import "CDZOrderPaymentClearanceVC.h"

@interface SpecAutosPartsDetailVC ()

@property (strong, nonatomic) NSDictionary *itemDetail;

@property (weak, nonatomic) IBOutlet UIImageView *productIV;

@property (weak, nonatomic) IBOutlet UILabel *productNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *productSalePriceLabel;

@property (weak, nonatomic) IBOutlet UILabel *productSoldCountLabel;

@property (weak, nonatomic) IBOutlet UILabel *selectedCountLabel;

@property (weak, nonatomic) IBOutlet UILabel *productStockCountLabel;


@property (nonatomic, weak) IBOutlet UIImageView *commenterImageView;

@property (nonatomic, weak) IBOutlet UILabel *partsCommentCountLabel;

@property (nonatomic, weak) IBOutlet UILabel *commenterPhoneLabel;

@property (nonatomic, weak) IBOutlet HCSStarRatingView *commenterRatingView;

@property (nonatomic, weak) IBOutlet UILabel *commentDateTimeLabel;

@property (nonatomic, weak) IBOutlet UILabel *commentContentLabel;

@property (nonatomic, weak) IBOutlet UIControl *partsCommentTitleView;

@property (nonatomic, weak) IBOutlet UIView *partsCommentContainerView;

@property (nonatomic, strong) IBOutlet NSLayoutConstraint *partsCommentHeightConstraint;


@property (weak, nonatomic) IBOutlet UIImageView *shopBrandLogoIV;

@property (weak, nonatomic) IBOutlet UILabel *shopNameLabel;

@property (weak, nonatomic) IBOutlet HCSStarRatingView *shopCommentStarView;

@property (weak, nonatomic) IBOutlet UILabel *shopCommentMarkLabel;

@property (weak, nonatomic) IBOutlet UILabel *shopSaleCountLabel;

@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;

@property (weak, nonatomic) IBOutlet UILabel *shopAddressLabel;

@property (weak, nonatomic) IBOutlet UIButton *shoptelBtn;

@property (strong, nonatomic) NSString *shopTelNumber;


@property (nonatomic, weak) IBOutlet UIButton *partsInfoButton;

@property (nonatomic, weak) IBOutlet UIButton *partsImagesInfoButton;

@property (nonatomic, weak) IBOutlet UILabel *partsTypeLabel;

@property (nonatomic, weak) IBOutlet UILabel *partsSpecLabel;

@property (nonatomic, weak) IBOutlet UIView *partsBottomButtonsView;

@property (nonatomic, weak) IBOutlet UIView *partsBottomInfoView;

@property (nonatomic, weak) IBOutlet ImageFallsTV *tableView;

@property (nonatomic, weak) IBOutlet UIView *nonImagesInfoView;

@property (nonatomic, weak) IBOutlet UIScrollView *infoScrollView;

@property (nonatomic, strong) IBOutlet NSLayoutConstraint *partsInfoScrollViewHeightConstraint;

@property (nonatomic, strong) IBOutlet NSLayoutConstraint *tableViewHeightConstraint;

@property (nonatomic, assign) BOOL wasInfoViewWithImages;


@property (nonatomic, weak) IBOutlet UIView *bottomInfoView;


@end

@implementation SpecAutosPartsDetailVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.loginAfterShouldPopToRoot = NO;
    self.title = @"产品详情";
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
    [self.selectedCountLabel.superview setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:0.5 withColor:[UIColor colorWithHexString:@"646464"] withBroderOffset:nil];
    [self.selectedCountLabel.superview setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:3.0f];
    [self.selectedCountLabel setViewBorderWithRectBorder:UIRectBorderLeft|UIRectBorderRight borderSize:0.5 withColor:[UIColor colorWithHexString:@"646464"] withBroderOffset:nil];
    [self.productStockCountLabel.superview.superview setViewBorderWithRectBorder:UIRectBorderTop|UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    
    [self borderLineSetting];
    
    
    [self.shopBrandLogoIV setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self.shopBrandLogoIV setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:4.0f];
    BorderOffsetObject *offset = [BorderOffsetObject new];
    offset.leftUpperOffset = roundf(CGRectGetHeight(self.shoptelBtn.frame)*0.2);
    offset.leftBottomOffset = offset.leftUpperOffset;
    [self.shoptelBtn setViewBorderWithRectBorder:UIRectBorderLeft borderSize:0.5 withColor:nil withBroderOffset:offset];
    [self.shoptelBtn.superview setViewBorderWithRectBorder:UIRectBorderTop borderSize:0.5 withColor:nil withBroderOffset:offset];
    [self.shoptelBtn.superview.superview setViewBorderWithRectBorder:UIRectBorderTop|UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:offset];
    
    [self.partsBottomButtonsView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull firstView, NSUInteger firstIdx, BOOL * _Nonnull firstStop) {
        if ([firstView isKindOfClass:UIControl.class]&&firstView.tag==0) {
            [firstView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull secondView, NSUInteger secondIdx, BOOL * _Nonnull secondStop) {
                if ([secondView isKindOfClass:UIButton.class]) {
                    [secondView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:2
                                                  withColor:[(UIButton *)secondView titleColorForState:UIControlStateSelected]
                                           withBroderOffset:nil];
                    
                }
            }];
        }
    }];
    [self.nonImagesInfoView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self.partsBottomButtonsView setViewBorderWithRectBorder:UIRectBorderTop|UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self.bottomInfoView setViewBorderWithRectBorder:UIRectBorderTop borderSize:0.5 withColor:nil withBroderOffset:nil];


}

- (void)borderLineSetting {
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
}

- (void)handleNavBackBtnPopOtherAction {
    @autoreleasepool {
        
    }
}

- (void)componentSetting {
    @autoreleasepool {
        [self getSpecPartsDeatil];
    }
}

- (void)initializationUI {
    @autoreleasepool {
        
    }
}

- (void)setReactiveRules {
    @autoreleasepool {
        @weakify(self);
        [RACObserve(self, tableView.contentSize) subscribeNext:^(id size) {
            @strongify(self);
            CGSize contentSize = [size CGSizeValue];
            if (contentSize.height<=0) {
                contentSize.height = 72.0f;
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

- (void)updateUIData {
//    "id": "16070214505549089599",
//    "name": "玻璃",
//    "logo": "http://he.bccar.net:80/imgUpload/demo/common/product/160702145044lM3YFGGr0K.png",
//    "price": "1",
//    "sales": "21",
//    "stocknum": "79",
//    "product_model": "玻璃",
//    "kind_name": "前挡风玻璃",
//    "comment_len": 0,
//    "star": "5.0",
//    "comment_info": { },
//    "product_info": [
//    {
//        "imgurl": "http://he.bccar.net:80/imgUpload/demo/common/product/160702145052oas8xoVUTq.png"
//    }
//                     ],
//    "wxs_info": {
//        "wxs_id": "16061411182263347181",
//        "wxs_name": "汽车玻璃专修店",
//        "wxs_kind": "专修店",
//        "wxs_tel": "0731-88865333",
//        "wxs_logo": "http://cdz.cdzer.net:80/imgUpload/demo/common/logo/160920162757s31pvQtKwC.png",
//        "wxs_address": "湖南省长沙市岳麓区麓谷麓枫路21号",
//        "wxs_star": "4.3",
//        "wxs_sales": 118,
//        "wxs_distance": 1
//    }
//

    //商品图片
    NSString *partsImageString = self.itemDetail[@"logo"];
    if ([partsImageString isContainsString:@"http"]) {
        @weakify(self);
        [self.productIV setImageWithURL:[NSURL URLWithString:partsImageString] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            @strongify(self);
            if (image) {
                UIImage *scaledImage = [UIImage imageWithCGImage:image.CGImage
                                                           scale:2.0f
                                                     orientation:image.imageOrientation];
                self.productIV.image = scaledImage;
            }else {
                self.productIV.image = [ImageHandler getColorLogo];
            }
            
        } usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    //商品名称
    self.productNameLabel.text = self.itemDetail[@"name"];
    //商品原价
    self.productSalePriceLabel.text = [SupportingClass verifyAndConvertDataToString:self.itemDetail[@"price"]];
    //商品销售量
    self.productSoldCountLabel.text = [SupportingClass verifyAndConvertDataToString:self.itemDetail[@"sales"]];
    //商品库存
    self.productStockCountLabel.text = [SupportingClass verifyAndConvertDataToString:self.itemDetail[@"stocknum"]];
    //商品评价总人数
    self.partsCommentCountLabel.text = [SupportingClass verifyAndConvertDataToString:self.itemDetail[@"comment_len"]];
    self.partsCommentHeightConstraint.active = YES;
    self.partsCommentHeightConstraint.constant = 43.0f;
    if (![self.partsCommentCountLabel.text isEqualToString:@"0"]) {
        self.partsCommentHeightConstraint.active = NO;
        NSDictionary *commentInfo = self.itemDetail[@"comment_info"];
        NSString *partsImageString = commentInfo[@"face_img"];
        self.commenterImageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"eservice_default_img@3x.png" ofType:nil]];
        
        if ([partsImageString isContainsString:@"http"]) {
            [self.commenterImageView setImageWithURL:[NSURL URLWithString:partsImageString] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        }
        
        self.commentDateTimeLabel.text = commentInfo[@"create_time"];
        self.commenterPhoneLabel.text = commentInfo[@"userName"];
        self.commenterRatingView.value = [commentInfo[@"star"] floatValue];
        self.commentContentLabel.text = commentInfo[@"content"];
    }
    
    NSDictionary *shopDetail = self.itemDetail[@"wxs_info"];
    NSString *shopBrandLogoString = shopDetail[@"wxs_logo"];
    if ([shopBrandLogoString isContainsString:@"http"]) {
        @weakify(self);
        [self.shopBrandLogoIV setImageWithURL:[NSURL URLWithString:shopBrandLogoString] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            @strongify(self);
            if (image) {
                UIImage *scaledImage = [UIImage imageWithCGImage:image.CGImage
                                                           scale:2.0f
                                                     orientation:image.imageOrientation];
                self.shopBrandLogoIV.image = scaledImage;
            }else {
                self.shopBrandLogoIV.image = [ImageHandler getWhiteLogo];
            }
            
        } usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    self.shopTelNumber = [SupportingClass verifyAndConvertDataToString:shopDetail[@"wxs_tel"]];
    self.shopNameLabel.text = shopDetail[@"wxs_name"];
    self.shopAddressLabel.text = shopDetail[@"wxs_address"];
    self.shopCommentMarkLabel.text = [SupportingClass verifyAndConvertDataToString:shopDetail[@"wxs_star"]];
    self.shopCommentStarView.value = self.shopCommentMarkLabel.text.floatValue;
    self.shopSaleCountLabel.text = [SupportingClass verifyAndConvertDataToString:shopDetail[@"wxs_sales"]];
    self.distanceLabel.text = [SupportingClass verifyAndConvertDataToString:shopDetail[@"wxs_distance"]];
    
    
    self.partsTypeLabel.text = self.itemDetail[@"kind_name"];
    self.partsSpecLabel.text = self.itemDetail[@"product_model"];
    

    if ([self.itemDetail[@"product_info"] isKindOfClass:NSArray.class]) {
        NSArray *imageList = [self.itemDetail[@"product_info"] valueForKey:@"imgurl"];
        [self.tableView setupImageList:imageList];
    }

    
    
    [self.view setNeedsUpdateConstraints];
    [self.view setNeedsLayout];
    
}

- (void)getSpecPartsDeatil {
    @weakify(self);
    [ProgressHUDHandler showHUD];
    [APIsConnection.shareConnection rapidRepairAPIsGetSpecProductDetailWithSpecProductID:self.specProductID coordinate:self.coordinate success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        if (errorCode!=0) {
            [ProgressHUDHandler dismissHUD];
            [SupportingClass showAlertViewWithTitle:@"" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            }];
            return ;
        }
        
        [ProgressHUDHandler dismissHUD];
        self.itemDetail = responseObject[CDZKeyOfResultKey];
        [self updateUIData];
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

- (IBAction)pushToProductsOrderClearance {
    @autoreleasepool {
        CDZOrderPaymentClearanceVC *vc = [CDZOrderPaymentClearanceVC new];
        UIImage *image = [ImageHandler scaleImage:self.shopBrandLogoIV.image toNewSize:CGSizeMake(15.0f, 15.0f)];
        if (image) vc.shopLogoImage = image;
        vc.specProductID = [SupportingClass verifyAndConvertDataToString:self.itemDetail[@"id"]];
        vc.specProductPurchaseCount = @(self.selectedCountLabel.text.integerValue);
        vc.orderClearanceType = CDZOrderPaymentClearanceTypeOfSpecRepair;
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)dailupTheTel {
    if (self.shopTelNumber&&![self.shopTelNumber isEqualToString:@""]) {
        [SupportingClass makeACall:self.shopTelNumber andContents:[@"系统将会拨打以下号码：\n" stringByAppendingString:self.shopTelNumber] withTitle:@"温馨提示"];
    }
}

- (IBAction)pushToCommentView {
    NSUInteger commentCount = [SupportingClass verifyAndConvertDataToString:_itemDetail[@"comment_len"]].integerValue;
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

- (IBAction)pushToShopDetail {
    @autoreleasepool {
        NSDictionary *shopDetail = self.itemDetail[@"wxs_info"];
        ShopNServiceDetailVC *vc = nil;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.class == %@", ShopNServiceDetailVC.class];
        NSArray *result = [self.navigationController.viewControllers filteredArrayUsingPredicate:predicate];
        if (result&&result.count>0) {
            vc = (ShopNServiceDetailVC *)result.lastObject;
            vc.shopOrServiceID = [SupportingClass verifyAndConvertDataToString:shopDetail[@"wxs_id"]];
            vc.wasSpecItemService = YES;
            vc.shouldReloadData = YES;
            [self.navigationController popToViewController:result.lastObject animated:YES];
            return;
        }
        
        vc = [ShopNServiceDetailVC new];
        vc.shopOrServiceID = [SupportingClass verifyAndConvertDataToString:shopDetail[@"wxs_id"]];
        vc.wasSpecItemService = YES;
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
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
    self.wasInfoViewWithImages = sender.tag;
    [self.infoScrollView setContentOffset:CGPointMake(CGRectGetWidth(self.infoScrollView.frame)*sender.tag, 0.0f) animated:NO];
    
    if (self.wasInfoViewWithImages) {
        CGSize contentSize = self.tableView.contentSize;
        if (contentSize.height<=0) {
            contentSize.height = 72.0f;
        }
        self.partsInfoScrollViewHeightConstraint.constant = contentSize.height;
    }else {
        self.partsInfoScrollViewHeightConstraint.constant = CGRectGetHeight(self.nonImagesInfoView.frame);
    }
}

@end
