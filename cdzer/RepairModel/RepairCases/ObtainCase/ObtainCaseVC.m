//
//  ObtainCaseVC.m
//  cdzer
//
//  Created by 车队长 on 16/11/16.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#define kObjIDKey @"id"
#define kListOne @"list_one"
#define kListTwo @"list_two"
#define kObjParentIDKey @"parent_id"
#define kObjDetailContentKey @"detail_content"

#import "ObtainCaseVC.h"
#import "CaseResultsVC.h"
#import "AddCaseVC.h"
#import "UserAutosSelectonVC.h"
#import "SelfDiagnosisModuleCell.h"
#import "UISearchBarWithReturnKey.h"
#import "OCVCOptionView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>



@interface ObtainCaseVC ()<UISearchBarWithReturnKeyDelegate,UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIControl *headView;

@property (weak, nonatomic) IBOutlet UIImageView *titleImageView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UIImageView *arrowImageView;

@property (weak, nonatomic) IBOutlet UILabel *addCarMessageLabel;

@property (weak, nonatomic) IBOutlet UIButton *engineButton;//发动机

@property (weak, nonatomic) IBOutlet UIButton *electricApplianceButton;//电子电器

@property (weak, nonatomic) IBOutlet UIButton *bodyAndAccessoriesButton;//车身及附件

@property (weak, nonatomic) IBOutlet UIButton *maintenanceAccessoriesButton;//保养配件

@property (weak, nonatomic) IBOutlet UIButton *chassisButton;//底盘

@property (weak, nonatomic) IBOutlet UIView *tishiView;

@property (weak, nonatomic) IBOutlet OCVCOptionView *carView;

@property (weak, nonatomic) IBOutlet UITableView *tableView;



@property (nonatomic, strong) NSArray *listOneArray;

@property (nonatomic, strong) NSString *idStr;

@property (nonatomic, strong) NSString *mainTitleKeyword;

@property (nonatomic, strong) NSArray *currentDataList;

@property (nonatomic, strong) UISearchBarWithReturnKey *searchBar;

@property (nonatomic, strong) UserSelectedAutosInfoDTO *autosSelectedData;

@property (nonatomic, assign) BOOL isSecondStep;

@end

@implementation ObtainCaseVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!self.isSecondStep) {
        [self getCaseSecond];
    }else{
        
        [self getCaseThird];
    }
    
    UserSelectedAutosInfoDTO *autosData = [DBHandler.shareInstance getSelectedAutoData];
    if (!self.autosSelectedData||
        ![self.autosSelectedData.brandID isEqualToString:@""]||
        ![self.autosSelectedData.dealershipID isEqualToString:@""]||
        ![self.autosSelectedData.seriesID isEqualToString:@""]||
        ![self.autosSelectedData.modelID isEqualToString:@""]) {
        self.autosSelectedData = autosData;
    }
    if (!self.isSecondStep) {
        if (self.autosSelectedData.brandID&&self.autosSelectedData.dealershipID&&
            self.autosSelectedData.seriesID&&self.autosSelectedData.modelID&&
            ![self.autosSelectedData.brandID isEqualToString:@""]&&
            ![self.autosSelectedData.dealershipID isEqualToString:@""]&&
            ![self.autosSelectedData.seriesID isEqualToString:@""]&&
            ![self.autosSelectedData.modelID isEqualToString:@""]) {
            BOOL autosInfoWasChange = (![autosData.brandID isEqualToString:self.autosSelectedData.brandID]||
                                       ![autosData.dealershipID isEqualToString:self.autosSelectedData.dealershipID]||
                                       ![autosData.seriesID isEqualToString:self.autosSelectedData.seriesID]||
                                       ![autosData.modelID isEqualToString:self.autosSelectedData.modelID]);
            if (self.currentDataList.count==0||autosInfoWasChange) {
                if (autosInfoWasChange) {
                    self.autosSelectedData = autosData;
                }
            }
        }
    }
    [self updateAutosInfoData];
    NSLog(@"%@", NSStringFromCGRect(self.view.frame));
    NSLog(@"carView   %@", NSStringFromCGRect(self.carView.frame));
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.carView.showTheLine = YES;
    [self.carView setNeedsDisplay];
    [self.carView setNeedsLayout];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    self.loginAfterShouldPopToRoot = NO;
    [self componentSetting];
    [self initializationUI];
 }

