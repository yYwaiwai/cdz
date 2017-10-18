//
//  SNSDCouponView.m
//  cdzer
//
//  Created by KEns0nLau on 8/29/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "SNSDCouponView.h"
#import "SNSDCouponViewCell.h"
#import "XIBBaseViewController.h"

@interface SNSDCouponView() <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSLayoutConstraint *heightConstraint;

@end

@implementation SNSDCouponView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [self registerNib:[UINib nibWithNibName:@"SNSDCouponViewCell" bundle:nil] forCellWithReuseIdentifier:CDZKeyOfCellIdentKey];
    self.delegate = self;
    self.dataSource = self;
    self.bounces = NO;
    self.backgroundColor = [UIColor whiteColor];
    
    @weakify(self);
    [self.constraints enumerateObjectsUsingBlock:^(__kindof NSLayoutConstraint * _Nonnull constraints, NSUInteger idx, BOOL * _Nonnull stop) {
        @strongify(self);
        if (constraints.firstAttribute==NSLayoutAttributeHeight) {
            self.heightConstraint = constraints;
        }
    }];
    self.couponList = @[];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
}

- (void)setCouponList:(NSArray *)couponList {
    if (!couponList) couponList = @[];
    _couponList = couponList;
    [self reloadData];
    BOOL zeroCount = (couponList.count==0);
    self.heightConstraint.constant = zeroCount?0:100;
    self.hidden = zeroCount;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.couponList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SNSDCouponViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CDZKeyOfCellIdentKey forIndexPath:indexPath];
    
    NSDictionary *detail = self.couponList[indexPath.item];
    [cell updateUIData:detail];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *receicedSign = [self.couponList[indexPath.item] objectForKey:@"is_receive"];
    if (![receicedSign isEqualToString:@"yes"]) {
        [self collectCoupon:indexPath];
    }
}

- (void)collectCoupon:(NSIndexPath *)indexPath {
    @autoreleasepool {
        if (!vGetUserToken) {
            UIViewController *nav = UIApplication.sharedApplication.keyWindow.rootViewController;
            if ([nav isKindOfClass:BaseNavigationController.class]) {
                UIViewController *vc = [(BaseNavigationController *)nav visibleViewController];
                if ([vc respondsToSelector:@selector(handleMissingTokenAction)]) {
                    [(XIBBaseViewController *)vc handleMissingTokenAction];
                }
            }
            return;
        }
        NSDictionary *couponDetail = self.couponList[indexPath.row];
        NSString *couponID = [SupportingClass verifyAndConvertDataToString:couponDetail[@"id"]];
        
        if (!vGetUserToken||!couponID||[couponID isEqualToString:@""])return;
        [ProgressHUDHandler showHUD];
        @weakify(self);
        [APIsConnection.shareConnection maintenanceShopsAPIsPostUserCollectMaintenanceShopCouponWithAccessToken:vGetUserToken couponID:couponID success:^(NSURLSessionDataTask *operation, id responseObject) {
            NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
            NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
            NSLog(@"%@",message);
            @strongify(self);
            
            if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
                return;
            }
            [ProgressHUDHandler dismissHUD];
            
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                if(errorCode==0){
                    @strongify(self);
                    if (self.reloadBlock) {
                        self.reloadBlock();
                    }
                }
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
}

@end
