//
//  SelfDiagnosisModuleBottomView.m
//  cdzer
//
//  Created by KEns0n on 08/11/2016.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "SelfDiagnosisModuleBottomView.h"
#import "SelfDiagnosisMBVCell.h"

@interface SelfDiagnosisModuleBottomView ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) IBOutlet NSLayoutConstraint *heightConstraint;


@end

@implementation SelfDiagnosisModuleBottomView

- (void)awakeFromNib {
    [super awakeFromNib];
    if (SCREEN_WIDTH>320) {
        self.heightConstraint.constant -= 10;
    }
    CGRect frame = self.frame;
    frame.size.height = self.heightConstraint.constant;
    self.frame = frame;
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [self.collectionView registerNib:[UINib nibWithNibName:@"SelfDiagnosisMBVCell" bundle:nil] forCellWithReuseIdentifier:CDZKeyOfCellIdentKey];
    NSLog(@"%@", NSStringFromCGRect(self.frame));
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [[self viewWithTag:1] setViewBorderWithRectBorder:UIRectBorderTop|UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    
}

- (void)setDataSources:(NSArray *)dataSources {
    _dataSources = dataSources;
    [self.collectionView reloadData];
}

- (void)reloadCollectionView {
    [self.collectionView reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSources.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SelfDiagnosisMBVCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CDZKeyOfCellIdentKey forIndexPath:indexPath];
    NSUInteger currentIdx = (indexPath.item+1)%3;
    cell.viewBorderRect = UIRectBorderBottom;
    if (currentIdx==2) {
        cell.viewBorderRect = UIRectBorderLeft|UIRectBorderBottom|UIRectBorderRight;
    }
    NSDictionary *detail = self.dataSources[indexPath.item];
    [cell updateUIData:detail];
    return cell;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger currentIdx = (indexPath.item+1)%3;
    CGSize size = CGSizeZero;
    NSUInteger remainWidth = (NSInteger)SCREEN_WIDTH%3;
    NSUInteger width = (NSInteger)SCREEN_WIDTH/3;
    if (currentIdx==2) {
        width+=remainWidth;
    }
    size.width = width;
    size.height = CGRectGetHeight(collectionView.frame)/2.0f;
    return size;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.reponseBlock) {
        self.reponseBlock(indexPath);
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
