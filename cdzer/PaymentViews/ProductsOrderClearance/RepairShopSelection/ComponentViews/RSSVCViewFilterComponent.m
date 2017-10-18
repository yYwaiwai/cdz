//
//  RSSVCViewFilterComponent.m
//  cdzer
//
//  Created by KEns0n on 24/10/2016.
//  Copyright © 2016 CDZER. All rights reserved.
//
#define vMainTypeHeight 200.0f
#define vSubTypeHeight 165.0f
#import "RSSVCViewFilterComponent.h"
#import "SNSSLViewFilterSubTypeCell.h"

@interface RSSVCViewFilterComponent () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, weak) IBOutlet UIView *backgroundMaskView;//背景视图
@property (nonatomic, weak) IBOutlet UIControl *mainTypeBtnControlView;//主选项按钮
@property (nonatomic, weak) IBOutlet UIControl *subTypeBtnControlView;//次选项按钮
@property (nonatomic, weak) IBOutlet UIView *filterBtnsContainerView;//按钮主视图

@property (nonatomic, weak) IBOutlet UIView *mainTypeContainerView;//主选项主视图
@property (nonatomic, weak) IBOutlet UIControl *mainTypeOfAllBtnControlView;//主选项全部按钮
@property (nonatomic, weak) IBOutlet UIControl *mainTypeOfBrandBtnControlView;//主选项品牌店按钮
@property (nonatomic, weak) IBOutlet UIControl *mainTypeOfSpcRepairBtnControlView;//主选项专修店按钮
@property (nonatomic, weak) IBOutlet UIView *mainTypeBtnsContainerView;//主选项按钮主视图
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *mainTypeContainerViewHeightConstraint;
@property (nonatomic, assign) SNSSLVFilterType mainTypeCurrentSelection;

@property (nonatomic, weak) IBOutlet UITableView *subTypeTableView;//次选项TableView
@property (nonatomic, strong) NSArray <NSString *> *subTypeSelectionList;//次选项数据
@property (nonatomic, strong) NSIndexPath *subTypeCurrentSelection;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *subTypeTableViewHeightConstraint;

@property (nonatomic, strong) NSLayoutConstraint *bottomToSuperviewBottomConstraint;
@property (nonatomic, assign) BOOL wasFilterViewExpand;//选项是否打开
@property (nonatomic, assign) NSInteger lastSelectedBtnTag;//上次主次选项按钮的TagID
@property (nonatomic, strong) NSArray <NSString *> *keyArray;


@end

@implementation RSSVCViewFilterComponent

- (void)awakeFromNib {
    [super awakeFromNib];
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.subTypeSelectionList = @[@"距离最近", @"好评优先", @"销量最高", @"价格最低", @"价格最高"];
    //    self.subTypeSelectionList = @[@"距离最近", @"好评优先", @"销量最高", @"工时最低", @"工时最高"];
    self.mainTypeCurrentSelection = SNSSLVFilterTypeOfAll;
    self.mainTypeContainerView.hidden = YES;
    self.mainTypeContainerViewHeightConstraint.constant = 0;
    [self.mainTypeBtnsContainerView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull view, NSUInteger idx, BOOL * _Nonnull stop) {
        BOOL selected = (view.tag==1);
        view.backgroundColor = selected?CDZColorOfWhite:CDZColorOfClearColor;
        [(UIImageView *)[view viewWithTag:4] setHighlighted:selected];
        [(UILabel *)[view viewWithTag:5] setHighlighted:selected];
        UIColor *borderColor = [UIColor colorWithRed:0.839 green:0.843 blue:0.863 alpha:1.00];
        
        UIRectBorder borderOption = selected?(view.tag==1?UIRectBorderBottom:(UIRectBorderTop|UIRectBorderBottom)):UIRectBorderRight;
        [view setViewBorderWithRectBorder:borderOption borderSize:0.5 withColor:borderColor withBroderOffset:nil];
    }];
    
    self.subTypeTableViewHeightConstraint.constant = 0;
    self.subTypeCurrentSelection = [NSIndexPath indexPathForRow:0 inSection:0];
    self.subTypeTableView.hidden = YES;
    self.subTypeTableView.rowHeight = 33;
    [self.subTypeTableView registerNib:[UINib nibWithNibName:@"SNSSLViewFilterSubTypeCell" bundle:nil]
                forCellReuseIdentifier:@"subTypeCell"];
    
    [self.subTypeTableView reloadData];
    [self.subTypeTableView selectRowAtIndexPath:self.subTypeCurrentSelection animated:NO scrollPosition:UITableViewScrollPositionNone];
    

}

