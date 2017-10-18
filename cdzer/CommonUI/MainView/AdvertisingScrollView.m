//
//  AdvertisingScrollView.m
//  cdzer
//
//  Created by KEns0n on 2/26/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#define kDefaultImg @"default_banner@3x.jpg"

#import "AdvertisingScrollView.h"
#import "NSTimer+Addition.h"
#import "UIView+LayoutConstraintHelper.h"

@interface AdvertisingSVPageCountView()
@property (nonatomic, strong) UILabel *label;
@end

@implementation AdvertisingSVPageCountView

- (void)layoutSubviews {
    [super layoutSubviews];
    [self setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:4.0f];
}

- (instancetype)init {
    if (self=[super init]) {
        [self initializationUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self=[super initWithFrame:frame]) {
        [self initializationUI];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initializationUI];
}

- (void)initializationUI {
    self.currentPage = 0;
    self.numberOfPages = 0;
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    if (!self.label) {
        self.label = [UILabel new];
        self.label.translatesAutoresizingMaskIntoConstraints = NO;
        self.label.textColor = UIColor.whiteColor;
        self.label.font = [self.label.font fontWithSize:13];
        self.label.text = @"0/0";
        [self addSubview:self.label];
        [self.label addSelfByFourMarginToSuperview:self withEdgeConstant:UIEdgeInsetsMake(3, 6, 3, 6)];
    }
    self.translatesAutoresizingMaskIntoConstraints = NO;
}

- (void)setCurrentPage:(NSInteger)currentPage {
    if (currentPage>(self.numberOfPages-1)) currentPage = self.numberOfPages-1;
    if (currentPage<0) currentPage = 0;
    _currentPage = currentPage;
    [self updateLabelText];
}

- (void)setNumberOfPages:(NSInteger)numberOfPages {
    _numberOfPages = numberOfPages;
    [self updateLabelText];
}

- (void)updateLabelText {
    NSInteger currentPage = self.currentPage;
    if (self.numberOfPages>0) currentPage = self.currentPage+1;
    self.label.text = [NSString stringWithFormat:@"%d/%d", currentPage, self.numberOfPages];
}

@end

@interface AdvertisingScrollViewCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView *imageDisplayView;
@end

@implementation AdvertisingScrollViewCell

- (UIImageView *)imageDisplayView {
    if (!_imageDisplayView) {
        self.imageDisplayView = [UIImageView new];
        self.imageDisplayView.translatesAutoresizingMaskIntoConstraints = NO;
        _imageDisplayView.backgroundColor = UIColor.whiteColor;
//        _imageDisplayView.contentMode = UIViewContentModeScaleAspectFit;
        [_imageDisplayView addSelfByFourMarginToSuperview:self.contentView];
        [self.contentView addSubview:_imageDisplayView];
    }
    return _imageDisplayView;
}

@end

@interface AdvertisingScrollView () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout> {
    
    NSTimeInterval _animationDuration;
}

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) UIPageControl *pageControl;

@property (nonatomic, strong) AdvertisingSVPageCountView *pageCountView;

@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, strong) NSTimer *timer;


@end

@implementation AdvertisingScrollView

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    [self viewWillDisappear];
    [self.collectionView reloadData];
    [self viewWillAppear];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self viewWillDisappear];
    [self.collectionView reloadData];
    [self viewWillAppear];
}

- (void)setAnimationDuration:(NSTimeInterval)newDuration {
    _animationDuration = newDuration;
    if (([self.dataArray count]>1)){
        if ([_timer isValid])[_timer invalidate];
        _timer = [NSTimer scheduledTimerWithTimeInterval:_animationDuration
                                                  target:self
                                                selector:@selector(updateCurrentPage)
                                                userInfo:nil
                                                 repeats:YES];
    }
}

- (CGRect)calculateRect:(CGRect)original{
    double ratio = 2.37931034482759;
    CGRect rect = original;
    CGFloat width = CGRectGetWidth([[UIScreen mainScreen] bounds]);
    rect.size = CGSizeMake(width, round(ratio*width));
    return rect;
}

- (instancetype)initWithMinFrame:(CGRect)frame {
    CGRect resizeRect = [self calculateRect:frame];
    self = [self initWithFrame:resizeRect];
    if (self) {}
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        if (!self.dataArray) self.dataArray = [NSMutableArray array];
        if (_animationDuration == 0.0000f) _animationDuration = 2.0f;
        [self initializationUI];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    if (!self.dataArray) self.dataArray = [NSMutableArray array];
    if (_animationDuration == 0.0000f) _animationDuration = 2.0f;
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [self initializationUI];
}

