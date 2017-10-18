//
//  CommentListVC.m
//  cdzer
//
//  Created by KEns0n on 3/12/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#import "CommentListVC.h"
#import "CommentListCell.h"
#import "SimpleRatingChartView.h"
#import "HCSStarRatingView.h"
#import <ODRefreshControl/ODRefreshControl.h>
#import <MJRefresh/MJRefresh.h>

@interface CommentListVC () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *appraisalData;

@property (nonatomic, strong) SimpleRatingChartView *chartView;

@property (nonatomic, strong) HCSStarRatingView *ratingView;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataList;

@property (nonatomic, strong) NSMutableDictionary *dataDetail;

@property (nonatomic, strong) UILabel *numOfRatingLabel;

@property (nonatomic, strong) UILabel *ratingCountLabel;

@end


@implementation CommentListVC


- (void)setupAppraisalData {
    @autoreleasepool {
        NSInteger totalCount = [_dataDetail[@"list"] count];
        NSArray *array = @[@{@"totalRating":@(totalCount), @"numberOfRating":@([_dataDetail[@"star_5"] integerValue]), @"ratingName":@"5"},
                           @{@"totalRating":@(totalCount), @"numberOfRating":@([_dataDetail[@"star_4"] integerValue]), @"ratingName":@"4"},
                           @{@"totalRating":@(totalCount), @"numberOfRating":@([_dataDetail[@"star_3"] integerValue]), @"ratingName":@"3"},
                           @{@"totalRating":@(totalCount), @"numberOfRating":@([_dataDetail[@"star_2"] integerValue]), @"ratingName":@"2"},
                           @{@"totalRating":@(totalCount), @"numberOfRating":@([_dataDetail[@"star_1"] integerValue]), @"ratingName":@"1"},
                           ];
        
        [self setAppraisalData:array];
    }
}

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.contentView setBackgroundColor:CDZColorOfWhite];
    [self setTitle:getLocalizationString(@"service_comment")];
    self.dataList = [NSMutableArray array];
    self.dataDetail = [NSMutableDictionary dictionary];
    [self componentSetting];
    [self initializationUI];
    // Do any additional setup after loading the view.
}

- (void)componentSetting {
    [self pageObjectToDefault];
}

- (void)pageObjectPlusOne {
    self.pageNums = @(self.pageNums.intValue+1);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.totalPageSizes.integerValue == 0) {
        [self getMaintenanceShopsAPIsGetMaintenanceShopsCommnetWithRefreshView:nil];
    }
}

