//
//  InfoTabBtns.h
//  cdzer
//
//  Created by KEns0n on 9/24/15.
//  Copyright © 2015 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ButtonIndexBlock)(NSUInteger btnIndex);

@interface  ButtonObject: NSObject

@property (nonatomic, strong) NSString *title;

@property (nonatomic, strong) NSString *action;

@property (nonatomic, copy) id target;

@property (nonatomic, strong) UIButton *button;

@end

@interface InfoTabBtns : UIView

@property (nonatomic, assign) NSUInteger btnIndex;

- (void)initializationUIWithButtonObject:(NSArray *)btnList withBtnActionBlock:(ButtonIndexBlock)block;

@end
