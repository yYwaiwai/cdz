//
//  MAIVCTableViewCell.h
//  cdzer
//
//  Created by KEns0n on 10/16/15.
//  Copyright © 2015 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MAIVCTableViewCell : UITableViewCell

- (void)updateUIDataWithDate:(NSDictionary *)detail;

- (void)clearAllsetting;

- (void)showAllView;

@end
