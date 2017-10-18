//
//  WorkingInfoCell.h
//  cdzer
//
//  Created by KEns0nLau on 9/25/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WorkingInfoCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *productLogoImageView;

@property (weak, nonatomic) IBOutlet UILabel *productName;

@property (weak, nonatomic) IBOutlet UILabel *productPrice;

@property (nonatomic) BOOL fullBottomBorderLine;

@end
