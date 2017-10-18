//
//  TypeOfInsuranceCell.h
//  cdzer
//
//  Created by 车队长 on 17/1/11.
//  Copyright © 2017年 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TypeOfInsuranceCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *notesLabel;

@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

-(void)upDataUIDetail:(NSDictionary *)detail;
@end
