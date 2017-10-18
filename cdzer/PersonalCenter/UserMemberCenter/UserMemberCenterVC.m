//
//  UserMemberCenterVC.m
//  cdzer
//
//  Created by KEns0n on 27/10/2016.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "UserMemberCenterVC.h"
#import "UserMemberCenterRightsCell.h"
#import "UserMemberTypeCell.h"
#import "UserMemberHistoryCell.h"
#import "UserMemberCenterConfig.h"
#import "MemberDetailVC.h"
#import "UserMemberHistoryVC.h"
#import "UserRightsDetailVC.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>

@interface UserMemberCenterVC () <UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *userPortraitIV;

@property (weak, nonatomic) IBOutlet UIImageView *currentMemberTypeIV;

@property (weak, nonatomic) IBOutlet UILabel *userName;

@property (weak, nonatomic) IBOutlet UIView *progressBarView;

@property (weak, nonatomic) IBOutlet UIView *trackBarView;

@property (weak, nonatomic) IBOutlet UIImageView *progressPointIV;
@property (weak, nonatomic) IBOutlet UIImageView *inReviewIV;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *currentProgressWidthConstraint;

@property (weak, nonatomic) IBOutlet UICollectionView *userMemberRightsCV;
@property (strong, nonatomic) NSArray <NSDictionary *> *userRightsDetailList;

@property (weak, nonatomic) IBOutlet UITableView *memberTypeTV;
@property (nonatomic, strong) NSArray <UMTDataModel *> *memberTypeList;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *memberTypeTVHeightConstraint;

@property (weak, nonatomic) IBOutlet UITableView *userMemberHistoryTV;
@property (nonatomic, strong) NSArray <UMHDataModel *> *memberHistoryList;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *memberHistoryTVHeightConstraint;

@property (strong, nonatomic) NSDictionary *memberDetail;
@property (nonatomic, assign) BOOL isMemberInReview;

@property (nonatomic, assign) UserMemberType memberType;

@end

@implementation UserMemberCenterVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"会员中心";
    // Do any additional setup after loading the view.
    [self componentSetting];
    [self initializationUI];
    [self setReactiveRules];
    [self getMemberCenterDetail];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self setAllContainerBorder];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self setAllContainerBorder];
}

- (void)setReactiveRules {
    @autoreleasepool {
        @weakify(self);
        [RACObserve(self, userMemberHistoryTV.contentSize) subscribeNext:^(id size) {
            @strongify(self);
            CGSize contentSize = [size CGSizeValue];
            if (self.memberHistoryList.count==0) {
                contentSize.height = 36;
            }
            self.memberHistoryTVHeightConstraint.constant = contentSize.height;
        }];
        
        
        [RACObserve(self, memberTypeTV.contentSize) subscribeNext:^(id size) {
            @strongify(self);
            CGSize contentSize = [size CGSizeValue];
            self.memberTypeTVHeightConstraint.constant = contentSize.height;
        }];
        
    }
    
}

- (void)componentSetting {
    @autoreleasepool {
        [self.userMemberRightsCV registerNib:[UINib nibWithNibName:@"UserMemberCenterRightsCell" bundle:nil] forCellWithReuseIdentifier:CDZKeyOfCellIdentKey];
        
        
        self.memberTypeTV.rowHeight = UITableViewAutomaticDimension;
        self.memberTypeTV.estimatedRowHeight = 200.0f;
        [self.memberTypeTV registerNib:[UINib nibWithNibName:@"UserMemberTypeCell" bundle:nil]  forCellReuseIdentifier:CDZKeyOfCellIdentKey];
        
        self.userMemberHistoryTV.rowHeight = UITableViewAutomaticDimension;
        self.userMemberHistoryTV.estimatedRowHeight = 100.0f;
        [self.userMemberHistoryTV registerNib:[UINib nibWithNibName:@"UserMemberHistoryCell" bundle:nil]  forCellReuseIdentifier:CDZKeyOfCellIdentKey];
        
        
        self.memberType = UserMemberTypeOfNone;
    }
}

