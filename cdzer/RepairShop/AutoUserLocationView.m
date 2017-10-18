//
//  AutoUserLocationView.m
//  cdzer
//
//  Created by KEns0n on 9/9/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//
#import "KeyCityDTO.h"
#import "AutoUserLocationView.h"
#import "InsetsLabel.h"
#import "UserLocationHandler.h"
#define offsetX 15.0f
#define kDefaultLoadingTitle getLocalizationString(@"locating")

@interface AutoUserLocationTVC : UITableViewCell

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@end

@implementation AutoUserLocationTVC

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _indicatorView.hidesWhenStopped = NO;
        _indicatorView.hidden = YES;
        [_indicatorView startAnimating];
        [self addSubview:_indicatorView];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    
    CGRect indicatorFrame = self.indicatorView.frame;
    indicatorFrame.origin.x = CGRectGetMaxX(self.imageView.frame)+15.0f;
    self.indicatorView.frame = indicatorFrame;
    self.indicatorView.center = CGPointMake(_indicatorView.center.x, CGRectGetHeight(self.frame)/2.0f);
    
    BOOL indicatorHidden = (_indicatorView.hidden);
    CGRect textFrame = self.textLabel.frame;
    textFrame.origin.x = indicatorHidden?+15.0f:CGRectGetMaxX(self.indicatorView.frame)+5.0f;
    self.textLabel.frame = textFrame;
    self.textLabel.center = CGPointMake(self.textLabel.center.x, CGRectGetHeight(self.frame)/2.0f);
    
    
    CGRect accessoryViewFrame = self.accessoryView.frame;
    accessoryViewFrame.origin.x = CGRectGetWidth(self.frame)-CGRectGetWidth(self.accessoryView.frame)-10.0f;
    self.accessoryView.frame = accessoryViewFrame;
    
    CGRect detailTextFrame = self.detailTextLabel.frame;
    detailTextFrame.origin.x = CGRectGetMaxX(self.textLabel.frame);
    if (self.accessoryView) {
        detailTextFrame.size.width = CGRectGetMaxX(self.accessoryView.frame)-CGRectGetMaxX(self.textLabel.frame)-10.0f;
    }
    self.detailTextLabel.frame = detailTextFrame;
    self.detailTextLabel.center = CGPointMake(self.detailTextLabel.center.x, CGRectGetHeight(self.frame)/2.0f);
    
}

@end

@interface AutoUserLocationView ()
{
    BOOL _isUpdated;
    BOOL _isUpdating;
    NSTimer *_timer;
    NSString *_currentCity;
    CLLocationCoordinate2D _coordinate;
}

@property (nonatomic, strong) AutoUserLocationTVC *remindTVC;

@property (nonatomic, strong) UIButton *myLocationBtn;

@property (nonatomic, strong) UIButton *citySelectionBtn;

@property (nonatomic, strong) UIImageView *arrowView;

@end

@implementation AutoUserLocationView

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (instancetype)init {
    self = [self initWithFrame:CGRectZero];
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    frame.origin.y += (IS_IPHONE_6||IS_IPHONE_6P)?vO2OSpaceSpace:vO2OSpaceSpace*0.5f;;
    self = [super initWithFrame:frame];
    if (self) {
        [self initializationUI];
        [self setReactiveRules];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)updateSelectedCity:(KeyCityDTO *)selectedCity {
    self.selectedCity = selectedCity;
    if (_selectedCity) {
        [self stopLoading];
        [self changeTitleWithCity:_selectedCity.cityName coordinate:_selectedCity.coordinate isError:NO];
    }
}

- (void)setSelectedCity:(KeyCityDTO *)selectedCity {
    _selectedCity = selectedCity;
}

- (void)initializationUI {
    @autoreleasepool {
        self.backgroundColor = CDZColorOfClearColor;
        UIImage *arrowImage = ImageHandler.getRightArrow;
        
        self.arrowView = [[UIImageView alloc] initWithImage:arrowImage];
        
        self.remindTVC = [[AutoUserLocationTVC alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
        _remindTVC.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.bounds)*0.7, CGRectGetHeight(self.bounds));
        _remindTVC.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        _remindTVC.textLabel.numberOfLines = 1;
        _remindTVC.detailTextLabel.numberOfLines = 0;
        _remindTVC.backgroundColor = CDZColorOfWhite;
        _remindTVC.accessoryView = _arrowView;
        _remindTVC.textLabel.text = @"请选择城市";
        _remindTVC.textLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 15.0f, NO);
        _remindTVC.detailTextLabel.textColor = CDZColorOfBlack;
        _remindTVC.detailTextLabel.font = _remindTVC.textLabel.font;
        _remindTVC.detailTextLabel.textAlignment = NSTextAlignmentLeft;
        [_remindTVC setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:0.5 withColor:nil withBroderOffset:nil];
        [self addSubview:_remindTVC];
        
//        self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//        _indicatorView.hidesWhenStopped = NO;
//        [_indicatorView startAnimating];
        
        self.citySelectionBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        _citySelectionBtn.frame = _remindTVC.bounds;
        _citySelectionBtn.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        [_remindTVC insertSubview:_citySelectionBtn belowSubview:_remindTVC.accessoryView];
        
        self.myLocationBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        _myLocationBtn.backgroundColor = CDZColorOfDefaultColor;
        _myLocationBtn.frame = CGRectMake(CGRectGetWidth(self.bounds)*0.74,
                                          CGRectGetHeight(self.bounds)*0.05,
                                          CGRectGetWidth(self.bounds)*0.22,
                                          CGRectGetHeight(self.bounds)*0.9);
        [_myLocationBtn setTitle:@"定位" forState:UIControlStateNormal];
        [_myLocationBtn setTitle:@"定位" forState:UIControlStateDisabled];
        [_myLocationBtn setTitleColor:CDZColorOfWhite forState:UIControlStateNormal];
        [_myLocationBtn setTitleColor:CDZColorOfWhite forState:UIControlStateDisabled];
        [_myLocationBtn setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:5.0f];
        [_myLocationBtn addTarget:self action:@selector(startUserLocation) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_myLocationBtn];
    }
}

