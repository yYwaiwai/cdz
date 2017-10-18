//
//  CaseResultTitleView.h
//  cdzer
//
//  Created by KEns0n on 23/11/2016.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CaseResultTitleView : UIView

+ (CaseResultTitleView *)setTitleViewWithSearchTitle:(NSString *)searchTitle andSuperView:(UIView *)superView;

+ (CaseResultTitleView *)setTitleViewWithMainTitle:(NSString *)mainTitle subTitle:(NSString *)subTitle andSuperView:(UIView *)superView scrollView:(UIScrollView *)scrollView;

- (void)updateTitleWithSearchTitle:(NSString *)searchTitle;

- (void)updateTitleWithMainTitle:(NSString *)mainTitle subTitle:(NSString *)subTitle;


@end
