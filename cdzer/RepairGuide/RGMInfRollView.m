//
//  RGMInfRollView.m
//  cdzer
//
//  Created by KEns0n on 2/26/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#import "RGMInfRollView.h"
#import "NSTimer+Addition.h"
#import "APIActionConversionTable.h"
#import "InsetsLabel.h"

@interface RGMInfRollViewCell : UITableViewCell

@end

@implementation RGMInfRollViewCell

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize size = CGSizeMake(1.0f, 1.0f);
    if (self.imageView.image) {
        size = self.imageView.image.size;
    }

    CGRect rect = self.imageView.frame;
    rect.size.height = 150.f;
    rect.size.width = roundf(size.width*CGRectGetHeight(rect)/size.height);
    rect.origin.y = CGRectGetHeight(self.frame)-CGRectGetHeight(rect);
    self.imageView.frame = rect;
    
    CGPoint ivCenter = self.imageView.center;
    ivCenter.x = CGRectGetWidth(self.frame)/2.0f;
    self.imageView.center = ivCenter;
    
    self.imageView.autoresizingMask = UIViewAutoresizingNone;
    
}

@end

@interface RGMInfRollView () <UITableViewDataSource, UITableViewDelegate>
{
    NSTimeInterval _animationDuration;
}
@property (nonatomic, strong) UIView *reminderView;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIPageControl *pageControl;

@property (nonatomic, strong) NSMutableArray *dataList;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) UIActivityIndicatorView *loadingIndicatorView;

@property (nonatomic, strong) InsetsLabel *titlLabel;

@property (nonatomic, copy) RGMInfRollViewSelectionResponseBlock responseBlock;

@end

@implementation RGMInfRollView

- (void)removeTheTimer {
    if (_timer&&[_timer isValid]){
        [_timer invalidate];
    }
    _timer = nil;
}

- (void)setAnimationDuration:(NSTimeInterval)newDuration {
    _animationDuration = newDuration;
    if (([_dataList count]>1)){
        [self removeTheTimer];
        _timer = [NSTimer scheduledTimerWithTimeInterval:_animationDuration
                                                  target:self
                                                selector:@selector(tableViewAutomaticScroll)
                                                userInfo:nil
                                                 repeats:YES];
    }
}

- (void)setSelectionResponseBlock:(RGMInfRollViewSelectionResponseBlock)responseBlock {
    self.responseBlock = nil;
    self.responseBlock = responseBlock;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        if (!_dataList) {
            //initialize AnimationDuration
            if (_animationDuration <= 0.0000f) _animationDuration = 3.5f;
            self.dataList = [NSMutableArray new];
            [self initializationUI];
        }
    }
    return self;
}

- (void)initializationUI {
    @autoreleasepool {
        self.backgroundColor = CDZColorOfBlack;
           //首界面的所有btn和广告的pageControl
        if (!_tableView) {
            CGRect frame = self.bounds;
            frame.size.height -= 16.0f;
            UITableView *tableView = [[UITableView alloc] initWithFrame:frame];
            [tableView setTransform:CGAffineTransformMakeRotation(-M_PI_2)];
            [tableView setFrame:frame];
            [tableView setBounces:NO];
            [tableView setShowsHorizontalScrollIndicator:NO];
            [tableView setShowsVerticalScrollIndicator:NO];
            [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
            [tableView setRowHeight:CGRectGetWidth(self.bounds)];
            [tableView setDelegate:self];
            [tableView setPagingEnabled:YES];
            [tableView setDataSource:self];
            [tableView setContentOffset:CGPointMake(0.0f, CGRectGetWidth(self.bounds))];
            tableView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
            [self setTableView:tableView];
            [self addSubview:tableView];
            tableView = nil;
        }
        
        if (!_titlLabel) {
            CGRect frame = self.bounds;
            frame.origin.y = CGRectGetMaxY(_tableView.frame);
            frame.size.height = 16.0f;
            self.titlLabel = [[InsetsLabel alloc] initWithFrame:frame andEdgeInsetsValue:DefaultEdgeInsets];
            _titlLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
            _titlLabel.textAlignment = NSTextAlignmentCenter;
            _titlLabel.textColor = CDZColorOfWhite;
            [self addSubview:_titlLabel];
        }
        
        if (!_pageControl) {
            CGRect pcRect = self.bounds;
            pcRect.size.height = 26.0f*vWidthRatio+CGRectGetHeight(_titlLabel.frame);
            pcRect.origin = CGPointMake(0.0f, CGRectGetHeight(self.bounds)-CGRectGetHeight(pcRect));
            UIPageControl *pageControl = [[UIPageControl alloc] initWithFrame:pcRect];
            [pageControl setUserInteractionEnabled:NO];
            [pageControl setPageIndicatorTintColor:[UIColor colorWithRed:0.824f green:0.827f blue:0.827f alpha:1.00f]];
            [pageControl setCurrentPageIndicatorTintColor:CDZColorOfDefaultColor];
            pageControl.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
            [self setPageControl:pageControl];
            [self addSubview:pageControl];
            pageControl = nil;
        }
        //UIActivityIndicatorView  转圈
        self.loadingIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _loadingIndicatorView.color = CDZColorOfBlack;
        _loadingIndicatorView.center = CGPointMake(CGRectGetWidth(self.frame)/2.0f, CGRectGetHeight(self.frame)/2.0f);
        _loadingIndicatorView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        //hidesWhenStopped  当停止动画的时候，是否隐藏。默认为YES。
        _loadingIndicatorView.hidesWhenStopped = NO;
        _loadingIndicatorView.hidden = YES;
        [_loadingIndicatorView startAnimating];
        [self addSubview:_loadingIndicatorView];
    }
}

- (void)viewWillDisappear {
    if (_timer&&[_dataList count] > 1) [_timer pauseTimer];
    _loadingIndicatorView.hidden = YES;
}

- (void)viewWillAppearWithData:(NSArray *)list {
    if (!_dataList) {
        self.dataList = [NSMutableArray array];
    }
    [self setupScrollDataList:list];
    if ([_dataList count] > 1) {
        _loadingIndicatorView.hidden = YES;
        if (!_timer) {
            [self startPlay];
        }else {
            [_timer resumeTimerAfterTimeInterval:_animationDuration];
        }
    }else {
        _loadingIndicatorView.hidden = NO;
    }
}

- (void)startPlay {
    if ([_dataList count] >1) {
        NSInteger numberOfPages = ([_dataList count] == 1)?1:[_dataList count]-2;
        [_pageControl setNumberOfPages:numberOfPages];
        [_pageControl setCurrentPage:0];
        [_tableView reloadData];
        [self removeTheTimer];
        _timer = [NSTimer scheduledTimerWithTimeInterval:_animationDuration
                                                  target:self
                                                selector:@selector(tableViewAutomaticScroll)
                                                userInfo:nil
                                                 repeats:YES];
    }
}

- (void)setupScrollDataList:(NSArray *)dataList {
    @autoreleasepool {
        
        [_dataList removeAllObjects];
        if (!dataList || [dataList count] != 0) {
            if ([dataList count]==1) {
                [_dataList addObjectsFromArray:dataList];
                self.titlLabel.text = [_dataList[0] objectForKey:@"name"];
            }else{
                [_dataList addObject:[dataList objectAtIndex:[dataList count]-1]];
                [_dataList addObjectsFromArray:dataList];
                [_dataList addObject:[dataList objectAtIndex:0]];
                self.titlLabel.text = [_dataList[1] objectForKey:@"name"];
            }
        }
        [self.tableView reloadData];
        if (_dataList.count>1) {
            //滑动到某一行，UITableViewScrollPosition代表想要这一行显示在当前TableView中的位置
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:NO];
        }
    }
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [_tableView reloadData];
}

