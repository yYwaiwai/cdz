//
//  ShopNItemPartsCommentListCell.m
//  cdzer
//
//  Created by KEns0nLau on 9/2/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "ShopNItemPartsCommentListCell.h"
#import "HCSStarRatingView.h"
#import "ShopMechanicDetailDTO.h"
@interface ShopNItemPartsCommentListCell ()

@property (nonatomic, weak) IBOutlet UIImageView *userPortraitIV;

@property (weak, nonatomic) IBOutlet UILabel *userPhoneLabel;

@property (weak, nonatomic) IBOutlet UILabel *datetimeLabel;

@property (weak, nonatomic) IBOutlet HCSStarRatingView *ratingStarView;

@property (weak, nonatomic) IBOutlet UILabel *commentContentLabel;

@property (weak, nonatomic) IBOutlet UILabel *serviceOrItemNameLabel;



@end

@implementation ShopNItemPartsCommentListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateUIData:(NSDictionary *)dataDetail {
    self.userPortraitIV.image = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"eservice_default_img_M@3x" ofType:@"png"]];
    if ([dataDetail[@"face_img"] isContainsString:@"http"]) {
        [self.userPortraitIV setImageWithURL:[NSURL URLWithString:dataDetail[@"face_img"]] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    }
    
    self.userPhoneLabel.text = dataDetail[@"user_name"];
    self.datetimeLabel.text = dataDetail[@"create_time"];
    self.commentContentLabel.text = dataDetail[@"content"];
    if (dataDetail[@"lever_name"]) {
        self.ratingStarView.value = [SupportingClass verifyAndConvertDataToNumber:dataDetail[@"lever_name"]].floatValue;
    }else {
        self.ratingStarView.value = [SupportingClass verifyAndConvertDataToNumber:dataDetail[@"star"]].floatValue;
    }
    
    self.serviceOrItemNameLabel.text = @"";
    if (dataDetail[@"product_name"]) {
        self.serviceOrItemNameLabel.text = dataDetail[@"product_name"];
    }
    if (dataDetail[@"item"]) {
        self.serviceOrItemNameLabel.text = dataDetail[@"item"];
    }
    
}

- (void)updateUIDataByDto:(ShopMechanicCommentDetailDTO *)detailData {
    self.userPortraitIV.image = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"eservice_default_img_M@3x" ofType:@"png"]];
    if ([detailData.userPortrait isContainsString:@"http"]) {
        [self.userPortraitIV setImageWithURL:[NSURL URLWithString:detailData.userPortrait] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    }
    
    self.userPhoneLabel.text = detailData.userName;
    self.datetimeLabel.text = detailData.commentDatetime;
    self.commentContentLabel.text = detailData.commentContent;
    
    self.ratingStarView.value = detailData.commentMarking.floatValue;
    
    self.serviceOrItemNameLabel.text = @"";
    
}


@end
