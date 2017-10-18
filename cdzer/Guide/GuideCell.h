
//  Created by
//  Copyright © 2016年 All rights reserved.
//

#import <UIKit/UIKit.h>
@class GuideCell;
@protocol GuideCellDelegate <NSObject>

@optional
- (void)guideCellDidClickStart:(GuideCell *)cell;

@end
@interface GuideCell : UICollectionViewCell
@property (nonatomic,copy) NSString *imageName;

- (void)showStartButton:(BOOL)show;
@property (nonatomic, weak) id<GuideCellDelegate> delegate;
@end
