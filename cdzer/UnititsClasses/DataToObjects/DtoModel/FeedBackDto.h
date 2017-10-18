//
//  FeedBackDto.h
//  iCars
//
//  Created by zcwl_mac_mini on 14-3-12.
//  Copyright (c) 2014年 zciot. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FeedBackDto : NSObject

// 反馈电话
@property (strong, nonatomic) NSString *phone;
// 反馈内容
@property (strong, nonatomic) NSString *content;

@end
