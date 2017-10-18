//
//  MessageDto.h
//  iCars
//
//  Created by Alex on 13-12-30.
//  Copyright (c) 2013年 zciot. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessageDto : NSObject
//
@property (strong, nonatomic) NSString *msgId;
//
@property (strong, nonatomic) NSString *type;
//
@property (strong, nonatomic) NSString *remark;
//
@property (strong, nonatomic) NSString *time;
//标题
@property (strong, nonatomic) NSString *title;

//新数据，有颜色
@property (strong, nonatomic) NSString *color;

@property (assign, nonatomic) int link;
@property (strong, nonatomic) NSString *remarkValue;
@property (strong, nonatomic) NSString *remarkUrl;
@end
