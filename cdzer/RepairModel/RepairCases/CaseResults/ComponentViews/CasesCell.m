//
//  CasesCell.m
//  cdzer
//
//  Created by 车队长 on 16/11/17.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "CasesCell.h"
#import "RepairCaseResultDTO.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface CasesCell ()
@property (weak, nonatomic) IBOutlet UIButton *evaluationCaseButton;//评价此案例

@property (weak, nonatomic) IBOutlet UIButton *viewMoreEvaluationButton;//查看更多评价

@property (weak, nonatomic) IBOutlet UIView *messageView;

@property (weak, nonatomic) IBOutlet UILabel *carNumberLabel;

@property (weak, nonatomic) IBOutlet UIImageView *xitongOrUserSignImage;//系统或用户的图片标志

@property (weak, nonatomic) IBOutlet UILabel *vehicleSystemLabel;//车型车系

@property (weak, nonatomic) IBOutlet UILabel *uploadTimeLabel;//上传时间

@property (weak, nonatomic) IBOutlet UILabel *descriptionOfFaultsLabel;//故障描述

@property (weak, nonatomic) IBOutlet UILabel *maintenanceTimeLabel;//维修时间

@property (weak, nonatomic) IBOutlet UILabel *maintenanceCostsLabel;//维修费用

@property (weak, nonatomic) IBOutlet UILabel *repairShopLabel;//维修店铺

@property (weak, nonatomic) IBOutlet UILabel *maintenanceTelephoneLabel;//维修电话
@property (weak, nonatomic) IBOutlet UILabel *maintenanceAddressLabel;//维修地址


@property (strong, nonatomic) IBOutlet NSLayoutConstraint *repairDetailViewBottomConstraint;

@property (weak, nonatomic) IBOutlet UIView *repairDetailContentView;

@property (weak, nonatomic) IBOutlet UIButton *repairDetailExpandBtn;

@property (weak, nonatomic) IBOutlet UILabel *descriptionOfFaultsDetailLabel;//维修详情里的   故障描述

@property (weak, nonatomic) IBOutlet UILabel *workingHoursLabels;//工时

@property (weak, nonatomic) IBOutlet UILabel *personnelExpensesLabels;//工时费

@property (weak, nonatomic) IBOutlet UILabel *replacementPartsLabels;//更换配件

@property (weak, nonatomic) IBOutlet UILabel *numberLabels;//数量

@property (weak, nonatomic) IBOutlet UILabel *priceLabels;//单价



@property (strong, nonatomic) IBOutlet NSLayoutConstraint *commentViewBottomConstraint;

@property (weak, nonatomic) IBOutlet UIView *commentContentView;

@property (weak, nonatomic) IBOutlet UIButton *commentExpandBtn;

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;//头像图片

@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;//电话

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;//时间

@property (weak, nonatomic) IBOutlet UILabel *commentContentLabel;//评价内容

@property (weak, nonatomic) IBOutlet UILabel *noMoreCommentLabel;


@property (strong, nonatomic) NSString *telephoneNumber;

@property (nonatomic, assign) NSInteger contentWidth;

@property (nonatomic, assign) NSInteger contentOriginX;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *contentViewWidthConstraint;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *repairItemsLeftContentWidthConstraint;

@property (assign, nonatomic) BOOL isExpandPriceDetail;

@property (assign, nonatomic) BOOL isExpandCommentDetail;

@property (assign, nonatomic) BOOL haveCommentRecord;




@end

