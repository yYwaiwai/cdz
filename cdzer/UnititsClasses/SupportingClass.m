//
//  SupportingClass.m
//  cdzer
//
//  Created by KEns0n on 2/7/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//
#define k_car_staOn @"0"    //在线
#define k_car_staOff @"1"   //熄火
#define k_car_staOver @"2"  //离线
#define k_car_staNo @"3"    //无信号
#import <ReactiveObjC/ReactiveObjC.h>
#import <PinYin4Objc/PinYin4Objc.h>
#import "SupportingClass.h"
#import "InsetsLabel.h"
@implementation SupportingClass
static NSArray * menuConfigList;
static NSArray * brandConfigList;

+ (void)showToast:(NSString *)msg  {
    @autoreleasepool {
        CGFloat width = SCREEN_WIDTH-10;
        UIFont *font = [self boldAndSizeFont:15];
        CGFloat height = [self getStringSizeWithString:msg font:font widthOfView:CGSizeMake(width, MAXFLOAT) withEdgeInset:DefaultEdgeInsets].height+15.0f;
        InsetsLabel *msgLa = [[InsetsLabel alloc] initWithFrame:CGRectMake(0, 0, width, height)
                                             andEdgeInsetsValue:DefaultEdgeInsets];
        msgLa.text = msg ;
        msgLa.textAlignment = NSTextAlignmentCenter ;
        msgLa.font = font;
        msgLa.numberOfLines = 0;
        msgLa.backgroundColor = CDZColorOfBlack;
        msgLa.textColor = CDZColorOfWhite;
        msgLa.center = CGPointMake(SCREEN_WIDTH/2.0f, SCREEN_HEIGHT*0.75f);
        [msgLa setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:5.0f];
        [UIApplication.sharedApplication.keyWindow addSubview:msgLa];
        [UIView animateWithDuration:0.8 delay:3 options:UIViewAnimationOptionCurveEaseOut animations:^(void)
         {
             [msgLa setAlpha:0.0];
         }completion:^(BOOL finished)
         {
             [msgLa removeFromSuperview];
         }];

    }
}

+ (NSString *)getLocalizationString:(NSString *)localizationKey{
    if (!localizationKey||[localizationKey isEqualToString:@""]) {
        return @"Untitled";
    }
    return NSLocalizedStringFromTable(localizationKey, @"Localization", nil);
}

+ (NSString *)getEDRLocalizationString:(NSString *)localizationKey{
    if (!localizationKey||[localizationKey isEqualToString:@""]) {
        return @"Untitled";
    }
    return NSLocalizedStringFromTable(localizationKey, @"EDR_Localization", nil);
}

+ (BOOL)isOS7Plus {
    if ([UIDevice currentDevice].systemVersion.floatValue >= 7.00000) {
        return YES;
    }
    return NO;
}
//
+ (BOOL)isOS8Plus {
    if ([UIDevice currentDevice].systemVersion.floatValue >= 8.10000) {
        return YES;
    }
    return NO;
}

+ (CGFloat)getKeyboardHeight {
    CGFloat height = 253.0f;
    if (IS_IPHONE_6P) height = 271.0f;
    if (IS_IPHONE_6) height = 258.0f;
    return height;
}

+ (BOOL)isTripleSizeRetinaScreen {
    return ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
            ([UIScreen mainScreen].scale >= 3.0));
}

+ (BOOL)isTwiceSizeRetinaScreen {
    return ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
            ([UIScreen mainScreen].scale >= 2.0));
}

+ (id)deepMutableObject:(id)object {
    if ([object isKindOfClass:NSArray.class]||[object isKindOfClass:NSDictionary.class]) {
        BOOL isArray = [object isKindOfClass:NSArray.class];
        return  isArray?(NSMutableArray *)CFBridgingRelease(CFPropertyListCreateDeepCopy(kCFAllocatorDefault,
                                                                                         (CFArrayRef)object,
                                                                                         kCFPropertyListMutableContainersAndLeaves))
                       :(NSMutableDictionary *)CFBridgingRelease(CFPropertyListCreateDeepCopy(kCFAllocatorDefault,
                                                                                              (CFDictionaryRef)object,
                                                                                              kCFPropertyListMutableContainersAndLeaves));
    }
    return nil;
}

