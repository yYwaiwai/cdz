//
//  DrivingRecordInfoView.m
//  cdzer
//
//  Created by KEns0n on 5/26/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#define kPositionLocating @"正在获取位置..."
#define YDIMG(__name) [UIImage imageNamed:__name]
#define vLabelTag 110
#define minHeight vAdjustByScreenRatio(102.0f)
#import "DrivingRecordInfoView.h"
#import "UIView+Borders.h"
#import "InsetsLabel.h"
#import "YDSlider.h"

@interface DrivingRecordInfoView ()
@property (nonatomic, strong) InsetsLabel *startTimeLabel;
@property (nonatomic, strong) InsetsLabel *endTimeLabel;

@property (nonatomic, strong) InsetsLabel *milesLabel;
@property (nonatomic, strong) InsetsLabel *dateTimeLabel;
@property (nonatomic, strong) InsetsLabel *localtionLabel;

@property (nonatomic, strong) YDSlider *timeSlider;

@property (nonatomic, copy) DRISliderValueBlock valueBlock;

@end

@implementation DrivingRecordInfoView

- (instancetype)initWithFrame:(CGRect)frame {
    if (CGRectEqualToRect(frame, CGRectZero)) {
        frame.size = CGSizeMake(SCREEN_WIDTH, minHeight);
    }
    if (frame.size.height<minHeight) {
        frame.size.height = minHeight;
    }
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.shadowOffset = CGSizeMake(-2, 6);
        self.layer.shadowRadius = 5;
        self.layer.shadowOpacity = 0.6;
        self.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.8f];
        [self initializationUI];
    }
    return self;
}

- (instancetype)init {
    self = [self initWithFrame:CGRectZero];
    if (self) {
    }
    return self;
}

#pragma makr- LabelSetting
- (void)labelInitialWithImageByID:(NSInteger)identID {
    @autoreleasepool {
        NSString *imageName = nil;
        UIEdgeInsets insetValue = UIEdgeInsetsZero;
        
        NSInteger row = identID/2;
        NSInteger column = identID%2;
        
        CGRect rect = CGRectZero;
        rect.size = CGSizeMake(CGRectGetWidth(self.frame)/2, vAdjustByScreenRatio(34.0f));
        rect.origin.x = column*CGRectGetWidth(rect);
        rect.origin.y = row*CGRectGetHeight(rect);
        
        InsetsLabel *dataLabel = [InsetsLabel new];
        switch (identID) {
            case 0:
                self.startTimeLabel = dataLabel;
                insetValue.left = vAdjustByScreenRatio(8.0f);
                rect.size.width = CGRectGetWidth(self.frame);
                break;
                
            case 1:
                self.endTimeLabel = dataLabel;
                dataLabel.textAlignment = NSTextAlignmentRight;
                insetValue.right = vAdjustByScreenRatio(8.0f);
                rect.size.width = CGRectGetWidth(self.frame);
                rect.origin.x = 0.0f;
                break;
                
            case 2:
                self.milesLabel = dataLabel;
                imageName = @"ic_map_car_speed@2x";
                break;
                
            case 3:
                self.dateTimeLabel = dataLabel;
                imageName = @"ic_map_car_time@2x";
                rect.origin.x -= vAdjustByScreenRatio(12.0)*2.0f;
                rect.size.width +=vAdjustByScreenRatio(12.0)*2.0f;
                insetValue.right = vAdjustByScreenRatio(8.0f);
                dataLabel.textAlignment = NSTextAlignmentRight;
                break;
                
            case 4:
                self.localtionLabel = dataLabel;
                imageName = @"ic_map_car_position@2x";
                insetValue.right = vAdjustByScreenRatio(8.0);
                rect.size.width = CGRectGetWidth(self.frame);
                break;
            default:
                break;
        }
        if (imageName) {
            UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:imageName ofType:@"png"]];
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(vAdjustByScreenRatio(8.0f),
                                                                                   (CGRectGetHeight(rect)-image.size.width)/2.0f,
                                                                                   image.size.width,
                                                                                   image.size.height)];
            [imageView setImage:image];
            [dataLabel addSubview:imageView];
            insetValue.left = CGRectGetMaxX(imageView.frame)+vAdjustByScreenRatio(8.0f);
        }
        
        dataLabel.tag = identID+vLabelTag;
        dataLabel.frame = rect;
        dataLabel.edgeInsets = insetValue;
        dataLabel.font = systemFontBoldWithoutRatio(14.0f);
        dataLabel.text = @"--";
        dataLabel.textColor = CDZColorOfBlack;
        [self addSubview:dataLabel];
        [dataLabel addBottomBorderWithHeight:1.0f andColor:CDZColorOfGray];
    }
}

