//
//  RepairCell.m
//  cdzer
//
//  Created by 车队长 on 16/8/30.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "RepairCell.h"

@implementation RepairCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateUIDataWithData:(NSDictionary *)dataDetail withStatusType:(CDZMaintenanceStatusType)statusType {
    
    @autoreleasepool {
        if ([dataDetail[@"wxs_kind"] isEqualToString:@""]) {
            self.brandShopLabel.text=@"普通店";
        }else{
        self.brandShopLabel.text=dataDetail[@"wxs_kind"];
//            self.brandShopLabel.backgroundColor=CDZColorOfOrangeColor;
        }
        NSString *process=dataDetail[@"process"];
        UIFont *boldFont15 = systemFontWithoutRatio(14.0f);
        UIFont *commentFont = [UIFont systemFontOfSize:13.0f];
        NSString *orderID = nil;
        NSString *statusName = @"state_name";
        NSString *lineOneStrKey = nil;
        NSString *lineTwoStrKey = nil;
        NSString *lineThreeStrKey = nil;
        NSString *lineFourStrKey = nil;
        
        NSString*leftButtonTitle=nil;
        NSString*rightButtonTitle=nil;
        UIColor*leftButtonColor=[UIColor colorWithRed:164.00/255.00 green:164.00/255.00 blue:164.00/255.00 alpha:1.0];
        UIColor*rightButtonColor=nil;
        switch (statusType) {
            case CDZMaintenanceStatusTypeOfAppointment:
                orderID = @"order_id";
                lineOneStrKey = @"wxs_name";
                lineTwoStrKey = @"fct_name";
                lineThreeStrKey = @"repair_type";
//                lineFourStrKey = @"make_technician";
                
                self.leftButton.hidden=YES;
                self.cellButtonView.hidden=YES;
                self.butttonViewLayoutConstraint.constant=-33;
//                if ([dataDetail[statusName] isEqualToString:@"已预约"]) {
//                    self.cellButtonView.hidden=NO;
//                    rightButtonTitle=@"取消预约";
//                    rightButtonColor=[UIColor colorWithRed:164.00/255.00 green:164.00/255.00 blue:164.00/255.00 alpha:1.0];
//                    if (self.butttonViewLayoutConstraint.constant==-33) {
//                        self.butttonViewLayoutConstraint.constant=0;
//                    }
//                }
//                else if ([dataDetail[statusName] isEqualToString:@"取消预约"]||[statusName isEqualToString:@"预约失败"]) {
//                    self.cellButtonView.hidden=NO;
//                    rightButtonTitle=@"删除";
//                    rightButtonColor=[UIColor colorWithRed:164.00/255.00 green:164.00/255.00 blue:164.00/255.00 alpha:1.0];
//                    if (self.butttonViewLayoutConstraint.constant==-33) {
//                        self.butttonViewLayoutConstraint.constant=0;
//                    }
//                }else{
//                    self.cellButtonView.hidden=YES;
//                    self.butttonViewLayoutConstraint.constant=-33;
//                }
                
                
                break;
            case CDZMaintenanceStatusTypeOfDiagnosis:
                orderID = @"order_id";
                lineOneStrKey = @"wxs_name";
                lineTwoStrKey = @"fct_name";
                lineThreeStrKey = @"repair_type";
                self.leftButton.hidden=YES;
                
                if ([dataDetail[statusName] isEqualToString:@"诊断完成"]) {
                    if ([process isEqualToString:@"4"]) {
                        
                        
                        self.cellButtonView.hidden=NO;
                        rightButtonTitle=@"维修确认";
                        rightButtonColor=[UIColor colorWithRed:62.0/255.0 green:187.0/255.0 blue:242.0/255.0 alpha:1.0] ;
                        if (self.butttonViewLayoutConstraint.constant==-33) {
                            self.butttonViewLayoutConstraint.constant=0;
                        }
                    }
//                else if ([dataDetail[statusName] isEqualToString:@"取消维修"]) {
//                    self.cellButtonView.hidden=NO;
//                    rightButtonTitle=@"删除";
//                    rightButtonColor=[UIColor colorWithRed:164.00/255.00 green:164.00/255.00 blue:164.00/255.00 alpha:1.0];
//                    if (self.butttonViewLayoutConstraint.constant==-33) {
//                        self.butttonViewLayoutConstraint.constant=0;
//                    }
//                }
                    else{
                        self.butttonViewLayoutConstraint.constant=-33;
                        self.cellButtonView.hidden=YES;
                        
                    }
                }else{
                    self.butttonViewLayoutConstraint.constant=-33;
                    self.cellButtonView.hidden=YES;
                    
                }

                break;
            case CDZMaintenanceStatusTypeOfUserAuthorized:
                orderID = @"order_id";
                lineOneStrKey = @"wxs_name";
                lineTwoStrKey = @"fct_name";
                lineThreeStrKey = @"repair_type";
                
                self.cellButtonView.hidden=YES;
                self.butttonViewLayoutConstraint.constant=-33;
                
                break;
            case CDZMaintenanceStatusTypeOfHasBeenClearing:
                orderID = @"order_id";
                lineOneStrKey = @"wxs_name";
                lineTwoStrKey=@"fct_name";
                lineThreeStrKey=@"repair_type";
                lineFourStrKey = @"sum_price";
                
                
                rightButtonColor=[UIColor colorWithRed:62.0/255.0 green:187.0/255.0 blue:242.0/255.0 alpha:1.0] ;
                if ([process isEqualToString:@"8"]) {
//                    if ([dataDetail[statusName] isEqualToString:@"等待付款"]) {
                    self.cellButtonView.hidden=NO;
                    rightButtonTitle=@"确认付款";
//                    leftButtonTitle=@"删除";
                    self.leftButton.hidden=YES;
                    if (self.butttonViewLayoutConstraint.constant==-33) {
                        self.butttonViewLayoutConstraint.constant=0;
                    }
//                  }
                }
                
                else   if ([process isEqualToString:@"9"]) {
//                    if ([dataDetail[statusName] isEqualToString:@"已结算"]) {
                    self.cellButtonView.hidden=NO;
//                    self.leftButton.hidden=NO;
                    rightButtonTitle=@"评价";
//                    leftButtonTitle=@"删除";
                    self.leftButton.hidden=YES;
                    if (self.butttonViewLayoutConstraint.constant==-33) {
                        self.butttonViewLayoutConstraint.constant=0;
                    }
//                  }
                }
                else  if ([process isEqualToString:@"10"]) {
//                if ([dataDetail[statusName] isEqualToString:@"已评价"]) {
                    self.cellButtonView.hidden=NO;
                    self.leftButton.hidden=YES;
                    rightButtonTitle=@"查看评价";
                    if (self.butttonViewLayoutConstraint.constant==-33) {
                        self.butttonViewLayoutConstraint.constant=0;
                    }
//                  }
                }
                else{
                    self.butttonViewLayoutConstraint.constant=-33;
                    self.cellButtonView.hidden=YES;
                    
                }

                break;
                
            default:
                break;
        }
        
        
        if (dataDetail[orderID]&&![dataDetail[orderID] isEqualToString:@""]) {
            
            NSMutableAttributedString* text = [NSMutableAttributedString new];
            [text appendAttributedString:[[NSAttributedString alloc]
                                          initWithString:dataDetail[orderID]
                                          attributes:@{NSForegroundColorAttributeName:CDZColorOfBlack,
                                                       NSFontAttributeName:commentFont}]];
            
            _orderNumberLabel.attributedText = text;
        }
        
        if (dataDetail[@"create_time"]&&![dataDetail[@"create_time"] isEqualToString:@""]) {
            
            NSMutableAttributedString* text = [NSMutableAttributedString new];
//            NSMutableAttributedString* timetext = [NSMutableAttributedString new];
//            [timetext appendAttributedString:[[NSAttributedString alloc]
//                                          initWithString:getLocalizationString(@"diagnosis_datetime")
//                                          attributes:@{NSForegroundColorAttributeName:_timeLabel.textColor,
//                                                       NSFontAttributeName:[UIFont systemFontOfSize:11.0]}]];
            [text appendAttributedString:[[NSAttributedString alloc]
                                          initWithString:dataDetail[@"create_time"]
                                          attributes:@{NSForegroundColorAttributeName:CDZColorOfBlack,
                                                       NSFontAttributeName:commentFont}]];
//            _timeLabel.attributedText=timetext;
            _timeDateLabel.attributedText = text;
        }
        
        _stateLabel.text = dataDetail[statusName];
        _stateLabel.backgroundColor = CDZColorOfClearColor;
        if (dataDetail[@"color"]) {
            _stateLabel.backgroundColor = [UIColor colorWithHexString:dataDetail[@"color"]];
        }
        
        
        _maintenanceMerchantLabel.attributedText = nil;
        _vehicleTypeLabel.attributedText = nil;
        _maintenanceProjectLabel.attributedText = nil;
        _priceLabel.attributedText = nil;
        
        if (lineOneStrKey) {
            NSMutableAttributedString* text = [NSMutableAttributedString new];

            [text appendAttributedString:[[NSAttributedString alloc]
                                          initWithString:dataDetail[lineOneStrKey]
                                          attributes:@{NSForegroundColorAttributeName:CDZColorOfBlack,
                                                       NSFontAttributeName:boldFont15}]];
            
            [_maintenanceMerchantLabel setAttributedText:text];
        }
        
        if (lineTwoStrKey) {
            NSMutableAttributedString* text = [NSMutableAttributedString new];
            [text appendAttributedString:[[NSAttributedString alloc]
                                          initWithString:dataDetail[lineTwoStrKey]
                                          attributes:@{NSForegroundColorAttributeName:CDZColorOfBlack,
                                                       NSFontAttributeName:boldFont15}]];
            
            [_vehicleTypeLabel setAttributedText:text];
        }
        
        if (lineThreeStrKey) {
            
            NSMutableAttributedString* text = [NSMutableAttributedString new];
            [text appendAttributedString:[[NSAttributedString alloc]
                                          initWithString:dataDetail[lineThreeStrKey]
                                          attributes:@{NSForegroundColorAttributeName:CDZColorOfBlack,
                                                       NSFontAttributeName:boldFont15}]];
            
            [_maintenanceProjectLabel setAttributedText:text];
        }
        
        if (lineFourStrKey) {
            BOOL isAppointment = (statusType==CDZMaintenanceStatusTypeOfAppointment);
//            NSString *title = getLocalizationString(isAppointment?@"repair_technician_with_symbol":@"diagnosis_fee");
            NSString *content = dataDetail[lineFourStrKey];
            if (!isAppointment) {
                content = [@"¥" stringByAppendingString:dataDetail[lineFourStrKey]];
            }
            NSMutableAttributedString* text = [NSMutableAttributedString new];
            [text appendAttributedString:[[NSAttributedString alloc]
                                          initWithString:content
                                          attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:248.0/255.0 green:175.0/255.0  blue:48.0/255.0  alpha:1.0],
                                                       NSFontAttributeName:boldFont15}]];
            
            [_priceLabel setAttributedText:text];
            
           

        }
        [UIView performWithoutAnimation:^{
            [self.rightButton setTitle:rightButtonTitle forState:UIControlStateNormal];
            [self.leftButton setTitle:leftButtonTitle forState:UIControlStateNormal];
            [self.rightButton setTitleColor:rightButtonColor forState:UIControlStateNormal];
        }];
        [self.rightButton setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:1 withColor:rightButtonColor withBroderOffset:nil];
//        [self.leftButton setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:1 withColor:leftButtonColor withBroderOffset:nil];
        [self.leftButton setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:1 withColor:leftButtonColor withBroderOffset:nil];
//        [self.rightButton setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:0.5 withColor:rightButtonColor withBroderOffset:nil];
        
        
        
    }
}

- (IBAction)buttonAction:(id)sender {
    if (self.btnActionBlock) {
        self.btnActionBlock(self.indexPath);
    }
}

@end
