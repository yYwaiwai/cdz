//
//  MemberReviewNoticeView.h
//  cdzer
//
//  Created by KEns0n on 31/10/2016.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserMemberCenterConfig.h"

@interface MemberReviewNoticeView : UIView

- (void)showReviewNoticeSuccess:(BOOL)isSuccess memberType:(UserMemberType)memberType withRejectReason:(NSString *)rejectReason;

@end
