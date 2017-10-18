//
//  MyCarVC.h
//  cdzer
//
//  Created by 车队长 on 16/8/23.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "XIBBaseViewController.h"

@interface MyCarVC : XIBBaseViewController
//点击确认键是否返回上一页的功能
@property (nonatomic, assign) BOOL wasSubmitAfterLeave;
//返回首页，如果 wasSubmitAfterLeave 是 YES
@property (nonatomic, assign) BOOL wasBackRootView;
//展示违章提示框
@property (nonatomic, assign) BOOL showTrafficViolationReminder;

@end
