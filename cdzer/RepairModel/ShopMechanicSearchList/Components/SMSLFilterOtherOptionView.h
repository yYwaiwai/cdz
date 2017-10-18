//
//  SMSLFilterOtherOptionView.h
//  cdzer
//
//  Created by KEns0n on 15/11/2016.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SMSLFOOViewSelectionResponseBlock)();

@interface SMSLFilterOtherOptionView : UIView

@property (nonatomic, copy) SMSLFOOViewSelectionResponseBlock responseBlock;

@property (nonatomic, readonly) NSString *otherFilterString;

- (void)showView;

- (void)hideView;

@end
