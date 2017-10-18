//
//  LicensePlateSelectionView.m
//  cdzer
//
//  Created by KEns0n on 07/12/2016.
//  Copyright © 2016 CDZER. All rights reserved.
//

#define vDefaultSize CGSizeMake(50, 34)
#define kObjIDKey @"id"
#define kObjNameKey @"name"
#define vProvinceIdx 0
#define vCityCodeIdx 1

#import "LicensePlateSelectionView.h"
#import "UIView+LayoutConstraintHelper.h"

@interface LicensePlateSelectionView ()<UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong) UITextField *displayTF;

@property (nonatomic, strong) UIButton *activeBtn;

@property (nonatomic, strong) UIPickerView *pickView;

@property (nonatomic, strong) NSMutableArray <NSArray <NSDictionary *>*> *provinceAndCityCodeList;

@property (nonatomic, assign) BOOL isFirstLoad;

@property (nonatomic, assign) NSInteger provinceSelectionIdx;

@property (nonatomic, assign) NSInteger cityCodeSelectionIdx;

@property (nonatomic, assign) BOOL finishCityCodeDataLoadForInitialize;

@end

@implementation LicensePlateSelectionView

- (void)initializeSettingFromLicensePlate:(NSString *)licensePlate {
    if (!licensePlate||licensePlate.length<=2) return;
        NSString *lpPrefixCode = [licensePlate substringToIndex:2];
    if (lpPrefixCode&&lpPrefixCode.length==2) {
        if (self.provinceAndCityCodeList[vProvinceIdx].count>0) {
            NSString *provinceCode = [lpPrefixCode substringToIndex:1];
            NSString *cityCode = [lpPrefixCode substringFromIndex:1];
            @weakify(self);
            _finishCityCodeDataLoadForInitialize = NO;
            [self.provinceAndCityCodeList[vProvinceIdx] enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull pcDetail, NSUInteger pcIdx, BOOL * _Nonnull pcStop) {
                @strongify(self);
                
                if ([pcDetail[kObjNameKey] isContainsString:provinceCode]) {
                    NSString *provinceID = pcDetail[kObjIDKey];
                    [self getTheAutosCityListWithAutosProvinceID:provinceID];
                    __block RACDisposable *handler = [RACObserve(self, finishCityCodeDataLoadForInitialize) subscribeNext:^(NSNumber *finishLoading) {
                        @strongify(self);
                        
                        
                        [handler dispose];
                         //处理信息
                        [self.provinceAndCityCodeList[vCityCodeIdx] enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull ccDetail, NSUInteger ccIdx, BOOL * _Nonnull ccStop) {
                            @strongify(self);
                            
                            
                            if ([pcDetail[kObjNameKey] isContainsString:provinceCode]) {
                                self.lpProvinceString = provinceCode;
                                self.lpCityCodeString = cityCode;
                                self.provinceSelectionIdx = pcIdx;
                                self.cityCodeSelectionIdx = ccIdx;
                                [self.pickView selectRow:self.provinceSelectionIdx inComponent:vProvinceIdx animated:NO];
                                [self.pickView selectRow:self.cityCodeSelectionIdx inComponent:vCityCodeIdx animated:!self.isFirstLoad];
                                self.displayTF.text = [self.lpProvinceString stringByAppendingFormat:@" %@", self.lpCityCodeString];
                                *ccStop = YES;
                            }
                        }];
                    }];
                    *pcStop = YES;
                }
            }];
            
           
            
        }else {
            [self performSelector:@selector(initializeSettingFromLicensePlate:) withObject:licensePlate afterDelay:0.5];
        }
    }
}

- (NSString *)combineString {
    return [self.lpProvinceString stringByAppendingString:self.lpCityCodeString];
}

- (void)setLpProvinceString:(NSString *)lpProvinceString {
    _lpProvinceString = lpProvinceString;
}

- (void)setLpCityCodeString:(NSString *)lpCityCodeString {
    _lpCityCodeString = lpCityCodeString;
}

