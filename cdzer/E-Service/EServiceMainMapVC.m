//
//  EServiceMainMapVC.m
//  
//
//  Created by KEns0nLau on 6/3/16.
//
//

#import "EServiceMainMapVC.h"
#import "EServiceLocatePinView.h"
#import "EServiceConsultantMapAnnotationView.h"
#import "EServiceSelectLocationVC.h"
#import "EServiceSubmitionFormVC.h"
#import "HCSStarRatingView.h"
#import "EServiceConsultantDetailView.h"
#import "EServiceMapPointAnnotation.h"
#import "MemberDetailVC.h"
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>
#import "EServiceServiceListVC.h"


typedef void(^EServiceMMCBtnActionBlock)(NSIndexPath *indexPath);

@interface EServiceMainMapCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UIButton *submitBtn;

@property (nonatomic, weak) IBOutlet UIImageView *consultantPortrait;

@property (nonatomic, weak) IBOutlet UILabel *consultantNameLabel;

@property (nonatomic, weak) IBOutlet UILabel *consultantCommentLabel;

@property (nonatomic, weak) IBOutlet UILabel *consultantServiceNumLabel;

@property (nonatomic, weak) IBOutlet UILabel *consultantTimeLabel;

@property (nonatomic, weak) IBOutlet UILabel *consultantDistanceLabel;

@property (nonatomic, strong) IBOutlet HCSStarRatingView *consultantRatingView;;

@property (nonatomic, strong) UIImage *portraitImage;

@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, copy) EServiceMMCBtnActionBlock btnActionBlock;

@end

@implementation EServiceMainMapCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:5.0f];
    self.portraitImage = self.consultantPortrait.image;
    [self.consultantPortrait setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:CGRectGetHeight(self.consultantPortrait.frame)/2.0f];
    [self.submitBtn setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:CGRectGetHeight(self.submitBtn.frame)/2.0f];
    
    BorderOffsetObject *offset = [BorderOffsetObject new];
    offset.rightUpperOffset = 10.0f;
    offset.rightBottomOffset = 10.0f;
    
    offset.leftUpperOffset = 10.0f;
    offset.leftBottomOffset = 10.0f;
    [self.consultantTimeLabel setViewBorderWithRectBorder:UIRectBorderLeft|UIRectBorderRight borderSize:0.5f withColor:nil withBroderOffset:offset];
}

- (IBAction)buttonAction {
    if (self.btnActionBlock) {
        self.btnActionBlock (self.indexPath);
    }
}

@end

@interface EServiceMainMapVC () <BMKMapViewDelegate, BMKLocationServiceDelegate, BMKGeoCodeSearchDelegate, UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    BMKLocationService* _locService;
    BMKGeoCodeSearch *_geoCodeSearch;
}

@property (nonatomic, weak) IBOutlet UIView *bottomBtnsView;

@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;

@property (nonatomic, weak) IBOutlet BMKMapView *mapView;

@property (nonatomic, weak) IBOutlet UIButton *singleEasyOrderBtn;

@property (nonatomic, weak) IBOutlet UIButton *secondEasyOrderBtn;

@property (nonatomic, weak) IBOutlet UIButton *secondManualOrderBtn;

@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) IBOutlet UIControl *consultantSelectionMaskView;

@property (nonatomic, strong) IBOutlet EServiceConsultantDetailView *consultantDetailView;

@property (nonatomic, strong) NSMutableArray *dataList;

@property (nonatomic, assign) BOOL firesUpdatePoint;

@property (nonatomic, assign) CLLocationCoordinate2D userCurrentCoordinate;

@property (nonatomic, strong) EServiceLocatePinView *locatePinView;

@property (nonatomic, strong) BMKReverseGeoCodeResult *userPointReverseGeoCode;

@property (nonatomic, strong) UIBarButtonItem *searchBarButton;

@property (nonatomic, assign) UIEdgeInsets mapPadding;

@property (nonatomic, assign) CLLocationCoordinate2D coordinateFromSelection;

@property (nonatomic, assign) BOOL updateCoordinateFromSelection;


@end

