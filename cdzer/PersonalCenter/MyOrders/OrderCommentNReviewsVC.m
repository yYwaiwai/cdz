//
//  OrderCommentNReviewsVC.m
//  cdzer
//
//  Created by 车队长 on 16/9/6.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "OrderCommentNReviewsVC.h"
#import "CommodityInformationCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "ServiceEvaluationVC.h"

@interface OrderCommentNReviewsVC ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic,strong) NSArray *commentArr;

@property (nonatomic,strong) NSDictionary *resultDic;

@end

@implementation OrderCommentNReviewsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"评论";
    
    self.tableView.backgroundColor=self.view.backgroundColor;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 134.0f;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.showsVerticalScrollIndicator = NO;
    UINib*nib = [UINib nibWithNibName:@"CommodityInformationCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"CommodityInformationCell"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getCommentList];
}

- (void)viewDidDisappear:(BOOL)animated {
    
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ident = @"CommodityInformationCell";
    CommodityInformationCell *cell = [tableView dequeueReusableCellWithIdentifier:ident forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.numberLabel.hidden=YES;
    cell.priceLabel.hidden=YES;
    self.resultDic=self.commentArr[indexPath.row];
    
    NSString *imgURL = self.resultDic[@"product_img"];
    if ([imgURL containsString:@"http"]) {
        [cell.commodityImageView sd_setImageWithURL:[NSURL URLWithString:imgURL] placeholderImage:[ImageHandler getDefaultWhiteLogo]];
    }
    cell.commodityNameLabel.text=self.resultDic[@"product_name"];
    NSNumber*regTag=self.resultDic[@"reg_tag"];
    if ([regTag  isEqual:@0]) {
        [cell.commodityButton setTitle:@"评价" forState:UIControlStateNormal];
        [cell.commodityButton addTarget:self action:@selector(commodityButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }else{
        [cell.commodityButton setTitle:@"查看评价" forState:UIControlStateNormal];
        [cell.commodityButton addTarget:self action:@selector(viewEvaluation:) forControlEvents:UIControlEventTouchUpInside];
    }
    cell.commodityButton.tag=indexPath.row;
    [cell.commodityButton setTitleColor:CDZColorOfOrangeColor forState:UIControlStateNormal];
    [cell.commodityButton setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:1.0f withColor:CDZColorOfOrangeColor withBroderOffset:nil];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.commentArr.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
//评价
- (void)commodityButtonClick:(UIButton*)button{
    self.resultDic=self.commentArr[button.tag];
    ServiceEvaluationVC*vc=[[ServiceEvaluationVC alloc]init];
    vc.repairID=self.orderID;
    vc.resultDic=self.resultDic;
    vc.isPushFromOrder = YES;
    vc.fromVCStr=@"产品评价";
    [self.navigationController pushViewController:vc animated:YES];
    [self setDefaultNavBackButtonWithoutTitle];
}

//查看评论
- (void)viewEvaluation:(UIButton*)button {
    self.resultDic=self.commentArr[button.tag];
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    [ProgressHUDHandler showHUD];
    [[APIsConnection shareConnection] personalCenterAPIsPostShowOrderGroupCommentInfoWithAccessToken:self.accessToken keyID:self.orderID productID:self.resultDic[@"product_id"] success:^(NSURLSessionDataTask *operation, id responseObject) {
        
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@----%@",message,operation.currentRequest.URL.absoluteString);
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        
        if (errorCode!=0) {
            [ProgressHUDHandler dismissHUD];
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
            return;
        }
        NSLog(@"%@",responseObject);
        
        [ProgressHUDHandler dismissHUD];
        NSDictionary *resultDic=[responseObject objectForKey:CDZKeyOfResultKey];
        ServiceEvaluationVC*vc=[[ServiceEvaluationVC alloc]init];
        vc.resultDic=resultDic;
        vc.fromVCStr=@"产品评价查看";
        
        [self.navigationController pushViewController:vc animated:YES];
        [self setDefaultNavBackButtonWithoutTitle];
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {  NSLog(@"%@",error);
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

//评价
- (void)getCommentList {
    
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    [ProgressHUDHandler showHUD];
    [[APIsConnection shareConnection] personalCenterAPIsGetCommentOrderInfoByaccessToken:self.accessToken keyID:self.orderID success:^(NSURLSessionDataTask *operation, id responseObject) {
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
            return;
        }
        
        if (errorCode!=0) {
            [ProgressHUDHandler dismissHUD];
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
            return;
        }
        
        [ProgressHUDHandler dismissHUD];
        self.commentArr = [responseObject objectForKey:CDZKeyOfResultKey];
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
