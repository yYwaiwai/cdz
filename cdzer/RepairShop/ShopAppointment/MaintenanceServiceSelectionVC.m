//
//  MaintenanceServiceSelectionVC.m
//  cdzer
//
//  Created by KEns0n on 6/15/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#import "MaintenanceServiceSelectionVC.h"
#import "InsetsLabel.h"

@interface MaintenanceServiceSelectionVC ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *serviceList;

@property (nonatomic, strong) UITableView *serviceTableView;

@end

@implementation MaintenanceServiceSelectionVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = getLocalizationString(@"select_maintenance_service");
    // Do any additional setup after loading the view.
    [self componentSetting];
    [self initializationUI];
    [self setReactiveRules];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getMaintenanceServiceList];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)setReactiveRules {
    @weakify(self);
    [RACObserve(self, serviceList) subscribeNext:^(NSArray *serviceList) {
        @strongify(self);
        if (self.serviceTableView) {
            if (!self.selectedServiceList&&!serviceList) {
                self.selectedServiceList = [NSMutableArray arrayWithCapacity:serviceList.count];
                
            }
            [serviceList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if (self.selectedServiceList.count!=serviceList.count) {
                    [self.selectedServiceList addObject:[NSMutableSet set]];
                }
            }];
            [self.serviceTableView reloadData];
            
            [self.selectedServiceList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if ([obj isKindOfClass:[NSMutableSet class]]) {
                    NSArray *array = [(NSMutableSet *)obj allObjects];
                    if (array.count!=0&&serviceList) {
                        for (id object in array) {
                            NSInteger index = [serviceList[idx] indexOfObject:object];
                            [self.serviceTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:idx] animated:NO scrollPosition:UITableViewScrollPositionNone];
                        }
                    }
                }

            }];
        }
    }];
    
    [RACObserve(self, selectedServiceList) subscribeNext:^(NSMutableArray *list) {
        @strongify(self);
        if (list.count!=0) {
            __block BOOL isEnable = NO;
            [self.selectedServiceList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSMutableSet *itemListSet = list[idx];
                NSArray *array = [itemListSet allObjects];
                if (array.count != 0) {
                    isEnable = YES;
                    *stop = YES;
                }
            }];
            self.navigationItem.rightBarButtonItem.enabled = isEnable;
        }else {
            
            self.navigationItem.rightBarButtonItem.enabled = NO;
        }
    }];

}

- (void)componentSetting {
    @autoreleasepool {
        [self setRightNavButtonWithTitleOrImage:@"finish" style:UIBarButtonItemStyleDone target:self action:@selector(submitServiceSelection) titleColor:nil isNeedToSet:YES];
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

- (void)submitServiceSelection {
    [[NSNotificationCenter defaultCenter] postNotificationName:CDZNotiKeyOfSelectedMaintenanceItemsUpdate object:_selectedServiceList];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)initializationUI {
    @autoreleasepool {
        self.serviceTableView = [[UITableView alloc] initWithFrame:self.contentView.bounds style:UITableViewStylePlain];
        _serviceTableView.editing = YES;
        _serviceTableView.bounces = NO;
        _serviceTableView.delegate = self;
        _serviceTableView.dataSource = self;
        _serviceTableView.allowsSelection = NO;
        _serviceTableView.allowsMultipleSelection = NO;
        _serviceTableView.allowsSelectionDuringEditing = YES;
        _serviceTableView.allowsMultipleSelectionDuringEditing = YES;
        [self.contentView addSubview:_serviceTableView];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma -mark UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return _serviceList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    return [_serviceList[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CDZKeyOfCellIdentKey];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CDZKeyOfCellIdentKey];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell setBackgroundColor:CDZColorOfWhite];
        cell.textLabel.text = @"";
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 15.0f, NO);
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    // Configure the cell...
    @autoreleasepool {
        NSArray *array = _serviceList[indexPath.section];
        cell.textLabel.text = [array[indexPath.row] objectForKey:@"main_name"];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    return 50.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 30.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    @autoreleasepool {
        static NSString *headerIdentifier = @"header";
        
        UITableViewHeaderFooterView *myHeader = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerIdentifier];
        if(!myHeader) {
            myHeader = [[UITableViewHeaderFooterView alloc]initWithReuseIdentifier:headerIdentifier];
            InsetsLabel *titleLabel = [[InsetsLabel alloc] initWithFrame:CGRectZero
                                                               andEdgeInsetsValue:UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 10.0f)];
            titleLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfBold, 17.5f, NO);
            titleLabel.textAlignment = NSTextAlignmentCenter;
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
        NSString *title = getLocalizationString(@"normal_check");
        if (section==1) {
            title = getLocalizationString(@"d_check");
        }
        titleLabel.text = title;
        return myHeader;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    @autoreleasepool {
        NSMutableArray *tmpSelectedArray = [self mutableArrayValueForKey:@"selectedServiceList"];
        NSMutableSet *set = tmpSelectedArray[indexPath.section];
        [set addObject:[_serviceList[indexPath.section] objectAtIndex:indexPath.row]];
        [tmpSelectedArray replaceObjectAtIndex:indexPath.section withObject:set];
    }
}
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    @autoreleasepool {
        NSMutableArray *tmpSelectedArray = [self mutableArrayValueForKey:@"selectedServiceList"];
        NSMutableSet *set = tmpSelectedArray[indexPath.section];
        [set removeObject:[_serviceList[indexPath.section] objectAtIndex:indexPath.row]];
        [tmpSelectedArray replaceObjectAtIndex:indexPath.section withObject:set];
    }
}


#pragma mark- API Access Code Section
- (void)getMaintenanceServiceList {
    [ProgressHUDHandler showHUDWithTitle:getLocalizationString(@"loading") onView:nil];
    @weakify(self);
    [[APIsConnection shareConnection] commonAPIsGetRepairShopServiceListWithShopID:self.shopID success:^(NSURLSessionDataTask *operation, id responseObject) {
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        [ProgressHUDHandler dismissHUD];
        if (errorCode!=0) {
            [SupportingClass showAlertViewWithTitle:@"error" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
            return;
        }
        @strongify(self);
        NSDictionary *result = responseObject[CDZKeyOfResultKey];
        self.serviceList = @[result[@"convention_maintain"], result[@"deepness_maintain"]];
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