@implementation EServiceMainMapVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self componentSetting];
    [self initializationUI];
    [self setReactiveRules];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.mapPadding = UIEdgeInsetsMake(CGRectGetHeight(self.searchBar.frame), 0.0f,
                                       CGRectGetHeight(self.bottomBtnsView.frame), 0.0f);
    _mapView.mapPadding = self.mapPadding;
    self.locatePinView.centerPointOffset = UIOffsetMake(0.0f, self.mapPadding.top-self.mapPadding.bottom);
    [self.locatePinView layoutSubviews];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.mapView viewWillDisappear];
    self.mapView.delegate = nil;
    _locService.delegate = nil;
    _geoCodeSearch.delegate = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.mapView viewWillAppear];
    if (self.mapView.delegate != self) {
        if (!self.mapView.delegate) self.mapView.delegate = nil;
        self.mapView.delegate = self;
    }
    if (_locService.delegate != self) {
        if (!_locService.delegate) _locService.delegate = nil;
        _locService.delegate = self;
    }
    if (_geoCodeSearch.delegate != self) {
        if (!_geoCodeSearch.delegate) _geoCodeSearch.delegate = nil;
        _geoCodeSearch.delegate = self;
    }
    
    if (self.updateCoordinateFromSelection) {
        self.updateCoordinateFromSelection = NO;
        [self.mapView setCenterCoordinate:self.coordinateFromSelection animated:NO];
        self.coordinateFromSelection = CLLocationCoordinate2DMake(0, 0);
    }
    
}

- (void)initializationUI {
    @autoreleasepool {
        [self setupLocatePinView];
    }
}

- (void)setupLocatePinView {
    @autoreleasepool {
        
        UINib *nib = [UINib nibWithNibName:@"EServiceLocatePinView" bundle:nil];
        NSArray *viewList = [nib instantiateWithOwner:self options:nil];
        self.locatePinView = viewList.lastObject;
        self.locatePinView.translatesAutoresizingMaskIntoConstraints = NO;
        self.locatePinView.showArrow = YES;
        [self.view insertSubview:self.locatePinView belowSubview:self.consultantSelectionMaskView];
        [self.locatePinView addTarget:self action:@selector(pushToSelectLocation) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)handleNavBackBtnPopOtherAction {
    @autoreleasepool {
        
    }
}

- (void)componentSetting {
    @autoreleasepool {
        self.loginAfterShouldPopToRoot = NO;
        
        UINib *listNib = [UINib nibWithNibName:@"EServiceConsultantDetailView" bundle:nil];
        [listNib instantiateWithOwner:self options:nil];
        
        UINib *nib = [UINib nibWithNibName:@"EServiceMainMapCell" bundle:nil];
        [self.collectionView registerNib:nib forCellWithReuseIdentifier:@"cell"];
        [self.collectionView registerClass:UICollectionReusableView.class forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headerFooterCell"];
        [self.collectionView registerClass:UICollectionReusableView.class forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"headerFooterCell"];
        
        self.dataList = [@[] mutableCopy];
        
        switch (self.serviceType) {
            case EServiceTypeOfERepair:
                self.title = @"E-代修";
                break;
            case EServiceTypeOfEInspect:
                self.title = @"E-代检";
                break;
            case EServiceTypeOfEInsurance:
                self.title = @"E-代赔";
                self.secondEasyOrderBtn.hidden = YES;
                self.secondManualOrderBtn.hidden = YES;
                self.singleEasyOrderBtn.hidden = NO;
                break;
                
            default:
                break;
        }
        
        [self.searchBar setBarTintColor:[UIColor colorWithRed:0.961 green:0.961 blue:0.961 alpha:1.00]];
        [self.searchBar setBorderWithColor:[UIColor colorWithRed:0.839 green:0.843 blue:0.863 alpha:1.00] borderWidth:0.5f];
        
        [self.singleEasyOrderBtn setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:5.0f];
        [self.secondEasyOrderBtn setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:5.0f];
        [self.secondManualOrderBtn setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:5.0f];
        
        
        
        UIToolbar *toolBar =  [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), 40)];
        [toolBar setBarStyle:UIBarStyleDefault];
        UIBarButtonItem * spaceButton = [[UIBarButtonItem  alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                      target:self
                                                                                      action:nil];
        UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc]initWithTitle:getLocalizationString(@"cancel")
                                                                     style:UIBarButtonItemStyleDone
                                                                    target:self.searchBar
                                                                    action:@selector(resignFirstResponder)];
        self.searchBarButton = [[UIBarButtonItem alloc]initWithTitle:getLocalizationString(@"提交搜索")
                                                               style:UIBarButtonItemStyleDone
                                                              target:self
                                                              action:@selector(searchConsultantByPhone)];
        self.searchBarButton.enabled = NO;
        NSArray * buttonsArray = [NSArray arrayWithObjects:cancelBtn, spaceButton, self.searchBarButton, nil];
        [toolBar setItems:buttonsArray];
        self.searchBar.inputAccessoryView = toolBar;
        
        
        _geoCodeSearch = [BMKGeoCodeSearch new];
        _geoCodeSearch.delegate = self;

        _mapView.delegate = self;
        _locService = [[BMKLocationService alloc]init];
        _locService.delegate = self;
        [_locService startUserLocationService];
        _mapView.showsUserLocation = NO;
        _mapView.zoomLevel = 15;
        _mapView.userTrackingMode = BMKUserTrackingModeFollow;
        _mapView.showsUserLocation = YES;
//        _mapView.delegate = self;
//        BMKPointAnnotation *userAnnotation = [[BMKPointAnnotation alloc] init];
//        userAnnotation.coordinate = CLLocationCoordinate2DMake(28.227455, 112.905907);
//        [_mapView addAnnotation:userAnnotation];
    }
    
}

