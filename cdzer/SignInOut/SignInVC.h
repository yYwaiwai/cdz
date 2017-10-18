//
//  SignInVC.h
//  cdzer
//
//  Created by 车队长 on 16/10/12.
//  Copyright © 2016年 CDZER. All rights reserved.
//

typedef void (^ULVCLoginCancelResposeBlock)();

#import "XIBBaseViewController.h"

@interface SignInVC : XIBBaseViewController


- (void)setCancelLoginResponseBlock:(ULVCLoginCancelResposeBlock)cancelBlock;
@end