- (instancetype)init {
    self=[self initWithFrame:CGRectZero];
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self=[super initWithFrame:frame]) {
        [self setupView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self=[super initWithCoder:aDecoder]) {
        [self setupView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:3.0f];
    [self setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:0.5 withColor:[UIColor colorWithHexString:@"49C7F5"] withBroderOffset:nil];
}

- (void)setupView {
    __block NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:self
                                                                               attribute:NSLayoutAttributeWidth
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:nil
                                                                               attribute:NSLayoutAttributeNotAnAttribute
                                                                              multiplier:1
                                                                                constant:vDefaultSize.width];
    __block NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:self
                                                                                attribute:NSLayoutAttributeHeight
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:nil
                                                                                attribute:NSLayoutAttributeNotAnAttribute
                                                                               multiplier:1
                                                                                 constant:vDefaultSize.height];
    
    [self.constraints enumerateObjectsUsingBlock:^(__kindof NSLayoutConstraint * _Nonnull constraint, NSUInteger idx, BOOL * _Nonnull stop) {
        if (constraint.firstItem==self&&
            constraint.firstAttribute==NSLayoutAttributeWidth) {
            constraint.constant = vDefaultSize.width;
            widthConstraint = nil;
        }
        
        if (constraint.firstItem==self&&
            constraint.firstAttribute==NSLayoutAttributeHeight) {
            constraint.constant = vDefaultSize.height;
            heightConstraint = nil;
        }
        
    }];
    if (widthConstraint) {
        [self addConstraint:widthConstraint];
    }
    if (heightConstraint) {
        [self addConstraint:heightConstraint];
    }
    
    self.provinceAndCityCodeList = [@[@[],@[]] mutableCopy];
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.lpProvinceString = @"湘";
    self.lpCityCodeString = @"A";
    
    self.displayTF = [UITextField new];
    self.displayTF.borderStyle = UITextBorderStyleNone;
    self.displayTF.frame = self.bounds;
    self.displayTF.font = [UIFont systemFontOfSize:13];
    self.displayTF.textAlignment = NSTextAlignmentCenter;
    self.displayTF.text = @"湘 A";
    self.displayTF.textColor = [UIColor colorWithHexString:@"323232"];
    [self.displayTF addSelfByFourMarginToSuperview:self];
    self.displayTF.tintColor = [UIColor whiteColor];
    
    self.activeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    self.activeBtn.frame = self.bounds;
    [self.activeBtn addTarget:self action:@selector(showSelectionView) forControlEvents:UIControlEventTouchUpInside];
    [self.activeBtn addSelfByFourMarginToSuperview:self];
    
    self.pickView = [UIPickerView new];
    self.pickView.delegate = self;
    self.pickView.backgroundColor = [UIColor whiteColor];
    self.displayTF.inputView = self.pickView;
    self.isFirstLoad = YES;
    [self getTheAutosProvinceList];
    
    [self setNeedsUpdateConstraints];
    [self setNeedsDisplay];
    [self setNeedsLayout];
}

- (void)setTitleColor:(UIColor *)titleColor {
    if (!titleColor) titleColor = [UIColor colorWithHexString:@"323232"];
    self.displayTF.textColor = titleColor;
}

