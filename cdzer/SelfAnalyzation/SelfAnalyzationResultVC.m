//
//  SelfAnalyzationResultVC.m
//  cdzer
//
//  Created by KEns0n on 3/17/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#define startPointX vAdjustByScreenRatio(14.0f)
#define startPointY vAdjustByScreenRatio(8.0f)


#import "SelfAnalyzationResultVC.h"
#import "VENSeparatorView.h"

@interface SelfAnalyzationResultVC ()

@property (nonatomic, strong) VENSeparatorView *vensView;

@end

@implementation SelfAnalyzationResultVC

- (void) viewDidLoad {
    [super viewDidLoad];
    [self.contentView setBackgroundColor:[UIColor colorWithRed:0.953f green:0.953f blue:0.953f alpha:1.00f]];
    [self setTitle:getLocalizationString(@"analyzation_result")];
    [self initializationUI];
    // Do any additional setup after loading the view, typically from a nib.
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)initializationUI {
    UIView *selectedCarView = [[UIView alloc] initWithFrame:CGRectMake(startPointX,
                                                                     startPointY,
                                                                     CGRectGetWidth(self.contentView.frame)-startPointX*2.0f,
                                                                     vAdjustByScreenRatio(32.0f))];
    [selectedCarView setBackgroundColor:[UIColor colorWithRed:0.933f green:0.933f blue:0.933f alpha:1.00f]];
    [selectedCarView setBorderWithColor:[UIColor colorWithRed:0.882f green:0.882f blue:0.882f alpha:1.00f] borderWidth:(1.0f)];
    [self.contentView addSubview:selectedCarView];
    
    
    CGFloat borderWidth = vAdjustByScreenRatio(4.0f);
    CGRect selectedCarLblRect = selectedCarView.bounds;
    selectedCarLblRect.origin.x = borderWidth;
    selectedCarLblRect.origin.y = borderWidth;
    selectedCarLblRect.size.width -= borderWidth*2.0f;
    selectedCarLblRect.size.height -= borderWidth*2.0f;
    UILabel *selectedCarLabel = [[UILabel alloc] initWithFrame:selectedCarLblRect];
    [selectedCarLabel setBackgroundColor:CDZColorOfWhite];
    [selectedCarLabel setBorderWithColor:[UIColor colorWithRed:0.906f green:0.906f blue:0.906f alpha:1.00f] borderWidth:(1.0f)];
    [selectedCarLabel setFont:[UIFont systemFontOfSize:vAdjustByScreenRatio(14.0f)]];
    [selectedCarLabel setText:@" 进口宝马 E39 520i  2.0L 1945年产"];
    [selectedCarView addSubview:selectedCarLabel];
    
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    CGFloat rdViewPointY = vAdjustByScreenRatio(vO2OSpaceSpace)+CGRectGetMaxY(selectedCarView.frame);
    CGRect rdViewRect = selectedCarView.frame;
    rdViewRect.origin.y = rdViewPointY;
    rdViewRect.size.height = vAdjustByScreenRatio(240.0f);
    UIView *resultDetailView = [[UIView alloc] initWithFrame:rdViewRect];
    [resultDetailView setBackgroundColor:[UIColor clearColor]];
    [self.contentView addSubview:resultDetailView];
    
    CGRect longRectBkgRect = CGRectZero;
    longRectBkgRect.size.width = CGRectGetWidth(rdViewRect);
    longRectBkgRect.size.height = vAdjustByScreenRatio(20.0f);
    UIImageView *longRectBkgView = [[UIImageView alloc] initWithFrame:longRectBkgRect];
    [longRectBkgView setBackgroundColor:[UIColor colorWithRed:0.855f green:0.847f blue:0.851f alpha:1.00f]];
    [longRectBkgView.layer setCornerRadius:CGRectGetHeight(longRectBkgRect)/2];
    [longRectBkgView.layer setMasksToBounds:YES];
    [resultDetailView addSubview:longRectBkgView];
    
    CGFloat vensViewPointX = vAdjustByScreenRatio(23.0f)-startPointX;
    CGRect vensViewRect = resultDetailView.bounds;
    vensViewRect.origin.y = CGRectGetMidY(longRectBkgRect);
    vensViewRect.origin.x = vensViewPointX;
    vensViewRect.size.height -= CGRectGetMidY(longRectBkgRect);
    vensViewRect.size.width -= vensViewPointX*2.0f;
    
    [self setVensView:[[VENSeparatorView alloc] initWithFrame:vensViewRect topLineSeparatorType:VENSeparatorTypeJagged bottomLineSeparatorType:VENSeparatorTypeJagged]];
    [_vensView setJaggedEdgeHorizontalVertexDistance:vAdjustByScreenRatio(8.0f)];
    [_vensView setJaggedEdgeVerticalVertexDistance:vAdjustByScreenRatio(15.0f)];
    [_vensView setIsNeedLRSideBorder:YES];
    [_vensView setFillColor:[UIColor colorWithRed:0.953f green:0.953f blue:0.953f alpha:1.00f]];
    [_vensView setBackgroundColor:[UIColor clearColor]];
    [_vensView.layer setMasksToBounds:YES];
    [resultDetailView addSubview:_vensView];
    
    
    
    
}

@end
