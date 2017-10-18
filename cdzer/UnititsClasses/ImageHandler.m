//
//  ImageHandler.m
//  cdzer
//
//  Created by KEns0n on 2/26/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#define vP6PWidth 1242.0f
#define vP6Width 750.0f
#define vP5Width 640.0f

#define vP6PHeight 2208.0f
#define vP6Height 1334.0f
#define vP5Height 1136.0f
#define vP4Height 960.0f


#import "ImageHandler.h"
#import "UIView+ShareAction.h"

@implementation ImageHandler

static UIImage *colorLogo = nil;
static UIImage *defaultWhiteLogo = nil;
static UIImage *whiteLogo = nil;
static UIImage *getWhiteUserLogo = nil;
static UIImage *getRankingUserLogo = nil;
static UIImage *leftArrow = nil;
static UIImage *rigthArrow = nil;
static UIImage *couponOn = nil;
static UIImage *couponOff = nil;
static UIImage *skIcon = nil;



+ (UIImage *)getTheLaunchImage {
    
    
//    NSInteger osVersion = floor([[[UIDevice currentDevice] systemVersion] floatValue])*100;
//    NSString *key;
//    if (osVersion >= 700) {
//        key = @"UILaunchImages";
//    } else {
//        key = @"UILaunchImageFile";
//    }
//    NSArray *array = [[[NSBundle mainBundle] infoDictionary] valueForKey:key];
//    NSLog(@"%@",array);
    
    NSString *defaultImageName = @"LaunchImage";
    NSInteger osVersion = floor([[[UIDevice currentDevice] systemVersion] floatValue])*100;
    
    NSInteger screenHeight = CGRectGetHeight([UIScreen mainScreen].bounds);
    // 3.5inch
    if (screenHeight < 568) {
        
        if (osVersion >= 700) {
            defaultImageName = [NSString stringWithFormat:@"%@-700",defaultImageName];
        } else {
            defaultImageName = [NSString stringWithFormat:@"%@",defaultImageName];
        }
        
    }
    // 4.0inch
    else if(screenHeight < 667){
        
        if (osVersion >= 700) {
            defaultImageName = [NSString stringWithFormat:@"%@-700-568h",defaultImageName];
        } else {
            defaultImageName = [NSString stringWithFormat:@"%@-568h",defaultImageName];
        }
    }
    // 4,7inch
    else if (screenHeight < 736) {
        
        defaultImageName = [NSString stringWithFormat:@"%@-800-667h",defaultImageName];
        
    }
    // 5.5inch
    else{
        NSString *orientation = @"";
        switch ([[UIApplication sharedApplication] statusBarOrientation]) {
            case UIInterfaceOrientationUnknown:
            case UIInterfaceOrientationPortrait:
            case UIInterfaceOrientationPortraitUpsideDown:
                orientation = @"Portrait";
                break;
            case UIInterfaceOrientationLandscapeLeft:
            case UIInterfaceOrientationLandscapeRight:
                orientation = @"Landscape";
                break;
            default:
                break;
        }
        defaultImageName = [NSString stringWithFormat:@"%@-800-%@-736h",defaultImageName,orientation];
    }
    return [UIImage imageNamed:defaultImageName];
}



