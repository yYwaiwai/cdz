//
//  MaintenanceExpressVC.m
//  cdzer
//
//  Created by KEns0nLau on 9/10/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "MaintenanceExpressVC.h"
#import "MaintenanceItemObjectComponent.h"
#import "MaintenanceItemDispalyView.h"
#import "MaintainProjectSelectionVC.h"
#import "UserAutosSelectonVC.h"
#import "UserLocationHandler.h"
#import "MaintenanceRecordVC.h"
#import "MyCarVC.h"
#import "CDZOrderPaymentClearanceVC.h"

@interface MaintenanceExpressVC ()<UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UIView *autosMaintenanceInfoView;

@property (nonatomic, weak) IBOutlet UIControl *maintenanceSelectedInfoView;

@property (nonatomic, weak) IBOutlet MaintenanceItemDispalyView *regularMaintenanceItemView;

@property (nonatomic, weak) IBOutlet MaintenanceItemDispalyView *deepMaintenanceItemView;

@property (nonatomic, weak) IBOutlet UILabel *start2DriveDateTimeLabel;

@property (nonatomic, weak) IBOutlet UILabel *mileageLabel;

@property (nonatomic, weak) IBOutlet UILabel *totalSelectedMainTypeCountLabel;

@property (nonatomic, weak) IBOutlet UILabel *totalSelectedSubTypeCountLabel;

@property (nonatomic, weak) IBOutlet UILabel *totalPriceLabel;


@property (nonatomic, weak) IBOutlet UIView *headerContentView;

@property (nonatomic, weak) IBOutlet UIView *logoImageContainer;

@property (nonatomic, weak) IBOutlet UIImageView *logoImage;

@property (nonatomic, weak) IBOutlet UILabel *selectedAutosLabel;

@property (nonatomic, weak) IBOutlet UILabel *selectAutosHintLabel;

@property (nonatomic, strong) UIImage *autoDefaultImage;


@property (nonatomic, strong) UserSelectedAutosInfoDTO *autosSelectedData;

@property (nonatomic, strong) UserSelectedAutosInfoDTO *tmpAutosSelectedData;

@property (nonatomic, strong) NSString *start2DriveDateTime;

@property (nonatomic, strong) NSString *totalMileage;

@property (nonatomic, strong) UIDatePicker *datePicker;

@property (nonatomic, strong) UIToolbar *toolbar;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic, strong) NSMutableArray *maintenanceSelectionList;

@property (nonatomic, strong) NSMutableSet <NSIndexPath *> *regularMaintenanceSelectedList;

@property (nonatomic, strong) NSMutableSet <NSIndexPath *> *deepMaintenanceSelectedList;

@property (nonatomic, strong) NSMutableArray <NSArray *> *dataSourceList;

@property (nonatomic, assign) BOOL wasFirstLoaded;

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@property (nonatomic, strong) NSString *cityName;


@property (weak, nonatomic) IBOutlet UITextField *start2DriveDateTimeTest;

@property (nonatomic, strong) UIView *mileageBGView;

@property (nonatomic, strong) UITextField *mileageTF;

@end

@implementation MaintenanceExpressVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
    [NSNotificationCenter.defaultCenter removeObserver:self];
    [UserLocationHandler.shareInstance stopUserLocationService];
}

