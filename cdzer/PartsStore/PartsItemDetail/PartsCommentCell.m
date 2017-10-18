//
//  PartsCommentCell.m
//  cdzer
//
//  Created by KEns0n on 3/16/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#import "PartsCommentCell.h"
#import "InsetsLabel.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface PartsCommentCell ()

@property (nonatomic, weak) IBOutlet UIImageView *userImageView;

@property (nonatomic, weak) IBOutlet UILabel *userNameLabel;

@property (nonatomic, weak) IBOutlet UIView *starRatingContainerView;

@property (nonatomic, strong) HCSStarRatingView *starRatingView;

@property (nonatomic, weak) IBOutlet UILabel *dateTimeLabel;

@property (nonatomic, weak) IBOutlet UILabel *commentDescriptionLabel;

@end

@implementation PartsCommentCell

- (void)awakeFromNib {
    [super awakeFromNib];
    if (!self.starRatingView) {
        self.starRatingView = [[HCSStarRatingView alloc] initWithFrame:self.starRatingContainerView.bounds];
        _starRatingView.allowsHalfStars = NO;
        _starRatingView.maximumValue = 5.0f;
        _starRatingView.minimumValue = 0.0f;
        _starRatingView.value = 3.0f;
        _starRatingView.tintColor = [UIColor redColor];
        _starRatingView.userInteractionEnabled = NO;
        [self.starRatingContainerView addSubview:_starRatingView];
    }
}

- (void)updateUIDataWithData:(NSDictionary *)dataDetail {
//    "content": "bxncjncjd",
//    "face_img": "http://cdz.cdzer.com:80/imgUpload/demo/basic/faceImg/150914163436gWgtHsGurl.jpg",
//    "create_time": "2015-09-16 16:28:15 ",
//    "userName": "181****7163",
//    "autopart_name": "嘉实多ATF多用途自动变速箱油/波箱油/排档液4L",
//    "star": "1.0",
//    "id": "15091616281597383050",
//    "repply_content": ""
    @autoreleasepool {
        NSMutableString *dateString = [NSMutableString stringWithString:[dataDetail[@"create_time"] stringByReplacingOccurrencesOfString:@" " withString:@"\n"]];
        if ([[dateString substringWithRange:NSMakeRange(dateString.length-1, 1)] isEqualToString:@"\n"]) {
            [dateString deleteCharactersInRange:NSMakeRange(dateString.length-1, 1)];
        }
        _dateTimeLabel.text = dataDetail[@"create_time"];
        _userNameLabel.text = dataDetail[@"userName"];
        _starRatingView.value = [dataDetail[@"star"] floatValue];
        _commentDescriptionLabel.text = dataDetail[@"content"];
        
        
        NSString *urlString = dataDetail[@"face_img"];
        UIImage *defaultImage = [ImageHandler getWhiteLogo];
        self.userImageView.image = nil;
        self.userImageView.image = defaultImage;
        if ([urlString rangeOfString:@"http"].location != NSNotFound) {
            [self.userImageView sd_setImageWithURL:[NSURL URLWithString:urlString] placeholderImage:defaultImage];
        }
    }
    
}

@end