+ (UIImage *)getImageScale:(NSString *)imageName {
    UIImage *image = [UIImage imageNamed:imageName];
    return [image resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
}

+ (UIImage *)getColorLogo {
    if (!colorLogo) {
        colorLogo = [self getImageFromCacheByScreenRatioWithFileRootPath:kSysImageCaches
                                                                fileName:@"color_logo"
                                                                    type:FMImageTypeOfPNG
                                                         scaleWithPhone4:NO
                                                             offsetRatioForP4:1.0f
                                                            needToUpdate:YES];
    }
    return colorLogo;
}

+ (UIImage *)getDefaultUserLogo {
    if (!getWhiteUserLogo) {
        getWhiteUserLogo = [self getImageFromCacheByScreenRatioWithFileRootPath:kSysImageCaches
                                                                       fileName:@"login_logo"
                                                                           type:FMImageTypeOfPNG
                                                                scaleWithPhone4:NO
                                                               offsetRatioForP4:1.0f
                                                                   needToUpdate:YES];
    }
    return getWhiteUserLogo;
}

+ (UIImage *)getDefaultRankingUserLogo {
    if (!getRankingUserLogo) {
        getRankingUserLogo = [self getImageFromCacheByScreenRatioWithFileRootPath:kSysImageCaches
                                                                         fileName:@"ranking_head"
                                                                             type:FMImageTypeOfPNG
                                                                  scaleWithPhone4:NO
                                                                 offsetRatioForP4:1.0f
                                                                     needToUpdate:YES];
    }
    return getRankingUserLogo;
}

+ (UIImage *)getWhiteLogo {
    if (!whiteLogo) {
        whiteLogo = [self getImageFromCacheByScreenRatioWithFileRootPath:kSysImageCaches
                                                                       fileName:@"white_logo"
                                                                           type:FMImageTypeOfPNG
                                                                scaleWithPhone4:NO
                                                                    offsetRatioForP4:1.0f
                                                                   needToUpdate:YES];
    }
    return whiteLogo;
}

+ (UIImage *)getDefaultWhiteLogo {
    if (!defaultWhiteLogo) {
        defaultWhiteLogo = [self getImageFromCacheByScreenRatioWithFileRootPath:kSysImageCaches
                                                                       fileName:@"default_white_logo_new"
                                                                           type:FMImageTypeOfPNG
                                                                scaleWithPhone4:NO
                                                                    offsetRatioForP4:1.0f
                                                                   needToUpdate:YES];
    }
    return defaultWhiteLogo;
}

+ (UIImage *)getLeftArrow {
    if (!leftArrow) {
        leftArrow = [ImageHandler getImageFromCacheByScreenRatioWithFileRootPath:kSysImageCaches
                                                                        fileName:@"left_arrow"
                                                                            type:FMImageTypeOfPNG
                                                                 scaleWithPhone4:NO
                                                                     offsetRatioForP4:1.0f
                                                                    needToUpdate:YES];
    }
    return leftArrow;
}

+ (UIImage *)getRightArrow {
    if (!rigthArrow) {
        rigthArrow = [ImageHandler getImageFromCacheByScreenRatioWithFileRootPath:kSysImageCaches
                                                                         fileName:@"right_arrow"
                                                                             type:FMImageTypeOfPNG
                                                                  scaleWithPhone4:NO
                                                                      offsetRatioForP4:1.0f
                                                                     needToUpdate:YES];
    }
    return rigthArrow;
}

+ (UIImage *)getSKIcon {
    if (!skIcon) {
        skIcon = [ImageHandler getImageFromCacheByScreenRatioWithFileRootPath:kSysImageCaches
                                                                     fileName:@"sk_icon"
                                                                         type:FMImageTypeOfPNG
                                                              scaleWithPhone4:NO
                                                             offsetRatioForP4:1.0f
                                                                 needToUpdate:YES];
    }
    return skIcon;
}

+ (UIImage *)getCouponOnImage {
    if (!couponOn) {
        couponOn = [ImageHandler getImageFromCacheByScreenRatioWithFileRootPath:kSysImageCaches
                                                                       fileName:@"coupon_on"
                                                                           type:FMImageTypeOfPNG
                                                                scaleWithPhone4:NO
                                                                    offsetRatioForP4:1.0f
                                                                   needToUpdate:YES];
    }
    return couponOn;
}

+ (UIImage *)getCouponOffImage {
    if (!couponOff) {
        couponOff = [ImageHandler getImageFromCacheByScreenRatioWithFileRootPath:kSysImageCaches
                                                                        fileName:@"coupon_off"
                                                                            type:FMImageTypeOfPNG
                                                                 scaleWithPhone4:NO
                                                                     offsetRatioForP4:1.0f
                                                                    needToUpdate:YES];
    }
    return couponOff;
}

+ (UIImage *)ipMaskedImage:(UIImage *)image color:(UIColor *)color {
 
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, image.scale);
    CGContextRef c = UIGraphicsGetCurrentContext();
    [image drawInRect:rect];
    CGContextSetFillColorWithColor(c, [color CGColor]);
    CGContextSetBlendMode(c, kCGBlendModeSourceAtop);
    CGContextFillRect(c, rect);
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}

+ (UIImage *)croppingImageWithImage:(UIImage *)imageToCrop toRect:(CGRect)rect {
    
    rect.origin.x = rect.origin.x*imageToCrop.scale;
    rect.origin.y = rect.origin.y*imageToCrop.scale;
    rect.size.width = rect.size.width*imageToCrop.scale;
    rect.size.height = rect.size.height*imageToCrop.scale;
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([imageToCrop CGImage], rect);
    
    UIImage *cropped = [UIImage imageWithCGImage:imageRef scale:imageToCrop.scale orientation:imageToCrop.imageOrientation];
    
    CGImageRelease(imageRef);
    
    return cropped;
    
}

