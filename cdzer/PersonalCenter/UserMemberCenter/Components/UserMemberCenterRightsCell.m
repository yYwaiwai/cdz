//
//  UserMemberCenterRightsCell.m
//  cdzer
//
//  Created by KEns0n on 28/10/2016.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "UserMemberCenterRightsCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface UserMemberCenterRightsCell ()

@property (weak, nonatomic) IBOutlet UIImageView *iconIV;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation UserMemberCenterRightsCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)updateUIDataWithTitle:(NSString *)title andIconURL:(NSString *)iconURL {
    
    self.iconIV.image = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"white_logo_small@3x" ofType:@"png"]];
    if ([iconURL isContainsString:@"http"]) {
        [self.iconIV sd_setImageWithURL:[NSURL URLWithString:iconURL]];
    }
    
    self.titleLabel.text = title;
}

@end
