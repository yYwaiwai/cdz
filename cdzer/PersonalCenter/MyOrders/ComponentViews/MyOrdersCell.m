//
//  MyOrdersself.m
//  cdzer
//
//  Created by 车队长 on 16/8/31.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "MyOrdersCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
@interface MyOrdersCell ()

@property (nonatomic, strong) IBOutlet NSLayoutConstraint *topConstraint;

@end

@implementation MyOrdersCell

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.buttonBgView setViewBorderWithRectBorder:UIRectBorderBottom|UIRectBorderTop borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self.cellTopView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    
    [self.rightButton setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:0.5 withColor:self.rightButton.titleLabel.textColor withBroderOffset:nil];
    [self.leftButton setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:0.5 withColor:self.leftButton.titleLabel.textColor withBroderOffset:nil];
    [self.rightButton setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:3.0f];
    [self.leftButton setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:3.0f];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)updateUIData:(NSDictionary *)sourceData {
    
    self.leftButton.hidden=NO;
    self.rightButton.hidden=NO;
    self.buttonBgView.hidden = NO;
    self.topConstraint.constant = 0;
    NSString *orderBack = sourceData[@"order_back"];
    NSNumber *regTag = sourceData[@"reg_tag"];
    NSString *orderType = sourceData[@"order_type"];
    BOOL isSpecRepairProduct = (![orderType isEqualToString:@"M"]&&
                                ![orderType isEqualToString:@"O"]&&
                                ![orderType isEqualToString:@"P"]&&
                                ![orderType isEqualToString:@""]);
    self.orderTypeImage.image = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle
                                                                  pathForResource:isSpecRepairProduct?@"wddd-shangjiatubiao@3x":@"logo_white@3x" ofType:@"png"]];
    
    
    if ([sourceData[@"store_name"] isKindOfClass:[NSNull class]]) {
        self.shopNameLabel.text = @"暂无商家名称";
    }else{
        self.shopNameLabel.text=sourceData[@"store_name"];
    }
    self.stateLabel.text=sourceData[@"state_name"];
    
    NSString *imgURL = [sourceData objectForKey:@"product_img"];
    if ([imgURL containsString:@"http"]) {
        [self.shopImageView sd_setImageWithURL:[NSURL URLWithString:imgURL] placeholderImage:[ImageHandler getDefaultWhiteLogo]];
    }
    self.contentLabel.text=sourceData[@"product_name"];
    self.priceLabel.text=[NSString stringWithFormat:@"￥%@",sourceData[@"order_price"]];
    if (isSpecRepairProduct) {
        self.numberLabel.text=[NSString stringWithFormat:@"%@件",sourceData[@"product_num"]];
    }else {
        self.numberLabel.text=[NSString stringWithFormat:@"共%@件商品",sourceData[@"product_num"]];
        NSString *workingNum = [SupportingClass verifyAndConvertDataToString:sourceData[@"work_num"]];
        if (workingNum&&workingNum.integerValue>0) {
            self.numberLabel.text=[self.numberLabel.text stringByAppendingFormat:@"%@项工时费",sourceData[@"product_num"]];
        }
    }
    
    NSString*rightButtonTitle=nil;
    NSString*leftButtonTitle=nil;
    
    
    
  
    
    //        /////////////////////////////////////
    if ([sourceData[@"state_name"] isEqualToString:@"待付款"]||[sourceData[@"state_name"] isEqualToString:@"未付款"]) {
        leftButtonTitle=@"取消订单";
        rightButtonTitle=@"立即支付";
    }
    
    if ([sourceData[@"state_name"] isEqualToString:@"货到付款"]) {
        rightButtonTitle=@"取消订单";
        self.leftButton.hidden=YES;
    }
    
    if ([sourceData[@"state_name"] isEqualToString:@"交易关闭"]||
        [sourceData[@"state_name"] isEqualToString:@"订单取消"]) {
        rightButtonTitle=@"删除订单";
        self.leftButton.hidden=YES;
//        if ([orderBack isEqualToString:@"yes"]) {
//            leftButtonTitle=@"返修/退换";
//        }else{
//            self.leftButton.hidden=YES;
//        }
    }
    if ([sourceData[@"state_name"] isEqualToString:@"待安装"]) {
        self.leftButton.hidden=YES;
        if ([orderBack isEqualToString:@"yes"]) {
            rightButtonTitle=@"返修/退换";
        }else{
            rightButtonTitle=@"取消订单";
        }
    }
    if ([sourceData[@"state_name"] isEqualToString:@"已付款"]) {
        rightButtonTitle=@"取消订单";
        self.leftButton.hidden=YES;
    }
    if ([sourceData[@"state_name"] isEqualToString:@"已到店"]) {
        self.leftButton.hidden=YES;
        if ([orderBack isEqualToString:@"yes"]) {
            rightButtonTitle=@"返修/退换";
        }else{
            self.rightButton.hidden=YES;
        }
    }
    if ([sourceData[@"state_name"] isEqualToString:@"订单完成"]) {
        if ([regTag  isEqual:@0]) {
            rightButtonTitle=@"评价";
            if (![orderType isEqualToString:@"V"]&&![orderType isEqualToString:@"v"]) {
                if ([orderType isEqualToString:@"M"]||[orderType isEqualToString:@"O"]||[orderType isEqualToString:@"P"]||[orderType isEqualToString:@""]) {
                    if ([orderBack isEqualToString:@"yes"]) {
                        leftButtonTitle=@"返修/退换";
                    }else{
                        leftButtonTitle=@"删除订单";
                    }
                    
                }else{
                    leftButtonTitle=@"删除订单";
                }
            }else {
                self.leftButton.hidden=YES;
            }
            
            
        }if ([regTag isEqual:@1]){
            rightButtonTitle=@"查看评价";
            if (![orderType isEqualToString:@"V"]&&![orderType isEqualToString:@"v"]) {
                if ([orderType isEqualToString:@"M"]||[orderType isEqualToString:@"O"]||[orderType isEqualToString:@"P"]||[orderType isEqualToString:@""]) {
                    if ([orderBack isEqualToString:@"yes"]) {
                        leftButtonTitle=@"返修/退换";
                    }else{
                        leftButtonTitle=@"删除订单";
                    }
                }else{
                    leftButtonTitle=@"删除订单";
                }
            }else {
                self.leftButton.hidden=YES;
            }
            
            
        }
    }
    if ([sourceData[@"state_name"] isEqualToString:@"派送中"]) {
        self.leftButton.hidden=YES;
        if ([orderType isEqualToString:@"O"]||[orderType isEqualToString:@"P"]||[orderType isEqualToString:@""]) {
            
            rightButtonTitle=@"确认收货";
        }else{
            if ([orderBack isEqualToString:@"yes"]) {
                rightButtonTitle=@"返修/退换";
            }else{
                self.rightButton.hidden=YES;
            }
            
        }
    }
    [UIView performWithoutAnimation:^{
        [self.rightButton setTitle:rightButtonTitle forState:UIControlStateNormal];
        [self.leftButton setTitle:leftButtonTitle forState:UIControlStateNormal];
    }];
    if (self.leftButton.hidden&&self.rightButton.hidden) {
        self.buttonBgView.hidden = YES;
        self.topConstraint.constant = -CGRectGetHeight(self.buttonBgView.frame);
    }
}

- (IBAction)btnAction:(UIButton *)sender {
    if (self.btnActionBlock) {
        self.btnActionBlock(self.indexPath, [sender titleForState:UIControlStateNormal]);
    }
}

@end
