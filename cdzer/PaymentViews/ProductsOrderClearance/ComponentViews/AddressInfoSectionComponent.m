//
//  AddressInfoSectionComponent.m
//  cdzer
//
//  Created by KEns0nLau on 9/22/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "AddressInfoSectionComponent.h"
#import "MyAddressesVC.h"
#import "RepairShopSelectionVC.h"


@interface AddressInfoSectionForRegularParts ()

@property (weak, nonatomic) IBOutlet UILabel *consigneeNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *consigneePhoneLabel;

@property (weak, nonatomic) IBOutlet UILabel *consigneeAddressLabel;

@property (weak, nonatomic) IBOutlet UILabel *selectAddressRemindLabel;

@end
@implementation AddressInfoSectionForRegularParts

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.selectedAddressDTO = [DBHandler.shareInstance getUserDefaultAddress];
    [self addTarget:self action:@selector(pushToAddressSelection) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setSelectedAddressDTO:(AddressDTO *)selectedAddressDTO {
    _selectedAddressDTO = selectedAddressDTO;
    BOOL dataIsReady = (selectedAddressDTO.telNumber&&selectedAddressDTO.consigneeName&&selectedAddressDTO.address);
    self.selectAddressRemindLabel.hidden = dataIsReady;
    if (dataIsReady) {
        self.consigneeNameLabel.text = selectedAddressDTO.consigneeName;
        self.consigneePhoneLabel.text = selectedAddressDTO.telNumber;
        self.consigneeAddressLabel.text = selectedAddressDTO.address;
    }else {
        self.consigneeNameLabel.text = @"请选择收货人";
        self.consigneePhoneLabel.text = @"请选择电话";
        self.consigneeAddressLabel.text = @"请选择收货地址";
    }
}

- (IBAction)pushToAddressSelection {
    @autoreleasepool {
        BaseNavigationController *nav = (BaseNavigationController *)self.window.rootViewController;
        if (nav) {
            MyAddressesVC *vc = [MyAddressesVC new];
            vc.isForSelection = YES;
            vc.selectedDTO = self.selectedAddressDTO;
            @weakify(self);
            vc.resultBlock = ^(AddressDTO *selectedDTO) {
                @strongify(self);
                self.selectedAddressDTO = selectedDTO;
            };
            [nav.visibleViewController setDefaultNavBackButtonWithoutTitle];
            [nav pushViewController:vc animated:YES];
        }
    }
}

@end



@interface AddressInfoSectionForSpecRepair ()

@property (weak, nonatomic) IBOutlet UIView *autosSpecContainerView;

@property (weak, nonatomic) IBOutlet UIView *singelAutosSpecView;

@property (weak, nonatomic) IBOutlet UILabel *singleAutosInfoLabel;

@property (weak, nonatomic) IBOutlet UILabel *leftSideAutosInfoLabel;

@property (weak, nonatomic) IBOutlet UILabel *rightSideAutosTireInfoLabel;

@property (weak, nonatomic) IBOutlet UILabel *repairShopNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *repairShopAddressLabel;

@property (strong, nonatomic) NSString *shopTelNumber;

@end
@implementation AddressInfoSectionForSpecRepair

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self setViewBorderWithRectBorder:UIRectBorderTop|UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self.autosSpecContainerView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    
    BorderOffsetObject *offset = [BorderOffsetObject new];
    offset.leftUpperOffset = 4;
    offset.leftBottomOffset = offset.leftUpperOffset;
    [self.rightSideAutosTireInfoLabel setViewBorderWithRectBorder:UIRectBorderLeft borderSize:0.5 withColor:nil withBroderOffset:offset];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.translatesAutoresizingMaskIntoConstraints = NO;
}

- (void)updateUIData:(NSDictionary *)sourceData {
    BOOL isProductTypeOfTire = [sourceData[@"product_name"] isContainsString:@"轮胎"];
    UserSelectedAutosInfoDTO *selectedAutosDTO = [DBHandler.shareInstance getSelectedAutoData];
    self.singleAutosInfoLabel.text = [selectedAutosDTO.seriesName stringByAppendingString:selectedAutosDTO.modelName];
    self.leftSideAutosInfoLabel.text = self.singleAutosInfoLabel.text;
    self.rightSideAutosTireInfoLabel.text = selectedAutosDTO.selectedTireSpec;
    self.singelAutosSpecView.hidden = isProductTypeOfTire;
    self.repairShopNameLabel.text = sourceData[@"wxs_name"];
    self.repairShopAddressLabel.text = sourceData[@"wxs_address"];
    self.shopTelNumber = [SupportingClass verifyAndConvertDataToString:sourceData[@"wxs_tel"]];
}


