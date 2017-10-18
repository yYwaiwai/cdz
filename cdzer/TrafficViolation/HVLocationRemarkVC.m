//
//  HVLocationRemarkVC.m
//  cdzer
//
//  Created by KEns0n on 1/23/16.
//  Copyright © 2016 CDZER. All rights reserved.
//
#define vMapZoomLevel 13

#import "InsetsTextField.h"
#import "HVLocationRemarkVC.h"
#import <GPXParser/GPXParser.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>

@interface HVLRVCell : UITableViewCell

@property (nonatomic, assign) BOOL isSelected;

@end


@implementation HVLRVCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.imageView.image = [[ImageHandler getSKIcon] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.imageView.tintColor = CDZColorOfWeiboColor;
        [self.imageView sizeToFit];
        self.imageView.autoresizingMask = UIViewAutoresizingNone;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.imageView.tintColor = _isSelected?CDZColorOfDefaultColor:CDZColorOfWeiboColor;
    CGRect ivRect = self.imageView.frame;
    ivRect.origin.x = DefaultEdgeInsets.left;
    self.imageView.frame = ivRect;
    CGPoint ivCenter = self.imageView.center;
    ivCenter.y = CGRectGetHeight(self.frame)/2.0f;
    self.imageView.center = ivCenter;
}

@end

@interface HVLocationRemarkVC () <BMKMapViewDelegate, BMKPoiSearchDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>
{
    BMKMapView *_mapView;
    BMKPoiSearch *_bmkSearch;
}

@property (nonatomic, strong) UITableView *searchTableView;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) InsetsTextField *textField;

@property (nonatomic, assign) CGRect keyboardRect;

@property (nonatomic, strong) NSMutableArray *searchList;

@property (nonatomic, strong) NSMutableArray *displayList;

@property (nonatomic, strong) BMKPoiInfo *selectedPointInfo;

@property (nonatomic, strong) BMKPoiInfo *searchedPointInfo;

@property (nonatomic, assign) CLLocationCoordinate2D lastCenterCoordinate;


@end

@implementation HVLocationRemarkVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
    if (_mapView) {
        _mapView = nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"%@", _reverseGeoCodeResult);
    self.loginAfterShouldPopToRoot = NO;
    // Do any additional setup after loading the view.
    self.title = @"位置纠错";
    [self componentSetting];
    [self initializationUI];
    [self setReactiveRules];
}

