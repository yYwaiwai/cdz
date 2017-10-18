//
//  AnimationHandler.h
//  cdzer
//
//  Created by KEns0n on 3/16/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AnimationHandler : NSObject

+ (void)makeBarChartAnimationWithView:(UIView *)view totalCount:(CGFloat)totalCount currentCount:(CGFloat)currentCount;
@end
