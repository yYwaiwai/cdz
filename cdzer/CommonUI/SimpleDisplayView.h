//
//  SimpleDisplayView.h
//  cdzer
//
//  Created by KEns0n on 3/4/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//


typedef NS_ENUM(NSInteger, SDVType) {
    SDVTypeTextField = 1,
    SDVTypeButtonTouch = 2,
    SDVTypePickerView = 3,
};

#import <UIKit/UIKit.h>

@interface SimpleDisplayView : UIView

@property (nonatomic, strong) NSString *textString;

@property (nonatomic, assign) NSUInteger selectedIndex;

@property (nonatomic, assign) SDVType sdvType;

- (void)initializationUIWithType:(SDVType)type iConImage:(NSString *)imageName imageType:(FMImageType)imageType placeHolder:(NSString *)placeHolder;

- (void)setAccessibilityIdentifierByID:(NSInteger)theIdenID;

- (void)setPreviousSDVTF:(SimpleDisplayView *)psdvtf andNextSDVTF:(SimpleDisplayView *)nsdvtf;

- (BOOL)textFieldGetFirstResponder;

- (BOOL)textFieldResignFirstResponder;

- (void)setTFInputAccessoryView:(UIView *)accessoryView;

- (void)setPickerViewData:(NSArray *)dataArray;

- (void)buttonTouchAddTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;

@end
