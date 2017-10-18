
//  Created by
//  Copyright © 2016年 All rights reserved.
//

#import "GuideCell.h"

@interface GuideCell ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
- (IBAction)startApp:(id)sender;

@end
@implementation GuideCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setImageName:(NSString *)imageName {
    _imageName = imageName;
    [self.startButton setBackgroundImage:nil forState:UIControlStateNormal];
    self.imageView.image = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:imageName ofType:@"png"]];
}

- (IBAction)startApp:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(guideCellDidClickStart:)]) {
        [self.delegate guideCellDidClickStart:self];
    }
    
}

- (void)showStartButton:(BOOL)show {
    self.startButton.hidden = !show;
}

@end
