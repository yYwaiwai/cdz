//
//  EServiceServiceListOptionView.m
//  cdzer
//
//  Created by KEns0nLau on 6/15/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "EServiceServiceListOptionView.h"

@interface EServiceServiceListOptionView ()

@property (nonatomic, weak) IBOutlet UIButton *allServiceBtn;

@property (nonatomic, weak) IBOutlet UIButton *eRepairBtn;

@property (nonatomic, weak) IBOutlet UIButton *eInspectBtn;

@property (nonatomic, weak) IBOutlet UIButton *eInsuranceBtn;

@property (nonatomic, weak) IBOutlet UIButton *arrowView;

@end

@implementation EServiceServiceListOptionView

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)setServiceType:(EServiceType)serviceType {
    
    self.allServiceBtn.backgroundColor = CDZColorOfClearColor;
    self.eRepairBtn.backgroundColor = CDZColorOfClearColor;
    self.eInspectBtn.backgroundColor = CDZColorOfClearColor;
    self.eInsuranceBtn.backgroundColor = CDZColorOfClearColor;
    
    _serviceType = serviceType;
    switch (serviceType) {
        case EServiceTypeOfERepair:
            self.eRepairBtn.backgroundColor = [UIColor colorWithRed:0.337 green:0.784 blue:0.945 alpha:1.00];
            self.eRepairBtn.selected = YES;
            break;
            
        case EServiceTypeOfEInspect:
            self.eInspectBtn.backgroundColor = [UIColor colorWithRed:0.337 green:0.784 blue:0.945 alpha:1.00];
            self.eInspectBtn.selected = YES;
            break;
            
        case EServiceTypeOfEInsurance:
            self.eInsuranceBtn.backgroundColor = [UIColor colorWithRed:0.337 green:0.784 blue:0.945 alpha:1.00];
            self.eInsuranceBtn.selected = YES;
            break;
            
        default:
            self.allServiceBtn.backgroundColor = [UIColor colorWithRed:0.337 green:0.784 blue:0.945 alpha:1.00];
            self.allServiceBtn.selected = YES;
            break;
    }
    [self hideOptionView];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self addTarget:self action:@selector(hideOptionView) forControlEvents:UIControlEventTouchUpInside];
    self.serviceType = EServiceTypeOfAllService;
    [self.allServiceBtn setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:5.0f];
    [self.eRepairBtn setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:5.0f];
    [self.eInspectBtn setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:5.0f];
    [self.eInsuranceBtn setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:5.0f];
    
}

- (IBAction)buttonAction:(UIButton *)sender {
    self.allServiceBtn.selected = NO;
    self.eRepairBtn.selected = NO;
    self.eInspectBtn.selected = NO;
    self.eInsuranceBtn.selected = NO;
    self.serviceType = sender.tag;
}

- (void)showOptionView {
    self.arrowView.selected = YES;
    UIWindow *window = UIApplication.sharedApplication.keyWindow;
    self.frame = window.bounds;
    self.translatesAutoresizingMaskIntoConstraints = YES;
    [window addSubview:self];
    @weakify(self);
    [UIView animateWithDuration:0.25 animations:^{
        @strongify(self);
        self.alpha = 1;
    }];
}

- (void)hideOptionView {
    self.arrowView.selected = NO;
    @weakify(self);
    [UIView animateWithDuration:0.25 animations:^{
        @strongify(self);
        self.alpha = 0;
    } completion:^(BOOL finished) {
        @strongify(self);
        [self removeFromSuperview];
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
