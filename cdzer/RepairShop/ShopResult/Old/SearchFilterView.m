//
//  SearchFilterView.m
//  cdzer
//
//  Created by KEns0n on 3/9/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#define kName @"name"
#define kID @"id"

#define vStandardWidth 320.0f*vWidthRatio
#define vStandardHeight 40.0f*vWidthRatio
#define vStartOffsetX 26.0f*vWidthRatio
#import "SearchFilterView.h"

@interface SearchFilterView () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign) UIButton *maskBtnView;

@property (nonatomic, assign) NSInteger currentSelection;

@property (nonatomic, assign) BOOL isSelect;

@property (nonatomic, strong) UIView *btnsSuperView;

@property (nonatomic, strong) UITableView *selectionTableView;

@property (nonatomic, strong) NSArray *selectionDataList;

@property (nonatomic, strong) NSMutableArray *selectedList;

@property (nonatomic, copy) FilterResponseBlock responseBlock;

@end

@implementation SearchFilterView

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (instancetype)initWithOrigin:(CGPoint)origin {
    if (origin.y>0.0f) {
        origin.y += (((IS_IPHONE_6||IS_IPHONE_6P)?vO2OSpaceSpace:vO2OSpaceSpace*0.5f)*vWidthRatio);
    }
    self = [super initWithFrame:CGRectMake(origin.x, origin.y, vStandardWidth, vStandardHeight)];
    if (self) {
        _isValid = @NO;
        _shopTypeID = @"";
        _shopServiceTypeID = @"";
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
        

        
        NSMutableArray *typeArray = [NSMutableArray arrayWithObject:@{kID:@"", kName:@"全部维修商类型"}];
        [typeArray addObjectsFromArray:DBHandler.shareInstance.getRepairShopTypeList];
        
        NSMutableArray *servicetypeArray = [NSMutableArray arrayWithObject:@{kID:@"", kName:@"全部服务项目"}];
        [servicetypeArray addObjectsFromArray:DBHandler.shareInstance.getRepairShopServiceTypeList];
        
        self.selectionDataList = @[typeArray,
                                   servicetypeArray,
                                   @[@{kName:getLocalizationString(@"non_authenticated")}, @{kName:getLocalizationString(@"was_authenticated")}]];
        
        NSMutableArray *titleArray = [@[@"全部维修商类型", @"全部服务项目", @"non_authenticated"] mutableCopy];
        self.selectedList = [NSMutableArray array];
        for (int i=0; i<titleArray.count; i++) {
            [_selectedList addObject:[NSIndexPath indexPathForRow:0 inSection:0]];
        }
        
        if (_shopTypeID&&![_shopTypeID isEqualToString:@""]) {
            @weakify(self)
            [(NSArray *)_selectionDataList[0] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                @strongify(self)
                if ([self.shopTypeID isEqualToString:obj[kID]]) {
                    *stop = YES;
                    [self.selectedList replaceObjectAtIndex:0 withObject:[NSIndexPath indexPathForRow:idx inSection:0]];
                    [titleArray replaceObjectAtIndex:0 withObject:obj[kName]];
                }
                
            }];
        }
        
        if (_shopServiceTypeID&&![_shopServiceTypeID isEqualToString:@""]) {
            @weakify(self)
            [(NSArray *)_selectionDataList[1] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                @strongify(self)
                if ([self.shopServiceTypeID isEqualToString:obj[kID]]) {
                    *stop = YES;
                    [self.selectedList replaceObjectAtIndex:1 withObject:[NSIndexPath indexPathForRow:idx inSection:0]];
                    [titleArray replaceObjectAtIndex:1 withObject:obj[kName]];
                }
                
            }];
        }
        

        
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
            [btn setTag:880+i];
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
        UIButton *btn = (UIButton *)[_btnsSuperView viewWithTag:880+i];
        if (![button isEqual:btn]) {
            [btn setSelected:NO];
        }
    }
    BOOL isSeleted = YES;
    if (button.tag == _currentSelection+880) {
        [self setCurrentSelection:-1];
        isSeleted = NO;
    }else{
        [self setCurrentSelection:button.tag-880];
    }
    [button setSelected:isSeleted];
    [self setIsSelect:isSeleted];
}

- (void)selectionTVfolding:(UIButton *)button{
    BOOL isSeleted = button.selected;
    CGRect selectionTVRect = _selectionTableView.frame;

    if (isSeleted) {
        CGFloat containerHeight = 44.0f*[[_selectionDataList objectAtIndex:_currentSelection] count];
        if (containerHeight > 226.0f*vWidthRatio) containerHeight = 226.0f*vWidthRatio;
        CGRect containerRect = self.frame;
        
        [_selectionTableView setDelegate:self];
        [_selectionTableView setDataSource:self];
         NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        if (_currentSelection != -1) {
            indexPath = _selectedList[_currentSelection];
        }
        [_selectionTableView reloadData];
        [_selectionTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionTop];
        [_selectionTableView setContentOffset:CGPointMake(0.0f, 0.0f)];
        
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
            
            [self.selectionTableView setDelegate:self];
            [self.selectionTableView setDataSource:self];
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
        button = (UIButton *)[_btnsSuperView viewWithTag:880+_currentSelection];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"resignSearchBarFirstResponder" object:nil];
    [self handleButtonAnimation:button];
    [self selectionTVfolding:button];
}

- (void)setSelectedResponseBlock:(FilterResponseBlock)responseBlock {
    self.responseBlock = responseBlock;
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
    return [[_selectionDataList objectAtIndex:_currentSelection] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ident = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ident];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ident];
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
        [cell setBackgroundColor:CDZColorOfWhite];
        
    }
    NSString *text = [[[_selectionDataList objectAtIndex:_currentSelection] objectAtIndex:indexPath.row] objectForKey:kName];
    [cell.textLabel setText:[text stringByReplacingOccurrencesOfString:@"\n" withString:@""]];
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
    
    switch (_currentSelection) {
        case 0:
            if (indexPath.row!=0) {
                self.shopTypeID = [[_selectionDataList[0] objectAtIndex:indexPath.row] objectForKey:kID];
            }else {
                self.shopTypeID = @"";
            }
            break;
        case 1:
            if (indexPath.row!=0) {
                self.shopServiceTypeID = [[_selectionDataList[1] objectAtIndex:indexPath.row] objectForKey:kID];
            }else {
                self.shopServiceTypeID = @"";
            }
            break;
        case 2:
            self.isValid = @(indexPath.row);
            break;
            
        default:
            break;
    }
    NSString *title = [[_selectionDataList[_currentSelection] objectAtIndex:indexPath.row] objectForKey:kName];
    UIButton *btn = (UIButton *)[_btnsSuperView viewWithTag:880+_currentSelection];
    [btn setTitle:getLocalizationString(title) forState:UIControlStateNormal];
    [btn setTitle:getLocalizationString(title) forState:UIControlStateSelected];
    [_selectedList replaceObjectAtIndex:_currentSelection withObject:indexPath];
    [self btnsResponeAction:_maskBtnView];
    if (self.responseBlock) {
        self.responseBlock();
    }
}

@end
