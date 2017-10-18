//
//  UITextField+ShareAction.m
//  cdzer
//
//  Created by KEns0nLau on 9/25/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "UITextField+ShareAction.h"

@implementation UITextField (ShareAction)

@dynamic shouldStopPCDAction;
static char key;

- (void)setShouldStopPCDAction:(BOOL)shouldStopPCDAction {
    objc_setAssociatedObject(self,&key, @(shouldStopPCDAction) ,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)shouldStopPCDAction {
    return [objc_getAssociatedObject(self, &key) boolValue];
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (self.shouldStopPCDAction&&(action == @selector(paste:)||action == @selector(cut:)||action == @selector(delete:))) {
        return NO;
    }
    return [super canPerformAction:action withSender:sender];
}

@end
