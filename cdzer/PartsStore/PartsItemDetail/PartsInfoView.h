//
//  PartsInfoView.h
//  cdzer
//
//  Created by KEns0n on 7/24/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PartsInfoView : UIView

@property (nonatomic, readonly) BOOL partCompatibilityForCurrentAutos;

- (void)updateUIDataWithDetailData:(NSDictionary *)itemDetail;

- (void)setShowCommnetViewTarget:(id)target action:(SEL)action;

@end
