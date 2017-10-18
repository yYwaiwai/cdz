//
//  ShopNServiceMoreDetailVC.m
//  cdzer
//
//  Created by KEns0nLau on 8/31/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "ShopNServiceMoreDetailVC.h"
#import "AdvertisingScrollView.h"
#import "UIView+LayoutConstraintHelper.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>

@interface ShopCertsListViewCell : UICollectionViewCell;
@property (nonatomic, strong) UIImageView *imageView;
@end
@implementation ShopCertsListViewCell

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [UIImageView new];
        _imageView.translatesAutoresizingMaskIntoConstraints = NO;
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [_imageView addSelfByFourMarginToSuperview:self];
    }
    return _imageView;
}

- (UICollectionViewLayoutAttributes *)preferredLayoutAttributesFittingAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    UICollectionViewLayoutAttributes *attributes = [super preferredLayoutAttributesFittingAttributes:layoutAttributes];
    CGSize systemLayoutSize = [self systemLayoutSizeFittingSize:layoutAttributes.size withHorizontalFittingPriority:UILayoutPriorityFittingSizeLevel verticalFittingPriority:UILayoutPriorityRequired];
    if (systemLayoutSize.height>=systemLayoutSize.width) {
        systemLayoutSize.width = systemLayoutSize.height;
    }else {
        systemLayoutSize.width = roundf(systemLayoutSize.height*attributes.size.width/attributes.size.height);
    }
    attributes.size = systemLayoutSize;
    return attributes;
}

@end

@interface ShopNServiceMoreDetailVC () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property (nonatomic, weak) IBOutlet AdvertisingScrollView *shopAdvertisingScrollView;

@property (nonatomic, weak) IBOutlet UIView *shopIntroTitleContainerView;
@property (nonatomic, weak) IBOutlet UILabel *shopNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *shopIntroLabel;

@property (nonatomic, weak) IBOutlet UIView *shopFacilitiesTitleContainerView;
@property (nonatomic, weak) IBOutlet UILabel *shopFacilitiesLabel;

@property (nonatomic, weak) IBOutlet UIView *shopCertsTitleContainerView;
@property (nonatomic, weak) IBOutlet UICollectionView *shopCertsListView;

@property (nonatomic, strong) NSArray *shopCertsList;

@property (nonatomic, assign) CGFloat collectionViewLayoutHeight;

@end

@implementation ShopNServiceMoreDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeTop;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.extendedLayoutIncludesOpaqueBars = YES;
    self.navigationController.navigationBar.translucent = YES;
    [self updateShopInfoDetal];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.shopAdvertisingScrollView.shouldNotAutoScroll = NO;
    [self.shopAdvertisingScrollView setupDataSourcesArray:[self.shopDetail[@"shop_img"] valueForKey:@"imgurl"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    BorderOffsetObject *borderOffset = [BorderOffsetObject new];
    borderOffset.bottomLeftOffset = 12.0f;
    
    [self.shopIntroTitleContainerView setViewBorderWithRectBorder:UIRectBorderTop|UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:borderOffset];
    [[self.shopIntroTitleContainerView.superview viewWithTag:99] setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    
    [self.shopFacilitiesTitleContainerView setViewBorderWithRectBorder:UIRectBorderTop|UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:borderOffset];
    [[self.shopFacilitiesTitleContainerView.superview viewWithTag:99] setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    
    [self.shopCertsTitleContainerView setViewBorderWithRectBorder:UIRectBorderTop|UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:borderOffset];
    [self.shopCertsTitleContainerView.superview setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
}

- (void)updateShopInfoDetal {
    
    self.shopAdvertisingScrollView.shouldNotAutoScroll = YES;
    [self.shopAdvertisingScrollView setupDataSourcesArray:[self.shopDetail[@"shop_img"] valueForKey:@"imgurl"]];
    
    self.shopNameLabel.text = self.shopDetail[@"wxs_name"];
    self.shopIntroLabel.text = self.shopDetail[@"wxs_introduce"];
    if ([self.shopIntroLabel.text isEqualToString:@""]) {
        self.shopIntroLabel.text = @"暂无更多简介";
    }
    NSArray *shopFacilitiesList = [self.shopDetail[@"wxs_facilities"] valueForKey:@"name"];
    self.shopFacilitiesLabel.text = [shopFacilitiesList componentsJoinedByString:@" "];
    self.shopCertsList = [self.shopDetail[@"wxs_certificate_honor"] valueForKey:@"imgurl"];
    
    UICollectionViewFlowLayout *collectionViewLayout = (UICollectionViewFlowLayout *)self.shopCertsListView.collectionViewLayout;
    collectionViewLayout.estimatedItemSize = CGSizeMake(178, collectionViewLayout.itemSize.height);
    self.collectionViewLayoutHeight=collectionViewLayout.itemSize.height;
    [self.shopCertsListView registerClass:ShopCertsListViewCell.class forCellWithReuseIdentifier:@"cell"];
    [self.shopCertsListView reloadData];
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *text = @"暂无更多资质信息！";
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0f],
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return  self.shopCertsList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ShopCertsListViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.imageView.backgroundColor = [UIColor colorWithHexString:@"f5f5f5"alpha:0.6];
    NSString *imgURL = self.shopCertsList[indexPath.item];
    [cell.imageView setImageWithURL:[NSURL URLWithString:imgURL] placeholderImage:[ImageHandler getWhiteLogo] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    return cell;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(178, self.collectionViewLayoutHeight);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