+ (UIImage *)imageWithImage:(UIImage *)image convertToSize:(CGSize)size {
    
    UIGraphicsBeginImageContextWithOptions(size, NO, image.scale);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return destImage;
}

+ (CGSize)getImageTureSizeFromIamge:(UIImage *)image {
    CGFloat scaleRatio = [SupportingClass isTripleSizeRetinaScreen]?3.0f:([SupportingClass isTwiceSizeRetinaScreen]?2.0f:1.0f);
    CGSize imageSize = CGSizeMake(image.size.width/scaleRatio, image.size.height/scaleRatio);
    return imageSize;
}

+ (UIImage *)scaleImage:(UIImage *)image toNewSize:(CGSize)newSize {
    CGRect rect = CGRectZero;
    rect.size = newSize;
    UIGraphicsBeginImageContextWithOptions(newSize, NO, image.scale);
    [image drawInRect:rect];
    
    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return smallImage;
    
}

+ (UIImage *)imageResizeToNormalRetinaByFixedRatioWithoutScaleWithPath:(NSString *)imageFullPath {
    @autoreleasepool {
        
        UIImage * image = nil;
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:imageFullPath]) {
            UIImage *tmpImage = [UIImage imageWithContentsOfFile:imageFullPath];
            image = tmpImage;
            
            CGRect rect = CGRectZero;
            if (![SupportingClass isTwiceSizeRetinaScreen]) {
                image = nil;
                CGSize oldSize = tmpImage.size;
                rect.size = CGSizeMake(oldSize.width/3.0f, oldSize.height/3.0f);
                image = [self scaleImage:tmpImage toNewSize:rect.size];
                
            }else if (![SupportingClass isTripleSizeRetinaScreen]) {
                image = nil;
                CGSize oldSize = tmpImage.size;
                rect.size = CGSizeMake(oldSize.width/3.0f*2.0f, oldSize.height/3.0f*2.0f);
                image = [self scaleImage:tmpImage toNewSize:rect.size];
            }
        }
        
        return image;
    }
}

+ (UIImage *)imageWithImage:(UIImage *)image scaleRatio:(NSUInteger)scaleRatio convertToSize:(CGSize)size {
    
    UIGraphicsBeginImageContextWithOptions(size, NO, scaleRatio);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return destImage;
}


+ (UIImage *)imageResizeToRetinaImageByScreenScaleAndScreenWidthWithPath:(NSString *)imageFullPath {
    @autoreleasepool {
        
        UIImage * image = nil;
        if ([[NSFileManager defaultManager] fileExistsAtPath:imageFullPath]) {
            UIImage *tmpImage = [UIImage imageWithContentsOfFile:imageFullPath];
            CGRect lastRect = CGRectZero;
            CGRect rectS1 = CGRectZero;
            rectS1.size = tmpImage.size;
            CGRect rectS2 = CGRectZero;
            rectS2.size = CGSizeMake(round(tmpImage.size.width/2.0f), round(tmpImage.size.height/2.0f));
            CGRect rectS3 = CGRectZero;
            rectS3.size = CGSizeMake(round(tmpImage.size.width/3.0f), round(tmpImage.size.height/3.0f));
            
            NSUInteger scaleRatio = 1;
            if (rectS1.size.width<=SCREEN_WIDTH&&rectS1.size.height<=SCREEN_WIDTH*0.7f) {
                lastRect = rectS1;
            }else if (rectS2.size.width<=SCREEN_WIDTH&&rectS2.size.height<=SCREEN_WIDTH*0.7f) {
                lastRect = rectS2;
                scaleRatio = 2;
            }else {
                lastRect = rectS3;
                scaleRatio = IS_IPHONE_6P?3:2;
            }
            image = [self imageWithImage:tmpImage scaleRatio:scaleRatio convertToSize:lastRect.size];
        }
        
            return image;
    }
}

