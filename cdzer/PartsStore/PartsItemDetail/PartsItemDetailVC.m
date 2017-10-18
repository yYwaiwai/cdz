//
//  PartsItemDetailVC.m
//  cdzer
//
//  Created by KEns0n on 3/20/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//  配件信息VC

#define vStartSpace (22.0f)

#import "PartsItemDetailVC.h"
#import "HCSStarRatingView.h"
#import "InsetsLabel.h"
#import "PartsInfoView.h"
#import "FindAccessoriesVC.h"
#import "UserSelectedAutosInfoDTO.h"
#import "MyShoppingCartVC.h"
#import "PartsCommentVC.h"
#import "GPSApplicationFormVC.h"
#import "MyCarVC.h"
#import <SDWebImage/UIImageView+WebCache.h>
@interface PartsItemDetailVC ()

@property (nonatomic, assign) BOOL isPriceNeedToEnquire;
/// 自动数据
@property (nonatomic, strong) UserSelectedAutosInfoDTO *autoData;
/// 评论列表
@property (nonatomic, strong) NSArray *commentList;
/// 零件项目明细
@property (nonatomic, strong) UIImageView *itemImageView;
/// 自动标签项目
@property (nonatomic, strong) InsetsLabel *itemForAutoLabel;
/// 信息视图
@property (nonatomic, strong) PartsInfoView *infoView;

#pragma mark - contentView
/// 项目标题标签
@property (nonatomic, strong) InsetsLabel *itemTitleLabel;
/// 项目描述标签
@property (nonatomic, strong) InsetsLabel *itemDescriptionLabel;
/// 项目价格标签
@property (nonatomic, strong) InsetsLabel *itemPriceLabel;

@property (nonatomic, strong) InsetsLabel *itemOPriceLabel;


#pragma mark - BottomView
/// 底部的容器视图
@property (nonatomic, strong) UIView *buttomContainerView;
/// 添加购物车按钮
@property (nonatomic, strong) UIButton *addCartButton;
/// 购物车按钮
@property (nonatomic, strong) UIButton *cartButton;
/// 收藏我们按钮
@property (nonatomic, strong) UIButton *addFavorite;

/// GPS设备
@property (nonatomic, assign) BOOL wasGPSDevice;

@end

@implementation PartsItemDetailVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.contentView.backgroundColor = [UIColor colorWithRed:0.953f green:0.953f blue:0.953f alpha:1.00f];
    self.title = @"产品详情";//getLocalizationString(@"item_detail");
    self.autoData = [[DBHandler shareInstance] getSelectedAutoData];
    self.isPriceNeedToEnquire = NO;
    if (!_itemDetail[@"no_yes"]&&![_itemDetail[@"no_yes"] boolValue]) {
        self.isPriceNeedToEnquire = YES;
    }
    self.wasGPSDevice = NO;
    NSString *name = [SupportingClass verifyAndConvertDataToString:_itemDetail[@"name"]];
    if (![name isEqualToString:@""]&&[name isContainsString:@"GPS"]) {
        self.wasGPSDevice = YES;
    }
    self.commentList = @[];
    [self initializationUI];
    [self setReactiveRules];
    // Do any additional setup after loading the view, typically from a nib.
    self.loginAfterShouldPopToRoot = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getCollectedStoreListWithpageNums:@"1" pageSizes:@"100"];
}

- (void)setReactiveRules {
    @weakify(self);
    
    [RACObserve(self, infoView.frame) subscribeNext:^(id theRect) {
        @strongify(self);
        CGRect rect = [theRect CGRectValue];
         [self.scrollView setContentSize:CGSizeMake(CGRectGetWidth(self.scrollView.frame), CGRectGetMaxY(rect)+(30.0f))];
    }];
}

