//
//  GPSAutosCurrentInfoView.m
//  cdzer
//
//  Created by KEns0nLau on 6/23/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#define k_car_staOn 0    //在线
#define k_car_staOff 1   //熄火
#define k_car_staOver 2  //离线
#define k_car_staNo 3    //无信号

#define K_GSM_TEXT      @"暂无"
#define K_GSM_WEAK      @"弱"
#define K_GSM_GOOD      @"良"
#define K_GSM_PERFECT   @"好"

#define K_GPS_NO_OPEN   @"暂无"
#define K_GPS_NO        @"无"
#define K_GPS_WEAK      @"弱"
#define K_GPS_GOOD      @"良"
#define K_GPS_PERFECT   @"好"

#define kPositionLocating @"正在获取位置..."

#import "GPSAutosCurrentInfoView.h"
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>

@interface GPSAutosCurrentInfoView () <BMKGeoCodeSearchDelegate>

@property (nonatomic, weak) IBOutlet UILabel *dateTimeLabel;

@property (nonatomic, weak) IBOutlet UILabel *milesLabel;

@property (nonatomic, weak) IBOutlet UILabel *GPSSignalLabel;

@property (nonatomic, weak) IBOutlet UILabel *GSMSignalLabel;

@property (nonatomic, weak) IBOutlet UILabel *addressLabel;

@property (nonatomic, weak) IBOutlet UIButton *autosStatusLabel;

@property (nonatomic, strong) BMKGeoCodeSearch *geoSearcher;

@end

@implementation GPSAutosCurrentInfoView

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
    [NSNotificationCenter.defaultCenter removeObserver:self];
    self.geoSearcher.delegate = nil;
    self.geoSearcher = nil;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAutosLabelUIInfo) name:CDZNotiKeyOfUpdateAutoGPSInfo object:nil];
    self.geoSearcher = [[BMKGeoCodeSearch alloc] init];
    self.geoSearcher.delegate = self;
}

