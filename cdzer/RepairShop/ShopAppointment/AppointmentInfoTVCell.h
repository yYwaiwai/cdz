//
//  AppointmentInfoTVCell.h
//  cdzer
//
//  Created by KEns0n on 10/8/15.
//  Copyright © 2015 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppointmentInfoTVCell : UITableViewCell

@property (nonatomic, strong) NSString *itemName;

@property (nonatomic, strong) NSString *manHour;

@property (nonatomic, strong) NSString *workingPrice;

@property (nonatomic, strong) NSString *totalWorkingPrice;

@property (nonatomic, strong) NSString *serviceAdvice;

- (void)clearAllResultLabelText;

@end
