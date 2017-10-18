//
//  UserMemberTypeCell.m
//  cdzer
//
//  Created by KEns0n on 01/11/2016.
//  Copyright © 2016 CDZER. All rights reserved.
//dataModel
#import "UserMemberTypeCell.h"

@interface UserMemberTypeCell ()

@property (weak, nonatomic) IBOutlet UIImageView *memberTypeIconIV;

@property (weak, nonatomic) IBOutlet UILabel *memberTypeLabel;

@property (weak, nonatomic) IBOutlet UILabel *memberRightsLabel;

@property (nonatomic, strong) BorderOffsetObject *borderOffset;

@end

@implementation UserMemberTypeCell

- (void)layoutSubviews {
    [super layoutSubviews];
    self.borderOffset.bottomLeftOffset = CGRectGetMinX(self.memberTypeLabel.superview.frame);
    if (self.isLastCell) {
        self.borderOffset.bottomLeftOffset = 0;
    }
    [self setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:self.borderOffset];
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.borderOffset = [BorderOffsetObject new];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateUIDataWithDataModel:(UMTDataModel *)dataModel {
    self.memberTypeLabel.text = dataModel.title;
    self.memberRightsLabel.text = dataModel.content;
    NSString *imgName = @"umc_display_bronze_medal_icon@3x";
    if ([dataModel.title isContainsString:@"铜牌"]) {
        imgName = @"umc_display_bronze_medal_icon@3x";
    }else if ([dataModel.title isContainsString:@"银牌"]) {
        imgName = @"umc_display_silver_medal_icon@3x";
    }else if ([dataModel.title isContainsString:@"金牌"]) {
        imgName = @"umc_display_gold_medal_icon@3x";
    }else if ([dataModel.title isContainsString:@"白金"]||
              [dataModel.title isContainsString:@"铂金"]) {
        imgName = @"umc_display_platinum_icon@3x";
    }else if ([dataModel.title isContainsString:@"钻石"]) {
        imgName = @"umc_display_diamond_icon@3x";
    }
    self.memberTypeIconIV.image = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:imgName ofType:@"png"]];
        
//    if ([dataModel.iconURL isContainsString:@"http"]) {
//        @weakify(self);
//        [self.memberTypeIconIV setImageWithURL:[NSURL URLWithString:dataModel.iconURL]  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//            @strongify(self);
//            image = [ImageHandler imageWithImage:image convertToSize:CGSizeMake(image.size.width/2.0f, image.size.height/2.0f)];
//            NSData *imageData = nil;
//            if ([imageURL.absoluteString isContainsString:@"png"]) {
//                imageData = UIImagePNGRepresentation(image);
//            }else {
//                imageData = UIImageJPEGRepresentation(image, 1);
//            }
//            image = [UIImage imageWithData:imageData scale:3];
//            self.memberTypeIconIV.image = image;
//            [self.memberTypeIconIV setNeedsUpdateConstraints];
//            [self.memberTypeIconIV setNeedsLayout];
//            imageData = nil;
//        } usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray ];
//    }
}

@end
