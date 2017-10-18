//
//  GPSAutosDrivingPathInfoView.h
//  cdzer
//
//  Created by KEns0nLau on 6/23/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PositionDto.h"

@interface GPSAutosDrivingPathInfoView : UIView

- (void)updateCurrentCarPosition:(PositionDto *)carPosition autosHeadingDegree:(CGFloat)headingDegree andWasLastPoint:(BOOL)waslastPoint;;

@end
