//
//  TypeOfInsuranceCell.m
//  cdzer
//
//  Created by 车队长 on 17/1/11.
//  Copyright © 2017年 CDZER. All rights reserved.
//

#import "TypeOfInsuranceCell.h"

@implementation TypeOfInsuranceCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)upDataUIDetail:(NSDictionary *)detail
{
    
    
    
    
    if (![detail[@"price"] isEqualToString:@""]) {
        self.priceLabel.text=[NSString stringWithFormat:@"￥%@",detail[@"price"]];
    }else{
        self.priceLabel.text=@"";
    }
    
    if (![detail[@"coverage_no"] isEqualToString:@""]) {
        self.notesLabel.text=[NSString stringWithFormat:@"(%@)",detail[@"coverage_no"]];
            self.notesLabel.textColor=[UIColor colorWithHexString:@"f8af30"];

    }else{
        self.notesLabel.text=nil;
    }
}

@end