- (void)initializationUI {
    
//    all = 1;
//    allstar = "1.0";
//    autopartinfoName = "\U706b\U82b1\U585e";
//    "car_shop_num" = 0;
//    "center_name" = "\U957f\U6c99\U9ad8\U6865\U91c7\U8d2d\U4e2d\U5fc3";
//    description =     (
//                       "",
//                       "http://cdz.cdzer.com:80/imgUpload/demo/common/product/150916154706LzyaDpue9g.jpg",
//                       "http://cdz.cdzer.com:80/imgUpload/demo/common/product/150916154707fSX5Ir3YOk.jpg",
//                       "http://cdz.cdzer.com:80/imgUpload/demo/common/product/150916154707SpgH7ezsR6.jpg",
//                       "http://cdz.cdzer.com:80/imgUpload/demo/common/product/150916154707GnWdueWVyC.jpg",
//                       "http://cdz.cdzer.com:80/imgUpload/demo/common/product/150916154707Glb0RYYYQ5.jpg"
//                       );
//    factory = 15090110490849799931;
//    factoryName = "\U535a\U4e16";
//    id = 15091615470912620536;
//    img = "http://cdz.cdzer.com:80/imgUpload/demo/common/product/150916154650fXtQStzAlG.png";
//    len = 1;
//    leng = 4;
//    marketprice = 105;
//    memberprice = 100;
//    name = "\U535a\U4e16\U94f1\U91d1\U706b\U82b1\U585e4\U652f\U88c5";
//    number = PD150916154709779321;
//    pjsId = 15090110111178107017;
//    "pjs_logo" = "http://cdz.cdzer.com:80/imgUpload/uploads/20150902151733xpZ99sObPZ.png";
//    sendcostName = "";
//    "speci_speci_name" =     (
//                              {
//                                  "speci_name_str" = "2015\U6b3e 30 TFSI \U624b\U52a8\U8212\U9002\U578b";
//                                  "speci_str" = 19485;
//                              },
//                              {
//                                  "speci_name_str" = "2015\U6b3e 30 TFSI \U624b\U52a8\U8212\U9002\U578b";
//                                  "speci_str" = 19485;
//                              }
//                              );
//    stocknum = 933;
//    "store_name" = "\U6e56\U5357\U4e30\U8fbe\U6c7d\U8f66\U914d\U4ef6";

    @autoreleasepool {
        
        
        
        __block BOOL isFoundCartVC = NO;
        [self.navigationController.viewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:MyShoppingCartVC.class]) {
                *stop = YES;
                isFoundCartVC = YES;
            }
        }];
        
        CGFloat bottomLabelHeight = 40.0f;
        CGRect bottomLabelRect = CGRectMake(0.0f, CGRectGetHeight(self.contentView.frame)-bottomLabelHeight,
                                            CGRectGetWidth(self.contentView.frame), bottomLabelHeight);
        self.buttomContainerView = [[UIView alloc] initWithFrame:bottomLabelRect];
        _buttomContainerView.clipsToBounds = YES;
        _buttomContainerView.backgroundColor = [UIColor colorWithRed:0.227f green:0.227f blue:0.227f alpha:1.00f];
        [self.contentView addSubview:_buttomContainerView];
        
        
        if (!(isFoundCartVC&&_wasGPSDevice)) {
            self.addCartButton = [UIButton buttonWithType:UIButtonTypeSystem];
            [_addCartButton setFrame:CGRectMake(CGRectGetWidth(_buttomContainerView.frame)*0.6, 0.0f,
                                                CGRectGetWidth(_buttomContainerView.frame)*0.4, CGRectGetHeight(bottomLabelRect))];
            _addCartButton.backgroundColor = UIColor.redColor;
            [_addCartButton setTitle:getLocalizationString(_wasGPSDevice?@"apply_gps":@"add_cart") forState:UIControlStateNormal];
            [_addCartButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_addCartButton addTarget:self action:(_wasGPSDevice?@selector(pushToGPSAppointmentVC):@selector(addPartsToCart)) forControlEvents:UIControlEventTouchUpInside];
            [_buttomContainerView addSubview:_addCartButton];
        }
        
        UIImage *image = [ImageHandler getImageFromCacheWithByFixdeRatioFileRootPath:kSysImageCaches
                                                                            fileName:@"favorite"
                                                                                type:FMImageTypeOfPNG
                                                                         needToUpdate:YES];
        
        CGFloat width = (isFoundCartVC&&_wasGPSDevice)?CGRectGetWidth(_buttomContainerView.frame):CGRectGetMinX(_addCartButton.frame);
        self.addFavorite = [UIButton buttonWithType:UIButtonTypeCustom];
        _addFavorite.tintColor = CDZColorOfClearColor;
        _addFavorite.frame = CGRectMake(width-bottomLabelHeight, 0.0f, bottomLabelHeight, bottomLabelHeight);
        [_addFavorite setImage:image forState:UIControlStateNormal];
        [_addFavorite setImage:[ImageHandler ipMaskedImage:image color:CDZColorOfYellow] forState:UIControlStateSelected];
        [_addFavorite addTarget:self action:@selector(changeFavorite) forControlEvents:UIControlEventTouchUpInside];
        [_buttomContainerView addSubview:_addFavorite];
        
        if (!isFoundCartVC) {
            UIImage *cartImage = [ImageHandler getImageFromCacheWithByFixdeRatioFileRootPath:kSysImageCaches
                                                                                    fileName:@"cart"
                                                                                        type:FMImageTypeOfPNG
                                                                                needToUpdate:YES];
            
            self.cartButton = [UIButton buttonWithType:UIButtonTypeCustom];
            _cartButton.hidden = _wasGPSDevice;
            _cartButton.tintColor = CDZColorOfClearColor;
            _cartButton.frame = CGRectMake(0.0f, 0.0f, bottomLabelHeight, bottomLabelHeight);
            [_cartButton setImage:cartImage forState:UIControlStateNormal];
            [_cartButton addTarget:self action:@selector(pushToCartView) forControlEvents:UIControlEventTouchUpInside];
            [_buttomContainerView addSubview:_cartButton];
        }
        

        
        
        
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        self.scrollView.hidden = NO;
        self.scrollView.frame = CGRectMake(0.0f, 0.0f,
                                           CGRectGetWidth(self.contentView.bounds),
                                           CGRectGetHeight(self.contentView.bounds)-CGRectGetHeight(_buttomContainerView.frame));
        self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.frame), CGRectGetHeight(self.scrollView.frame)*2.0f);
        self.scrollView.bounces = NO;
        self.scrollView.backgroundColor = CDZColorOfWhite;
        
        CGFloat imgWidth = 200;
        self.itemImageView = [[UIImageView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.contentView.frame)-imgWidth)/2.0f, 0.0f, imgWidth, imgWidth)];
        [self.scrollView addSubview:_itemImageView];
        NSString *imageURL = _itemDetail[@"img"];
        if ([imageURL isEqualToString:@""]||!imageURL||[imageURL rangeOfString:@"http"].location==NSNotFound) {
            _itemImageView.image = [ImageHandler getWhiteLogo];
        }else {
            [_itemImageView sd_setImageWithURL:[NSURL URLWithString:imageURL] placeholderImage:[ImageHandler getWhiteLogo]];
        }
        
