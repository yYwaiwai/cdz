//
//  AppointmentInfoTVCell.m
//  cdzer
//
//  Created by KEns0n on 10/8/15.
//  Copyright © 2015 CDZER. All rights reserved.
//

#import "AppointmentInfoTVCell.h"
#import "InsetsLabel.h"


@interface AppointmentInfoTVCell ()

@property (nonatomic, strong) InsetsLabel *itemNameLabel;

@property (nonatomic, strong) InsetsLabel *workingPriceWithManHourLabel;

@property (nonatomic, strong) InsetsLabel *totalWorkingPriceLabel;

@property (nonatomic, strong) InsetsLabel *serviceAdviceLabel;

@end

@implementation AppointmentInfoTVCell


- (InsetsLabel *)setupInsetsLabel{
    InsetsLabel *label = [[InsetsLabel alloc] initWithFrame:self.bounds
                                         andEdgeInsetsValue:UIEdgeInsetsMake(0.0f, 15.0f, 0.0f, 15.0f)];
    label.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 16.0f, NO);
    [self.contentView addSubview:label];
    return label;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.itemNameLabel = [self setupInsetsLabel];
        self.itemNameLabel.numberOfLines = 0;
        self.itemNameLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 17.0f, NO);
        
        self.workingPriceWithManHourLabel = [self setupInsetsLabel];
        self.workingPriceWithManHourLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 14.0f, NO);
        
        self.totalWorkingPriceLabel = [self setupInsetsLabel];
        self.totalWorkingPriceLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 14.0f, NO);
        self.totalWorkingPriceLabel.textAlignment = NSTextAlignmentRight;
        
        self.serviceAdviceLabel = [self setupInsetsLabel];
        self.serviceAdviceLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 13.0f, NO);
        self.serviceAdviceLabel.textColor = CDZColorOfTxtGaryColor;
        self.serviceAdviceLabel.numberOfLines = 0;
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateLayoutSubviews];
}

- (void)updateLayoutSubviews {
    
    CGFloat width = CGRectGetWidth(self.contentView.frame);
    
    CGFloat sizeWidth = CGRectGetWidth(self.contentView.frame)-self.itemNameLabel.edgeInsets.left-self.itemNameLabel.edgeInsets.right;
    CGFloat itemNameLabelHeight = [SupportingClass getStringSizeWithString:self.itemNameLabel.text
                                                                      font:self.itemNameLabel.font
                                                               widthOfView:CGSizeMake(sizeWidth, CGFLOAT_MAX)].height;
    self.itemNameLabel.frame = CGRectMake(0.0f, 5.0f, width, itemNameLabelHeight);
    self.workingPriceWithManHourLabel.frame = CGRectMake(0.0f, CGRectGetMaxY(self.itemNameLabel.frame)+5.0f, width, 22.0f);
    self.totalWorkingPriceLabel.frame = CGRectMake(0.0f, CGRectGetMaxY(self.workingPriceWithManHourLabel.frame), width, 22.0f);
    self.serviceAdviceLabel.frame = CGRectMake(0.0f, CGRectGetMaxY(self.totalWorkingPriceLabel.frame), width, CGRectGetHeight(self.contentView.frame)-CGRectGetMaxY(self.totalWorkingPriceLabel.frame));
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)clearAllResultLabelText {
    self.itemNameLabel.text = @"";
    
    self.workingPriceWithManHourLabel.text = @"";
    
    self.totalWorkingPriceLabel.text = @"";
    
    self.serviceAdviceLabel.text = @"";
}

- (void)setItemName:(NSString *)itemName {
    self.itemNameLabel.text = itemName;
    _itemName = itemName;
}

- (void)setManHour:(NSString *)manHour{
    if (!manHour) manHour = @"0";
    _manHour = manHour;
    [self updateWorkingPriceWithManHourText];
    
}

- (void)setWorkingPrice:(NSString *)workingPrice {
    if (!workingPrice) workingPrice = @"0";
    _workingPrice = workingPrice;
    [self updateWorkingPriceWithManHourText];
}

- (void)updateWorkingPriceWithManHourText {
    NSString *workingPrice = @"0";
    NSString *manHour = @"0";
    if (self.workingPrice) workingPrice = self.workingPrice;
    if (self.manHour) manHour = self.manHour;
    UIFont *font = self.workingPriceWithManHourLabel.font;
    
    NSMutableAttributedString* text = [NSMutableAttributedString new];
    [text appendAttributedString:[[NSAttributedString alloc]
                                  initWithString:[@"¥" stringByAppendingString:workingPrice]
                                  attributes:@{NSForegroundColorAttributeName:CDZColorOfRed,
                                               NSFontAttributeName:font}]];
    [text appendAttributedString:[[NSAttributedString alloc]
                                  initWithString:[NSString stringWithFormat:@" (工时费) x %@ (工时)", manHour]
                                  attributes:@{NSFontAttributeName:font}]];
    
    self.workingPriceWithManHourLabel.attributedText = text;
    
}

- (void)setTotalWorkingPrice:(NSString *)totalWorkingPrice {
    if (!totalWorkingPrice) totalWorkingPrice = @"0";
    _totalWorkingPrice = totalWorkingPrice;
    
    NSMutableAttributedString* text = [NSMutableAttributedString new];
    [text appendAttributedString:[[NSAttributedString alloc]
                                  initWithString:@"预计总工时费："
                                  attributes:@{NSFontAttributeName:self.totalWorkingPriceLabel.font}]];
    [text appendAttributedString:[[NSAttributedString alloc]
                                  initWithString:[@"¥" stringByAppendingString:totalWorkingPrice]
                                  attributes:@{NSForegroundColorAttributeName:CDZColorOfRed,
                                               NSFontAttributeName:self.totalWorkingPriceLabel.font}]];
    self.totalWorkingPriceLabel.attributedText = text;

}

- (void)setServiceAdvice:(NSString *)serviceAdvice {
    if (!serviceAdvice||[serviceAdvice isEqualToString:@""]) serviceAdvice = @"－－－";
    self.serviceAdviceLabel.text = [@"服务建议：" stringByAppendingString:serviceAdvice];
    _serviceAdvice = serviceAdvice;
}

@end
