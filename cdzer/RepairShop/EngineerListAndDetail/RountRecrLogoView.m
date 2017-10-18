//
//  RountRecrLogoView.m
//  cdzer
//
//  Created by KEns0n on 3/12/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#import "RountRecrLogoView.h"

@interface RountRecrLogoView ()

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIImageView *logoImageView;

@end

@implementation RountRecrLogoView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initializationUI];
    }
    
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initializationUI];
    }
    
    return self;
}

- (void)initializationUI {
    
}

@end