- (void)layoutSubviews {
    [super layoutSubviews];
    UIColor *borderColor = [UIColor colorWithRed:0.839 green:0.843 blue:0.863 alpha:1.00];
    BorderOffsetObject *offset = [BorderOffsetObject new];
    offset.leftUpperOffset = 10;
    offset.leftBottomOffset = 10;
    offset.rightUpperOffset = 10;
    offset.rightBottomOffset = 10;
    [self.mainTypeBtnControlView setViewBorderWithRectBorder:UIRectBorderRight borderSize:0.5 withColor:borderColor withBroderOffset:offset];
    [self.filterBtnsContainerView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:borderColor withBroderOffset:nil];
    
    CGFloat height = CGRectGetHeight(self.superview.frame);
    CGFloat constant = (self.wasFilterViewExpand?0:(height-CGRectGetHeight(self.filterBtnsContainerView.frame)));
    self.bottomToSuperviewBottomConstraint.constant = constant;
    
    
    
    if (self.mainTypeCurrentSelection==1) {
        [self.mainTypeOfAllBtnControlView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
        [self.mainTypeOfBrandBtnControlView setViewBorderWithRectBorder:UIRectBorderRight borderSize:0.5 withColor:nil withBroderOffset:nil];
        [self.mainTypeOfSpcRepairBtnControlView setViewBorderWithRectBorder:UIRectBorderRight borderSize:0.5 withColor:nil withBroderOffset:nil];
        
    }else if (self.mainTypeCurrentSelection==2) {
        [self.mainTypeOfAllBtnControlView setViewBorderWithRectBorder:UIRectBorderRight borderSize:0.5 withColor:nil withBroderOffset:nil];
        [self.mainTypeOfBrandBtnControlView setViewBorderWithRectBorder:UIRectBorderBottom|UIRectBorderTop borderSize:0.5 withColor:nil withBroderOffset:nil];
        [self.mainTypeOfSpcRepairBtnControlView setViewBorderWithRectBorder:UIRectBorderRight borderSize:0.5 withColor:nil withBroderOffset:nil];
    }else if (self.mainTypeCurrentSelection==3) {
        
        [self.mainTypeOfAllBtnControlView setViewBorderWithRectBorder:UIRectBorderRight borderSize:0.5 withColor:nil withBroderOffset:nil];
        [self.mainTypeOfBrandBtnControlView setViewBorderWithRectBorder:UIRectBorderRight borderSize:0.5 withColor:nil withBroderOffset:nil];
        [self.mainTypeOfSpcRepairBtnControlView setViewBorderWithRectBorder:UIRectBorderBottom|UIRectBorderTop borderSize:0.5 withColor:nil withBroderOffset:nil];
    }
}

- (IBAction)showFilterViewByBtns:(UIControl *)sender {
    BOOL isMainTypeBtn = (sender.tag==1);
    BOOL isSubTypeBtn = (sender.tag==2);
    if (self.wasFilterViewExpand&&
        self.lastSelectedBtnTag==sender.tag) {
        self.lastSelectedBtnTag = -1;
        [self updateMainTypeStatus:NO andSubTypeStatus:NO ];
        self.wasFilterViewExpand = NO;
    }else {
        self.lastSelectedBtnTag = sender.tag;
        [self updateMainTypeStatus:isMainTypeBtn andSubTypeStatus:isSubTypeBtn];
        self.wasFilterViewExpand = YES;
    }
    if (self.wasFilterViewExpand) {
        [self showFilterView];
    }else {
        [self hideFilterView];
    }
}

- (void)updateMainTypeStatus:(BOOL)mainTypeSelected andSubTypeStatus:(BOOL)subTypeSelected {
    [self.mainTypeBtnControlView.subviews.lastObject.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([obj isKindOfClass:UILabel.class]) {
            UILabel *label = (UILabel *)obj;
            NSString *title = @"全部类型";
            if (self.mainTypeCurrentSelection==SNSSLVFilterTypeOfBrandOption) {
                title = @"品牌店";
            }else if(self.mainTypeCurrentSelection==SNSSLVFilterTypeOfSpecRepairOption) {
                title = @"专修店";
            }
            label.text = title;
            label.highlighted = mainTypeSelected;
        }
        if ([obj isKindOfClass:UIImageView.class]) [(UIImageView *)obj setHighlighted:mainTypeSelected];
    }];
    
    [self.subTypeBtnControlView.subviews.lastObject.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([obj isKindOfClass:UILabel.class]) {
            UILabel *label = (UILabel *)obj;
            NSString *title = self.subTypeSelectionList[self.subTypeCurrentSelection.row];
            label.text = title;
            label.highlighted = subTypeSelected;
        }
        if ([obj isKindOfClass:UIImageView.class]) [(UIImageView *)obj setHighlighted:subTypeSelected];
    }];
    
    CGFloat mainTypeHeight = mainTypeSelected?vMainTypeHeight:0;
    CGFloat subTypeHeight = subTypeSelected?vSubTypeHeight:0;
    if (mainTypeSelected) {
        self.mainTypeContainerViewHeightConstraint.constant = mainTypeHeight;
        self.mainTypeContainerView.hidden = NO;
        self.subTypeTableView.hidden = YES;
    }
    if (subTypeSelected) {
        self.subTypeTableViewHeightConstraint.constant = subTypeHeight;
        self.subTypeTableView.hidden = NO;
        self.mainTypeContainerView.hidden = YES;
    }
    
    @weakify(self);
    [UIView animateWithDuration:0.25 animations:^{
        @strongify(self);
        CGRect mainTypeFrame = self.mainTypeContainerView.frame;
        mainTypeFrame.size.height = mainTypeHeight;
        self.mainTypeContainerView.frame = mainTypeFrame;
        
        CGRect subTypeFrame = self.subTypeTableView.frame;
        subTypeFrame.size.height = subTypeHeight;
        self.subTypeTableView.frame = subTypeFrame;
        
    } completion:^(BOOL finished) {
        @strongify(self);
        if (!mainTypeSelected) {
            self.mainTypeContainerView.hidden = YES;
            self.mainTypeContainerViewHeightConstraint.constant = mainTypeHeight;
        }
        if (!subTypeSelected) {
            self.subTypeTableView.hidden = YES;
            self.subTypeTableViewHeightConstraint.constant = subTypeHeight;
        }
        

    }];
}

