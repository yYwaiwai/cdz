//
//  DocumentPhotoDisplayView.h
//  cdzer
//
//  Created by 车队长 on 17/1/3.
//  Copyright © 2017年 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DocumentPhotoDisplayView : UIView

@property (weak, nonatomic) IBOutlet UIControl *DocumentPhotoDisplayBGView;

@property (weak, nonatomic) IBOutlet UIImageView *certificatesImageView;


- (void)showView;

@end
