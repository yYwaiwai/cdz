//
//  MyCaseCell.m
//  cdzer
//
//  Created by 车队长 on 16/11/19.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "MyCaseCell.h"
#import "MyCaseResultDTO.h"
#import <SDWebImage/UIImageView+WebCache.h>
@interface MyCaseCell ()

@property (weak, nonatomic) IBOutlet UIView *messageView;

@property (weak, nonatomic) IBOutlet UILabel *carNumberLabel;

@property (weak, nonatomic) IBOutlet UILabel *stateLabel;

@property (weak, nonatomic) IBOutlet UILabel *vehicleSystemLabel;//车型车系

@property (weak, nonatomic) IBOutlet UILabel *uploadTimeLabel;//上传时间

@property (weak, nonatomic) IBOutlet UILabel *descriptionOfFaultsLabel;//故障描述

@property (weak, nonatomic) IBOutlet UILabel *maintenanceTimeLabel;//维修时间

@property (weak, nonatomic) IBOutlet UILabel *maintenanceCostsLabel;//维修费用

@property (weak, nonatomic) IBOutlet UILabel *repairShopLabel;//维修店铺

@property (weak, nonatomic) IBOutlet UILabel *maintenanceTelephoneLabel;//维修电话

@property (weak, nonatomic) IBOutlet UILabel *maintenanceAddressLabel;//维修地址

@property (weak, nonatomic) IBOutlet UIView *wxxqFeeControl;




@property (weak, nonatomic) IBOutlet UILabel *descriptionOfFaultsDetailLabel;//维修详情里的   故障描述

@property (weak, nonatomic) IBOutlet UILabel *workingHoursLabels;//工时

@property (weak, nonatomic) IBOutlet UILabel *personnelExpensesLabels;//工时费

@property (weak, nonatomic) IBOutlet UILabel *replacementPartsLabels;//更换配件

@property (weak, nonatomic) IBOutlet UILabel *numberLabels;//数量

@property (weak, nonatomic) IBOutlet UILabel *priceLabels;//单价

@property (weak, nonatomic) IBOutlet UIView *buttonBgView;

@property (weak, nonatomic) IBOutlet UIButton *editButton;//编辑按钮

@property (weak, nonatomic) IBOutlet UIButton *deleteButton;//删除按钮

@property (weak, nonatomic) IBOutlet UIView *ckjsdControl;//查看结算单 Control

@property (weak, nonatomic) IBOutlet UIImageView *ckjsdImageView;



@property (weak, nonatomic) IBOutlet UIButton *repairDetailExpandBtn;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *repairDetailViewBottomConstraint;

@property (weak, nonatomic) IBOutlet UIView *repairDetailContentView;

@property (weak, nonatomic) IBOutlet UIButton *repairReceiptsDetailExpandBtn;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *repairReceiptsViewBottomConstraint;

@property (weak, nonatomic) IBOutlet UIView *repairReceiptsContentView;

@property (weak, nonatomic) IBOutlet UILabel *noMoreReceiptsLabel;

@property (nonatomic, assign) NSInteger contentWidth;

@property (nonatomic, assign) NSInteger contentOriginX;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *contentViewWidthConstraint;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *repairItemsLeftContentWidthConstraint;

@property (assign, nonatomic) BOOL isExpandPriceDetail;

@property (assign, nonatomic) BOOL isExpandRepairReceiptsDetail;

@property (assign, nonatomic) BOOL haveReceiptsDetailRecord;


@end

@implementation MyCaseCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.repairDetailExpandBtn.imageView.transform = CGAffineTransformMakeRotation(M_PI);
    self.repairReceiptsDetailExpandBtn.imageView.transform = CGAffineTransformMakeRotation(M_PI);
    [self.messageView setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:6.0];
    [self updateConstraintSetting];
}

