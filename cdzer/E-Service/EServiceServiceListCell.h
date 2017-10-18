//
//  EServiceServiceListCell.h
//  cdzer
//
//  Created by KEns0nLau on 6/8/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EServiceConfig.h"

typedef NS_ENUM(NSUInteger, EServiceSLCActionType) {
    EServiceSLCActionTypeOfCancel = 0,
    EServiceSLCActionTypeOfPayment,
    EServiceSLCActionTypeOfConfirnReturn,
    EServiceSLCActionTypeOfToComment,
    EServiceSLCActionTypeOfReviewComment,
};

typedef void(^EServiceSLCActionBlock)(NSIndexPath *indexPath, EServiceSLCActionType actionType);

@interface EServiceServiceListCell : UITableViewCell

@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, copy) EServiceSLCActionBlock actionBlock;

@property (nonatomic, assign, readonly) EServiceType serviceType;

- (void)updateCellConfig:(NSDictionary *)configDetail;

@end