- (void)setReactiveRules {
//    @weakify(self);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)locateCurrentView {
    [self.mapView setCenterCoordinate:self.userCurrentCoordinate animated:YES];
    BMKReverseGeoCodeOption *reverseGeoCodeOption = [BMKReverseGeoCodeOption new];
    reverseGeoCodeOption.reverseGeoPoint = self.userCurrentCoordinate;
    [_geoCodeSearch reverseGeoCode:reverseGeoCodeOption];
}

- (IBAction)pushToSelectLocation {
    @autoreleasepool {
        EServiceSelectLocationVC *vc = [EServiceSelectLocationVC new];
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
        @weakify(self);
        vc.responsBlock = ^(BMKPoiInfo *addressPoiInfo) {
            @strongify(self);
            self.coordinateFromSelection = addressPoiInfo.pt;
            self.updateCoordinateFromSelection = YES;
        };
    }
}

- (IBAction)orderAction:(UIButton *)sender {
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    [self getUserMemberStatusNServicePrice:sender];
}

- (void)pushToSubmitionFormVCWithConsultantID:(NSString *)consultantID consultantName:(NSString *)consultantName consultantPhone:(NSString *)consultantPhone {
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    @autoreleasepool {
        if (!consultantPhone||[consultantPhone isEqualToString:@""]) {
            consultantPhone = @"--";
        }
        EServiceSubmitionFormVC *vc = [EServiceSubmitionFormVC new];
        vc.wasAppointment = NO;
        vc.wasSelectedConsultant = YES;
        vc.consultantID = consultantID;
        vc.consultantName = consultantName;
        vc.consultantPhone = consultantPhone;
        vc.serviceType = self.serviceType;
        vc.userLocatedAddress = self.userPointReverseGeoCode.address;
        vc.userLocatedAddressCoordinate = self.mapView.centerCoordinate;
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)handleUserLoginResult:(BOOL)isSuccess fromAlert:(BOOL)fromAlert {
    
}

#pragma -mark UICollectionViewDelegate, UICollectionViewDataSource
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(240, 128);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *recommendView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"headerFooterCell" forIndexPath:indexPath];
    recommendView.backgroundColor = CDZColorOfClearColor;
    return recommendView;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(12, 128);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return CGSizeMake(12, 128);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    EServiceMainMapCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CDZKeyOfCellIdentKey forIndexPath:indexPath];
    cell.indexPath = indexPath;
    if (!cell.btnActionBlock) {
        @weakify(self);
        cell.btnActionBlock = ^(NSIndexPath *indexPath) {
            @strongify(self);
            NSDictionary * detail = self.dataList[indexPath.item];
            NSString *consultantID = [SupportingClass verifyAndConvertDataToString:detail[@"id"]];
            NSString *consultantName = [SupportingClass verifyAndConvertDataToString:detail[@"realName"]];
            NSString *consultantPhone = [SupportingClass verifyAndConvertDataToString:detail[@"telphone"]];
            [self hideConsultantSelectionView];
            if (UserBehaviorHandler.shareInstance.getUserMemberType<UserMemberTypeOfSilverMedal) {
                [SupportingClass showAlertViewWithTitle:@"" message:@"金牌及以上会员才可享受E服务，您还不是金牌以上会员，是否了解如何成为金牌会员？" isShowImmediate:YES cancelButtonTitle:@"cancel" otherButtonTitles:@"去了解" clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                    if (btnIdx.integerValue==1) {
                        MemberDetailVC *vc = [MemberDetailVC new];
                        vc.memberType = UserMemberTypeOfGoldMedal;
                        [self setDefaultNavBackButtonWithoutTitle];
                        [self.navigationController pushViewController:vc animated:YES];
                    }
                }];
            }else{
            [self pushToSubmitionFormVCWithConsultantID:consultantID consultantName:consultantName consultantPhone:consultantPhone];
            }
        };
    }
    NSDictionary *detail = self.dataList[indexPath.item];
