//
//  UserMemberTypeCell.h
//  cdzer
//
//  Created by KEns0n on 01/11/2016.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserMemberCenterConfig.h"

@interface UserMemberTypeCell : UITableViewCell

@property (nonatomic, assign) BOOL isLastCell;

- (void)updateUIDataWithDataModel:(UMTDataModel *)dataModel;

@end
