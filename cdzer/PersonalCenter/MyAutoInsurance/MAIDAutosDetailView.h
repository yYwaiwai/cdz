//
//  MAIDAutosDetailView.h
//  cdzer
//
//  Created by KEns0n on 10/17/15.
//  Copyright © 2015 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MAIDConfigObject.h"

@interface MAIDAutosDetailView : UIView

@property (nonatomic, assign) BOOL isReady;

@property (nonatomic, strong, nullable) MAIDConfigObject *autosInsuranceDetail;

- (void)updateAutosInsuranceData;

- (void)hiddenButton;

- (void)showButton;

- (nullable instancetype)initWithFrame:(CGRect)frame isEditMode:(BOOL)editMode;

- (void)autosRegisterbuttonAddTarget:(nullable id)target action:(_Nullable SEL)action forControlEvents:(UIControlEvents)controlEvents;


@end
