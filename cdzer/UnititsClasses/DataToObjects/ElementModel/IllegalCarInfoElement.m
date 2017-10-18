//
//  IllegalCarInfoElement.m
//  iCars
//
//  Created by xuhu on 14-10-16.
//  Copyright (c) 2014年 zciot. All rights reserved.
//

#import "IllegalCarInfoElement.h"

/*
 * 违章车辆信息模型类
 */
@implementation IllegalCarInfoElement

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.cityName forKey:@"cityName"];
    [aCoder encodeObject:self.cityCode forKey:@"cityCode"];
    [aCoder encodeObject:self.carType forKey:@"carType"];
    [aCoder encodeObject:self.plateNo forKey:@"plateNo"];
    [aCoder encodeObject:self.enginerNo forKey:@"enginerNo"];
    [aCoder encodeObject:self.rackNo forKey:@"rackNo"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self.cityName = [aDecoder decodeObjectForKey:@"cityName"];
        self.cityCode = [aDecoder decodeObjectForKey:@"cityCode"];
        self.carType = [aDecoder decodeObjectForKey:@"carType"];
        self.plateNo = [aDecoder decodeObjectForKey:@"plateNo"];
        self.enginerNo = [aDecoder decodeObjectForKey:@"enginerNo"];
        self.rackNo = [aDecoder decodeObjectForKey:@"rackNo"];
    }
    return self;
}


@end
