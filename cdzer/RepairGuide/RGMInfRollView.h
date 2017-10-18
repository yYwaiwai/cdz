//
//  RGMInfRollView.h
//  cdzer
//
//  Created by KEns0n on 2/26/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

typedef void(^RGMInfRollViewSelectionResponseBlock)(NSDictionary *dataDetail);

#import <UIKit/UIKit.h>

@interface RGMInfRollView : UIView

- (void)setAnimationDuration:(NSTimeInterval)newVar;

- (void)viewWillDisappear;

- (void)viewWillAppearWithData:(NSArray *)list;

- (void)setSelectionResponseBlock:(RGMInfRollViewSelectionResponseBlock)responseBlock;

@end
