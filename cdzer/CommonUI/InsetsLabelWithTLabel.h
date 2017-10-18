//
//  InsetsLabelWithTLabel.h
//  cdzer
//
//  Created by KEns0n on 11/23/15.
//  Copyright © 2015 CDZER. All rights reserved.
//

#import "InsetsLabel.h"

@interface InsetsLabelWithTLabel : InsetsLabel

@property (nonatomic, readonly, strong) InsetsLabel *titleLabel;

@property (nonatomic, assign) CGFloat titleNContenWidth;

@property (nonatomic, assign) UIEdgeInsets defaultInsets;

@property (nonatomic, assign) UIEdgeInsets insetsForTitle;

@end
