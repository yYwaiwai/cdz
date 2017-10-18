//
//  MaintenanceItemDispalyViewCell.m
//  cdzer
//
//  Created by KEns0nLau on 9/12/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "MaintenanceItemDispalyViewCell.h"

@interface MaintenanceItemDispalyViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *productLogoImageView;

@property (weak, nonatomic) IBOutlet UILabel *productName;

@property (weak, nonatomic) IBOutlet UILabel *productCount;

@property (weak, nonatomic) IBOutlet UILabel *productPrice;

@property (weak, nonatomic) IBOutlet UIView *editingView;

@property (weak, nonatomic) IBOutlet UIButton *minusButton;

@property (weak, nonatomic) IBOutlet UILabel *countLabel;

@property (weak, nonatomic) IBOutlet UIButton *plusButton;

@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

@property (weak, nonatomic) IBOutlet UIButton *exchangeButton;

@property (nonatomic) NSUInteger productStockCount;

@property (nonatomic) NSUInteger currentSelectedCount;


@end

@implementation MaintenanceItemDispalyViewCell

- (void)layoutSubviews {
    [super layoutSubviews];
    BorderOffsetObject *broderOffset = [BorderOffsetObject new];
    broderOffset.bottomLeftOffset = CGRectGetMinX(self.editingView.frame);
    [self setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:broderOffset];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateUIData:(MaintenanceProductItemDTO *)dto wasEditingMode:(BOOL)editingMode {
    self.productLogoImageView.image = [ImageHandler getWhiteLogo];
    if ([dto.productLogo isContainsString:@"http"]) {
        [self.productLogoImageView setImageWithURL:[NSURL URLWithString:dto.productLogo] placeholderImage:ImageHandler .getWhiteLogo usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    self.editingView.hidden = !editingMode;
    self.productName.text = dto.productName;
    self.productCount.text = @(dto.currentSelectedCount).stringValue;
    self.countLabel.text = @(dto.currentSelectedCount).stringValue;
    self.productPrice.text = [NSString stringWithFormat:@"%0.2f", dto.productPrice.floatValue];
    self.productStockCount = dto.productStockCount;
    self.currentSelectedCount = dto.currentSelectedCount;
}

- (void)setProductStockCount:(NSUInteger)productStockCount {
    if (productStockCount>50) productStockCount = 50;
    _productStockCount = productStockCount;
}

- (IBAction)buttonAction:(UIButton *)sender {
    MIDVCButtonAction buttonAction = 0;
    BOOL wasTouch = NO;
    if (sender==self.minusButton) {
        wasTouch = YES;
        buttonAction = MIDVCButtonActionOfProductCountMinus;
    }
    if (sender==self.plusButton) {
        wasTouch = YES;
        buttonAction = MIDVCButtonActionOfProductCountPlus;
    }
    if (sender==self.deleteButton) {
        wasTouch = YES;
        buttonAction =MIDVCButtonActionOfProductDelete;
    }
    if (sender==self.exchangeButton) {
        wasTouch = YES;
        buttonAction = MIDVCButtonActionOfProductExchange;
    }
    [self updateCountLabel:sender];
    if (self.actionBlock&&wasTouch) {
        self.actionBlock(buttonAction, self.indexPath);
    }
}

- (void)updateCountLabel:(UIButton *)sender {
    if (sender==self.minusButton) {
        self.currentSelectedCount--;
    }
    if (sender==self.plusButton) {
        self.currentSelectedCount++;
    }
    if (self.currentSelectedCount<=0) self.currentSelectedCount = 1;
    if (self.currentSelectedCount>=self.productStockCount) self.currentSelectedCount = self.productStockCount;
    
    self.countLabel.text = @(self.currentSelectedCount).stringValue;
}

@end