- (void)buttonAddTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents {
    [_citySelectionBtn addTarget:target action:action forControlEvents:controlEvents];
}

- (void)setReactiveRules {

}

- (void)showLoading {
    if ([_timer isValid]) {
        [_timer invalidate];
    }
    _timer = nil;
    _remindTVC.detailTextLabel.text = @"";
    _remindTVC.textLabel.text = kDefaultLoadingTitle;
    _citySelectionBtn.hidden = YES;
    _myLocationBtn.enabled = NO;
    _myLocationBtn.backgroundColor = CDZColorOfDeepGray;
    _remindTVC.indicatorView.hidden = NO;
    _remindTVC.accessoryView.hidden = YES;
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateLoadingTitle) userInfo:nil repeats:YES];
}

- (void)updateLoadingTitle {
    NSString *currentTitle = kDefaultLoadingTitle;
    if (![_remindTVC.textLabel.text isEqualToString:[kDefaultLoadingTitle stringByAppendingString:@"....."]]) {
        currentTitle = [_remindTVC.textLabel.text stringByAppendingString:@"."];
    }
    _remindTVC.textLabel.text = currentTitle;
}

- (void)stopLoading {
    if ([_timer isValid]) {
        [_timer invalidate];
    }
    _timer = nil;
    _citySelectionBtn.hidden = NO;
    _myLocationBtn.enabled = YES;
    _myLocationBtn.backgroundColor = CDZColorOfDefaultColor;
    _remindTVC.indicatorView.hidden = YES;
    _remindTVC.accessoryView.hidden = NO;
}


- (void)showDefaultCity {
    _remindTVC.textLabel.text = @"当前城市：";
    _remindTVC.detailTextLabel.text = _selectedCity.cityName;
}

- (void)changeTitleWithCity:(NSString *)city coordinate:(CLLocationCoordinate2D)coordinate isError:(BOOL)isError {
    if (isError) {
        _remindTVC.textLabel.text = @"定位失败！";
        _remindTVC.detailTextLabel.text = @"";
        _currentCity = nil;
        _coordinate = CLLocationCoordinate2DMake(0.0f, 0.0f);
        self->_isLocateSuccess = NO;
        if (self.selectedCity) {
            
        }
        return;
    }
    self->_isLocateSuccess = YES;
    _currentCity = city;
    _coordinate = coordinate;
    _remindTVC.textLabel.text = @"当前城市：";
    _remindTVC.detailTextLabel.text = city;
}

- (void)startUserLocation {
    self->_isLocateSuccess = NO;
    [self showLoading];
    _isUpdating = YES;
    @weakify(self);
    [UserLocationHandler.shareInstance startUserLocationServiceWithBlock:^(BMKUserLocation *userLocation, NSError *error) {
        @strongify(self);
        NSLog(@"%f,,,,,,%f", userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
        if (error) {
            self->_isUpdating = NO;
            [self changeTitleWithCity:nil coordinate:CLLocationCoordinate2DMake(0.0f, 0.0f) isError:YES];
            [self stopLoading];
            [self stopUserLocation];
            return;
        }
        [UserLocationHandler.shareInstance reverseGeoCodeSearchWithCoordinate:userLocation.location.coordinate resultBlock:^(BMKReverseGeoCodeResult *result, BMKSearchErrorCode error) {
            if (error!=0) {
                self->_isUpdating = NO;
                [self changeTitleWithCity:nil coordinate:CLLocationCoordinate2DMake(0.0f, 0.0f) isError:YES];
                [self stopLoading];
                [self stopUserLocation];
                return;
            }
            self->_isUpdating = NO;
            [self changeTitleWithCity:result.addressDetail.city coordinate:userLocation.location.coordinate isError:NO];
            [self stopLoading];
            [self stopUserLocation];
        }];
    }];
}

- (void)stopUserLocation {
    [UserLocationHandler.shareInstance stopUserLocationService];
}

@end
