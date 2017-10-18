//
//  MemberRightListBottomCell.h
//  cdzer
//
//  Created by KEns0n on 12/12/2016.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MDRDataModel;

@interface MemberRightListBottomCell : UITableViewCell

@property (nonatomic, assign) BOOL isLastCell;

- (void)updateUIDataWithIndex:(NSUInteger)index andContent:(NSString *)content;

- (void)updateUIDataWithDataModel:(MDRDataModel *)dataModel;

@end
