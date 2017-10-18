//
//  MemberDetailRulesCell.m
//  cdzer
//
//  Created by KEns0n on 28/10/2016.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "MemberDetailRulesCell.h"
@interface MemberDetailRulesCell()

@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

@end

@implementation MemberDetailRulesCell

- (void)layoutSubviews {
    [super layoutSubviews];
    
    UIRectBorder rectBorderOption = UIRectBorderNone;
    if (self.isLastCell) {
        rectBorderOption = UIRectBorderBottom;
    }
    [self setViewBorderWithRectBorder:rectBorderOption borderSize:0.5 withColor:nil withBroderOffset:nil];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateUIDataWithIndex:(NSUInteger)index andContent:(NSString *)content {
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

@end
