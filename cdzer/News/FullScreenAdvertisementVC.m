//
//  FullScreenAdvertisementVC.m
//  cdzer
//
//  Created by KEns0n on 17/05/2017.
//  Copyright © 2017 CDZER. All rights reserved.
//

#import "FullScreenAdvertisementVC.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "APIActionConversionTable.h"

static NSString *EventDetailKey = @"EventDetailKey";
@interface FullScreenAdvertisementVC ()

@property (nonatomic, weak) IBOutlet UIImageView *imageView;

@property (nonatomic, strong) NSDictionary *eventDetail;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *closeBtnWidthConstraint;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *closeBtnTopConstraint;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *closeBtnTailConstraint;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *contentViewWidthConstraint;

@end

@implementation FullScreenAdvertisementVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSUserDefaults *userDefaults = NSUserDefaults.standardUserDefaults;
    self.eventDetail = [userDefaults objectForKey:EventDetailKey];
    if (self.eventDetail&&self.eventDetail[@"img_ios"]) {
        NSURL *url = [NSURL URLWithString:self.eventDetail[@"img_ios"]];
        [self.imageView setImageWithURL:url placeholderImage:nil options:SDWebImageRefreshCached usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    }
    if (IS_IPHONE_5||IS_IPHONE_4_OR_LESS) {
        self.closeBtnWidthConstraint.constant = 30.0f;
        self.closeBtnTopConstraint.constant = 25.0f;
        self.closeBtnTailConstraint.constant = 15.0f;
        self.contentViewWidthConstraint.constant = 250.0f;
    }
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)animationAlert:(UIView *)view {
    
    CAKeyframeAnimation *popAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    popAnimation.duration = 0.4;
    popAnimation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.01f, 0.01f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1f, 1.1f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9f, 0.9f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DIdentity]];
    popAnimation.keyTimes = @[@0.0f, @0.5f, @0.75f, @1.0f];
    popAnimation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [view.layer addAnimation:popAnimation forKey:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)goToEvent {
    NSString *action = self.eventDetail[@"action"];
    NSString *url = self.eventDetail[@"url"];
    NSString *title = self.eventDetail[@"title"];
    APIActionConvertedObject *configObj = [APIActionConversionTable getAPIActionConversionDetailWithActionString:action withObjects:url title:title];
    [APIActionConversionTable runTheAction:configObj];
    [self closeView];
}

- (IBAction)closeView {
    [self.view removeFromSuperview];
    if (self.closingBlock) {
        self.closingBlock();
    }
}

- (void)setSuperView:(UIView *)superView {
    self.view.frame = superView.bounds;
    [superView addSubview:self.view];
    [self animationAlert:self.imageView.superview];
}

@end
