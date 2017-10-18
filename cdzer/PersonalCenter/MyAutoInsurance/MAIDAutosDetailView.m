//
//  MAIDAutosDetailView.m
//  cdzer
//
//  Created by KEns0n on 10/17/15.
//  Copyright © 2015 CDZER. All rights reserved.
//

#import "MAIDAutosDetailView.h"
#import "InsetsLabel.h"
#import "MyAutoInsuranceInfoFormVC.h"
#import "AppDelegate.h"

@interface MAIDAutosDetailViewCell : UITableViewCell

@end

@implementation MAIDAutosDetailViewCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.accessoryType = selected?UITableViewCellAccessoryCheckmark:UITableViewCellAccessoryNone;
}

@end

@interface MAIDAutosDetailView ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *autosList;

@property (nonatomic, strong) NSMutableArray *autosSelectionList;

@property (nonatomic, assign) BOOL isEditMode;

@property (nonatomic, assign) NSUInteger selectionIndex;

@property (nonatomic, strong) InsetsLabel *autosLicenseNumLabel;

@property (nonatomic, strong) InsetsLabel *autosModelLabel;

@property (nonatomic, strong) InsetsLabel *autosOwnerLabel;
/// 更换车辆
@property (nonatomic, strong) UIButton *autosSelectionBtn;
/// 添加车辆
@property (nonatomic, strong) UIButton *registerAutosInfoBtn;

@property (nonatomic, strong) UIControl *tableBackgroundView;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, assign) CGRect lastRect;

@end

@implementation MAIDAutosDetailView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (instancetype)initWithFrame:(CGRect)frame isEditMode:(BOOL)editMode {
    self = [super initWithFrame:frame];
    if (self) {
        self.isReady = NO;
        self.isEditMode = editMode;
        self.selectionIndex = 0;
        self.autosList = [@[] mutableCopy];
        self.autosSelectionList = [@[] mutableCopy];
        [self initializationUI];
    }
    return self;
    
}

- (instancetype)init {
    self = [self initWithFrame:CGRectZero];
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [self initWithFrame:frame isEditMode:NO];
    return self;
}

- (void)hiddenButton {
    self.lastRect = self.frame;
    CGRect frame = self.frame;
    frame.size.height = CGRectGetMaxY(_autosModelLabel.frame)+5.0f;
    self.frame = frame;
}

- (void)showButton {
    self.frame = _lastRect;
}

