//
//  EServiceServiceListCell.m
//  cdzer
//
//  Created by KEns0nLau on 6/8/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "EServiceServiceListCell.h"
@interface  EServiceServiceListCell()

@property (nonatomic, weak) IBOutlet UIView *upperView;

@property (nonatomic, weak) IBOutlet UIView *bottomView;

@property (nonatomic, weak) IBOutlet UIButton *serviceTypeIV;

@property (nonatomic, weak) IBOutlet UIButton *serviceTypeLB;

@property (nonatomic, weak) IBOutlet UILabel *dateTimeLabel;

@property (nonatomic, weak) IBOutlet UILabel *statusTypeLabel;


@property (nonatomic, weak) IBOutlet UIImageView *consultantPortrait;

@property (nonatomic, weak) IBOutlet UILabel *consultantNameLabel;

@property (nonatomic, weak) IBOutlet UILabel *consultantPhoneLabel;

@property (nonatomic, weak) IBOutlet UIImageView *userAutosLogoIV;

@property (nonatomic, weak) IBOutlet UILabel *userAutosSeriesLabel;

@property (nonatomic, weak) IBOutlet UILabel *addressLabel;


@property (nonatomic, weak) IBOutlet UIView *appiontmentButtonsContainer;

@property (nonatomic, weak) IBOutlet UIView *allButtonsContainer;

@property (nonatomic, weak) IBOutlet UIButton *confirmAutosReturnBtn;

@property (nonatomic, weak) IBOutlet UIButton *cancelOrderBtn;

@property (nonatomic, weak) IBOutlet UIButton *commentOrderBtn;

@property (nonatomic, weak) IBOutlet UIButton *reviewCommentBtn;


@property (nonatomic, strong) UIImage *consultantDefaultPortraitImage;


@end

@implementation EServiceServiceListCell

- (void)layoutBorderSetup {
    @autoreleasepool {
        [self.userAutosSeriesLabel setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:5.0f];
        BorderOffsetObject *offset = [BorderOffsetObject new];
        offset.bottomLeftOffset = 12.0f;
        offset.bottomRightOffset = offset.bottomLeftOffset;
        [self.upperView setViewBorderWithRectBorder:UIRectBorderTop borderSize:0.5 withColor:[UIColor colorWithRed:0.839 green:0.843 blue:0.863 alpha:1.00] withBroderOffset:offset];
        [self.upperView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:[UIColor colorWithRed:0.839 green:0.843 blue:0.863 alpha:1.00] withBroderOffset:offset];
        
        offset.upperLeftOffset = offset.bottomLeftOffset;
        offset.upperRightOffset = offset.bottomLeftOffset;
        [self.bottomView setViewBorderWithRectBorder:UIRectBorderTop borderSize:0.5 withColor:[UIColor colorWithRed:0.839 green:0.843 blue:0.863 alpha:1.00] withBroderOffset:offset];
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self layoutBorderSetup];
    self.consultantDefaultPortraitImage = self.consultantPortrait.image;
    [self.bottomView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull firstView, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([firstView isKindOfClass:UIButton.class]) {
            [firstView setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:5.0f];
        }else {
            [firstView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull secondView, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([secondView isKindOfClass:UIButton.class]) {
                    [secondView setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:5.0f];
                }
            }];
        }
        
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self layoutBorderSetup];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)buttonAction:(UIButton *)sender {
    if (self.actionBlock) {
        self.actionBlock (self.indexPath, sender.tag);
    }
}

- (void)setServiceType:(EServiceType)serviceType {
    _serviceType = serviceType;
}