- (void)viewDidLoad {
    self.title = @"快速保养";
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self componentSetting];
    [self initializationUI];
    [self setReactiveRules];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.regularMaintenanceItemView.maintenanceItemList.count==0&&
        self.deepMaintenanceItemView.maintenanceItemList.count==0) {
        if (self.wasFirstLoaded) {
            UserSelectedAutosInfoDTO *autosData = [DBHandler.shareInstance getSelectedAutoData];
            if (!self.autosSelectedData||
                autosData.brandID!=self.autosSelectedData.brandID||
                autosData.dealershipID!=self.autosSelectedData.dealershipID||
                autosData.seriesID!=self.autosSelectedData.seriesID||
                autosData.modelID!=self.autosSelectedData.modelID) {
                self.autosSelectedData = autosData;
                
                if (self.autosSelectedData.isSelectFromOnline) {
                    UserAutosInfoDTO *userAutosDetail = [DBHandler.shareInstance getUserAutosDetail];
                    self.start2DriveDateTime = userAutosDetail.registrTime;
                    self.totalMileage = userAutosDetail.mileage;
                }else {
                    self.start2DriveDateTime = nil;
                    self.totalMileage = nil;
                }
                if (self.regularMaintenanceSelectedList.count>0||self.deepMaintenanceSelectedList.count>0) {
                    [self getMaintenanceList];
                }else {
                    [self getRecommendMaintenanceList];
                }
            }
        }else {
            self.autosSelectedData = [DBHandler.shareInstance getSelectedAutoData];
            if (self.autosSelectedData.isSelectFromOnline) {
                UserAutosInfoDTO *userAutosDetail = [DBHandler.shareInstance getUserAutosDetail];
                self.start2DriveDateTime = userAutosDetail.registrTime;
                self.totalMileage = userAutosDetail.mileage;
            }
            [self defaultMaintenanceList];
        }
    }else{
        UserSelectedAutosInfoDTO *autosData = [DBHandler.shareInstance getSelectedAutoData];
        if (!self.autosSelectedData||
            autosData.brandID!=self.autosSelectedData.brandID||
            autosData.dealershipID!=self.autosSelectedData.dealershipID||
            autosData.seriesID!=self.autosSelectedData.seriesID||
            autosData.modelID!=self.autosSelectedData.modelID) {
            self.autosSelectedData = autosData;
        }
        if (self.autosSelectedData.isSelectFromOnline) {
            UserAutosInfoDTO *userAutosDetail = [DBHandler.shareInstance getUserAutosDetail];
            self.start2DriveDateTime = userAutosDetail.registrTime;
            self.totalMileage = userAutosDetail.mileage;
        }else {
            self.start2DriveDateTime = nil;
            self.totalMileage = nil;
        }

    }
    [self updateHeaderStatus];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.mileageTF resignFirstResponder];
    [self.start2DriveDateTimeTest resignFirstResponder];
    [self.mileageBGView removeFromSuperview];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self.autosMaintenanceInfoView setViewBorderWithRectBorder:UIRectBorderTop|UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    BorderOffsetObject *borderOffset = [BorderOffsetObject new];
    borderOffset.rightUpperOffset = 8;
    borderOffset.rightBottomOffset = borderOffset.rightUpperOffset;
    [[self.autosMaintenanceInfoView viewWithTag:100] setViewBorderWithRectBorder:UIRectBorderRight borderSize:0.5 withColor:nil withBroderOffset:borderOffset];
    
    //Hint View
    [[self.view viewWithTag:101] setViewBorderWithRectBorder:UIRectBorderTop borderSize:0.5 withColor:nil withBroderOffset:nil];
    
    [self.maintenanceSelectedInfoView setViewBorderWithRectBorder:UIRectBorderTop|UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    
    [self.logoImageContainer setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:CGRectGetHeight(self.logoImageContainer.frame)/2.0f];
    [self.logoImage setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:CGRectGetHeight(self.logoImage.frame)/2.0f];
}

- (void)componentSetting {
    @autoreleasepool {
        
        [self setRightNavButtonWithTitleOrImage:@"记录" style:UIBarButtonItemStylePlain target:self action:@selector(pushToMyMaintenanceRecordVC) titleColor:nil isNeedToSet:YES];
        
        self.regularMaintenanceSelectedList = [NSMutableSet set];
        self.deepMaintenanceSelectedList = [NSMutableSet set];
        self.dataSourceList = [@[] mutableCopy];
        NSDictionary *serviceDetail = DBHandler.shareInstance.getMaintenanceServiceList;
        if (serviceDetail.count&&serviceDetail) {
            [self.dataSourceList addObjectsFromArray:@[serviceDetail[CDZObjectKeyOfConventionMaintain],
                                                       serviceDetail[CDZObjectKeyOfDeepnessMaintain]]];
        }
        
        [self updateUserLocation];
        self.autoDefaultImage = self.logoImage.image;
        self.deepMaintenanceItemView.isDeepMaintenanceItem = YES;
        @weakify(self);
        MIDVReloadResponsBlock reloadResponsBlock = ^{
            @strongify(self);
            float totalPrice = self.regularMaintenanceItemView.getTotalPrice+self.deepMaintenanceItemView.getTotalPrice;
            self.totalPriceLabel.text = [NSString stringWithFormat:@"%0.02f", totalPrice];
            [self updateSelectedTitle];
        };
        self.regularMaintenanceItemView.reloadResponsBlock = reloadResponsBlock;
        self.deepMaintenanceItemView.reloadResponsBlock = reloadResponsBlock;
        
        
        MIDVOtherDataSourceCountingBlock countingBlock = ^(MaintenanceItemDispalyView *displayView){
            @strongify(self);
            NSUInteger counting = 0;
            if (displayView==self.regularMaintenanceItemView) {
                for (int count=0; count<self.deepMaintenanceItemView.maintenanceItemList.count; count++) {
                    counting += self.deepMaintenanceItemView.maintenanceItemList[count].maintenanceProductItemList.count;
                }
            }
            if (displayView==self.deepMaintenanceItemView) {
                for (int count=0; count<self.regularMaintenanceItemView.maintenanceItemList.count; count++) {
                    counting += self.regularMaintenanceItemView.maintenanceItemList[count].maintenanceProductItemList.count;
                }
            }
            return counting;
        };
        self.regularMaintenanceItemView.otherSourceCountingBlock = countingBlock;
        self.deepMaintenanceItemView.otherSourceCountingBlock = countingBlock;
        
    }
}

