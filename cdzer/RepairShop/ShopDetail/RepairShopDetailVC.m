//
//  RepairShopDetailVC.m
//  cdzer
//
//  Created by KEns0n on 3/11/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#import "RepairShopDetailVC.h"
#import "AdvertisingScrollView.h"
#import "ShopInfoDetail.h"
#import "ServiceSelectionView.h"
#import "CommentMiniView.h"
#import "EngineerListVC.h"
#import "CommentListVC.h"
#import "ShopAppointmentVC.h"
#import "UserSelectedAutosInfoDTO.h"
#import "ExternalShopDetailView.h"
#import "ShopCouponListVC.h"
#import "RepairShopMembershipTnCVC.h"
#import "MyCarVC.h"


@interface CouponSelectedView : UITableViewCell
@property (nonatomic, strong) UIButton *button;
@end

@implementation CouponSelectedView
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.imageView.image = [ImageHandler getImageFromCacheByScreenRatioWithFileRootPath:kSysImageCaches fileName:@"coupon_icon" type:FMImageTypeOfPNG scaleWithPhone4:NO offsetRatioForP4:1.0f needToUpdate:YES];
        self.textLabel.text = @"点击领取优惠劵";
        self.accessoryView = [[UIImageView alloc] initWithImage:ImageHandler.getRightArrow];
        self.button = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:self.button];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect imgViewFrame = self.imageView.frame;
    imgViewFrame.origin.x = 15.0f;
    self.imageView.frame = imgViewFrame;
    
    self.button.frame = self.bounds;
    CGPoint center = self.accessoryView.center;
    center.x = CGRectGetWidth(self.frame)-CGRectGetWidth(self.accessoryView.frame)/2.0f-15.0f;
    self.accessoryView.center = center;
}

@end

@interface RepairShopDetailVC () <UIScrollViewDelegate>

@property (nonatomic, strong) AdvertisingScrollView *advertSrollView;

@property (nonatomic, strong) ShopInfoDetail *infoDetail;

@property (nonatomic, strong) ServiceSelectionView *serviceSelectionView;

@property (nonatomic, strong) CommentMiniView *extFacilitiesView;

@property (nonatomic, strong) UIButton *appointmentBtn;

@property (nonatomic, strong) UIButton *addFavorite;

@property (nonatomic, strong) UIButton *engineerBtn;

@property (nonatomic, strong) ExternalShopDetailView *externalShopDetailView;

@property (nonatomic, strong) CouponSelectedView *couponView;


@end

@implementation RepairShopDetailVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:getLocalizationString(@"store_detail")];
    [self.contentView setBackgroundColor:sCommonBGColor];
    [self componentSetting];
    [self initializationUI];
    [self setReactiveRules];
    self.loginAfterShouldPopToRoot = NO;
}

- (void)handleUserLoginResult:(BOOL)isSuccess fromAlert:(BOOL)fromAlert{
    if (isSuccess) {
        NSLog(@"success reload function %d", [self executeReloadFunction]);
    }else {
        //        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)componentSetting {
    [self setRightNavButtonWithTitleOrImage:@"加入会员"
                                      style:UIBarButtonItemStyleDone target:self action:@selector(showTNCVC) titleColor:nil isNeedToSet:YES];
}

- (void)showTNCVC {
    if (!self.accessToken) {
        [SupportingClass showAlertViewWithTitle:nil message:@"加入前请先登录" isShowImmediate:YES cancelButtonTitle:@"cancel" otherButtonTitles:@"ok" clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            if (btnIdx.integerValue>0) {
                [self presentLoginViewWithBackTitle:nil animated:YES completion:^{
                    
                }];
            }
        }];
        return;
    }
    @autoreleasepool {
        RepairShopMembershipTnCVC *vc = [RepairShopMembershipTnCVC new];
        NSString *urlString = [kTNCURLPrefix stringByAppendingString:@"add_merber.html"];
        vc.url = [NSURL URLWithString:urlString];
        vc.shopID = _detailData[@"id"];
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)setReactiveRules {
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getCollectedShopListWithpageNums:nil pageSizes:nil];
}

