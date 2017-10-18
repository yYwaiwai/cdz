//
//  MyAddressesCell.m
//  cdzer
//
//  Created by 车队长 on 16/9/9.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "MyAddressesCell.h"
@interface MyAddressesCell ()

@property (weak, nonatomic) IBOutlet UIImageView *littleImage;

@property (weak, nonatomic) IBOutlet UILabel *mrLabel;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UILabel *addressLabel;

@end

@implementation MyAddressesCell

- (void)layoutSubviews {
    [super layoutSubviews];
    [self setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.editImage.tintColor = [UIColor colorWithHexString:@"49c7f5"];
    if (self.editImage.image&&self.editImage.image.renderingMode!=UIImageRenderingModeAlwaysTemplate) {
        UIImage *theImage = [self.editImage.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.editImage.image = theImage;
    }
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.accessoryType = (self.isForSelection&&selected)?UITableViewCellAccessoryCheckmark:UITableViewCellAccessoryNone;
    // Configure the view for the selected state
}

- (void)updateUIData:(AddressDTO *)dto {
    self.nameLabel.text = [NSString stringWithFormat:@"%@ %@",dto.consigneeName, dto.telNumber];
    self.addressLabel.text = dto.address;
    
    AddressDTO *selectedAddress = DBHandler.shareInstance.getUserDefaultAddress;
    BOOL isDefaultAddress = [selectedAddress.addressID isEqualToString:dto.addressID];
    self.mrLabel.hidden = !isDefaultAddress;
    self.littleImage.hidden = !isDefaultAddress;
}

@end
