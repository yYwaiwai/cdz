//
//  SNSSLSViewFilterComponent.h
//  cdzer
//
//  Created by KEns0nLau on 8/10/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNSSLViewFilterViewConfig.h"
#import "UIView+LayoutConstraintHelper.h"

@interface SNSSLSViewFilterView : UIView

@property (nonatomic, readonly) SNSSLVFilterType currentFilterTypeIdx;

@property (nonatomic, copy) SNSSLViewFilterViewResultBlock resultBlock;

@property (nonatomic, readonly) NSString *mainFilterSelectedID;

@property (nonatomic, readonly) NSNumber *subTypeFilterSequence;

@property (nonatomic, readonly) SNSSLVFItemBrandType itemBrandType;


@end
