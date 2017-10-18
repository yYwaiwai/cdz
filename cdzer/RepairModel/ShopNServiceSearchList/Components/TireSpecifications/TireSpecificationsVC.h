//
//  TireSpecificationsVC.h
//  cdzer
//
//  Created by 车队长 on 16/7/23.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "XIBBaseViewController.h"

typedef void (^ReturnSpecificationTextBlock )(NSString * specificationText);

@interface TireSpecificationsVC : XIBBaseViewController

@property (nonatomic, assign) BOOL popBackProductCenter;

@property (nonatomic, copy) ReturnSpecificationTextBlock returnSpecificationTextBlock;

- (void)setupReturnSpecificationsText:(ReturnSpecificationTextBlock)block;

@end
