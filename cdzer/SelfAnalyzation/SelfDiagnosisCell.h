//
//  SelfDiagnosisCell.h
//  cdzer
//
//  Created by KEns0n on 6/23/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>
@class  InsetsLabel;
@interface SelfDiagnosisCell : UITableViewCell

@property (nonatomic, readonly) UIButton *currentStepLogo;

@property (nonatomic, readonly) InsetsLabel *titleLabel;

@property (nonatomic, readonly) InsetsLabel *subDetailLabel;


@end
