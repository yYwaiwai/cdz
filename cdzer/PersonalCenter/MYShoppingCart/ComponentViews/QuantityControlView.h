//
//  QuantityControlView.h
//  cdzer
//
//  Created by KEns0n on 7/18/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QuantityControlView : UIControl

@property (nonatomic, assign, readonly) NSUInteger value;

@property (nonatomic, assign, readonly) NSUInteger maxValue;

@property (nonatomic, strong) NSIndexPath *identifierIndexPath;

- (void)setValue:(NSUInteger)value withMaxValue:(NSUInteger)maxValue;

@end