+ (UIImage *)imageResizeToRetinaByScreenHeightRatioWithPath:(NSString *)imageFullPath scaleWithPhone4:(BOOL)needScale offsetRatioForP4:(double)offsetRatioForP4 {
    @autoreleasepool {
        
        UIImage * image = nil;
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:imageFullPath]) {
            UIImage *tmpImage = [UIImage imageWithContentsOfFile:imageFullPath];
            image = tmpImage;
            
            if (offsetRatioForP4<0.0f) offsetRatioForP4 = 0.0f;
            if (offsetRatioForP4>1.0f) offsetRatioForP4 = 1.0f;
            
            CGRect rect = CGRectZero;
            CGFloat ratio ;
            CGFloat ratioGap = 1;
            if (!IS_IPHONE_6P) {
                if (IS_IPHONE_5||IS_IPHONE_4_OR_LESS) {
                    ratio = vP6PHeight/vP5Height;
                    ratioGap = vP5Width/(vP6PWidth/ratio);
                }else if (IS_IPHONE_6) {
                    ratio = vP6PHeight/vP6Height;
                    ratioGap = vP6Width/(vP6PWidth/ratio);
                }
                image = nil;
                CGSize oldSize = tmpImage.size;
                rect.size = CGSizeMake(oldSize.width/ratio*ratioGap, oldSize.height/ratio);
                image = [self scaleImage:tmpImage toNewSize:rect.size];
                if (IS_IPHONE_4_OR_LESS&&needScale) {
                    CGFloat tmpHeight = CGRectGetHeight(rect);
                    rect.size.height = CGRectGetHeight(rect)*vP4Height/vP5Height;
                    rect.origin.y = (tmpHeight - CGRectGetHeight(rect))*offsetRatioForP4;
                    tmpImage = nil;
                    tmpImage = image;
                    image = nil;
                    image = [self croppingImageWithImage:tmpImage toRect:rect];
                }
            }
        }
        return image;
    }
}

+ (UIImage *)imageResizeToRetinaByScreenHeightRatioWithImage:(UIImage *)originalImage{
    @autoreleasepool {
        
        UIImage * image = nil;
        
        if (originalImage) {
            image = originalImage;
            
            CGRect rect = CGRectZero;
            CGFloat ratio ;
            CGFloat ratioGap = 1;
            if (!IS_IPHONE_6P) {
                if (IS_IPHONE_5||IS_IPHONE_4_OR_LESS) {
                    ratio = vP6PHeight/vP5Height;
                    ratioGap = vP5Width/(vP6PWidth/ratio);
                }else if (IS_IPHONE_6) {
                    ratio = vP6PHeight/vP6Height;
                    ratioGap = vP6Width/(vP6PWidth/ratio);
                }
                image = nil;
                CGSize oldSize = originalImage.size;
                rect.size = CGSizeMake(oldSize.width*originalImage.scale/ratio*ratioGap, oldSize.height*originalImage.scale/ratio);
                image = [self scaleImage:originalImage toNewSize:rect.size];
            }
        }
        return image;
    }
}

+ (UIImage *)getImageFromCacheWithByFixdeRatioFileRootPath:(NSString *)rootPath
                                                  fileName:(NSString *)fileName
                                                      type:(FMImageType)type
                                              needToUpdate:(BOOL)isUpdate{
    NSString *newFileName = fileName;
    NSString *fileType = (type==FMImageTypeOfJPEG)?@"jpg":@"png";
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:fileName ofType:fileType];
    NSString *path = [[[[FileManager getRootFolder:FMRootFolderTypeOfCache]
                        stringByAppendingPathComponent:rootPath]
                       stringByAppendingPathComponent:fileName]
                      stringByAppendingPathExtension:fileType];
    
    if ([SupportingClass isTripleSizeRetinaScreen]) {
        newFileName = nil;
        newFileName = [fileName stringByAppendingString:@"@3x"];
        
    }else if ([SupportingClass isTwiceSizeRetinaScreen]){
        newFileName = nil;
        newFileName = [fileName stringByAppendingString:@"@2x"];
    }
    
    if (![FileManager checkFileIsExistWithtRootType:FMRootFolderTypeOfCache
                                            subPath:rootPath
                                            theFile:newFileName
                                            extType:fileType
                                        isDirectory:nil]||isUpdate) {
        [FileManager saveImageToFileWithImageType:type
                                         rootType:FMRootFolderTypeOfCache
                                          subPath:rootPath
                                          theFile:[newFileName stringByAppendingPathExtension:fileType]
                                            image:[ImageHandler imageResizeToNormalRetinaByFixedRatioWithoutScaleWithPath:bundlePath]
                                         exifData:nil];
    }
    UIImage *imageTab = nil;
    
    imageTab = [UIImage imageWithContentsOfFile:path];
    
    return imageTab;
}