- (void)initializationUI {
    self.clipsToBounds = YES;
    self.backgroundColor = [UIColor colorWithRed:0.129f green:0.796f blue:0.604f alpha:1.00f];
    
    UIFont *font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfBold, 15.0f, NO);
    self.autosLicenseNumLabel = [[InsetsLabel alloc] initWithFrame:CGRectMake(0.0f, 5.0f, CGRectGetWidth(self.frame), 30.0f)
                                                andEdgeInsetsValue:DefaultEdgeInsets];
    _autosLicenseNumLabel.text = @"车牌号：--";
    _autosLicenseNumLabel.font = font;
    _autosLicenseNumLabel.textColor = CDZColorOfWhite;
    [self addSubview:_autosLicenseNumLabel];
    
    
    self.autosOwnerLabel = [[InsetsLabel alloc] initWithFrame:_autosLicenseNumLabel.frame
                                           andEdgeInsetsValue:DefaultEdgeInsets];
    _autosOwnerLabel.font = font;
    _autosOwnerLabel.text = @"车主：--";
    _autosOwnerLabel.textColor = CDZColorOfWhite;
    _autosOwnerLabel.textAlignment = NSTextAlignmentRight;
    [self addSubview:_autosOwnerLabel];

    
    
    self.autosModelLabel = [[InsetsLabel alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(_autosLicenseNumLabel.frame), CGRectGetWidth(self.frame), 30.0f)
                                           andEdgeInsetsValue:DefaultEdgeInsets];
    _autosModelLabel.font = font;
    _autosModelLabel.text = @"车型：--";
    _autosModelLabel.textColor = CDZColorOfWhite;
    [self addSubview:_autosModelLabel];
    
    self.autosSelectionBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    _autosSelectionBtn.frame = CGRectMake(DefaultEdgeInsets.left, CGRectGetMaxY(_autosModelLabel.frame)+6.0f, CGRectGetWidth(self.frame)*0.25f, 30.0f);
    _autosSelectionBtn.backgroundColor = CDZColorOfOrangeColor;
    [_autosSelectionBtn setTitle:@"更换车辆" forState:UIControlStateNormal];
    [_autosSelectionBtn setTitleColor:CDZColorOfWhite forState:UIControlStateNormal];
    [_autosSelectionBtn setTitle:@"更换车辆" forState:UIControlStateHighlighted];
    [_autosSelectionBtn setTitleColor:CDZColorOfGray forState:UIControlStateHighlighted];
    [_autosSelectionBtn setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:5.0f];
    [_autosSelectionBtn addTarget:self action:@selector(showSelectionTableView) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_autosSelectionBtn];
    
    
    self.registerAutosInfoBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    _registerAutosInfoBtn.frame = CGRectMake(CGRectGetWidth(self.frame)-CGRectGetWidth(_autosSelectionBtn.frame)-DefaultEdgeInsets.right,
                                             CGRectGetMaxY(_autosModelLabel.frame)+6.0f, CGRectGetWidth(self.frame)*0.25f, 30.0f);
    _registerAutosInfoBtn.backgroundColor = CDZColorOfOrangeColor;
    [_registerAutosInfoBtn setTitle:@"添加车辆" forState:UIControlStateNormal];
    [_registerAutosInfoBtn setTitleColor:CDZColorOfWhite forState:UIControlStateNormal];
    [_registerAutosInfoBtn setTitle:@"添加车辆" forState:UIControlStateHighlighted];
    [_registerAutosInfoBtn setTitleColor:CDZColorOfGray forState:UIControlStateHighlighted];
    [_registerAutosInfoBtn setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:5.0f];
    [self addSubview:_registerAutosInfoBtn];
    
    self.tableBackgroundView = [[UIControl alloc] initWithFrame:UIScreen.mainScreen.bounds];
    _tableBackgroundView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.7f];
    [_tableBackgroundView addTarget:self action:@selector(hiddenSelectionTableView) forControlEvents:UIControlEventTouchUpInside];
    _tableBackgroundView.alpha = 0.0f;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(_tableBackgroundView.frame)*0.8f, CGRectGetHeight(_tableBackgroundView.frame)*0.7f)];
    _tableView.center = CGPointMake(CGRectGetWidth(_tableBackgroundView.frame)/2.0f, CGRectGetHeight(_tableBackgroundView.frame)/2.0f);
    _tableView.bounces = NO;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.allowsMultipleSelection = NO;
    _tableView.allowsSelection = YES;
    [_tableBackgroundView addSubview:_tableView];
    
    @weakify(self);
    [RACObserve(self, tableView.contentSize) subscribeNext:^(id contentSize) {
       @strongify(self);
        CGRect frame = self.tableView.frame;
        frame.size.height = [contentSize CGSizeValue].height;
        self.tableView.frame = frame;
        self.tableView.center = CGPointMake(CGRectGetWidth(self.tableBackgroundView.frame)/2.0f, CGRectGetHeight(self.tableBackgroundView.frame)/2.0f);
    }];    
    
}

- (void)hiddenSelectionTableView {
    @weakify(self);
    [UIView animateWithDuration:0.2 animations:^{
        @strongify(self);
        self.tableBackgroundView.alpha = 1;
    } completion:^(BOOL finished) {
        @strongify(self);
        [self.tableBackgroundView removeFromSuperview];
    }];
}

- (void)showSelectionTableView {
    [UIApplication.sharedApplication.keyWindow addSubview:_tableBackgroundView];
    @weakify(self);
    [UIView animateWithDuration:0.2 animations:^{
        @strongify(self);
        self.tableBackgroundView.alpha = 1;
    }];
}

