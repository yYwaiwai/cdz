//
//  MemberRightListBottomCell.m
//  cdzer
//
//  Created by KEns0n on 12/12/2016.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "MemberRightListBottomCell.h"
#import "UserMemberCenterConfig.h"
@interface MemberRightListBottomCell()

@property (weak, nonatomic) IBOutlet UIImageView *userRightsIconIV;

@property (weak, nonatomic) IBOutlet UILabel *userRightsTitleLabel;

@property (weak, nonatomic) IBOutlet UILabel *userRightsContentLabel;


@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

@property (nonatomic, assign) BOOL isLevelDetailCell;

@end

@implementation MemberRightListBottomCell

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.isLevelDetailCell) {
        UIRectBorder rectBorderOption = UIRectBorderNone;
        if (self.isLastCell) {
            rectBorderOption = UIRectBorderBottom;
        }
        [self setViewBorderWithRectBorder:rectBorderOption borderSize:0.5 withColor:nil withBroderOffset:nil];
    }else {
        [self.userRightsIconIV setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:CGRectGetWidth(self.userRightsIconIV.frame)/2.0f];
        
        BorderOffsetObject *borderOffset = [BorderOffsetObject new];
        borderOffset.bottomLeftOffset = CGRectGetMinX(self.userRightsTitleLabel.superview.frame);
        if (self.isLastCell) {
            borderOffset.bottomLeftOffset = 0;
        }
        [self setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:borderOffset];
    }
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)updateUIDataWithIndex:(NSUInteger)index andContent:(NSString *)content {
    self.isLevelDetailCell = YES;
    if (index>19) index = 19;
    NSInteger utf8Integer = 14848416+index;
    NSString *utf8HexString = [NSString stringWithFormat:@"%lX", (unsigned long)utf8Integer];
    NSString *indexString = utf8HexString.hexStringToString;
    
    if (!content) content = @"";
    if (![content isContainsString:indexString]&&![content isEqualToString:@""]) {
        content = [indexString stringByAppendingFormat:@" %@", content];
    }
    self.contentLabel.text = content;
}


- (void)updateUIDataWithDataModel:(MDRDataModel *)dataModel {
    self.isLevelDetailCell = NO;
    self.userRightsTitleLabel.text = dataModel.title;
    self.userRightsContentLabel.text = dataModel.content;
    self.userRightsIconIV.image = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:dataModel.iconURL ofType:nil]];
}

@end

