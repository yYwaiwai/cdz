//
//  InsetsTextFieldWithTLabel.h
//  cdzer
//
//  Created by KEns0n on 11/23/15.
//  Copyright © 2015 CDZER. All rights reserved.
//

#import "InsetsTextField.h"
#import "InsetsLabel.h"

@interface InsetsTextFieldWithTLabel : InsetsTextField

@property (nonatomic, readonly, strong) InsetsLabel *titleLabel;

@property (nonatomic, assign) CGFloat titleNContenWidth;

@property (nonatomic, assign) UIEdgeInsets defaultInsets;

@property (nonatomic, assign) UIEdgeInsets insetsForTitle;

@end