//
//  MPAdvertisingView.m
//  cdzer
//
//  Created by KEns0n on 2/26/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#import "MPAdvertisingView.h"
#import "NSTimer+Addition.h"
#import "APIActionConversionTable.h"
#import <UIActivityIndicator-for-SDWebImage/UIImageView+UIActivityIndicatorForSDWebImage.h>

@interface MPAdvertisingView () <UITableViewDataSource, UITableViewDelegate>
{
    NSTimeInterval _animationDuration;
    NSUInteger _retryCount;
}
@property (nonatomic, strong) UIView *reminderView;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIPageControl *pageControl;

@property (nonatomic, strong) NSMutableArray *dataList;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) UIActivityIndicatorView *loadingIndicatorView;

@property (nonatomic, strong) UIImageView *placeholderIV;
@end

@implementation MPAdvertisingView

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

- (CGRect)calculateRect:(CGRect)original{
    CGRect rect = original;
    CGFloat width = CGRectGetWidth([[UIScreen mainScreen] bounds]);
    rect.size = CGSizeMake(width, original.size.height*vWidthRatio);
    return rect;
}

- (instancetype)initWithMinFrame:(CGRect)frame {
    
    CGRect resizeRect = [self calculateRect:frame];
    self = [self initWithFrame:resizeRect];
    return self;
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


- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect pcRect = self.bounds;
    pcRect.size.height = 26.0f*vWidthRatio;
    pcRect.origin = CGPointMake(0.0f, CGRectGetHeight(self.bounds)-CGRectGetHeight(pcRect));
    self.pageControl.frame = pcRect;
    
    self.loadingIndicatorView.center = CGPointMake(CGRectGetWidth(self.frame)/2.0f, CGRectGetHeight(self.frame)/2.0f);
}

