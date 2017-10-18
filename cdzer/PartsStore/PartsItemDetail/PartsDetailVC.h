//
//  PartsDetailVC.h
//  cdzer
//
//  Created by KEns0nLau on 6/27/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "XIBBaseViewController.h"

@interface PartsDetailVC : XIBBaseViewController

@property (nonatomic, strong) NSString *productID;

@property (nonatomic, strong) NSDictionary *itemDetail;

@property (nonatomic, assign) BOOL hiddenExpressBtnNCartAddBtnNGPSBtn;

@end
