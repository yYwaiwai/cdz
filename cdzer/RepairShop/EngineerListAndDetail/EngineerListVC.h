//
//  EngineerListVC.h
//  cdzer
//
//  Created by KEns0n on 3/12/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#import "BaseTableViewController.h"

@interface EngineerListVC : BaseTableViewController

@property (nonatomic, strong) NSString *shopID;

@property (nonatomic, assign) BOOL isForSelection;

@property (nonatomic, strong) NSDictionary* selectedEngineerData;
@end
