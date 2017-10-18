//
//  AdvertisingScrollView.h
//  cdzer
//
//  Created by KEns0n on 2/26/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AdvertisingScrollView : UIView

@property (nonatomic, assign) BOOL displayPageCountView;

@property (nonatomic, assign) BOOL shouldNotAutoScroll;

- (void)setAnimationDuration:(NSTimeInterval)newVar;

- (instancetype)initWithMinFrame:(CGRect)frame;

- (void)setupDataSourcesArray:(NSArray *)dataArray;

- (void)viewWillAppear;

- (void)viewWillDisappear;

- (void)reloadData;
@end

@interface AdvertisingSVPageCountView : UIView;
@property(nonatomic) NSInteger numberOfPages;          // default is 0
@property(nonatomic) NSInteger currentPage;          // default is 0
@end
