//
//  DateTimeSelectionView.h
//  cdzer
//
//  Created by KEns0n on 5/28/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^DRSResponseBlock)(NSString *startDateTime, NSString *endDateTime);
@interface DateTimeSelectionView : UIView

- (void)setDateSelectedResponseBlock:(DRSResponseBlock)block;
@end
