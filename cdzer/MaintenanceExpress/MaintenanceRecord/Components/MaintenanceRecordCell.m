//
//  MaintenanceRecordCell.m
//  cdzer
//
//  Created by KEns0nLau on 10/11/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "MaintenanceRecordCell.h"
@interface MaintenanceRecordCell()

@property (weak, nonatomic) IBOutlet UILabel *dateTimeLabel;

@property (weak, nonatomic) IBOutlet UILabel *totalMilesLabel;

@property (weak, nonatomic) IBOutlet UILabel *itemsLabel;

@property (weak, nonatomic) IBOutlet UIImageView *typeIndicatorView;

@property (weak, nonatomic) IBOutlet UIButton *editBtn;


@end

@implementation MaintenanceRecordCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)editBtnAction {
    if (self.editBlock) {
        self.editBlock(self.indexPath);
    }
}

- (void)updateUIDate:(NSDictionary *)dataDetail {
    BOOL isSelfRepairType = [SupportingClass verifyAndConvertDataToNumber:dataDetail[@"mark"]].boolValue;
    self.editBtn.hidden = !isSelfRepairType;
    self.typeIndicatorView.highlighted = isSelfRepairType;
    self.dateTimeLabel.text = dataDetail[@"add_time"];
    self.totalMilesLabel.text = [[SupportingClass verifyAndConvertDataToString:dataDetail[@"mileage"]] stringByReplacingOccurrencesOfString:@"km" withString:@""];
    NSArray *itemList = [dataDetail[@"maintain_info"] valueForKey:@"name"];
    NSString *itemsString = [itemList componentsJoinedByString:@"\n"];
    itemsString = [itemsString stringByReplacingOccurrencesOfString:@" " withString:@""];
    self.itemsLabel.text = itemsString;
}

@end
