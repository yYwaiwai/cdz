//
//  PCRDataModel.m
//  cdzer
//
//  Created by KEns0nLau on 9/18/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "PCRDataModel.h"

@implementation PCRDataModel

- (instancetype)init {
    if (self=[super init]) {
        [self getProvinceList];
        [self setReactiveRules];
    }
    return self;
}

- (void)setReactiveRules {
    @autoreleasepool {
        @weakify(self);
        [RACObserve(self, regionList) subscribeNext:^(NSArray *regionList) {
            @strongify(self);
            if (regionList.count>0) {
                if (self.completeBlock) {
                    self.completeBlock();
                }
            }
        }];
    }
}

- (void)setProvinceList:(NSArray *)provinceList {
    _provinceList = provinceList;
}

- (void)setCityList:(NSArray *)cityList {
    _cityList = cityList;
}

- (void)setRegionList:(NSArray *)regionList {
    _regionList = regionList;
}

- (void)setProvinceID:(NSString *)provinceID {
    _provinceID = provinceID;
}

- (void)setCityID:(NSString *)cityID {
    _cityID = cityID;
}

- (void)setRegionID:(NSString *)regionID {
    _regionID = regionID;
}

- (void)updateProvinceID:(NSString *)provinceID cityID:(NSString *)cityID regionID:(NSString *)regionID {
    @weakify(self);
    if (regionID&&![regionID isEqualToString:@""]){
        if (![self.regionID isEqualToString:regionID]) {
            _regionID = regionID;
            [self.regionList enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull detail, NSUInteger idx, BOOL * _Nonnull stop) {
                @strongify(self);
                NSString *regionID = [SupportingClass verifyAndConvertDataToString:detail[kResultKeyID]];
                if ([self.regionID isEqualToString:regionID]) {
                    self->_regionObjIdx = idx;
                    *stop = YES;
                }
            }];
        }
        if (self.completeBlock) {
            self.completeBlock();
        }
    }else if (cityID&&![cityID isEqualToString:@""]){
        _regionID = nil;
        if (![self.cityID isEqualToString:cityID]) {
            _cityID = cityID;
            [self.cityList enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull detail, NSUInteger idx, BOOL * _Nonnull stop) {
                @strongify(self);
                NSString *cityID = [SupportingClass verifyAndConvertDataToString:detail[kResultKeyID]];
                if ([self.cityID isEqualToString:cityID]) {
                    self->_cityObjIdx = idx;
                    *stop = YES;
                }
                
            }];
            [self getDistrictList:cityID];
        }
        
    }else if (provinceID&&![provinceID isEqualToString:@""]){
        _cityID = nil;
        _regionID = nil;
        if (![self.provinceID isEqualToString:provinceID]) {
            _provinceID = provinceID;
            [self.provinceList enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull detail, NSUInteger idx, BOOL * _Nonnull stop) {
                @strongify(self);
                NSString *provinceID = [SupportingClass verifyAndConvertDataToString:detail[kResultKeyID]];
                if ([self.provinceID isEqualToString:provinceID]) {
                    self->_provinceObjIdx = idx;
                    *stop = YES;
                }
                
            }];
            [self getCityList:provinceID];
        }
    }
}

// 请求省列表
- (void)getProvinceList {
    NSLog(@"%@ accessing province list request",NSStringFromClass(self.class));
    [[APIsConnection shareConnection] commonAPIsGetProvinceListWithSuccessBlock:^(NSURLSessionDataTask *operation, id responseObject) {
        operation.userInfo = @{@"iden":@0};
        [self requestResultHandle:operation responseObject:responseObject withError:nil];
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        [self requestResultHandle:operation responseObject:nil withError:error];
    }];
}

