//
//  RepairShopResultVCComponent.m
//  cdzer
//
//  Created by KEns0nLau on 6/29/16.
//  Copyright © 2016 CDZER. All rights reserved.
//
#define kName @"name"
#define kID @"id"
#import "RepairShopResultVCComponent.h"

@interface  RepairShopResultFilterView ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UIButton *shopTypeArrowBtn;

@property (nonatomic, weak) IBOutlet UIButton *serviceTypeArrowBtn;

@property (nonatomic, weak) IBOutlet UIButton *certArrowBtn;

@property (nonatomic, weak) IBOutlet UILabel *shopTypeLabel;

@property (nonatomic, weak) IBOutlet UILabel *serviceTypeLabel;

@property (nonatomic, weak) IBOutlet UILabel *certLabel;

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, weak) IBOutlet UIControl *maskView;

@property (nonatomic, strong) NSLayoutConstraint *selfHeightConstraint;

@property (nonatomic, strong) IBOutlet NSLayoutConstraint *tvHeightConstraint;

@property (nonatomic, assign) NSUInteger currentMainIdx;

@property (nonatomic, strong) NSArray *selectionDataList;

@property (nonatomic, strong) NSMutableArray <NSIndexPath *> *selectedList;

@property (nonatomic, copy) RepairShopFilterResponseBlock responseBlock;

@end

@implementation RepairShopResultFilterView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selfHeightConstraint = [NSLayoutConstraint constraintWithItem:self
                                                             attribute:NSLayoutAttributeHeight
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:nil
                                                             attribute:NSLayoutAttributeNotAnAttribute
                                                            multiplier:1
                                                              constant:42];
    [self addConstraint:self.selfHeightConstraint];
    
    NSMutableArray *typeArray = [NSMutableArray arrayWithObject:@{kID:@"", kName:@"全部维修商类型"}];
    [typeArray addObjectsFromArray:DBHandler.shareInstance.getRepairShopTypeList];
    
    NSMutableArray *servicetypeArray = [NSMutableArray arrayWithObject:@{kID:@"", kName:@"全部服务项目"}];
    [servicetypeArray addObjectsFromArray:DBHandler.shareInstance.getRepairShopServiceTypeList];
    
    self.selectionDataList = @[typeArray,
                               servicetypeArray,
                               @[@{kName:getLocalizationString(@"non_authenticated")}, @{kName:getLocalizationString(@"was_authenticated")}]];
    [self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:@"cell"];\
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    self.selectedList = [@[indexPath, indexPath, indexPath] mutableCopy];
    self.tableView.rowHeight = 34.0f;
    
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull subview, NSUInteger idx, BOOL * _Nonnull stop) {
        if (subview.tag==101) {
            [subview setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5f withColor:[UIColor colorWithRed:0.839 green:0.843 blue:0.863 alpha:1.00] withBroderOffset:nil];
        }
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (IBAction)showOptionView:(UIControl *)sender {
    if (sender.selected) {
        sender.selected = NO;
        [self unfoldingFilterView];
        return;
    }
    self.currentMainIdx = sender.tag;
    
    self.shopTypeArrowBtn.selected = NO;
    self.serviceTypeArrowBtn.selected = NO;
    self.certArrowBtn.selected = NO;
    
    
    CGFloat height = CGRectGetHeight(self.superview.frame);
    if (height<=0) height = 42;
    self.selfHeightConstraint.constant = height;
    
    [self.tableView reloadData];
    CGFloat contentSizeHeight = self.tableView.contentSize.height;
    CGFloat contentSizeMaxHeight = (self.tableView.rowHeight*4+10);
    if (contentSizeHeight>contentSizeMaxHeight) {
        contentSizeHeight = contentSizeMaxHeight;
    }
    @weakify(self);
    [UIView animateWithDuration:0.25 animations:^{
        @strongify(self);
        CGRect frame = self.tableView.frame;
        frame.size.height = contentSizeHeight;
        self.tableView.frame = frame;
        self.maskView.alpha = 1;
        if (sender.tag==0) self.shopTypeArrowBtn.selected = YES;
        if (sender.tag==1) self.serviceTypeArrowBtn.selected = YES;
        if (sender.tag==2) self.certArrowBtn.selected = YES;
    }];
    [self.tableView selectRowAtIndexPath:self.selectedList[self.currentMainIdx]
                                animated:NO scrollPosition:UITableViewScrollPositionMiddle];
    self.tvHeightConstraint.constant = contentSizeHeight;
}

- (void)unfoldingFilterView {
    @weakify(self);
    [UIView animateWithDuration:0.25 animations:^{
        @strongify(self);
        CGRect frame = self.tableView.frame;
        frame.size.height = 0;
        self.tableView.frame = frame;
        self.maskView.alpha = 0;
        
        self.shopTypeArrowBtn.selected = NO;
        self.serviceTypeArrowBtn.selected = NO;
        self.certArrowBtn.selected = NO;
    } completion:^(BOOL finished) {
        @strongify(self);
        self.selfHeightConstraint.constant = 42;
    }];
    self.tvHeightConstraint.constant = 0;
}

- (void)setSelectedResponseBlock:(RepairShopFilterResponseBlock)responseBlock {
    self.responseBlock = responseBlock;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.selectionDataList.count==0) return 0;
    return [self.selectionDataList[self.currentMainIdx] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *indet = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:indet forIndexPath:indexPath];
    NSDictionary *detail = [self.selectionDataList[self.currentMainIdx] objectAtIndex:indexPath.row];
    cell.textLabel.textColor = cell.selected?[UIColor colorWithRed:0.286 green:0.780 blue:0.961 alpha:1.00]:
                                             [UIColor colorWithRed:0.196 green:0.196 blue:0.196 alpha:1.00];
    cell.textLabel.font = [cell.textLabel.font fontWithSize:13];
    cell.textLabel.text = detail[kName];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView cellForRowAtIndexPath:self.selectedList[self.currentMainIdx]].textLabel.textColor = [UIColor colorWithRed:0.196 green:0.196 blue:0.196 alpha:1.00];
    [tableView cellForRowAtIndexPath:indexPath].textLabel.textColor = [UIColor colorWithRed:0.286 green:0.780 blue:0.961 alpha:1.00];
    
    switch (self.currentMainIdx) {
        case 0:
            if (indexPath.row!=0) {
                self.shopTypeID = [[_selectionDataList[0] objectAtIndex:indexPath.row] objectForKey:kID];
            }else {
                self.shopTypeID = @"";
            }
            self.shopTypeLabel.text = [[_selectionDataList[0] objectAtIndex:indexPath.row] objectForKey:kName];
            break;
        case 1:
            if (indexPath.row!=0) {
                self.shopServiceTypeID = [[_selectionDataList[1] objectAtIndex:indexPath.row] objectForKey:kID];
            }else {
                self.shopServiceTypeID = @"";
            }
            self.serviceTypeLabel.text = [[_selectionDataList[1] objectAtIndex:indexPath.row] objectForKey:kName];
            break;
        case 2:
            self.isValid = @(indexPath.row);
            self.certLabel.text = [[_selectionDataList[2] objectAtIndex:indexPath.row] objectForKey:kName];
            break;
            
        default:
            break;
    }
    [self.selectedList replaceObjectAtIndex:self.currentMainIdx withObject:indexPath];
    [self unfoldingFilterView];
    if (self.responseBlock) {
        self.responseBlock ();
    }
    
}


@end
