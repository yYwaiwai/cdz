//
//  CarTypeDto.h
//  iCars
//
//  Created by Alex on 13-12-30.
//  Copyright (c) 2013年 zciot. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CarTypeDto : NSObject

//
@property (strong, nonatomic) NSString *carTypeId;
//
@property (strong, nonatomic) NSString *name;
//
@property (strong, nonatomic) NSString *ischild;
//
@property (strong, nonatomic) NSArray *children;

@property (strong, nonatomic) NSString *parentId;

@end