- (void)updateConstraintSetting {
    CGFloat widthRaito = 0.893719806763285;
    CGFloat superViewWidth = SCREEN_WIDTH;
    self.contentWidth = roundf(superViewWidth*widthRaito);
    if (self.contentWidth%2==1) self.contentWidth +=1;
    self.contentOriginX = (superViewWidth-self.contentWidth)/2;
    self.contentViewWidthConstraint.constant = self.contentWidth;
    
    NSUInteger repairItemsWidth = roundf((self.contentWidth-24)*0.5);
    if (repairItemsWidth%2==1) repairItemsWidth -=1;
    self.repairItemsLeftContentWidthConstraint.constant = repairItemsWidth;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGFloat height = CGRectGetHeight(rect)-20;
    CGSize cornerRadii = CGSizeMake(6, 6);
    CGRect bkRect = CGRectMake(self.contentOriginX, 14, self.contentWidth, height);
    
    CGFloat shadowWidthOffset = 6;
    CGRect shadowRect = CGRectZero;
    shadowRect.size.width = self.contentWidth-shadowWidthOffset;
    shadowRect.size.height = 20;
    shadowRect.origin.x = self.contentOriginX+shadowWidthOffset/2;
    shadowRect.origin.y = CGRectGetMaxY(bkRect)-CGRectGetHeight(shadowRect);
    
    
    //// General Declarations
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Color Declarations
    UIColor* shadowColor = [UIColor colorWithRed:0.122 green:0.475 blue:1 alpha:0.38];
    UIColor* color = [UIColor whiteColor];
    
    //// Shadow Declarations
    NSShadow* shadow = [[NSShadow alloc] init];
    [shadow setShadowColor:[shadowColor colorWithAlphaComponent:CGColorGetAlpha(shadowColor.CGColor) * 0.44]];
    [shadow setShadowOffset:CGSizeMake(0.1, 1.1)];
    [shadow setShadowBlurRadius:7];
    
    //// Rectangle Drawing
    UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRoundedRect:shadowRect byRoundingCorners:UIRectCornerBottomLeft|UIRectCornerBottomRight cornerRadii:cornerRadii];
    [rectanglePath closePath];
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, shadow.shadowOffset, shadow.shadowBlurRadius, [shadow.shadowColor CGColor]);
    [color setFill];
    [rectanglePath fill];
    CGContextRestoreGState(context);
    
    //// Rectangle 2 Drawing
    UIBezierPath* rectangle2Path = [UIBezierPath bezierPathWithRoundedRect:bkRect byRoundingCorners:UIRectCornerAllCorners cornerRadii:cornerRadii];
    [rectangle2Path closePath];
    [color setFill];
    [rectangle2Path fill];
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    @weakify(self);
    [UIView animateWithDuration:0.25 animations:^{
        @strongify(self);
        CGAffineTransform hideTransform = CGAffineTransformMakeRotation(M_PI);
        CGAffineTransform showTransform = CGAffineTransformMakeRotation(-2*M_PI);
        self.repairDetailExpandBtn.imageView.transform = self.isExpandPriceDetail?showTransform:hideTransform;
        self.repairReceiptsDetailExpandBtn.imageView.transform = (self.isExpandRepairReceiptsDetail&&self.haveReceiptsDetailRecord)?showTransform:hideTransform;
    }];
    
}