#pragma -makr tableView scroll By automatic

- (void)tableViewAutomaticScroll{
    if ([_dataList count] >1) {
        // 监控目前滚动的位置(默认CGPointZero)
        [_tableView setContentOffset:CGPointMake(_tableView.contentOffset.x, _tableView.contentOffset.y+CGRectGetWidth(self.bounds)) animated:YES];
    }
}


#pragma -mark UITableViewDelgate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [_dataList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    RGMInfRollViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CDZKeyOfCellIdentKey];
    if (!cell) {
        cell = [[RGMInfRollViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CDZKeyOfCellIdentKey];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell setBackgroundColor:[UIColor colorWithHexString:@"EEEEEE"]];
        //就是将cell旋转90度。
        [cell setTransform:CGAffineTransformMakeRotation(M_PI_2)];
    }
    // Configure the cell...
    [cell.imageView setImage:nil];

    NSString *urlString = [_dataList[indexPath.row] objectForKey:@"image"];
    //不必一个字符一个字符的匹配
    @weakify(cell)
    if ([urlString rangeOfString:@"http"].location != NSNotFound) {
        [cell.imageView setImageWithURL:[NSURL URLWithString:urlString] placeholderImage:[ImageHandler getColorLogo] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            @strongify(cell)
            cell.imageView.image = image;
            [cell layoutSubviews];
        }  usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGRectGetWidth(self.bounds);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *detail = _dataList[indexPath.row];
    if (_responseBlock) {
        _responseBlock(detail);
    }
    if (_timer&&[_dataList count]>1)[_timer resumeTimerAfterTimeInterval:_animationDuration];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if ([_dataList count] != 1) {
        [_timer pauseTimer];
        [scrollView setUserInteractionEnabled:NO];
    }
}
//scrollView 的滑动逻辑
- (void)checkContentOffset:(UIScrollView *)scrollView {
    if ([_dataList count] != 1) {
        NSInteger currentPage = scrollView.contentOffset.y/CGRectGetHeight(scrollView.bounds);
        self.titlLabel.text = [_dataList[currentPage] objectForKey:@"name"];
        NSInteger minBouce = -1;
        NSInteger maxBouce = [_dataList count]-2;
        if ((currentPage+minBouce) == maxBouce) {
            [scrollView setContentOffset:CGPointMake(0.0f, CGRectGetWidth(self.bounds))];
            currentPage = 1;
        }else if ((currentPage+minBouce) == minBouce) {
            [scrollView setContentOffset:CGPointMake(0.0f, CGRectGetWidth(self.bounds) * maxBouce)];
            currentPage = maxBouce;
        }
        [_pageControl setCurrentPage:currentPage+minBouce];
        [scrollView setUserInteractionEnabled:YES];
    }else if(_dataList.count==1) {
        self.titlLabel.text = [_dataList[0] objectForKey:@"name"];
    }
    
}
//scrollView 拖拽的时候
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self checkContentOffset:scrollView];
}
//scrollView 减速
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self checkContentOffset:scrollView];
    if (_timer&&[_dataList count]>1)[_timer resumeTimerAfterTimeInterval:_animationDuration];
}
@end
