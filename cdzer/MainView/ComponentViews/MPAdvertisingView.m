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

@interface MPAdvertisingCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UIImageView *imageView;

@end

@implementation MPAdvertisingCell

@end

@interface MPAdvertisingView () <UICollectionViewDelegate, UICollectionViewDataSource> {
    NSTimeInterval _animationDuration;
    NSUInteger _retryCount;
}

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;

@property (nonatomic, weak) IBOutlet UIPageControl *pageControl;

@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *loadingIndicatorView;

@property (nonatomic, weak) IBOutlet UIImageView *placeholderIV;

@property (nonatomic, strong) NSMutableArray *dataList;

@property (nonatomic, strong) NSTimer *timer;
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
                                                selector:@selector(scrollViewAutomaticScroll)
                                                userInfo:nil
                                                 repeats:YES];
    }
}
- (void)awakeFromNib {
    @autoreleasepool {
        [super awakeFromNib];
        self.backgroundColor = CDZColorOfBlack;
        if (_animationDuration <= 0.0000f) _animationDuration = 3.5f;
        self.dataList = [NSMutableArray new];
        
        self.loadingIndicatorView.color = CDZColorOfBlack;
        _loadingIndicatorView.hidden = YES;
        [_loadingIndicatorView startAnimating];
        self.placeholderIV.hidden = YES;
        self.placeholderIV.userInteractionEnabled = YES;
        
        UINib *nib = [UINib nibWithNibName:@"MPAdvertisingCell" bundle:nil];
        [self.collectionView registerNib:nib forCellWithReuseIdentifier:@"cell"];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    UIImage *image = [ImageHandler getTheLaunchImage];
    CGRect drawRect = self.bounds;
    drawRect.origin.y = (image.size.height-CGRectGetHeight(self.frame))/2.0f;
    image = [ImageHandler croppingImageWithImage:image toRect:drawRect];
    self.placeholderIV.image = image;
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
        [self.pageControl setNumberOfPages:numberOfPages];
        [self.pageControl setCurrentPage:0];
        [self.collectionView reloadData];
        [self removeTheTimer];
        _timer = [NSTimer scheduledTimerWithTimeInterval:_animationDuration
                                                  target:self
                                                selector:@selector(scrollViewAutomaticScroll)
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
        [self.collectionView reloadData];
        if (_dataList.count>1) {
            //滑动到某一行，UITableViewScrollPosition代表想要这一行显示在当前TableView中的位置
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
        }
        
        [self startPlay];
    }
    
}

#pragma -makr tableView scroll By automatic

- (void)scrollViewAutomaticScroll{
    if ([_dataList count] >1) {
        // 监控目前滚动的位置(默认CGPointZero)
        [self.collectionView setContentOffset:CGPointMake(self.collectionView.contentOffset.x+CGRectGetWidth(self.bounds), self.collectionView.contentOffset.y) animated:YES];
    }
}

#pragma -mark UICollectionViewDelegate, UICollectionViewDataSource
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.bounds.size;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    MPAdvertisingCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CDZKeyOfCellIdentKey forIndexPath:indexPath];
    NSDictionary *detail = self.dataList[indexPath.item];
    NSString *urlString = detail[@"img"];
    //不必一个字符一个字符的匹配
    if ([urlString rangeOfString:@"http"].location != NSNotFound) {
        [cell.imageView setImageWithURL:[NSURL URLWithString:urlString] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
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
        NSInteger currentPage = scrollView.contentOffset.x/CGRectGetWidth(scrollView.bounds);
        NSInteger minBouce = -1;
        NSInteger maxBouce = [_dataList count]-2;
        if ((currentPage+minBouce) == maxBouce) {
            [scrollView setContentOffset:CGPointMake(CGRectGetWidth(self.bounds), 0.0f)];
            currentPage = 1;
        }
        if ((currentPage+minBouce) == minBouce) {
            [scrollView setContentOffset:CGPointMake(CGRectGetWidth(self.bounds) * maxBouce, 0.0f)];
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
    @weakify(self);
    _loadingIndicatorView.hidden = NO;
    [APIsConnection.shareConnection personalCenterAPIsGetMainPageAdvertisingInfoListWithSuccessBlock:^(NSURLSessionDataTask *operation, id responseObject) {
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
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
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
