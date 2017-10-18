//
//  QuestionObject.m
//  cdzer
//
//  Created by KEns0n on 2/3/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "QuestionObject.h"

@interface QuestionObject ()

@property(nonatomic, assign) NSUInteger lastNumberOfCanSelAnswer;

@end

@implementation QuestionObject

- (void)setAnwserSelectionList:(NSArray *)anwserSelectionList {
    if (anwserSelectionList.count>=2) {
        if (_lastNumberOfCanSelAnswer>anwserSelectionList.count) {
            self.lastNumberOfCanSelAnswer = anwserSelectionList.count;
            _numberOfCanSelAnswer = _lastNumberOfCanSelAnswer;
        }
    }
    _anwserSelectionList = anwserSelectionList;
}

- (void)setNumberOfCanSelAnswer:(NSUInteger)numberOfCanSelAnswer {
    self.lastNumberOfCanSelAnswer = numberOfCanSelAnswer;
    if (numberOfCanSelAnswer>_anwserSelectionList.count) {
        numberOfCanSelAnswer = _anwserSelectionList.count;
    }
    _numberOfCanSelAnswer = numberOfCanSelAnswer;
}

- (NSUInteger)cellCount {
    return 1+_anwserSelectionList.count+_withOtherComment;
}

@end
