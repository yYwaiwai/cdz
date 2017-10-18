//
//  MemberDetailRulesCell.h
//  cdzer
//
//  Created by KEns0n on 28/10/2016.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MemberDetailRulesCell : UITableViewCell

@property (nonatomic, assign) BOOL isLastCell;

- (void)updateUIDataWithIndex:(NSUInteger)index andContent:(NSString *)content;

@end
