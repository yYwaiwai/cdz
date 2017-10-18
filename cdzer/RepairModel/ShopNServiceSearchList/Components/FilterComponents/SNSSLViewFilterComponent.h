//
//  SNSSLViewFilterComponent.h
//  cdzer
//
//  Created by KEns0nLau on 8/10/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNSSLViewFilterViewConfig.h"
#import "UIView+LayoutConstraintHelper.h"

@interface SNSSLViewFilterView : UIView

@property (nonatomic, readonly) SNSSLVFilterType currentFilterTypeIdx;

@property (nonatomic, copy) SNSSLViewFilterViewResultBlock resultBlock;

@property (nonatomic, readonly) NSString *mainFilterSelectedID;

@property (nonatomic, readonly) NSNumber *subTypeFilterSequence;

@property (nonatomic, readonly) SNSSLVFItemBrandType itemBrandType;

@property (nonatomic, readonly) NSString *itemBrandName;

- (void)setToItemBrandFilterTypeOnlyWith:(SNSSLVFItemBrandType)itemBrandType;

- (void)setToItemSpecShopFilterTypeWithItemIdx:(NSIndexPath *)indexPath specShopServiceTypeList:(NSArray <NSDictionary *> *)specShopServiceTypeList;

@end