- (void)initializationUI {
    if (!self.collectionView) {
        UICollectionViewFlowLayout *flowLayout = [UICollectionViewFlowLayout new];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.minimumLineSpacing = 0;
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.sectionInset = UIEdgeInsetsZero;
        self.collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flowLayout];
        self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
        self.collectionView.bounces = NO;
        self.collectionView.pagingEnabled = YES;
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        self.collectionView.showsVerticalScrollIndicator = NO;
        self.collectionView.showsHorizontalScrollIndicator = NO;
        [self.collectionView registerClass:AdvertisingScrollViewCell.class forCellWithReuseIdentifier:@"cell"];
        [self.collectionView addSelfByFourMarginToSuperview:self];
    }
    
    if (!self.pageControl) {
        self.pageControl = [UIPageControl new];
        self.pageControl.translatesAutoresizingMaskIntoConstraints = NO;
        self.pageControl.userInteractionEnabled = NO;
        self.pageControl.pageIndicatorTintColor = [UIColor colorWithRed:0.824f green:0.827f blue:0.827f alpha:1.00f];
        self.pageControl.currentPageIndicatorTintColor = [UIColor colorWithHexString:@"49C7F5"];
        [self addSubview:self.pageControl];
        
        [self addConstraints:@[[NSLayoutConstraint constraintWithItem:self
                                                            attribute:NSLayoutAttributeBottom
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self.pageControl
                                                            attribute:NSLayoutAttributeBottom
                                                           multiplier:1
                                                             constant:0],
                               [NSLayoutConstraint constraintWithItem:self.pageControl
                                                            attribute:NSLayoutAttributeCenterX
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeCenterX
                                                           multiplier:1
                                                             constant:0]]];
    }
    
    if (!self.pageCountView) {
        self.pageCountView = [AdvertisingSVPageCountView new];
        self.pageCountView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.pageCountView];
        [self.pageCountView addSelfByFourMarginToSuperview:self withEdgeConstant:UIEdgeInsetsMake(0, 0, 8, 12) andLayoutAttribute:LayoutHelperAttributeBottom|LayoutHelperAttributeTrailing];
    }
    self.displayPageCountView = YES;
}

- (void)setupDataSourcesArray:(NSArray *)dataArray {
    @autoreleasepool {
        [self.dataArray removeAllObjects];
        if (!dataArray || [dataArray count] != 0) {
            if ([dataArray count]==1) {
                [self.dataArray addObjectsFromArray:dataArray];
            }else{
                [self.dataArray addObject:[dataArray objectAtIndex:[dataArray count]-1]];
                [self.dataArray addObjectsFromArray:dataArray];
                [self.dataArray addObject:[dataArray objectAtIndex:0]];
            }
        }else {
            [self.dataArray addObject:kDefaultImg];
        }
        [self.collectionView reloadData];
        
        if ([self.dataArray count]>1) {
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
            NSInteger numberOfPages = ([self.dataArray count] == 1)?1:[self.dataArray count]-2;
            self.pageControl.numberOfPages = numberOfPages;
            self.pageControl.currentPage = 0;
            self.pageCountView.numberOfPages = numberOfPages;
            self.pageCountView.currentPage = 0;
            [self.collectionView reloadData];
            if ([_timer isValid])[_timer invalidate];
            if (!self.shouldNotAutoScroll) {
                _timer = [NSTimer scheduledTimerWithTimeInterval:_animationDuration
                                                          target:self
                                                        selector:@selector(updateCurrentPage)
                                                        userInfo:nil
                                                         repeats:YES];
            }
        }
    }
    
}

- (void)setDisplayPageCountView:(BOOL)displayPageCountView {
    _displayPageCountView = displayPageCountView;
    self.pageCountView.hidden = !displayPageCountView;
    self.pageControl.hidden = !displayPageCountView;
}

#pragma -makr tableView scroll By automatic
- (void)updateCurrentPage {
    if ([self.dataArray count] >1) {
        [self.collectionView setContentOffset:CGPointMake(self.collectionView.contentOffset.x+CGRectGetWidth(self.bounds), self.collectionView.contentOffset.y) animated:YES];
    }
}

- (void)viewWillAppear {
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:_animationDuration
                                                  target:self
                                                selector:@selector(updateCurrentPage)
                                                userInfo:nil
                                                 repeats:YES];

    }
    self.timer.fireDate = [NSDate distantPast];
}

- (void)viewWillDisappear {
    self.timer.fireDate = [NSDate distantFuture];
}

- (void)reloadData {
    [self.collectionView reloadData];
}

#pragma -mark UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.bounds.size;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    AdvertisingScrollViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CDZKeyOfCellIdentKey forIndexPath:indexPath];
    cell.imageDisplayView.image =[UIImage imageNamed:@"weixiushang-all-bgView"];
    NSString *urlString = self.dataArray[indexPath.row];
    if ([urlString isContainsString:@"http"]){
        [cell.imageDisplayView sd_setImageWithURL:[NSURL URLWithString:urlString] placeholderImage:[UIImage imageNamed:@"weixiushang-all-bgView"]];
    }
    if ([urlString isEqualToString:kDefaultImg]) {
        cell.imageDisplayView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:urlString ofType:nil]];
    }
    return cell;
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if ([self.dataArray count] != 1) {
        [_timer pauseTimer];
        [scrollView setUserInteractionEnabled:NO];
    }
}

- (void)checkContentOffset:(UIScrollView *)scrollView {
    if ([self.dataArray count] != 1) {
        NSLog(@"%f", scrollView.contentOffset.x);
        NSLog(@"%f", CGRectGetWidth(scrollView.bounds));
        NSInteger currentPage = scrollView.contentOffset.x/CGRectGetWidth(scrollView.bounds);
        NSInteger minBouce = -1;
        NSInteger maxBouce = [self.dataArray count]-2;
        if ((currentPage+minBouce) == maxBouce) {
            [scrollView setContentOffset:CGPointMake(CGRectGetWidth(self.bounds), 0.0f)];
            currentPage = 1;
        }else if ((currentPage+minBouce) == minBouce) {
            [scrollView setContentOffset:CGPointMake(CGRectGetWidth(self.bounds) * maxBouce, 0.0f)];
            currentPage = maxBouce;
        }
        self.pageControl.currentPage = currentPage+minBouce;
        self.pageCountView.currentPage = currentPage+minBouce;
        [scrollView setUserInteractionEnabled:YES];
    }
    
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self checkContentOffset:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self checkContentOffset:scrollView];
    if ([_timer isValid]&&[self.dataArray count] != 1)[_timer resumeTimerAfterTimeInterval:_animationDuration];
}

@end