- (void)initializationUI {
    
    for (int i=0; i<5; i++) {
        [self labelInitialWithImageByID:i];
    }
    [self setAutoLocaleInfoWithMilesString:@"0.0" dateTime:@"2015-01-01 00:00:00"
                                 startTime:@"00:00" endTime:@"01:00" localtion:kPositionLocating];
    
    self.timeSlider = [[YDSlider alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.frame)*0.6875, CGRectGetHeight(_endTimeLabel.frame))];
    self.timeSlider.center = CGPointMake(CGRectGetWidth(self.frame)/2.0f, _timeSlider.center.y);
    _timeSlider.value = 0.0;
    [_timeSlider setThumbImage:YDIMG(@"player-progress-point") forState:UIControlStateNormal];
    [_timeSlider setThumbImage:YDIMG(@"player-progress-point-h") forState:UIControlStateHighlighted];
    
    _timeSlider.minimumTrackTintColor = CDZColorOfDefaultColor;
//    [_timeSlider setMinimumTrackImage:[YDIMG(@"player-progress-h") resizableImageWithCapInsets:UIEdgeInsetsMake(4, 3, 5, 4) resizingMode:UIImageResizingModeStretch]];
//    [_timeSlider setMiddleTrackImage:[YDIMG(@"player-progress-loading") resizableImageWithCapInsets:UIEdgeInsetsMake(4, 3, 5, 4) resizingMode:UIImageResizingModeStretch]];
    [_timeSlider setMaximumTrackImage:[YDIMG(@"player-progress") resizableImageWithCapInsets:UIEdgeInsetsMake(4, 3, 5, 4) resizingMode:UIImageResizingModeStretch]];
    [_timeSlider addTarget:self action:@selector(onSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:_timeSlider];
}

- (void)setAutoLocaleInfoWithMilesString:(NSString *)milesString dateTime:(NSString *)dateTime
                               startTime:(NSString *)startTime endTime:(NSString *)endTime
                               localtion:(NSString *)localtion {
    
    
    if (startTime) {
        _startTimeLabel.text = startTime;
    }
    
    if (endTime) {
        _endTimeLabel.text = endTime;
    }
    
    if (milesString) {
        _milesLabel.text = [NSString stringWithFormat:@"%.1fKM/S", milesString.floatValue];
    }
    if (dateTime) {
        _dateTimeLabel.text = dateTime;
    }
    
    if (localtion) {
        _localtionLabel.text = localtion;
    }else if([localtion isEqualToString:@""]){
        _localtionLabel.text = kPositionLocating;
    }
}

- (void)setSliderResponseBlock:(DRISliderValueBlock)block {
    if (block) {
        self.valueBlock = block;
    }
}

- (void)setSliderValue:(CGFloat)value {
    if (value<=1&&value>=0) {
        self.timeSlider.value = value;
    }
}

- (CGFloat)sliderValue {
    return self.timeSlider.value;
}

- (void)onSliderValueChanged:(YDSlider* )slider {
    if (self.valueBlock) {
        self.valueBlock(slider,slider.value);
    }
}

- (void)releaseInternalObjects {
    [_timeSlider removeFromSuperview];
    [_timeSlider removeTarget:self action:@selector(setSliderResponseBlock:) forControlEvents:UIControlEventTouchUpInside];
    _timeSlider = nil;
}

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
