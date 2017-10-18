//
//  UserMemberHistoryCell.h
//  cdzer
//
//  Created by KEns0n on 28/10/2016.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UMHDataModel;


@interface UserMemberHistoryCell : UITableViewCell

- (void)updateUIDataWithDataModel:(UMHDataModel *)dataModel;

@end