- (void)initializationUI {
    @autoreleasepool {
        self.dateFormatter = [NSDateFormatter new];
        [self.dateFormatter setDateFormat:@"yyyy-MM-dd"];
        
        self.datePicker = [UIDatePicker new];
        self.datePicker.backgroundColor = CDZColorOfWhite;
        [self.datePicker addTarget:self action:@selector(dateChangeFromDatePicker:) forControlEvents:UIControlEventValueChanged];
        self.datePicker.datePickerMode = UIDatePickerModeDate;
        
        
        self.toolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth([UIScreen mainScreen].bounds), 40.0f)];
        [self.toolbar setBarStyle:UIBarStyleDefault];
        UIBarButtonItem *spaceButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                    target:self
                                                                                    action:nil];
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]initWithTitle:getLocalizationString(@"finish")
                                                                      style:UIBarButtonItemStyleDone
                                                                     target:self
                                                                     action:@selector(hiddenKeyboard)];
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]initWithTitle:@"取消"
                                                                      style:UIBarButtonItemStyleDone
                                                                     target:self
                                                                     action:@selector(cancelKeyboard)];
        doneButton.tintColor = [UIColor colorWithHexString:@"6DD2F7"];
        cancelButton.tintColor = [UIColor colorWithHexString:@"6DD2F7"];
        NSArray * buttonsArray = [NSArray arrayWithObjects:cancelButton,spaceButton,doneButton,nil];
        [self.toolbar setItems:buttonsArray];
        
    }
}

- (void)setReactiveRules {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateHeaderStatus {
    BOOL userAutosInfoExist = (self.autosSelectedData.brandID.integerValue>0&&
                               self.autosSelectedData.dealershipID.integerValue>0&&
                               self.autosSelectedData.seriesID.integerValue>0&&
                               self.autosSelectedData.modelID.integerValue>0);
    self.headerContentView.hidden = !userAutosInfoExist;
    self.selectAutosHintLabel.hidden = userAutosInfoExist;
    self.selectedAutosLabel.text = @"";
    self.logoImage.image = self.autoDefaultImage;
    if (userAutosInfoExist) {
        self.selectedAutosLabel.text = [NSString stringWithFormat:@"%@ %@ %@ %@",self.autosSelectedData.brandName, self.autosSelectedData.dealershipName, self.autosSelectedData.seriesName, self.autosSelectedData.modelName];
        
        if ([self.autosSelectedData.brandImgURL isContainsString:@"http"]) {
            [self.logoImage setImageWithURL:[NSURL URLWithString:self.autosSelectedData.brandImgURL] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        }
    }
    
    
    self.start2DriveDateTimeLabel.text = self.start2DriveDateTime;
    if (!self.start2DriveDateTime||[self.start2DriveDateTime isEqualToString:@""]) {
        self.start2DriveDateTimeLabel.text = @"--";
    }
    
    self.mileageLabel.text = self.totalMileage;
    if (!self.totalMileage||[self.totalMileage isEqualToString:@""]) {
        self.mileageLabel.text = @"0";
    }
}

- (void)defaultMaintenanceList {
    if (!self.autosSelectedData.seriesID||!self.autosSelectedData.modelID) {
        [SupportingClass showAlertViewWithTitle:@"" message:@"请选择需要保养的汽车型号！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
        }];
        return;
    }
    [ProgressHUDHandler showHUD];
    @weakify(self);
    [APIsConnection.shareConnection maintenanceExpressAPIsGetMaintenanceListWithItemsList:@[] seriesID:self.autosSelectedData.seriesID modelID:self.autosSelectedData.modelID success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@--%@",message,operation.currentRequest.URL.absoluteString);
        if (errorCode!=0) {
            [ProgressHUDHandler dismissHUD];
            [SupportingClass showAlertViewWithTitle:@"" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            }];
            return ;
        }
        [ProgressHUDHandler dismissHUD];
        [self updateAllMaintenanceList:responseObject[CDZKeyOfResultKey] sourceFromManualSelected:NO];
        self.wasFirstLoaded = YES;
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        @strongify(self);
        [ProgressHUDHandler dismissHUD];
        if (error.code==-1009) {
            [SupportingClass showAlertViewWithTitle:@"error" message:@"网络连接失败，请检查网络设置！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            }];
            return;
        }
        
        
        if (error.code==-1001) {
            [SupportingClass showAlertViewWithTitle:@"error" message:@"网络连接逾时，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            }];
            return;
        }
        
        [SupportingClass showAlertViewWithTitle:@"error" message:@"网络错误，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
        }];
        
    }];
}

