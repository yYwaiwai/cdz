//
//  RSSVCViewFilterComponent.h
//  cdzer
//
//  Created by KEns0n on 24/10/2016.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNSSLViewFilterViewConfig.h"
#import "UIView+LayoutConstraintHelper.h"

@interface RSSVCViewFilterComponent : UIView

@property (nonatomic, readonly) SNSSLVFilterType currentFilterTypeIdx;

@property (nonatomic, readonly) NSNumber *subTypeFilterSequence;

@property (nonatomic, copy) SNSSLViewFilterViewResultBlock resultBlock;

@end
