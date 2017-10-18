//
//  CDZOPCObjectComponents.m
//  cdzer
//
//  Created by KEns0nLau on 9/23/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "CDZOPCObjectComponents.h"

@implementation PISCConfigObject

- (instancetype)init {
    if(self=[super init]) {
        self.payeeNameString = @"";
        self.userRemarkString = @"";
    }
    return self;
}

@end