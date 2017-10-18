//
//  OBDCell.m
//  iCars
//
//  Created by xuhu on 14-9-28.
//  Copyright (c) 2014年 zciot. All rights reserved.
//

#import "OBDCell.h"

@interface OBDCell ()

@property (nonatomic, strong) UIImageView *isCheckedIV;

@property (nonatomic, strong) UIImageView *waitForCheckedIV;

@end

@implementation OBDCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.isCheckedIV = [[UIImageView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, 20.0f, 20.0f)];
        _isCheckedIV.image = [UIImage imageNamed:@"l_selected.png"];

        self.waitForCheckedIV = [[UIImageView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, 20.0f, 20.0f)];
        _waitForCheckedIV.image = [UIImage imageNamed:@"c_selected_n.png"];
        
        self.accessoryView = _waitForCheckedIV;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setIsChecked:(BOOL)isChecked {
    _isChecked = isChecked;
    self.accessoryView = isChecked?_isCheckedIV:_waitForCheckedIV;
}


@end