- (UIButton *)singleSelectViewWithtitle:(NSString *)text titleColor:(UIColor *)color frame:(CGRect)frame{
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    UIView *view = [[UIView alloc] initWithFrame:frame];
    [view setBackgroundColor:CDZColorOfWhite];
    [view setBorderWithColor:[UIColor lightGrayColor] borderWidth:(0.5f)];
    [self.scrollView addSubview:view];
    
    CGFloat width = 12.0f*vWidthRatio;
    UIImageView *arrowIV= [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(view.frame)-width-14.0f,
                                                                        (CGRectGetHeight(view.frame)-width)/2.0f,
                                                                        width,
                                                                        width)];
    arrowIV.image = ImageHandler.getRightArrow;
    [view addSubview:arrowIV];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [button setFrame:view.bounds];
    [button setBackgroundColor:[UIColor clearColor]];
    [button setTitle:text forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont systemFontOfSize:15.0f]];
    [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [button setTitleEdgeInsets:UIEdgeInsetsMake(0.0f, 14.0f, 0.0f, 0.0f)];
    [button setTitleColor:color forState:UIControlStateNormal];
    [view addSubview:button];
    
    return button;
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
}

- (void)popToCouponCollectView {
    @autoreleasepool {
        if (!self.accessToken) {
            [self presentLoginViewWithBackTitle:nil animated:YES completion:nil];
            return;
        }
        ShopCouponListVC *vc = ShopCouponListVC.new;
        vc.shopID = _detailData[@"id"];
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)initializationUI {
    self.scrollView.hidden = NO;
    self.scrollView.backgroundColor = sCommonBGColor;
    self.scrollView.delegate = self;
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.frame), CGRectGetHeight(self.scrollView.frame)*2.0f);
    [self setAdvertSrollView:[[AdvertisingScrollView alloc] initWithMinFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.contentView.frame), 140.0f)]];
    [_advertSrollView setupDataSourcesArray:_detailData[@"user_bannerimg"]];
    [self.scrollView addSubview:_advertSrollView];
    
    [self setInfoDetail:[[ShopInfoDetail alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(_advertSrollView.frame), CGRectGetWidth(self.contentView.frame), 180.0f)]];
    [_infoDetail initializationUIWithDetailData:_detailData];
    [self.scrollView addSubview:_infoDetail];
    
    NSNumber *couponExist = [SupportingClass verifyAndConvertDataToNumber:_detailData[@"prefer_num"]];
    if (couponExist.boolValue) {
        self.couponView = [[CouponSelectedView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        _couponView.backgroundColor = CDZColorOfWhite;
        _couponView.frame = CGRectMake(0.0f, CGRectGetMaxY(_infoDetail.frame)+vO2OSpaceSpace, CGRectGetWidth(self.scrollView.frame), 44.0f);
        [_couponView setViewBorderWithRectBorder:UIRectBorderTop|UIRectBorderBottom borderSize:0.5f withColor:UIColor.grayColor withBroderOffset:nil];
        [_couponView.button addTarget:self action:@selector(popToCouponCollectView) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:_couponView];
    }
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    CGFloat externalShopDetailY = CGRectGetMaxY(_infoDetail.frame)+vO2OSpaceSpace;
    if (self.couponView) {
        externalShopDetailY = CGRectGetMaxY(_couponView.frame)+vO2OSpaceSpace;
    }
    
    self.externalShopDetailView = [[ExternalShopDetailView alloc] initWithFrame:CGRectMake(0.0f, externalShopDetailY, SCREEN_WIDTH, 32.0f)];
    [_externalShopDetailView initializationUIWithShopDetail:_detailData];
    [self.scrollView addSubview:_externalShopDetailView];
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    //    [self setServiceSelectionView:[[ServiceSelectionView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(_selectCar.superview.frame)+vO2OSpaceSpace, SCREEN_WIDTH, 45.0f)]];
    //    [_serviceSelectionView initializationUI];
    //    [self.scrollView addSubview:_serviceSelectionView];
    
    
    [self setExtFacilitiesView:[[CommentMiniView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(_externalShopDetailView.frame)+vO2OSpaceSpace, SCREEN_WIDTH, 32.0f)]];
    [_extFacilitiesView initializationUI];
    [_extFacilitiesView setNumberOfComment:_detailData[@"comment_size"] withRatingValue:_detailData[@"star"]];
    if ([SupportingClass verifyAndConvertDataToNumber:_detailData[@"comment_size"]].unsignedIntegerValue>0) {
        [_extFacilitiesView addTarget:self action:@selector(pushCommentListVC) forControlEvents:UIControlEventTouchUpInside];
    }
    [self.scrollView addSubview:_extFacilitiesView];
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    [self setEngineerBtn:[self singleSelectViewWithtitle:@"技师中心"
                                              titleColor:[UIColor colorWithRed:0.180f green:0.180f blue:0.180f alpha:1.00f]
                                                   frame:CGRectMake(0.0f,
                                                                    CGRectGetMaxY(_extFacilitiesView.frame)+vO2OSpaceSpace,
                                                                    SCREEN_WIDTH,
                                                                    32.0f)]];
    [_engineerBtn addTarget:self action:@selector(pushEngineerListVC) forControlEvents:UIControlEventTouchUpInside];
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    
    CGFloat btnHeight = 60.0f;
    UIImage *image = [ImageHandler getImageFromCacheWithByFixdeRatioFileRootPath:kSysImageCaches
                                                                        fileName:@"favorite"
                                                                            type:FMImageTypeOfPNG
                                                                    needToUpdate:YES];
    self.addFavorite = [UIButton buttonWithType:UIButtonTypeCustom];
    _addFavorite.tintColor = CDZColorOfClearColor;
    _addFavorite.frame = CGRectMake(0.0f, CGRectGetHeight(self.contentView.frame)-btnHeight, btnHeight, btnHeight);
    _addFavorite.backgroundColor = CDZColorOfDeepGray;
    [_addFavorite setImage:image forState:UIControlStateNormal];
    [_addFavorite setImage:[ImageHandler ipMaskedImage:image color:CDZColorOfYellow] forState:UIControlStateSelected];
    [_addFavorite addTarget:self action:@selector(changeFavorite) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_addFavorite];
    
    [self setAppointmentBtn:[UIButton buttonWithType:UIButtonTypeSystem]];
    [_appointmentBtn setBorderWithColor:[UIColor colorWithRed:0.212f green:0.212f blue:0.212f alpha:1.00f] borderWidth:(12.0f)];
    [_appointmentBtn setTitle:getLocalizationString(@"appointment_now") forState:UIControlStateNormal];
    [_appointmentBtn setBackgroundColor:CDZColorOfDefaultColor];
    [_appointmentBtn setTitleColor:CDZColorOfWhite forState:UIControlStateNormal];
    [_appointmentBtn setFrame:CGRectMake(btnHeight, CGRectGetHeight(self.contentView.frame)-btnHeight, SCREEN_WIDTH-btnHeight, btnHeight)];
    [_appointmentBtn addTarget:self action:@selector(showAppointmentView) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_appointmentBtn];
    
    
    CGFloat totalHeight = CGRectGetHeight(_appointmentBtn.frame)+CGRectGetMaxY(_engineerBtn.superview.frame)+vO2OSpaceSpace;
    [self.scrollView setContentSize:CGSizeMake(CGRectGetWidth(self.scrollView.frame), totalHeight)];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat baseLine = scrollView.contentSize.height-CGRectGetHeight(scrollView.frame);
    [scrollView setBounces:(scrollView.contentOffset.y >= baseLine*0.45f)];
}

- (void)pushCommentListVC {
    @autoreleasepool {
        CommentListVC * commentListVC = [[CommentListVC alloc] init];
        commentListVC.shopID = _detailData[@"id"];
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:commentListVC animated:YES];
    }
}

