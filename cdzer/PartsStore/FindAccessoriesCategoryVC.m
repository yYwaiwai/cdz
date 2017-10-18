//
//  FindAccessoriesCategoryVC.m
//  cdzer
//
//  Created by 车队长 on 16/9/9.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "FindAccessoriesCategoryVC.h"
#import "FindAccessoriesCategoryCell.h"
#import "UIView+LayoutConstraintHelper.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "SelectedBgViewCell.h"

@interface FindAccessoriesCategoryVC ()<UICollectionViewDelegate,UICollectionViewDataSource,UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIControl *headControl;

@property (weak, nonatomic) IBOutlet UILabel *carMessageLabel;

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) NSArray *typeInfoList;

@property (nonatomic, strong) NSArray *secondLevelList;

@property (nonatomic, strong) NSArray *thirdLevelList;

@property (nonatomic, strong) NSIndexPath *stepOneIndexPath;

@property (nonatomic, strong) NSIndexPath *stepTwoIndexPath;

@property (nonatomic, strong) NSIndexPath *stepThreeIndexPath;

@property (nonatomic) BOOL statusTwo;

@end

@implementation FindAccessoriesCategoryVC

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getAutopartType];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title=@"类型";
    
    [self.headImageView.layer setCornerRadius:22.5];
    [self.headImageView.layer setMasksToBounds:YES];
    [self.headImageView setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:3.0f withColor:[UIColor colorWithHexString:@"82d5f7"] withBroderOffset:nil];
    NSString *imgURL = self.headImageUrl;
    if ([imgURL containsString:@"http"]) {
        [self.headImageView sd_setImageWithURL:[NSURL URLWithString:imgURL] placeholderImage:[ImageHandler getDefaultWhiteLogo]];
    }
    self.carMessageLabel.text=self.carLabelText;
    [self.headControl addTarget:self action:@selector(headControlClick) forControlEvents:UIControlEventTouchUpInside];
    
    self.stepOneIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    self.tableView.tableFooterView = [UIView new];
    UINib*nib = [UINib nibWithNibName:@"SelectedBgViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"SelectedBgViewCell"];
    
    [self.collectionView registerClass:[FindAccessoriesCategoryCell class] forCellWithReuseIdentifier:@"FindAccessoriesCategoryCell"];
    
}