//    distance = 12251;
//    faceImg = "http://admin.bccar.net:80/imgUpload/uploads/20160524140221IhYPORbhuo.png";
//    id = 16052413490713023337;
//    latitude = "28.226789";
//    longitude = "112.905343";
//    "order_num" = 2;
//    realName = "\U674e\U56db";
//    star = 0;
//    time = 20;
//    comment = @"暂无评论";
    
    cell.consultantNameLabel.text = detail[@"realName"];
    
    NSString *imgURLStr = detail[@"faceImg"];
    cell.consultantPortrait.image = cell.portraitImage;
    if ([imgURLStr isContainsString:@"http"]) {
        [cell.consultantPortrait setImageWithURL:[NSURL URLWithString:imgURLStr] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    
    NSNumber *starNum = [SupportingClass verifyAndConvertDataToNumber:detail[@"star"]];
    cell.consultantRatingView.value = starNum.floatValue;
    
    NSMutableAttributedString *serviceNumText = [NSMutableAttributedString new];
    [serviceNumText appendAttributedString:[[NSAttributedString alloc]
                                            initWithString:@"服务次数\n"
                                            attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"646464"],
                                                         NSFontAttributeName:[UIFont systemFontOfSize:9]}]];
    [serviceNumText appendAttributedString:[[NSAttributedString alloc]
                                            initWithString:[NSString stringWithFormat:@"%@次", [SupportingClass verifyAndConvertDataToString:detail[@"order_num"]]]
                                            attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"323232"],
                                                         NSFontAttributeName:[UIFont systemFontOfSize:11]}]];
    cell.consultantServiceNumLabel.attributedText = serviceNumText;
    
    
    NSMutableAttributedString *timeText = [NSMutableAttributedString new];
    [timeText appendAttributedString:[[NSAttributedString alloc]
                                      initWithString:@"时间\n"
                                      attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"646464"],
                                                   NSFontAttributeName:[UIFont systemFontOfSize:9]}]];
    [timeText appendAttributedString:[[NSAttributedString alloc]
                                      initWithString:[NSString stringWithFormat:@"%@分钟", [SupportingClass verifyAndConvertDataToString:detail[@"time"]]]
                                      attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"323232"],
                                                   NSFontAttributeName:[UIFont systemFontOfSize:11]}]];
    cell.consultantTimeLabel.attributedText = timeText;
    
    
    NSMutableAttributedString *distanceText = [NSMutableAttributedString new];
    [distanceText appendAttributedString:[[NSAttributedString alloc]
                                          initWithString:@"距离\n"
                                          attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"646464"],
                                                       NSFontAttributeName:[UIFont systemFontOfSize:9]}]];
    [distanceText appendAttributedString:[[NSAttributedString alloc]
                                          initWithString:[NSString stringWithFormat:@"%@KM", [SupportingClass verifyAndConvertDataToString:detail[@"distance"]]]
                                          attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"323232"],
                                                       NSFontAttributeName:[UIFont systemFontOfSize:11]}]];
    cell.consultantDistanceLabel.attributedText = distanceText;
    
    NSString *comment = detail[@"comment"];
    if (!comment||[comment isEqualToString:@""]) {
        comment = @"暂无评论";
    }
    cell.consultantCommentLabel.text = comment;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.consultantDetailView) {
        @autoreleasepool {
            UINib *nib = [UINib nibWithNibName:@"EServiceConsultantDetailView" bundle:nil];
            [nib instantiateWithOwner:self options:nil];
        }
    }
    if (!self.consultantDetailView.btnAction) {
        @weakify(self);
        self.consultantDetailView.btnAction = ^(NSString *consultantID, NSString *consultantName, NSString *consultantPhone){
            @strongify(self);
            [self hideConsultantSelectionView];
            [self pushToSubmitionFormVCWithConsultantID:consultantID consultantName:consultantName consultantPhone:consultantPhone];
        };
    }
    NSDictionary * detail = self.dataList[indexPath.item];
    NSString *consultantID = [SupportingClass verifyAndConvertDataToString:detail[@"id"]];
    self.consultantDetailView.consultantID = consultantID;
    self.consultantDetailView.userCurrentCoordinate = self.mapView.centerCoordinate;
    [self.consultantDetailView showDetailView];
}