- (void)initializationUI {
    @autoreleasepool {

        [self setRightNavButtonWithTitleOrImage:@"添加案例" style:UIBarButtonItemStylePlain target:self action:@selector(addCaseClick) titleColor:[UIColor blackColor] isNeedToSet:YES];
        
        
        UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 40)];
        [toolBar setBarStyle:UIBarStyleDefault];
        UIBarButtonItem * spaceButton = [[UIBarButtonItem  alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                       target:self
                                                                                       action:nil];
        UIBarButtonItem * doneButton = [[UIBarButtonItem alloc] initWithTitle:getLocalizationString(@"cancel")
                                                                        style:UIBarButtonItemStylePlain
                                                                       target:self
                                                                       action:@selector(hideSearchBarKeyborad)];
        NSArray * buttonsArray = [NSArray arrayWithObjects:spaceButton,doneButton,nil];
        [toolBar setItems:buttonsArray];
        
        
        self.searchBar = [[UISearchBarWithReturnKey alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame)*0.8, 30.0f)];
        self.searchBar.backgroundColor = CDZColorOfClearColor;
        self.searchBar.placeholder = @"请输入故障现象";
        self.searchBar.delegate = self;
        self.searchBar.inputAccessoryView = toolBar;
        self.searchBar.enablesReturnKeyAutomatically = NO;
        self.navigationItem.titleView = self.searchBar;
        
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 50.0f;
        self.tableView.tableFooterView = [UIView new];
        self.tableView.backgroundColor = self.view.backgroundColor;
        UINib * nib = [UINib nibWithNibName:@"SelfDiagnosisModuleCell" bundle:nil];
        [self.tableView registerNib:nib forCellReuseIdentifier:CDZKeyOfCellIdentKey];
        
        
        if (!self.isSecondStep) {
            self.tableView.hidden = YES;
        }else {
            
            self.tishiView.hidden = YES;
            self.carView.hidden = YES;
            self.tableView.hidden = NO;
        }
        
    }
}

- (void)componentSetting {
    if (!self.currentDataList||!self.listOneArray) {
        self.currentDataList = @[];
        self.listOneArray = @[];
    }

    [self.titleImageView.layer setCornerRadius:22.5];
    [self.titleImageView.layer setMasksToBounds:YES];
    [self.titleImageView setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:3.0f withColor:[UIColor colorWithHexString:@"82d5f7"] withBroderOffset:nil];
}

- (void)updateAutosInfoData {
    if (self.autosSelectedData.brandID&&self.autosSelectedData.dealershipID&&
        self.autosSelectedData.seriesID&&self.autosSelectedData.modelID&&
        ![self.autosSelectedData.brandID isEqualToString:@""]&&
        ![self.autosSelectedData.dealershipID isEqualToString:@""]&&
        ![self.autosSelectedData.seriesID isEqualToString:@""]&&
        ![self.autosSelectedData.modelID isEqualToString:@""]) {
        
        [self.titleImageView sd_setImageWithURL:[NSURL URLWithString:self.autosSelectedData.brandImgURL] placeholderImage:[ImageHandler getDefaultWhiteLogo]];
        NSMutableString *string = [NSMutableString string];
        [string appendFormat:@"%@ %@",self.autosSelectedData.seriesName, self.autosSelectedData.modelName];
        self.titleLabel.text = string;
        
        self.titleImageView.hidden = NO;
        self.titleLabel.hidden = NO;
        self.addCarMessageLabel.hidden = YES;
    }else {
        self.titleImageView.hidden = YES;
        self.titleLabel.hidden = YES;
        self.addCarMessageLabel.hidden = NO;
    }

    if (!self.isSecondStep) {
        [self.headView addTarget:self action:@selector(headViewControlClick) forControlEvents:UIControlEventTouchUpInside];
    }
    self.arrowImageView.hidden = self.isSecondStep;
}

- (void)addCaseClick {
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    [self.searchBar resignFirstResponder];
    AddCaseVC*vc = [AddCaseVC new];
    [self.navigationController pushViewController:vc animated:YES];
    [self setDefaultNavBackButtonWithoutTitle];
    
}

