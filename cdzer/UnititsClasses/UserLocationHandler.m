//
//  UserLocationHandler.m
//  cdzer
//
//  Created by KEns0n on 7/9/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//
#import "KeyCityDTO.h"
#import "UserLocationHandler.h"
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <GPXParser/GPXParser.h>

@interface UserLocationHandler ()<BMKLocationServiceDelegate, BMKGeoCodeSearchDelegate>

@property (nonatomic, strong) BMKLocationService *locService;

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@property (nonatomic, copy) ULHUserLocationResultBlock locationResultBlock;

@property (nonatomic, copy) ULHGeoCodeSearchResultBlock geoCodeSearchResult;

@property (nonatomic, copy) ULHReverseGeoCodeSearchResultBlock reverseGeoCodeSearchResult;


@end

@implementation UserLocationHandler
static UserLocationHandler *_userLocationInstance  = nil;

+ (UserLocationHandler *)shareInstance {
    
    if (!_userLocationInstance) {
        _userLocationInstance = [UserLocationHandler new];
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"lastLocation"]) {
            NSArray *coordinateArray = [[[NSUserDefaults standardUserDefaults] objectForKey:@"lastLocation"] componentsSeparatedByString:@","];
            _userLocationInstance.coordinate = CLLocationCoordinate2DMake([coordinateArray[0] doubleValue], [coordinateArray[1] doubleValue]);
        }else {
            
            @autoreleasepool {
                NSData *fileData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Changsha_China" ofType:@"gpx"]];
                [GPXParser parse:fileData completion:^(BOOL success, GPX *gpx) {
                    if (success) {
                        Waypoint *wayPoint = gpx.waypoints[0];
                        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@,%@",
                                                                          [NSDecimalNumber numberWithDouble:wayPoint.coordinate.latitude],
                                                                          [NSDecimalNumber numberWithDouble:wayPoint.coordinate.longitude]]
                                                                  forKey:@"lastLocation"];
                        _userLocationInstance.coordinate = wayPoint.coordinate;
                    }
                }];
            }
            
        }
        
        
        if (!_userLocationInstance->_locService) {
            _userLocationInstance->_locService = [[BMKLocationService alloc] init];
            //设置定位精确度，默认：kCLLocationAccuracyBest
            _userLocationInstance->_locService.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
            //指定最小距离更新(米)，默认：kCLDistanceFilterNone
            _userLocationInstance->_locService.distanceFilter = 100.0f;
        }
    }
    return _userLocationInstance;
}

- (void)startUserLocationServiceWithBlock:(ULHUserLocationResultBlock)block {
    if ([CLLocationManager authorizationStatus]!=kCLAuthorizationStatusDenied&&[CLLocationManager authorizationStatus]!=kCLAuthorizationStatusRestricted) {
        _locService.delegate = self;
        _locationResultBlock = nil;
        _locationResultBlock = block;
        [_locService startUserLocationService];
    }else {
        block(nil, [NSError errorWithDomain:@"无法定位！" code:-1000 userInfo:nil]);
        [SupportingClass showAlertViewWithTitle:@"alert_remind" message:@"无法定位！定位限制设置已开启。\n请在“设置”-“隐私”-“位置”-“车队站”里面开启。" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:nil];
    }
}

- (void)stopUserLocationService {
    [_locService stopUserLocationService];
    _locService.delegate = nil;
    _locationResultBlock = nil;
}

- (void)reverseGeoCodeSearchWithCoordinate:(CLLocationCoordinate2D)coordinate resultBlock:(ULHReverseGeoCodeSearchResultBlock)block {
    @autoreleasepool {
        _reverseGeoCodeSearchResult = nil;
        _reverseGeoCodeSearchResult = block;
        BMKGeoCodeSearch *geoSearcher = [[BMKGeoCodeSearch alloc] init];
        geoSearcher.delegate = self;
        BMKReverseGeoCodeOption *reverseGeoOption = [[BMKReverseGeoCodeOption alloc] init];
        reverseGeoOption.reverseGeoPoint = coordinate;
        BOOL isReady = [geoSearcher reverseGeoCode:reverseGeoOption];
        NSLog(@"is Ready to Reverse GeoCode Search %d", isReady);
    }
}