- (void)showSelectionView {
    if (!self.displayTF.isFirstResponder) {
        [self.displayTF becomeFirstResponder];
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return self.provinceAndCityCodeList.count;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.provinceAndCityCodeList[component].count;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    if (!view||![view isKindOfClass:UILabel.class]) {
        UILabel *label = [UILabel new];
        label.numberOfLines = 0;
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = [UIColor colorWithHexString:@"323232"];
        view = label;
    }
    
    UILabel *label = (UILabel *)view;
    label.text = @"";
    if (component<=vCityCodeIdx) {
        NSArray <NSDictionary *> *list = self.provinceAndCityCodeList[component];
        label.text = [list[row] objectForKey:kObjNameKey];
    }
    return view;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (component<=vCityCodeIdx&&self.provinceAndCityCodeList.count==2) {
        NSArray <NSDictionary *> *list = self.provinceAndCityCodeList[component];
        if ((row+1)<=list.count) {
            if (component==vProvinceIdx) {
                NSString *provinceID = [list[row] objectForKey:kObjIDKey];
                self.lpProvinceString = [list[row] objectForKey:kObjNameKey];
                self.provinceSelectionIdx = row;
                [self getTheAutosCityListWithAutosProvinceID:provinceID];
            }else {
                self.lpCityCodeString = [list[row] objectForKey:kObjNameKey];
                self.cityCodeSelectionIdx = row;
                self.displayTF.text = [self.lpProvinceString stringByAppendingFormat:@" %@", self.lpCityCodeString];
            }
        }
    }
  
}

- (void)getTheAutosProvinceList {
    @weakify(self)
    if (!self.isFirstLoad) [ProgressHUDHandler showHUD];
    [APIsConnection.shareConnection personalCenterAPIsGetMyAutoProvincesListWithSuccess:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self)
        
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"TheAutosProvinceList:%@",message);
        if (!self.isFirstLoad) [ProgressHUDHandler dismissHUD];
        if (errorCode!=0) {
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:nil];
            return;
        }
        [self.provinceAndCityCodeList replaceObjectAtIndex:vProvinceIdx withObject:responseObject[CDZKeyOfResultKey]];
        if (self.isFirstLoad) {
            NSDictionary *tempDic = self.provinceAndCityCodeList[vProvinceIdx].firstObject;
           __block NSString *provinceID = [SupportingClass verifyAndConvertDataToString:tempDic[kObjIDKey]];
            self.lpProvinceString = tempDic[kObjNameKey];
            self.provinceSelectionIdx = 0;
            [self.pickView reloadComponent:vProvinceIdx];
            
            @weakify(self);
            [self.provinceAndCityCodeList[vProvinceIdx] enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull detail, NSUInteger idx, BOOL * _Nonnull stop) {
                @strongify(self);
                if ([detail[kObjNameKey] isContainsString:@"湘"]) {
                    provinceID = detail[kObjIDKey];
                    self.lpProvinceString = @"湘";
                    self.provinceSelectionIdx = idx;
                    *stop = YES;
                }
            }];
            [self.pickView selectRow:self.provinceSelectionIdx inComponent:vProvinceIdx animated:NO];
            [self getTheAutosCityListWithAutosProvinceID:provinceID];
        }
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
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

- (void)getTheAutosCityListWithAutosProvinceID:(NSString *)autosProvinceID {
    if ([autosProvinceID isEqualToString:@""]||!autosProvinceID) return;
    if (!self.isFirstLoad) [ProgressHUDHandler showHUD];
    
    @weakify(self)
    [APIsConnection.shareConnection personalCenterAPIsGetMyAutoCityListWithAutoProvincesID:autosProvinceID success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self)
        if (!self.isFirstLoad) [ProgressHUDHandler dismissHUD];
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        if (errorCode!=0) {
            NSLog(@"TheAutosCityListWithAutosProvinceID:%@",message);
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:nil];
            return;
        }
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:kObjNameKey ascending:YES];
        NSArray *sortDescriptors = @[sortDescriptor];
        NSArray *cityCodeList = [responseObject[CDZKeyOfResultKey] sortedArrayUsingDescriptors:sortDescriptors];
        [self.provinceAndCityCodeList replaceObjectAtIndex:vCityCodeIdx withObject:cityCodeList];
        
        self.cityCodeSelectionIdx = 0;
        [self.pickView reloadComponent:vCityCodeIdx];
        [self.pickView selectRow:self.cityCodeSelectionIdx inComponent:vCityCodeIdx animated:!self.isFirstLoad];
        self.lpCityCodeString = self.provinceAndCityCodeList[vCityCodeIdx].firstObject[kObjNameKey];
        self.displayTF.text = [self.lpProvinceString stringByAppendingFormat:@" %@", self.lpCityCodeString];
        self.isFirstLoad = NO;
        self.finishCityCodeDataLoadForInitialize = YES;
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        if (!self.isFirstLoad) [ProgressHUDHandler dismissHUD];
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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