- (void)headViewControlClick {
    @autoreleasepool {
        UserAutosSelectonVC *vc = [UserAutosSelectonVC new];
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)buttonClick:(UIButton*)sender {
    for (int i = 0; i < self.listOneArray.count; ++i) {
        NSDictionary *detail = self.listOneArray[i];
        if (i==sender.tag) {
            self.idStr = detail[@"id"];
            self.mainTitleKeyword = detail[@"dictionary"];
        }
        
    }

    [self getCaseThird];
    
    
}

- (void)hideSearchBarKeyborad {
    [self.searchBar resignFirstResponder];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SelfDiagnosisModuleCell *cell = [tableView dequeueReusableCellWithIdentifier:CDZKeyOfCellIdentKey forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    cell.labelOne.text = @"";
    cell.labelTwo.text = @"";
    NSDictionary *dic = self.currentDataList[indexPath.row];
    if (self.isSecondStep) {
        cell.labelOne.text = dic[@"dictionary"];
    }
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    @autoreleasepool {
        if (self.isSecondStep) {
            CaseResultsVC * vc = [CaseResultsVC new];
            vc.mainTitleKeyword = self.mainTitleKeyword;
            vc.subTitleKeyword = [self.currentDataList[indexPath.row] objectForKey:@"dictionary"];
            [self.navigationController pushViewController:vc animated:YES];
            [self setDefaultNavBackButtonWithoutTitle];

        }
    }
    
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (!self.isSecondStep) {
        if (self.currentDataList.count==0) {
            return 0;
        }
        return self.currentDataList.count;
    }
    return self.currentDataList.count;
}

- (void)pushNextStepViewWithData:(NSArray *)responseObject withIdent:(NSInteger)ident {
    @autoreleasepool {
        if (!responseObject||![responseObject isKindOfClass:NSArray.class]||responseObject.count==0) {
            return;
        }
        
        ObtainCaseVC *vc = ObtainCaseVC.new;
        vc.isSecondStep = YES;
        vc.idStr = self.idStr;
        vc.mainTitleKeyword = self.mainTitleKeyword;
        [self.navigationController pushViewController:vc animated:YES];
        [self setDefaultNavBackButtonWithoutTitle];
        
    }
}

- (void)searchBarReturnKey:(UISearchBar *)searchBar {
    CaseResultsVC * vc = [CaseResultsVC new];
    vc.mainTitleKeyword = @"";
    vc.subTitleKeyword = searchBar.text;
    [self.navigationController pushViewController:vc animated:YES];
    [self setDefaultNavBackButtonWithoutTitle];
}

#pragma mark- APIs Access Request

- (void)getCaseSecond {
    @weakify(self);
    [ProgressHUDHandler showHUD];
    [[APIsConnection shareConnection] casesHistoryAPIsGetcaseSecondsuccess:^(NSURLSessionDataTask *operation, id responseObject) {
        
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@--%@",message,operation.currentRequest.URL.absoluteString);
        [ProgressHUDHandler dismissHUD];
        if (errorCode!= 0) {
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            }];
            return ;
        }
        @strongify(self);
        
        NSDictionary *obj = responseObject[CDZKeyOfResultKey];
        self.listOneArray = obj[@"list_one"];
        
        
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

- (void)getCaseThird {
    UserSelectedAutosInfoDTO *autosData = [DBHandler.shareInstance getSelectedAutoData];
    if (!self.autosSelectedData||
        autosData.brandID!= self.autosSelectedData.brandID||
        autosData.dealershipID!= self.autosSelectedData.dealershipID||
        autosData.seriesID!= self.autosSelectedData.seriesID||
        autosData.modelID!= self.autosSelectedData.modelID) {
        self.autosSelectedData = autosData;
    }
    if (autosData.modelID.length==0) {
        [SupportingClass showAlertViewWithTitle:@"alert_remind" message:@"请先选择车辆信息" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
        }];
        return;
    }
    @weakify(self);
    [ProgressHUDHandler showHUD];
    [[APIsConnection shareConnection]  casesHistoryAPIsGetCaseThirdWithAutosModelID:autosData.modelID  idStr:self.idStr success:^(NSURLSessionDataTask *operation, id responseObject) {
        
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@--%@",message,operation.currentRequest.URL.absoluteString);
        [ProgressHUDHandler dismissHUD];
        if (errorCode!= 0) {
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            }];
            return ;
        }
        @strongify(self);
        self.currentDataList = responseObject[CDZKeyOfResultKey];
        if (self.currentDataList.count==0) {
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:@"此车型暂无该信息！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            }];
            return;
        }
        if (!self.isSecondStep) {
            [self pushNextStepViewWithData:self.currentDataList withIdent:1];
        }
        [self.tableView reloadData];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleUserLoginResult:(BOOL)isSuccess fromAlert:(BOOL)fromAlert {
    
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