- (void)initializationUI {

    @autoreleasepool {
        
        
        UIView *upperView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.contentView.frame), vAdjustByScreenRatio(130.0f))];
        [upperView setBackgroundColor:[UIColor clearColor]];
        [upperView setBorderWithColor:[UIColor colorWithRed:0.910f green:0.910f blue:0.910f alpha:1.00f] borderWidth:(1.0f)];
        
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        CGFloat startPositionX = vAdjustByScreenRatio(20.0f);
        NSMutableAttributedString* message = [NSMutableAttributedString new];
        [message appendAttributedString:[[NSAttributedString alloc]
                                         initWithString:@"0.00"
                                         attributes:@{NSForegroundColorAttributeName:CDZColorOfDefaultColor,
                                                      NSFontAttributeName:[UIFont systemFontOfSize:vAdjustByScreenRatio(40.0f)]
                                                      }]];
        [message appendAttributedString:[[NSAttributedString alloc]
                                         initWithString:@"分"
                                         attributes:@{NSForegroundColorAttributeName:CDZColorOfDefaultColor,
                                                      NSFontAttributeName:[UIFont boldSystemFontOfSize:vAdjustByScreenRatio(25.0f)]
                                                      }]];
        
        CGRect ratingLabelRect = CGRectZero;
        ratingLabelRect.origin.x = startPositionX;
        ratingLabelRect.origin.y = vAdjustByScreenRatio(10.0f);
        CGSize standardSize = CGSizeMake(vAdjustByScreenRatio(122.0f), vAdjustByScreenRatio(34.0f));
        ratingLabelRect.size = [SupportingClass getAttributedStringSizeWithString:message widthOfView:standardSize];
        
        self.numOfRatingLabel = [[UILabel alloc] initWithFrame:ratingLabelRect];
        [_numOfRatingLabel setAttributedText:message];
        [_numOfRatingLabel setTextAlignment:NSTextAlignmentCenter];
        [upperView addSubview:_numOfRatingLabel];
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        NSString *countText = @"000000000人评价";
        UIFont *countFont = [UIFont systemFontOfSize:vAdjustByScreenRatio(15.0f)];
        CGRect countRect = ratingLabelRect;
        countRect.origin.y = CGRectGetMaxY(ratingLabelRect);
        countRect.size = [SupportingClass getStringSizeWithString:countText font:countFont widthOfView:standardSize];
        countRect.size.height *=vAdjustByScreenRatio(1.4);

        self.ratingCountLabel = [[UILabel alloc] initWithFrame:countRect];
        [_ratingCountLabel setText:countText];
        [_ratingCountLabel setFont:countFont];
        [_ratingCountLabel setCenter:CGPointMake(_numOfRatingLabel.center.x, _ratingCountLabel.center.y)];
        [_ratingCountLabel setTextColor:[UIColor colorWithRed:0.349f green:0.341f blue:0.345f alpha:1.00f]];
        [_ratingCountLabel setTextAlignment:NSTextAlignmentCenter];
        [upperView addSubview:_ratingCountLabel];
        
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        CGRect ratingViewRect = ratingLabelRect;
        ratingViewRect.origin.y = CGRectGetMaxY(countRect)+vAdjustByScreenRatio(6.0f);
        ratingViewRect.size.width = CGRectGetWidth(ratingLabelRect);
        ratingViewRect.size.height = vAdjustByScreenRatio(26.0f);
        [self setRatingView:[[HCSStarRatingView alloc] initWithFrame:ratingViewRect]];
        [_ratingView setCenter:CGPointMake(_ratingCountLabel.center.x, _ratingView.center.y)];
        [_ratingView setMaximumValue:5.0f];
        [_ratingView setMinimumValue:0.0f];
        [_ratingView setValue:0.0f];
        [_ratingView setAllowsHalfStars:NO];
        [_ratingView setTintColor:[UIColor redColor]];
        [_ratingView setUserInteractionEnabled:NO];
//        [_ratingView addTarget:self action:@selector(didChangeValue:) forControlEvents:UIControlEventValueChanged];
        [upperView addSubview:_ratingView];
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        [self setChartView:[[SimpleRatingChartView alloc] initWithFrame:CGRectMake(vAdjustByScreenRatio(130.0f),
                                                                                   vAdjustByScreenRatio(10.0f),
                                                                                   vAdjustByScreenRatio(160.0f),
                                                                                   vAdjustByScreenRatio(110.0f))]];
        [upperView addSubview:_chartView];
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        if (!_tableView) {
            self.tableView = [[UITableView alloc] initWithFrame:self.contentView.bounds];
            _tableView.bounces = YES;
            _tableView.showsHorizontalScrollIndicator = NO;
            _tableView.showsVerticalScrollIndicator = NO;
//            [tabelView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
            _tableView.delegate = self;
            _tableView.dataSource = self;
            [_tableView setTableHeaderView:upperView];
            [self.contentView addSubview:_tableView];
        }
        
        
        ODRefreshControl *refreshControl = [[ODRefreshControl alloc] initInScrollView:_tableView];
        [refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
        
        _tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(refreshView:)];
        _tableView.mj_footer.automaticallyHidden = NO;
        _tableView.mj_footer.hidden = YES;
    }
}

- (void)stopRefresh:(id)refresh {
    [refresh endRefreshing];
}

- (void)handleData:(id)refresh {
    [self getMaintenanceShopsAPIsGetMaintenanceShopsCommnetWithRefreshView:refresh];
}

- (void)refreshView:(id)refresh {
    BOOL isRefreshing = NO;
    if ([refresh isKindOfClass:[ODRefreshControl class]]) {
        isRefreshing = [(ODRefreshControl *)refresh refreshing];
        [self componentSetting];
    }else if ([refresh isKindOfClass:[MJRefreshAutoNormalFooter class]]) {
        isRefreshing = [(MJRefreshAutoNormalFooter *)refresh isRefreshing];
        [self pageObjectPlusOne];
    }
    if (isRefreshing) {
        [self performSelector:@selector(handleData:) withObject:refresh afterDelay:1.5];
    }
}

