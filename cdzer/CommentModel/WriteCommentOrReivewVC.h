//
//  WriteCommentOrReivewVC.h
//  cdzer
//
//  Created by KEns0n on 30/11/2016.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "XIBBaseViewController.h"

@interface WriteCommentOrReivewVC : XIBBaseViewController

@property (nonatomic, strong) NSString *commentGroupID;

@property (nonatomic, assign) NSUInteger commentsRemainCount;

@property (nonatomic, assign) BOOL typeOfReivew;

@property (nonatomic, assign) BOOL commentForRepair;

@property (nonatomic, strong) NSDictionary *commentInfoData;

@end