- (void)updateCellConfig:(NSDictionary *)configDetail {
    
//    "addTime":"暂无",
//    "address":"湖南省长沙市岳麓区麓枫路46号",
//    "carImg":"http://x.autoimg.cn/app/image/brand/33_3.png",
//    "carNumber":"湘A46790",
//    "name":"",
//    "order_state":"未付款",
//    "pid":"ER160513154640141495",
//    "regTag":"0",
//    "state":"代赔取消",
//    "tel":"",
//    "type":"e代赔",
//    "wxsName":"暂无"
    NSString *serviceTypeStr = configDetail[@"type"];
    if ([serviceTypeStr isEqualToString:@"e代修"]) self.serviceType = EServiceTypeOfERepair;
    if ([serviceTypeStr isEqualToString:@"e代检"]) self.serviceType = EServiceTypeOfEInspect;
    if ([serviceTypeStr isEqualToString:@"e代赔"]) self.serviceType = EServiceTypeOfEInsurance;
    NSString *serviceStatusStr = configDetail[@"state"];
    NSString *orderStatusStr = configDetail[@"order_state"];
    NSString *dateTime = configDetail[@"create_time"];
    NSString *address = [SupportingClass verifyAndConvertDataToString:configDetail[@"address"]];
    NSString *autosImages = configDetail[@"carImg"];
    NSString *autosNumber = [SupportingClass verifyAndConvertDataToString:configDetail[@"carNumber"]];
    NSString *consultantImgURL = configDetail[@"face_img"];
    NSString *consultantName = [SupportingClass verifyAndConvertDataToString:configDetail[@"name"]];
    if ([consultantName isEqualToString:@""]) consultantName = @"--";
    NSString *consultantTel = [SupportingClass verifyAndConvertDataToString:configDetail[@"tel"]];
    if ([consultantTel isEqualToString:@""]) consultantTel = @"--";
    NSNumber *isCommented = [SupportingClass verifyAndConvertDataToNumber:configDetail[@"regTag"]];
    
    self.consultantPortrait.image = self.consultantDefaultPortraitImage;
    self.userAutosLogoIV.image = [ImageHandler getWhiteLogo];
    
    self.serviceTypeIV.selected = (self.serviceType==EServiceTypeOfEInspect);
    self.serviceTypeIV.enabled = !(self.serviceType==EServiceTypeOfEInsurance);
    self.serviceTypeLB.selected = (self.serviceType==EServiceTypeOfEInspect);
    self.serviceTypeLB.enabled = !(self.serviceType==EServiceTypeOfEInsurance);
    self.dateTimeLabel.text = dateTime;
    self.statusTypeLabel.text = [orderStatusStr stringByAppendingFormat:@"-%@", serviceStatusStr];
    self.addressLabel.text = address;
    self.consultantNameLabel.text = consultantName;
    self.consultantPhoneLabel.text = consultantTel;
    self.allButtonsContainer.hidden = YES;
    self.appiontmentButtonsContainer.hidden = YES;
    if (![serviceStatusStr isContainsString:@"取消"]) {
        self.confirmAutosReturnBtn.hidden = YES;
        self.cancelOrderBtn.hidden = YES;
        self.reviewCommentBtn.hidden = YES;
        self.commentOrderBtn.hidden = YES;
        if ([serviceStatusStr isContainsString:@"等待接车"]) {
            self.cancelOrderBtn.hidden = NO;
            self.allButtonsContainer.hidden = NO;
        }
        if ([serviceStatusStr isContainsString:@"中"]) {
            self.allButtonsContainer.hidden = NO;
            self.confirmAutosReturnBtn.hidden = NO;
        }
        if ([serviceStatusStr isContainsString:@"预约成功"]) {
            BOOL orderWasPaid = [orderStatusStr isContainsString:@"已付款"];
            self.allButtonsContainer.hidden = !orderWasPaid;
            self.appiontmentButtonsContainer.hidden = orderWasPaid;
            self.cancelOrderBtn.hidden = !orderWasPaid;
        }
        if ([serviceStatusStr isContainsString:@"完成"]) {
            self.allButtonsContainer.hidden = NO;
            self.commentOrderBtn.hidden = isCommented.boolValue;
            self.reviewCommentBtn.hidden = !isCommented.boolValue;
        }
    }
    
    if ([autosImages isContainsString:@"http"]) {
        [self.userAutosLogoIV setImageWithURL:[NSURL URLWithString:autosImages] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    if ([consultantImgURL isContainsString:@"http"]) {
        [self.consultantPortrait setImageWithURL:[NSURL URLWithString:consultantImgURL] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    
}

@end
