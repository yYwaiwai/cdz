//
//  SearchFilterView.h
//  cdzer
//
//  Created by KEns0n on 3/9/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^FilterResponseBlock)(void);
@interface SearchFilterView : UIView

@property (nonatomic, strong) NSString *shopTypeID;

@property (nonatomic, strong) NSString *shopServiceTypeID;

@property (nonatomic, strong) NSNumber *isValid;

- (instancetype)initWithOrigin:(CGPoint)origin;

- (void)unfoldingFilterView;

- (void)initializationUIWithMaskView:(UIButton *)maskBtnView;

- (void)setSelectedResponseBlock:(FilterResponseBlock)responseBlock;

@end
