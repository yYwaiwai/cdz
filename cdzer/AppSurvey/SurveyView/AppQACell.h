//
//  AppQACell.h
//  cdzer
//
//  Created by KEns0n on 2/3/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuestionObject.h"
#import "AnswerObject.h"

#define kIntEdgeInsets UIEdgeInsetsMake(0.0f, 12.0f, 0.0f, 12.0f)

typedef void(^AQACAnswerSelectionBlock)(AnswerObject *aObject, NSIndexPath *theIdxPath);

@class InsetsTextField;
static NSString *const AQATFDidBeginEditingNotification = @"AQATFDidBeginEditingNotification";
static NSString *const AQATableViewActiveScrollEnableNotification = @"AQATableViewActiveScrollEnableNotification";
@interface AppQACell : UITableViewCell

@property (nonatomic, strong, readonly) InsetsTextField *otherCommentLabel;

@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, readonly, copy) AQACAnswerSelectionBlock asBlock;

- (void)updateUIData:(QuestionObject *)qObject andAnswerObject:(AnswerObject *)aObject;

- (void)setAnswerSelectionBlock:(AQACAnswerSelectionBlock)asBlock;

@end
