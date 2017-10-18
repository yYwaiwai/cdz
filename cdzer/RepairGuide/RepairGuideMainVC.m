//
//  RepairGuideMainVC.m
//  cdzer
//
//  Created by KEns0n on 16/3/30.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "RepairGuideMainVC.h"
#import "RGMInfRollView.h"
#import "RepairSubGuideVC.h"
#import "RepairGudieProcedureVC.h"
@interface RepairGuideMainVC () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UIView *infRollView;
@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, weak) IBOutlet UIImageView *type1ImageView;
@property (nonatomic, weak) IBOutlet UIImageView *type2ImageView;
@property (nonatomic, weak) IBOutlet UIImageView *type3ImageView;
@property (nonatomic, weak) IBOutlet UIImageView *type4ImageView;
@property (nonatomic, weak) IBOutlet UIImageView *type5ImageView;
@property (nonatomic, weak) IBOutlet UIImageView *type6ImageView;

@property (nonatomic, strong) RGMInfRollView *rollView;


@property (nonatomic, strong) NSMutableArray *headerList;
@property (nonatomic, strong) NSMutableArray *bottomDataList;

@end

@implementation RepairGuideMainVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}


- (void)viewDidLoad {
    self.title = @"维修指南";
    [super viewDidLoad];
    [self componentSetting];
    [self initializationUI];
    [self setReactiveRules];
    [self getGuideData];    
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_headerList.count>0) {
        [_rollView viewWillAppearWithData:_headerList];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_rollView viewWillDisappear];
}

- (void)setReactiveRules {
    @autoreleasepool {
        
    }
    
}

- (void)componentSetting {
    @autoreleasepool {
        self.headerList = [NSMutableArray array];
        self.bottomDataList = [NSMutableArray array];
    }
}

- (void)initializationUI {
    @autoreleasepool {
        self.type1ImageView.image = [ImageHandler getImageFromCacheWithByFixdeRatioFileRootPath:nil fileName:@"guide_type1" type:FMImageTypeOfPNG needToUpdate:YES];
        self.type2ImageView.image = [ImageHandler getImageFromCacheWithByFixdeRatioFileRootPath:nil fileName:@"guide_type2" type:FMImageTypeOfPNG needToUpdate:YES];
        self.type3ImageView.image = [ImageHandler getImageFromCacheWithByFixdeRatioFileRootPath:nil fileName:@"guide_type3" type:FMImageTypeOfPNG needToUpdate:YES];
        self.type4ImageView.image = [ImageHandler getImageFromCacheWithByFixdeRatioFileRootPath:nil fileName:@"guide_type4" type:FMImageTypeOfPNG needToUpdate:YES];
        self.type5ImageView.image = [ImageHandler getImageFromCacheWithByFixdeRatioFileRootPath:nil fileName:@"guide_type5" type:FMImageTypeOfPNG needToUpdate:YES];
        self.type6ImageView.image = [ImageHandler getImageFromCacheWithByFixdeRatioFileRootPath:nil fileName:@"guide_type6" type:FMImageTypeOfPNG needToUpdate:YES];
        
        self.rollView = [[RGMInfRollView alloc] initWithFrame:_infRollView.bounds];
        _rollView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        [_infRollView addSubview:_rollView];
        @weakify(self);
        [_rollView setSelectionResponseBlock:^(NSDictionary *dataDetail) {
            @strongify(self);
            [self handleGuideData:dataDetail];
        }];
    }
}

- (IBAction)subTypeGuideViewAction:(UIControl *)sender {
    UILabel *label = (UILabel *)[sender viewWithTag:101];
    [self getRepairSubGuideList:label.text andSubTypeIdx:sender.tag];
}

