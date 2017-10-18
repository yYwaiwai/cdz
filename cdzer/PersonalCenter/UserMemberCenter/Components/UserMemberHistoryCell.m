//
//  UserMemberHistoryCell.m
//  cdzer
//
//  Created by KEns0n on 28/10/2016.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "UserMemberHistoryCell.h"
#import "UserMemberCenterConfig.h"

@interface UserMemberHistoryCell()

@property (weak, nonatomic) IBOutlet UIImageView *bottomIndicatorIV;

@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

@property (weak, nonatomic) IBOutlet UILabel *dateTimeLabel;

@property (weak, nonatomic) IBOutlet UILabel *memberStatusLabel;

@end

@implementation UserMemberHistoryCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateUIDataWithDataModel:(UMHDataModel *)dataModel {
    self.contentLabel.text = dataModel.content;
    self.dateTimeLabel.text = dataModel.datatime;
    self.memberStatusLabel.text = dataModel.currentGradeContent;
    self.bottomIndicatorIV.hidden = dataModel.isLastRow;
    self.memberStatusLabel.highlighted = dataModel.wasDowngrade;
}

@end
