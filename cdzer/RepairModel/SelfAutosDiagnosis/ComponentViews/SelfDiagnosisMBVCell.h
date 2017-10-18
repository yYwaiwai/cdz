//
//  SelfDiagnosisMBVCell.h
//  cdzer
//
//  Created by KEns0n on 08/11/2016.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelfDiagnosisMBVCell : UICollectionViewCell

@property (nonatomic, assign) UIRectBorder viewBorderRect;

- (void)updateUIData:(NSDictionary *)detail;

@end
