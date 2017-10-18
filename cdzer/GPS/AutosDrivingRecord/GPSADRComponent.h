//
//  GPSADRComponent.h
//  cdzer
//
//  Created by KEns0nLau on 6/24/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void (^GPSADRDRSResponseBlock)(NSString *startDateTime, NSString *endDateTime);

@interface GPSADRDateTimeSelectionView : UIView

@property (nonatomic, copy) GPSADRDRSResponseBlock responseBlock;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic, strong, readonly) NSDate *startDateTime;

@property (nonatomic, strong, readonly) NSDate *endDateTime;

@end
