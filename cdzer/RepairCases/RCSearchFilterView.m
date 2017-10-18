//
//  RCSearchFilterView.m
//  cdzer
//
//  Created by KEns0n on 3/9/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//
#define vStandardWidth 320.0f*vWidthRatio
#define vStandardHeight 40.0f*vWidthRatio
#define vStartOffsetX 26.0f*vWidthRatio
#define vBtnTag 880
#import "RCSearchFilterView.h"

@interface RCSearchFilterView () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign) UIButton *maskBtnView;

@property (nonatomic, assign) NSInteger currentSelection;

@property (nonatomic, assign) BOOL isSelect;

@property (nonatomic, strong) UIView *btnsSuperView;

@property (nonatomic, strong) UITableView *selectionTableView;

@property (nonatomic, strong) NSArray *selectionList;

@property (nonatomic, copy) RCSearchFilterBlock responseBlock;

@end

@implementation RCSearchFilterView

- (instancetype)initWithOrigin:(CGPoint)origin {
    
    self = [super initWithFrame:CGRectMake(origin.x, origin.y, vStandardWidth, vStandardHeight)];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        [self setClipsToBounds:YES];
    }
    return self;
}

- (void)initializationUIWithMaskView:(UIButton *)maskBtnView {
    @autoreleasepool {
        if (maskBtnView) {
            [self setMaskBtnView:maskBtnView];
            [_maskBtnView addTarget:self action:@selector(btnsResponeAction:) forControlEvents:UIControlEventTouchUpInside];
        }
        [self setCurrentSelection:-1];
        
        NSArray *titleArray = @[@"price_order_by_default"];
        
        self.selectedList = [NSMutableArray array];
        for (int i=0; i<titleArray.count; i++) {
            [_selectedList addObject:[NSIndexPath indexPathForRow:0 inSection:0]];
        }
        
        [self setSelectionList:@[@[getLocalizationString(@"price_order_by_default"),
                                   getLocalizationString(@"price_order_by_descent"),
                                   getLocalizationString(@"price_order_by_ascent")]]];
        CGFloat averageWidth = CGRectGetWidth(self.frame)/[titleArray count];
        
        [self setBtnsSuperView:[[UIView alloc] initWithFrame:self.bounds]];
        [_btnsSuperView setBackgroundColor:[UIColor colorWithRed:0.941f green:0.941f blue:0.941f alpha:1.00f]];
        [_btnsSuperView setBorderWithColor:[UIColor lightGrayColor] borderWidth:(0.5f)];
        [self addSubview:_btnsSuperView];
        
        for (int i = 0; i < [titleArray count]; i++) {
            UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setTitle:getLocalizationString(titleArray[i]) forState:UIControlStateNormal];
            [btn setTitle:getLocalizationString(titleArray[i]) forState:UIControlStateSelected];
            [btn setTitleColor:CDZColorOfDefaultColor forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor colorWithRed:0.988f green:0.424f blue:0.129f alpha:1.00f] forState:UIControlStateSelected];
            [btn.titleLabel setFont:[UIFont systemFontOfSize:13.0f*vWidthRatio]];
            [btn setFrame:CGRectMake(i*averageWidth, 0.0f, averageWidth, CGRectGetHeight(self.frame))];
            [btn addTarget:self action:@selector(btnsResponeAction:) forControlEvents:UIControlEventTouchUpInside];
            [btn setTag:vBtnTag+i];
            [_btnsSuperView addSubview:btn];
        }
        for (int i = 0; i < ([titleArray count]-1); i++) {
            CGFloat height = CGRectGetHeight(self.frame)*0.6f;
            UIImageView *separateIV = [[UIImageView alloc] initWithFrame:CGRectMake(averageWidth*(i+1), CGRectGetHeight(self.frame)*0.2f, 1.0f, height)];
            [separateIV setBackgroundColor:[UIColor lightGrayColor]];
            [_btnsSuperView addSubview:separateIV];
        }
        
        CGRect selectionTVRect = CGRectZero;
        selectionTVRect.origin.y = CGRectGetHeight(self.frame);
        selectionTVRect.size = CGSizeMake(CGRectGetWidth(self.frame), 10.0f);
        [self setSelectionTableView:[[UITableView alloc] initWithFrame:selectionTVRect style:UITableViewStylePlain]];
        [_selectionTableView setBounces:NO];
        [_selectionTableView setScrollsToTop:YES];
        [self addSubview:_selectionTableView];
    }
}

