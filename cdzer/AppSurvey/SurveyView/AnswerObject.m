//
//  AnswerObject.m
//  cdzer
//
//  Created by KEns0n on 2/3/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "AnswerObject.h"

@interface AnswerObject ()

@end

@implementation AnswerObject

- (instancetype)init {
    self = [super init];
    if (self) {
        self.selectedAnswerSet = [NSMutableSet set];
        self.otherComment = @"";
    }
    return self;
}

@end
