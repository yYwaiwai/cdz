//
//  EServiceLocatePinView.h
//  cdzer
//
//  Created by KEns0nLau on 6/4/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EServiceLocatePinView : UIControl

@property (nonatomic, assign) BOOL showArrow;

@property (nonatomic, readonly) UILabel *addressLabel;

@property (nonatomic, assign) UIOffset centerPointOffset;

@end