- (void)backToStepOne {
    self.statusTwo = NO;
    [self.tableView reloadData];
    if (self.stepOneIndexPath) {
        [self.tableView selectRowAtIndexPath:self.stepOneIndexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
    }
    [self.collectionView reloadData];
    if (self.stepTwoIndexPath) {
        [self.collectionView selectItemAtIndexPath:self.stepTwoIndexPath animated:YES scrollPosition:UICollectionViewScrollPositionTop];
    }
}
//选择车型
- (void)headControlClick
{
    
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ident = @"SelectedBgViewCell";
    SelectedBgViewCell *cell =[tableView dequeueReusableCellWithIdentifier:ident ];
    if (!cell) {
        cell=[[SelectedBgViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ident];
    }
    tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    [cell.bgView setViewBorderWithRectBorder:UIRectBorderLeft borderSize:3 withColor:[UIColor colorWithHexString:@"49c7f5"] withBroderOffset:nil];
    NSArray *sourceList = self.typeInfoList;
    if (self.statusTwo) sourceList = self.secondLevelList;
    cell.nameLabel.text=[sourceList[indexPath.row] objectForKey:@"name"];
    cell.nameLabel.textColor=[UIColor colorWithHexString:@"323232"];
    cell.nameLabel.highlightedTextColor = [UIColor colorWithHexString:@"49c7f5"];
    
    return cell;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.statusTwo) {
        return self.secondLevelList.count;
    }
    return self.typeInfoList.count;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    static NSString *ident = @"headerView";
    UITableViewHeaderFooterView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:ident];
    if (!header) {
        header = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:ident];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.translatesAutoresizingMaskIntoConstraints = NO;
        button.titleLabel.font = [button.titleLabel.font fontWithSize:14];
        [button setTitle:@"上一步" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithHexString:@"49c7f5"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(backToStepOne) forControlEvents:UIControlEventTouchUpInside];
        [button addSelfByFourMarginToSuperview:header];
        
    }
    return header;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.statusTwo) {
        return 30;
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.statusTwo) {
        self.stepTwoIndexPath = indexPath;
        NSString*typeIDStr=[[self.secondLevelList objectAtIndex:indexPath.row] objectForKey:@"id"];
        [self getAutopartInfo:typeIDStr];
    }else {
        self.stepOneIndexPath = indexPath;
        NSString*typeIDStr=[[self.typeInfoList objectAtIndex:indexPath.row] objectForKey:@"id"];
        [self getAutopartList:typeIDStr];
    }
   
}
/////
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier = @"FindAccessoriesCategoryCell";
    FindAccessoriesCategoryCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    NSArray *sourceList = self.secondLevelList;
    if (self.statusTwo) sourceList = self.thirdLevelList;
    cell.nameLabel.text=[sourceList[indexPath.row] objectForKey:@"name"];
    if ([UIScreen mainScreen].bounds.size.width <= 375.0) {
        cell.nameLabel.font=[UIFont systemFontOfSize:12];
    }else{
        cell.nameLabel.font=[UIFont systemFontOfSize:13];
    }
    [cell systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    NSString *imgURL = [sourceList[indexPath.row] objectForKey:@"imgurl"];
    if ([imgURL containsString:@"http"]) {
        [cell.headImageView sd_setImageWithURL:[NSURL URLWithString:imgURL] placeholderImage:[ImageHandler getDefaultWhiteLogo]];
    }
    return cell;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    float width=(self.collectionView.bounds.size.width-10)/4;
    return CGSizeMake(width, 110);
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(2, 2, 2, 2);
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.statusTwo) {
        return self.thirdLevelList.count;
    }
    return self.secondLevelList.count;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (self.statusTwo) {
        self.stepThreeIndexPath = indexPath;
        NSString*typeIDStr=[[self.thirdLevelList objectAtIndex:indexPath.row] objectForKey:@"id"];
        //添加 字典，将label的值通过key值设置传递
        NSDictionary *diction =[[NSDictionary alloc] initWithObjectsAndKeys:typeIDStr,@"id",nil];
        //创建jsTongZhi通知
        NSNotification *notification =[NSNotification notificationWithName:@"czpjTongZhi" object:nil userInfo:diction];
        //通过通知中心发送通知
        [[NSNotificationCenter defaultCenter] postNotification:notification];
        [self.navigationController popViewControllerAnimated:YES];
    }else {
        self.stepTwoIndexPath = indexPath;
        NSString*typeIDStr=[[self.secondLevelList objectAtIndex:indexPath.row] objectForKey:@"id"];
        [self getAutopartInfo:typeIDStr];
    }
    
}
//配件一级分类
- (void)getAutopartType
{
    [ProgressHUDHandler showHUD];
    [[APIsConnection shareConnection] personalCenterAPIsGetAutopartTypeSuccess:^(NSURLSessionDataTask *operation, id responseObject) {
        operation.userInfo = @{@"ident":@"autopartType"};
        [self requestResultHandle:operation responseObject:responseObject withError:nil];
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        operation.userInfo = @{@"ident":@"autopartType"};
        [self requestResultHandle:operation responseObject:nil withError:error];

    }];
}
//配件二级分类信息
- (void)getAutopartList:(NSString *)typeId
{
    [[APIsConnection shareConnection] personalCenterAPIsGetAutopartListBykeyID:typeId success:^(NSURLSessionDataTask *operation, id responseObject) {
        operation.userInfo = @{@"ident":@"autopartList"};
        [self requestResultHandle:operation responseObject:responseObject withError:nil];
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        operation.userInfo = @{@"ident":@"autopartList"};
        [self requestResultHandle:operation responseObject:nil withError:error];
        
    }];
}
//配件三级分类信息
- (void)getAutopartInfo:(NSString *)typeId
{
    [[APIsConnection shareConnection] personalCenterAPIsGetAutopartInfoBykeyID:typeId success:^(NSURLSessionDataTask *operation, id responseObject) {
        operation.userInfo = @{@"ident":@"autopartInfo"};
        [self requestResultHandle:operation responseObject:responseObject withError:nil];
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        operation.userInfo = @{@"ident":@"autopartInfo"};
        [self requestResultHandle:operation responseObject:nil withError:error];
        
    }];
}
- (void)requestResultHandle:(NSURLSessionDataTask *)operation responseObject:(id)responseObject withError:(NSError *)error {
    id refreshView = operation.userInfo[@"refreshView"];
    
    if (error&&!responseObject) {
        NSLog(@"%@",error);
        if(!refreshView){
            [ProgressHUDHandler dismissHUD];
        }else{
        }
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
        [SupportingClass showAlertViewWithTitle:@"error" message:@"连接超时，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
        }];

    }else if (!error&&responseObject) {
        
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@-----%@",message,operation.currentRequest.URL.absoluteString);
        
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        
        if (errorCode!=0) {
            if(!refreshView){
                [ProgressHUDHandler dismissHUD];
            }else{
            }
            [SupportingClass showAlertViewWithTitle:@"error" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                
            }];
            return;
        }
        
        if (operation.userInfo&&[operation.userInfo[@"ident"] isEqualToString:@"autopartType"]) {
            self.typeInfoList=[[responseObject objectForKey:CDZKeyOfResultKey] objectForKey:@"type_info"];
            self.secondLevelList=[[responseObject objectForKey:CDZKeyOfResultKey] objectForKey:@"list_info"];
            [self.tableView reloadData];
            if (self.stepOneIndexPath) {
                [self.tableView selectRowAtIndexPath:self.stepOneIndexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
            }
            [self.collectionView reloadData];
            [ProgressHUDHandler dismissHUD];
        }
        if (operation.userInfo&&[operation.userInfo[@"ident"] isEqualToString:@"autopartList"]) {
            self.secondLevelList=[responseObject objectForKey:CDZKeyOfResultKey] ;
            [self.collectionView reloadData];
            [ProgressHUDHandler dismissHUD];
            
        }
        if (operation.userInfo&&[operation.userInfo[@"ident"] isEqualToString:@"autopartInfo"]) {
            self.statusTwo = YES;
            self.thirdLevelList=[responseObject objectForKey:CDZKeyOfResultKey] ;
            [self.tableView reloadData];
            if (self.stepTwoIndexPath) {
                [self.tableView selectRowAtIndexPath:self.stepTwoIndexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
            }
            [self.collectionView reloadData];
            [ProgressHUDHandler dismissHUD];
        }

    }
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
