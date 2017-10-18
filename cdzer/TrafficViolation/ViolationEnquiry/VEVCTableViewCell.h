//
//  VEVCTableViewCell.h
//  cdzer
//
//  Created by KEns0n on 1/4/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VEVCTableViewCell : UITableViewCell

- (void)updateUIData:(NSDictionary *)detailData withWarningLabel:(NSString *)warningText;

@end
