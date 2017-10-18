//
//  MyRepairShopMemberCell.h
//  cdzer
//
//  Created by 车队长 on 16/8/27.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^MyRepairShopMemberCellResponseBlock)(BOOL wasSendByCancel, BOOL wasSendBySetTop, NSIndexPath *indexPath);
@interface MyRepairShopMemberCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *shopLogo;

@property (nonatomic, weak) IBOutlet UILabel *shopNameLabel;

@property (nonatomic, weak) IBOutlet UILabel *shopNameTelLabel;

@property (nonatomic, weak) IBOutlet UILabel *shopAddressLabel;

@property (nonatomic, weak) IBOutlet UIButton *setTopButton;

@property (nonatomic, weak) IBOutlet UIButton *cancelMember;

@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, copy) MyRepairShopMemberCellResponseBlock buttonResponseBlock;

@property (weak, nonatomic) IBOutlet UIView *buttonBgView;

@end
