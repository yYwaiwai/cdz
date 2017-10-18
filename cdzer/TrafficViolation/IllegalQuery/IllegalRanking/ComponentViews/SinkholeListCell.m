//
//  SinkholeListCell.m
//  cdzer
//
//  Created by 车队长 on 16/12/8.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "SinkholeListCell.h"

@implementation SinkholeListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self.contentBgView.layer setCornerRadius:5];
    [self.contentBgView.layer setMasksToBounds:YES];
    [self.contentBgView setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:0.5f withColor:nil withBroderOffset:nil];


}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateUIData:(NSDictionary *)detailData{
@autoreleasepool {
    if (detailData.count==0) {
        self.addressImageView.image=nil;
        self.contentsLabel.text=@"";
        self.vnumLabel.text=@"";
        self.rankLabel.text=@"";
        self.markImageView.image=nil;
        self.sortLabel.text=@"";
    }else{
        
        self.vnumLabel.text=[NSString stringWithFormat:@"%@条",detailData[@"num"]];
        self.contentsLabel.text=[NSString stringWithFormat:@"%@",detailData[@"place_name"]];
        self.sortLabel.text=[NSString stringWithFormat:@"%@",detailData[@"sort"]];
        if ([self.sortLabel.text isEqualToString:@"0"]) {
            self.sortLabel.text=@"";
        }
        NSNumber *rankCount = @([SupportingClass verifyAndConvertDataToNumber:detailData[@"rank"]].integerValue+1);
        
        if (rankCount.integerValue>0&&rankCount.integerValue<=3) {
            
            self.addressImageView.highlighted=YES;
            self.contentsLabel.textColor=[UIColor colorWithHexString:@"ffffff"] ;
            self.vnumLabel.textColor=[UIColor colorWithHexString:@"ffffff"] ;
            self.rankLabel.textColor=[UIColor colorWithHexString:@"ffffff"] ;
            self.sortLabel.textColor=[UIColor colorWithHexString:@"ffffff"] ;
            
            if (rankCount.integerValue==1) {
                self.contentBgView.backgroundColor=[UIColor colorWithHexString:@"f7977b"] ;
                self.rankLabel.text=[NSString stringWithFormat:@"%@st",rankCount];
            }
            if (rankCount.integerValue==2) {
                self.contentBgView.backgroundColor=[UIColor colorWithHexString:@"ffc34f"] ;
                self.rankLabel.text=[NSString stringWithFormat:@"%@nd",rankCount];
            }
            if (rankCount.integerValue==3) {
                self.contentBgView.backgroundColor=[UIColor colorWithHexString:@"ffd481"] ;
                self.rankLabel.text=[NSString stringWithFormat:@"%@rd",rankCount];
            }
        }else {
            self.addressImageView.highlighted=NO;
            
            
            self.contentBgView.backgroundColor=[UIColor colorWithHexString:@"ffffff"] ;
            self.contentsLabel.textColor=[UIColor colorWithHexString:@"646464"] ;
            self.vnumLabel.textColor=[UIColor colorWithHexString:@"646464"] ;
            self.rankLabel.textColor=[UIColor colorWithHexString:@"646464"] ;
            self.sortLabel.textColor=[UIColor colorWithHexString:@"646464"] ;
            
            self.rankLabel.text=[NSString stringWithFormat:@"%@",rankCount];
        }
        
        NSString *markStr=[NSString stringWithFormat:@"%@",[SupportingClass verifyAndConvertDataToString:detailData[@"mark"]]];
        if ([markStr isEqualToString:@"-1"]) {
            self.markImageView.image=[UIImage imageNamed:@"weizhangpaihang-down@3x"];
        }
        if ([markStr isEqualToString:@"1"]) {
            self.markImageView.image=[UIImage imageNamed:@"weizhangpaihang-Up@3x"];
        }
        if ([markStr isEqualToString:@"0"]) {
            self.markImageView.image=[UIImage imageNamed:@"weizhangpaihang-NoChange@3x"];
        }

        
    }
}

}

@end
