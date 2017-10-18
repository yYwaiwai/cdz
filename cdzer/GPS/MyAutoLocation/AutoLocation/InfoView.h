//
//  InfoView.h
//  cdzer
//
//  Created by KEns0n on 5/26/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InfoView : UIView

- (void)setAutoLocaleInfoWithMilesString:(NSString *)milesString dateTime:(NSString *)dateTime
                               gpsSignal:(NSString *)gpsSignal gsmSignal:(NSString *)gsmSignal
                               localtion:(NSString *)localtion ;

@end
