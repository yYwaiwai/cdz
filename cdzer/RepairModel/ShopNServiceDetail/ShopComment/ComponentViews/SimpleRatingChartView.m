//
//  SimpleRatingChartView.m
//  cdzer
//
//  Created by KEns0n on 3/14/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#import "SimpleRatingChartView.h"
#import "AnimationHandler.h"

@implementation SimpleRatingChartView


- (void)initializationUIWithData:(NSArray *)arrayData {
    
    CGFloat startPositionY = 9.0f;
    CGFloat height = (CGRectGetHeight(self.frame)-startPositionY*arrayData.count+1)/arrayData.count;
    for (int i = 0; i < [arrayData count]; i++) {
        
        NSDictionary *dictionary = [arrayData objectAtIndex:i];
        NSString *currentStarName = [dictionary objectForKey:@"ratingName"];
        CGFloat arg2TotalCount = [[dictionary objectForKey:@"totalRating"] floatValue];
        CGFloat arg3CurrentCount = [[dictionary objectForKey:@"numberOfRating"] floatValue];
        
        CGRect labelRect = CGRectZero;
        CGSize labelSize = CGSizeMake(40.0f, height);
        labelRect.size = labelSize;
        labelRect.origin.y = startPositionY+(labelSize.height+startPositionY)*i;
        UILabel *label = [[UILabel alloc] initWithFrame:labelRect];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTextColor:[UIColor colorWithHexString:@"323232"]];
        [label setText:currentStarName];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setFont:[UIFont systemFontOfSize:13.0f]];
        [self addSubview:label];
        
        
        CGRect chartRect = CGRectZero;
        chartRect.origin.x = CGRectGetMaxX(labelRect);
        chartRect.size = CGSizeMake(CGRectGetWidth(self.frame)-CGRectGetMaxX(labelRect)-startPositionY, labelSize.height);
        chartRect.origin.y = CGRectGetMinY(labelRect);
        UIView *chartView = [[UIView alloc] initWithFrame:chartRect];
        [self addSubview:chartView];
        
        SEL theSelector = @selector(makeBarChartAnimationWithView:totalCount:currentCount:);
        NSMethodSignature* signature1 = [[AnimationHandler class] methodSignatureForSelector:theSelector];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature1];
        [invocation setTarget:[AnimationHandler class]];
        [invocation setSelector:theSelector];
        [invocation setArgument:&chartView atIndex:2];
        [invocation setArgument:&arg2TotalCount atIndex:3];
        [invocation setArgument:&arg3CurrentCount atIndex:4];
        [invocation performSelector:@selector(invoke) withObject:nil afterDelay:0.5];
        [chartView setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:2.0f];
    }
    
    
}


- (void)removeAllView {
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}



@end
