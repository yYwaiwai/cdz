//
//  OrderDetailHeaderView.h
//  cdzer
//
//  Created by 车队长 on 16/9/13.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderDetailHeaderView : UIView

@property (nonatomic, strong) NSString *orderType;

@property (nonatomic, strong) NSDictionary *contentDetail;

@property (weak, nonatomic) IBOutlet UIButton *telButton;

- (void)updateUIData;

@end
