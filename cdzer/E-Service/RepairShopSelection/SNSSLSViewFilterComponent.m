//
//  SNSSLSViewFilterComponent.m
//  cdzer
//
//  Created by KEns0nLau on 8/10/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#define vMainTypeHeight 316.0f
#define vSubTypeHeight 165.0f
#import "SNSSLSViewFilterComponent.h"
#import "UserSelectedAutosInfoDTO.h"
#import "SNSSLViewFilterMainTypeCell.h"
#import "SNSSLViewFilterSubTypeCell.h"
#import "AutosBrandDTO.h"

@interface SNSSLSViewFilterView () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UIView *backgroundMaskView;//背景视图
@property (nonatomic, weak) IBOutlet UIControl *subTypeBtnControlView;//次选项按钮
@property (nonatomic, weak) IBOutlet UIView *filterBtnsContainerView;//按钮主视图




@property (nonatomic, weak) IBOutlet UITableView *subTypeTableView;//次选项TableView
@property (nonatomic, strong) NSArray <NSString *> *subTypeSelectionList;//次选项数据
@property (nonatomic, strong) NSIndexPath *subTypeCurrentSelection;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *subTypeTableViewHeightConstraint;



@property (nonatomic, strong) NSLayoutConstraint *bottomToSuperviewBottomConstraint;
@property (nonatomic, assign) BOOL wasFilterViewExpand;//选项是否打开
@property (nonatomic, assign) NSInteger lastSelectedBtnTag;//上次主次选项按钮的TagID
@property (nonatomic, strong) NSArray <NSString *> *keyArray;

@end

@implementation SNSSLSViewFilterView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.subTypeSelectionList = @[@"距离最近", @"好评优先", @"销量最高", @"价格最低", @"价格最高"];
    
    self.subTypeCurrentSelection = [NSIndexPath indexPathForRow:0 inSection:0];
    self.subTypeTableView.hidden = YES;
    self.subTypeTableViewHeightConstraint.constant = 0;
    self.subTypeTableView.rowHeight = 33;
    [self.subTypeTableView registerNib:[UINib nibWithNibName:@"SNSSLViewFilterSubTypeCell" bundle:nil]
                forCellReuseIdentifier:@"subTypeCell"];
    
    [self.subTypeTableView reloadData];
    [self.subTypeTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
    
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    UIColor *borderColor = [UIColor colorWithRed:0.839 green:0.843 blue:0.863 alpha:1.00];
    [self.filterBtnsContainerView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:borderColor withBroderOffset:nil];
    
    CGFloat height = CGRectGetHeight(self.superview.frame);
    CGFloat constant = (self.wasFilterViewExpand?0:(height-CGRectGetHeight(self.filterBtnsContainerView.frame)));
    self.bottomToSuperviewBottomConstraint.constant = constant;
    
}

- (IBAction)showFilterViewByBtns:(UIControl *)sender {
    BOOL isSubTypeBtn = (sender.tag==2);
    if (self.wasFilterViewExpand&&
        self.lastSelectedBtnTag==sender.tag) {
        self.lastSelectedBtnTag = -1;
        [self updateSubTypeStatus:NO];
        self.wasFilterViewExpand = NO;
    }else {
        self.lastSelectedBtnTag = sender.tag;
        [self updateSubTypeStatus:isSubTypeBtn];
        self.wasFilterViewExpand = YES;
    }
    if (self.wasFilterViewExpand) {
        [self showFilterView];
    }else {
        [self hideFilterView];
    }
}


- (void)updateSubTypeStatus:(BOOL)subTypeSelected {
    [self.subTypeBtnControlView.subviews.lastObject.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([obj isKindOfClass:UILabel.class]) {
            UILabel *label = (UILabel *)obj;
            NSString *title = self.subTypeSelectionList[self.subTypeCurrentSelection.row];
            label.text = title;
            label.highlighted = subTypeSelected;
        }
        if ([obj isKindOfClass:UIImageView.class]) [(UIImageView *)obj setHighlighted:subTypeSelected];
    }];
    
    CGFloat subTypeHeight = subTypeSelected?vSubTypeHeight:0;
    self.subTypeTableView.hidden = YES;
    if (subTypeSelected) {
        self.subTypeTableViewHeightConstraint.constant = subTypeHeight;
        self.subTypeTableView.hidden = NO;
    }
    
    @weakify(self);
    [UIView animateWithDuration:0.25 animations:^{
        @strongify(self);
        CGRect subTypeFrame = self.subTypeTableView.frame;
        subTypeFrame.size.height = subTypeHeight;
        self.subTypeTableView.frame = subTypeFrame;
        
    } completion:^(BOOL finished) {
        @strongify(self);
        if (!subTypeSelected) {
            self.subTypeTableView.hidden = YES;
            self.subTypeTableViewHeightConstraint.constant = subTypeHeight;
        }
    }];
}

- (void)showFilterView {
//    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
//    UIView *firstResponder = [keyWindow performSelector:@selector(firstResponder)];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
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
    return SNSSLVFilterTypeOfAll;
}

- (NSNumber *)subTypeFilterSequence {
    return @(self.subTypeCurrentSelection.row);
}

- (SNSSLVFItemBrandType)itemBrandType {
    return SNSSLVFItemBrandTypeOfNone;
}

- (NSString *)mainFilterSelectedID {
    return @"";
}

@end

