//
//  SMSLFilterOtherOptionView.m
//  cdzer
//
//  Created by KEns0n on 15/11/2016.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "SMSLFilterOtherOptionView.h"
#import "UIView+LayoutConstraintHelper.h"

@interface SMSLFilterOtherOptionCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UILabel *textLabel;

@end

@implementation SMSLFilterOtherOptionCell

- (void)layoutSubviews {
    [super layoutSubviews];
    [self setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:5.0f];
    [self updateSelectStatus];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    [self updateSelectStatus];
}

- (void)updateSelectStatus {
    UIColor *color = self.selected?[UIColor colorWithRed:0.286 green:0.780 blue:0.961 alpha:1.00]:[UIColor colorWithRed:0.702 green:0.702 blue:0.702 alpha:1.00];
    self.textLabel.textColor = color;
    [self setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:0.5 withColor:color withBroderOffset:nil];
}

@end

@interface SMSLFilterOtherOptionView ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) IBOutlet UICollectionView *collcetionView;

@property (nonatomic, strong) NSArray <NSString *> *dataList;

@end

@implementation SMSLFilterOtherOptionView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.dataList = @[];
    _otherFilterString = @"";
    [self.collcetionView registerNib:[UINib nibWithNibName:@"SMSLFilterOtherOptionCell" bundle:nil] forCellWithReuseIdentifier:CDZKeyOfCellIdentKey];
    [self getMechanicSpecialList];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SMSLFilterOtherOptionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CDZKeyOfCellIdentKey forIndexPath:indexPath];
    cell.textLabel.text = self.dataList[indexPath.item];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger currentIdx = (indexPath.item+1)%3;
    NSInteger contianerWidth = CGRectGetWidth(collectionView.frame)-20;
    CGSize size = CGSizeZero;
    NSUInteger remainWidth = contianerWidth%3;
    NSUInteger width = contianerWidth/3;
    if (currentIdx==2) {
        width+=remainWidth;
    }
    size.width = width;
    size.height = 24;
    return size;
}

- (void)restoreSelection {
    _otherFilterString = @"";
    [self.collcetionView reloadData];
}

- (void)showView {
    UIWindow *keyWindow = UIApplication.sharedApplication.keyWindow;
    [self addSelfByFourMarginToSuperview:keyWindow];
}

- (IBAction)hideView {
    [self removeFromSuperview];
}

- (IBAction)resetOption {
    [self restoreSelection];
    [self hideView];
    if (self.responseBlock) {
        self.responseBlock();
    }
}


- (IBAction)submitSelection {
    if (!self.collcetionView.indexPathsForSelectedItems) {
        [self restoreSelection];
    }else {
        NSIndexPath *indexPath = self.collcetionView.indexPathsForSelectedItems.firstObject;
        _otherFilterString = self.dataList[indexPath.item];
    }
    [self hideView];
    if (self.responseBlock) {
        self.responseBlock();
    }
}

- (void)getMechanicSpecialList {
    @weakify(self)
    [APIsConnection.shareConnection mechanicCenterAPIsGetMechanicSpecialListWithSuccess:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self)
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"getMechanicSpecialList:%@", message);
        if (errorCode==0) {
            self.dataList = [responseObject[CDZKeyOfResultKey] valueForKey:@"name"];
        }
        [self.collcetionView reloadData];
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        @strongify(self)
        self.dataList = @[];
        [self.collcetionView reloadData];
        if (error.code==-1009) {
            [SupportingClass showAlertViewWithTitle:@"error" message:@"网络连接失败，请检查网络设置！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            }];
            return;
        }
        
        
        if (error.code==-1001) {
            [SupportingClass showAlertViewWithTitle:@"error" message:@"网络连接逾时，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            }];
            return;
        }
        
        [SupportingClass showAlertViewWithTitle:@"error" message:@"网络错误，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
        }];
        
    }];

}

@end
