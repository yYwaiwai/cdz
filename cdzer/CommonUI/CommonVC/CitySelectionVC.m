//
//  CitySelectionVC.m
//  cdzer
//
//  Created by KEns0n on 3/6/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#define kResultKeyID @"region_id"
#define kResultKeyName @"region_name"
#define kResultKeyNamePY @"city_name_pinyin"
#import "CitySelectionVC.h"
#import "UserLocateView.h"
#import "UserLocationHandler.h"
#import "KeyCityDTO.h"

@interface CitySelectionVC () <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UISearchBar *searchBar;

@property (nonatomic, strong) UITableView *resultTableView, *searchedResultTableView;

@property (nonatomic, strong) NSArray *filterCityArray;

@property (nonatomic, strong) NSArray *cityArray;

@property (nonatomic, strong) NSMutableArray *keyArray;

@property (nonatomic, strong) UserLocateView *locateView;

@end

@implementation CitySelectionVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (void)viewDidLoad {
    [self setRightNavButtonWithTitleOrImage:@"ok" style:UIBarButtonItemStyleDone target:self action:@selector(confirmSelection) titleColor:nil isNeedToSet:YES];
    [self.contentView setBackgroundColor:[UIColor colorWithRed:0.953f green:0.953f blue:0.953f alpha:1.00f]];
    self.cityArray = @[];
    self.filterCityArray = @[];
    [self getCityList];
    [super viewDidLoad];
    [self initializationUI];
    [self setReactiveRules];
    // Do any additional setup after loading the view.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_locateView stopUserLocation];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchBarTextChange) name:UITextFieldTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchBarTextChange) name:UITextFieldTextDidBeginEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAppear:) name:UIKeyboardWillShowNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)keyboardWillAppear:(NSNotification *)notiObject {
    CGRect keyboardRect = [notiObject.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat tbTotalHeight = CGRectGetHeight(self.contentView.frame)-CGRectGetHeight(keyboardRect)-CGRectGetHeight(self.searchBar.frame);
    CGRect rect = _searchedResultTableView.frame;
    rect.size.height = tbTotalHeight;
    _searchedResultTableView.frame = rect;
}

- (void)searchBarTextChange {
    NSString *text = _searchBar.text;
    if ([text isEqualToString:@""]) {
        self.filterCityArray = @[];
    }else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"cityName CONTAINS[cd] %@ || cityNamePY CONTAINS[cd] %@ ",[text lowercaseString],[text lowercaseString]];
//        NSLog(@"%@",[_cityArray filteredArrayUsingPredicate:predicate]);
        self.filterCityArray = [_cityArray filteredArrayUsingPredicate:predicate];
    }

    [_searchedResultTableView reloadData];
}

- (void)scrollBackToTop {
    [_resultTableView setContentOffset:CGPointZero animated:YES];
}

- (NSArray *)getFilterArray:(NSInteger)section {
    NSString *key = [_keyArray objectAtIndex:section];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"SELF.sortedKey LIKE[cd] %@",key];
    NSArray *arrayCount = [_cityArray filteredArrayUsingPredicate:predicate];
    return  arrayCount;
}

- (void)setReactiveRules {
    @weakify(self);
    [RACObserve(self, selectedCity) subscribeNext:^(KeyCityDTO *selectedCity) {
        @strongify(self);
        BOOL isSelected = (selectedCity!=nil);
        self.navigationItem.rightBarButtonItem.enabled = isSelected;
    }];
}

- (void)initializationUI {
    @autoreleasepool {
        
        CGRect searchBarRect = CGRectZero;
        searchBarRect.size = CGSizeMake(CGRectGetWidth(self.contentView.frame), 40.0f);
        [self setSearchBar:[[UISearchBar alloc] initWithFrame:searchBarRect]];
        [_searchBar setBarTintColor:[UIColor colorWithRed:0.953f green:0.953f blue:0.953f alpha:1.00f]];
        [_searchBar setBorderWithColor:[UIColor colorWithRed:0.953f green:0.953f blue:0.953f alpha:1.00f] borderWidth:(1.0f)];
        [_searchBar setPlaceholder:getLocalizationString(@"input_city")];
        [_searchBar setContentMode:UIViewContentModeLeft];
        [_searchBar setDelegate:self];
        [self.contentView addSubview:_searchBar];
        
        
        CGRect resultTVRect = CGRectZero;
        resultTVRect.origin.y = CGRectGetMaxY(searchBarRect);
        resultTVRect.size = CGSizeMake(CGRectGetWidth(self.contentView.frame), CGRectGetHeight(self.contentView.frame)-CGRectGetHeight(searchBarRect));
        [self setResultTableView:[[UITableView alloc] initWithFrame:resultTVRect style:UITableViewStylePlain]];
        [_resultTableView setDelegate:self];
        [_resultTableView setDataSource:self];
        [_resultTableView setBounces:YES];
        [_resultTableView setScrollsToTop:YES];
        [self.contentView addSubview:_resultTableView];
        
        CGRect searchResultTVRect = CGRectZero;
        searchResultTVRect.origin.y = CGRectGetMaxY(searchBarRect);
        searchResultTVRect.size = CGSizeMake(CGRectGetWidth(self.contentView.frame), CGRectGetHeight(self.contentView.frame)-CGRectGetHeight(searchBarRect));
        [self setSearchedResultTableView:[[UITableView alloc] initWithFrame:searchResultTVRect style:UITableViewStylePlain]];
        [_searchedResultTableView setDelegate:self];
        [_searchedResultTableView setDataSource:self];
        [_searchedResultTableView setBounces:YES];
        [_searchedResultTableView setScrollsToTop:YES];
        [_searchedResultTableView setHidden:YES];
        [self.contentView addSubview:_searchedResultTableView];
        
    }
}

