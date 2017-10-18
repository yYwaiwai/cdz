//
//  GPSAppointmentVC.m
//  cdzer
//
//  Created by KEns0n on 10/23/15.
//  Copyright © 2015 CDZER. All rights reserved.
//

#import "GPSAppointmentVC.h"
#import "GPSAppointmentContentVC.h"
#import "InsetsLabel.h"
#import "MyCarVC.h"
#import "MyShoppingCartVC.h"
#import "WKWebViewController.h"


@interface GPSAppointmentVC ()

@property (nonatomic, strong) GPSAppointmentNavVC *navVC;

@property (nonatomic, assign) BOOL resendAppointment;

@end

@implementation GPSAppointmentVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self componentSetting];
    [self initializationUI];
    [self setReactiveRules];
    self.loginAfterShouldPopToRoot = NO;
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    if (_resendAppointment) {
        [_navVC retryAppointmentRequest];
    }
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(showWebViewWithObject:) name:CDZKeyOfShowWebRequestion object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(handleMissingTokenAction) name:CDZKeyOfLoginVC object:nil];
}

- (void)showWebViewWithObject:(NSNotification *)notif {
    @autoreleasepool {
        if ([notif.userInfo[@"url"] isKindOfClass:NSString.class]&&[notif.userInfo[@"url"] rangeOfString:@"http"].location!=NSNotFound) {
            
            NSString *urlString = notif.userInfo[@"url"];
            WKWebViewController *webVC = [[WKWebViewController alloc] initWithURL:[NSURL URLWithString:urlString]];
            webVC.title = @"车队长科技预约GPS协议";
            webVC.showPageTitleAndURL = NO;
            webVC.hideBarsWithGestures = NO;
            webVC.supportedWebNavigationTools = WKWebNavigationToolNone;
            webVC.supportedWebActions = WKWebActionNone;
            webVC.webViewContentScale = 500;
            [self setDefaultNavBackButtonWithoutTitle];
            [self.navigationController pushViewController:webVC animated:YES];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)componentSetting {
   
    
}

- (void)pushToUserAutosEditView {
    @autoreleasepool {
        MyCarVC *vc = [MyCarVC new];
        vc.wasBackRootView = YES;
        vc.wasSubmitAfterLeave = YES;
        self.resendAppointment = YES;
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)pushToMyCart {
    @autoreleasepool {
        MyShoppingCartVC *vc = MyShoppingCartVC.new;
        vc.navShouldPopOtherVC = YES;
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }
}


- (void)initializationUI {
    @autoreleasepool {
        GPSAppointmentResultBlock resultBlock = ^(GPSAppointmentResultType result, NSString *errorString){
            switch (result) {
                case GPSAppointmentResultTypeOfMissingAutosData:
                    [self pushToUserAutosEditView];
                    break;
                    
                case GPSAppointmentResultTypeOfWasAppointmented:
                    [self.navigationController popToRootViewControllerAnimated:YES];
                    break;
                    
                case GPSAppointmentResultTypeOfSuccess:
                    [self pushToMyCart];
                    break;
                    
                default:
                    break;
            }
        };
        
        GPSAppointmentContentVC *rootView = [[GPSAppointmentContentVC alloc] initWithStepID:0];
        self.navVC = [[GPSAppointmentNavVC alloc] initWithRootViewController:rootView];
        _navVC.navigationBarHidden = YES;
        _navVC.view.frame = self.contentView.bounds;
        [self.contentView addSubview:_navVC.view];
        _navVC.resultBlock = resultBlock;
        
        
        
    }
}

- (void)setReactiveRules {
    @weakify(self);
    [RACObserve(self, navVC.title) subscribeNext:^(NSString *title) {
        @strongify(self);
        self.title = title;
    }];
}

- (void)handleUserLoginResult:(BOOL)isSuccess fromAlert:(BOOL)fromAlert {
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