+ (BOOL)analyseCarStatus:(NSString*)status withParentView:(UIView *)parentView {
    BOOL flag = NO;
    if ([k_car_staOn isEqualToString:status] || [k_car_staOff isEqualToString:status]) {
        flag = YES;
    }else{
        NSString *text = @"离线";
        if ([k_car_staNo isEqualToString:status]) {
            text = @"无信号";
        }
        CGRect frame = alertFrame;
        NSString *msg = [NSString stringWithFormat:@"您当前的车辆处于%@状态，无法操作！",text];
        if (!parentView) {
            parentView = [UIApplication sharedApplication].keyWindow;
        }
        [self addLabelWithFrame:frame content:msg radius:5 fontSize:13 parentView:parentView isAlertShow:YES  pushBlock:^{
        }];
    }
    return flag;
}

+ (float)roundToLastTwoFloatValue:(float)value {
    float rounded = roundf( value * 100.0);
    rounded = rounded / 100.0;
    return rounded ;
}

+ (UIFont *)getHelveticaNeueFontType:(HelveticaNeueFontType)fontType withFontSize:(CGFloat)fontSize isAdjustByRatio:(BOOL)isNeedAdjust {
    @autoreleasepool {
        NSArray *fontTypeNameList =  @[@"HelveticaNeue-BoldItalic",
                                       @"HelveticaNeue-Light",
                                       @"HelveticaNeue-Italic",
                                       @"HelveticaNeue-UltraLightItalic",
                                       @"HelveticaNeue-CondensedBold",
                                       @"HelveticaNeue-MediumItalic",
                                       @"HelveticaNeue-Thin",
                                       @"HelveticaNeue-Medium",
                                       @"HelveticaNeue-ThinItalic",
                                       @"HelveticaNeue-LightItalic",
                                       @"HelveticaNeue-UltraLight",
                                       @"HelveticaNeue-Bold",
                                       @"HelveticaNeue",
                                       @"HelveticaNeue-CondensedBlack"];
        CGFloat size = (isNeedAdjust)?vAdjustByScreenRatio(fontSize):fontSize;
        if (fontType>fontTypeNameList.count-1) fontType =HelveticaNeueFontTypeOfRegular;
        
        NSString *fontTypeName = fontTypeNameList[fontType];
        UIFont *font = nil;
        switch (fontType) {
            case HelveticaNeueFontTypeOfBoldItalic:
            case HelveticaNeueFontTypeOfItalic:
            case HelveticaNeueFontTypeOfUltraLightItalic:
            case HelveticaNeueFontTypeOfMediumItalic:
            case HelveticaNeueFontTypeOfThinItalic:
            case HelveticaNeueFontTypeOfLightItalic:{
                CGAffineTransform matrix = CGAffineTransformMake(1, 0, tanf(15 * (CGFloat)M_PI / 180), 1, 0, 0);
                UIFontDescriptor *desc = [UIFontDescriptor fontDescriptorWithName:fontTypeName matrix:matrix];
                font = [UIFont fontWithDescriptor:desc size:size];
            }
                break;
                
            default:
                font = [UIFont fontWithName:fontTypeName size:size];
                break;
        }
        return font;
    }
    
}

+ (CGFloat)ratioOfiP5TOiP4 {
    CGFloat maxHeight = 568.0f;
    CGFloat miniHeight = 480.0f;
    return miniHeight/maxHeight;
}

+ (CGFloat)screenRatioOfiP5TOiP6P {
    CGFloat minHeight = 568.0f;
    CGFloat currentHeight = CGRectGetHeight([UIScreen mainScreen].bounds);
    return currentHeight/minHeight;
}

+ (UIFont *)boldAndSizeFont:(int) sizeValue {
    UIFont *font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:sizeValue];
    return font ;
}

+ (NSString *)verifyAndConvertDataToString:(id)data {
    NSString *string = data;
    if ([data isKindOfClass:NSNumber.class]) {
        string = [(NSNumber*)data stringValue];
    }
    if (!string||[string isKindOfClass:NSNull.class]) {
        string = @"";
    }
    return string;
}

+ (NSNumber *)verifyAndConvertDataToNumber:(id)data {
    NSNumber *number = data;
    if ([data isKindOfClass:NSString.class]) {
        if ([data rangeOfString:@"."].location!=NSNotFound) {
            number = @([(NSString*)data doubleValue]);
        }else {
            number = @([(NSString*)data longLongValue]);
        }
    }
    if (!number||[number isKindOfClass:NSNull.class]) {
        number = @(0);
    }
    return number;
}

