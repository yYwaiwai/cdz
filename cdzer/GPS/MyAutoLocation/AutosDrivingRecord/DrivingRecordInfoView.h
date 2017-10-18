//
//  DrivingRecordInfoView.h
//  cdzer
//
//  Created by KEns0n on 5/26/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YDSlider;
typedef void (^DRISliderValueBlock)(YDSlider *timeSlider, CGFloat value);

@interface DrivingRecordInfoView : UIView

@property (nonatomic, assign) CGFloat sliderValue;

- (void)releaseInternalObjects;

- (void)setAutoLocaleInfoWithMilesString:(NSString *)milesString dateTime:(NSString *)dateTime
                               startTime:(NSString *)startTime endTime:(NSString *)endTime
                               localtion:(NSString *)localtion;

- (void)setSliderResponseBlock:(DRISliderValueBlock)block;

@end