- (void)updateAutosLabelUIInfo {
    @autoreleasepool {
        NSDictionary * autoGPSDetail = [[DBHandler shareInstance] getAutoRealtimeDataWithDataID:1];

        NSString *milesString = [SupportingClass verifyAndConvertDataToString:autoGPSDetail[@"speed"]];
        NSString *dateTime = [SupportingClass verifyAndConvertDataToString:autoGPSDetail[@"time"]];
        NSString *gpsSignal = [SupportingClass verifyAndConvertDataToString:autoGPSDetail[@"gpsNum"]];
        NSString *gsmSignal = [SupportingClass verifyAndConvertDataToString:autoGPSDetail[@"gsm"]];
        NSNumber *accStatus = [SupportingClass verifyAndConvertDataToNumber:autoGPSDetail[@"acc"]];
        
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = [autoGPSDetail[@"lat"] doubleValue];
        coordinate.longitude = [autoGPSDetail[@"lon"] doubleValue];

//        self.addressLabel.text = kPositionLocating;
        
        BMKReverseGeoCodeOption *reverseGeoOption = [[BMKReverseGeoCodeOption alloc] init];
        reverseGeoOption.reverseGeoPoint = coordinate;
        [_geoSearcher reverseGeoCode:reverseGeoOption];
        
        if (milesString) {
            self.milesLabel.text = [NSString stringWithFormat:@"%.1fKM/S", milesString.floatValue];
        }
        if (dateTime) {
            self.dateTimeLabel.text = dateTime;
        }
        
        NSString *gpsSignalString = K_GPS_NO_OPEN;
        if (gpsSignal) {
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
        }
        self.GPSSignalLabel.text = gpsSignalString;
        
        NSString *gsmSignalString = K_GSM_TEXT;
        if (gsmSignal) {
            
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
        }
        self.GSMSignalLabel.text = gsmSignalString;
        self.autosStatusLabel.enabled = NO;
        self.autosStatusLabel.selected = NO;
        
        if (k_car_staOn==accStatus.integerValue) {
            self.autosStatusLabel.enabled = YES;
            self.autosStatusLabel.selected = NO;
        }
        
        if (k_car_staOff==accStatus.integerValue) {
            self.autosStatusLabel.enabled = YES;
            self.autosStatusLabel.selected = YES;
        }
            
    }
}
#pragma mark BMKGeoCodeSearchDelegate
/**
 *返回反地理编码搜索结果
 *@param searcher 搜索对象
 *@param result 搜索结果
 *@param error 错误号，@see BMKSearchErrorCode
 */
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error {
    self.addressLabel.text = result.address;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    UIEdgeInsets rectangleEdgeOffset = UIEdgeInsetsMake(3, 3, 55, 3);
    CGFloat centerXAxisPoint = CGRectGetWidth(rect)/2.0f;
    CGFloat rectangleHeight = CGRectGetHeight(rect)-rectangleEdgeOffset.top-rectangleEdgeOffset.bottom;
    CGFloat rectangleWidth = CGRectGetWidth(rect)-rectangleEdgeOffset.left-rectangleEdgeOffset.right;
    //// General Declarations
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    
    //// Color Declarations
    UIColor* color = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];
    UIColor* color2 = [UIColor colorWithRed: 0.839 green: 0.843 blue: 0.863 alpha: 1];
    UIColor* color3 = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];
    
    //// Shadow Declarations
    NSShadow* shadow = [[NSShadow alloc] init];
    [shadow setShadowColor: [UIColor.blackColor colorWithAlphaComponent: 0.49]];
    [shadow setShadowOffset: CGSizeMake(0.1, -0.1)];
    [shadow setShadowBlurRadius: 3];
    NSShadow* shadowArrow = [[NSShadow alloc] init];
    [shadowArrow setShadowColor: UIColor.blackColor];
    [shadowArrow setShadowOffset: CGSizeMake(0.1, -0.1)];
    [shadowArrow setShadowBlurRadius: 3];
    
    
    
    //// triangle With Shadows Drawing
    
    CGRect triangleFrame = CGRectZero;
    triangleFrame.size.width = 26.0f;
    triangleFrame.size.height = 14.0f;
    triangleFrame.origin = CGPointMake(centerXAxisPoint-CGRectGetWidth(triangleFrame)/2.0f,
                                      rectangleEdgeOffset.top+rectangleHeight);
    UIBezierPath* triangleWithShadowsPath = [UIBezierPath bezierPath];
    [triangleWithShadowsPath moveToPoint: triangleFrame.origin];
    [triangleWithShadowsPath addLineToPoint: CGPointMake(CGRectGetMaxX(triangleFrame),
                                                         CGRectGetMinY(triangleFrame))];
    [triangleWithShadowsPath addLineToPoint: CGPointMake(centerXAxisPoint,
                                                         CGRectGetMaxY(triangleFrame))];
    [triangleWithShadowsPath addLineToPoint: triangleFrame.origin];
    [triangleWithShadowsPath closePath];
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, shadowArrow.shadowOffset, shadowArrow.shadowBlurRadius, [shadowArrow.shadowColor CGColor]);
    [color3 setFill];
    [triangleWithShadowsPath fill];
    CGContextRestoreGState(context);
    
    
    
    //// Rectangle Drawing
    UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(rectangleEdgeOffset.left,
                                                                                      rectangleEdgeOffset.top,
                                                                                      rectangleWidth,
                                                                                      rectangleHeight)
                                                             cornerRadius: 5];
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, shadow.shadowOffset, shadow.shadowBlurRadius, [shadow.shadowColor CGColor]);
    [color setFill];
    [rectanglePath fill];
    CGContextRestoreGState(context);
    
    
    
    //// triangle Drawing
    UIBezierPath* trianglePath = [UIBezierPath bezierPath];
    trianglePath.CGPath = triangleWithShadowsPath.CGPath;
    [color3 setFill];
    [trianglePath fill];
    
    
    CGFloat averageHeight = rectangleHeight/4.0f;
    UIBezierPath* lineStrokePath = [UIBezierPath bezierPath];
    //// line1 Drawing
    [lineStrokePath moveToPoint: CGPointMake(rectangleEdgeOffset.left,
                                             averageHeight+rectangleEdgeOffset.top)];
    [lineStrokePath addLineToPoint: CGPointMake(rectangleEdgeOffset.left+rectangleWidth,
                                                averageHeight+rectangleEdgeOffset.top)];
    
    //// line2 Drawing
    [lineStrokePath moveToPoint: CGPointMake(rectangleEdgeOffset.left,
                                             averageHeight*2+rectangleEdgeOffset.top)];
    [lineStrokePath addLineToPoint: CGPointMake(rectangleEdgeOffset.left+rectangleWidth,
                                                averageHeight*2+rectangleEdgeOffset.top)];
    
    //// line3 Drawing
    [lineStrokePath moveToPoint: CGPointMake(rectangleEdgeOffset.left,
                                             averageHeight*3+rectangleEdgeOffset.top)];
    [lineStrokePath addLineToPoint: CGPointMake(rectangleEdgeOffset.left+rectangleWidth,
                                                averageHeight*3+rectangleEdgeOffset.top)];
    
    //// Centerline Drawing
    [lineStrokePath moveToPoint: CGPointMake(centerXAxisPoint,
                                             averageHeight+rectangleEdgeOffset.top)];
    [lineStrokePath addLineToPoint: CGPointMake(centerXAxisPoint,
                                                averageHeight*3+rectangleEdgeOffset.top)];
    
    [color2 setStroke];
    lineStrokePath.lineWidth = 0.5;
    [lineStrokePath stroke];


}



@end