- (void)getRecommendMaintenanceList {
    if (!self.autosSelectedData.seriesID||!self.autosSelectedData.modelID) {
        [SupportingClass showAlertViewWithTitle:@"" message:@"请选择需要保养的汽车型号！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
        }];
        return;
    }
    
    if (!self.start2DriveDateTime||[self.start2DriveDateTime isEqualToString:@""]) {
        [SupportingClass showAlertViewWithTitle:@"" message:@"请输入上牌时间" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
        }];
        return;
    }
    
    if (!self.totalMileage||[self.totalMileage isEqualToString:@""]) {
        [SupportingClass showAlertViewWithTitle:@"" message:@"请输入当前里数" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
        }];
        return;
    }
    @weakify(self);
    [ProgressHUDHandler showHUD];
    [APIsConnection.shareConnection maintenanceExpressAPIsGetMaintenanceRecommendListWithStartToDriveDateTime:self.start2DriveDateTime mileage:self.totalMileage seriesID:self.autosSelectedData.seriesID modelID:self.autosSelectedData.modelID success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@  %@",message,operation.currentRequest.URL.absoluteString);
        if (errorCode!=0) {
            [ProgressHUDHandler dismissHUD];
            [SupportingClass showAlertViewWithTitle:@"" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            }];
            return ;
        }
        [ProgressHUDHandler dismissHUD];
        self.totalSelectedMainTypeCountLabel.text = @"0";
        self.totalSelectedSubTypeCountLabel.text = @"0";
        [self updateAllMaintenanceList:responseObject[CDZKeyOfResultKey] sourceFromManualSelected:NO];
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        @strongify(self);
        [ProgressHUDHandler dismissHUD];
        if (error.code==-1009) {
            [SupportingClass showAlertViewWithTitle:@"error" message:@"网络连接失败，请检查网络设置！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            }];
            return;
        }
        
        
        if (error.code==-1001) {
            [SupportingClass showAlertViewWithTitle:@"error" message:@"网络连接逾时，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            }];
            return;
        }
        
        [SupportingClass showAlertViewWithTitle:@"error" message:@"网络错误，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
        }];
        
    }];
}

