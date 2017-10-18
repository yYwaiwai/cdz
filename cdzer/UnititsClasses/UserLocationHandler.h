//
//  UserLocationHandler.h
//  cdzer
//
//  Created by KEns0n on 7/9/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//
@class KeyCityDTO;
#import <Foundation/Foundation.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>

typedef void (^ULHUserLocationResultBlock)(BMKUserLocation *userLocation, NSError *error);
typedef void (^ULHReverseGeoCodeSearchResultBlock)(BMKReverseGeoCodeResult *result, BMKSearchErrorCode error);
typedef void (^ULHGeoCodeSearchResultBlock)(BMKGeoCodeResult *result, BMKSearchErrorCode error);
typedef void (^ULHCityListResultBlock)(NSArray *resultList, NSError *error);

@interface UserLocationHandler : NSObject

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

+ (UserLocationHandler *)shareInstance;

- (void)startUserLocationServiceWithBlock:(ULHUserLocationResultBlock)block;

- (void)stopUserLocationService;

- (void)reverseGeoCodeSearchWithCoordinate:(CLLocationCoordinate2D)coordinate resultBlock:(ULHReverseGeoCodeSearchResultBlock)block;

- (void)geoCodeSearchWithAddress:(NSString *)address andCity:(NSString *)city resultBlock:(ULHGeoCodeSearchResultBlock)block;

+ (KeyCityDTO *)getKeyCity;

+ (BOOL)updateKeyCity:(KeyCityDTO *)city;

+ (void)getCityList:(ULHCityListResultBlock)resultBlock;

+ (void)checkSelectedKeyCity:(void (^)(KeyCityDTO *selectedCity))completion;
@end
