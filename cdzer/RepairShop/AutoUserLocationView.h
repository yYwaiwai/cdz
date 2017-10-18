//
//  AutoUserLocationView.h
//  cdzer
//
//  Created by KEns0n on 9/9/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

@class KeyCityDTO;
#import <UIKit/UIKit.h>

@interface AutoUserLocationView : UIView

@property (nonatomic, readonly) BOOL isUpdated;

@property (nonatomic, readonly) BOOL isUpdating;

@property (nonatomic, readonly) BOOL isLocateSuccess;

@property (nonatomic, readonly) KeyCityDTO *selectedCity;

@property (nonatomic, readonly) NSString *currentCity;

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

- (void)updateSelectedCity:(KeyCityDTO *)selectedCity;

- (void)buttonAddTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;

- (void)startUserLocation;

- (void)stopUserLocation;


@end
