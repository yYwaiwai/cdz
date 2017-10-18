//
//  WriteCommentVC.h
//  cdzer
//
//  Created by KEns0n on 6/29/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//
typedef NS_ENUM(NSInteger, CommentType) {
    CommentTypeOfOrderCommment,
    CommentTypeOfShopComment,
};

#import "BaseViewController.h"

@interface WriteCommentVC : BaseViewController

@property (nonatomic, assign) BOOL popToSecondVC;

- (void)setCommentType:(CommentType)type andID:(NSString *)theID productID:(NSString *)productID;

@end
