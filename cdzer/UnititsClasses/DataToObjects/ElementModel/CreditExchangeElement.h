//
//  CreditExchangeElement.h
//  iCars
//
//  Created by xuhu on 14-11-26.
//  Copyright (c) 2014年 zciot. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 * 积分对象模型类
 */
@interface CreditExchangeElement : NSObject

@property (strong ,nonatomic) NSString *marketPrice ;
@property (strong ,nonatomic) NSString *name ;
@property (strong ,nonatomic) NSString *number ;
@property (strong ,nonatomic) NSString *productType ;
@property (strong ,nonatomic) NSString *scale ;

@end
