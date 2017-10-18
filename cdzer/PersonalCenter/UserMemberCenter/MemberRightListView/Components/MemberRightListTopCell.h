//
//  MemberRightListTopCell.h
//  cdzer
//
//  Created by KEns0n on 09/12/2016.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MemberRightListTopCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UIImageView *leftBarIV;

@property (nonatomic, weak) IBOutlet UIImageView *rightBarIV;

- (void)updateSettingByIndex:(NSIndexPath *)indexPath andSelected:(BOOL)selected;

- (void)imageTransitionReduction;

- (void)imageTransitionSelection;
@end