- (void)showFilterView {
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    self.filterBtnsContainerView.userInteractionEnabled = NO;
    self.bottomToSuperviewBottomConstraint.constant = 0;
    CGRect frame = self.frame;
    frame.size.height = CGRectGetHeight(self.superview.frame);
    self.frame = frame;
    
    @weakify(self);
    [UIView animateWithDuration:0.25 animations:^{
        @strongify(self);
        if (self.lastSelectedBtnTag==3) {
            self.backgroundMaskView.alpha = 0;
        }else {
            self.backgroundMaskView.alpha = self.wasFilterViewExpand;
        }
    } completion:^(BOOL finished) {
        self.filterBtnsContainerView.userInteractionEnabled = YES;
    }];
    
}

- (void)hideFilterView {
    self.filterBtnsContainerView.userInteractionEnabled = NO;
    @weakify(self);
    [UIView animateWithDuration:0.25 animations:^{
        @strongify(self);
        self.backgroundMaskView.alpha = self.wasFilterViewExpand;
    } completion:^(BOOL finished) {
        @strongify(self);
        CGRect frame = self.frame;
        frame.size.height = CGRectGetHeight(self.filterBtnsContainerView.frame);
        self.frame = frame;
        
        CGFloat constant = CGRectGetHeight(self.superview.frame)-CGRectGetHeight(self.filterBtnsContainerView.frame);
        self.bottomToSuperviewBottomConstraint.constant = constant;
        self.filterBtnsContainerView.userInteractionEnabled = YES;
    }];
    
}

