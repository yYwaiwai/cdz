//
//  GroupCommentListVC.m
//  cdzer
//
//  Created by KEns0n on 30/11/2016.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "GroupCommentListVC.h"
#import "GroupCommentListCell.h"
#import "WriteCommentOrReivewVC.h"
#import "APIsConnection.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface GroupCommentListVC ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray <NSDictionary *> *commentGroupList;

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end

@implementation GroupCommentListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self componentSetting];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    if (self.commentGroupList.count==0||self.shouldReloadData) {
        [self getCommentGroupList];
//    }
    self.shouldReloadData = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)componentSetting {
    self.title = @"订单评价";
    if (self.commentForRepair) {
        self.title = @"维修评价";
    }
    
    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 134.0f;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    UINib*nib = [UINib nibWithNibName:@"GroupCommentListCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:CDZKeyOfCellIdentKey];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.commentGroupList.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GroupCommentListCell *cell = [tableView dequeueReusableCellWithIdentifier:CDZKeyOfCellIdentKey forIndexPath:indexPath];
    NSDictionary *detailData = self.commentGroupList[indexPath.row];
    
    cell.commodityNameLabel.text = detailData[self.commentForRepair?@"wxs_name":@"product_name"];
    
    cell.shopTypeIV.hidden = YES;
    NSString *repairShopType = detailData[@"wxs_kind"];
    if (![repairShopType isEqualToString:@""]&&repairShopType) {
        cell.shopTypeIV.hidden = NO;
        cell.shopTypeIV.highlighted = [repairShopType isContainsString:@"专修"];
    }
    
    NSString *imgURL = detailData[@"product_img"];
    if (self.commentForRepair) {
        imgURL = detailData[@"wxs_logo"];
    }
    cell.commodityImageView.image = [ImageHandler getDefaultWhiteLogo];
    if ([imgURL containsString:@"http"]) {
        [cell.commodityImageView sd_setImageWithURL:[NSURL URLWithString:imgURL] placeholderImage:[ImageHandler getDefaultWhiteLogo]];
    }
    
    
    NSNumber *commentType = [SupportingClass verifyAndConvertDataToNumber:detailData[@"product_type"]];
    CGFloat rectCornerSize = 0;
    NSString *wxsKind = detailData[@"wxs_kind"];
    if ((self.commentForRepair&&[wxsKind isEqualToString:@""])||
        (commentType.integerValue==2&&!self.commentForRepair)) {
        rectCornerSize = (CGRectGetHeight(cell.commodityImageView.frame)/2.0f);
    }
    [cell.commodityImageView setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:rectCornerSize];
    
    
    if ([cell.commodityButton actionsForTarget:self forControlEvent:UIControlEventTouchUpInside].count==0) {
        [cell.commodityButton addTarget:self action:@selector(commodityButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    
    NSNumber *regTag = [SupportingClass verifyAndConvertDataToNumber:detailData[@"reg_tag"]];
    BOOL isCommented = (regTag.integerValue==1);
    cell.commodityButton.selected = isCommented;
    cell.commodityButton.tag = indexPath.row;
    return cell;
}

- (void)commodityButtonClick:(UIButton *)button {
    NSDictionary *detailData = self.commentGroupList[button.tag];
    if (button.selected) {
        //查看评论
        NSString *commentItemID = [SupportingClass verifyAndConvertDataToString:detailData[@"product_id"]];
        [self getCommentReviewDetail:commentItemID];
    }else {
        //评价
        NSString *commentedTagString = [[self.commentGroupList valueForKey:@"reg_tag"] componentsJoinedByString:@","];
        NSUInteger resultCount = 0, length = [commentedTagString length];
        NSRange range = NSMakeRange(0, length);
        while(range.location != NSNotFound) {
            range = [commentedTagString rangeOfString:@"0" options:0 range:range];
            if(range.location != NSNotFound) {
                range = NSMakeRange(range.location + range.length, length - (range.location + range.length));
                resultCount++;
            }
        }
        
        WriteCommentOrReivewVC *vc = [[WriteCommentOrReivewVC alloc]init];
        vc.commentGroupID = self.commentGroupID;
        vc.commentInfoData = detailData;
        vc.typeOfReivew = NO;
        vc.commentForRepair = self.commentForRepair;
        vc.commentsRemainCount = resultCount;
        [self.navigationController pushViewController:vc animated:YES];
        [self setDefaultNavBackButtonWithoutTitle];
    }
}

//评价信息
- (void)getCommentReviewDetail:(NSString *)commentItemID {
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    
    
    [ProgressHUDHandler showHUD];
    @weakify(self);
    APIsConnectionSuccessBlock success = ^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
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
        NSDictionary *resultDic = [responseObject objectForKey:CDZKeyOfResultKey];
        WriteCommentOrReivewVC *vc = [[WriteCommentOrReivewVC alloc]init];
        vc.typeOfReivew = YES;
        vc.commentForRepair = self.commentForRepair;
        vc.commentInfoData = resultDic;
        [self.navigationController pushViewController:vc animated:YES];
        [self setDefaultNavBackButtonWithoutTitle];
    };
    APIsConnectionFailureBlock failure = ^(NSURLSessionDataTask *operation, NSError *error) {
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

    };
    if (self.commentForRepair) {
        [[APIsConnection shareConnection] personalCenterAPIsPostShowRepairGroupCommentInfoWithAccessToken:self.accessToken keyID:self.commentGroupID productID:commentItemID success:success failure:failure];
    }else {
        [[APIsConnection shareConnection] personalCenterAPIsPostShowOrderGroupCommentInfoWithAccessToken:self.accessToken keyID:self.commentGroupID productID:commentItemID success:success failure:failure];
    }
}

//评价列表
- (void)getCommentGroupList {
    if (!self.accessToken) {
        [self handleMissingTokenAction];
        return;
    }
    
    [ProgressHUDHandler showHUD];
    @weakify(self);
    APIsConnectionSuccessBlock success = ^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
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
        self.commentGroupList = [responseObject objectForKey:CDZKeyOfResultKey];
        [self.tableView reloadData];
    };
    
    APIsConnectionFailureBlock failure = ^(NSURLSessionDataTask *operation, NSError *error) {
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
        
    };
    if (self.commentForRepair) {
        [[APIsConnection shareConnection] personalCenterAPIsPostCommentRepairWithAccessToken:self.accessToken keyID:self.commentGroupID success:success failure:failure];
    }else {
        [[APIsConnection shareConnection] personalCenterAPIsGetCommentOrderInfoByaccessToken:self.accessToken keyID:self.commentGroupID success:success failure:failure];
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

@end
