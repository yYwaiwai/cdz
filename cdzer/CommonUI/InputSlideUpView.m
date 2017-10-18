//
//  InputSlideUpView.m
//  cdzer
//
//  Created by KEns0n on 5/21/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#import "InputSlideUpView.h"
#import <FXBlurView/FXBlurView.h>

@interface InputSlideUpView ()

@property (nonatomic, strong) FXBlurView *tfContainerView;



@end

@implementation InputSlideUpView

- (instancetype)init {
    self = [self initWithFrame:UIScreen.mainScreen.bounds];
    if (self) {
        
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (!CGRectEqualToRect(frame, UIScreen.mainScreen.bounds)) {
        frame = UIScreen.mainScreen.bounds;
    }
    
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.5]];
        self.tfContainerView = [[FXBlurView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetHeight(frame)*0.75f, CGRectGetWidth(frame), CGRectGetHeight(frame)*0.25f)];
        _tfContainerView.dynamic = YES;
        _tfContainerView.tintColor = UIColor.whiteColor;
        [self addSubview:_tfContainerView];
    }
    return self;
}

//#warning stop to develope

- (void)show {
    
}

@end
