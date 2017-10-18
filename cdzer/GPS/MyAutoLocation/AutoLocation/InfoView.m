//
//  InfoView.m
//  cdzer
//
//  Created by KEns0n on 5/26/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//
#define K_GSM_TEXT      @"GSM信号：暂无"
#define K_GSM_WEAK      @"GSM信号：弱"
#define K_GSM_GOOD      @"GSM信号：良"
#define K_GSM_PERFECT   @"GSM信号：好"

#define K_GPS_NO_OPEN   @"GPS信号：暂无"
#define K_GPS_NO        @"GPS信号：无"
#define K_GPS_WEAK      @"GPS信号：弱"
#define K_GPS_GOOD      @"GPS信号：良"
#define K_GPS_PERFECT   @"GPS信号：好"

#define kPositionLocating @"正在获取位置..."

#define vLabelTag 110
#define minHeight vAdjustByScreenRatio(102.0f)
#import "InfoView.h"
#import "InsetsLabel.h"

@interface InfoView ()

@property (nonatomic, strong) InsetsLabel *milesLabel;
@property (nonatomic, strong) InsetsLabel *dateTimeLabel;
@property (nonatomic, strong) InsetsLabel *gpsSignalLabel;
@property (nonatomic, strong) InsetsLabel *gsmSignalLabel;
@property (nonatomic, strong) InsetsLabel *localtionLabel;

@end

@implementation InfoView
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
                self.milesLabel = dataLabel;
                imageName = @"ic_map_car_speed@2x";
                break;
                
            case 1:
                self.dateTimeLabel = dataLabel;
                imageName = @"ic_map_car_time@2x";
                rect.origin.x -= 6;
                rect.size.width +=6;
                break;
                
            case 2:
                self.gpsSignalLabel = dataLabel;
                imageName = @"ic_mycar_position_signal@2x";
                break;
                
            case 3:
                self.gsmSignalLabel = dataLabel;
                imageName = @"ic_mycar_infobox_gsm@2x";
                rect.origin.x -= 6;
                rect.size.width +=6;
                break;
                
            case 4:
                self.localtionLabel = dataLabel;
                imageName = @"ic_map_car_position@2x";
                insetValue.right = vAdjustByScreenRatio(10.0);
                rect.size.width = CGRectGetWidth(self.frame);
                break;
            default:
                break;
        }
        UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:imageName ofType:@"png"]];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(vAdjustByScreenRatio(6.0f),
                                                                              (CGRectGetHeight(rect)-image.size.width)/2.0f,
                                                                              image.size.width,
                                                                               image.size.height)];
        [imageView setImage:image];
        [dataLabel addSubview:imageView];
        insetValue.left = CGRectGetMaxX(imageView.frame)+vAdjustByScreenRatio(6.0f);
        
        dataLabel.tag = identID+vLabelTag;
        dataLabel.frame = rect;
        dataLabel.edgeInsets = insetValue;
        dataLabel.font = systemFontBoldWithoutRatio(14.0f);
        dataLabel.text = @"--";
        dataLabel.textColor = CDZColorOfBlack;
        [self addSubview:dataLabel];
        [dataLabel setViewBorderWithRectBorder:UIRectBorderBottom borderSize:1.0f withColor:CDZColorOfGray withBroderOffset:nil];
    }
}

- (void)initializationUI {
    for (int i=0; i<5; i++) {
        [self labelInitialWithImageByID:i];
    }
    [self setAutoLocaleInfoWithMilesString:@"0.0" dateTime:@"2015-01-01 00:00:00"
                                 gpsSignal:nil gsmSignal:nil localtion:kPositionLocating];
}

- (void)setAutoLocaleInfoWithMilesString:(NSString *)milesString dateTime:(NSString *)dateTime
                               gpsSignal:(NSString *)gpsSignal gsmSignal:(NSString *)gsmSignal
                               localtion:(NSString *)localtion {
    
    if (milesString) {
        _milesLabel.text = [NSString stringWithFormat:@"%.1fKM/S", milesString.floatValue];
    }
    if (dateTime) {
        _dateTimeLabel.text = dateTime;
    }
    
    if (gpsSignal) {
        NSString *gpsSignalString = K_GPS_NO_OPEN;
        if (gpsSignal && ![@"" isEqualToString:gpsSignal]) {
            CGFloat num = [gpsSignal intValue];
            if (num<3) {
                gpsSignalString = K_GPS_NO;
            }else if(num>=3 && num<5){
                gpsSignalString = K_GPS_WEAK;
            }else if(num>=5 && num<10){
                gpsSignalString = K_GPS_GOOD;
            }else if(num>=10 && num<12){
                gpsSignalString = K_GPS_PERFECT;
            }
        }
        _gpsSignalLabel.text = gpsSignalString;
    }
    if (gsmSignal) {
        NSString *gsmSignalString = K_GSM_TEXT;
        
        if (gsmSignal && ![@"" isEqualToString:gsmSignal]) {
            CGFloat num = [gsmSignal floatValue];
            if (num<2) {
                gsmSignalString = K_GSM_WEAK;
            }else if(num>=2 && num<31){
                gsmSignalString = K_GSM_GOOD;
            }else if(num>=31 && num<99){
                gsmSignalString = K_GSM_PERFECT;
            }else if(num>=99){
                gsmSignalString = K_GSM_TEXT;
            }
        }
        _gsmSignalLabel.text = gsmSignalString;
    }
    
    if (localtion) {
        _localtionLabel.text = localtion;
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
