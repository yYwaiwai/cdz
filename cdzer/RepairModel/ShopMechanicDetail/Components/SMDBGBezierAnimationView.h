//
//  SMDBGBezierAnimationView.h
//  cdzer
//
//  Created by KEns0n on 18/11/2016.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SMDBGBezierAnimationView : UIView

@property (nonatomic, weak) UIScrollView *scrollView;

@property (nonatomic, strong) UIColor *firstWaveColor;    // 第一个波浪颜色
@property (nonatomic, strong) UIColor *secondWaveColor;   // 第二个波浪颜色

- (void)startWave;

- (void)stopWave;

- (void)reset;

@end