- (void)handleButtonAnimation:(UIButton *)button {
    for (int i = 0; i<4; i++) {
        UIButton *btn = (UIButton *)[_btnsSuperView viewWithTag:vBtnTag+i];
        if (![button isEqual:btn]) {
            [btn setSelected:NO];
        }
    }
    BOOL isSeleted = YES;
    if (button.tag == _currentSelection+vBtnTag) {
        [self setCurrentSelection:-1];
        isSeleted = NO;
    }else{
        [self setCurrentSelection:button.tag-vBtnTag];
    }
    [button setSelected:isSeleted];
    [self setIsSelect:isSeleted];
}

- (void)selectionTVfolding:(UIButton *)button{
    BOOL isSeleted = button.selected;
    CGRect selectionTVRect = _selectionTableView.frame;

    if (isSeleted) {
        CGFloat containerHeight = 44.0f*[[_selectionList objectAtIndex:_currentSelection] count];
        if (containerHeight > 226.0f*vWidthRatio) containerHeight = 226.0f*vWidthRatio;
        CGRect containerRect = self.frame;
        [_selectionTableView setDelegate:self];
        [_selectionTableView setDataSource:self];
         NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        if (_currentSelection != -1) {
            indexPath = _selectedList[_currentSelection];
        }
        [_selectionTableView reloadData];
        [_selectionTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionTop];        [_selectionTableView setContentOffset:CGPointMake(0.0f, 0.0f)];
        containerRect.size.height = vStandardHeight + containerHeight;
        selectionTVRect.size.height = containerHeight;
        
        [UIView animateWithDuration:0.25f animations:^{
            [self.maskBtnView setAlpha:1];
            [self setFrame:containerRect];
            [self.selectionTableView setFrame:selectionTVRect];
        } completion:^(BOOL finished) {
            [self.selectionTableView flashScrollIndicators];
        }];
        
    }else{
        selectionTVRect.size.height = 10.0f;
        
        [UIView animateWithDuration:0.25f animations:^{
            [self.selectionTableView setFrame:selectionTVRect];
            [self.maskBtnView setAlpha:0];
            CGRect containerRect = self.frame;
            containerRect.size.height = vStandardHeight;
            [self setFrame:containerRect];
        } completion:^(BOOL finished) {
        }];
        
    }
}

- (void)unfoldingFilterView {
    if (_isSelect) {
        [self btnsResponeAction:_maskBtnView];
    }
}

- (void)btnsResponeAction:(UIButton *)button {
    if ([button isEqual:_maskBtnView]) {
        if (_currentSelection<0) _currentSelection = 0;
        button = (UIButton *)[_btnsSuperView viewWithTag:vBtnTag+_currentSelection];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"resignSearchBarFirstResponder" object:nil];
    [self handleButtonAnimation:button];
    [self selectionTVfolding:button];
}

- (void)setSelectionResponseBlock:(RCSearchFilterBlock)block {
    self.responseBlock = block;
}

#pragma -mark UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (_currentSelection<0) {
        return 0;
    }
    return [[_selectionList objectAtIndex:_currentSelection] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CDZKeyOfCellIdentKey];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CDZKeyOfCellIdentKey];
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
        [cell setBackgroundColor:CDZColorOfWhite];
        
    }
    NSString *text = [[_selectionList objectAtIndex:_currentSelection] objectAtIndex:indexPath.row];
    [cell.textLabel setText:text];
    // Configure the cell...
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 0.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return 0.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 44.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    [self btnsResponeAction:(UIButton *)[_btnsSuperView viewWithTag:vBtnTag+_currentSelection]];
    [_selectedList replaceObjectAtIndex:_currentSelection withObject:indexPath];
    [(UIButton *)[_btnsSuperView viewWithTag:vBtnTag+_currentSelection] setTitle:[_selectionList[_currentSelection]
                                                                   objectAtIndex:indexPath.row] forState:UIControlStateNormal];
    [(UIButton *)[_btnsSuperView viewWithTag:vBtnTag+_currentSelection] setTitle:[_selectionList[_currentSelection]
                                                                   objectAtIndex:indexPath.row] forState:UIControlStateSelected];
    [self unfoldingFilterView];
    if (_responseBlock) {
        self.responseBlock();
    }
}

@end


@interface autosPartsTypeObject : NSObject

@property (nonatomic, strong) NSArray *autoPartTop;


@end