+ (UIImage *)getImageFromCacheByScreenRatioWithFileRootPath:(NSString *)rootPath
                                                   fileName:(NSString *)fileName
                                                       type:(FMImageType)type
                                            scaleWithPhone4:(BOOL)needScale
                                                offsetRatioForP4:(double)offsetRatioForP4
                                               needToUpdate:(BOOL)isUpdate {
    if (!rootPath||[rootPath isEqualToString:@""]) {
        rootPath = kSysImageCaches;
    }
    NSString *fileType = (type==FMImageTypeOfJPEG)?@"jpg":@"png";
    if (![FileManager checkFileIsExistWithtRootType:FMRootFolderTypeOfBundle
                                            subPath:nil
                                            theFile:fileName
                                            extType:fileType
                                        isDirectory:nil]) {
        return nil;
    }
    @autoreleasepool {
        
        NSString *newFileName = fileName;
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:fileName ofType:fileType];
        NSString *path = [[[[FileManager getRootFolder:FMRootFolderTypeOfCache]
                            stringByAppendingPathComponent:rootPath]
                           stringByAppendingPathComponent:fileName]
                          stringByAppendingPathExtension:fileType];
                
        if ([SupportingClass isTripleSizeRetinaScreen]) {
            newFileName = nil;
            newFileName = [fileName stringByAppendingString:@"@3x"];
            
        }else if ([SupportingClass isTwiceSizeRetinaScreen]){
            newFileName = nil;
            newFileName = [fileName stringByAppendingString:@"@2x"];
        }
        
        if (![FileManager checkFileIsExistWithtRootType:FMRootFolderTypeOfCache
                                                subPath:rootPath
                                                theFile:newFileName
                                                extType:fileType
                                            isDirectory:nil]||isUpdate) {
            [FileManager saveImageToFileWithImageType:type
                                             rootType:FMRootFolderTypeOfCache
                                              subPath:rootPath
                                              theFile:[newFileName stringByAppendingPathExtension:fileType]
                                                image:[self imageResizeToRetinaByScreenHeightRatioWithPath:bundlePath scaleWithPhone4:needScale offsetRatioForP4:offsetRatioForP4]
                                             exifData:nil];
        }
        UIImage *imageTab = nil;
        
        imageTab = [UIImage imageWithContentsOfFile:path];
        
        return imageTab;
    }
}

+ (UIImage *)getImageFromCacheByRatioFromImage:(UIImage *)image
                                  fileRootPath:(NSString *)rootPath
                                      fileName:(NSString *)fileName
                                          type:(FMImageType)type
                                      exifData:(ExifContainer *)exifData
                                  needToUpdate:(BOOL)isUpdate {
    if (!image||!fileName||!type) {
        return nil;
    }
    
    NSString *newFileName = fileName;
    NSString *fileType = (type==FMImageTypeOfJPEG)?@"jpg":@"png";
    NSString *path = [[[[FileManager getRootFolder:FMRootFolderTypeOfCache]
                        stringByAppendingPathComponent:rootPath]
                       stringByAppendingPathComponent:fileName]
                      stringByAppendingPathExtension:fileType];
    
    if ([SupportingClass isTripleSizeRetinaScreen]) {
        newFileName = nil;
        newFileName = [fileName stringByAppendingString:@"@3x"];
        
    }else if ([SupportingClass isTwiceSizeRetinaScreen]){
        newFileName = nil;
        newFileName = [fileName stringByAppendingString:@"@2x"];
    }
    
    if (![FileManager checkFileIsExistWithtRootType:FMRootFolderTypeOfCache
                                            subPath:rootPath
                                            theFile:newFileName
                                            extType:fileType
                                        isDirectory:nil]||isUpdate) {
        [FileManager saveImageToFileWithImageType:type
                                         rootType:FMRootFolderTypeOfCache
                                          subPath:rootPath
                                          theFile:[newFileName stringByAppendingPathExtension:fileType]
                                            image:[self imageResizeToRetinaByScreenHeightRatioWithImage:image]
                                         exifData:exifData];
    }
    UIImage *imageTab = nil;
    
    imageTab = [UIImage imageWithContentsOfFile:path];
    
    return imageTab;
}

