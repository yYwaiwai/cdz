//
//  SupportingClass.h
//  cdzer
//
//  Created by KEns0n on 2/7/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

typedef NS_ENUM(NSInteger, HelveticaNeueFontType)
{
    HelveticaNeueFontTypeOfBoldItalic = 0,
    HelveticaNeueFontTypeOfLight,
    HelveticaNeueFontTypeOfItalic,
    HelveticaNeueFontTypeOfUltraLightItalic,
    HelveticaNeueFontTypeOfCondensedBold,
    HelveticaNeueFontTypeOfMediumItalic,
    HelveticaNeueFontTypeOfThin,
    HelveticaNeueFontTypeOfMedium,
    HelveticaNeueFontTypeOfThinItalic,
    HelveticaNeueFontTypeOfLightItalic,
    HelveticaNeueFontTypeOfUltraLight,
    HelveticaNeueFontTypeOfBold,
    HelveticaNeueFontTypeOfRegular,
    HelveticaNeueFontTypeOfCondensedBlack
    
};

typedef void (^ULHAutosBrandListResultBlock)(NSArray *resultList, NSError *error);

#define kMenuShowListKey @"MenuShowListKey"
/* Quick Support Code Section */
#define fIntegerToNumber(integer) [NSNumber numberWithInteger:(long)integer]

#import <Foundation/Foundation.h>
@interface SupportingClass : NSObject

+ (BOOL)isOS7Plus;

+ (BOOL)isOS8Plus;

+ (BOOL)isTwiceSizeRetinaScreen;

+ (BOOL)isTripleSizeRetinaScreen;

+ (id)deepMutableObject:(id)object;

+ (float)roundToLastTwoFloatValue:(float)value;
/*
 * 显示用户信息提示框
 */
+ (void)showToast:(NSString *)msg;

+ (void)makeACall:(NSString *)number andContents:(NSString *)contents withTitle:(NSString *)title;

+ (void)makeACall:(NSString *)number;

+ (NSString *)removeHTML:(NSString *)html;

#pragma mark - 分析状态返回yes/no，看是否继续执行下去
+ (BOOL)analyseCarStatus:(NSString*)status withParentView:(UIView *)parentView;

+ (UIFont *)getHelveticaNeueFontType:(HelveticaNeueFontType)fontType withFontSize:(CGFloat)fontSize isAdjustByRatio:(BOOL)isNeedAdjust;

+ (CGFloat)getKeyboardHeight;

+ (UIFont *)boldAndSizeFont:(int) sizeValue;

+ (NSString *)getLocalizationString:(NSString *)localizationKey;

+ (NSString *)getEDRLocalizationString:(NSString *)localizationKey;

+ (NSString *)verifyAndConvertDataToString:(id)data;

+ (NSNumber *)verifyAndConvertDataToNumber:(id)data;

+ (NSString *)chineseStringConvertToPinYinStringWithString:(NSString *)words;

+ (CGSize)getStringSizeWithString:(NSString *)string font:(UIFont *)font widthOfView:(CGSize)size;

+ (CGSize)getStringSizeWithString:(NSString *)string font:(UIFont *)font widthOfView:(CGSize)size withEdgeInset:(UIEdgeInsets)edgeInsetsValue;

+ (CGSize)getAttributedStringSizeWithString:(NSAttributedString *)string widthOfView:(CGSize)size;

+ (CGSize)getAttributedStringSizeWithString:(NSAttributedString *)string widthOfView:(CGSize)size withEdgeInset:(UIEdgeInsets)edgeInsetsValue;

+ (UIAlertView *)showAlertViewWithTitle:(NSString *)title
                                message:(NSString *)message
                        isShowImmediate:(BOOL)isShowImmediate
                      cancelButtonTitle:(NSString *)cancelButtonTitle
                      otherButtonTitles:(id)otherButtonTitles
          clickedButtonAtIndexWithBlock:(void (^)(NSNumber *btnIdx, UIAlertView *alertView))clickedButtonBlock;

+ (void)addLabelWithFrame:(CGRect)frame content:(NSString*)text radius:(CGFloat)radius fontSize:(CGFloat)size  parentView:(UIView *)parentView isAlertShow:(BOOL)isAlertShow pushBlock:(void (^)(void))pushBlock;

+ (void)getAutosBrandList:(ULHAutosBrandListResultBlock)resultBlock;
@end
