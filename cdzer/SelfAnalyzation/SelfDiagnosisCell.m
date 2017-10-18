//
//  SelfDiagnosisCell.m
//  cdzer
//
//  Created by KEns0n on 6/23/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#define cellHeight 40.0f
#import "SelfDiagnosisCell.h"
#import "InsetsLabel.h"
@interface SelfDiagnosisCell ()
{
    UIButton *_currentStepLogo;
    InsetsLabel *_titleLabel;
    InsetsLabel *_subDetailLabel;
}
@end

@implementation SelfDiagnosisCell
@synthesize currentStepLogo = _currentStepLogo;
@synthesize titleLabel = _titleLabel;
@synthesize subDetailLabel = _subDetailLabel;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initializationUI];
    }
    return self;
}

- (void)initializationUI {
    // Initialization code
    @autoreleasepool {
        if (!_currentStepLogo) {
            CGRect rect = CGRectZero;
            rect.origin.x = 15.0;
            CGFloat width = cellHeight*0.6;
            rect.size = CGSizeMake(width, width);
            _currentStepLogo = [UIButton buttonWithType:UIButtonTypeCustom];
            _currentStepLogo.backgroundColor = CDZColorOfDefaultColor;
            _currentStepLogo.alpha = 0.5;
            _currentStepLogo.frame = rect;
            _currentStepLogo.userInteractionEnabled = NO;
            _currentStepLogo.titleLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 13.0f, NO);
            _currentStepLogo.center = CGPointMake(_currentStepLogo.center.x, CGRectGetHeight(self.frame)/2.0f);
            [_currentStepLogo setTitleColor:CDZColorOfWhite forState:UIControlStateNormal];
            [_currentStepLogo setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:CGRectGetHeight(_currentStepLogo.frame)/2.0f];
            [self.contentView addSubview:_currentStepLogo];
            _currentStepLogo.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
            _currentStepLogo.translatesAutoresizingMaskIntoConstraints = YES;
        }
        
        if (!_titleLabel) {
            CGRect rect = self.bounds;
            _titleLabel = [[InsetsLabel alloc] initWithFrame:rect
                                                   andEdgeInsetsValue:UIEdgeInsetsMake(0.0f, CGRectGetMaxX(_currentStepLogo.frame)+5.0f, 0.0f, 15.0f)];
            _titleLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 16.0f, NO);
            [self.contentView addSubview:_titleLabel];
            _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
            _titleLabel.translatesAutoresizingMaskIntoConstraints = YES;
            
        }
        
        if (!_subDetailLabel) {
            CGRect rect = self.bounds;
            rect.origin.x = CGRectGetWidth(self.bounds)/2.0f;
            rect.size.width = CGRectGetWidth(self.bounds)/2.0f;
            _subDetailLabel = [[InsetsLabel alloc] initWithFrame:rect
                                                   andEdgeInsetsValue:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 15.0f)];
            _subDetailLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 15.0f, NO);
            _subDetailLabel.textColor = CDZColorOfDefaultColor;
            [self.contentView addSubview:_subDetailLabel];
            _subDetailLabel.numberOfLines = 0;
            _subDetailLabel.textAlignment = NSTextAlignmentRight;
            _subDetailLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
            _subDetailLabel.translatesAutoresizingMaskIntoConstraints = YES;
            
        }
    }
}


@end