#pragma mark - SearchBar Configs & UISearchBarDelegate

- (void)searchConsultantByPhone {
    [self.searchBar resignFirstResponder];
    [self getConsultantPostionListWithConsultantPhoneNum:self.searchBar.text shouldShowCollectionView:YES];
    [self updateSearchCancelButton];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = NO;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = YES;
    self.searchBarButton.enabled = (searchBar.text.length>=11);
    [self updateSearchCancelButton];
    return YES;
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSUInteger maxLength = 11;
    NSCharacterSet *numCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789 "];
    NSString *trimedText = [text stringByTrimmingCharactersInSet:numCharacterSet];
    NSString *invertedTrimedText = [text stringByTrimmingCharactersInSet:[numCharacterSet invertedSet]];
    if (trimedText.length!=0) {
        if (invertedTrimedText.length!=0) {
            NSUInteger remindLen = maxLength-searchBar.text.length;
            if (remindLen>0) {
                searchBar.text = [searchBar.text stringByReplacingCharactersInRange:NSMakeRange(range.location, 0) withString:[invertedTrimedText substringToIndex:remindLen]];
            }
        }
        [self searchBar:searchBar textDidChange:searchBar.text];
        return NO;
    }else if(searchBar.text.length+invertedTrimedText.length>11) {
        NSUInteger remindLen = maxLength-searchBar.text.length;
        if (remindLen>0) {
            searchBar.text = [searchBar.text stringByReplacingCharactersInRange:NSMakeRange(range.location, 0) withString:[invertedTrimedText substringToIndex:remindLen]];
        }
        [self searchBar:searchBar textDidChange:searchBar.text];
        return NO;
    }
    if (searchBar.text.length>=11&&![text isEqualToString:@""]) {
        return NO;
    }
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.searchBarButton.enabled = (searchBar.text.length>=11);
}

- (void)updateSearchCancelButton {
    [self.searchBar.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull view , NSUInteger idx, BOOL * _Nonnull stop) {
        [view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull subview, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([subview isKindOfClass:UIButton.class]) {
                [(UIButton*)subview setTitle:@"取消" forState:UIControlStateNormal];
                [(UIButton*)subview setEnabled:YES];
                [(UIButton*)subview setUserInteractionEnabled:YES];
            }
        }];
    }];
}

#pragma mark - MapView Configs & BMKMapViewDelegate

