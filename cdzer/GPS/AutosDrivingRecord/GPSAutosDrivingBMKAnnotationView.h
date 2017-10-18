//
//  GPSAutosDrivingBMKAnnotationView.h
//  cdzer
//
//  Created by KEns0nLau on 6/23/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import "GPSAutosDrivingPathInfoView.h"
#import "PositionDto.h"

@interface GPSAutosDrivingBMKAnnotationView : BMKAnnotationView

- (void)updateCurrentCarPosition:(PositionDto *)carPosition autosHeadingDegree:(CGFloat)headingDegree andWasLastPoint:(BOOL)waslastPoint;


@end