- (void)handleUserLoginResult:(BOOL)isSuccess fromAlert:(BOOL)fromAlert {
    if (isSuccess) {
        
    }else {
        
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_mapView) {
        [_mapView viewWillAppear];
        _mapView.delegate = self;
        if (_mapView.annotations.count==0) {
            [_mapView removeAnnotations:_mapView.annotations];
            if (_latitude.doubleValue>0&&_longitude.doubleValue>0) {
                CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(_latitude.doubleValue, _longitude.doubleValue);
                BMKPointAnnotation *annotation = BMKPointAnnotation.new;
                annotation.coordinate = coordinate;
                [_mapView addAnnotation:annotation];
                [_mapView setCenterCoordinate:coordinate animated:YES];
                _mapView.zoomLevel = vMapZoomLevel;
            }
        }
    }
    if (!_selectedPointInfo&&_displayList.count>0) {
        [self tableView:_tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldEditing:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_mapView viewWillDisappear];
    _mapView.delegate = nil;
    _bmkSearch.delegate = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setReactiveRules {
    @autoreleasepool {
    }
    
}

- (void)componentSetting {
    @autoreleasepool {
        self.displayList = [@[] mutableCopy];
        self.searchList = [@[] mutableCopy];
        
        _bmkSearch = BMKPoiSearch.new;
        
        if (_bmkSearch&&_bmkSearch.delegate!=self) {
            _bmkSearch.delegate = nil;
            _bmkSearch.delegate = self;
        }
        
        if (!_reverseGeoCodeResult||[_reverseGeoCodeResult.address isEqualToString:@""]) {
            @weakify(self);
            if (self.latitude.doubleValue==0||self.longitude.doubleValue==0) {
                [UserLocationHandler.shareInstance startUserLocationServiceWithBlock:^(BMKUserLocation *userLocation, NSError *error) {
                    if (userLocation&&!error) {
                        @strongify(self);
                        self.latitude = @(userLocation.location.coordinate.latitude);
                        self.longitude = @(userLocation.location.coordinate.longitude);
                        [self reverseGeoCodeSearchWithCoordinate];
                    }else {
                        NSData *fileData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Changsha_China" ofType:@"gpx"]];
                        [GPXParser parse:fileData completion:^(BOOL success, GPX *gpx) {
                            @strongify(self);
                            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(28.22746, 112.905903);
                            if (success) {
                                Waypoint *wayPoint = gpx.waypoints[0];
                                coordinate = wayPoint.coordinate;
                            }
                            //转换GPS坐标至百度坐标(加密后的坐标)
                            NSDictionary* testdic = BMKConvertBaiduCoorFrom(coordinate,BMK_COORDTYPE_GPS);
                            NSLog(@"x=%@,y=%@",[testdic objectForKey:@"x"],[testdic objectForKey:@"y"]);
                            //解密加密后的坐标字典
                            CLLocationCoordinate2D baiduCoor = BMKCoorDictionaryDecode(testdic);//转换后的百度坐标
                            self.latitude = @(baiduCoor.latitude);
                            self.longitude = @(baiduCoor.longitude);
                            [self reverseGeoCodeSearchWithCoordinate];
                        }];
                    }
                    [UserLocationHandler.shareInstance stopUserLocationService];
                }];
            }else {
                [self reverseGeoCodeSearchWithCoordinate];
            }
        }else {
            [self.displayList addObjectsFromArray:self.reverseGeoCodeResult.poiList];
        }
        [self setRightNavButtonWithTitleOrImage:@"ok" style:UIBarButtonItemStyleDone target:self action:@selector(submitLocationCoordinate) titleColor:nil isNeedToSet:YES];
        
    }
}

- (void)reverseGeoCodeSearchWithCoordinate {
    
    @weakify(self);
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(self.latitude.doubleValue, self.longitude.doubleValue);
    [UserLocationHandler.shareInstance reverseGeoCodeSearchWithCoordinate:coordinate resultBlock:^(BMKReverseGeoCodeResult *result, BMKSearchErrorCode error) {
        @strongify(self);
        if (BMK_SEARCH_NO_ERROR==error) {
            self.reverseGeoCodeResult = result;
            NSLog(@"Get City Success!");
            [self.displayList removeAllObjects];
            [self.displayList addObjectsFromArray:self.reverseGeoCodeResult.poiList];
            if (self.tableView) {
                [self.tableView reloadData];
            }
            [self locateUserPosition];
        }
    }];
}

- (void)submitLocationCoordinate {
    [SupportingClass showAlertViewWithTitle:nil message:@"是否确认提交更改地点坐标！" isShowImmediate:YES cancelButtonTitle:@"cancel" otherButtonTitles:@"ok" clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
        if (btnIdx.integerValue>0) {
            [self submitAndUpdateLocationCoordinate];
        }
    }];
}

- (void)initializationUI {
    @autoreleasepool {
        self.scrollView.hidden = NO;
        
        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.scrollView.frame), 30.0f)];
        [toolbar setBarStyle:UIBarStyleDefault];
        UIBarButtonItem *spaceButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                    target:self
                                                                                    action:nil];
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]initWithTitle:getLocalizationString(@"finish")
                                                                      style:UIBarButtonItemStyleDone
                                                                     target:self
                                                                     action:@selector(hiddenKeyboard)];
        NSArray * buttonsArray = [NSArray arrayWithObjects:spaceButton,doneButton,nil];
        [toolbar setItems:buttonsArray];
        
        UIEdgeInsets insetsValue = DefaultEdgeInsets;
        insetsValue.left = 6.0f;
        UIImage *searchImg = [ImageHandler getImageFromCacheWithByFixdeRatioFileRootPath:nil fileName:@"search_s" type:FMImageTypeOfPNG needToUpdate:YES];
        self.textField = [[InsetsTextField alloc] initWithFrame:CGRectMake(10.0f, 6.0f, CGRectGetWidth(self.contentView.frame)-20.0f, 32.0f)
                                             andEdgeInsetsValue:insetsValue];
        _textField.borderStyle = UITextBorderStyleRoundedRect;
        _textField.leftViewMode = UITextFieldViewModeAlways;
        _textField.placeholder = @"请输入地址";
        _textField.inputAccessoryView = toolbar;
        _textField.delegate = self;
        _textField.leftView = [[UIImageView alloc] initWithImage:searchImg];
        [self.scrollView addSubview:_textField];
        
        _mapView = [[BMKMapView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(_textField.frame)+6.0f,
                                                                CGRectGetWidth(self.contentView.frame), CGRectGetWidth(self.contentView.frame)*0.7)];
        [self.scrollView addSubview:_mapView];
        
        
        
        UIImage *btnImageBKG = [ImageHandler getImageFromCacheByScreenRatioWithFileRootPath:nil fileName:@"nav_loc_bkg" type:FMImageTypeOfPNG
                                                                            scaleWithPhone4:NO offsetRatioForP4:0 needToUpdate:YES];
        
        UIImage *btnImage = [ImageHandler getImageFromCacheByScreenRatioWithFileRootPath:nil fileName:@"nav_loc_off" type:FMImageTypeOfPNG
                                                                         scaleWithPhone4:NO offsetRatioForP4:0 needToUpdate:YES];
        UIImage *btnImageSelected = [btnImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIButton *locationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        locationBtn.imageView.tintColor = CDZColorOfDefaultColor;
        [locationBtn setImage:btnImage forState:UIControlStateNormal];
        [locationBtn setImage:btnImageSelected forState:UIControlStateSelected];
        [locationBtn setBackgroundImage:btnImageBKG forState:UIControlStateNormal];
        [locationBtn setBackgroundImage:btnImageBKG forState:UIControlStateSelected];
        [locationBtn setBackgroundImage:btnImageBKG forState:UIControlStateHighlighted];
        [locationBtn sizeToFit];
        [locationBtn addTarget:self action:@selector(locateUserPosition) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:locationBtn];
        CGRect btnRect = locationBtn.frame;
        btnRect.origin.x = CGRectGetWidth(_mapView.frame)*0.8;
        btnRect.origin.y = CGRectGetMaxY(_mapView.frame)*0.8;
        locationBtn.frame = btnRect;
        
        
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(_mapView.frame), CGRectGetWidth(self.scrollView.frame),
                                                                       CGRectGetHeight(self.scrollView.frame)-CGRectGetMaxY(_mapView.frame))];
        _tableView.bounces = NO;
        _tableView.showsHorizontalScrollIndicator = NO;