//        NSString *modelName = [_autoData.seriesName stringByAppendingFormat:@" %@",_autoData.modelName];
//        CGRect itemSuitableRect = CGRectZero;
//        itemSuitableRect.origin.x = vStartSpace;
//        itemSuitableRect.origin.y = CGRectGetMaxY(_itemImageView.frame);//+(22.0f);
//        itemSuitableRect.size.width = CGRectGetWidth(self.contentView.frame)-vStartSpace*2.0f;
//        itemSuitableRect.size.height = (57.0f);
//        
//        
//        
//        __block NSString *itemSuitForTitle = getLocalizationString(@"item_non_suitable_for");
//        NSString *modelID = [_autoData.modelID stringValue];
//        if (!modelID) {
//            modelID = @"";
//        }
//        NSArray *array = _itemDetail[@"speci_speci_name"];
//        [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//            NSDictionary *detail = (NSDictionary *)obj;
//            if ([detail[@"speci_str"] isEqualToString:modelID]||[detail[@"speci_str"] isEqualToString:@"适用所有车型id"]) {
//                itemSuitForTitle = getLocalizationString(@"item_suitable_for");
//                if ([modelID isEqualToString:@""]) itemSuitForTitle = [itemSuitForTitle stringByAppendingString:@"适用所有车型"];
//                *stop = YES;
//            }
//        }];
        
//        self.itemForAutoLabel = [[InsetsLabel alloc] initWithFrame:itemSuitableRect];
//        [_itemForAutoLabel setBackgroundColor:[UIColor colorWithRed:1.000f green:0.992f blue:0.996f alpha:1.00f]];
//        [_itemForAutoLabel setBorderWithColor:[UIColor colorWithRed:0.847f green:0.843f blue:0.835f alpha:1.00f] borderWidth:(1.0f)];
//        [_itemForAutoLabel setTextAlignment:NSTextAlignmentCenter];
//        [_itemForAutoLabel setFont:[UIFont systemFontOfSize:(14.0f)]];
//        [_itemForAutoLabel setNumberOfLines:2];
//        _itemForAutoLabel.text = [itemSuitForTitle stringByAppendingString:modelName];
//        [self.scrollView addSubview:_itemForAutoLabel];
        
        CGRect infoRect = self.scrollView.bounds;
        infoRect.origin.y = CGRectGetMaxY(_itemImageView.frame)+(12.0f);
        self.infoView = [[PartsInfoView alloc] initWithFrame:infoRect];
        [_infoView updateUIDataWithDetailData:_itemDetail];
        [_infoView setShowCommnetViewTarget:self action:@selector(pushToCommentView)];
        [self.scrollView addSubview:_infoView];
        
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        [self.scrollView setContentSize:CGSizeMake(CGRectGetWidth(self.scrollView.frame), CGRectGetMaxY(_infoView.frame)+(30.0f))];
    }
    
}