- (void)autosRegisterbuttonAddTarget:(nullable id)target action:(_Nullable SEL)action forControlEvents:(UIControlEvents)controlEvents {
    [_registerAutosInfoBtn removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [_registerAutosInfoBtn addTarget:target action:action forControlEvents:controlEvents];
}

- (void)updateAutosInsuranceData {
    [self getUserRegisteredAutosInsuranceList];
}

#pragma -mark UITableViewDelgate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return _autosSelectionList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MAIDAutosDetailViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CDZKeyOfCellIdentKey];
    if (!cell) {
        cell = [[MAIDAutosDetailViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CDZKeyOfCellIdentKey];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.detailTextLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 15.0f, NO);
        cell.detailTextLabel.textColor = CDZColorOfBlack;
        cell.detailTextLabel.numberOfLines = 0;
    }
    // Configure the cell...
    cell.detailTextLabel.text = _autosSelectionList[indexPath.row];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    static NSString *headerIdentifier = @"header";
    UITableViewHeaderFooterView *myHeader = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerIdentifier];
    if(!myHeader) {
        myHeader = [[UITableViewHeaderFooterView alloc]initWithReuseIdentifier:headerIdentifier];
        InsetsLabel *titleLabel = [[InsetsLabel alloc] initWithFrame:CGRectZero
                                                  andEdgeInsetsValue:DefaultEdgeInsets];
        titleLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfBold, 17.5f, NO);
        titleLabel.backgroundColor = CDZColorOfBlack;
        titleLabel.textColor = CDZColorOfWhite;
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.tag = 10;
        titleLabel.translatesAutoresizingMaskIntoConstraints = YES;
        titleLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        [myHeader addSubview:titleLabel];
        
        [myHeader setNeedsUpdateConstraints];
        [myHeader updateConstraintsIfNeeded];
        [myHeader setNeedsLayout];
        [myHeader layoutIfNeeded];
    }
    InsetsLabel *titleLabel = (InsetsLabel *)[myHeader viewWithTag:10];
    titleLabel.text = @"请选择车牌号码";
    return myHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectionIndex = indexPath.row;
    @weakify(self);
    [UIView animateWithDuration:0.2 animations:^{
        @strongify(self);
        self.tableBackgroundView.alpha = 0.0f;
    }completion:^(BOOL finished) {
        @strongify(self);
        self.isReady = NO;
        [self.tableBackgroundView removeFromSuperview];
        NSDictionary *detail = self.autosList[self.selectionIndex];
        self.autosLicenseNumLabel.text = [@"车牌号：" stringByAppendingString:detail[@"licenseNo"]];
        self.autosOwnerLabel.text = [@"车主：" stringByAppendingString:detail[@"carUserName"]];
        self.autosModelLabel.text = [@"车型：" stringByAppendingString:detail[@"speciName"]];
        NSString *autosLicenseNum = self.autosSelectionList[self.selectionIndex];
        [self getAutoInsurancePremiumDetailDetailWithAutosLicenseNum:autosLicenseNum];
    }];
}

