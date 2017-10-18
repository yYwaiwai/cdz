//
//  IconNumDto.m
//  iCars
//
//  Created by zcwl_mac_mini on 14-4-11.
//  Copyright (c) 2014年 zciot. All rights reserved.
//

#import "IconNumDto.h"

@implementation IconNumDto


- (void)setNum:(int)v{
    _num = v; 
    //NSLog(@"IconNumDto:setNum = %d",_num);
    if (_num ==0){
        _frame = CGRectMake(0, 0, 0, 0);
    }else if(_num<10) {
        _frame = CGRectMake(120, 8, 16, 16);
    }else{
        _frame = CGRectMake(120, 8, 25, 16);
    }
    if (_num>99) {
        _num = 99;
    }
}
@end
