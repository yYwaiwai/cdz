//
//  MaintenanceDetailHeaderView.h
//  cdzer
//
//  Created by 车队长 on 2017/2/24.
//  Copyright © 2017年 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MaintenanceDetailHeaderView : UIView

@property (weak, nonatomic) IBOutlet UIButton *phoneButton;

- (void)updateUIData:(NSDictionary*)contentDetail;

@end