- (void)pushEngineerListVC {
    @autoreleasepool {
        EngineerListVC * engineerListVC = [[EngineerListVC alloc] init];
        engineerListVC.shopID = _detailData[@"id"];
        //#warning data is Fixed Plx~~~
        //        engineerListVC.shopID = @"15033111512569858399";
        //#warning data is Fixed Plx~~~
        engineerListVC.isForSelection = NO;
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:engineerListVC animated:YES];
    }
}

- (void)showAppointmentView {
    if (!self.accessToken) {
        [SupportingClass showAlertViewWithTitle:nil message:@"预约前请先登录" isShowImmediate:YES cancelButtonTitle:@"cancel" otherButtonTitles:@"ok" clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            if (btnIdx.integerValue>0) {
                [self presentLoginViewWithBackTitle:nil animated:YES completion:^{
                    
                }];
            }
        }];
        return;
    }
    
    UserAutosInfoDTO *dto = [DBHandler.shareInstance getUserAutosDetail];
    if ([dto.brandID isEqualToString:@""]||[dto.brandName isEqualToString:@""]||
        [dto.dealershipID isEqualToString:@""]||[dto.dealershipName isEqualToString:@""]||
        [dto.seriesID isEqualToString:@""]||[dto.seriesName isEqualToString:@""]||
        [dto.modelID isEqualToString:@""]||[dto.modelName isEqualToString:@""]) {
        [SupportingClass showAlertViewWithTitle:nil message:@"预约前请先完善个人车辆信息，现在去完善吗？" isShowImmediate:YES cancelButtonTitle:@"cancel" otherButtonTitles:@"ok" clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            if (btnIdx.integerValue>0) {
                [self pushToUserAutosInfoVC];
            }
        }];
        return;
    }
    
    @autoreleasepool {
        ShopAppointmentVC *vc = [ShopAppointmentVC new];
        vc.diagnosisResultReason = self.diagnosisResultReason;
        vc.dataDetail= _detailData;
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)pushToUserAutosInfoVC {
    @autoreleasepool {
        MyCarVC *vc = [MyCarVC new];
        vc.wasBackRootView = NO;
        vc.wasSubmitAfterLeave = YES;
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)pushAutoSelectVC {
    [self pushToAutosSelectionViewWithBackTitle:nil animated:YES onlyForSelection:NO andSelectionResultBlock:nil];
    
}

- (void)getCollectedShopListWithpageNums:(NSNumber *)pageNums pageSizes:(NSNumber *)pageSizes {
    
    if (!self.accessToken) {
        //        [self handleMissingTokenAction];
        return;
    }
    @weakify(self);
    NSLog(@"%@ accessing network product list request",NSStringFromClass(self.class));
    [self setReloadFuncWithAction:_cmd parametersList:nil];
    [[APIsConnection shareConnection] personalCenterAPIsGetShopsCollectionListWithAccessToken:self.accessToken pageNums:pageNums pageSizes:pageSizes coordinate:CLLocationCoordinate2DMake(0, 0) success:^(NSURLSessionDataTask *operation, id responseObject) {
        [ProgressHUDHandler dismissHUD];
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        @strongify(self);
        NSArray *partList = [responseObject[CDZKeyOfResultKey] valueForKey:@"shop_id"];
        NSString *partsID = ([self.detailData[@"id"] isKindOfClass:NSNumber.class])?[self.detailData[@"id"] stringValue]:self.detailData[@"id"];
        partsID = [partsID stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        [partList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *tmpPartsID = ([obj isKindOfClass:NSNumber.class])?[obj stringValue]:obj;
            tmpPartsID = [tmpPartsID stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if ([tmpPartsID isEqualToString:partsID]) {
                *stop = YES;
                self.addFavorite.selected = YES;
            }
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

- (void)changeFavorite {
    
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    [ProgressHUDHandler showHUD];
    @weakify(self);
    NSLog(@"%@ accessing network change parts favorite request",NSStringFromClass(self.class));
    NSString *theID = _detailData[@"id"];
    
    [[APIsConnection shareConnection] personalCenterAPIsPostInsertShopCollectionWithAccessToken:self.accessToken shopIDList:@[theID] success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        [ProgressHUDHandler dismissHUD];
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
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
    //
    //    if (_addFavorite.selected) {
    //        [[APIsConnection shareConnection] personalCenterAPIsPostDeleteShopCollectionWithAccessToken:self.accessToken collectionIDList:@[theID] success:^(NSURLSessionDataTask *operation, id responseObject) {
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
    //        [[APIsConnection shareConnection] personalCenterAPIsPostInsertShopCollectionWithAccessToken:self.accessToken shopIDList:@[theID] success:^(NSURLSessionDataTask *operation, id responseObject) {
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

@end
