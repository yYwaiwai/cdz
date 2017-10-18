//
//  RefundReasonVC.m
//  cdzer
//
//  Created by 车队长 on 16/9/6.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "RefundReasonVC.h"

@interface RefundReasonVC ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic,strong)NSString *reasonStr;

@end

@implementation RefundReasonVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title=@"退款原因";
    
    self.tableView.tableFooterView=[UIView new];
    self.tableView.backgroundColor=self.view.backgroundColor;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CDZKeyOfCellIdentKey ];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (!cell) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.font=[UIFont systemFontOfSize:13];
    NSDictionary *result=self.listArr[indexPath.row];
    self.reasonStr=result[@"name"];
    cell.textLabel.text=self.reasonStr;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *result=self.listArr[indexPath.row];
    self.reasonStr=result[@"name"];
    //添加 字典，将label的值通过key值设置传递
    NSDictionary *diction =[[NSDictionary alloc] initWithObjectsAndKeys:self.reasonStr,@"reasonName", nil];
    //创建jsTongZhi通知
    NSNotification *notification =[NSNotification notificationWithName:@"reasonTongZhi" object:nil userInfo:diction];
    //通过通知中心发送通知
    [[NSNotificationCenter defaultCenter] postNotification:notification];
    [self.navigationController popViewControllerAnimated:YES];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _listArr.count;
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
