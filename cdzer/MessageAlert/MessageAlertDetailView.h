//
//  MessageAlertDetailView.h
//  cdzer
//
//  Created by KEns0n on 12/19/15.
//  Copyright © 2015 CDZER. All rights reserved.
//  信息详情数据视图

#import <UIKit/UIKit.h>

@interface MessageAlertDetailView : UIControl

@property (nonatomic, assign, readonly) BOOL isShowView;

- (void)showMessageViewWith:(NSString *)content;

@end
