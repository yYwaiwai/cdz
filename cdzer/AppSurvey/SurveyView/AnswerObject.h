//
//  AnswerObject.h
//  cdzer
//
//  Created by KEns0n on 2/3/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AnswerObject : NSObject

@property (nonatomic, strong) NSNumber *qid;

@property (nonatomic, strong) NSMutableSet <NSIndexPath *> *selectedAnswerSet;

@property (nonatomic, strong) NSString *otherComment;

@end
