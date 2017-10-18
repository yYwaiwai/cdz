//
//  SNSSLVFItemBrandListComponent.m
//  cdzer
//
//  Created by KEns0nLau on 8/20/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "SNSSLVFItemBrandListComponent.h"
#import "SNSSLVFItemBrandListCell.h"

@interface  SNSSLVFItemBrandListComponent () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) IBOutlet UIControl *maskView;

@property (nonatomic, weak) IBOutlet UIView *collectionViewContainer;

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) NSArray *dateList;

@property (nonatomic, strong) IBOutlet NSLayoutConstraint *leadingToTrailingConstraint;

@end

@implementation SNSSLVFItemBrandListComponent

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)awakeFromNib {
    [super awakeFromNib];
    self.itemBrandType = SNSSLVFItemBrandTypeOfNone;
    [self.collectionView registerNib:[UINib nibWithNibName:@"SNSSLVFItemBrandListCell"  bundle:nil] forCellWithReuseIdentifier:@"cell"];
}

- (void)setItemBrandName:(NSString *)itemBrandName {
    _itemBrandName = itemBrandName;
}

- (void)setItemBrandType:(SNSSLVFItemBrandType)itemBrandType {
    _itemBrandType = itemBrandType;
    self.itemBrandName = @"";
    if (itemBrandType==SNSSLVFItemBrandTypeOfNone) {
        self.dateList = nil;
        [self.collectionView reloadData];
    }else {
        [self getSpecServiceItemBrandList];
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dateList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    SNSSLVFItemBrandListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CDZKeyOfCellIdentKey forIndexPath:indexPath];
    NSDictionary *detial = self.dateList[indexPath.item];
    NSString *imageName = detial[@"imgurl"];
    cell.brandLogoImageView.image = cell.brandLogoDefaultImage;
    if ([imageName isContainsString:@"http"]) {
        imageName = [imageName stringByReplacingOccurrencesOfString:@"," withString:@""];
        [cell.brandLogoImageView setImageWithURL:[NSURL URLWithString:imageName] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    cell.brandNameLabel.text = detial[@"name"];
    return cell;

}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    UIEdgeInsets sectionInset = [(UICollectionViewFlowLayout*)collectionViewLayout sectionInset];
    NSInteger width = CGRectGetWidth(collectionView.frame)-sectionInset.left-sectionInset.right-[(UICollectionViewFlowLayout*)collectionViewLayout minimumInteritemSpacing]*2;
    if (width%3!=0) width -= (NSInteger)width%3;
    width/=3;
    CGFloat height = roundf(width/1.19626168224299);
    return CGSizeMake(width, height);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *detial = self.dateList[indexPath.item];
    self.itemBrandName = detial[@"name"];
    if (self.resultBlock) {
        self.resultBlock();
    }
    [self hideItemBrandListView];
}

- (void)showItemBrandListView {
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    self.frame = UIApplication.sharedApplication.keyWindow.rootViewController.view.bounds;
    [UIApplication.sharedApplication.keyWindow.rootViewController.view addSubview:self];
    @weakify(self);
    self.leadingToTrailingConstraint.constant = -(CGRectGetWidth(self.frame)*0.724638);
    [UIView animateWithDuration:0.25 animations:^{
        @strongify(self);
        CGRect frame = self.collectionViewContainer.frame;
        frame.origin.x = CGRectGetWidth(self.frame)-CGRectGetWidth(self.collectionViewContainer.frame);
        self.collectionViewContainer.frame = frame;
        self.maskView.alpha = 1;
    }];
    
}

- (void)hideItemBrandListView {
    @weakify(self);
    self.leadingToTrailingConstraint.constant = 0;
    [UIView animateWithDuration:0.25 animations:^{
        @strongify(self);
        CGRect frame = self.collectionViewContainer.frame;
        frame.origin.x = CGRectGetWidth(self.frame);
        self.collectionViewContainer.frame = frame;
        self.maskView.alpha = 0;
    } completion:^(BOOL finished) {
        @strongify(self);
        if (self.superview) {
            [self removeFromSuperview];
        }
    }];
}

- (void)getSpecServiceItemBrandList {
    @weakify(self);
    [APIsConnection.shareConnection rapidRepairSpecServiceItemBrandListWithItemBrandType:self.itemBrandType success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        if (errorCode==0) {
            
        }
        self.dateList = responseObject[CDZKeyOfResultKey];
        [self.collectionView reloadData];
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
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
