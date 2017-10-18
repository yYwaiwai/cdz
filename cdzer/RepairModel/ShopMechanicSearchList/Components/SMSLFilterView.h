//
//  SMSLFilterView.h
//  cdzer
//
//  Created by KEns0n on 15/11/2016.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, SMSLFilterType) {
    SMSLFilterTypeOfAll = 0,
    SMSLFilterTypeOfCommentDescend,
    SMSLFilterTypeOfCommentAscend,
    SMSLFilterTypeOfExperienceDescend,
    SMSLFilterTypeOfExperienceAscend,
};

typedef void(^SMSLFilterViewSelectionResponseBlock)();

@interface SMSLFilterView : UIView

@property (nonatomic, assign, readonly) SMSLFilterType filterType;

@property (nonatomic, readonly) NSString *otherFilterString;

@property (nonatomic, copy) SMSLFilterViewSelectionResponseBlock responseBlock;

@end
