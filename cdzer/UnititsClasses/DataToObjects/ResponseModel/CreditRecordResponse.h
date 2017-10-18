//
//  CreditRecordResponse.h
//  iCars
//
//  Created by xuhu on 14-11-27.
//  Copyright (c) 2014年 zciot. All rights reserved.
//

#import "BaseResponse.h"

/*
 * 积分记录的数据响应类
 */
@interface CreditRecordResponse : BaseResponse

@property (strong ,nonatomic) NSMutableArray *recordAry ;

@end