- (void)updateMapAnnotations {
    @autoreleasepool {
        if (self.mapView.annotations.count>0) {
            [self.mapView removeAnnotations:self.mapView.annotations];
        }
        @weakify(self);
        [self.dataList enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull detail, NSUInteger idx, BOOL * _Nonnull stop) {
            @strongify(self);
            NSNumber *longitude = [SupportingClass verifyAndConvertDataToNumber:detail[@"longitude"]];
            NSNumber *latitude = [SupportingClass verifyAndConvertDataToNumber:detail[@"latitude"]];
            NSNumber *starValue = [SupportingClass verifyAndConvertDataToNumber:detail[@"star"]];
            NSString *consultantID = [SupportingClass verifyAndConvertDataToString:detail[@"id"]];
            NSString *consultantName = [SupportingClass verifyAndConvertDataToString:detail[@"realName"]];
            NSString *consultantPortraitString = [SupportingClass verifyAndConvertDataToString:detail[@"faceImg"]];
            EServiceMapPointAnnotation *pointAnnotation = [[EServiceMapPointAnnotation alloc] init];
            pointAnnotation.coordinate = CLLocationCoordinate2DMake(latitude.doubleValue, longitude.doubleValue);
            pointAnnotation.consultantID = consultantID;
            pointAnnotation.consultantPortraitString = consultantPortraitString;
            pointAnnotation.consultantName = consultantName;
            pointAnnotation.starValue = starValue;
            [self.mapView addAnnotation:pointAnnotation];
        }];
    }
}

/**
 *返回反地理编码搜索结果
 *@param searcher 搜索对象
 *@param result 搜索结果
 *@param error 错误号，@see BMKSearchErrorCode
 */
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error {
    if (error==BMK_SEARCH_NO_ERROR) {
        self.userPointReverseGeoCode = result;
        NSString *address = result.address;
        if (!address||[address isEqualToString:@""]) address = @"无法显示地址";
        self.locatePinView.addressLabel.text = address;
        if (![address isEqualToString:@"无法显示地址"]) {
            [self getConsultantPostionListWithConsultantPhoneNum:@"" shouldShowCollectionView:NO];
        }
    }
}


/**
 *在地图View将要启动定位时，会调用此函数
 *@param mapView 地图View
 */
- (void)willStartLocatingUser {
    NSLog(@"start locate");
}

/**
 *用户方向更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation {
    [_mapView updateLocationData:userLocation];
    self.userCurrentCoordinate = userLocation.location.coordinate;
    NSLog(@"%f , %f", userLocation.location.coordinate.latitude ,userLocation.location.coordinate.longitude);
    NSLog(@"heading is %@",userLocation.heading);
}

/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation {
    NSLog(@"didUpdateUserLocation lat %f,long %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
    [_mapView updateLocationData:userLocation];
    CLLocationCoordinate2D coordinate = userLocation.location.coordinate;
    self.userCurrentCoordinate = coordinate;
    _mapView.userTrackingMode = BMKUserTrackingModeNone;
    if (!self.firesUpdatePoint) {
        [self locateCurrentView];
        self.firesUpdatePoint = YES;
    }
}

/**
 *在地图View停止定位后，会调用此函数
 *@param mapView 地图View
 */
- (void)didStopLocatingUser {
    NSLog(@"stop locate");
}

/**
 *定位失败后，会调用此函数
 *@param mapView 地图View
 *@param error 错误号，参考CLError.h中定义的错误号
 */
- (void)didFailToLocateUserWithError:(NSError *)error {
    NSLog(@"location error");
}