- (void)getMaintenanceList {
    if (!self.autosSelectedData.seriesID||!self.autosSelectedData.modelID) {
        [SupportingClass showAlertViewWithTitle:@"" message:@"请选择需要保养的汽车型号！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
        }];
        return;
    }
    NSMutableArray *maintanceSelectedItemList = [NSMutableArray array];
    if (self.regularMaintenanceSelectedList.count>0) {
        NSArray *list = [self.dataSourceList[0] valueForKey:@"id"];
        NSMutableIndexSet *set = [NSMutableIndexSet indexSet];
        [self.regularMaintenanceSelectedList enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull indexPath, BOOL * _Nonnull stop) {
            [set addIndex:indexPath.row];
        }];
        [maintanceSelectedItemList addObjectsFromArray:[list objectsAtIndexes:set]];
        
    }
    if (self.deepMaintenanceSelectedList.count>0) {
        NSArray *list = [self.dataSourceList[1] valueForKey:@"id"];
        NSMutableIndexSet *set = [NSMutableIndexSet indexSet];
        [self.deepMaintenanceSelectedList enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull indexPath, BOOL * _Nonnull stop) {
            [set addIndex:indexPath.row];
        }];
        [maintanceSelectedItemList addObjectsFromArray:[list objectsAtIndexes:set]];
    }
    
    [ProgressHUDHandler showHUD];
    @weakify(self);
    [APIsConnection.shareConnection maintenanceExpressAPIsGetMaintenanceListWithItemsList:maintanceSelectedItemList seriesID:self.autosSelectedData.seriesID modelID:self.autosSelectedData.modelID success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        if (errorCode!=0) {
            [ProgressHUDHandler dismissHUD];
            [SupportingClass showAlertViewWithTitle:@"" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            }];
            return ;
        }
        [ProgressHUDHandler dismissHUD];
        [self updateAllMaintenanceList:responseObject[CDZKeyOfResultKey] sourceFromManualSelected:YES];
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        @strongify(self);
        [ProgressHUDHandler dismissHUD];
        if (error.code==-1009) {
            [SupportingClass showAlertViewWithTitle:@"error" message:@"网络连接失败，请检查网络设置！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            }];
            return;
        }
        
        
        if (error.code==-1001) {
            [SupportingClass showAlertViewWithTitle:@"error" message:@"网络连接逾时，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            }];
            return;
        }
        
        [SupportingClass showAlertViewWithTitle:@"error" message:@"网络错误，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
        }];
        
    }];
}

- (void)updateAllMaintenanceList:(NSDictionary *)sourceData sourceFromManualSelected:(BOOL)manualSelected {

    NSArray <NSDictionary *> *regularMaintenanceTmpList = sourceData[@"service_info"];
    NSMutableArray <MaintenanceTypeDTO *> *regularMaintenanceList = [@[] mutableCopy];
    [regularMaintenanceTmpList enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull detail, NSUInteger idx, BOOL * _Nonnull stop) {
        MaintenanceTypeDTO *dto = [MaintenanceTypeDTO getMaintenanceTypeDTOBySourceData:detail];
        if (dto) {
            [regularMaintenanceList addObject:dto];
        }
    }];
    [self.regularMaintenanceItemView reloadDataSource:regularMaintenanceList];
   
    
    NSArray <NSDictionary *> *deepMaintenanceTmpList = sourceData[@"service_info_two"];
    NSMutableArray <MaintenanceTypeDTO *> *deepMaintenanceList = [@[] mutableCopy];
    [deepMaintenanceTmpList enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull detail, NSUInteger idx, BOOL * _Nonnull stop) {
        MaintenanceTypeDTO *dto = [MaintenanceTypeDTO getMaintenanceTypeDTOBySourceData:detail];
        if (dto) {
            [deepMaintenanceList addObject:dto];
        }
    }];
    [self.deepMaintenanceItemView reloadDataSource:deepMaintenanceList];
   
    if (!manualSelected) {
        if (self.dataSourceList.count==0) return;
        @weakify(self);
        [self.regularMaintenanceItemView.maintenanceItemList enumerateObjectsUsingBlock:^(MaintenanceTypeDTO * _Nonnull dto, NSUInteger idx, BOOL * _Nonnull stop) {
            @strongify(self);
            [self.dataSourceList[0] enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull detail, NSUInteger subIdx, BOOL * _Nonnull subStop) {
                NSString *name = detail[@"name"];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:subIdx inSection:0];
                if ([dto.maintenanceTypeName isContainsString:name]) {
                    [self.regularMaintenanceSelectedList addObject:indexPath];
                    *subStop = YES;
                }
            }];
        }];
        
        [self.deepMaintenanceItemView.maintenanceItemList enumerateObjectsUsingBlock:^(MaintenanceTypeDTO * _Nonnull dto, NSUInteger idx, BOOL * _Nonnull stop) {
            @strongify(self);
            [self.dataSourceList[1] enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull detail, NSUInteger subIdx, BOOL * _Nonnull subStop) {
                NSString *name = detail[@"name"];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:subIdx inSection:0];
                if ([dto.maintenanceTypeName isContainsString:name]) {
                    [self.deepMaintenanceSelectedList addObject:indexPath];
                    *subStop = YES;
                }
            }];
        }];
    }
    [self updateSelectedTitle];
}

