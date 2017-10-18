//
//  MessageAlertCell.m
//  cdzer
//
//  Created by KEns0n on 6/25/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#define vTopHeight 30.0f
#define vMediumHeight 18.0f

#import "MessageAlertCell.h"
#import "InsetsLabel.h"
@interface MessageAlertCell ()

@property (nonatomic, weak) IBOutlet UIImageView *readImageView;

@property (nonatomic, weak) IBOutlet UIImageView *unreadImageView;

@property (nonatomic, weak) IBOutlet UILabel *dateTimeLabel;

@property (nonatomic, weak) IBOutlet UILabel *statusLabel;

@property (nonatomic, weak) IBOutlet UILabel *messageDetailLabel;


@end

@implementation MessageAlertCell

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}


- (void)updateUIDataWithData:(NSDictionary *)dataDetail {
//content: "亲爱的用户，百城1已经接受了您的预约，请您在2015-06-30 09前去维修！【车队长】",
//msg_type: "维修消息",
//create_time: "2015-06-06 09:24:08 ",
//state_name: "未读"
    
    
    BOOL wasUnread = [dataDetail[@"state_name"] isContainsString:@"未读"];
    NSString *readStatusString = wasUnread?@"unread":@"read";
    NSString *imageName = nil;
    
    NSString *mssageType = dataDetail[@"msg_type"];
    if ([mssageType isContainsString:@"系统"]) {
        imageName = [NSString stringWithFormat:@"message_system_alert_%@_icon@3x",readStatusString];
    }
    if ([mssageType isContainsString:@"维修"]) {
        imageName = [NSString stringWithFormat:@"message_repair_alert_%@_icon@3x",readStatusString];
    }
    if ([mssageType isContainsString:@"订单"]) {
        imageName = [NSString stringWithFormat:@"message_order_alert_%@_icon@3x",readStatusString];
    }
    if ([mssageType isContainsString:@"超速"]) {
        imageName = [NSString stringWithFormat:@"message_over_speed_alert_%@_icon@3x",readStatusString];
    }
    if ([mssageType isContainsString:@"断电"]) {
        imageName = [NSString stringWithFormat:@"message_power_alert_%@_icon@3x",readStatusString];
    }
    if ([mssageType isContainsString:@"公告"]) {
        imageName = @"eservice_default_img@3x";
    }
    
    UIImage *statusImage = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:imageName ofType:@"png"]];
    self.unreadImageView.image = nil;
    self.readImageView.image = nil;
    self.unreadImageView.hidden = !wasUnread;
    self.readImageView.hidden = wasUnread;
    if (wasUnread) {
        self.unreadImageView.image = statusImage;
    }else {
        self.readImageView.image = statusImage;
    }
    
    self.dateTimeLabel.text = dataDetail[@"create_time"];
    self.statusLabel.text = mssageType;
    self.messageDetailLabel.text = dataDetail[@"content"];
    
}


@end