- (void)initializationUI {
    @autoreleasepool {
    
    }
}

- (void)setAllContainerBorder {
    [self.userPortraitIV setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:CGRectGetWidth(self.userPortraitIV.frame)/2.0f];
    [self.userPortraitIV.superview setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:CGRectGetWidth(self.userPortraitIV.frame)/2.0f];
    
    BorderOffsetObject *bottomLeftOffset = [BorderOffsetObject new];
    bottomLeftOffset.bottomLeftOffset = 12;
    [[self.view viewWithTag:9] setViewBorderWithRectBorder:UIRectBorderTop|UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:bottomLeftOffset];
    
    [self.userMemberRightsCV setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    
    [[[self.view viewWithTag:10] viewWithTag:1] setViewBorderWithRectBorder:UIRectBorderTop|UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:bottomLeftOffset];
//    NSArray <UIView *> *subview = [self.view viewWithTag:11].subviews;
//        [subview enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull view, NSUInteger idx, BOOL * _Nonnull stop) {
//            if (subview.count==idx+1) {
//                [view setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
//            }else {
//                [[view viewWithTag:1] setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
//            }
//        }];
    [[[self.view viewWithTag:12] viewWithTag:1] setViewBorderWithRectBorder:UIRectBorderTop|UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:bottomLeftOffset];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pusToUserRightsDetail {
    @autoreleasepool {
        UserRightsDetailVC *vc = [UserRightsDetailVC new];
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)pusToUserMemberHistory {
    @autoreleasepool {
        UserMemberHistoryVC *vc = [UserMemberHistoryVC new];
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)changeUserMemberTypeWithAnimationByType:(UserMemberType)memberType {
    if (memberType==UserMemberTypeOfNone) return;
    CGFloat offset = 20.f;
    CGFloat progressWidth = 0;
    switch (memberType) {
        case UserMemberTypeOfSilverMedal:
            progressWidth = (CGRectGetWidth(self.trackBarView.frame)-offset*2)*0.25+offset;
            break;
        case UserMemberTypeOfGoldMedal:
            progressWidth = CGRectGetWidth(self.trackBarView.frame)/2.0f;
            break;
        case UserMemberTypeOfPlatinum:{
            CGFloat ratio = 0.75;
            if (self.isMemberInReview) ratio = 0.625;
            progressWidth = (CGRectGetWidth(self.trackBarView.frame)-offset*2)*ratio+offset;
        }
            break;
        case UserMemberTypeOfDiamond:
            progressWidth = CGRectGetWidth(self.trackBarView.frame)-offset;
            if (self.isMemberInReview) {
                progressWidth = (CGRectGetWidth(self.trackBarView.frame)-offset*2)*0.875+offset;
            }
            break;
        case UserMemberTypeOfNone:
        case UserMemberTypeOfBronzeMedal:
        default:
            progressWidth = offset;
            break;
    }
    self.currentProgressWidthConstraint.constant = progressWidth;
    [self.view setNeedsUpdateConstraints];
    
    
    self.inReviewIV.alpha = 0;
    [UIView animateWithDuration:0.75 animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (self.isMemberInReview) {
            [UIView animateWithDuration:0.35 animations:^{
                self.inReviewIV.alpha = 1;
            }];
        }
    }];
    
}

- (void)setMemberDetail:(NSDictionary *)memberDetail {
    _memberDetail = memberDetail;
    [self updateUIData];
}

- (void)updateUIData {
//    face_img										头像
//    nichen										昵称
//    level_name									当前状态
//    listmap[{										进度条
//        name									名称
//    }]
//    my_right[{									我的权益
//        img										图标
//        right										权益
//    }]
//    member_right[{								会员攻略
//        id										详情id
//        img										图标
//        name									会员等级
//        right										享受权益
//    }]
//    growth_list[{									我的成长
//        reason									原因
//        remark									说明
//        update_date								日期
//    }]


    NSString *userPortrait = self.memberDetail[@"face_img"];
    if ([userPortrait isContainsString:@"http"]) {
        [self.userPortraitIV setImageWithURL:[NSURL URLWithString:userPortrait] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    self.userName.text = [SupportingClass verifyAndConvertDataToString:self.memberDetail[@"nichen"]];
    self.memberType = [UserMemberCenterConfig getMemberTypeByString:self.memberDetail[@"level_name"]];
    
    self.isMemberInReview = NO;
    if ([self.memberDetail[@"level_name"] isContainsString:@"审核中"]) {
        self.isMemberInReview = YES;
    }
    
    if (self.memberDetail[@"my_right"]&&[self.memberDetail[@"my_right"] isKindOfClass:NSArray.class]) {
        self.userRightsDetailList = self.memberDetail[@"my_right"];
    }
    [self.userMemberRightsCV reloadData];
    
    self.currentMemberTypeIV.image = [UserMemberCenterConfig getMemberStateImageByType:self.memberType wasInReview:self.isMemberInReview];
    [self.currentMemberTypeIV layoutIfNeeded];
    
    self.memberTypeList = [UMTDataModel createDataModelWithSourceList:self.memberDetail[@"member_right"]];
    [self.memberTypeTV reloadData];
  
    self.memberHistoryList = [UMHDataModel createDataModelWithSourceList:self.memberDetail[@"growth_list"]];
    [self.userMemberHistoryTV reloadData];
  
    [self performSelector:@selector(delayProgressAnimation) withObject:nil afterDelay:0.1];
}

- (void)delayProgressAnimation {
    [self changeUserMemberTypeWithAnimationByType:self.memberType];
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *text = @"暂无更多数据！";
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:13.0f],
                                 NSForegroundColorAttributeName: [UIColor colorWithHexString:@"646464"]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.memberTypeTV==tableView) {
        return self.memberTypeList.count;
    }
    return self.memberHistoryList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.memberTypeTV==tableView) {
        UserMemberTypeCell *cell = [tableView dequeueReusableCellWithIdentifier:CDZKeyOfCellIdentKey forIndexPath:indexPath];
        cell.isLastCell = (indexPath.row+1==self.memberTypeList.count);
        UMTDataModel *dataModel = self.memberTypeList[indexPath.row];
        [cell updateUIDataWithDataModel:dataModel];
        return cell;
    }
    UserMemberHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:CDZKeyOfCellIdentKey forIndexPath:indexPath];
    UMHDataModel *dataModel = self.memberHistoryList[indexPath.row];
    dataModel.isLastRow = (self.memberHistoryList.count==indexPath.row+1);
    [cell updateUIDataWithDataModel:dataModel];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.memberTypeTV==tableView) {
        UMTDataModel *dataModel = self.memberTypeList[indexPath.row];
        MemberDetailVC *vc = [MemberDetailVC new];
        vc.memberType = dataModel.memberTypeID.integerValue;
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.userRightsDetailList.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize size = CGSizeMake(70.f, CGRectGetHeight(collectionView.frame));
    return size;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UserMemberCenterRightsCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CDZKeyOfCellIdentKey forIndexPath:indexPath];
    NSDictionary *detail = self.userRightsDetailList[indexPath.item];
    [cell updateUIDataWithTitle:detail[@"right"] andIconURL:detail[@"img"]];
    return cell;
}

- (void)getMemberCenterDetail {
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    [ProgressHUDHandler showHUD];
    @weakify(self);
    [APIsConnection.shareConnection personalCenterAPIsGetUserMemberCenterDetailWithAccessToken:self.accessToken success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self)
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"详情%@-----%@",message, operation.currentRequest.URL.absoluteString);
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        [ProgressHUDHandler dismissHUD];
        if (errorCode!=0) {
            [SupportingClass showAlertViewWithTitle:@"error" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                
            }];
            return;
        }
        NSDictionary *memberDetail = responseObject[CDZKeyOfResultKey];
        [UserBehaviorHandler.shareInstance updateUserMemberType:memberDetail[@"level_name"]];
        self.memberDetail = memberDetail;
        
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
