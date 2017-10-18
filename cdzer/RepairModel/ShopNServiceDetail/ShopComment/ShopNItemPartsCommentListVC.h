//
//  ShopNItemPartsCommentListVC.h
//  cdzer
//
//  Created by KEns0nLau on 9/2/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

typedef NS_ENUM(NSUInteger, SNIPCLCommentType) {
    SNIPCLCommentTypeOfShop,
    SNIPCLCommentTypeOfParts,
    SNIPCLCommentTypeOfMechanic,
};

#import "XIBBaseViewController.h"

@interface ShopNItemPartsCommentListVC : XIBBaseViewController

@property (nonatomic, assign) SNIPCLCommentType commentType;

@property (nonatomic, strong) NSString *commentTypeID;

@end
