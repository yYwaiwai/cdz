//
//  HomeInfoDto.m
//  iCars
//
//  Created by Alex on 13-12-30.
//  Copyright (c) 2013年 zciot. All rights reserved.
//

#import "HomeInfoDto.h"

@implementation HomeInfoDto

-(id)copyWithZone:(NSZone *)zone{
    HomeInfoDto *dto = [[[self class] allocWithZone:zone] init];
    dto.color = [_color copy];
    dto.signCode = [_signCode copy];
    dto.engineCode = [_engineCode copy];
    dto.mileage = [_mileage copy];
    dto.warrantyNo = [_warrantyNo copy];
    return dto;
}
@end
