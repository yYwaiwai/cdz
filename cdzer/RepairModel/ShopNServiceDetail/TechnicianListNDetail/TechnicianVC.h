//
//  TechnicianVC.h
//  cdzer
//
//  Created by 车队长 on 16/7/25.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "XIBBaseViewController.h"

typedef void(^TechnicianSelectedResultBlock)(NSDictionary* selectedEngineerData);

@interface TechnicianVC : XIBBaseViewController

@property (nonatomic, strong) NSString *shopID;

@property (nonatomic, assign) BOOL onlyForSelection;

@property (nonatomic, strong) NSDictionary* selectedEngineerData;

@property (nonatomic, copy) TechnicianSelectedResultBlock resultBlock;

@end
