//
//  MyAddressesCell.h
//  cdzer
//
//  Created by 车队长 on 16/9/9.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddressDTO.h"
@interface MyAddressesCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *editImage;

@property (nonatomic, assign) BOOL isForSelection;

- (void)updateUIData:(AddressDTO *)dto;

@end
