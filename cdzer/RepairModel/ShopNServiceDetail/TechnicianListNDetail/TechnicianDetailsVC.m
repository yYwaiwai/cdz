//
//  TechnicianDetailsVC.m
//  cdzer
//
//  Created by 车队长 on 16/7/25.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "TechnicianDetailsVC.h"
#import "ExperienceCell.h"
#import <ODRefreshControl/ODRefreshControl.h>
#import <MJRefresh/MJRefresh.h>
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>

@interface TechnicianDetailsVC ()<UITableViewDelegate,UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *topImageView;

@property (weak, nonatomic) IBOutlet UIButton *technicianBiographicalButton;

@property (weak, nonatomic) IBOutlet UIButton *trainingExperienceButton;

@property (weak, nonatomic) IBOutlet UIScrollView *bgView;

@property (weak, nonatomic) IBOutlet UILabel *contentLbeal;

@property (weak, nonatomic) IBOutlet UILabel*line;

@property (weak, nonatomic) IBOutlet UITableView *tableView;


@property (weak, nonatomic) IBOutlet UIImageView *technicianImage;


@property (weak, nonatomic) IBOutlet UILabel *technicianName;

@property (weak, nonatomic) IBOutlet UILabel *technicianDetailLabel;

@property (weak, nonatomic) IBOutlet UIView *buttonBgView;


@property (nonatomic, strong) NSMutableArray *experienceList;

@property (nonatomic, strong) NSDictionary *technicianDetailData;

@end

@implementation TechnicianDetailsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"技师详情";
    self.topImageView.image = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"TechnicianDetails-bg@3x"  ofType:@"png"]];
    [self.technicianBiographicalButton addTarget:self action:@selector(aboutTechnician:) forControlEvents:UIControlEventTouchUpInside];
    [self.trainingExperienceButton addTarget:self action:@selector(aboutTechnician:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.technicianImage setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:CGRectGetHeight(self.technicianImage.frame)/2.0f];
    
    
    self.buttonBgView.frame = CGRectMake(0,CGRectGetHeight(self.topImageView.frame), CGRectGetWidth(self.buttonBgView.frame), 40);

    self.tableView.hidden = YES;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 100.0f;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.showsVerticalScrollIndicator  =  NO;
    self.tableView.backgroundColor = self.view.backgroundColor;
    [self.tableView registerNib:[UINib nibWithNibName:@"ExperienceCell" bundle:nil] forCellReuseIdentifier:@"ExperienceCell"];
    

    [self getMaintenanceShopsTechnicianDetail:nil isReloadAll:YES];
}

- (void)aboutTechnician:(UIButton*)sender {
    if (sender.tag==101) {
        [self.technicianBiographicalButton setTitleColor:CDZColorOfDefaultColor forState:UIControlStateNormal];
        [self.trainingExperienceButton setTitleColor:CDZColorOfBlack forState:UIControlStateNormal];
        self.line.frame = CGRectMake(0, CGRectGetHeight(self.trainingExperienceButton.frame), CGRectGetWidth(self.technicianBiographicalButton.frame), 1);
        self.bgView.hidden = NO;
        self.tableView.hidden = YES;
    }if (sender.tag==102)
    {
        [self.technicianBiographicalButton setTitleColor:CDZColorOfBlack forState:UIControlStateNormal];
        [self.trainingExperienceButton setTitleColor:CDZColorOfDefaultColor forState:UIControlStateNormal];
        self.line.frame = CGRectMake(CGRectGetMinX(self.trainingExperienceButton.frame),CGRectGetHeight(self.trainingExperienceButton.frame), CGRectGetWidth(self.technicianBiographicalButton.frame), 1);
        self.bgView.hidden = YES;
        self.tableView.hidden = NO;
    }
}

- (void)handleData:(id)refresh {
    [self getMaintenanceShopsTechnicianDetail:refresh isReloadAll:[refresh isKindOfClass:ODRefreshControl.class]];
}

- (void)pageObjectPlusOne {
    self.pageNums = @(self.pageNums.integerValue+1);
}

- (void)stopRefresh:(id)refresh {
    if (refresh&&[refresh respondsToSelector:@selector(endRefreshing)]) {
        [refresh endRefreshing];
    }
}