- (void)handleGuideData:(NSDictionary *)data {
    if (!data||data.count==0) {
        return;
    }
    NSString *procedureDetailID = data[@"id"];
    NSString *name = data[@"name"];
    [self getRepairGuideProcedureDetail:procedureDetailID withName:name];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.bottomDataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CDZKeyOfCellIdentKey];
    
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CDZKeyOfCellIdentKey];
        [cell setBackgroundColor:CDZColorOfClearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = @"";
        cell.textLabel.textColor = CDZColorOfDefaultColor;
        cell.detailTextLabel.text = @"";
        cell.textLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 16.0f, NO);
        cell.detailTextLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 14.0f, NO);
        cell.textLabel.numberOfLines = 0;
        cell.detailTextLabel.numberOfLines = 0;
        cell.detailTextLabel.textColor = CDZColorOfDefaultColor;
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    NSDictionary *detail = _bottomDataList[indexPath.row];
    cell.textLabel.text = detail[@"name"];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NSDictionary *detail = _bottomDataList[indexPath.row];
    [self handleGuideData:detail];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getGuideData {
    [ProgressHUDHandler showHUD];
    @weakify(self);
    [APIsConnection.shareConnection repairGuideAPIsGetMainPageGuideDataWithSuccessBlock:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        [ProgressHUDHandler dismissHUD];
        if (errorCode!=0&&![message isEqualToString:@"返回成功"]) {
            [ProgressHUDHandler dismissHUD];
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
            return;
        }
        NSArray <NSDictionary *> *result = responseObject[CDZKeyOfResultKey];
        [result enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull detail, NSUInteger idx, BOOL * _Nonnull stop) {
            if (detail[@"video"]&&![detail[@"video"] isEqualToString:@""]&&[detail[@"video"] isContainsString:@"http"]) {
                [self.headerList addObject:detail];
            }else {
                [self.bottomDataList addObject:detail];
            }
        }];
        [self.rollView viewWillAppearWithData:self.headerList];
        [self.tableView reloadData];
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        NSLog(@"%@",error);
        [ProgressHUDHandler showError];
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
        return;
    }];
}

- (void)getRepairSubGuideList:(NSString *)mainTypeName andSubTypeIdx:(NSUInteger)subTypeIdx {
    if (!mainTypeName||[mainTypeName isEqualToString:@""]) {
        return;
    }
    if ([mainTypeName isEqualToString:@"动力传动系统"]) {
        mainTypeName = @"变速箱和动力传动系统";
    }
    if ([mainTypeName isEqualToString:@"预防性维护"]) {
        mainTypeName = @"预防性的维护";
    }
    [ProgressHUDHandler showHUD];
    @weakify(self);
    [APIsConnection.shareConnection repairGuideAPIsGetRepairGuideSubTypeListWithMainTypeName:mainTypeName success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        [ProgressHUDHandler dismissHUD];
        if (errorCode!=0&&![message isEqualToString:@"返回成功"]) {
            [ProgressHUDHandler dismissHUD];
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
            return;
        }
        NSArray *result = responseObject[CDZKeyOfResultKey];
        if (result.count) {
            RepairSubGuideVC *vc = [RepairSubGuideVC new];
            vc.currentIdex = subTypeIdx;
            vc.title = mainTypeName;
            vc.subTypeList = result;
            [self setDefaultNavBackButtonWithoutTitle];
            [self.navigationController pushViewController:vc animated:YES];
        }
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        NSLog(@"%@",error);
        [ProgressHUDHandler showError];
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
        return;
    }];
}

- (void)getRepairGuideProcedureDetail:(NSString *)procedureDetailID withName:(NSString *)name {
    if (!procedureDetailID||[procedureDetailID isEqualToString:@""]) {
        return;
    }
    if (!name) name = @"";
    
    [ProgressHUDHandler showHUD];
    @weakify(self);
    [APIsConnection.shareConnection repairGuideAPIsGetRepairGuideProcedureDetailWithProcedureDetailID:procedureDetailID success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        [ProgressHUDHandler dismissHUD];
        if (errorCode!=0&&![message isEqualToString:@"返回成功"]) {
            [ProgressHUDHandler dismissHUD];
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
            return;
        }
        NSDictionary *procedureDetail = responseObject[CDZKeyOfResultKey];
        if (procedureDetail.count>0&&procedureDetail) {
            RepairGudieProcedureVC *vc = [RepairGudieProcedureVC new];
            vc.procedureDetail = procedureDetail;
            vc.title = name;
            [self setDefaultNavBackButtonWithoutTitle];
            [self.navigationController pushViewController:vc animated:YES];
        }
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        NSLog(@"%@",error);
        [ProgressHUDHandler showError];
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
        return;
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