- (void)confirmSelection {
    if (!_selectionWithoutSave) {
        [UserLocationHandler updateKeyCity:_selectedCity];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:CDZNotiKeyOfUpdateLocation object:_selectedCity];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma -mark UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    if ([tableView isEqual:_searchedResultTableView]) {
        return 1;
    }
    return [_keyArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if ([tableView isEqual:_searchedResultTableView]) {
        return _filterCityArray.count;
    }
    if (section==0&&_cityArray.count!=0&&!_hiddenLocationView) return 1;
    return [[self getFilterArray:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section==0&&[tableView isEqual:_resultTableView]&&!_hiddenLocationView) {
        static NSString *ident = @"locateCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ident];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CDZKeyOfCellIdentKey];
            [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
            [cell setBackgroundColor:CDZColorOfWhite];
            self.locateView = [[UserLocateView alloc] initWithFrame:cell.bounds];
            _locateView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
            _locateView.translatesAutoresizingMaskIntoConstraints = YES;
            [cell.contentView addSubview:_locateView];
            [_locateView startUserLocation];
        }
        return cell;
    }
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CDZKeyOfCellIdentKey];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CDZKeyOfCellIdentKey];
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
        [cell setBackgroundColor:CDZColorOfWhite];
        cell.textLabel.text = @"";

    }
    // Configure the cell...
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.textLabel.text = @"";
    if ([tableView isEqual:_searchedResultTableView]) {
        KeyCityDTO *dto = _filterCityArray[indexPath.row];
        [cell.textLabel setText:dto.cityName];
    }
    if([cell.reuseIdentifier isEqualToString:CDZKeyOfCellIdentKey]){
        NSArray *cityList = [self getFilterArray:indexPath.section];
        KeyCityDTO *dto = [cityList objectAtIndex:indexPath.row];
        cell.textLabel.text = dto.cityName;
    }
    if ([tableView.indexPathForSelectedRow isEqual:indexPath]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([tableView isEqual:_searchedResultTableView]) {
        return 0.0f;
    }
    return 20.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return 0.0f;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ([tableView isEqual:_searchedResultTableView]) {
        return nil;
    }
    return [_keyArray objectAtIndex:section];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if ([tableView isEqual:_searchedResultTableView]) {
        return nil;
    }
    return _keyArray;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_resultTableView==tableView) {
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        KeyCityDTO *dto = nil;
        self.selectedCity = nil;
        if ([cell.reuseIdentifier isEqualToString:@"locateCell"]) {
            if (!_locateView.isLocateSuccess) {
                cell.accessoryType = UITableViewCellAccessoryNone;
                [tableView deselectRowAtIndexPath:indexPath animated:NO];
                return;
            }else {
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.cityName LIKE[cd] %@", _locateView.currentCity];
                NSArray *result = [_cityArray filteredArrayUsingPredicate:predicate];
                if ([result.lastObject isKindOfClass:KeyCityDTO.class]) {
                    self.selectedCity = result.lastObject;
                    self.selectedCity.isSelectFormPosition = YES;
                }
            }
        }else {
            NSArray *cityList = [self getFilterArray:indexPath.section];
            dto = [cityList objectAtIndex:indexPath.row];
            cell.textLabel.text = dto.cityName;
            self.selectedCity = dto;
        }
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_resultTableView==tableView) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryNone;
        self.selectedCity = nil;
    }
}

#pragma -mark UISearchBarDelegate
- (void)resignSearchBarFirstResponder {
    [_searchBar resignFirstResponder];
    _searchedResultTableView.frame = _resultTableView.frame;
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    _searchedResultTableView.hidden = NO;
    [searchBar setShowsCancelButton:YES animated:YES];
    for (UIView *view in [searchBar subviews]) {
        for (UIView *subview in [view subviews]) {
            if ([subview isKindOfClass:[UIButton class]] && [[(UIButton *)subview currentTitle] isEqualToString:@"Cancel"] ) {
                [(UIButton*)subview setTitle:getLocalizationString(@"cancel") forState:UIControlStateNormal];
            }
        }
    }
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    _searchedResultTableView.hidden = YES;
    _searchedResultTableView.frame = _resultTableView.frame;
}

