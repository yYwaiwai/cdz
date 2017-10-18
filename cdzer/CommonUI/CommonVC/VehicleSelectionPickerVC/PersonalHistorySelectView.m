//
//  PersonalHistorySelectView.m
//  cdzer
//
//  Created by KEns0n on 5/8/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


#import "PersonalHistorySelectView.h"
#import "InsetsLabel.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UserSelectedAutosInfoDTO.h"
#import "UserAutosInfoDTO.h"

@interface PersonalHistorySelectView ()

@property (nonatomic, strong) UserAutosInfoDTO *userDto;

@property (nonatomic, strong) UserSelectedAutosInfoDTO *historyDto;

@property (nonatomic, strong) UserSelectedAutosInfoDTO *selectedDto;

@property (nonatomic, assign) BOOL isHistoryView;

@property (nonatomic, strong) UIImageView *logoImageView;

@property (nonatomic, strong) UIImageView *trickImageView;

@property (nonatomic, strong) InsetsLabel *carDetailLabel;

@property (nonatomic, strong) InsetsLabel *warningLabel;

@property (nonatomic, strong) NSString *iconURL;

@end

@implementation PersonalHistorySelectView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self componentSetting];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self componentSetting];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self componentSetting];
    }
    return self;
}

- (void)setIsReady:(NSNumber *)isReady {
    _isReady = nil;
    _isReady = isReady;
}

- (void)setIsSelected:(NSNumber *)isSelected {
    _isSelected = nil;
    _isSelected = isSelected;
}

- (void)setAutoData:(UserSelectedAutosInfoDTO *)autoData {
    @autoreleasepool {
        if (_autoData) {
            _autoData = nil;
        }
        _autoData = autoData;
    }
}

- (void)componentSetting {
    _isHistoryView = NO;
    self.isReady = @(NO);
    self.isSelected = @(NO);
    self.selectedDto = [DBHandler.shareInstance getSelectedAutoData];
    [self addTarget:self action:@selector(selectedSelf) forControlEvents:UIControlEventTouchUpInside];
}

#pragma Pubic Function Section
- (void)reloadData {
    self.historyDto = nil;
    self.userDto = nil;
    self.autoData = nil;
    [self setupUIInfoData];
}

- (void)selectedSelf {
    if (_isHistoryView) {
        if (!_historyDto) return;
    }else {
        if (!UserBehaviorHandler.shareInstance.getUserToken) return;
        if (!_userDto) return;
    }
        
    self.isSelected = @(YES);
    [self setBorderWithColor:CDZColorOfDefaultColor borderWidth:1.5f];
    self.autoData = [self getAutoDataWithFormat];
    self.trickImageView.hidden = NO;
}

- (void)deselectedSelf {
    self.isSelected = @(NO);
    [self setBorderWithColor:CDZColorOfClearColor borderWidth:1.5f];
    self.autoData = nil;
    self.trickImageView.hidden = YES;
}