#pragma mark BMKMapViewDelegate
/**
 *根据anntation生成对应的View
 *@param mapView 地图View
 *@param annotation 指定的标注
 *@return 生成的标注View
 */
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation {
    static NSString * pinIdentifier = @"annotation";
    
    if ([annotation isKindOfClass:EServiceMapPointAnnotation.class]) {
        BMKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:pinIdentifier];
       
        if (annotationView == nil) {
            annotationView = [[EServiceConsultantMapAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pinIdentifier];
        }
        
        EServiceMapPointAnnotation *pointAnnotation = (EServiceMapPointAnnotation *)annotation;
        EServiceConsultantMapAnnotationView *theAnnotationView = (EServiceConsultantMapAnnotationView *)annotationView;
        theAnnotationView.consultantID = pointAnnotation.consultantID;
        theAnnotationView.consultantNameLabel.text = pointAnnotation.consultantName;
        theAnnotationView.consultantRatingView.value = pointAnnotation.starValue.floatValue;
        if ([pointAnnotation.consultantPortraitString isContainsString:@"http"]) {
            [theAnnotationView.consultantPortrait setImageWithURL:[NSURL URLWithString:pointAnnotation.consultantPortraitString] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        }
        if (!theAnnotationView.actionBlock) {
            @weakify(self);
            theAnnotationView.actionBlock = ^(NSString *consultantID) {
                @strongify(self);
                [self showConsultantSelectionViewWithConsultantID:consultantID];
            };
        }
        return annotationView;
    }
    
    return nil;
}

/**
 *地图区域改变完成后会调用此接口
 *@param mapview 地图View
 *@param animated 是否动画
 */
- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    BMKReverseGeoCodeOption *reverseGeoCodeOption = [BMKReverseGeoCodeOption new];
    reverseGeoCodeOption.reverseGeoPoint = mapView.centerCoordinate;
    [_geoCodeSearch reverseGeoCode:reverseGeoCodeOption];
}

/**
 *当选中一个annotation views时，调用此接口
 *@param mapView 地图View
 *@param views 选中的annotation views
 */
- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view {
    
}

- (void)showConsultantSelectionViewWithConsultantID:(NSString *)consultantID {
    if (consultantID&&![consultantID isEqualToString:@""]) {
        __block NSIndexPath *indexPath = nil;
        [self.dataList enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull detail, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *verConsultantID = [SupportingClass verifyAndConvertDataToString:detail[@"id"]];
            if ([verConsultantID isEqualToString:consultantID]) {
                indexPath = [NSIndexPath indexPathForItem:idx inSection:0];
            }
        }];
        
        UIWindow *window = UIApplication.sharedApplication.keyWindow;
        self.consultantSelectionMaskView.frame = window.bounds;
        self.consultantSelectionMaskView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.consultantSelectionMaskView.translatesAutoresizingMaskIntoConstraints = YES;
        [self.collectionView reloadData];
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
        [window addSubview:self.consultantSelectionMaskView];
    }
}

