//
//  FaultDto.h
//  iCars
//
//  Created by Alex on 13-12-30.
//  Copyright (c) 2013年 zciot. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FaultDto : NSObject

// 故障码
@property (strong, nonatomic) NSString *itemCode;
// 故障类型
@property (strong, nonatomic) NSString *itemType;
// 故障分析
@property (strong, nonatomic) NSString *itemAnayse;
// 故障建议
@property (strong, nonatomic) NSString *itemAdvice; 
// 故障项
@property (strong, nonatomic) NSString *itemName;
// remark
@property (strong, nonatomic) NSString *remark;

@end
