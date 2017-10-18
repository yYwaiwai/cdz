//
//  RepairShopResultVCComponent.h
//  cdzer
//
//  Created by KEns0nLau on 6/29/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^RepairShopFilterResponseBlock)(void);
@interface RepairShopResultFilterView : UIView

@property (nonatomic, strong) NSString *shopTypeID;

@property (nonatomic, strong) NSString *shopServiceTypeID;

@property (nonatomic, strong) NSNumber *isValid;

- (void)unfoldingFilterView;

- (void)setSelectedResponseBlock:(RepairShopFilterResponseBlock)responseBlock;

@end