//        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self.scrollView addSubview:_tableView];
        
        self.searchTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMinY(_mapView.frame), CGRectGetWidth(self.scrollView.frame),
                                                                       CGRectGetHeight(self.scrollView.frame)-CGRectGetMinY(_mapView.frame))];
        _searchTableView.bounces = NO;
        _searchTableView.alpha = 0;
        _searchTableView.showsHorizontalScrollIndicator = NO;
//        _searchTableView.showsVerticalScrollIndicator = NO;
        _searchTableView.delegate = self;
        _searchTableView.dataSource = self;
        [self.scrollView addSubview:_searchTableView];

    }
}

- (void)locateUserPosition {
    [self updateUserLocation:CLLocationCoordinate2DMake(_latitude.doubleValue, _longitude.doubleValue)];
}

- (void)updateUserLocation:(CLLocationCoordinate2D)coordinate {
    [_mapView setCenterCoordinate:coordinate animated:YES];
//    _mapView.zoomLevel = vMapZoomLevel;
    [self.displayList removeAllObjects];
    [self.displayList addObjectsFromArray:_reverseGeoCodeResult.poiList];
    [self tableView:_tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)hiddenKeyboard {
    [_textField resignFirstResponder];
    @weakify(self);
    [UIView animateWithDuration:0.26 animations:^{
        @strongify(self);
        self.searchTableView.alpha = 0;
    } completion:^(BOOL finished) {
        CGRect rect = self.searchTableView.frame;
        rect.size.height = CGRectGetHeight(self.scrollView.frame)-CGRectGetMinY(self->_mapView.frame);
        self.searchTableView.frame = rect;
    }];
}

- (void)keyboardWillShow:(NSNotification *)notifyObject {
    CGRect keyboardRect = [[notifyObject.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    if (!CGRectEqualToRect(keyboardRect, _keyboardRect)) {
        self.keyboardRect = keyboardRect;
        [self showSearchListTable];
    }
    
}

- (void)showSearchListTable {
    @autoreleasepool {
        @weakify(self);
        [UIView animateWithDuration:0.26 animations:^{
            @strongify(self);
            self.searchTableView.alpha = 1;
            CGRect rect = self.searchTableView.frame;
            rect.size.height = CGRectGetHeight(self.scrollView.frame)-CGRectGetHeight(self.keyboardRect)-CGRectGetMinY(self->_mapView.frame);
            self.searchTableView.frame = rect;
        }];
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (!CGRectEqualToRect(CGRectZero, _keyboardRect)) {
        [self showSearchListTable];
    }
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    [textField sendActionsForControlEvents:UIControlEventEditingChanged];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self hiddenKeyboard];
    [textField resignFirstResponder];
    return YES;
}


- (void)textFieldEditing:(id)sender {
    InsetsTextField *textField = nil;
    if (!sender) return;
    if ([sender isKindOfClass:[NSNotification class]]) textField = [(NSNotification *)sender object];
    if ([sender isKindOfClass:[InsetsTextField class]]) textField = sender;
    
    if (!textField.text||[textField.text isEqualToString:@""]){
        [self.searchList removeAllObjects];
        [_searchTableView reloadData];
        self.searchedPointInfo = nil;
        return;
    }
    
    BMKCitySearchOption *searchOption = [[BMKCitySearchOption alloc] init];
    searchOption.keyword = textField.text;
    searchOption.city = _reverseGeoCodeResult.addressDetail.city;
    [_bmkSearch poiSearchInCity:searchOption];
}

#pragma mark- BMKPoiSearchDelegate
/**
 *返回POI搜索结果
 *@param searcher 搜索对象
 *@param poiResult 搜索结果列表
 *@param errorCode 错误号，@see BMKSearchErrorCode
 */
- (void)onGetPoiResult:(BMKPoiSearch*)searcher result:(BMKPoiResult*)poiResult errorCode:(BMKSearchErrorCode)errorCode {
    switch (errorCode) {
        case BMK_SEARCH_NO_ERROR:{
            [self.searchList removeAllObjects];
            if (poiResult.poiInfoList&&poiResult.poiInfoList.count!=0) {
                [self.searchList addObjectsFromArray:poiResult.poiInfoList];
            }
            [_searchTableView reloadData];
            
            if ([_textField isFirstResponder]&&_searchedPointInfo) {
                NSIndexPath *indexPath = nil;
                NSInteger row = [[NSSet setWithArray:_searchList] containsObject:_searchedPointInfo];
                indexPath = [NSIndexPath indexPathForRow:row inSection:0];
                [_searchTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionTop];
            }
        }
            break;
            
        default:
            [self.searchList removeAllObjects];
            [_searchTableView reloadData];
            break;
    }
}


#pragma -mark UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // NSInteger the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (tableView==_tableView) {
        return _displayList.count;
    }
    return _searchList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView==_searchTableView) {
        static NSString *ident = @"cellS";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ident];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ident];
            cell.backgroundColor = CDZColorOfWhite;
            cell.textLabel.numberOfLines = 0;
            cell.detailTextLabel.numberOfLines = 0;
            
        }
        cell.textLabel.text = @"";
        cell.detailTextLabel.text = @"";
        BMKPoiInfo *poiInfo = _searchList[indexPath.row];
        cell.textLabel.text = poiInfo.name;
        cell.detailTextLabel.text = poiInfo.address;
        return cell;
    }
    
    HVLRVCell *cell = [tableView dequeueReusableCellWithIdentifier:CDZKeyOfCellIdentKey];
    if (!cell) {
        cell = [[HVLRVCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CDZKeyOfCellIdentKey];
        cell.backgroundColor = CDZColorOfWhite;
        cell.textLabel.font = [UIFont fontWithName:cell.textLabel.font.fontName size:cell.textLabel.font.pointSize-2];
        cell.textLabel.numberOfLines = 0;
        cell.detailTextLabel.numberOfLines = 0;
        
    }
    cell.isSelected = NO;
    cell.textLabel.text = @"";
    cell.detailTextLabel.text = @"";
    if (tableView==_tableView) {
        BMKPoiInfo *poiInfo = _displayList[indexPath.row];
        cell.textLabel.text = poiInfo.name;
        cell.detailTextLabel.text = poiInfo.address;
        if (poiInfo==_selectedPointInfo) {
            [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionTop];
            cell.isSelected = YES;
            
        }
    }
    // Configure the cell...
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView==_tableView) {
        return 78.0f;
    }
    return 60.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 0.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return 0.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_textField isFirstResponder]&&tableView==_searchTableView&&_searchList.count>0) {
        self.searchedPointInfo = _searchList[indexPath.row];
        _textField.text = _searchedPointInfo.name;
        self.selectedPointInfo = self.searchedPointInfo;
        [_displayList removeAllObjects];
        [_displayList addObjectsFromArray:_searchList];
        [_tableView reloadData];
        [self updatePinWithCoordinate:_selectedPointInfo.pt withSetZoomLevel:YES];
        [_tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionTop];
        [self hiddenKeyboard];
    }
    if (tableView==_tableView&&_displayList.count>0) {
        self.selectedPointInfo = _displayList[indexPath.row];
        [self updatePinWithCoordinate:_selectedPointInfo.pt withSetZoomLevel:YES];
        [tableView reloadData];
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionTop];
    }
    
}

