//
//  UserAutosSelectonVC.h
//  cdzer
//
//  Created by KEns0nLau on 8/27/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "XIBBaseViewController.h"

@interface UserAutosSelectonVC : XIBBaseViewController

@property (nonatomic, assign) BOOL onlyForSelection;

@property (nonatomic, copy) UserAutosSelectonResultBlock resultBlock;

@end
