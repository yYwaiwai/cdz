//
//  CommentListCell.h
//  cdzer
//
//  Created by KEns0n on 3/16/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HCSStarRatingView.h"

@interface CommentListCell : UITableViewCell

- (void)initializationUI;

- (void)updateUIDataWithData:(NSDictionary *)dataDetail;

@end