- (void)getUserRegisteredAutosInsuranceList {
    NSString *token = UserBehaviorHandler.shareInstance.getUserToken;
    if (!token) {
        @weakify(self);
        [self handleMissingTokenAction:^(BOOL isSuccess) {
            @strongify(self);
            self.isReady = YES;
        }];
        return;
    }
    
    @weakify(self);
    [APIsConnection.shareConnection personalCenterAPIsGetUserInsuranceAutosListWithAccessToken:token success:^(NSURLSessionDataTask *operation, id responseObject) {
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        @strongify(self);
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        if(errorCode!=0){
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                @strongify(self);
                self.isReady = YES;
                self.autosLicenseNumLabel.text = @"车牌号：--";
                self.autosOwnerLabel.text = @"车主：--";
                self.autosModelLabel.text = @"车型：--";
                
            }];
            return;
        }
        
//        "id": "15101313355272339927",
//        "carUserName": "小谢",
//        "licenseNo": "新A12365",
//        "speciName": "布加迪 2008款 16.4 8.0T"
        
        [self.autosList removeAllObjects];
        [self.autosSelectionList removeAllObjects];
        [self.autosList addObjectsFromArray:[responseObject[CDZKeyOfResultKey] objectForKey:@"car_list"]];
        [self.autosSelectionList addObjectsFromArray:[self.autosList valueForKey:@"licenseNo"]];
        if (self.autosSelectionList.count>0&&self.autosList.count>0) {
            NSDictionary *detail = self.autosList[self.selectionIndex];
            self.autosLicenseNumLabel.text = [@"车牌号：" stringByAppendingString:detail[@"licenseNo"]];
            self.autosOwnerLabel.text = [@"车主：" stringByAppendingString:detail[@"carUserName"]];
            self.autosModelLabel.text = [@"车型：" stringByAppendingString:detail[@"speciName"]];
            [self.tableView reloadData];
            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
            
            NSString *autosLicenseNum = self.autosSelectionList[self.selectionIndex];
            [self getAutoInsurancePremiumDetailDetailWithAutosLicenseNum:autosLicenseNum];
        }else {
            self.isReady = YES;
            self.autosLicenseNumLabel.text = @"车牌号：--";
            self.autosOwnerLabel.text = @"车主：--";
            self.autosModelLabel.text = @"车型：--";
            BaseNavigationController *navVC = (BaseNavigationController *)[(AppDelegate*)UIApplication.sharedApplication.delegate navViewController];
            NSString *cancelBtn = @"cancel";
            NSString *confirmBtn = @"ok";
            message = @"你还没有完善个人车辆保险信息  现在去完善吗？";
            [SupportingClass showAlertViewWithTitle:nil message:message isShowImmediate:YES cancelButtonTitle:cancelBtn otherButtonTitles:confirmBtn clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                if (btnIdx.unsignedIntegerValue==0) {
                    [navVC popViewControllerAnimated:YES];
                }
                
                if (btnIdx.unsignedIntegerValue==1) {
                    [self pushToInsuranceFormVCWithTitle:nil isFirstTime:YES isShowCancelBtn:YES];
                }
            }];
        }
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        
        if (error.code==-1009) {
            [SupportingClass showAlertViewWithTitle:@"error" message:@"网络连接失败，请检查网络设置！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                self.isReady = YES;
            }];
            return;
        }
        
        
        if (error.code==-1001) {
            [SupportingClass showAlertViewWithTitle:@"error" message:@"网络连接逾时，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                self.isReady = YES;
            }];
            return;
        }
        
        [SupportingClass showAlertViewWithTitle:@"error" message:@"网络错误，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            self.isReady = YES;
        }];
    }];
    
}

- (void)pushToInsuranceFormVCWithTitle:(NSString *)title isFirstTime:(BOOL)isFirstTime isShowCancelBtn:(BOOL)isShowCancelBtn {
    @autoreleasepool {
        BaseNavigationController *navVC = (BaseNavigationController *)[(AppDelegate*)UIApplication.sharedApplication.delegate navViewController];
        MyAutoInsuranceInfoFormVC *vc = [MyAutoInsuranceInfoFormVC new];
        vc.isShowCancelBtn = isShowCancelBtn;
        vc.isFirstTime = isFirstTime;
        [(BaseViewController*)navVC.visibleViewController setNavBackButtonTitleOrImage:title titleColor:nil];
        [navVC pushViewController:vc animated:YES];
    }
}

- (void)getAutoInsurancePremiumDetailDetailWithAutosLicenseNum:(NSString *)autosLicenseNum {
    NSString *token = UserBehaviorHandler.shareInstance.getUserToken;
    if (!token) {
        @weakify(self);
        [self handleMissingTokenAction:^(BOOL isSuccess) {
            @strongify(self);
            self.isReady = YES;
        }];
        return;
    }
    
    @weakify(self);
    [APIsConnection.shareConnection personalCenterAPIsGetUserInsuranceAutosInsurancePremiumDetailWithAccessToken:token autosLicenseNum:autosLicenseNum success:^(NSURLSessionDataTask *operation, id responseObject) {
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        @strongify(self);
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        if(errorCode!=0){
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                @strongify(self);
                self.isReady = YES;
                
            }];
            return;
        }
        
        self.autosInsuranceDetail = nil;
        self.autosInsuranceDetail = [[MAIDConfigObject alloc] initWithInsuranceDetail:responseObject[CDZKeyOfResultKey]];
        self.isReady = YES;
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        
        if (error.code==-1009) {
            [SupportingClass showAlertViewWithTitle:@"error" message:@"网络连接失败，请检查网络设置！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                self.isReady = YES;
            }];
            return;
        }
        
        
        if (error.code==-1001) {
            [SupportingClass showAlertViewWithTitle:@"error" message:@"网络连接逾时，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                self.isReady = YES;
            }];
            return;
        }
        
        [SupportingClass showAlertViewWithTitle:@"error" message:@"网络错误，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            self.isReady = YES;
        }];
        
        
    }];
    
}


@end
