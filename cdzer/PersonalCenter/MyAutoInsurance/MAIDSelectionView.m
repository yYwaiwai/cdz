//
//  MAIDSelectionView.m
//  cdzer
//
//  Created by KEns0n on 10/20/15.
//  Copyright © 2015 CDZER. All rights reserved.
//

#import "MAIDSelectionView.h"
#import "InsetsLabel.h"

@interface MAIDSelectionViewCell : UITableViewCell

@end

@implementation MAIDSelectionViewCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.accessoryType = selected?UITableViewCellAccessoryCheckmark:UITableViewCellAccessoryNone;
}

@end

@interface MAIDSelectionView ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSString *title;

@property (nonatomic, strong) NSArray *dataList;

@property (nonatomic, strong) UIButton *cancelButton;

@property (nonatomic, strong) UIButton *confirmButton;

@property (nonatomic, assign) BOOL isShowButton;

@property (nonatomic, strong) UIView *buttonCView;

@property (nonatomic, strong) UIButton *buttonForBGCancel;

@property (nonatomic, copy) MAIDSelectionViewResponseBlock responseBlock;

@end

@implementation MAIDSelectionView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)init {
    CGRect frame = UIScreen.mainScreen.bounds;
    self = [self initWithFrame:frame];
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    frame = UIScreen.mainScreen.bounds;
    self = [super initWithFrame:frame];
    if (self) {
        self.dataList = @[];
        [self initializationUI];
    }
    return self;
}

- (void)setTitle:(NSString *)title withDataList:(NSArray *)dataList andWasShowButton:(BOOL)isShowButton responseBlock:(MAIDSelectionViewResponseBlock)responseBlock {
    self.title = title;
    self.dataList = dataList;
    self.isShowButton = isShowButton;
    
    self.tableView.tableFooterView = nil;
    self.buttonForBGCancel.hidden = YES;
//    self.buttonForBGCancel.hidden = NO;
    if (self.isShowButton) {
        self.tableView.tableFooterView = _buttonCView;
    }
    
    self.responseBlock = NULL;
    if (responseBlock) {
        self.responseBlock = responseBlock;
    }
    
    if (self.tableView) {
        [self.tableView reloadData];
    }

    if (self.currentSelectionID<=(dataList.count-1)&&self.currentSelectionID>=0) {
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:self.currentSelectionID inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    if (dataList.count>0) {
        [self showSelectionView];
    }
    
}

- (void)showSelectionView {
    if (!_title||!_dataList||_dataList.count==0) {
        return;
    }
    @weakify(self);
    [UIApplication.sharedApplication.keyWindow addSubview:self];
    [UIView animateWithDuration:0.25 animations:^{
        @strongify(self);
        self.alpha = 1;
    }];
}

- (void)hiddenSelectionView {
    @weakify(self);
    [UIView animateWithDuration:0.25 animations:^{
        @strongify(self);
        self.alpha = 0;
    }completion:^(BOOL finished) {
        @strongify(self);
        [self removeFromSuperview];
    }];
}

- (void)initializationUI {
    
//    self.currentSelectionID =-1;
    
    self.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.7f];
    self.alpha = 0.0f;
    self.buttonForBGCancel = [UIButton buttonWithType:UIButtonTypeCustom];
    _buttonForBGCancel.frame = self.bounds;
    _buttonForBGCancel.hidden = YES;
    [_buttonForBGCancel addTarget:self action:@selector(hiddenSelectionView) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_buttonForBGCancel];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.frame)*0.8f, CGRectGetHeight(self.frame)*0.7f)];
    _tableView.center = CGPointMake(CGRectGetWidth(self.frame)/2.0f, CGRectGetHeight(self.frame)/2.0f);
    _tableView.bounces = NO;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.allowsMultipleSelection = NO;
    _tableView.allowsSelection = YES;
    [self addSubview:_tableView];
    
    
    @weakify(self);
    [RACObserve(self, tableView.contentSize) subscribeNext:^(id contentSize) {
        @strongify(self);
        CGRect frame = self.tableView.frame;
        frame.size.height = [contentSize CGSizeValue].height;
        if (CGRectGetHeight(frame)>CGRectGetHeight(self.frame)*0.8f) {
            frame.size.height = CGRectGetHeight(self.frame)*0.8f;
        }
        self.tableView.frame = frame;
        self.tableView.center = CGPointMake(CGRectGetWidth(self.frame)/2.0f, CGRectGetHeight(self.frame)/2.0f);
    }];
    
    self.buttonCView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(_tableView.frame), 36.0f)];
    _buttonCView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _buttonCView.translatesAutoresizingMaskIntoConstraints = YES;
    [_buttonCView setViewBorderWithRectBorder:UIRectBorderTop borderSize:1.0f withColor:CDZColorOfSeperateLineDeepColor withBroderOffset:nil];
    
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _cancelButton.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(_buttonCView.frame)/2.0f, CGRectGetHeight(_buttonCView.frame));
    _cancelButton.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleRightMargin;
    _cancelButton.translatesAutoresizingMaskIntoConstraints = YES;
    [_cancelButton setTitle:getLocalizationString(@"cancel") forState:UIControlStateNormal];
    [_cancelButton setTitleColor:CDZColorOfDeepGray forState:UIControlStateNormal];
    [_cancelButton addTarget:self action:@selector(buttonEventsResponse:) forControlEvents:UIControlEventTouchUpInside];
    [_cancelButton setViewBorderWithRectBorder:UIRectBorderRight borderSize:0.5f withColor:CDZColorOfSeperateLineDeepColor withBroderOffset:nil];
    [_buttonCView addSubview:_cancelButton];
    
    self.confirmButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _confirmButton.frame = CGRectMake(CGRectGetWidth(_buttonCView.frame)/2.0f, 0.0f, CGRectGetWidth(_buttonCView.frame)/2.0f, CGRectGetHeight(_buttonCView.frame));
    _confirmButton.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin;
    _confirmButton.translatesAutoresizingMaskIntoConstraints = YES;
    [_confirmButton setTitle:getLocalizationString(@"ok") forState:UIControlStateNormal];
    [_confirmButton setTitleColor:CDZColorOfDefaultColor forState:UIControlStateNormal];
    [_confirmButton addTarget:self action:@selector(buttonEventsResponse:) forControlEvents:UIControlEventTouchUpInside];
    [_confirmButton setViewBorderWithRectBorder:UIRectBorderLeft borderSize:0.5f withColor:CDZColorOfSeperateLineDeepColor withBroderOffset:nil];
    [_buttonCView addSubview:_confirmButton];
    
    
}

