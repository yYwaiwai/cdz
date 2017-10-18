//
//  SNSSLViewFilterComponent.h
//  cdzer
//
//  Created by KEns0nLau on 8/10/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

typedef NS_ENUM(NSUInteger, SNSSLVFilterType) {
    SNSSLVFilterTypeOfAll = 1,
    SNSSLVFilterTypeOfBrandOption,
    SNSSLVFilterTypeOfSpecRepairOption,
};  

typedef void(^SNSSLViewFilterViewResultBlock)();
#import <UIKit/UIKit.h>
#import "UIView+LayoutConstraintHelper.h"

@interface SNSSLViewFilterView : UIView

@property (nonatomic, readonly) SNSSLVFilterType currentFilterTypeIdx;

@property (nonatomic, copy) SNSSLViewFilterViewResultBlock resultBlock;

@property (nonatomic, readonly) NSString *mainFilterSelectedID;

@property (nonatomic, readonly) NSNumber *subTypeFilterSequence;

@property (nonatomic, readonly) SNSSLVFItemBrandType itemBrandType;

@property (nonatomic, readonly) NSString *itemBrandName;

@end

@interface SNSSLViewFilterMainTypeCell : UITableViewCell

@end

@interface SNSSLViewFilterSubTypeCell : UITableViewCell

@property (nonatomic, strong) NSIndexPath *indexPath;

@end