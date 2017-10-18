//
//  BadgeButtonView.h
//  cdzer
//
//  Created by KEns0n on 3/24/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BadgeButtonView : UIView

@property (nonatomic, assign) NSUInteger badgeCount;

- (void)setImage:(UIImage *)image andTitle:(NSString *)title;

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;
@end
