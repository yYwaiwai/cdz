//
//  MaintainDetailView.h
//  cdzer
//
//  Created by KEns0nLau on 9/13/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MaintainDetailView : UIView

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

- (void)showView;

@end
