//
//  MultiProductInfoDetailVC.m
//  cdzer
//
//  Created by KEns0nLau on 9/25/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "MultiProductInfoDetailVC.h"
#import "ProductInfoCell.h"
#import "WorkingInfoCell.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>

@interface MultiProductInfoDetailVC ()<UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property (weak, nonatomic) IBOutlet UILabel *totalProductNworkingInfoLabel;

@property (weak, nonatomic) IBOutlet UILabel *totalPriceLabel;

@property (weak, nonatomic) IBOutlet UITableView *productInfoTableView;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *productInfoViewHeightConstaint;

@property (weak, nonatomic) IBOutlet UITableView *workingInfoTableView;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *workingInfoViewHeightConstaint;

@property (strong, nonatomic) NSArray *productInfoList;

@property (strong, nonatomic) NSArray *workingInfoList;

@end

@implementation MultiProductInfoDetailVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)viewDidLoad {
    self.title = @"商品工时费清单";
    if (self.hiddenWorkingInfo) self.title = @"商品清单";
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
    [[self.productInfoTableView.superview viewWithTag:10] setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    [[self.workingInfoTableView.superview viewWithTag:10] setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    
    [self.productInfoTableView.superview setViewBorderWithRectBorder:UIRectBorderTop borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self.workingInfoTableView.superview setViewBorderWithRectBorder:UIRectBorderTop borderSize:0.5 withColor:nil withBroderOffset:nil];
}

- (void)componentSetting {
    @autoreleasepool {
        [self.productInfoTableView registerNib:[UINib nibWithNibName:@"ProductInfoCell" bundle:nil] forCellReuseIdentifier:CDZKeyOfCellIdentKey];
        self.productInfoTableView.rowHeight = UITableViewAutomaticDimension;
        self.productInfoTableView.estimatedRowHeight = 200;
        self.productInfoTableView.tableFooterView = [UIView new];
        
        [self.workingInfoTableView registerNib:[UINib nibWithNibName:@"WorkingInfoCell" bundle:nil] forCellReuseIdentifier:CDZKeyOfCellIdentKey];
        self.workingInfoTableView.rowHeight = UITableViewAutomaticDimension;
        self.workingInfoTableView.estimatedRowHeight = 200;
        self.workingInfoTableView.tableFooterView = [UIView new];
        
        self.productInfoList = self.infoDetail[@"product_info"];
        [self.productInfoTableView reloadData];
        
        self.workingInfoTableView.superview.hidden = YES;
        self.totalProductNworkingInfoLabel.text = [NSString stringWithFormat:@"共%d件商品", self.productInfoList.count];
        if (!self.hiddenWorkingInfo) {
            self.workingInfoTableView.superview.hidden = NO;
            self.workingInfoList = self.infoDetail[@"work_info"];
            [self.workingInfoTableView reloadData];
            self.totalProductNworkingInfoLabel.text = [NSString stringWithFormat:@"共%d件商品、%d项工时费", self.productInfoList.count, self.workingInfoList.count];
        }
        
        CGFloat productInfoTotalPrice = [[self.productInfoList valueForKeyPath:@"@sum.total_price"] floatValue];
        CGFloat workingInfoTotalPrice = [[self.workingInfoList valueForKeyPath:@"@sum.price"] floatValue];
        self.totalPriceLabel.text = [NSString stringWithFormat:@"%0.02f", productInfoTotalPrice+workingInfoTotalPrice];
    }
}

- (void)initializationUI {
    @autoreleasepool {
        
    }
}

- (void)setReactiveRules {
    @autoreleasepool {
        @weakify(self);
        [RACObserve(self, productInfoTableView.contentSize) subscribeNext:^(id size) {
            @strongify(self);
            CGSize contentSize = [size CGSizeValue];
            if (self.productInfoList.count==0) contentSize.height = 50;
            self.productInfoViewHeightConstaint.constant = contentSize.height;
        }];
        
        [RACObserve(self, workingInfoTableView.contentSize) subscribeNext:^(id size) {
            @strongify(self);
            CGSize contentSize = [size CGSizeValue];
            if (self.workingInfoList.count==0) contentSize.height = 50;
            if (self.hiddenWorkingInfo) contentSize.height = 0;
            self.workingInfoViewHeightConstaint.constant = contentSize.height;
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismissSelf {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *text = @"暂无更多工时费信息";
    if (self.productInfoTableView==scrollView) {
        text = @"暂无更多商品信息";
    }
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:15.0f],
                                 NSForegroundColorAttributeName:[UIColor colorWithHexString:@"646464"]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (self.productInfoTableView==tableView) return self.productInfoList.count;
    
    return self.workingInfoList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.productInfoTableView==tableView) {
        ProductInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:CDZKeyOfCellIdentKey forIndexPath:indexPath];
        NSDictionary *detail = self.productInfoList[indexPath.row];
        NSString *imageURL = detail[@"product_img"];
        if ([imageURL isContainsString:@"http"]) {
            [cell.productLogoImageView setImageWithURL:[NSURL URLWithString:imageURL] placeholderImage:[ImageHandler getDefaultWhiteLogo] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        }
        cell.productName.text = detail[@"product_name"];
        cell.productPrice.text = [SupportingClass verifyAndConvertDataToString:detail[@"total_price"]];
        cell.productCount.text = [SupportingClass verifyAndConvertDataToString:detail[@"buy_count"]];
        cell.fullBottomBorderLine = (self.productInfoList.count==indexPath.row+1);
        return cell;
    }
    WorkingInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:CDZKeyOfCellIdentKey forIndexPath:indexPath];
    NSDictionary *detail = self.workingInfoList[indexPath.row];
    NSString *imageURL = detail[@"img"];
    if ([imageURL isContainsString:@"http"]) {
        UIImage *image = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"white_logo_small@3x" ofType:@"png"]];
        [cell.productLogoImageView setImageWithURL:[NSURL URLWithString:imageURL] placeholderImage:image usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    cell.productName.text = detail[@"name"];
    cell.productPrice.text = [SupportingClass verifyAndConvertDataToString:detail[@"price"]];
    cell.fullBottomBorderLine = (self.workingInfoList.count==indexPath.row+1);
    return cell;
}


@end
