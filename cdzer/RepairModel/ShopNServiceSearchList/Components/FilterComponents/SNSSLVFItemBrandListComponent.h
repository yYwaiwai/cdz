//
//  SNSSLVFItemBrandListComponent.h
//  cdzer
//
//  Created by KEns0nLau on 8/20/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SNSSLVFIBLResultBlock)();

@interface SNSSLVFItemBrandListComponent : UIView

@property (nonatomic, assign) SNSSLVFItemBrandType itemBrandType;

@property (nonatomic, copy) SNSSLVFIBLResultBlock resultBlock;

@property (nonatomic, readonly) NSString *itemBrandName;

- (void)showItemBrandListView;

- (void)hideItemBrandListView;

@end
