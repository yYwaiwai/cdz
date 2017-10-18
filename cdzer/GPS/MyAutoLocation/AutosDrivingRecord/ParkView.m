//
//  ParkView.m
//  iCars
//
//  Created by xuhu on 14-10-15.
//  Copyright (c) 2014年 zciot. All rights reserved.
//

#import "ParkView.h"

@implementation ParkView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#pragma mark -设置停车视图的数据信息
- (void)setParkViewData:(PositionDto *) posDto {
    
    NSString *timeStr = posDto.time ;
    NSArray *timeAry = [timeStr componentsSeparatedByString:@"|"];
    NSString *startTime,*endTime ;
    if([timeAry count]>1){
        startTime = [timeAry objectAtIndex:0];
        endTime = [timeAry objectAtIndex:1];
    }else if([timeAry count] == 1){
        startTime = [timeAry objectAtIndex:0];
        endTime = @"--";
    }else{
        startTime = @"--";
        endTime = @"--";
    }
    self.startTime.text = [NSString stringWithFormat:@"停车时间：%@",startTime] ;
    self.endTime.text = [NSString stringWithFormat:@"结束时间：%@",endTime];
    self.address.text = @"正在加载地址…";
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
