//
//  RepairCell.h
//  cdzer
//
//  Created by 车队长 on 16/8/30.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^RepairCellButtonActionBlock)(NSIndexPath *indexPath);

@interface RepairCell : UITableViewCell

@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, copy) RepairCellButtonActionBlock btnActionBlock;

@property (weak, nonatomic) IBOutlet UIView *bgView;

@property (weak, nonatomic) IBOutlet UILabel *orderNumberLabel;//订单号

@property (weak, nonatomic) IBOutlet UILabel *stateLabel;//诊断状态

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;//时间

@property (weak, nonatomic) IBOutlet UILabel *timeDateLabel;

@property (weak, nonatomic) IBOutlet UILabel *maintenanceMerchantLabel;//维修商

@property (weak, nonatomic) IBOutlet UILabel *vehicleTypeLabel;//车型车系

@property (weak, nonatomic) IBOutlet UILabel *maintenanceProjectLabel;//维修项目

@property (weak, nonatomic) IBOutlet UIButton *leftButton;

@property (weak, nonatomic) IBOutlet UIButton *rightButton;

@property (weak, nonatomic) IBOutlet UILabel *brandShopLabel;//品牌店

@property (weak, nonatomic) IBOutlet UILabel *priceLabel;//价格


@property (weak, nonatomic) IBOutlet UIView *cellButtonView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *butttonViewLayoutConstraint;

- (void)updateUIDataWithData:(NSDictionary *)dataDetail withStatusType:(CDZMaintenanceStatusType)statusType;


@end