- (void)updatePinWithCoordinate:(CLLocationCoordinate2D)coordinate withSetZoomLevel:(BOOL)isSet{
    
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id <BMKAnnotation> _Nonnull annotation, NSDictionary<NSString *,id> * _Nullable bindings) {
        if (annotation.coordinate.latitude==self.latitude.doubleValue&&
            annotation.coordinate.longitude==self.longitude.doubleValue) {
            return NO;
        }
        return YES;
    }];
    NSArray *result = [_mapView.annotations filteredArrayUsingPredicate:predicate];
    if (result.count>0) {
        [_mapView removeAnnotations:result];
    }
    
    BMKPointAnnotation *annotation = BMKPointAnnotation.new;
    annotation.coordinate = coordinate;
    [_mapView addAnnotation:annotation];
    [_mapView setCenterCoordinate:annotation.coordinate animated:NO];
    if (isSet) {
        _mapView.zoomLevel = vMapZoomLevel;
    }
}

#pragma mark BMKMapViewDelegate
/**
 *根据anntation生成对应的View
 *@param mapView 地图View
 *@param annotation 指定的标注
 *@return 生成的标注View
 */
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation {
    @autoreleasepool {
        if (annotation.coordinate.latitude==self.latitude.doubleValue&&
            annotation.coordinate.longitude==self.longitude.doubleValue) {
            static NSString * showShopInfoPinIdentifier = @"originalPin";
            BMKAnnotationView *newAnnotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:showShopInfoPinIdentifier];
            if (newAnnotationView == nil) {
                UIImage *image = [ImageHandler getImageFromCacheByScreenRatioWithFileRootPath:nil fileName:@"pin_lv1" type:FMImageTypeOfPNG scaleWithPhone4:NO offsetRatioForP4:0 needToUpdate:YES];
                
                newAnnotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:showShopInfoPinIdentifier];
                newAnnotationView.canShowCallout = YES;
                newAnnotationView.image = image;
                newAnnotationView.centerOffset = CGPointMake(0, -(newAnnotationView.frame.size.height * 0.5));
            }
            return newAnnotationView;
        }
        
        static NSString * showShopInfoPinIdentifier = @"selectedPin";
        BMKAnnotationView *newAnnotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:showShopInfoPinIdentifier];
        if (newAnnotationView == nil) {
            UIImage *image = [ImageHandler getImageFromCacheByScreenRatioWithFileRootPath:nil fileName:@"pin_lv3" type:FMImageTypeOfPNG scaleWithPhone4:NO offsetRatioForP4:0 needToUpdate:YES];
            
            newAnnotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:showShopInfoPinIdentifier];
            newAnnotationView.canShowCallout = YES;
            newAnnotationView.image = image;
            newAnnotationView.centerOffset = CGPointMake(0, -(newAnnotationView.frame.size.height * 0.5));
        }
        
        return newAnnotationView;
    }
}
/**
 *当mapView新添加annotation views时，调用此接口
 *@param mapView 地图View
 *@param views 新添加的annotation views
 */