- (void)setIsEditMode:(BOOL)isEditMode {
    _isEditMode = isEditMode;
    self.buttonBgView.hidden = !isEditMode;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateUIData:(MyCaseResultDTO *)dataObject {
    if (dataObject) {
        self.haveReceiptsDetailRecord = dataObject.haveReceiptsDetailRecord;
        self.isExpandPriceDetail = dataObject.isExpandPriceDetail;
        self.isExpandRepairReceiptsDetail = dataObject.isExpandRepairReceiptsDetail;
        
        self.repairDetailViewBottomConstraint.constant = self.isExpandPriceDetail?CGRectGetHeight(self.repairDetailContentView.frame):0;
        self.repairReceiptsViewBottomConstraint.constant = (self.isExpandRepairReceiptsDetail&&self.haveReceiptsDetailRecord)?CGRectGetHeight(self.repairReceiptsContentView.frame):0;
        self.repairDetailContentView.hidden = !self.isExpandPriceDetail;
        self.repairReceiptsContentView.hidden = !(self.isExpandRepairReceiptsDetail&&self.haveReceiptsDetailRecord);
        self.noMoreReceiptsLabel.hidden = self.haveReceiptsDetailRecord;
        self.repairReceiptsDetailExpandBtn.hidden = !self.haveReceiptsDetailRecord;
        
        @weakify(self);
        [UIView animateWithDuration:0.25 animations:^{
            @strongify(self);
            [self.contentView setNeedsLayout];
        }];
        
        self.carNumberLabel.text = dataObject.licensePlate;
        self.uploadTimeLabel.text = dataObject.createDatetime;
        if ([dataObject.createDatetime isEqualToString:@""]) {
            self.uploadTimeLabel.text = @"--";
        }
        NSString *vehicleTypeString = dataObject.autosInfo.seriesName;
        if (![dataObject.autosInfo.modelName isEqualToString:@""]) {
            vehicleTypeString = [dataObject.autosInfo.seriesName stringByAppendingFormat:@"\n%@", dataObject.autosInfo.modelName];
        }
        self.stateLabel.text = dataObject.stateName;
        if ([dataObject.stateName isContainsString:@"未审核"]) {
            self.stateLabel.textColor=[UIColor colorWithHexString:@"f8af30"];
        }
        if ([dataObject.stateName isContainsString:@"通过"]) {
            self.stateLabel.textColor=[UIColor colorWithHexString:@"49c7f5"];
        }else{
            self.stateLabel.textColor=[UIColor colorWithHexString:@"808080"];
        }
        self.vehicleSystemLabel.text = vehicleTypeString;
        NSString *stateStr = dataObject.stateName;
        self.editButton.hidden = !([stateStr isContainsString:@"失败"]||
                                   [stateStr isContainsString:@"未过"]||
                                   [stateStr isContainsString:@"未审核"]);
        
        
        self.descriptionOfFaultsLabel.text = dataObject.theCaseReason;
        self.maintenanceTimeLabel.text = dataObject.repairDateTime;
        self.maintenanceCostsLabel.text = [NSString stringWithFormat:@"%0.2f", dataObject.totalPrice.floatValue];
        self.repairShopLabel.text = dataObject.repairShopName;
        
        self.maintenanceTelephoneLabel.text = dataObject.repairShopPhone;
        self.maintenanceAddressLabel.text = dataObject.repairShopAddress;
        
        self.descriptionOfFaultsDetailLabel.text = dataObject.theCaseReason;
        self.workingHoursLabels.text = dataObject.workingHrs;
        self.personnelExpensesLabels.text = [NSString stringWithFormat:@"%0.2f", dataObject.workingPrice.floatValue];
        self.descriptionOfFaultsDetailLabel.text = dataObject.theCaseReason;
        self.workingHoursLabels.text = dataObject.workingHrs;
        self.personnelExpensesLabels.text = [NSString stringWithFormat:@"%0.2f", dataObject.workingPrice.floatValue];
        
        [self updatePartsStringList:dataObject];
        self.ckjsdImageView.image = nil;
        if (dataObject.haveReceiptsDetailRecord) {
            [self.ckjsdImageView sd_setImageWithURL:[NSURL URLWithString:dataObject.caseRepairReceiptsImg]];
        }
    }
    
}

- (void)updatePartsStringList:(MyCaseResultDTO *)dataObject {
    self.replacementPartsLabels.text = @"--";
    self.numberLabels.text = @"0";
    self.priceLabels.text = @"0";
    if (dataObject.repairPartsList.count==0) return;
    NSMutableAttributedString *partsAttributedString = [NSMutableAttributedString new];
    NSMutableAttributedString *partsCountAttributedString = [NSMutableAttributedString new];
    NSMutableAttributedString *partsPriceAttributedString = [NSMutableAttributedString new];
    //   NSParagraphStyleAttributeName 段落的风格（设置首行，行间距，对齐方式什么的）看自己需要什么属性，写什么
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;//结尾部分的内容以……方式省略 ( "...wxyz" ,"abcd..." ,"ab...yz")
    paragraphStyle.alignment = NSTextAlignmentLeft;//（两端对齐的）文本对齐方式：（左，中，右，两端对齐，自然）
    paragraphStyle.baseWritingDirection = NSWritingDirectionLeftToRight;//从左到右的书写方向（一共➡️三种）
    paragraphStyle.minimumLineHeight = 10;//最低行高
    paragraphStyle.maximumLineHeight = 20;//最大行高
    paragraphStyle.hyphenationFactor = 1;//连字属性 在iOS，唯一支持的值分别为0和1
    
    //        paragraphStyle.paragraphSpacing = 7;//段与段之间的间距
    //        paragraphStyle.lineHeightMultiple = 15;/* Natural line height is multiplied by this factor (if positive) before being constrained by minimum and maximum line height. */
    //        paragraphStyle.firstLineHeadIndent = 20.0f;//首行缩进
    //        paragraphStyle.headIndent = 20;//整体缩进(首行除外)
    //        paragraphStyle.tailIndent = 20;//
    //        paragraphStyle.paragraphSpacingBefore = 22.0f;//段首行空白空间/* Distance between the bottom of the previous paragraph (or the end of its paragraphSpacing, if any) and the top of this paragraph. */
    
    NSMutableParagraphStyle *centeParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    centeParagraphStyle.lineSpacing = paragraphStyle.lineSpacing;
    centeParagraphStyle.lineBreakMode = paragraphStyle.lineBreakMode;
    centeParagraphStyle.alignment = NSTextAlignmentCenter;
    centeParagraphStyle.baseWritingDirection = paragraphStyle.baseWritingDirection;
    centeParagraphStyle.minimumLineHeight = paragraphStyle.minimumLineHeight;
    centeParagraphStyle.maximumLineHeight = paragraphStyle.maximumLineHeight;
    centeParagraphStyle.hyphenationFactor = paragraphStyle.hyphenationFactor;
    
    NSUInteger count = dataObject.repairPartsList.count;
    for (int idx=0; idx<count; idx++) {
        MyCasePartDetailDTO *partDto = dataObject.repairPartsList[idx];
        NSString *partString = partDto.partName;
        NSString *partCountString = partDto.counting;
        NSString *partPriceString = partDto.partPrice;
        //计算有多少行
        if(idx!=count-1) {
            partString = [partString stringByAppendingString:@"\n"];
        }
        NSUInteger firstLineHeight = self.replacementPartsLabels.font.lineHeight;
        CGSize size = [SupportingClass getStringSizeWithString:partString font:self.replacementPartsLabels.font widthOfView:CGSizeMake(self.repairItemsLeftContentWidthConstraint.constant, CGFLOAT_MAX)];
        NSInteger lineCount = 0;
        lineCount = size.height/firstLineHeight;
        NSUInteger absoluteLine = lineCount-1;
        if (absoluteLine>0) {
            for (int i = 0; i<absoluteLine; i++) {
                partCountString = [partCountString stringByAppendingString:@"\n"];
                partPriceString = [partPriceString stringByAppendingString:@"\n"];
            }
        }
        
        if(idx>0) {
            paragraphStyle.lineSpacing = 14;
            centeParagraphStyle.lineSpacing = paragraphStyle.lineSpacing;
            [partsAttributedString appendAttributedString:[[NSAttributedString new] initWithString:@"\n" attributes:@{NSParagraphStyleAttributeName:paragraphStyle, NSFontAttributeName:self.replacementPartsLabels.font}]];
            
            [partsCountAttributedString appendAttributedString:[[NSAttributedString new] initWithString:@"\n" attributes:@{NSParagraphStyleAttributeName:centeParagraphStyle, NSFontAttributeName:self.numberLabels.font}]];
            
            [partsPriceAttributedString appendAttributedString:[[NSAttributedString new] initWithString:@"\n" attributes:@{NSParagraphStyleAttributeName:centeParagraphStyle, NSFontAttributeName:self.priceLabels.font}]];
        }
        
        
        paragraphStyle.lineSpacing = 0;
        centeParagraphStyle.lineSpacing = paragraphStyle.lineSpacing;
        [partsAttributedString appendAttributedString:[[NSAttributedString new] initWithString:partString attributes:@{NSParagraphStyleAttributeName:paragraphStyle, NSFontAttributeName:self.replacementPartsLabels.font}]];
        
        [partsCountAttributedString appendAttributedString:[[NSAttributedString new] initWithString:partCountString attributes:@{NSParagraphStyleAttributeName:centeParagraphStyle, NSFontAttributeName:self.numberLabels.font}]];
        
        [partsPriceAttributedString appendAttributedString:[[NSAttributedString new] initWithString:partPriceString attributes:@{NSParagraphStyleAttributeName:centeParagraphStyle, NSFontAttributeName:self.priceLabels.font}]];
    }
    
    self.replacementPartsLabels.attributedText = partsAttributedString;
    self.numberLabels.attributedText = partsCountAttributedString;
    self.priceLabels.attributedText = partsPriceAttributedString;
    
}

- (IBAction)displayAction:(UIButton *)sender {
    MCCellAction action = MCCellActionOfRepairDetailDisplay;
    if (sender==self.repairReceiptsDetailExpandBtn) {
        action = MCCellActionOfRepairReceiptsDisplay;
        if (sender==self.repairReceiptsDetailExpandBtn&&!self.haveReceiptsDetailRecord) {
            return;
        }
        
    }else if (sender==self.editButton) {
        action = MCCellActionOfEditCase;
        
    }else if (sender==self.deleteButton) {
        action = MCCellActionOfDeleteCase;
        
    }
    if (self.actionBlock) {
        self.actionBlock(action, self.indexPath);
    }

}

- (IBAction)pushToRepairShop {
    if (self.actionBlock) {
        self.actionBlock(MCCellActionOfPushToRepairShop, self.indexPath);
    }
}

@end
