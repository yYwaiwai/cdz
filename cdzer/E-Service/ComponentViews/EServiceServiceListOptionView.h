//
//  EServiceServiceListOptionView.h
//  cdzer
//
//  Created by KEns0nLau on 6/15/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EServiceConfig.h"

@interface EServiceServiceListOptionView : UIControl

@property (nonatomic, assign) EServiceType serviceType;

- (void)showOptionView;

@end