- (void)initializationUI {
    @autoreleasepool {
        self.backgroundColor = CDZColorOfBlack;
           //首界面的所有btn和广告的pageControl
        if (!_tableView) {
            UITableView *tableView = [[UITableView alloc] initWithFrame:self.bounds];
            [tableView setTransform:CGAffineTransformMakeRotation(-M_PI_2)];
            [tableView setFrame:self.bounds];
            [tableView setBounces:NO];
            [tableView setShowsHorizontalScrollIndicator:NO];
            [tableView setShowsVerticalScrollIndicator:NO];
            [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
            [tableView setRowHeight:CGRectGetWidth(self.bounds)];
            [tableView setDelegate:self];
            [tableView setPagingEnabled:YES];
            [tableView setDataSource:self];
            [tableView setContentOffset:CGPointMake(0.0f, CGRectGetWidth(self.bounds))];
            tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
            tableView.translatesAutoresizingMaskIntoConstraints = YES;
            [self setTableView:tableView];
            [self addSubview:tableView];
            tableView = nil;
        }
        
        if (!_pageControl) {
            CGRect pcRect = self.bounds;
            pcRect.size.height = 26.0f*vWidthRatio;
            pcRect.origin = CGPointMake(0.0f, CGRectGetHeight(self.bounds)-CGRectGetHeight(pcRect));
            UIPageControl *pageControl = [[UIPageControl alloc] initWithFrame:pcRect];
            [pageControl setUserInteractionEnabled:NO];
            [pageControl setPageIndicatorTintColor:[UIColor colorWithRed:0.824f green:0.827f blue:0.827f alpha:1.00f]];
            [pageControl setCurrentPageIndicatorTintColor:CDZColorOfDefaultColor];
            [self setPageControl:pageControl];
            [self addSubview:pageControl];
            pageControl = nil;
        }
        //UIActivityIndicatorView  转圈
        self.loadingIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _loadingIndicatorView.color = CDZColorOfBlack;
        _loadingIndicatorView.center = CGPointMake(CGRectGetWidth(self.frame)/2.0f, CGRectGetHeight(self.frame)/2.0f);
        //hidesWhenStopped  当停止动画的时候，是否隐藏。默认为YES。
        _loadingIndicatorView.hidesWhenStopped = NO;
        _loadingIndicatorView.hidden = YES;
        [_loadingIndicatorView startAnimating];
        [self addSubview:_loadingIndicatorView];
        
        UIImage *image = [ImageHandler getTheLaunchImage];
        CGRect drawRect = self.bounds;
        drawRect.origin.y = (image.size.height-CGRectGetHeight(self.frame))/2.0f;
        image = [ImageHandler croppingImageWithImage:image toRect:drawRect] ;
        self.placeholderIV = [[UIImageView alloc] initWithImage:image];
        self.placeholderIV.backgroundColor = [UIColor colorWithRed:0.231 green:0.675 blue:0.941 alpha:1.00];
        self.placeholderIV.contentMode = UIViewContentModeScaleAspectFit;
        self.placeholderIV.hidden = YES;
        self.placeholderIV.userInteractionEnabled = YES;
        [self addSubview:self.placeholderIV];
    }
}

- (void)viewWillDisappear {
    if (_timer&&[_dataList count] > 1) [_timer pauseTimer];
    _loadingIndicatorView.hidden = YES;
    self.placeholderIV.hidden = YES;
}

- (void)viewWillAppear {
    if ([_dataList count] > 1) {
        _loadingIndicatorView.hidden = YES;
        self.placeholderIV.hidden = YES;
        if (!_timer) {
            [self startPlay];
        }else {
            [_timer resumeTimerAfterTimeInterval:_animationDuration];
        }
        [self performSelectorInBackground:@selector(getMPADInfoData) withObject:nil];
    }else {
        _loadingIndicatorView.hidden = NO;
        _retryCount = 0;
        [self performSelectorInBackground:@selector(getMPADInfoData) withObject:nil];
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
            }else{
                [_dataList addObject:[dataList objectAtIndex:[dataList count]-1]];
                [_dataList addObjectsFromArray:dataList];
                [_dataList addObject:[dataList objectAtIndex:0]];
            }
        }
        [self.tableView reloadData];
        if (_dataList.count>1) {
            //滑动到某一行，UITableViewScrollPosition代表想要这一行显示在当前TableView中的位置
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:NO];
        }
        
        [self startPlay];
    }
    
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
    static NSString *ident = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ident];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ident];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell setBackgroundColor:[UIColor whiteColor]];
        //就是将cell旋转90度。
        [cell setTransform:CGAffineTransformMakeRotation(M_PI_2)];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [imageView setTag:9090];
        [cell addSubview:imageView];

    }
    // Configure the cell...
    
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:9090];
    imageView.frame = self.bounds;
    [imageView setImage:nil];

    NSString *urlString = [_dataList[indexPath.row] objectForKey:@"img"];
    //不必一个字符一个字符的匹配
    if ([urlString rangeOfString:@"http"].location != NSNotFound) {
        [imageView setImageWithURL:[NSURL URLWithString:urlString] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGRectGetWidth(self.bounds);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *detail = _dataList[indexPath.row];
    NSString *action = detail[@"action"];
    NSString *url = detail[@"url"];
    NSString *title = detail[@"title"];
    APIActionConvertedObject *configObj = [APIActionConversionTable getAPIActionConversionDetailWithActionString:action withObjects:url title:title];
    [APIActionConversionTable runTheAction:configObj];
    NSLog(@"%@",_dataList[indexPath.row]);
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
        NSInteger minBouce = -1;
        NSInteger maxBouce = [_dataList count]-2;
        if ((currentPage+minBouce) == maxBouce) {
            [scrollView setContentOffset:CGPointMake(0.0f, CGRectGetWidth(self.bounds))];
            currentPage = 1;
        }
        if ((currentPage+minBouce) == minBouce) {
            [scrollView setContentOffset:CGPointMake(0.0f, CGRectGetWidth(self.bounds) * maxBouce)];
            currentPage = maxBouce;
        }
        [_pageControl setCurrentPage:currentPage+minBouce];
        [scrollView setUserInteractionEnabled:YES];
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


- (void)getMPADInfoData {
    @weakify(self)
    _loadingIndicatorView.hidden = NO;
    [APIsConnection.shareConnection personalCenterAPIsGetMainPageAdvertisingInfoListWithSuccessBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        if (errorCode!=0) {
            
            [SupportingClass showAlertViewWithTitle:nil message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                
            }];
            return;
        }
        [self setupScrollDataList:responseObject[CDZKeyOfResultKey]];
        self->_retryCount = 0;
        self.loadingIndicatorView.hidden = YES;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (self->_retryCount>5) {
            self.loadingIndicatorView.hidden = YES;
            self.placeholderIV.hidden = NO;
            return;
        }
        self->_retryCount++;
        [self getMPADInfoData];
    }];
}
@end
