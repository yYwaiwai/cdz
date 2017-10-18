//
//  MaintenanceRecordInsertEditVC.h
//  cdzer
//
//  Created by KEns0nLau on 10/13/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "XIBBaseViewController.h"

typedef void(^MRIEVCSuccessBlock)();

@interface MaintenanceRecordInsertEditVC : XIBBaseViewController

@property (nonatomic, copy) MRIEVCSuccessBlock successBlock;

- (void)showEditModeViewWithRecordID:(NSString *)recordID selectedItemList:(NSArray <NSString *> *)itemList dateTime:(NSString *)dateTime mileageRecord:(NSString *)mileage;

- (void)showInsertModeView;

@end
