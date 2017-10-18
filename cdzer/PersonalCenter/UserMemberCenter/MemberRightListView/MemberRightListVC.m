//
//  MemberRightListVC.m
//  cdzer
//
//  Created by KEns0n on 01/12/2016.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "MemberRightListVC.h"
#import "MemberRightListTopCell.h"
#import "MemberRightListBottomCell.h"
#import "MRLBUpperTitleCell.h"
#import "MRLBBottomSpaceCell.h"

@interface MemberRightListVC ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@property (nonatomic, strong) NSArray *detailList;

@end

@implementation MemberRightListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"会员服务套餐介绍";
    [self componentSetting];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)componentSetting {
    self.automaticallyAdjustsScrollViewInsets = NO;
    NSString *pathfile = [NSBundle.mainBundle pathForResource:@"member_data_list" ofType:@"json"];
    NSData *data = [[NSData alloc] initWithContentsOfFile:pathfile];
    self.detailList = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    self.selectedIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    [self.collectionView registerNib:[UINib nibWithNibName:@"MemberRightListTopCell" bundle:nil] forCellWithReuseIdentifier:CDZKeyOfCellIdentKey];
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    UIEdgeInsets sectionInset = UIEdgeInsetsZero;
    sectionInset.left = (SCREEN_WIDTH-126)/2.0f;
    sectionInset.right = sectionInset.left;
    layout.sectionInset = sectionInset;
    layout.itemSize = CGSizeMake(126, 105);
    self.collectionView.allowsMultipleSelection = NO;
    self.collectionView.allowsSelection = YES;
    
    
    self.tableView.allowsMultipleSelection = NO;
    self.tableView.allowsSelection = NO;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 100;
    [self.tableView registerNib:[UINib nibWithNibName:@"MRLBUpperTitleCell" bundle:nil] forCellReuseIdentifier:@"headerView"];
    [self.tableView registerNib:[UINib nibWithNibName:@"MRLBBottomSpaceCell" bundle:nil] forCellReuseIdentifier:@"footerView"];
    [self.tableView registerNib:[UINib nibWithNibName:@"MRLBMemberRightCell" bundle:nil] forCellReuseIdentifier:@"MRLBMemberRightCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"MRLBLevelDetailCell" bundle:nil] forCellReuseIdentifier:@"MRLBLevelDetailCell"];
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 5;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MemberRightListTopCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CDZKeyOfCellIdentKey forIndexPath:indexPath];
    [cell updateSettingByIndex:indexPath andSelected:(self.selectedIndexPath&&[indexPath isEqual:self.selectedIndexPath])];
    cell.leftBarIV.hidden = (indexPath.item==0);
    cell.rightBarIV.hidden = (indexPath.item==4);
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.collectionView==collectionView) {
        if ([self.selectedIndexPath isEqual:indexPath]) return;
        if (self.selectedIndexPath) {
            MemberRightListTopCell *cell = (MemberRightListTopCell *)[collectionView cellForItemAtIndexPath:self.selectedIndexPath];
            [cell imageTransitionReduction];
        }
        self.selectedIndexPath = indexPath;
        MemberRightListTopCell *cell = (MemberRightListTopCell *)[collectionView cellForItemAtIndexPath:self.selectedIndexPath];
        [cell imageTransitionSelection];
        [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
        
        [UIView transitionWithView:self.tableView duration:0.5 options:UIViewAnimationOptionTransitionCurlUp animations:^{
            [self.tableView reloadData];
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        } completion:^(BOOL finished) {
            
        }];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSDictionary *detail = self.detailList[self.selectedIndexPath.item];
    if (detail[@"down_list"]) {
        return 9;
    }
    return 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDictionary *detail = self.detailList[self.selectedIndexPath.item];
    NSUInteger count = 1;
    if (section==1) {
        count = [detail[@"right_list"] count];
    }
    if (section==4) {
        count = [detail[@"up_list"] count];
    }
    if (section==7) {
        count = [detail[@"down_list"] count];
    }
    return count;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *detail = self.detailList[self.selectedIndexPath.item];
        if (indexPath.section==0||indexPath.section==3||indexPath.section==6) {
            MRLBUpperTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"headerView" forIndexPath:indexPath];
            cell.subTitleView.text = @"";
            cell.mainTitleView.text = @"";
            cell.bottomConstraint.constant = 19;
            if (indexPath.section==0) {
                cell.bottomConstraint.constant = 0;
                cell.mainTitleView.text = @"享受权益";
                cell.subTitleView.text = @"（注：会员服务只针对你跟人中心所绑定的车辆）";
            }else if (indexPath.section==3) {
                cell.mainTitleView.text = @"成为条件";
            }else if (indexPath.section==6) {
                cell.mainTitleView.text = @"会员须知";
            }
            return cell;
        }
        if (indexPath.section==2||indexPath.section==5||indexPath.section==8) {
            MRLBBottomSpaceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"footerView" forIndexPath:indexPath];
            cell.heightConstraint.constant = 13;
            if ((detail[@"down_list"]&&indexPath.section==8)||
                (!detail[@"down_list"]&&indexPath.section==5)) {
                cell.heightConstraint.constant = 88;
            }
            return cell;
        }
        
        MemberRightListBottomCell *cell = nil;
        if (detail&&detail.count>0) {
            if (indexPath.section==1) {
                cell = [tableView dequeueReusableCellWithIdentifier:@"MRLBMemberRightCell" forIndexPath:indexPath];
                NSArray *list = detail[@"right_list"];
                cell.isLastCell = (list.count==indexPath.item+1);
                MDRDataModel *dto = [MDRDataModel createDataModelWithSourceDetail:list[indexPath.item]];
                [cell updateUIDataWithDataModel:dto];
            }else if(indexPath.section==4||indexPath.section==7) {
                cell = [tableView dequeueReusableCellWithIdentifier:@"MRLBLevelDetailCell" forIndexPath:indexPath];
                NSArray <NSString *> *list = nil;
                if (indexPath.section==4) {
                    list = [detail[@"up_list"] valueForKey:@"des"];
                }else if (indexPath.section==7) {
                    list = [detail[@"down_list"] valueForKey:@"des"];
                }
                if (list.count>0&&list) {
                    cell.isLastCell = (list.count==indexPath.item+1);
                    [cell updateUIDataWithIndex:indexPath.item andContent:list[indexPath.item]];
                }
            }
        }
        return cell;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
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