- (void)refreshView:(id)refresh {
    BOOL isRefreshing = NO;
    if ([refresh isKindOfClass:[ODRefreshControl class]]) {
        isRefreshing = [(ODRefreshControl *)refresh refreshing];
    }else if ([refresh isKindOfClass:[MJRefreshAutoNormalFooter class]]) {
        isRefreshing = [(MJRefreshAutoNormalFooter *)refresh isRefreshing];
        [self pageObjectPlusOne];
    }
    if (isRefreshing) {
        [self performSelector:@selector(handleData:) withObject:refresh afterDelay:1.5];
    }
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *text = @"暂无更多技师经历数据！";
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0f],
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ident = @"ExperienceCell";
    ExperienceCell *cell = [tableView dequeueReusableCellWithIdentifier:ident forIndexPath:indexPath];
    cell.upperLineIV.hidden = NO;
    cell.bottomLineIV.hidden = NO;
    if (indexPath.row==0) {
        cell.upperLineIV.hidden = YES;
    }if (indexPath.row==self.experienceList.count-1) {
        cell.bottomLineIV.hidden = YES;
    }

    NSDictionary *detail = self.experienceList[indexPath.row];
    cell.timeLabel.text = detail[@"addtime"];
    cell.detailsLabel.text = detail[@"content"];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.experienceList.count;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getMaintenanceShopsTechnicianDetail:(id)refreshView isReloadAll:(BOOL)isReloadAll {
    
    if (isReloadAll&&!refreshView){
        [ProgressHUDHandler showHUD];
    }
    
    if (isReloadAll) {
        [self pageObjectToDefault];

    }
    
    @weakify(self);
    [[APIsConnection shareConnection] maintenanceShopsAPIsGetMaintenanceShopsTechnicianDetailWithTechnicianID:self.technicianID pageNums:self.pageNums pageSizes:self.pageSizes success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        if (errorCode!= 0) {
            
            if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:!refreshView]) {return;};
            if (isReloadAll&&!refreshView){
                [ProgressHUDHandler dismissHUD];
            }else{
                [self stopRefresh:refreshView];
                if (![message isContainsString:@"数据"]) {
                    self.pageNums = @(self.pageNums.integerValue-1);
                }
            }
            [SupportingClass showAlertViewWithTitle:@"" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            }];
            return ;
        }
        
        if (isReloadAll&&!refreshView) {
            [ProgressHUDHandler dismissHUD];
        }else{
            [self stopRefresh:refreshView];
        }
        
        if (isReloadAll) {
            [self.experienceList removeAllObjects];
        }
        self.pageNums = [SupportingClass verifyAndConvertDataToNumber:responseObject[CDZKeyOfPageNumsKey]];
        self.pageSizes = [SupportingClass verifyAndConvertDataToNumber:responseObject[CDZKeyOfPageSizesKey]];
        self.totalPageSizes = [SupportingClass verifyAndConvertDataToNumber:responseObject[CDZKeyOfTotalPageSizesKey]];
        self.tableView.mj_footer.hidden = ((self.pageNums.intValue*self.pageSizes.intValue)>= self.totalPageSizes.intValue);
        
        self.technicianDetailData = responseObject[CDZKeyOfResultKey];
        self.technicianName.text = self.technicianDetailData[@"real_name"];
        NSString *techImageURL = self.technicianDetailData[@"face_img"];
        if ([techImageURL isContainsString:@"http"]) {
            [self.technicianImage setImageWithURL:[NSURL URLWithString:techImageURL] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        }
        
        NSString *workingGrade = self.technicianDetailData[@"aptitude_name"];
        NSString *workingExperience = self.technicianDetailData[@"seniority_age"];
        self.technicianDetailLabel.text = [NSString stringWithFormat:@"资质：%@  工龄：%@", workingGrade, workingExperience];
        self.contentLbeal.text = self.technicianDetailData[@"introduce"];
        
        
        [self.experienceList addObjectsFromArray:self.technicianDetailData[@"train_info"]];
        [self.tableView reloadData];
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        @strongify(self);
        if (isReloadAll&&!refreshView){
            [ProgressHUDHandler dismissHUD];
        }else{
            [self stopRefresh:refreshView];
            self.pageNums = @(self.pageNums.integerValue-1);
        }
        if (error.code == -1009) {
            [SupportingClass showAlertViewWithTitle:@"error" message:@"网络连接失败，请检查网络设置！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            }];
            return;
        }
        
        
        if (error.code == -1001) {
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