+ (CAShapeLayer *)drawDashedBorderByType:(BorderType)borderType
                                  target:(UIView *)target
                              shapeLayer:(CAShapeLayer *)shapeLayer
                             borderColor:(UIColor *)borderColor
                            cornerRadius:(CGFloat)cornerRadius
                             borderWidth:(CGFloat)borderWidth
                             dashPattern:(NSInteger)dashPattern
                            spacePattern:(NSInteger)spacePattern
                         numberOfColumns:(NSInteger)columns
                            numberOfRows:(NSInteger)rows {
    
    if (shapeLayer) [shapeLayer removeFromSuperlayer];
    
    
    //drawing
    CGRect frame = target.bounds;
    
    shapeLayer = [CAShapeLayer layer];
    
    //creating a path
    CGMutablePathRef path = CGPathCreateMutable();
    
    //drawing a border around a view
    CGPathMoveToPoint(path, NULL, 0.0f, frame.size.height - cornerRadius);
    CGPathAddLineToPoint(path, NULL, 0.0f, cornerRadius);
    CGPathAddArc(path, NULL, cornerRadius, cornerRadius, cornerRadius, M_PI, -M_PI_2, NO);
    CGPathAddLineToPoint(path, NULL, frame.size.width - cornerRadius, 0.0f);
    CGPathAddArc(path, NULL, frame.size.width - cornerRadius, cornerRadius, cornerRadius, -M_PI_2, 0.0f, NO);
    CGPathAddLineToPoint(path, NULL, frame.size.width, frame.size.height - cornerRadius);
    CGPathAddArc(path, NULL, frame.size.width - cornerRadius, frame.size.height - cornerRadius, cornerRadius, 0.0f, M_PI_2, NO);
    CGPathAddLineToPoint(path, NULL, cornerRadius, frame.size.height);
    CGPathAddArc(path, NULL, cornerRadius, frame.size.height - cornerRadius, cornerRadius, M_PI_2, M_PI, NO);
    
    if (columns>1) {
        CGFloat averageWidth = frame.size.width/columns;
        for (int line = 1; line < columns; line++) {
            CGPathMoveToPoint(path, NULL, averageWidth*line, 0.0f);
            CGPathAddLineToPoint(path, NULL, averageWidth*line, frame.size.height);
        }
    }
    
    if (rows>1) {
        CGFloat averageHeight = frame.size.height/rows;
        for (int line = 1; line < rows; line++) {
            CGPathMoveToPoint(path, NULL, 0.0f,  averageHeight*line);
            CGPathAddLineToPoint(path, NULL, frame.size.width, averageHeight*line);
        }
    }
    
    //path is set as the shapeLayer object's path
    shapeLayer.path = path;
    CGPathRelease(path);
    
    shapeLayer.backgroundColor = [[UIColor clearColor] CGColor];
    shapeLayer.frame = frame;
    shapeLayer.masksToBounds = NO;
    [shapeLayer setValue:[NSNumber numberWithBool:NO] forKey:@"isCircle"];
    shapeLayer.fillColor = [[UIColor clearColor] CGColor];
    shapeLayer.strokeColor = [borderColor CGColor];
    shapeLayer.lineWidth = borderWidth;
    shapeLayer.lineDashPattern = borderType == BorderTypeDashed ? [NSArray arrayWithObjects:[NSNumber numberWithInteger:dashPattern], [NSNumber numberWithInteger:(long)spacePattern], nil] : nil;
    shapeLayer.lineCap = kCALineCapRound;
    
    //shapeLayer is added as a sublayer of the view
    [target.layer addSublayer:shapeLayer];
    target.layer.cornerRadius = cornerRadius;
    return shapeLayer;
}

+ (void)draw {
    
    CGContextRef con = UIGraphicsGetCurrentContext();
    
    // 绘制一个黑色的垂直黑色线，作为箭头的杆子
    
    CGContextMoveToPoint(con, 100, 100);
    
    CGContextAddLineToPoint(con, 100, 19);
    
    CGContextSetLineWidth(con, 20);
    
    CGContextStrokePath(con);
    
    // 绘制一个红色三角形箭头
    
    CGContextSetFillColorWithColor(con, [[UIColor redColor] CGColor]);
    
    CGContextMoveToPoint(con, 80, 25);
    
    CGContextAddLineToPoint(con, 100, 0);
    
    CGContextAddLineToPoint(con, 120, 25);
    
    CGContextFillPath(con);
    
    // 从箭头杆子上裁掉一个三角形，使用清除混合模式
    
    CGContextMoveToPoint(con, 90, 101);
    
    CGContextAddLineToPoint(con, 100, 90);
    
    CGContextAddLineToPoint(con, 110, 101);
    
    CGContextSetBlendMode(con, kCGBlendModeClear);
    
    CGContextFillPath(con);
}