- (void)initializationUIWasHistoryView:(BOOL)isHistoryView {
    self.isHistoryView = isHistoryView;
    
    NSString *title = isHistoryView?@"selected_history":@"personal_cars";
    NSString *warningTitle = isHistoryView?@"no_history_auto_data":((!UserBehaviorHandler.shareInstance.getUserToken)?@"user_auto_data_without_login":@"no_user_auto_data");
    
    CGFloat widthSpace = vAdjustByScreenRatio(15.0f);
    CGFloat heightSpace = vAdjustByScreenRatio(8.0f);
    
    self.backgroundColor = CDZColorOfWhite;
    
    InsetsLabel *titleLabel = [[InsetsLabel alloc] initWithFrame:CGRectMake(0.0f, heightSpace, CGRectGetWidth(self.frame), vAdjustByScreenRatio(25.0f))
                                                       andEdgeInsetsValue:UIEdgeInsetsMake(0.0f, widthSpace, 0.0f, widthSpace)];
    titleLabel.font = systemFontBold(16.0f);
    titleLabel.textColor = CDZColorOfDeepGray;
    titleLabel.text = getLocalizationString(title);
    [self addSubview:titleLabel];
    
    self.logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(widthSpace, CGRectGetMaxY(titleLabel.frame)+heightSpace, vAdjustByScreenRatio(70.0f), vAdjustByScreenRatio(70.0f))];
    [_logoImageView setImage:[ImageHandler getWhiteLogo]];
    [self addSubview:_logoImageView];
    
    self.carDetailLabel = [[InsetsLabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_logoImageView.frame)+heightSpace,
                                                                                CGRectGetMinY(_logoImageView.frame),
                                                                                CGRectGetWidth(self.frame)-CGRectGetMaxX(_logoImageView.frame)-heightSpace-widthSpace,
                                                                                CGRectGetHeight(_logoImageView.frame))
                                                           andEdgeInsetsValue:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
    _carDetailLabel.font = systemFont(16.0f);
    _carDetailLabel.textColor = CDZColorOfBlack;
    _carDetailLabel.numberOfLines = 0;
    [self addSubview:_carDetailLabel];
    
    CGFloat trickImageSize = vAdjustByScreenRatio(20.0f);
    self.trickImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame)-trickImageSize-vAdjustByScreenRatio(3.0f),
                                                                        vAdjustByScreenRatio(3.0f),
                                                                        trickImageSize, trickImageSize)];
    UIImage *trickImage = [ImageHandler drawRotundityWithTick:YES size:_trickImageView.frame.size strokeColor:nil fillColor:nil];
    self.trickImageView.image = trickImage;
    self.trickImageView.hidden = YES;
    [self addSubview:_trickImageView];

    
    self.warningLabel = [[InsetsLabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(_logoImageView.frame),
                                                                              CGRectGetMinY(_logoImageView.frame),
                                                                              CGRectGetWidth(self.frame)-widthSpace*2,
                                                                              CGRectGetHeight(_logoImageView.frame))
                                                         andEdgeInsetsValue:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
    _warningLabel.font = systemFontBold(24.0f);
    _warningLabel.textColor = CDZColorOfBlack;
    _warningLabel.text = getLocalizationString(warningTitle);
    _warningLabel.textAlignment = NSTextAlignmentCenter;
    _warningLabel.numberOfLines = 0;
    [self addSubview:_warningLabel];
    
    _logoImageView.hidden = YES;
    _carDetailLabel.hidden = YES;
    _warningLabel.hidden = YES;
    
    
    
    @weakify(self);
    if (_isHistoryView) {
        
        [RACObserve(self, historyDto) subscribeNext:^(UserSelectedAutosInfoDTO *dto) {
            @strongify(self);
            self.isReady = @(YES);
            [self setupHistoryAutoData];
        }];
    }else{
        [RACObserve(self, userDto) subscribeNext:^(UserAutosInfoDTO *dto) {
            @strongify(self);
            [self setupPersonalAutoData];
        }];
        
    }
}

- (void)setupUIInfoData {
    self.isReady = @(NO);
    self.userDto = nil;
    self.historyDto = nil;
    self.autoData = nil;
    self.selectedDto = [DBHandler.shareInstance getSelectedAutoData];
    if(_isHistoryView){
        self.historyDto = [[DBHandler shareInstance] getAutoSelectedHistory];
    }else {
        self.userDto = [[DBHandler shareInstance] getUserAutosDetail];
    }
    
}


#pragma mark- Data Handle

- (UserSelectedAutosInfoDTO *)getAutoDataWithFormat {
    @autoreleasepool {
        if (_isHistoryView) {
            self.autoData = _historyDto;
        }else {
            self.autoData = [UserSelectedAutosInfoDTO new];
            [_autoData processDataToObjectWithDto:_userDto];
        }
        
        return _autoData;
    }
}

