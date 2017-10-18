//
//  EngineerListVC.m
//  cdzer
//
//  Created by KEns0n on 3/12/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#import "EngineerListVC.h"
#import "EngineerListCell.h"
#import "EngineerDetailVC.h"
@interface EngineerListVC ()

@property (nonatomic, strong) NSMutableArray *engineerDataList;

@end

@implementation EngineerListVC


- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:getLocalizationString(@"engineer_list")];
    self.engineerDataList = [NSMutableArray array];
    self.tableView.allowsSelection = YES;
    self.tableView.allowsSelectionDuringEditing = YES;
    self.tableView.allowsMultipleSelection = NO;
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    [self initializationUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_engineerDataList.count==0) {
        [self getMaintenanceShopsTechnicianList];
    }
}

- (void)initializationUI {
    
    @autoreleasepool {
        if (_isForSelection) {
//            [self setLeftNavButtonWithTitleOrImage:@"cancel" style:UIBarButtonItemStylePlain target:self
//                                            action:@selector(dismissSelf) titleColor:CDZColorOfDefaultColor isNeedToSet:YES];
            
            [self setRightNavButtonWithTitleOrImage:@"ok" style:UIBarButtonItemStyleDone target:self
                                             action:@selector(confirmSelection) titleColor:CDZColorOfWhite isNeedToSet:YES];
            self.navigationItem.rightBarButtonItem.enabled = NO;
        }
    }
}

//- (void)dismissSelf {
//    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
//}

- (void)confirmSelection {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ConfirmEngineerData" object:_engineerDataList[self.tableView.indexPathForSelectedRow.row]];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma -mark UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // NSInteger the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return _engineerDataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    EngineerListCell *cell = [tableView dequeueReusableCellWithIdentifier:CDZKeyOfCellIdentKey];
    if (!cell) {
        cell = [[EngineerListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CDZKeyOfCellIdentKey];
        [cell initializationUI];
        [cell setSelectionStyle:_isForSelection?UITableViewCellSelectionStyleBlue:UITableViewCellSelectionStyleNone];
        [cell setBackgroundColor:CDZColorOfWhite];
    }
    // Configure the cell...
    [cell updateUIDataWithData:_engineerDataList[indexPath.row]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return vAdjustByScreenRatio(110.0f);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 0.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return 0.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    @autoreleasepool {
        if (!_isForSelection) {
            EngineerDetailVC *edvc = [[EngineerDetailVC alloc] init];
            edvc.technicianID = [_engineerDataList[indexPath.row] objectForKey:@"id"];
            [self setDefaultNavBackButtonWithoutTitle];
            [self.navigationController pushViewController:edvc animated:YES];
        }else {
            
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.navigationItem.rightBarButtonItem.enabled = NO;
}
#pragma mark- API Access Code Section

- (void)getMaintenanceShopsTechnicianList {
    [ProgressHUDHandler showHUD];
    
//    [[APIsConnection shareConnection] maintenanceShopsAPIsGetMaintenanceShopsTechnicianListWithShopID:_shopID success:^(NSURLSessionDataTask *operation, id responseObject) {
//        [self requestResultHandle:operation responseObject:responseObject withError:nil];
//    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
//        [self requestResultHandle:operation responseObject:nil withError:error];
//    }];
}


- (void)requestResultHandle:(NSURLSessionDataTask *)operation responseObject:(id)responseObject withError:(NSError *)error {
    [ProgressHUDHandler dismissHUD];
    
    if (error&&!responseObject) {
        NSLog(@"%@",error);
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
    }else if (!error&&responseObject) {
        
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        
        switch (errorCode) {
            case 0:{
                [self.engineerDataList removeAllObjects];
                [self.engineerDataList addObjectsFromArray:responseObject[CDZKeyOfResultKey]];
                [self.tableView reloadData];
                if (_selectedEngineerData&&_isForSelection) {
                    NSInteger idx = [_engineerDataList indexOfObject:_selectedEngineerData];
                    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
                }
            }
                break;
            case 1:
            case 2:
                [SupportingClass showAlertViewWithTitle:@"error" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                    
                }];
                break;
                
            default:
                break;
        }
        
    }
    
}

@end