- (void)updateSelectedTitle {
    __block NSUInteger totalCount = 0;
    [self.regularMaintenanceItemView.selelctedMaintenanceItemList enumerateObjectsUsingBlock:^(MaintenanceTypeDTO * _Nonnull dto, NSUInteger idx, BOOL * _Nonnull stop) {
        totalCount += dto.maintenanceProductItemList.count;
    }];
    
    [self.deepMaintenanceItemView.selelctedMaintenanceItemList enumerateObjectsUsingBlock:^(MaintenanceTypeDTO * _Nonnull dto, NSUInteger idx, BOOL * _Nonnull stop) {
        totalCount += dto.maintenanceProductItemList.count;
    }];
    self.totalSelectedSubTypeCountLabel.text = @(totalCount).stringValue;
    
    self.totalSelectedMainTypeCountLabel.text = @"0";
    if (self.regularMaintenanceItemView.selelctedMaintenanceItemList.count>0||self.deepMaintenanceItemView.selelctedMaintenanceItemList.count>0) {
        NSUInteger totalCount = self.regularMaintenanceItemView.selelctedMaintenanceItemList.count+
                                self.deepMaintenanceItemView.selelctedMaintenanceItemList.count;
        self.totalSelectedMainTypeCountLabel.text = @(totalCount).stringValue;
    }
}

