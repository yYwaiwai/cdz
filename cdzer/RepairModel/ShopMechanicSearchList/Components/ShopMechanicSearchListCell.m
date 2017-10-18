//
//  ShopMechanicSearchListCell.m
//  cdzer
//
//  Created by KEns0n on 15/11/2016.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "ShopMechanicSearchListCell.h"
#import "SMSLCellIndicatorBarView.h"
#import "SMSLResultDTO.h"
#import <SDWebImage/UIImageView+WebCache.h>


@interface ShopMechanicSearchListCell ()

@property (weak, nonatomic) IBOutlet UIImageView *mechanicPortrait;

@property (weak, nonatomic) IBOutlet UILabel *mechanicNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *shopNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *skillsNameListLabel;

@property (weak, nonatomic) IBOutlet UILabel *workingYearLabel;

@property (weak, nonatomic) IBOutlet UIImageView *typeGradeIV;

@property (weak, nonatomic) IBOutlet UILabel *currentExpLabel;

@property (weak, nonatomic) IBOutlet UILabel *maxExpLabel;

@property (weak, nonatomic) IBOutlet UIButton *selectionBtn;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnTailingConstraint;

@property (weak, nonatomic) IBOutlet SMSLCellIndicatorBarView *indicatorBar;


@end

@implementation ShopMechanicSearchListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.showSelection = NO;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.mechanicPortrait setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:CGRectGetHeight(self.mechanicPortrait.frame)/2.0f];
    UIRectBorder rectBorder = UIRectBorderBottom;
    if (self.indexPath.row==0) rectBorder = UIRectBorderBottom|UIRectBorderTop;
    [self setViewBorderWithRectBorder:rectBorder borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self.selectionBtn setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:CGRectGetHeight(self.selectionBtn.frame)/2.0f];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)setShowSelection:(BOOL)showSelection {
    _showSelection = showSelection;
    self.selectionBtn.superview.hidden = !showSelection;
    self.btnTailingConstraint.constant = showSelection?0:-(CGRectGetWidth(self.selectionBtn.superview.frame));
}

- (void)updateUIData:(SMSLResultDTO *)dataModel {
    self.mechanicPortrait.image = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"eservice_default_img@3x" ofType:@"png"]];
    if ([dataModel.mechanicPortrait isContainsString:@"http"]) {
        [self.mechanicPortrait sd_setImageWithURL:[NSURL URLWithString:dataModel.mechanicPortrait]];
    }
    self.mechanicNameLabel.text = dataModel.mechanicName;
    self.shopNameLabel.text = [dataModel.repairShopName stringByAppendingFormat:@"(%@)", dataModel.repairShopType];
    self.skillsNameListLabel.text = dataModel.specialism;
    self.workingYearLabel.text = dataModel.workingYrs;
    self.mechanicNameLabel.text = dataModel.mechanicName;
    self.mechanicNameLabel.text = dataModel.mechanicName;
    self.currentExpLabel.text = dataModel.currentScore;
    self.maxExpLabel.text = dataModel.totalScore;
    self.indicatorBar.currentValue = dataModel.scorePercentage.floatValue;
    
    NSString *gradeStr = @"";
    NSString *typeStr = @"";
    if ([dataModel.workingGrade isContainsString:@"初级"]) {
        gradeStr = @"junior";
    }else if ([dataModel.workingGrade isContainsString:@"中级"]) {
        gradeStr = @"intermediate";
    }else if ([dataModel.workingGrade isContainsString:@"高级"]) {
        gradeStr = @"senior";
    }
    
    if ([dataModel.workingGrade isContainsString:@"技工"]) {
        typeStr = @"mechanic";
    }else if ([dataModel.workingGrade isContainsString:@"技师"]) {
        typeStr = @"technician";
    }
        
    
    if (![gradeStr isEqualToString:@""]&&![typeStr isEqualToString:@""]) {
        NSString *imgName = [NSString stringWithFormat:@"smsl_%@_%@_icon@3x", gradeStr, typeStr];
        UIImage *image = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:imgName ofType:@"png"]];
        self.typeGradeIV.image = image;
    }
}

- (IBAction)btnAction {
    if (self.actionBlock) {
        self.actionBlock(self.indexPath);
    }
}
@end