static HanyuPinyinOutputFormat *outputFormat = nil;
+ (NSString *)chineseStringConvertToPinYinStringWithString:(NSString *)words {
    @autoreleasepool {
        
        if (!outputFormat) {
            outputFormat=[[HanyuPinyinOutputFormat alloc] init];
            [outputFormat setToneType:ToneTypeWithoutTone];
            [outputFormat setVCharType:VCharTypeWithV];
            [outputFormat setCaseType:CaseTypeLowercase];
        }
        NSString *outputPinyin=[PinyinHelper toHanyuPinyinStringWithNSString:words withHanyuPinyinOutputFormat:outputFormat withNSString:@" "];
        if ([words isEqualToString:@"长沙市"]||[words isEqualToString:@"长春市"]||[words isEqualToString:@"长治市"]) {
            outputPinyin = [outputPinyin stringByReplacingOccurrencesOfString:@"zhang" withString:@"chang"];
        }
        return outputPinyin;
    }
    
}

+ (CGSize)getStringSizeWithString:(nonnull NSString *)string font:(nonnull UIFont *)font widthOfView:(CGSize)size {
    
   return [self getStringSizeWithString:string font:font widthOfView:size withEdgeInset:UIEdgeInsetsZero];
}


+ (CGSize)getStringSizeWithString:(nonnull NSString *)string font:(nonnull UIFont *)font widthOfView:(CGSize)size withEdgeInset:(UIEdgeInsets)edgeInsetsValue {
    
    CGSize newSize = CGSizeZero;
    if (!string) string = @"";
    if (!font) font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 15.0f, NO);
    if (size.width!=CGFLOAT_MAX) {
        size.width = size.width-edgeInsetsValue.left-edgeInsetsValue.right;
    }
    if (size.height!=CGFLOAT_MAX) {
        size.height = size.height-edgeInsetsValue.top-edgeInsetsValue.bottom;
    }

    if ([string respondsToSelector:
         @selector(boundingRectWithSize:options:attributes:context:)])
    {
        NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
        paragraphStyle.alignment = NSTextAlignmentLeft;
        
        NSDictionary * attributes = @{NSFontAttributeName : font,
                                      NSParagraphStyleAttributeName : paragraphStyle};
        
        newSize = [string boundingRectWithSize:size
                                          options:NSStringDrawingUsesLineFragmentOrigin
                |NSStringDrawingUsesLineFragmentOrigin
                                       attributes:attributes
                                          context:nil].size;
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        newSize = [string sizeWithFont:font
                        constrainedToSize:size
                            lineBreakMode:NSLineBreakByWordWrapping];
#pragma clang diagnostic pop
    }
    return newSize;
}

+ (CGSize)getAttributedStringSizeWithString:(NSMutableAttributedString *)string widthOfView:(CGSize)size {
    return [self getAttributedStringSizeWithString:string widthOfView:size withEdgeInset:UIEdgeInsetsZero];
}

+ (CGSize)getAttributedStringSizeWithString:(NSAttributedString *)string widthOfView:(CGSize)size withEdgeInset:(UIEdgeInsets)edgeInsetsValue {
    
    CGSize newSize = CGSizeZero;
    if (size.width!=CGFLOAT_MAX) {
        size.width = size.width-edgeInsetsValue.left-edgeInsetsValue.right;
    }
    if (size.height!=CGFLOAT_MAX) {
        size.height = size.height-edgeInsetsValue.top-edgeInsetsValue.bottom;
    }
    
    if (!string) return CGSizeZero;
    if ([string respondsToSelector: @selector(boundingRectWithSize:options:context:)]) {
        
        newSize = [string boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    }
    return newSize;
    
}

+ (UIAlertView *)showAlertViewWithTitle:(NSString *)title
                                message:(NSString *)message
                        isShowImmediate:(BOOL)isShowImmediate
                      cancelButtonTitle:(NSString *)cancelButtonTitle
                      otherButtonTitles:(id)otherButtonTitles
          clickedButtonAtIndexWithBlock:(void (^)(NSNumber *btnIdx, UIAlertView *alertView))clickedButtonBlock {
    @autoreleasepool {
        if (!title||[title isEqualToString:@""]) title = @"alert_remind";
        if (!cancelButtonTitle||[cancelButtonTitle isEqualToString:@""]) cancelButtonTitle = @"ok";
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:getLocalizationString(title)
                                                            message:message
                                                           delegate:nil
                                                  cancelButtonTitle:getLocalizationString(cancelButtonTitle)
                                                  otherButtonTitles:nil];
        if (otherButtonTitles) {
            if ([otherButtonTitles isKindOfClass:[NSArray class]]) {
                [(NSArray *)otherButtonTitles enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    if ([obj isKindOfClass:[NSString class]]&&![(NSString *)obj isEqualToString:@""]) {
                        [alertView addButtonWithTitle:getLocalizationString(obj)];
                    }
                }];
            }else if([otherButtonTitles isKindOfClass:[NSString class]]&&![(NSString *)title isEqualToString:@""]){
                [alertView addButtonWithTitle:getLocalizationString(otherButtonTitles)];
            }
        }
        
        [alertView.rac_buttonClickedSignal subscribeNext:^(NSNumber *btnIdx) {
            if (clickedButtonBlock) {
                clickedButtonBlock(btnIdx, alertView);
            }
        }];
        
        if(isShowImmediate){
            [alertView show];
        }
        return alertView;
    }
}