- (void)pushToMyMaintenanceRecordVC {
    @autoreleasepool {
        if (!self.accessToken) {
            [self handleMissingTokenAction];
            return;
        }
        UserAutosInfoDTO *autosInfo = [DBHandler.shareInstance getUserAutosDetail];
        if ([autosInfo.brandID isEqualToString:@""]||[autosInfo.dealershipID isEqualToString:@""]||
            [autosInfo.seriesID isEqualToString:@""]||[autosInfo.modelID isEqualToString:@""]) {
            @weakify(self);
            [SupportingClass showAlertViewWithTitle:@"" message:@"使用保养记录前，请完善个人车辆信息！" isShowImmediate:YES cancelButtonTitle:@"cancel" otherButtonTitles:@"ok" clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                @strongify(self);
                if (btnIdx.integerValue>0) {
                    MyCarVC *vc = [MyCarVC new];
                    vc.wasSubmitAfterLeave = YES;
                    [self setDefaultNavBackButtonWithoutTitle];
                    [self.navigationController pushViewController:vc animated:YES];
                }
            }];
            return;
        }
        MaintenanceRecordVC *vc = [MaintenanceRecordVC new];
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)pushToMyAutosInfoVC {
    @autoreleasepool {
        UserAutosSelectonVC *vc = [UserAutosSelectonVC new];
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)MaintainProjectSelectionVC {
    if (!self.autosSelectedData.seriesID||!self.autosSelectedData.modelID) {
        [SupportingClass showAlertViewWithTitle:@"" message:@"请选择需要保养的汽车型号！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
        }];
        return;
    }
    @autoreleasepool {
        MaintainProjectSelectionVC *vc = [MaintainProjectSelectionVC new];
        vc.regularMaintenanceSelectedList = self.regularMaintenanceSelectedList;
        vc.deepMaintenanceSelectedList = self.deepMaintenanceSelectedList;
        vc.dataSourceList = self.dataSourceList;
        @weakify(self);
        vc.selectionBlock = ^(NSMutableSet <NSIndexPath *> *regularMaintenanceSelectedList,
                              NSMutableSet <NSIndexPath *> *deepMaintenanceSelectedList,
                              NSMutableArray <NSArray *> *dataSourceList) {
            @strongify(self);
            self.regularMaintenanceSelectedList = regularMaintenanceSelectedList;
            self.deepMaintenanceSelectedList = deepMaintenanceSelectedList;
            if (self.dataSourceList.count<2) {
                self.dataSourceList = dataSourceList;
                
            }
            if (self.regularMaintenanceSelectedList.count>0||self.deepMaintenanceSelectedList.count>0) {
                NSUInteger totalCount = self.regularMaintenanceSelectedList.count+self.deepMaintenanceSelectedList.count;
                self.totalSelectedMainTypeCountLabel.text = @(totalCount).stringValue;
                [self getMaintenanceList];
            }
            
        };
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)changeMileage {
    self.mileageBGView=[[UIView alloc]init];
    self.mileageBGView.frame=self.view.bounds;
    self.mileageBGView.backgroundColor=[UIColor colorWithHexString:@"676767" alpha:0.6];
    [self.view addSubview:self.mileageBGView];
    
    UIView *alertBGView=[[UIView alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.bounds)/6, CGRectGetMaxY(self.autosMaintenanceInfoView.frame)+10, CGRectGetWidth(self.view.bounds)*0.72, 100)];
    [self.mileageBGView addSubview:alertBGView];
    alertBGView.backgroundColor=[UIColor colorWithHexString:@"e2e2e2"];
    [alertBGView setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:10];
    
    self.mileageTF=[[UITextField alloc]initWithFrame:CGRectMake(12, 24, CGRectGetWidth(alertBGView.frame)-24, 28)];
    alertBGView.backgroundColor=CDZColorOfWhite;
    self.mileageTF.keyboardType =UIKeyboardTypeNumberPad;
    self.mileageTF.borderStyle=UITextBorderStyleNone;
    self.mileageTF.delegate = self;
    [alertBGView addSubview:self.mileageTF];
    [self.mileageTF setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:5];
    [self.mileageTF setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:0.5 withColor:nil withBroderOffset:nil];
    if (![self.mileageTF.text isEqualToString:@"0"]) {
        self.mileageTF.text=self.totalMileage;
    }
    
    
    UIButton *cancelButton=[[UIButton alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.mileageTF.frame)+10, CGRectGetWidth(alertBGView.bounds)/2, 35)];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [alertBGView addSubview:cancelButton];
    [cancelButton setTitleColor:CDZColorOfBlue forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton setViewBorderWithRectBorder:UIRectBorderRight|UIRectBorderTop borderSize:0.5 withColor:nil withBroderOffset:nil];
    
    UIButton *ensureButton=[[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(alertBGView.bounds)/2, CGRectGetMaxY(self.mileageTF.frame)+10, CGRectGetWidth(alertBGView.bounds)/2, 35)];
    [ensureButton setTitle:@"确定" forState:UIControlStateNormal];
    [alertBGView addSubview:ensureButton];
    [ensureButton setTitleColor:CDZColorOfBlue forState:UIControlStateNormal];
    [ensureButton setViewBorderWithRectBorder:UIRectBorderRight|UIRectBorderTop borderSize:0.5 withColor:nil withBroderOffset:nil];
    [ensureButton addTarget:self action:@selector(ensureButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
}

- (IBAction)changeStart2DriveDateTime {
    
    self.start2DriveDateTimeTest.inputView = self.datePicker;
    self.start2DriveDateTimeTest.inputAccessoryView = self.toolbar;
    [self.start2DriveDateTimeTest becomeFirstResponder];
    }

- (void)dateChangeFromDatePicker:(UIDatePicker *)datePicker {
    self.start2DriveDateTimeLabel.text = [self.dateFormatter stringFromDate:datePicker.date];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (self.start2DriveDateTimeTest==textField){
        NSDate *date = NSDate.date;//[NSDate dateWithTimeInterval:(2*60*60) sinceDate:NSDate.date];
        if (!self.start2DriveDateTimeLabel.text||[self.start2DriveDateTimeLabel.text isEqualToString:@"--"]) {
            self.start2DriveDateTime = [self.dateFormatter stringFromDate:date];
            self.start2DriveDateTimeLabel.text = self.start2DriveDateTime;
        }
        if (self.start2DriveDateTimeLabel.text.length>2) {
            textField.text = self.start2DriveDateTimeLabel.text;
            self.datePicker.date = [self.dateFormatter dateFromString:textField.text];
        }else{
            textField.text = [self.dateFormatter stringFromDate:self.datePicker.date];
            self.datePicker.date = [self.dateFormatter dateFromString:self.start2DriveDateTime];
        }
        self.datePicker.maximumDate = date;
    }else{
        
    }
}

- (void)hiddenKeyboard {
    if (self.start2DriveDateTimeTest) {
        self.start2DriveDateTime = self.start2DriveDateTimeLabel.text;
        [self.start2DriveDateTimeTest resignFirstResponder];
        if (self.totalMileage&&![self.totalMileage isEqualToString:@""]) {
            [self getRecommendMaintenanceList];
        }
    }
}

-(void)cancelKeyboard
{
    [self.start2DriveDateTimeTest resignFirstResponder];
    self.start2DriveDateTimeLabel.text=self.start2DriveDateTime;
}

-(void)cancelButtonClick{
    [self.mileageTF resignFirstResponder];
    [self.mileageBGView removeFromSuperview];
}

-(void)ensureButtonClick{
    [self.mileageTF resignFirstResponder];
    [self.mileageBGView removeFromSuperview];
    self.totalMileage=self.mileageTF.text;
    self.mileageLabel.text = self.totalMileage;
    if (self.start2DriveDateTime&&![self.start2DriveDateTime isEqualToString:@""]) {
        [self getRecommendMaintenanceList];
    }

}


- (IBAction)pushToProductsOrderClearance {
    @autoreleasepool {
        NSMutableArray *productList = [@[] mutableCopy];
        NSMutableArray *productCountList = [@[] mutableCopy];
        NSMutableArray *maintainItemList = [@[] mutableCopy];
        __block NSUInteger workingHours = 0;
        [self.regularMaintenanceItemView.selelctedMaintenanceItemList enumerateObjectsUsingBlock:^(MaintenanceTypeDTO * _Nonnull theTypeDTO, NSUInteger idx, BOOL * _Nonnull stop) {
            workingHours += theTypeDTO.maintenanceManHour.integerValue;
            [maintainItemList addObject:theTypeDTO.maintenanceTypeID];
            [theTypeDTO.maintenanceProductItemList enumerateObjectsUsingBlock:^(MaintenanceProductItemDTO * _Nonnull productItemDTO, NSUInteger idx, BOOL * _Nonnull stop) {
                [productList addObject:productItemDTO.productID];
                [productCountList addObject:@(productItemDTO.currentSelectedCount)];
            }];
        }];
        
        [self.deepMaintenanceItemView.selelctedMaintenanceItemList enumerateObjectsUsingBlock:^(MaintenanceTypeDTO * _Nonnull theTypeDTO, NSUInteger idx, BOOL * _Nonnull stop) {
            workingHours += theTypeDTO.maintenanceManHour.integerValue;
            [maintainItemList addObject:theTypeDTO.maintenanceTypeID];
            [theTypeDTO.maintenanceProductItemList enumerateObjectsUsingBlock:^(MaintenanceProductItemDTO * _Nonnull productItemDTO, NSUInteger idx, BOOL * _Nonnull stop) {
                [productList addObject:productItemDTO.productID];
                [productCountList addObject:@(productItemDTO.currentSelectedCount)];
            }];
        }];
        if (productList.count==0||productCountList.count==0) {
            [SupportingClass showAlertViewWithTitle:nil message:@"请至少选择一项保养项目" isShowImmediate:YES cancelButtonTitle:nil otherButtonTitles:nil clickedButtonAtIndexWithBlock:nil];
            return;
        }
        CDZOrderPaymentClearanceVC *vc = [CDZOrderPaymentClearanceVC new];
        vc.cityName = self.cityName;
        vc.coordinate = self.coordinate;
        vc.productList = productList;
        vc.workingHours = @(workingHours);
        vc.productCountList = productCountList;
        vc.maintainItemList = maintainItemList;
        vc.orderClearanceType = CDZOrderPaymentClearanceTypeOfMaintainExpress;
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)updateUserLocation {
    @weakify(self);
    [UserLocationHandler.shareInstance startUserLocationServiceWithBlock:^(BMKUserLocation *userLocation, NSError *error) {
        @strongify(self);
        if(!error) {
            [UserLocationHandler.shareInstance stopUserLocationService];
            self.coordinate = userLocation.location.coordinate;
            [UserLocationHandler.shareInstance reverseGeoCodeSearchWithCoordinate:self.coordinate resultBlock:^(BMKReverseGeoCodeResult *result, BMKSearchErrorCode error) {
                @strongify(self);
                if (!error) {
                    self.cityName = result.addressDetail.city;
                }else {
                    self.cityName = @"长沙市";
                }
            }];
        }else {
            self.cityName = @"长沙市";
            self.coordinate = CLLocationCoordinate2DMake(28.224610, 112.893959);
        }
    }];
}

@end