+ (UIImage *)drawRotundityWithTick:(BOOL)isSelected
                              size:(CGSize)size
                       strokeColor:(UIColor *)strokColor
                         fillColor:(UIColor *)fillColor {
    
    CGRect rect = CGRectZero;
    rect.origin = CGPointMake(1.0f, 1.0f);
    rect.size.width = size.width-CGRectGetMinX(rect)*2.0f;
    rect.size.height = size.height-CGRectGetMinX(rect)*2.0f;
    
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 CGRectGetWidth(rect),
                                                 CGRectGetHeight(rect), 8, 0,
                                                 CGColorSpaceCreateDeviceRGB(), kCGImageAlphaNone|kCGImageAlphaPremultipliedFirst);
    UIGraphicsBeginImageContextWithOptions(size,NO,[UIScreen mainScreen].scale);
    CGContextSetShouldAntialias(context, YES);
    UIBezierPath *ovalPath = nil;
    if (!isSelected) {
        if(!strokColor) strokColor = UIColor.grayColor;
        ovalPath = [UIBezierPath bezierPathWithOvalInRect:rect];
        ovalPath.lineWidth = 1.0f;
        [strokColor setStroke];
        [ovalPath stroke];
    }else {
        if(!fillColor) fillColor = CDZColorOfDefaultColor;
        if(!strokColor) strokColor = UIColor.whiteColor;
        
        ovalPath = [UIBezierPath bezierPathWithOvalInRect:rect];
        [fillColor setStroke];
        [fillColor setFill];
        [ovalPath fill];
        [ovalPath stroke];
        
        UIBezierPath *linePath = [UIBezierPath bezierPathWithOvalInRect:rect];
        [strokColor setStroke];
        [strokColor setFill];
        [linePath removeAllPoints];
        linePath.lineWidth = 1.0f;
        [linePath moveToPoint:CGPointMake(5.0f, 12.0f)];
        [linePath addLineToPoint:CGPointMake(9.0f, 16.0f)];
        [linePath addLineToPoint:CGPointMake(16.0f, 8.0f)];
        [linePath addLineToPoint:CGPointMake(16.0f, 7.0f)];
        [linePath addLineToPoint:CGPointMake(9.0f, 15.0f)];
        [linePath addLineToPoint:CGPointMake(5.0f, 11.0f)];
        [linePath closePath];
        [linePath stroke];
        [linePath fill];
        
        
        [linePath appendPath:ovalPath];
        [linePath setUsesEvenOddFillRule:YES];
        [linePath addClip];
    }
    CGContextAddPath(context, ovalPath.CGPath);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    //    NSLog(@"%f",image.scale);
    //    NSLog(@"%@",NSStringFromCGSize(image.size));
    CGContextRelease(context);
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)createImageWithColor:(UIColor*)color withSize:(CGSize)size {
    CGRect rect = CGRectZero;
    rect.size = size;
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

+ (UIImage *)getLineColorImage:(UIColor *)colors
                     imageSize:(CGSize)imageSize
                     setborder:(BOOL)isSelected
               borderWithColor:(UIColor *)borderColor
                   borderWidth:(CGFloat)borderWidth {
    CGRect originRect = CGRectMake(0, 0, imageSize.width, imageSize.height);
    
    UIGraphicsBeginImageContextWithOptions(originRect.size, NO, [UIScreen mainScreen].scale);
    //// Rectangle Drawing
    UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRoundedRect:originRect cornerRadius: imageSize.height/2.0f];
    if (!colors) colors = UIColor.darkGrayColor;
    
    [colors setFill];
    [rectanglePath fill];
    
    if (isSelected) {
        UIBezierPath* rectangle2Path = [UIBezierPath bezierPathWithRoundedRect:originRect cornerRadius: imageSize.height/2.0f];
        if (!borderColor) CDZColorOfLightGray;
        [borderColor setStroke];
        rectangle2Path.lineWidth = borderWidth;
        [rectangle2Path stroke];
    }

    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
    
}