+ (void)addLabelWithFrame:(CGRect)frame content:(NSString*)text radius:(CGFloat)radius fontSize:(CGFloat)size  parentView:(UIView *)parentView isAlertShow:(BOOL)isAlertShow pushBlock:(void (^)(void))pushBlock {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.layer.cornerRadius = radius;
    btn.layer.shadowOffset =  CGSizeMake(3, 5);
    btn.layer.shadowOpacity = 0.6;
    btn.layer.shadowColor =  [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1].CGColor;
    CGSize textSize = [self getStringSizeWithString:text font:systemFontBoldWithoutRatio(size) widthOfView:CGSizeMake(MAXFLOAT, 20)];
    int num = (int)(textSize.width/(frame.size.width));
    num++;
    CGFloat textHeight = num*textSize.height+14;
    frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, textHeight);
    
    btn.frame = frame;
    btn.backgroundColor =  [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
    btn.alpha = 0;
    
    UILabel *label = [UILabel new];
    label.frame = CGRectMake(10, 0, frame.size.width-20, frame.size.height);
    
    label.backgroundColor =  [UIColor clearColor];
    label.textColor = [UIColor whiteColor ];
    label.text = text;
    label.font = [UIFont boldSystemFontOfSize:size];
    label.alpha = 0;
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    [btn addSubview:label];
    CGFloat delay = 2.0;
    if (num==1) {
        delay = 1.7;
        CGFloat h = textHeight+6;
        CGFloat w = textSize.width+50;
        if (textSize.width>130) {
            w = textSize.width+34;
        }else{
            delay = 1.5;
        }
        if (w>frame.size.width) {
            w = frame.size.width;
        }
        btn.frame = CGRectMake(frame.origin.x, frame.origin.y-20, w, h);
        btn.center = CGPointMake(SCREEN_WIDTH*0.5,btn.frame.origin.y+h*0.5);
        label.frame = CGRectMake(0, 0, w, h);
        label.textAlignment = NSTextAlignmentCenter;
    }
    
    if (isAlertShow) {
        btn.alpha = 0.2;
        label.alpha = 0.2;
        btn.transform = CGAffineTransformMakeScale(0.6, 0.6);
        
        [parentView addSubview:btn];
        [UIView animateWithDuration:0.2
                         animations:^{
                             btn.alpha = 1;
                             label.alpha = 1;
                             btn.transform = CGAffineTransformMakeScale(1.1, 1.1);
                         }
                         completion:^(BOOL finished) {
                             [UIView animateWithDuration:0.1
                                              animations:^{
                                                  btn.transform = CGAffineTransformIdentity;
                                                  
                                                  
                                              }];
                             [UIView animateWithDuration:1.2 delay:delay options:UIViewAnimationOptionCurveLinear animations:^{
                                 label.alpha = 0;
                                 btn.alpha = 0;
                             } completion:^(BOOL finished) {
                                 [label removeFromSuperview];
                                 [btn removeFromSuperview];
                                 pushBlock();
                                 
                             }];
                             
                         }];
    }else{
        [parentView addSubview:btn];
        delay = delay-0.1;
        [UIView animateWithDuration:1.2 animations:^{
            label.alpha = 1;
            btn.alpha = 1;
            
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:1.2 delay:delay options:UIViewAnimationOptionCurveLinear animations:^{
                label.alpha = 0;
                btn.alpha = 0;
            } completion:^(BOOL finished) {
                [label removeFromSuperview];
                [btn removeFromSuperview];
                pushBlock();
                
            }];
        }];
    }
    
    
}

