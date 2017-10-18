//
//  AllCommentsCell.m
//  cdzer
//
//  Created by 车队长 on 16/11/18.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "AllCommentsCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation AllCommentsCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    CGFloat headImageViewWith=self.headImageView.frame.size.width;
    
    [self.headImageView.layer setCornerRadius:headImageViewWith/2];
    [self.headImageView.layer setMasksToBounds:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateUIData:(NSDictionary *)dataDetail {
    NSString *imageURL = dataDetail[@"face_img"];
    if ([imageURL isEqualToString:@""]||!imageURL||[imageURL rangeOfString:@"http"].location==NSNotFound) {
        self.headImageView.image=nil;
    }else {
        [self.headImageView sd_setImageWithURL:[NSURL URLWithString:imageURL] placeholderImage:[ImageHandler getWhiteLogo]];
    }
    
    self.phoneLabel.text=dataDetail[@"user_name"];
    self.timeLabel.text=dataDetail[@"addtime"];
    self.contronLabel.text=dataDetail[@"content"];
}
@end
