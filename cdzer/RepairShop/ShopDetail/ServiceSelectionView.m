//
//  ServiceSelectionView.m
//  cdzer
//
//  Created by KEns0n on 3/11/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#define vMinHeight vAdjustByScreenRatio(55.0f)
#import "ServiceSelectionView.h"

@interface ServiceSelectionView ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UIButton *triggerSSVCBtn;

@property (nonatomic, strong) UITableView *seletedServiceTV;

@end

@implementation ServiceSelectionView


- (void)initializationUI {
    @autoreleasepool {
        
        [self setBackgroundColor:CDZColorOfWhite];
        [self setBorderWithColor:[UIColor lightGrayColor] borderWidth:(0.5f)];
        
        if (CGRectGetHeight(self.frame)<vMinHeight) {
            CGRect rect = self.frame;
            rect.size.height = vMinHeight;
            [self setFrame:rect];
        }
        
        if (!_triggerSSVCBtn) {
            CGRect rect = CGRectZero;
            rect.origin = CGPointMake(vAdjustByScreenRatio(17.0f), vAdjustByScreenRatio(10.0f));
            rect.size = CGSizeMake(vAdjustByScreenRatio(286.0f), vAdjustByScreenRatio(35.0f));
            [self setTriggerSSVCBtn:[UIButton buttonWithType:UIButtonTypeSystem]];
            [_triggerSSVCBtn setFrame:rect];
            [_triggerSSVCBtn setBackgroundColor:[UIColor colorWithRed:0.863f green:0.863f blue:0.863f alpha:1.00f]];
            [_triggerSSVCBtn setTitleColor:[UIColor colorWithRed:0.208f green:0.208f blue:0.208f alpha:1.00f] forState:UIControlStateNormal];
            [_triggerSSVCBtn.titleLabel setFont:[UIFont systemFontOfSize:_triggerSSVCBtn.titleLabel.font.pointSize]];
            [_triggerSSVCBtn setTitle:getLocalizationString(@"appointment_service") forState:UIControlStateNormal];
            _triggerSSVCBtn.shapeLayer = [ImageHandler drawDashedBorderByType:BorderTypeDashed
                                                                       target:_triggerSSVCBtn
                                                                   shapeLayer:_triggerSSVCBtn.shapeLayer
                                                                  borderColor:[UIColor colorWithRed:0.608f green:0.608f blue:0.608f alpha:1.00f]
                                                                 cornerRadius:0
                                                                  borderWidth:2
                                                                  dashPattern:4
                                                                 spacePattern:5
                                                              numberOfColumns:0
                                                                 numberOfRows:0];
            [self addSubview:_triggerSSVCBtn];
        }

        if (!_seletedServiceTV) {
            [self setSeletedServiceTV:[[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain]];
            [_seletedServiceTV setTransform:CGAffineTransformMakeRotation(-M_PI_2)];
            [_seletedServiceTV setFrame:self.bounds];
            [_seletedServiceTV setBounces:NO];
            [_seletedServiceTV setShowsHorizontalScrollIndicator:NO];
            [_seletedServiceTV setShowsVerticalScrollIndicator:NO];
            [_seletedServiceTV setSeparatorStyle:UITableViewCellSeparatorStyleNone];
            [_seletedServiceTV setRowHeight:CGRectGetWidth(self.bounds)];
            [_seletedServiceTV setPagingEnabled:NO];
//            [_seletedServiceTV setDelegate:self];
//            [_seletedServiceTV setDataSource:self];
            [_seletedServiceTV setHidden:YES];
            [_seletedServiceTV setContentOffset:CGPointMake(0.0f, CGRectGetWidth(self.bounds))];
            [self addSubview:_seletedServiceTV];
        }
    }
}



#pragma -mark UITableViewDelgate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CDZKeyOfCellIdentKey];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CDZKeyOfCellIdentKey];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell setBackgroundColor:[UIColor blackColor]];
        [cell setTransform:CGAffineTransformMakeRotation(M_PI_2)];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [imageView setTag:9090];
        [cell addSubview:imageView];
        
    }
    // Configure the cell...

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 0.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return 0.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGRectGetWidth(self.bounds);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

@end
