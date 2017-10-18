//
//  SurveyView.m
//  cdzer
//
//  Created by KEns0n on 2/1/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "InsetsLabel.h"
#import "SurveyView.h"

@interface SurveyView ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) InsetsLabel *headerTitleView;

@end

@implementation SurveyView

- (instancetype)initWithFrame:(CGRect)frame {
    return self;
}

- (void)setHeaderTitle:(NSString *)headerTitle {
    _headerTitle = headerTitle;
    self.tableHeaderView = nil;
    [self setupHeaderTitleView];
}

- (void)setupHeaderTitleView {
    @autoreleasepool {
        if (!_headerTitleView) {
            self.headerTitleView = [[InsetsLabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 0.0f, 0.0f)
                                                   andEdgeInsetsValue:DefaultEdgeInsets];
        }
    }
    self.tableHeaderView = nil;
    [self.headerTitleView sizeToFit];
    self.tableHeaderView = _headerTitleView;
}

@end
