
//  Created by apple1 on
//  Copyright © 2016年   rights reserved.
//

#import "GuideController.h"
#import "BaseTabBarController.h"
#import "GuideCell.h"
#import "UIView+AJExp.h"
#import "AppDelegate.h"

@interface GuideController ()<GuideCellDelegate>

@property (nonatomic,strong) GuideController *guideController;

@property (nonatomic, strong) UIPageControl *pageControl;

@property (nonatomic, assign) NSUInteger totalCount;

@end

@implementation GuideController

- (instancetype)init {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    
    //设置item大小
    layout.itemSize = [UIScreen mainScreen].bounds.size;
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    if (self = [super initWithCollectionViewLayout:layout]) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.totalCount = 3;
    [self initializationUI];
}

- (void)initializationUI
{
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerNib:[UINib nibWithNibName:@"GuideCell" bundle:nil] forCellWithReuseIdentifier:@"GuideCell"];
    self.collectionView.pagingEnabled = YES;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.bounces = NO;
    
    
//    CGRect pcRect = self.view.bounds;
//    pcRect.size.height = 50.0f*vWidthRatio;
//    pcRect.origin = CGPointMake(0.0f, CGRectGetHeight(self.view.bounds)-CGRectGetHeight(pcRect));
//    self.pageControl = [[UIPageControl alloc] initWithFrame:pcRect];
//    _pageControl.numberOfPages = 4;
//    _pageControl.currentPage = 0;
//    [_pageControl setUserInteractionEnabled:NO];
//    [_pageControl setPageIndicatorTintColor:[UIColor colorWithRed:0.824f green:0.827f blue:0.827f alpha:1.00f]];
//    [_pageControl setCurrentPageIndicatorTintColor:CDZColorOfDefaultColor];
//    [self.view addSubview:_pageControl];
}


- (BOOL)prefersStatusBarHidden {
    
    return kShouldHiddenStatusBar;
}

#pragma mark - UICollectionViewDataSource

//- (void)checkContentOffset:(UIScrollView *)scrollView {
//        NSInteger currentPage = scrollView.contentOffset.x/CGRectGetWidth(scrollView.bounds);
//        [_pageControl setCurrentPage:currentPage];
//}
//
//- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
//    [self checkContentOffset:scrollView];
//}
//
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//    [self checkContentOffset:scrollView];
//}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.totalCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    GuideCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GuideCell" forIndexPath:indexPath];
    NSString *imageName = [NSString stringWithFormat:@"gc_guide_%02d@%dx", indexPath.row+1, (IS_IPHONE_4_OR_LESS?1:3)];
    cell.imageName = imageName;
    cell.delegate = self;
    [cell showStartButton:(indexPath.row+1 == self.totalCount)];
    
    return cell;
}


- (void)guideCellDidClickStart:(GuideCell *)cell {
    NSDictionary *dict = [NSBundle mainBundle].infoDictionary;
    NSString *version = dict[@"CFBundleShortVersionString"];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:version forKey:@"CFBundleShortVersionString"];
    [defaults synchronize];
    
    UIApplication *app = [UIApplication sharedApplication];
    UIWindow *window = app.keyWindow;
    AppDelegate *delegate = (AppDelegate *)app.delegate;
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    delegate.navViewController = [storyBoard instantiateInitialViewController];
    
    
    // remove the 1px bottom border from UINavigationBar
    [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init]
                                      forBarPosition:UIBarPositionAny
                                          barMetrics:UIBarMetricsDefault];
    
    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
    
    //BaseTabBarController is UITabBarController's subclass
    BaseTabBarController *rootVC = (BaseTabBarController *)delegate.navViewController.visibleViewController;
    //    rootVC.delegate = self;
    
    
    rootVC.selectedIndex = 0;   //TabBarController must set it to 0
    
    window.rootViewController = delegate.navViewController;
    
    window.backgroundColor = CDZColorOfWhite;
    
    @weakify(self);
    [UIView animateWithDuration:0.8 animations:^{
        @strongify(self);
        self.view.alpha = 0;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
    }];
    
}

- (void)dealloc {
    NSLog(@"dealloc");
}



- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