+ (void)makeACall:(NSString *)number andContents:(NSString *)contents withTitle:(NSString *)title {
    NSLog(@"%d",IS_SIMULATOR);
    NSLog(@"%d",IS_IPHONE);
    
    if (!title) title = @"温馨提示";
    if (!number) number = @"";
    if (!contents) contents = @"系统将会拨打以下号码：\n%@";
    if (![contents isContainsString:number]&&![contents isContainsString:@"%@"]) {
        contents = [contents stringByAppendingString:@"\n%@"];
    }
    if ([contents isContainsString:@"%@"]) contents = [NSString stringWithFormat:contents, number];
    if (IS_IPHONE&&/* DISABLES CODE */ (!IS_SIMULATOR)) {
        [SupportingClass showAlertViewWithTitle:title
                                        message:contents
                                isShowImmediate:YES cancelButtonTitle:@"cancel"
                              otherButtonTitles:@"ok" clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                                  if (btnIdx.integerValue == 1) {
                                      [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"tel:" stringByAppendingString:number]]];
                                  }
                              }];
    }else {
        [SupportingClass showAlertViewWithTitle:@"alert_remind"
                                        message:[@"本机不支援拨号功能！\n请用有拨号功能的电话拨打以下号码：\n" stringByAppendingString:number]
                                isShowImmediate:YES cancelButtonTitle:@"ok"
                              otherButtonTitles:nil clickedButtonAtIndexWithBlock:nil];
    }
    
}

+ (void)makeACall:(NSString *)number {
    [self makeACall:number andContents:nil withTitle:nil];
}


+ (NSString *)removeHTML:(NSString *)html {
    
    NSScanner *theScanner;
    
    NSString *text = nil;
    
    
    
    theScanner = [NSScanner scannerWithString:html];
    
    
    
    while ([theScanner isAtEnd] == NO) {
        
        // find start of tag
        
        [theScanner scanUpToString:@"<" intoString:NULL] ;
        
        
        
        // find end of tag
        
        [theScanner scanUpToString:@">" intoString:&text] ;
        
        
        
        // replace the found tag with a space
        
        //(you can filter multi-spaces out later if you wish)
        
        html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>", text] withString:@""];
        
        
        
    }
    
    return html;
    
}

+ (void)getAutosBrandList:(ULHAutosBrandListResultBlock)resultBlock {
    NSArray *autosBrandList = [DBHandler.shareInstance getAutosBrandList];
    BOOL needUpdate = [DBHandler.shareInstance isDataNeedToUpdate:CDZDBUpdateListOfAutosBrand];
    if (autosBrandList.count==0||needUpdate) {
        [self updateAutosBrandList:^(NSArray *resultList, NSError *error) {
            resultBlock(resultList, error);
        }];
    }else {
        resultBlock(autosBrandList, nil);
    }
    
}

+ (void)updateAutosBrandList:(ULHAutosBrandListResultBlock)resultBlock {
    
    [[APIsConnection shareConnection] commonAPIsGetAutoBrandListWithSuccessBlock:^(NSURLSessionDataTask *operation, id responseObject) {
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        if (errorCode!=0) {
            NSError *error = [NSError errorWithDomain:message code:-00001 userInfo:nil];
            if (resultBlock) {
                resultBlock(nil, error);
            }
            return;
        }
        
        if (!responseObject||[responseObject count]==0) {
            NSError *error = [NSError errorWithDomain:@"品牌列表获取失败！" code:-00001 userInfo:nil];
            if (resultBlock) {
                resultBlock(nil, error);
            }
            NSLog(@"data Error");
            return;
        }
        if (resultBlock) {
            NSArray *autosBrandList = responseObject[CDZKeyOfResultKey];
            @weakify(self);
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                @strongify(self)
                [self backgroundUpdateAutosBrandList:@[autosBrandList, resultBlock].copy];
            });
        }
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        if (resultBlock) {
            resultBlock(nil, error);
        }
    }];
    
}

+ (void)backgroundUpdateAutosBrandList:(NSArray *)argumentList {
    @autoreleasepool {
        NSArray *autosBrandList = [AutosBrandDTO handleDataListToDTOList:argumentList[0]];
        ULHAutosBrandListResultBlock resultBlock = argumentList[1];
        resultBlock(autosBrandList, nil);
        [self backGroundUpdateAutosBrandKeyList:autosBrandList];
    }
}

+ (void)backGroundUpdateAutosBrandKeyList:(NSArray *)keyBrandList {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([DBHandler.shareInstance updateAutosBrandList:keyBrandList]) {
            NSDate *nowDate = [NSDate date];
            NSCalendar *gregorian = [NSCalendar currentCalendar];
            NSDateComponents *dateComponents = [gregorian components:(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute)
                                                            fromDate:nowDate];
            dateComponents.day +=3;
            NSDate *newDate = [gregorian dateFromComponents:dateComponents];
            [DBHandler.shareInstance updateDataNextUpdateDateTime:newDate table:CDZDBUpdateListOfAutosBrand];
        }
    });
    
}
@end