- (void)updateMainTypeUIStatus:(UIControl *)sender {
    [self.mainTypeBtnsContainerView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull view, NSUInteger idx, BOOL * _Nonnull stop) {
        BOOL selected = (sender==view);
        view.backgroundColor = selected?CDZColorOfWhite:CDZColorOfClearColor;
        [(UIImageView *)[view viewWithTag:4] setHighlighted:selected];
        [(UILabel *)[view viewWithTag:5] setHighlighted:selected];
        UIColor *borderColor = [UIColor colorWithRed:0.839 green:0.843 blue:0.863 alpha:1.00];
        
        UIRectBorder borderOption = selected?(sender.tag==1?UIRectBorderBottom:(UIRectBorderTop|UIRectBorderBottom)):UIRectBorderRight;
        [view setViewBorderWithRectBorder:borderOption borderSize:0.5 withColor:borderColor withBroderOffset:nil];
    }];
}

- (IBAction)changeMainTypeSelection:(UIControl *)sender {
    [self updateMainTypeUIStatus:sender];
    self.mainTypeCurrentSelection = sender.tag;
    [self.subTypeTableView reloadData];
    self.subTypeCurrentSelection = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.subTypeTableView selectRowAtIndexPath:self.subTypeCurrentSelection animated:NO scrollPosition:UITableViewScrollPositionNone];
    [self showFilterViewByBtns:self.mainTypeBtnControlView];

    if (self.resultBlock) {
        self.resultBlock();
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.subTypeSelectionList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ident = @"subTypeCell";
    SNSSLViewFilterSubTypeCell *cell = [tableView dequeueReusableCellWithIdentifier:ident forIndexPath:indexPath];
    // Configure the cell...
    cell.indexPath = indexPath;
    cell.textLabel.text = self.subTypeSelectionList[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.subTypeCurrentSelection = indexPath;
    [self showFilterViewByBtns:self.subTypeBtnControlView];
    if (self.resultBlock) {
        self.resultBlock();
    }
}

- (NSMutableArray <NSLayoutConstraint *> *)addSelfByFourMarginToSuperview:(UIView *)superview {
    NSMutableArray <NSLayoutConstraint *> *constraintsList = [super addSelfByFourMarginToSuperview:superview];
    @weakify(self);
    [constraintsList enumerateObjectsUsingBlock:^(NSLayoutConstraint * _Nonnull constraint, NSUInteger idx, BOOL * _Nonnull stop) {
        @strongify(self);
        if (constraint.firstAttribute==NSLayoutAttributeBottom&&
            constraint.secondAttribute==NSLayoutAttributeBottom) {
            self.bottomToSuperviewBottomConstraint = constraint;
        }
    }];
    return constraintsList;
}

- (SNSSLVFilterType)currentFilterTypeIdx {
    return self.mainTypeCurrentSelection;
}

- (NSNumber *)subTypeFilterSequence {
    return @(self.subTypeCurrentSelection.row);
}

@end