- (IBAction)hideConsultantSelectionView {
    [self.consultantSelectionMaskView removeFromSuperview];
    if (self.searchBar.text&&![self.searchBar.text isEqualToString:@""]&&self.dataList.count==1) {
        [self getConsultantPostionListWithConsultantPhoneNum:@"" shouldShowCollectionView:NO];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)getConsultantPostionListWithConsultantPhoneNum:(NSString *)consultantPhoneNum shouldShowCollectionView:(BOOL)shouldShow {
    
    @weakify(self);
    [ProgressHUDHandler showHUD];
    [APIsConnection.shareConnection personalCenterAPIsGetEServiceConsultantPostionListWithLongitude:@(self.userPointReverseGeoCode.location.longitude).stringValue latitude:@(self.userPointReverseGeoCode.location.latitude).stringValue eServiceType:self.serviceType consultantPhoneNum:consultantPhoneNum success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSString *sing = responseObject[@"sing"];
        NSLog(@"%@",message);
        
      
        
        if (![message isContainsString:@"返回成功"]||errorCode!=0){
            if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {return;};
            [ProgressHUDHandler dismissHUD];
            if ([message isEqualToString:@"没有专员"]) message = @"很抱歉，暂未找到为您服务的专员";
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
            return;
        }
        
        if ([sing isEqualToString:@"没有改专员"]) {
            [SupportingClass showToast:@"没有找到该专员(或者该专员没有上班)，以下是车队长为您推荐的专员！"];
        }
        
        [ProgressHUDHandler dismissHUD];
        [self.dataList removeAllObjects];
        [self.dataList addObjectsFromArray:responseObject[CDZKeyOfResultKey]];
        [self.collectionView reloadData];
        [self updateMapAnnotations];
        if (shouldShow) {
            NSDictionary * detail = self.dataList.lastObject;
            NSString *consultantID = [SupportingClass verifyAndConvertDataToString:detail[@"id"]];
            [self showConsultantSelectionViewWithConsultantID:consultantID];
        }
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        NSLog(@"%@",error);
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
- (void)pushToEServiceList {
    @autoreleasepool {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.class == %@", EServiceServiceListVC.class];
        NSArray *result = [self.navigationController.viewControllers filteredArrayUsingPredicate:predicate];
        if (result&&result.count>0) {
            [self.navigationController popToViewController:result.lastObject animated:YES];
            return;
        }
        
        EServiceServiceListVC *vc = EServiceServiceListVC.new;
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }
}


- (void)checkIsMakeApointmentOrderBtn:(UIButton *)sender priceDetail:(NSDictionary *)detail {
    [ProgressHUDHandler showHUD];
    @weakify(self);
    [APIsConnection.shareConnection personalCenterAPIsGetEServiceVerifyUserWasMadeAppointmentWithAccessToken:self.accessToken theSign:@"" eServiceType:self.serviceType success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        [ProgressHUDHandler dismissHUD];
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        if (errorCode==0) {
            EServiceSubmitionFormVC *vc = [EServiceSubmitionFormVC new];
            vc.wasAppointment = (self.secondManualOrderBtn==sender);
            vc.serviceType = self.serviceType;
            vc.priceDetail = detail;
            vc.userLocatedAddress = self.userPointReverseGeoCode.address;
            vc.userLocatedAddressCoordinate = self.mapView.centerCoordinate;
            [self setDefaultNavBackButtonWithoutTitle];
            [self.navigationController pushViewController:vc animated:YES];
        }
        if ([message isContainsString:@"重复添加"]) {
            message = @"你已预约过E代修服务，请完成服务后再次下单或预约！";
            switch (self.serviceType) {
                case EServiceTypeOfERepair:
                    message = @"你已预约过E代修服务，请完成服务后再次下单或预约！";
                    break;
                case EServiceTypeOfEInspect:
                    message = @"你已预约过E代检服务，请完成服务后再次下单或预约！";
                    break;
                case EServiceTypeOfEInsurance:
                    message = @"你已预约过E代赔服务，请完成服务后再次下单或预约！";
                    break;
                default:
                    break;
            }
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                [self pushToEServiceList];
            }];
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

- (void)getUserMemberStatusNServicePrice:(UIButton *)sender {
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    
    @weakify(self);
    [ProgressHUDHandler showHUD];
    [APIsConnection.shareConnection personalCenterAPIsGetEServiceUserMemberStatusNPriceWithAccessToken:self.accessToken eServiceType:self.serviceType success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        
      
        
        if (![message isContainsString:@"返回成功"]||errorCode!=0){
            if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {return;};
            [ProgressHUDHandler dismissHUD];
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
            return;
        }
        
//        "price":"0","price_two":"0","level_name":"钻石会员"
        NSDictionary *detail = responseObject[CDZKeyOfResultKey];
        [UserBehaviorHandler.shareInstance updateUserMemberType:detail[@"level_name"]];
        if (UserBehaviorHandler.shareInstance.getUserMemberType<UserMemberTypeOfSilverMedal) {
            [ProgressHUDHandler dismissHUD];
            [SupportingClass showAlertViewWithTitle:@"" message:@"金牌及以上会员才可享受E服务，您还不是金牌以上会员，是否了解如何成为金牌会员？" isShowImmediate:YES cancelButtonTitle:@"cancel" otherButtonTitles:@"去了解" clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                if (btnIdx.integerValue>0) {
                    MemberDetailVC *vc = [MemberDetailVC new];
                    vc.memberType = UserMemberTypeOfGoldMedal;
                    [self setDefaultNavBackButtonWithoutTitle];
                    [self.navigationController pushViewController:vc animated:YES];
                }
            }];
            return;
        }
        [self checkIsMakeApointmentOrderBtn:sender priceDetail:detail];
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        NSLog(@"%@",error);
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

@end
