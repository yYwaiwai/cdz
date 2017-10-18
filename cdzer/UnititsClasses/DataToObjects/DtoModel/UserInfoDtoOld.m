//
//  UserInfoDto.m
//  HouseExhibits
//
//  Created by Alex on 13-3-8.
//  Copyright (c) 2013年 zciot. All rights reserved.
//

#import "UserInfoDtoOld.h"

@implementation UserInfoDto

-(id)copyWithZone:(NSZone *)zone{
    UserInfoDto *dto = [[[self class] allocWithZone:zone] init];
    dto.name = [_name copy];
    dto.sex = [_sex copy];
    dto.age = [_age copy];
    dto.qq = [_qq copy];
    dto.phone = [_phone copy];
    dto.drivingLicence = [_drivingLicence copy];
    return dto;
}
@end
