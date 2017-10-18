//
//  UserLocateView.m
//  cdzer
//
//  Created by KEns0n on 7/10/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//
#import "InsetsLabel.h"
#import "UserLocateView.h"
#import "UserLocationHandler.h"
#define offsetX 15.0f
#define kDefaultLoadingTitle getLocalizationString(@"locating")

@interface UserLocateView ()
{
    BOOL _isUpdated;
    BOOL _isUpdating;
    NSTimer *_timer;
    NSString *_currentCity;
    CLLocationCoordinate2D _coordinate;
}

@property (nonatomic, strong) InsetsLabel *titleLabel;

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;


@end

@implementation UserLocateView

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initializationUI];
        [self setReactiveRules];
    }
    return self;
}

- (void)setReactiveRules {
    @weakify(self);
    [RACObserve(self, indicatorView.hidden) subscribeNext:^(NSNumber *hidden) {
        @strongify(self);
        CGFloat insetsOffset = (hidden.boolValue)?15.0f:CGRectGetWidth(self.indicatorView.frame)+20.0f;
        self.titleLabel.edgeInsets = UIEdgeInsetsMake(0.0f, insetsOffset, 0.0f, 15.0f);
    }];
}

- (void)initializationUI {
    
    
    self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _indicatorView.hidesWhenStopped = NO;
    _indicatorView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    _indicatorView.translatesAutoresizingMaskIntoConstraints = YES;
    _indicatorView.frame = CGRectMake(offsetX, 0.0f, CGRectGetWidth(_indicatorView.frame), CGRectGetHeight(_indicatorView.frame));
    _indicatorView.center = CGPointMake(_indicatorView.center.x, CGRectGetHeight(self.frame)/2.0f);
    [_indicatorView startAnimating];
    _indicatorView.hidden = NO;
    
    
    self.titleLabel = [[InsetsLabel alloc] initWithFrame:self.bounds andEdgeInsetsValue:UIEdgeInsetsMake(0.0f, CGRectGetWidth(_indicatorView.frame)+20.0f, 0.0f, 15.0f)];
    _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    _titleLabel.translatesAutoresizingMaskIntoConstraints = YES;
    _titleLabel.text = kDefaultLoadingTitle;
    _titleLabel.textColor = CDZColorOfBlack;
    [_titleLabel addSubview:_indicatorView];
    [self addSubview:_titleLabel];
    
}

- (void)showLoading {
    if ([_timer isValid]) {
        [_timer invalidate];
    }
    _timer = nil;
    _titleLabel.text = kDefaultLoadingTitle;
    self.indicatorView.hidden = NO;
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateLoadingTitle) userInfo:nil repeats:YES];
}

- (void)updateLoadingTitle {
    NSString *currentTitle = kDefaultLoadingTitle;
    if (![_titleLabel.text isEqualToString:[kDefaultLoadingTitle stringByAppendingString:@"....."]]) {
        currentTitle = [_titleLabel.text stringByAppendingString:@"."];
    }
    _titleLabel.text = currentTitle;
}

- (void)stopLoading {
    if ([_timer isValid]) {
        [_timer invalidate];
    }
    _timer = nil;
    _indicatorView.hidden = YES;
}

- (void)changeTitleWithCity:(NSString *)city coordinate:(CLLocationCoordinate2D)coordinate isError:(BOOL)isError {
    if (isError) {
        _titleLabel.text = @"定位失败！";
        _currentCity = nil;
        _coordinate = CLLocationCoordinate2DMake(0.0f, 0.0f);
        self->_isLocateSuccess = NO;
        return;
    }
    self->_isLocateSuccess = YES;
    _currentCity = city;
    _coordinate = coordinate;
    _titleLabel.text = [@"你当前所在城市：" stringByAppendingString:city];
}

- (void)startUserLocation {
    self->_isLocateSuccess = NO;
    [self showLoading];
    _isUpdating = YES;
    @weakify(self);
    [UserLocationHandler.shareInstance startUserLocationServiceWithBlock:^(BMKUserLocation *userLocation, NSError *error) {
        @strongify(self);
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
        }];
    }];
}

- (void)stopUserLocation {
    [UserLocationHandler.shareInstance stopUserLocationService];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
