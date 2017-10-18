//
//  SNSSLVFItemBrandListCell.h
//  cdzer
//
//  Created by KEns0n on 24/03/2017.
//  Copyright © 2017 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface SNSSLVFItemBrandListCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UILabel *brandNameLabel;

@property (nonatomic, weak) IBOutlet UIImageView *brandLogoImageView;

@property (nonatomic, strong) UIImage *brandLogoDefaultImage;

@end
