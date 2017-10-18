//
//  ParkView.h
//  iCars
//
//  Created by xuhu on 14-10-15.
//  Copyright (c) 2014年 zciot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PositionDto.h"

@interface ParkView : UIView

@property (strong ,nonatomic) IBOutlet UILabel *startTime ;
@property (strong ,nonatomic) IBOutlet UILabel *endTime ;
@property (strong ,nonatomic) IBOutlet UILabel *address ;

#pragma mark -设置停车视图的数据信息
- (void)setParkViewData:(PositionDto *) posDto ;

@end