+ (UIImage *)getCircleColorImage:(UIColor *)colors
                       imageSize:(CGSize)imageSize
                       setborder:(BOOL)isSelected
                 borderWithColor:(UIColor *)borderColor
                     borderWidth:(CGFloat)borderWidth {
    @autoreleasepool {
        CGFloat padding = 0;//圆形图像距离图像的边距
        UIColor *epsBackColor = [UIColor clearColor];        //图像的背景色
        CGRect originRect = CGRectMake(0, 0, imageSize.width, imageSize.height);
        UIImage *originImage = [self createImageWithColor:colors withSize:originRect.size];
        
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, [UIScreen mainScreen].scale);
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        
        //目标区域。
        CGRect desRect =  CGRectMake(padding, padding,imageSize.width-(padding*2), imageSize.height-(padding*2));
        
        //设置填充背景色。
        CGContextSetFillColorWithColor(ctx, epsBackColor.CGColor);
        //可以替换为 [epsBackColor setFill];
        
        UIRectFill(originRect);//真正的填充
        
        //设置椭圆变形区域。
        CGContextAddEllipseInRect(ctx,desRect);
        CGContextClip(ctx);//截取椭圆区域。
        
        [originImage drawInRect:originRect];//将图像画在目标区域。
        
        // 边框 //
        if (isSelected) {
            
            if (borderWidth <=0) {
                borderWidth = 0.5;
            }
            if (!borderColor) {
                borderColor = CDZColorOfWhite;
            }
            
            CGContextSetStrokeColorWithColor(ctx, borderColor.CGColor);//设置边框颜色
            //可以替换为 [CDZColorOfWhite setFill];
            
            CGContextSetLineCap(ctx, kCGLineCapButt);
            CGContextSetLineWidth(ctx, borderWidth);//设置边框宽度。
            CGContextAddEllipseInRect(ctx, desRect);//在这个框中画圆
            CGContextStrokePath(ctx); // 描边框。
            
        }    // 边框 //
        UIImage *returnImage = UIGraphicsGetImageFromCurrentImageContext();// 获取当前图形上下文中的图像。
        
        UIGraphicsEndImageContext();
        
        return returnImage;
    }
    
}

+ (UIImage *)getCircleImage:(UIImage *)originImage
                  setborder:(BOOL)isSelected
            borderWithColor:(UIColor *)borderColor
                borderWidth:(CGFloat)borderWidth {
    @autoreleasepool {
        
        CGFloat padding = 0;//圆形图像距离图像的边距
        UIColor* epsBackColor = [UIColor clearColor];        //图像的背景色
        CGSize imageSize = originImage.size;
        if (originImage.scale > 1) {
            imageSize = CGSizeMake(originImage.size.width*originImage.scale, originImage.size.height*originImage.scale);
        }
        CGRect originRect = CGRectMake(0, 0, imageSize.width, imageSize.height);
        
        
        UIGraphicsBeginImageContext(imageSize);
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        
        //目标区域。
        CGRect desRect =  CGRectMake(padding, padding,imageSize.width-(padding*2), imageSize.height-(padding*2));
        
        //设置填充背景色。
        CGContextSetFillColorWithColor(ctx, epsBackColor.CGColor);
        //可以替换为 [epsBackColor setFill];
        
        UIRectFill(originRect);//真正的填充
        
        //设置椭圆变形区域。
        CGContextAddEllipseInRect(ctx,desRect);
        CGContextClip(ctx);//截取椭圆区域。
        
        [originImage drawInRect:originRect];//将图像画在目标区域。
        
        // 边框 //
        if (isSelected) {
            
            if (borderWidth <=0) {
                borderWidth = 6;
            }
            if (!borderColor) {
                borderColor = CDZColorOfWhite;
            }
            
            CGContextSetStrokeColorWithColor(ctx, borderColor.CGColor);//设置边框颜色
            //可以替换为 [CDZColorOfWhite setFill];
            
            CGContextSetLineCap(ctx, kCGLineCapButt);
            CGContextSetLineWidth(ctx, borderWidth);//设置边框宽度。
            CGContextAddEllipseInRect(ctx, desRect);//在这个框中画圆
            CGContextStrokePath(ctx); // 描边框。
            
        }    // 边框 //
        UIImage *returnImage = UIGraphicsGetImageFromCurrentImageContext();// 获取当前图形上下文中的图像。
        
        UIGraphicsEndImageContext();
        
        return returnImage;
    }
    
}


@end