#pragma mark- APIs Access Request
- (void)getCityList {
    [ProgressHUDHandler showHUD];
//    [UserLocationHandler updateCityList:^(NSArray *resultList, NSError *error) {
//        [ProgressHUDHandler dismissHUD];
//        if (resultList) {
//            [self performSelectorInBackground:@selector(delayLoading:) withObject:resultList];
//        }
//    }];
    
//    [[APIsConnection shareConnection] commonAPIsGetCityListWithProvinceID:nil isKeyCity:YES success:^(NSURLSessionDataTask *operation, id responseObject) {
//        [self requestResultHandle:operation responseObject:responseObject withError:nil];
//    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
//        [self requestResultHandle:operation responseObject:nil withError:error];
//    }];
//
    [UserLocationHandler getCityList:^(NSArray *resultList, NSError *error) {
        if (resultList) {
            [self delayLoading:resultList];
        }else {
            [ProgressHUDHandler dismissHUD];
        }
    }];
}

- (void)delayLoading:(NSArray *)responseObject {
    self.cityArray = responseObject;
    NSSet *keySet = [NSSet setWithArray:[_cityArray valueForKeyPath:@"sortedKey"]];
    self.keyArray = keySet.allObjects.mutableCopy;
    if (!_hiddenLocationView) {
        [_keyArray insertObject:@"#" atIndex:0];
    }
    [_resultTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    if (_selectedCity) {
        [self setupSelectedIndexPath];
    }
    [ProgressHUDHandler dismissHUD];
}

- (void)setupSelectedIndexPath {
    @weakify(self);
    [_keyArray enumerateObjectsUsingBlock:^(id sectionObj, NSUInteger section, BOOL *sectionStop) {
        if ([sectionObj isEqualToString:self.selectedCity.sortedKey]) {
            NSArray *cityList = [self getFilterArray:section];
            [cityList enumerateObjectsUsingBlock:^(id rowObj, NSUInteger row, BOOL *rowStop) {
                if ([[(KeyCityDTO*)rowObj cityName] isEqualToString:self.selectedCity.cityName]) {
                    @strongify(self);
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
                    [self.resultTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionMiddle];
                    *rowStop = YES;
                }
            }];
            *sectionStop = YES;
        }
    }];
}

#pragma mark- Data Handle Request
- (void)handleResponseData:(id)responseObject {
    @autoreleasepool {
        if (!responseObject||[responseObject count]==0) {
            NSLog(@"data Error");
            return;
        }
        
        [self performSelectorInBackground:@selector(delayLoading:) withObject:responseObject];
//        [self performSelectorInBackground:@selector(insertPinYinData:) withObject:responseObject];
        
    }
}

- (void)requestResultHandle:(NSURLSessionDataTask *)operation responseObject:(id)responseObject withError:(NSError *)error {
    
    if (error&&!responseObject) {
        NSLog(@"%@",error);
        [ProgressHUDHandler dismissHUD];
    }else if (!error&&responseObject) {
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        
        if (errorCode!=0) {
            [SupportingClass showAlertViewWithTitle:@"error" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                    [ProgressHUDHandler dismissHUD];
            }];
            return;
        }
        [self handleResponseData:responseObject[CDZKeyOfResultKey]];
        
    }
    
}

- (void)insertPinYinData:(id)sender {
    @autoreleasepool {
        NSArray *newData = nil;
        if ([sender isKindOfClass:[NSArray class]]) {
            NSMutableArray *tmpNewData = [NSMutableArray array];
            
            [sender enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSString *pinYin = [SupportingClass chineseStringConvertToPinYinStringWithString:[obj objectForKey:kResultKeyName]];
                NSMutableDictionary *cityDetail = [NSMutableDictionary dictionaryWithDictionary:obj];
                [cityDetail setObject:pinYin forKey:@"city_name_pinyin"];
                NSString *keyString = [pinYin substringToIndex:1];
                [cityDetail setObject:[keyString uppercaseString] forKey:@"sorted_key"];
                [tmpNewData addObject:cityDetail];
            }];
            
            NSSortDescriptor *sortDescriptor;
            sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"city_name_pinyin"
                                                         ascending:YES];
            
            NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
            newData = [tmpNewData sortedArrayUsingDescriptors:sortDescriptors];
        }
        
        for (NSString *key in [NSArray arrayWithArray:_keyArray]) {
            NSPredicate * predicate = [NSPredicate predicateWithFormat:@"sorted_key LIKE[cd] %@",key];
            NSArray *arrayCount = [newData filteredArrayUsingPredicate:predicate];
            if ([arrayCount count]==0) {
                [_keyArray removeObject:key];
            }
        }
        
        self.cityArray = newData;
        [_resultTableView reloadData];
    }
    
    [ProgressHUDHandler dismissHUD];
}
@end
