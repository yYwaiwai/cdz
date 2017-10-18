//
//  UserLocateView.h
//  cdzer
//
//  Created by KEns0n on 7/10/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserLocateView : UIView

@property (nonatomic, readonly) BOOL isUpdated;

@property (nonatomic, readonly) BOOL isUpdating;

@property (nonatomic, readonly) BOOL isLocateSuccess;

@property (nonatomic, readonly) NSString *currentCity;

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

- (void)startUserLocation;

- (void)stopUserLocation;

@end
