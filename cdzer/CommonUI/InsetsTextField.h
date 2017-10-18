//
//  InsetsTextField.h
//  cdzer
//
//  Created by KEns0n on 3/26/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITextField+ShareAction.h"

@interface InsetsTextField : UITextField

@property (nonatomic, assign) UIEdgeInsets edgeInsets;

- (id)initWithFrame:(CGRect)frame andEdgeInsetsValue:(UIEdgeInsets)edgeInsets;

- (id)initWithCoder:(NSCoder *)aDecoder andEdgeInsetsValue:(UIEdgeInsets)edgeInsets;

@end