- (void)pushToGPSAppointmentVC {
    @autoreleasepool {
        GPSApplicationFormVC *vc = GPSApplicationFormVC.new;
//        self set
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)pushToCartView {
    @autoreleasepool {
        MyShoppingCartVC *vc = [MyShoppingCartVC new];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)pushToCommentView {
    NSUInteger commentCount = [SupportingClass verifyAndConvertDataToString:_itemDetail[@"all"]].integerValue;
    if (commentCount==0) {
        [SupportingClass showAlertViewWithTitle:@"alert_remind" message:@"没有更多的评论" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:nil];
        return;
    }
    NSString *partsID = [SupportingClass verifyAndConvertDataToString:_itemDetail[@"id"]];
    if (!partsID) return;
        NSLog(@"%@ accessing network change parts favorite request",NSStringFromClass(self.class));
    
    PartsCommentVC *vc = [PartsCommentVC new];
    vc.partsID = partsID;
    [self setDefaultNavBackButtonWithoutTitle];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)getCollectedStoreListWithpageNums:(NSString *)pageNums pageSizes:(NSString *)pageSizes {
    
    if (!self.accessToken) {
//        [self handleMissingTokenAction];
        return;
    }
    @autoreleasepool {
        
        NSArray* array = self.navigationController.viewControllers;
        if (![array[array.count-2] isKindOfClass:FindAccessoriesVC.class]&&[array.lastObject isKindOfClass:self.class]) {
            [ProgressHUDHandler showHUD];
        }
    }
    [self setReloadFuncWithAction:_cmd parametersList:@[pageNums, pageSizes]];
    @weakify(self);
    NSLog(@"%@ accessing network product list request",NSStringFromClass(self.class));
    NSString *theID = _itemDetail[@"id"];
    [[APIsConnection shareConnection] personalCenterAPIsGetProductiWasCollectedWithAccessToken:self.accessToken collectionID:theID
    success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
//        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        [ProgressHUDHandler dismissHUD];
        if (errorCode==0) {
            BOOL isAdd = [responseObject[@"state_name"] boolValue];
            self.addFavorite.selected = !isAdd;
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

- (void)changeFavorite {
    
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    [ProgressHUDHandler showHUD];
    @weakify(self);
    NSLog(@"%@ accessing network change parts favorite request",NSStringFromClass(self.class));
    NSString *theID = _itemDetail[@"number"];
    [[APIsConnection shareConnection] personalCenterAPIsPostInsertProductCollectionWithAccessToken:self.accessToken productIDList:@[theID] success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
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
            
        }];
        self.addFavorite.selected = YES;
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

//    if (_addFavorite.selected) {
//        [[APIsConnection shareConnection] personalCenterAPIsPostDeleteProductsCollectionWithAccessToken:self.accessToken collectionIDList:@[theID] success:^(NSURLSessionDataTask *operation, id responseObject) {
//            @strongify(self);
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
//            @strongify(self);
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

- (void)addPartsToCart {
    
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
    NSLog(@"%@ accessing network add parts to cart request",NSStringFromClass(self.class));
    [[APIsConnection shareConnection] personalCenterAPIsPostInsertProductToTheCartWithAccessToken:self.accessToken
                                                                                        productID:theID
                                                                                          brandID:brandID
                                                                                brandDealershipID:brandDealershipID
                                                                                         seriesID:seriesID
                                                                                          modelID:modelID
    success:^(NSURLSessionDataTask *operation, id responseObject) {
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
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        [ProgressHUDHandler dismissHUD];
        [SupportingClass showAlertViewWithTitle:@"error" message:@"连接逾时！请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            
        }];
    }];
    
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

- (void)handleUserLoginResult:(BOOL)isSuccess fromAlert:(BOOL)fromAlert{
    if (isSuccess) {
        NSLog(@"success reload function %d", [self executeReloadFunction]);
    }else {
//        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

@end