@implementation CasesCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.repairDetailExpandBtn.imageView.transform = CGAffineTransformMakeRotation(M_PI);
    self.commentExpandBtn.imageView.transform = CGAffineTransformMakeRotation(M_PI);
    
    [self.messageView setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:6.0];
    
    CGFloat headImageViewWith=self.headImageView.frame.size.width;
    [self.headImageView setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:headImageViewWith/2];
    [self updateConstraintSetting];
    
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGFloat height = CGRectGetHeight(rect)-11;
    CGSize cornerRadii = CGSizeMake(6, 6);
    CGRect bkRect = CGRectMake(self.contentOriginX, 5, self.contentWidth, height);
    
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
        self.commentExpandBtn.imageView.transform = (self.isExpandCommentDetail&&self.haveCommentRecord)?showTransform:hideTransform;
    }];
    
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

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateUIData:(RepairCaseResultDTO *)dataObject {
    self.telephoneNumber = nil;
    if (dataObject) {
        self.haveCommentRecord = dataObject.haveCommentRecord;
        self.isExpandPriceDetail = dataObject.isExpandPriceDetail;
        self.isExpandCommentDetail = dataObject.isExpandCommentDetail;
        
        self.repairDetailViewBottomConstraint.constant = self.isExpandPriceDetail?CGRectGetHeight(self.repairDetailContentView.frame):0;
        self.commentViewBottomConstraint.constant = (self.isExpandCommentDetail&&self.haveCommentRecord)?CGRectGetHeight(self.commentContentView.frame):0;
        self.repairDetailContentView.hidden = !self.isExpandPriceDetail;
        self.commentContentView.hidden = !(self.isExpandCommentDetail&&self.haveCommentRecord);
        self.noMoreCommentLabel.hidden = self.haveCommentRecord;
        self.commentExpandBtn.hidden = !self.haveCommentRecord;
        
        @weakify(self);
        [UIView animateWithDuration:0.25 animations:^{
            @strongify(self);
            [self.contentView setNeedsLayout];
        }];
        
        self.xitongOrUserSignImage.highlighted = dataObject.wasCreateByUser;
        self.evaluationCaseButton.enabled = !dataObject.wasCommented;
        self.carNumberLabel.text = dataObject.licensePlate;
        self.uploadTimeLabel.text = dataObject.createDatetime;
        if ([dataObject.createDatetime isEqualToString:@""]) {
            self.uploadTimeLabel.text = @"--";
        }
        NSString *vehicleTypeString = dataObject.seriesName;
        if (![dataObject.modelName isEqualToString:@""]) {
            vehicleTypeString = [dataObject.seriesName stringByAppendingFormat:@"\n%@", dataObject.modelName];
        }
        self.vehicleSystemLabel.text = vehicleTypeString;
        
        self.descriptionOfFaultsLabel.text = dataObject.theCaseReason;
        self.maintenanceTimeLabel.text = dataObject.repairDateTime;
        self.maintenanceCostsLabel.text = [NSString stringWithFormat:@"%0.2f", dataObject.totalPrice.floatValue];
        self.repairShopLabel.text = dataObject.repairShopName;
        
        self.maintenanceTelephoneLabel.text = dataObject.repairShopPhone;
        self.telephoneNumber = dataObject.repairShopPhone;
        
        self.maintenanceAddressLabel.text = dataObject.repairShopAddress;
        
        self.descriptionOfFaultsDetailLabel.text = dataObject.theCaseReason;
        self.workingHoursLabels.text = dataObject.workingHrs;
        self.personnelExpensesLabels.text = [NSString stringWithFormat:@"%0.2f", dataObject.workingPrice.floatValue];
        self.descriptionOfFaultsDetailLabel.text = dataObject.theCaseReason;
        self.workingHoursLabels.text = dataObject.workingHrs;
        self.personnelExpensesLabels.text = [NSString stringWithFormat:@"%0.2f", dataObject.workingPrice.floatValue];
        
        [self updatePartsStringList:dataObject];
        self.headImageView.image = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"eservice_default_img@3x" ofType:@"png"]];
        if ([dataObject.userPortrait isContainsString:@"http"]) {
            [self.headImageView sd_setImageWithURL:[NSURL URLWithString:dataObject.userPortrait]];
        }
        self.phoneLabel.text = dataObject.userName;
        self.timeLabel.text = dataObject.commentDatetime;
        self.commentContentLabel.text = dataObject.commentContent;
    }
}

- (void)updatePartsStringList:(RepairCaseResultDTO *)dataObject {
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
        RepairCaseResultPartDTO *partDto = dataObject.repairPartsList[idx];
        NSString *partString = partDto.partName;
        NSString *partCountString = @(partDto.counting).stringValue;
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

- (IBAction)dailACall {
    if ([self.telephoneNumber isEqualToString:@""]||!self.telephoneNumber) {
        [SupportingClass showAlertViewWithTitle:@"" message:@"此案例暂无提供维修商电话" isShowImmediate:YES cancelButtonTitle:nil otherButtonTitles:nil clickedButtonAtIndexWithBlock:nil];
    }else {
        [SupportingClass makeACall:self.telephoneNumber];
    }
}

- (IBAction)displayHiddenContent:(UIButton *)sender {
    RCCellAction action = RCCellActionOfRepairDetailDisplay;
    if (sender==self.commentExpandBtn) {
        action = RCCellActionOfCommentDisplay;
    }
    if (sender==self.commentExpandBtn&&!self.haveCommentRecord) {
        return;
    }
    if (self.actionBlock) {
        self.actionBlock(action, self.indexPath);
    }
    
}

- (IBAction)viewMoreEvaluationButtonClick {
    if (self.actionBlock) {
        self.actionBlock(RCCellActionOfPushCommentList, self.indexPath);
    }
}

- (IBAction)evaluationCaseButtonClick {
    if (self.actionBlock) {
        self.actionBlock(RCCellActionOfWriteAComment, self.indexPath);
    }
}

- (IBAction)pushToRepairShop {
    if (self.actionBlock) {
        self.actionBlock(RCCellActionOfPushToRepairShop, self.indexPath);
    }
}

@end
