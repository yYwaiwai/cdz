//
//  IllegalInfoResponse.h
//  iCars
//
//  Created by xuhu on 14-10-17.
//  Copyright (c) 2014年 zciot. All rights reserved.
//

#import "BaseResponse.h"

/*
 *违章信息的服务响应类
 */
@interface IllegalInfoResponse : BaseResponse

@property (strong ,nonatomic) NSMutableArray *illAry ;

@end