- (void)geoCodeSearchWithAddress:(NSString *)address andCity:(NSString *)city resultBlock:(ULHGeoCodeSearchResultBlock)block {
    @autoreleasepool {
        _geoCodeSearchResult = nil;
        _geoCodeSearchResult = block;
        BMKGeoCodeSearch *geoSearcher = [[BMKGeoCodeSearch alloc] init];
        geoSearcher.delegate = self;

        BMKGeoCodeSearchOption *geoOption = [[BMKGeoCodeSearchOption alloc] init];
        geoOption.address = address;
        geoOption.city = city;
        BOOL isReady = [geoSearcher geoCode:geoOption];
        NSLog(@"is Ready geoCodeSearch%d", isReady);
    }
    
}

#pragma mark- BMKLocationServiceDelegate
/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */

- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation {
    self.coordinate = userLocation.location.coordinate;
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@,%@",
                                                      [NSDecimalNumber numberWithDouble:self.coordinate.latitude],
                                                      [NSDecimalNumber numberWithDouble:self.coordinate.longitude]]
                                              forKey:@"lastLocation"];
    if (_locationResultBlock) {
        _locationResultBlock(userLocation, nil);
    }
}

/**
 *定位失败后，会调用此函数
 *@param error 错误号
 */
- (void)didFailToLocateUserWithError:(NSError *)error {
    if (_locationResultBlock) {
        _locationResultBlock(nil, error);
    }
}

#pragma mark- BMKGeoCodeSearchDelegate
/**
 *返回反地理编码搜索结果
 *@param searcher 搜索对象
 *@param result 搜索结果
 *@param error 错误号，@see BMKSearchErrorCode
 */

- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error {
    searcher.delegate = nil;
    searcher = nil;
    if (_reverseGeoCodeSearchResult) {
        _reverseGeoCodeSearchResult(result, error);
    }
    _reverseGeoCodeSearchResult = nil;
}

/**
 *返回地址信息搜索结果
 *@param searcher 搜索对象
 *@param result 搜索结BMKGeoCodeSearch果
 *@param error 错误号，@see BMKSearchErrorCode
 */
- (void)onGetGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error {
    searcher.delegate = nil;
    searcher = nil;
    if (_geoCodeSearchResult) {
        _geoCodeSearchResult(result, error);
    }
    _geoCodeSearchResult = nil;
}

+ (KeyCityDTO *)getKeyCity {
    return [FileManager unArchiveObjectWithArchiveKey:kSelectedCityArchiverKey
                                             rootType:FMRootFolderTypeOfCache
                                              subPath:kDataKeyedArchiverPath
                                              theFile:kSelectedCityArchiverKey
                                              extType:kArchiverKeyOfType];
}

+ (BOOL)updateKeyCity:(KeyCityDTO *)city {
    if (!city||!city.cityID||city.cityID.unsignedLongLongValue<=0||[city.cityName isEqualToString:@""]) {
        return NO;
    }
    return [FileManager archiveObjectWithObject:city
                                  andArchiveKey:kSelectedCityArchiverKey
                                       rootType:FMRootFolderTypeOfCache
                                        subPath:kDataKeyedArchiverPath
                                        theFile:kSelectedCityArchiverKey
                                        extType:kArchiverKeyOfType];
}

+ (void)getCityList:(ULHCityListResultBlock)resultBlock {
    NSArray *cityList = [DBHandler.shareInstance getKeyCityList];
    BOOL needUpdate = [DBHandler.shareInstance isDataNeedToUpdate:CDZDBUpdateListOfKeyCity];
    if (cityList.count==0||needUpdate) {
        [self updateCityList:^(NSArray *resultList, NSError *error) {
            resultBlock(resultList, error);
        }];
    }else {
        resultBlock(cityList, nil);
    }
    
}

+ (void)updateCityList:(ULHCityListResultBlock)resultBlock {
    
    [[APIsConnection shareConnection] commonAPIsGetCityListWithProvinceID:nil isKeyCity:YES success:^(NSURLSessionDataTask *operation, id responseObject) {
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        if (errorCode!=0) {
            NSError *error = [NSError errorWithDomain:message code:-00001 userInfo:nil];
            if (resultBlock) {
                resultBlock(nil, error);
            }
            return;
        }
        
        if (!responseObject||[responseObject count]==0) {
            NSError *error = [NSError errorWithDomain:@"data Error" code:-00001 userInfo:nil];
            if (resultBlock) {
                resultBlock(nil, error);
            }
            NSLog(@"data Error");
            return;
        }
        if (resultBlock) {
            NSArray *cityList = responseObject[CDZKeyOfResultKey];
            [UserLocationHandler performSelectorInBackground:@selector(backgroundUpdateCityList:) withObject:@[cityList, resultBlock]];
        }
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        if (resultBlock) {
            resultBlock(nil, error);
        }
    }];
    
}

