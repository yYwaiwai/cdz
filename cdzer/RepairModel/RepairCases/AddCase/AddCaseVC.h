//
//  AddCaseVC.h
//  cdzer
//
//  Created by 车队长 on 16/11/18.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "XIBBaseViewController.h"
@class MyCaseResultDTO;
@interface AddCaseVC : XIBBaseViewController

//添加DTO等于是编辑案例
@property (nonatomic, strong) MyCaseResultDTO *resultData;

@end