#pragma -mark UITableViewDelgate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSLog(@"%lu",(unsigned long)_dataList.count);
    return _dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CommentListCell *cell = [tableView dequeueReusableCellWithIdentifier:CDZKeyOfCellIdentKey];
    if (!cell) {
        cell = [[CommentListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CDZKeyOfCellIdentKey];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell initializationUI];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:tableView.bounds];
        [imageView setTag:9090];
        [cell addSubview:imageView];
        
    }
    // Configure the cell...
    [cell updateUIDataWithData:_dataList[indexPath.row]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 0.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return 0.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return vAdjustByScreenRatio(115.0f);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)updateUpperViewData {
    @autoreleasepool {
        _tableView.mj_footer.hidden = ((self.pageSizes.integerValue*self.pageNums.integerValue)>self.totalPageSizes.integerValue);
        NSMutableAttributedString* message = [NSMutableAttributedString new];
        [message appendAttributedString:[[NSAttributedString alloc]
                                         initWithString:[_dataDetail[@"total_score"] stringValue]
                                         attributes:@{NSForegroundColorAttributeName:CDZColorOfDefaultColor,
                                                      NSFontAttributeName:[UIFont systemFontOfSize:vAdjustByScreenRatio(40.0f)]
                                                      }]];
        [message appendAttributedString:[[NSAttributedString alloc]
                                         initWithString:@"分"
                                         attributes:@{NSForegroundColorAttributeName:CDZColorOfDefaultColor,
                                                      NSFontAttributeName:[UIFont boldSystemFontOfSize:vAdjustByScreenRatio(25.0f)]
                                                      }]];
        [_numOfRatingLabel setAttributedText:message];
        
        [self setupAppraisalData];
        [_chartView removeAllView];
        [_chartView initializationUIWithData:_appraisalData];
        
        _ratingCountLabel.text = [NSString stringWithFormat:@"%@人评价",self.totalPageSizes.stringValue];
        
        CGFloat ratingValue = [_dataDetail[@"star_all"] floatValue];
        _ratingView.value = ratingValue;
        [_tableView reloadData];
    }
}

#pragma mark- API Access Code Section
- (void)getMaintenanceShopsAPIsGetMaintenanceShopsCommnetWithRefreshView:(id)refreshView {
    if (!refreshView) {
        [ProgressHUDHandler showHUD];
    }
    [[APIsConnection shareConnection] maintenanceShopsAPIsGetMaintenanceShopsCommnetListWithShopID:_shopID pageNums:self.pageNums.stringValue pageSizes:self.pageSizes.stringValue  success:^(NSURLSessionDataTask *operation, id responseObject) {
        if (refreshView) {
            operation.userInfo = @{@"refreshView":refreshView};
        }
        
        [self requestResultHandle:operation responseObject:responseObject withError:nil];
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        if (refreshView) {
            operation.userInfo = @{@"refreshView":refreshView};
        }
        [self requestResultHandle:operation responseObject:nil withError:error];
    }];
}
- (void)requestResultHandle:(NSURLSessionDataTask *)operation responseObject:(id)responseObject withError:(NSError *)error {
    
    id refreshView = operation.userInfo[@"refreshView"];
    if(!refreshView){
        [ProgressHUDHandler dismissHUD];
    }else{
        [self stopRefresh:refreshView];
    }

    if (error&&!responseObject) {
        if (refreshView) {
            self.pageNums = @(self.pageNums.intValue-1);
        }
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
                if (self.totalPageSizes.integerValue == 0) {
                    [self.dataList removeAllObjects];
                    self.totalPageSizes = @([responseObject[CDZKeyOfTotalPageSizesKey] integerValue]);
                }
                self.pageNums = @([responseObject[CDZKeyOfPageNumsKey] integerValue]);
                self.pageSizes = @([responseObject[CDZKeyOfPageSizesKey] integerValue]);
                self.dataDetail = responseObject[CDZKeyOfResultKey];
                self.tableView.mj_footer.hidden = ((self.pageNums.intValue*self.pageSizes.intValue)>=self.totalPageSizes.intValue);
                [self.dataList addObjectsFromArray:_dataDetail[@"list"]];
                [self updateUpperViewData];
            }
                break;
            case 1:
            case 2:
                if (refreshView) {
                    self.pageNums = @(self.pageNums.intValue-1);
                }
                [SupportingClass showAlertViewWithTitle:@"nil" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                }];
                break;
                
            default:
                break;
        }
        
    }
    
}
//- (void)didChangeValue:(HCSStarRatingView *)sender {
//    NSLog(@"Changed rating to %.1f", sender.value);
//}

@end
