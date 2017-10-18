//
//  UIImage+retateByDegress.h
//  HouseExhibits
//
//  Created by Alex on 13-3-28.
//  Copyright (c) 2013年 zciot. All rights reserved.
//

#import <UIKit/UIKit.h>
enum SvCropMode{
    enSvCropClip,               // the image size will be equal to orignal image, some part of image may be cliped
    enSvCropExpand,             // the image size will expand to contain the whole image, remain area will be transparent
};
typedef enum SvCropMode SvCropMode;
@interface UIImage(rotatedByDegrees)

#pragma mark - UIImage 按方向的度数旋转图片
- (UIImage*)imageRotatedByDegrees:(CGFloat)degrees;

- (UIImage*)rotateImageWithRadian:(CGFloat)radian cropMode:(SvCropMode)cropMode;
#pragma mark - UIImage 拉伸图片
+(UIImage *) stretchiOS6:(NSString *)icon;
// @property (nonatomic) BOOL isRetina;

@end