#pragma -mark UITableViewDelgate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return _dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MAIDSelectionViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CDZKeyOfCellIdentKey];
    if (!cell) {
        cell = [[MAIDSelectionViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CDZKeyOfCellIdentKey];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.detailTextLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 15.0f, NO);
        cell.detailTextLabel.textColor = CDZColorOfBlack;
        cell.detailTextLabel.numberOfLines = 0;
    }
    // Configure the cell...
    cell.detailTextLabel.text = _dataList[indexPath.row];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    static NSString *headerIdentifier = @"header";
    UITableViewHeaderFooterView *myHeader = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerIdentifier];
    if(!myHeader) {
        myHeader = [[UITableViewHeaderFooterView alloc]initWithReuseIdentifier:headerIdentifier];
        InsetsLabel *titleLabel = [[InsetsLabel alloc] initWithFrame:CGRectZero
                                                  andEdgeInsetsValue:DefaultEdgeInsets];
        titleLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfBold, 17.5f, NO);
        titleLabel.backgroundColor = CDZColorOfBlack;
        titleLabel.textColor = CDZColorOfWhite;
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.tag = 10;
        titleLabel.translatesAutoresizingMaskIntoConstraints = YES;
        titleLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        [myHeader addSubview:titleLabel];
        
        [myHeader setNeedsUpdateConstraints];
        [myHeader updateConstraintsIfNeeded];
        [myHeader setNeedsLayout];
        [myHeader layoutIfNeeded];
    }
    InsetsLabel *titleLabel = (InsetsLabel *)[myHeader viewWithTag:10];
    titleLabel.text = _title;
    return myHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.currentSelectionID = indexPath.row;
    if (!_isShowButton) {
        if (_responseBlock) {
            self.responseBlock(YES, _currentSelectionID);
        }
        [self hiddenSelectionView];
    }
}

- (void)buttonEventsResponse:(UIButton *)button {
    BOOL isConfirm = NO;
//    if(button==_confirmButton&&(_currentSelectionID<0||_currentSelectionID>_dataList.count-1))
    if (button==_confirmButton) isConfirm = YES;
    
    if (_responseBlock) {
        if (!self.tableView.indexPathForSelectedRow&&isConfirm&&_currentSelectionID==-1) {
            [SupportingClass showAlertViewWithTitle:nil message:_title isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:nil];
            return;
        }
        self.responseBlock(isConfirm, _currentSelectionID);
        [self hiddenSelectionView];
    }
}

@end