- (void)mapView:(BMKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
    
}

/**
 *地图区域改变完成后会调用此接口
 *@param mapview 地图View
 *@param animated 是否动画
 */
- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    
    NSLog(@"location.latitudee::%f",mapView.centerCoordinate.latitude);
    NSLog(@"location.longitude::%f",mapView.centerCoordinate.longitude);
    @weakify(self);
    if (mapView.centerCoordinate.latitude!=_lastCenterCoordinate.latitude&&
        mapView.centerCoordinate.longitude!=_lastCenterCoordinate.longitude) {
        self.lastCenterCoordinate = mapView.centerCoordinate;
        [UserLocationHandler.shareInstance reverseGeoCodeSearchWithCoordinate:_lastCenterCoordinate resultBlock:^(BMKReverseGeoCodeResult *result, BMKSearchErrorCode error) {
            @strongify(self);
            if (BMK_SEARCH_NO_ERROR==error) {
                NSLog(@"Get City Success!");
                [self.displayList removeAllObjects];
                [self.displayList addObjectsFromArray:result.poiList];
                if (self.tableView&&self.displayList.count>0) {
                    self.selectedPointInfo = self.displayList[0];
                    [self updatePinWithCoordinate:self.selectedPointInfo.pt withSetZoomLevel:NO];
                    [self.tableView reloadData];
                    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
                    
                }else {
                    [self updatePinWithCoordinate:mapView.centerCoordinate withSetZoomLevel:NO];
                    self.selectedPointInfo = nil;
                    [self.tableView reloadData];
                }
            }
        }];
        
    }

}

