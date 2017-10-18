//
//  LicensePlateSelectionView.h
//  cdzer
//
//  Created by KEns0n on 07/12/2016.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LicensePlateSelectionView : UIView

//车牌首两位代码信息
@property (nonatomic, readonly) NSString *combineString;
//车牌省代码信息
@property (nonatomic, readonly) NSString *lpProvinceString;
//车牌城市代码信息
@property (nonatomic, readonly) NSString *lpCityCodeString;

//配置字体颜色
- (void)setTitleColor:(UIColor *)titleColor;

//设置默认车牌信息
- (void)initializeSettingFromLicensePlate:(NSString *)licensePlate;

@end