- (void)setupHistoryAutoData {
    @autoreleasepool {
        if (!_historyDto) {
            _logoImageView.hidden = YES;
            _carDetailLabel.hidden = YES;
            _warningLabel.hidden = NO;
            return;
        }
        _logoImageView.hidden = NO;
        _carDetailLabel.hidden = NO;
        _warningLabel.hidden = YES;
        NSString *brandName = _historyDto.brandName;
        NSString *dealershipName = _historyDto.dealershipName;
        NSString *seriesName = _historyDto.seriesName;
        NSString *modelName = _historyDto.modelName;
        NSMutableString *carDetailString = NSMutableString.string;
        
        if (![brandName isEqualToString:@""]&&brandName) {
            [carDetailString appendFormat:@"%@ ",brandName];
        }
        
        if (dealershipName&&![dealershipName isEqualToString:@""]) {
            [carDetailString appendFormat:@"%@ ",dealershipName];
            
        }
        
        if (seriesName&&![seriesName isEqualToString:@""]) {
            [carDetailString appendFormat:@"%@ ",seriesName];
            
        }
        
        if (modelName&&![modelName isEqualToString:@""]) {
            [carDetailString appendFormat:@"%@ ",modelName];
            
        }
        NSString *carLogoURLString = _historyDto.brandImgURL;
        if (carLogoURLString&&![carLogoURLString isEqualToString:@""]&&[carLogoURLString rangeOfString:@"http"].location!=NSNotFound) {
            [_logoImageView sd_setImageWithURL:[NSURL URLWithString:carLogoURLString] placeholderImage:[ImageHandler getWhiteLogo]];
        }
        _carDetailLabel.text = carDetailString;
        if (_selectedDto&&_historyDto) {
            if (_selectedDto.brandID.longLongValue==_historyDto.brandID.longLongValue&&
                _selectedDto.dealershipID.longLongValue==_historyDto.dealershipID.longLongValue&&
                _selectedDto.seriesID.longLongValue==_historyDto.seriesID.longLongValue&&
                _selectedDto.modelID.longLongValue==_historyDto.modelID.longLongValue) {
                [self selectedSelf];
            }
        }
    }
}

- (void)setupPersonalAutoData {
    @autoreleasepool {
        
        if (!_userDto||!_userDto.brandID||[_userDto.brandID isEqualToString:@""]
            ||!_userDto.dealershipID||[_userDto.dealershipID isEqualToString:@""]
            ||!_userDto.seriesID||[_userDto.seriesID isEqualToString:@""]
            ||!_userDto.modelID||[_userDto.modelID isEqualToString:@""]) {
            _logoImageView.hidden = YES;
            _carDetailLabel.hidden = YES;
            _warningLabel.hidden = NO;
            _warningLabel.text = getLocalizationString((!UserBehaviorHandler.shareInstance.getUserToken)?@"user_auto_data_without_login":@"no_user_auto_data");
            _userDto = nil;
            self.isReady = @(YES);
            return;
        }
        _logoImageView.hidden = NO;
        _carDetailLabel.hidden = NO;
        _warningLabel.hidden = YES;
        NSString *brandName = _userDto.brandName;
        NSString *dealershipName = _userDto.dealershipName;
        NSString *seriesName = _userDto.seriesName;
        NSString *modelName = _userDto.modelName;
        NSMutableString *carDetailString = NSMutableString.string;
        
        if (![brandName isEqualToString:@""]&&brandName) {
            [carDetailString appendFormat:@"%@ ",brandName];
        }
        
        if (dealershipName&&![dealershipName isEqualToString:@""]) {
            [carDetailString appendFormat:@"%@ ",dealershipName];
            
        }
        
        if (seriesName&&![seriesName isEqualToString:@""]) {
            [carDetailString appendFormat:@"%@ ",seriesName];
            
        }
        
        if (modelName&&![modelName isEqualToString:@""]) {
            [carDetailString appendFormat:@"%@ ",modelName];
            
        }
        
        NSString *carLogoURLString = _userDto.brandImgURL;
        if (carLogoURLString&&![carLogoURLString isEqualToString:@""]&&[carLogoURLString rangeOfString:@"http"].location!=NSNotFound) {
            [_logoImageView sd_setImageWithURL:[NSURL URLWithString:carLogoURLString] placeholderImage:[ImageHandler getWhiteLogo]];
        }
        _carDetailLabel.text = carDetailString;
        self.isReady = @(YES);
        if (_selectedDto&&_userDto) {
            if (_selectedDto.brandID.longLongValue==_userDto.brandID.longLongValue&&
                _selectedDto.dealershipID.longLongValue==_userDto.dealershipID.longLongValue&&
                _selectedDto.seriesID.longLongValue==_userDto.seriesID.longLongValue&&
                _selectedDto.modelID.longLongValue==_userDto.modelID.longLongValue) {
                [self selectedSelf];
            }
        }
    }
}

@end
