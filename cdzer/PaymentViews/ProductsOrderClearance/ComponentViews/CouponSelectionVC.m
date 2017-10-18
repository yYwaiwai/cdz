//
//  CouponSelectionVC.m
//  cdzer
//
//  Created by KEns0nLau on 9/23/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "CouponSelectionVC.h"
#import "MyCouponCell.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>

@interface CouponSelectionVC () <UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property (weak, nonatomic) IBOutlet UINavigationBar *navBarView;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation CouponSelectionVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self componentSetting];
    [self initializationUI];
    [self setReactiveRules];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
}

- (void)componentSetting {
    @autoreleasepool {
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 122.0f;
        self.tableView.tableFooterView = [UIView new];
        self.tableView.showsVerticalScrollIndicator = NO;
        UINib*nib = [UINib nibWithNibName:@"MyCouponCell" bundle:nil];
        [self.tableView registerNib:nib forCellReuseIdentifier:@"cell"];
        if (!self.couponList) self.couponList = [@[] mutableCopy];
        
        if (self.couponList.count>0) {
            NSArray *filter = [self.couponList valueForKey:@"mark"];
            NSMutableIndexSet *indextSet = [NSMutableIndexSet indexSet];
            [filter enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *mark = [SupportingClass verifyAndConvertDataToString:obj];
                if ([mark isEqualToString:@"0"]) {
                    [indextSet addIndex:idx];
                }
            }];
            [self.couponList removeObjectsAtIndexes:indextSet];
        }
        [self.tableView reloadData];
    }
}

- (void)initializationUI {
    @autoreleasepool {
        
    }
}

- (void)setReactiveRules {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismissSelfVC {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *text = @"暂无可用优惠劵";
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:15.0f],
                                 NSForegroundColorAttributeName:[UIColor colorWithHexString:@"646464"]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"poc_no_coupon_icon@3x" ofType:@"png"]];
    
    return image;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //    prefer_info[{
    //        id							优惠券id
    //        amount						优惠券面值
    //        content						使用条件
    //        mark						标记【1代表当前可用，0代表当前不可用】
    //        start_time						开始日期
    //        endtime						结束日期
    //    }]
    
    
    MyCouponCell *cell = [tableView dequeueReusableCellWithIdentifier:CDZKeyOfCellIdentKey forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    cell.businessLabel.adjustsFontSizeToFitWidth=YES;
    cell.dateLabel.adjustsFontSizeToFitWidth=YES;
    
    cell.businessLabel.text = self.repairShopName;
    cell.overdueImageView.image = nil;
    
    NSDictionary *datail=self.couponList[indexPath.row];
    cell.priceLabel.text = datail[@"amount"];
    cell.preferentialQuotaLabel.text = datail[@"content"];
    cell.dateLabel.text=[NSString stringWithFormat:@"有效日期:%@至%@",datail[@"start_time"],datail[@"end_time"]];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.couponList.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.resultBlock) {
        NSDictionary *datail=self.couponList[indexPath.row];
        self.resultBlock(datail);
        [self dismissSelfVC];
    }
}


@end
