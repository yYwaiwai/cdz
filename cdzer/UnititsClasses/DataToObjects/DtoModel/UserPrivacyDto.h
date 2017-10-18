//
//  UserPrivacyDto.h
//  iCars
//
//  Created by Alex on 13-12-30.
//  Copyright (c) 2013年 zciot. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserPrivacyDto : NSObject

//
@property (strong, nonatomic) NSString *phone;
// 1开 0关
@property (strong, nonatomic) NSString *remindStatus;
// 1开 0关
@property (strong, nonatomic) NSString *locainfoStatus;

@end