+ (void)backgroundUpdateCityList:(NSArray *)argumentList {
    @autoreleasepool {
        NSArray *keyCityList = [KeyCityDTO handleDataListToDTOList:argumentList[0]];
        ULHCityListResultBlock resultBlock = argumentList[1];
        resultBlock(keyCityList, nil);
        [self performSelectorInBackground:@selector(backGroundUpdateCityKeyList:) withObject:keyCityList];
    }
}

+ (void)backGroundUpdateCityKeyList:(NSArray *)keyCityList {
    if ([DBHandler.shareInstance updateKeyCityList:keyCityList]) {
        NSDate *nowDate = [NSDate date];
        NSCalendar *gregorian = [NSCalendar currentCalendar];
        NSDateComponents *dateComponents = [gregorian components:(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute)
                                                        fromDate:nowDate];
        dateComponents.day +=3;
        NSDate *newDate = [gregorian dateFromComponents:dateComponents];
        [DBHandler.shareInstance updateDataNextUpdateDateTime:newDate table:CDZDBUpdateListOfKeyCity];
    }
    
}

+ (void)checkSelectedKeyCity:(void (^)(KeyCityDTO *selectedCity))completion {
    
    @autoreleasepool {
        [self getCityList:^(NSArray *resultList, NSError *error) {
            
            KeyCityDTO *selectedCity = self.getKeyCity;
            if (!selectedCity) {
                [UserLocationHandler.shareInstance startUserLocationServiceWithBlock:^(BMKUserLocation *userLocation, NSError *error) {
                    if (userLocation) {
                        [UserLocationHandler.shareInstance reverseGeoCodeSearchWithCoordinate:userLocation.location.coordinate resultBlock:^(BMKReverseGeoCodeResult *result, BMKSearchErrorCode error) {
                            if (result) {
                                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.cityName LIKE[cd] %@",result.addressDetail.city];
                                NSArray *listResult = [resultList filteredArrayUsingPredicate:predicate];
                                if (listResult.count>0) {
                                    KeyCityDTO *locatedCity = (KeyCityDTO *)listResult.lastObject;
                                    locatedCity.coordinate = userLocation.location.coordinate;
                                    locatedCity.isSelectFormPosition = YES;
                                    BOOL saveSuccess = [FileManager archiveObjectWithObject:locatedCity
                                                                              andArchiveKey:kSelectedCityArchiverKey
                                                                                   rootType:FMRootFolderTypeOfCache
                                                                                    subPath:kDataKeyedArchiverPath
                                                                                    theFile:kSelectedCityArchiverKey
                                                                                    extType:kArchiverKeyOfType];
                                    if (!saveSuccess) {
                                        [self setDefaultSelectedCityWithCityList:resultList withReturnBlock:completion];
                                        NSLog(@"can not save the location ");
                                        return;
                                    }
                                    if (completion) {
                                        completion(locatedCity);
                                    }
                                }else {
                                    [self setDefaultSelectedCityWithCityList:resultList withReturnBlock:completion];
                                    NSLog(@"can not found the city in list");
                                }
                                
                            }else {
                                [self setDefaultSelectedCityWithCityList:resultList withReturnBlock:completion];
                                NSLog(@"can not reverse geo code search");
                                
                            }
                        }];
                    }else {
                        [self setDefaultSelectedCityWithCityList:resultList withReturnBlock:completion];
                        NSLog(@"Location Error %@", error.domain);
                    }
                }];
            }
        }];
    }
}

+ (void)setDefaultSelectedCityWithCityList:(NSArray *)cityList withReturnBlock:(void (^)(KeyCityDTO *selectedCity))returnBlock  {
    @autoreleasepool {
        NSString *cityName = @"长沙";
        NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"SELF.cityName LIKE[cd] %@", cityName];
        NSArray *filterList = [cityList filteredArrayUsingPredicate:filterPredicate];
        if (filterList.count==0) {
            if (returnBlock) {
                returnBlock(nil);
            }
            NSLog(@"some error hsa been maked");
        }else {
            BOOL saveSuccess = [FileManager archiveObjectWithObject:filterList.lastObject
                                                      andArchiveKey:kSelectedCityArchiverKey
                                                           rootType:FMRootFolderTypeOfCache
                                                            subPath:kDataKeyedArchiverPath
                                                            theFile:kSelectedCityArchiverKey
                                                            extType:kArchiverKeyOfType];
            
            NSLog(@"is save the location success :: %d", saveSuccess);
            if (returnBlock) {
               returnBlock(filterList.lastObject);
            }
        }
    }
}

@end
