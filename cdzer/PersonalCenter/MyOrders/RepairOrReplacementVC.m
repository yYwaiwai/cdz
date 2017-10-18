//
//  RepairOrReplacementVC.m
//  cdzer
//
//  Created by 车队长 on 16/9/8.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "RepairOrReplacementVC.h"
#import "CommodityInformationCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface RepairOrReplacementVC ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation RepairOrReplacementVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title=@"退款进度";
    
    self.tableView.backgroundColor=self.view.backgroundColor;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 134.0f;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.showsVerticalScrollIndicator = NO;
    UINib*nib = [UINib nibWithNibName:@"CommodityInformationCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"CommodityInformationCell"];
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ident = @"CommodityInformationCell";
    CommodityInformationCell *cell = [tableView dequeueReusableCellWithIdentifier:ident forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    NSDictionary* resultDic=self.commentArr[indexPath.row];
    if (self.commentArr.count>0) {
        cell.numberLabel.text=[NSString stringWithFormat:@"x%@",resultDic[@"product_num"]];
        cell.priceLabel.text=[NSString stringWithFormat:@"￥%@",resultDic[@"product_price"]];
        NSString *imgURL = resultDic[@"product_img"];
        if ([imgURL containsString:@"http"]) {
            [cell.commodityImageView sd_setImageWithURL:[NSURL URLWithString:imgURL] placeholderImage:[ImageHandler getDefaultWhiteLogo]];
        }
        cell.commodityNameLabel.text=resultDic[@"product_name"];
        [cell.commodityButton setTitle:[NSString stringWithFormat:@"%@",resultDic[@"state_name"]] forState:UIControlStateNormal];
    }
        return cell;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _commentArr.count;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
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
