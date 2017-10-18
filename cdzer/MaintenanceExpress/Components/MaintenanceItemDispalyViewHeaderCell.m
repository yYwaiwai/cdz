//
//  MaintenanceItemDispalyViewHeaderCell.m
//  cdzer
//
//  Created by KEns0nLau on 9/12/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "MaintenanceItemDispalyViewHeaderCell.h"
#import "UIView+LayoutConstraintHelper.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <SDWebImage/UIImageView+HighlightedWebCache.h>

@interface MaintenanceItemDispalyViewHeaderContentView : UIView

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;

@property (nonatomic, weak) IBOutlet UIImageView *titleImageView;

@property (nonatomic, weak) IBOutlet UIButton *editingButton;

@property (nonatomic, weak) IBOutlet UIButton *displayButton;

@property (nonatomic, weak) IBOutlet UIView *iconsButtonView;

@property (nonatomic, weak) IBOutlet UIButton *saveButton;

@end

@implementation MaintenanceItemDispalyViewHeaderContentView

@end



@interface MaintenanceItemDispalyViewHeaderCell ()
{
    __weak IBOutlet MaintenanceItemDispalyViewHeaderContentView *_contentView;
}

@end

@implementation MaintenanceItemDispalyViewHeaderCell

- (void)updateUIData:(MaintenanceTypeDTO *)dto {
    BOOL partsIsEmpty = (dto.maintenanceProductItemList.count==0);
    _contentView.iconsButtonView.hidden = dto.isEditing;
    _contentView.editingButton.hidden = dto.isEditing;
    _contentView.saveButton.hidden = !dto.isEditing;
    _contentView.displayButton.selected = dto.isSelectedItem;
    _contentView.titleLabel.text = dto.maintenanceTypeName;
    _contentView.iconsButtonView.hidden = partsIsEmpty;
    _contentView.titleImageView.highlighted = (!partsIsEmpty&&dto.isSelectedItem);
    if ([dto.maintenanceTypeCheckIcon isContainsString:@"http"]) {
        [_contentView.titleImageView sd_setHighlightedImageWithURL:[NSURL URLWithString:dto.maintenanceTypeCheckIcon]];
    }
    if ([dto.maintenanceTypeUncheckIcon isContainsString:@"http"]) {
        [_contentView.titleImageView sd_setImageWithURL:[NSURL URLWithString:dto.maintenanceTypeUncheckIcon]];
    }
}

- (UIView *)contentView {
    return _contentView;
}

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        [[UINib nibWithNibName:@"MaintenanceItemDispalyViewHeaderContentView" bundle:nil] instantiateWithOwner:self options:nil];
        self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSelfByFourMarginToSuperview:self];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    BorderOffsetObject *borderOffset = [BorderOffsetObject new];
    borderOffset.bottomLeftOffset = 12;
    [self.contentView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:borderOffset];
}

- (IBAction)buttonAction:(UIButton *)sender {
    MIDVHCButtonAction buttonAction = MIDVHCButtonActionOfDetailExpand;
    if (sender==_contentView.editingButton)
    {
        _contentView.displayButton.hidden=YES;
        buttonAction = MIDVHCButtonActionOfEditing;
    }
    if (sender==_contentView.saveButton)
    {
        _contentView.displayButton.hidden=NO;
        buttonAction = MIDVHCButtonActionOfUpdateChange;
    }
    if (self.actionBlock) {
        self.actionBlock(buttonAction, self.sectionIdx);
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
