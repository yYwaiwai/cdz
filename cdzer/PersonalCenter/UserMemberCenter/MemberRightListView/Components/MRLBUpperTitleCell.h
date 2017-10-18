//
//  MRLBUpperTitleCell.h
//  cdzer
//
//  Created by KEns0n on 12/12/2016.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MRLBUpperTitleCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *mainTitleView;

@property (nonatomic, weak) IBOutlet UILabel *subTitleView;

@property (nonatomic, strong) IBOutlet NSLayoutConstraint *bottomConstraint;

@end
