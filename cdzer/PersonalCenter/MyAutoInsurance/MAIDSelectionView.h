//
//  MAIDSelectionView.h
//  cdzer
//
//  Created by KEns0n on 10/20/15.
//  Copyright © 2015 CDZER. All rights reserved.
//

typedef void(^MAIDSelectionViewResponseBlock)(BOOL isConfirm, NSInteger currentSelectionID);

#import <UIKit/UIKit.h>

@interface MAIDSelectionView : UIView

@property (nonatomic, assign) NSInteger currentSelectionID;

@property (nonatomic, assign) BOOL selected;

- (void)setTitle:(NSString *)title withDataList:(NSArray *)dataList andWasShowButton:(BOOL)isShowButton responseBlock:(MAIDSelectionViewResponseBlock)responseBlock;

- (void)showSelectionView;

@end