- (IBAction)dailupTheTel {
    if (self.shopTelNumber&&![self.shopTelNumber isEqualToString:@""]) {
        [SupportingClass makeACall:self.shopTelNumber andContents:[@"系统将会拨打以下号码：\n" stringByAppendingString:self.shopTelNumber] withTitle:@"温馨提示"];
    }else {
        [SupportingClass showAlertViewWithTitle:nil message:@"商家暂无提供电话信息！" isShowImmediate:YES cancelButtonTitle:nil otherButtonTitles:nil clickedButtonAtIndexWithBlock:nil];
    }
}

@end



@interface AddressInfoSectionForMaintenanceExpress ()

@property (weak, nonatomic) IBOutlet UILabel *consigneeNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *consigneePhoneLabel;

@property (weak, nonatomic) IBOutlet UIControl *consigneeContainerView;


@property (weak, nonatomic) IBOutlet UILabel *distributedDestinationLabel;

@property (weak, nonatomic) IBOutlet UIControl *distributedDestinationContainerView;

@property (nonatomic, strong) NSDictionary *selectedShopDetail;

@end
@implementation AddressInfoSectionForMaintenanceExpress

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [super layoutSubviews];
    [self setViewBorderWithRectBorder:UIRectBorderTop|UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self.consigneeContainerView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
}

- (void)setDefaultRepairShopID:(NSString *)repairShopID andRepairShopName:(NSString *)repairShopName {
    if (![repairShopName isEqualToString:@""]&&![repairShopID isEqualToString:@""]) {
        if (self.selectedShopDetail&&self.selectedShopDetail.count>3) {
            NSString *shopName = self.selectedShopDetail[@"wxs_name"];
            self.distributedDestinationLabel.text = shopName;
            self.repairShopWorkingPrice = [SupportingClass verifyAndConvertDataToString:self.selectedShopDetail[@"wxs_price"]];
            _repairShopID = self.selectedShopDetail[@"id"];
        }else {
            self.distributedDestinationLabel.text = repairShopName;
            self.repairShopWorkingPrice = @"0.00";
            _repairShopID = repairShopID;
        }
    }else {
        self.distributedDestinationLabel.text = @"请选择配送商家";
        self.repairShopWorkingPrice = @"0.00";
        _repairShopID = @"";
    }
}

- (void)setSelectedAddressDTO:(AddressDTO *)selectedAddressDTO {
    _selectedAddressDTO = selectedAddressDTO;
    self.consigneeNameLabel.text = @"请选择收货人";
    self.consigneePhoneLabel.text = @"请选择电话";
    if (selectedAddressDTO.telNumber&&selectedAddressDTO.consigneeName) {
        self.consigneeNameLabel.text = selectedAddressDTO.consigneeName;
        self.consigneePhoneLabel.text = selectedAddressDTO.telNumber;
    }
}

- (void)setRepairShopID:(NSString *)repairShopID {
    _repairShopID = repairShopID;
}

- (void)setRepairShopWorkingPrice:(NSString *)repairShopWorkingPrice {
    _repairShopWorkingPrice = repairShopWorkingPrice;
}

- (void)setSelectedShopDetail:(NSDictionary *)selectedShopDetail {
    _selectedShopDetail = selectedShopDetail;
    self.distributedDestinationLabel.text = @"请选择配送商家";
    if (selectedShopDetail&&selectedShopDetail.count>3) {
        NSString *shopName = selectedShopDetail[@"wxs_name"];
        self.distributedDestinationLabel.text = shopName;
    }
    self.repairShopWorkingPrice = [SupportingClass verifyAndConvertDataToString:self.selectedShopDetail[@"wxs_price"]];
    self.repairShopID = self.selectedShopDetail[@"id"];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.selectedAddressDTO = [DBHandler.shareInstance getUserDefaultAddress];
}

- (IBAction)pushToAddressSelection {
    @autoreleasepool {
        BaseNavigationController *nav = (BaseNavigationController *)self.window.rootViewController;
        if (nav) {
            MyAddressesVC *vc = [MyAddressesVC new];
            vc.isForSelection = YES;
            vc.selectedDTO = self.selectedAddressDTO;
            @weakify(self);
            vc.resultBlock = ^(AddressDTO *selectedDTO) {
                @strongify(self);
                self.selectedAddressDTO = selectedDTO;
            };
            [nav.visibleViewController setDefaultNavBackButtonWithoutTitle];
            [nav pushViewController:vc animated:YES];
        }
    }
}

- (IBAction)pushToShopSelection {
    @autoreleasepool {
        BaseNavigationController *nav = (BaseNavigationController *)self.window.rootViewController;
        if (nav) {
            RepairShopSelectionVC *vc = [RepairShopSelectionVC new];
            vc.isSelectionOnly = YES;
            vc.selectedMaintainItemList = self.maintainItemList;
            vc.selectedShopDetail = self.selectedShopDetail;
            @weakify(self);
            vc.resultBlock = ^(NSDictionary *selectedShopDetail) {
                @strongify(self);
                self.selectedShopDetail = selectedShopDetail;
            };
            [nav.visibleViewController setDefaultNavBackButtonWithoutTitle];
            [nav pushViewController:vc animated:YES];
        }
    }
}
@end
