//
//  QuestionObject.h
//  cdzer
//
//  Created by KEns0n on 2/3/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QuestionObject : NSObject

@property (nonatomic, strong) NSNumber *qid;

@property (nonatomic, strong) NSString *question;

@property (nonatomic, strong) NSArray *anwserSelectionList;

@property (nonatomic, assign) NSUInteger numberOfCanSelAnswer;

@property (nonatomic, assign) BOOL withOtherComment;

@property (nonatomic, strong) NSString *commentTitle;

@property (nonatomic, assign, readonly) NSUInteger cellCount;

@end