// 请求城市列表
- (void)getCityList:(NSString *)provinceID {
    
    NSLog(@"%@ accessing city list request",NSStringFromClass(self.class));
    [[APIsConnection shareConnection] commonAPIsGetCityListWithProvinceID:provinceID isKeyCity:NO success:^(NSURLSessionDataTask *operation, id responseObject) {
        operation.userInfo = @{@"iden":@1};
        [self requestResultHandle:operation responseObject:responseObject withError:nil];
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        [self requestResultHandle:operation responseObject:nil withError:error];
    }];
}
// 请求地区列表
- (void)getDistrictList:(NSString *)cityID {
    
    NSLog(@"%@ accessing district list request",NSStringFromClass(self.class));
    [[APIsConnection shareConnection] commonAPIsGetDistrictListWithCityID:cityID success:^(NSURLSessionDataTask *operation, id responseObject) {
        operation.userInfo = @{@"iden":@2};
        [self requestResultHandle:operation responseObject:responseObject withError:nil];
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        [self requestResultHandle:operation responseObject:nil withError:error];
    }];
}

- (void)requestResultHandle:(NSURLSessionDataTask *)operation responseObject:(id)responseObject withError:(NSError *)error {
    
    if (error&&!responseObject) {
        NSLog(@"%@",error);
        [ProgressHUDHandler dismissHUD];
        if (error.code==-1009) {
            [SupportingClass showAlertViewWithTitle:@"error" message:@"网络连接失败，请检查网络设置！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            }];
            return;
        }
        
        
        if (error.code==-1001) {
            [SupportingClass showAlertViewWithTitle:@"error" message:@"网络连接逾时，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            }];
            return;
        }
        
        [SupportingClass showAlertViewWithTitle:@"error" message:@"网络错误，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
        }];
        
    }else if (!error&&responseObject) {
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSNumber *idenNumber = [operation.userInfo objectForKey:@"iden"];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        if (errorCode==0) {
            @weakify(self);
            if (idenNumber.integerValue==0) {
                self.provinceList = responseObject[CDZKeyOfResultKey];
                if (self.provinceID&&![self.provinceID isEqualToString:@""]) {
                    [self.provinceList enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull detail, NSUInteger idx, BOOL * _Nonnull stop) {
                        @strongify(self);
                        NSString *provinceID = [SupportingClass verifyAndConvertDataToString:detail[kResultKeyID]];
                        if ([self.provinceID isEqualToString:provinceID]) {
                            self->_provinceObjIdx = idx;
                            *stop = YES;
                        }
                        
                    }];
                }else {
                    _provinceObjIdx = 0;
                    self.provinceID = [self.provinceList[0] objectForKey:kResultKeyID];
                    [self getCityList:self.provinceID];
                }
            }else if (idenNumber.integerValue==1) {
                self.cityList = responseObject[CDZKeyOfResultKey];
                if (self.cityID&&![self.cityID isEqualToString:@""]) {
                    [self.cityList enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull detail, NSUInteger idx, BOOL * _Nonnull stop) {
                        @strongify(self);
                        NSString *cityID = [SupportingClass verifyAndConvertDataToString:detail[kResultKeyID]];
                        if ([self.cityID isEqualToString:cityID]) {
                            self->_cityObjIdx = idx;
                            *stop = YES;
                        }
                        
                    }];
                }else {
                    _cityObjIdx = 0;
                    self.cityID = [self.cityList[0] objectForKey:kResultKeyID];
                    [self getDistrictList:self.cityID];
                }
            }else if (idenNumber.integerValue==2) {
                self.regionList = responseObject[CDZKeyOfResultKey];
                if (self.regionID&&![self.regionID isEqualToString:@""]) {
                    [self.regionList enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull detail, NSUInteger idx, BOOL * _Nonnull stop) {
                        @strongify(self);
                        NSString *regionID = [SupportingClass verifyAndConvertDataToString:detail[kResultKeyID]];
                        if ([self.regionID isEqualToString:regionID]) {
                            self->_regionObjIdx = idx;
                            *stop = YES;
                        }
                        
                    }];
                }else {
                    _regionObjIdx = 0;
                    self.regionID = [self.regionList[0] objectForKey:kResultKeyID];
                    
                }
            }
        }
    }
    
}

@end
