//
//  SNSDShopServiceView.m
//  cdzer
//
//  Created by KEns0nLau on 8/30/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "SNSDShopServiceView.h"
#import "SNSDShopServiceViewCell.h"
#import "UIView+LayoutConstraintHelper.h"
@interface SNSDShopServiceView () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSLayoutConstraint *heightConstraint;

@end

@implementation SNSDShopServiceView

- (void)setRepairItemList:(NSArray *)repairItemList {
    if (!repairItemList) repairItemList = @[];
    _repairItemList = repairItemList;
    [self reloadData];
    self.hidden = (_repairItemList.count==0);
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.delegate = self;
    self.dataSource = self;
    self.bounces = NO;
    self.translatesAutoresizingMaskIntoConstraints = NO;

    [self registerClass:UICollectionReusableView.class forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headerFooterCell"];
    [self registerNib:[UINib nibWithNibName:@"SNSDShopServiceViewCell" bundle:nil] forCellWithReuseIdentifier:CDZKeyOfCellIdentKey];
    @weakify(self);
    [self.constraints enumerateObjectsUsingBlock:^(__kindof NSLayoutConstraint * _Nonnull constraints, NSUInteger idx, BOOL * _Nonnull stop) {
        @strongify(self);
        if (constraints.firstAttribute==NSLayoutAttributeHeight) {
            self.heightConstraint = constraints;
        }
    }];
    self.repairItemList = @[];
    
    [RACObserve(self, contentSize) subscribeNext:^(id size) {
        @strongify(self);
        CGSize contentSize = [size CGSizeValue];
        self.heightConstraint.constant = (self.repairItemList.count==0)?0:contentSize.height;
    }];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *recommendView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"headerFooterCell" forIndexPath:indexPath];
    recommendView.backgroundColor = CDZColorOfClearColor;
    UILabel *label = (UILabel *)[recommendView viewWithTag:100];
    if (!label) {
        label = [[UILabel alloc] initWithFrame:recommendView.bounds];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        label.font = [label.font fontWithSize:13];
        label.textColor = [UIColor colorWithHexString:@"646464"];
        [recommendView addSubview:label];
        [label addSelfByFourMarginToSuperview:recommendView withEdgeConstant:UIEdgeInsetsMake(0.0f, 12.0f, 0.0, 12.0)];
    }
    label.text = @"服务项目";
    return recommendView;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(CGRectGetWidth(self.frame), 30.0f);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout*)collectionViewLayout;
    CGFloat width = (CGRectGetWidth(self.frame)-flowLayout.sectionInset.left-flowLayout.sectionInset.right-flowLayout.minimumLineSpacing-flowLayout.minimumInteritemSpacing)/2.0f;
    return CGSizeMake(width, 44.0f);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.repairItemList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SNSDShopServiceViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CDZKeyOfCellIdentKey forIndexPath:indexPath];
    
    NSDictionary *detail = self.repairItemList[indexPath.item];
    [cell updateUIData:detail];
    return cell;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