- (void)submitAndUpdateLocationCoordinate {
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    [ProgressHUDHandler showHUD];
    @weakify(self);
    [[APIsConnection shareConnection] personalCenterAPIsPostUserCorrectViolationLocationRequestWithAccessToken:self.accessToken blacksiteAddress:self.address longitude:@(_mapView.centerCoordinate.longitude) latitude:@(_mapView.centerCoordinate.latitude) cityName:_reverseGeoCodeResult.addressDetail.city success:^(AFHTTPRequestOperation *operation, id responseObject) {
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {return;};
        if (errorCode!=0&&![message isEqualToString:@"返回成功"]) {
            
            [ProgressHUDHandler dismissHUD];
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
            return;
        }
        
        [ProgressHUDHandler showSuccessWithStatus:nil onView:nil completion:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (error.code==-1009) {
            [SupportingClass showAlertViewWithTitle:@"error" message:@"网络连接失败，请检查网络设置！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                [ProgressHUDHandler dismissHUD];
            }];
            return;
        }
        
        
        if (error.code==-1001) {
            [SupportingClass showAlertViewWithTitle:@"error" message:@"网络连接逾时，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                [ProgressHUDHandler dismissHUD];
            }];
            return;
        }
        
        [SupportingClass showAlertViewWithTitle:@"error" message:@"网络错误，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            [ProgressHUDHandler dismissHUD];
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
