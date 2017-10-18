//
//  RepairSectionBtnsView.m
//  cdzer
//
//  Created by KEns0n on 3/4/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//
#define vUpperStandardHeight 30.0f
#define vStandardHeight 150.0f

#import "RepairSectionBtnsView.h"

@interface RepairSectionBtnsView ()

@property (nonatomic, strong) UIView *upperView;

@property (nonatomic, strong) UIView *bottomView;

@end

@implementation RepairSectionBtnsView

- (instancetype)initWithOrigin:(CGPoint)origin {
    CGFloat height = vAdjustByScreenRatio(vStandardHeight+vUpperStandardHeight);
    
    self = [super initWithFrame:CGRectMake(origin.x, origin.y+vAdjustByScreenRatio(vO2OSpaceSpace), SCREEN_WIDTH, height)];
    if (self) {
        [self initializationUI];
    }
    return self;
}

- (void)setAllButtonTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents {
    
    [self.searchBtn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [self.diagnosisBtn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [self.careServiceBtn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [self.casesBtn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [self.encyclopediaBtn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [self.quickServiceBtn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}

- (void)initializationUI {
    [self setBackgroundColor:[UIColor clearColor]];
    
//    [self setShapeLayer:[ImageHandler drawDashedBorderByType:BorderTypeSolid target:self shapeLayer:self.shapeLayer borderColor:[UIColor colorWithRed:0.882f green:0.882f blue:0.882f alpha:1.00f] cornerRadius:0 borderWidth:2 dashPattern:0 spacePattern:0 numberOfColumns:2 numberOfRows:2]];
    
    
    CGFloat titleLabelExtWidth = vAdjustByScreenRatio(10.0f);
    CGFloat titleLabelExtHeight = vAdjustByScreenRatio(20.0f);
    CGFloat leftSideMargin = vAdjustByScreenRatio(32.0f)-titleLabelExtWidth/2;
    CGFloat topSideMargin = vAdjustByScreenRatio(8.0f);
    CGFloat titleSpace = vAdjustByScreenRatio(5.0f);
    CGFloat fontSize = vAdjustByScreenRatio(12.0f);
    
    
    self.upperView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.frame), vAdjustByScreenRatio(vUpperStandardHeight))];
    [self addSubview:_upperView];
    
    UIImage *qServiceImage = [ImageHandler getImageFromCacheByScreenRatioWithFileRootPath:kSysImageCaches
                                                                                 fileName:@"repair_encyclopedia"
                                                                                     type:FMImageTypeOfPNG
                                                                          scaleWithPhone4:NO
                                                                              offsetRatioForP4:1.0f
                                                                             needToUpdate:YES];
    CGRect qMaintenanceBtnRect = CGRectZero;
    qMaintenanceBtnRect.size.width = qServiceImage.size.width + titleLabelExtWidth;
    qMaintenanceBtnRect.size.height = qServiceImage.size.height + titleLabelExtHeight;
    
    self.encyclopediaBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_encyclopediaBtn setFrame:qMaintenanceBtnRect];
    [_encyclopediaBtn setContentVerticalAlignment:UIControlContentVerticalAlignmentTop];
    [_encyclopediaBtn setImageEdgeInsets:UIEdgeInsetsMake(0.0f, titleLabelExtWidth/2, 0.0f, 0.0f)];
    [_encyclopediaBtn setTitleEdgeInsets:UIEdgeInsetsMake(qServiceImage.size.height+titleSpace, -qServiceImage.size.width, 0.0f, 0.0f)];
    [_encyclopediaBtn setTitle:getLocalizationString(@"repair_encyclopedia") forState:UIControlStateNormal];
    [_encyclopediaBtn setImage:qServiceImage forState:UIControlStateNormal];
    [_encyclopediaBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_encyclopediaBtn.titleLabel setFont:[UIFont systemFontOfSize:fontSize]];
    [_encyclopediaBtn.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [_encyclopediaBtn setTag:99];
    [_upperView addSubview:_encyclopediaBtn];
    _encyclopediaBtn.hidden = YES;
    CGRect upperFrame = _upperView.frame;
    upperFrame.size.height = CGRectGetHeight(_encyclopediaBtn.frame)+vAdjustByScreenRatio(12.0f);
    _upperView.frame = upperFrame;
    [_encyclopediaBtn setCenter:CGPointMake(CGRectGetWidth(_upperView.frame)/2, CGRectGetHeight(_upperView.frame)/2)];
    
    
    
    self.bottomView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(_upperView.frame), CGRectGetWidth(self.frame), vAdjustByScreenRatio(vStandardHeight))];
    [self addSubview:_bottomView];
    
    
    
    UIImage *searchImage = [ImageHandler getImageFromCacheByScreenRatioWithFileRootPath:kSysImageCaches
                                                                               fileName:@"search_businesses"
                                                                                   type:FMImageTypeOfPNG
                                                                        scaleWithPhone4:NO
                                                                            offsetRatioForP4:1.0f
                                                                           needToUpdate:YES];
    CGRect searchBtnRect = CGRectZero;
    searchBtnRect.size = searchImage.size;
    [self setSearchBtn:[UIButton buttonWithType:UIButtonTypeCustom]];
    [_searchBtn setImage:searchImage forState:UIControlStateNormal];
    [_searchBtn setFrame:searchBtnRect];
    [_searchBtn setCenter:CGPointMake(CGRectGetWidth(_bottomView.frame)/2, CGRectGetHeight(_bottomView.frame)/2)];
    [_searchBtn setTag:100];
    [_bottomView addSubview:_searchBtn];
    
    UIImage *diagnosisImage = [ImageHandler getImageFromCacheByScreenRatioWithFileRootPath:kSysImageCaches
                                                                                  fileName:@"self_diagnosis"
                                                                                      type:FMImageTypeOfPNG
                                                                           scaleWithPhone4:NO
                                                                               offsetRatioForP4:1.0f
                                                                              needToUpdate:YES];
    CGRect diagnosisBtnRect = CGRectZero;
    diagnosisBtnRect.origin = CGPointMake(leftSideMargin, topSideMargin);
    diagnosisBtnRect.size.width = diagnosisImage.size.width + titleLabelExtWidth;
    diagnosisBtnRect.size.height = diagnosisImage.size.height + titleLabelExtHeight;
    
    [self setDiagnosisBtn:[UIButton buttonWithType:UIButtonTypeCustom]];
    [_diagnosisBtn setFrame:diagnosisBtnRect];
    [_diagnosisBtn setContentVerticalAlignment:UIControlContentVerticalAlignmentTop];
    [_diagnosisBtn setImageEdgeInsets:UIEdgeInsetsMake(0.0f, titleLabelExtWidth/2, 0.0f, 0.0f)];
    [_diagnosisBtn setTitleEdgeInsets:UIEdgeInsetsMake(diagnosisImage.size.height+titleSpace, -diagnosisImage.size.width, 0.0f, 0.0f)];
    [_diagnosisBtn setTitle:getLocalizationString(@"self_diagnosis") forState:UIControlStateNormal];
    [_diagnosisBtn setImage:diagnosisImage forState:UIControlStateNormal];
    [_diagnosisBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_diagnosisBtn.titleLabel setFont:[UIFont systemFontOfSize:fontSize]];
    [_diagnosisBtn.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [_diagnosisBtn setTag:101];
    [_bottomView addSubview:_diagnosisBtn];
    
    UIImage *careServiceImage = [ImageHandler getImageFromCacheByScreenRatioWithFileRootPath:kSysImageCaches
                                                                                    fileName:@"self_care"
                                                                                        type:FMImageTypeOfPNG
                                                                             scaleWithPhone4:NO
                                                                                 offsetRatioForP4:1.0f
                                                                                needToUpdate:YES];
    CGRect careServiceBtnRect = CGRectZero;
    careServiceBtnRect.origin.x = CGRectGetWidth(_bottomView.frame)-CGRectGetWidth(diagnosisBtnRect)-leftSideMargin;
    careServiceBtnRect.origin.y = topSideMargin;
    careServiceBtnRect.size.width = careServiceImage.size.width + titleLabelExtWidth;
    careServiceBtnRect.size.height = careServiceImage.size.height + titleLabelExtHeight;
    
    [self setCareServiceBtn:[UIButton buttonWithType:UIButtonTypeCustom]];
    [_careServiceBtn setFrame:careServiceBtnRect];
    [_careServiceBtn setContentVerticalAlignment:UIControlContentVerticalAlignmentTop];
    [_careServiceBtn setImageEdgeInsets:UIEdgeInsetsMake(0.0f, titleLabelExtWidth/2, 0.0f, 0.0f)];
    [_careServiceBtn setTitleEdgeInsets:UIEdgeInsetsMake(careServiceImage.size.height+titleSpace, -careServiceImage.size.width, 0.0f, 0.0f)];
    [_careServiceBtn setTitle:getLocalizationString(@"self_care") forState:UIControlStateNormal];
    [_careServiceBtn setImage:careServiceImage forState:UIControlStateNormal];
    [_careServiceBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_careServiceBtn.titleLabel setFont:[UIFont systemFontOfSize:fontSize]];
    [_careServiceBtn.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [_careServiceBtn setTag:102];
    [_bottomView addSubview:_careServiceBtn];
    
    UIImage *casesImage = [ImageHandler getImageFromCacheByScreenRatioWithFileRootPath:kSysImageCaches
                                                                              fileName:@"get_cases"
                                                                                  type:FMImageTypeOfPNG
                                                                       scaleWithPhone4:NO
                                                                           offsetRatioForP4:1.0f
                                                                          needToUpdate:YES];
    CGRect casesBtnRect = CGRectZero;
    casesBtnRect.origin.x = leftSideMargin;
    casesBtnRect.origin.y = topSideMargin+CGRectGetHeight(_bottomView.frame)/2;
    casesBtnRect.size.width = casesImage.size.width + titleLabelExtWidth;
    casesBtnRect.size.height = casesImage.size.height + titleLabelExtHeight;
    
    [self setCasesBtn:[UIButton buttonWithType:UIButtonTypeCustom]];
    [_casesBtn setFrame:casesBtnRect];
    [_casesBtn setContentVerticalAlignment:UIControlContentVerticalAlignmentTop];
    [_casesBtn setImageEdgeInsets:UIEdgeInsetsMake(0.0f, titleLabelExtWidth/2, 0.0f, 0.0f)];
    [_casesBtn setTitleEdgeInsets:UIEdgeInsetsMake(casesImage.size.height+titleSpace, -casesImage.size.width, 0.0f, 0.0f)];
    [_casesBtn setTitle:getLocalizationString(@"get_cases") forState:UIControlStateNormal];
    [_casesBtn setImage:casesImage forState:UIControlStateNormal];
    [_casesBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_casesBtn.titleLabel setFont:[UIFont systemFontOfSize:fontSize]];
    [_casesBtn.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [_casesBtn setTag:103];
    [_bottomView addSubview:_casesBtn];
    
    
    UIImage *encyclopediaImage = [ImageHandler getImageFromCacheByScreenRatioWithFileRootPath:kSysImageCaches
                                                                                     fileName:@"quick_repair"
                                                                                         type:FMImageTypeOfPNG
                                                                              scaleWithPhone4:NO
                                                                                  offsetRatioForP4:1.0f
                                                                                 needToUpdate:YES];
    CGRect encyclopediaBtnRect = CGRectZero;
    encyclopediaBtnRect.origin.x = CGRectGetWidth(_bottomView.frame)-CGRectGetWidth(diagnosisBtnRect)-leftSideMargin;
    encyclopediaBtnRect.origin.y = topSideMargin+CGRectGetHeight(_bottomView.frame)/2;
    encyclopediaBtnRect.size.width = encyclopediaImage.size.width + titleLabelExtWidth;
    encyclopediaBtnRect.size.height = encyclopediaImage.size.height + titleLabelExtHeight;
    
    [self setQuickServiceBtn:[UIButton buttonWithType:UIButtonTypeCustom]];
    [_quickServiceBtn setFrame:encyclopediaBtnRect];
    [_quickServiceBtn setContentVerticalAlignment:UIControlContentVerticalAlignmentTop];
    [_quickServiceBtn setImageEdgeInsets:UIEdgeInsetsMake(0.0f, titleLabelExtWidth/2, 0.0f, 0.0f)];
    [_quickServiceBtn setTitleEdgeInsets:UIEdgeInsetsMake(encyclopediaImage.size.height+titleSpace, -encyclopediaImage.size.width, 0.0f, 0.0f)];
    [_quickServiceBtn setTitle:getLocalizationString(@"quick_maintenance") forState:UIControlStateNormal];
    [_quickServiceBtn setImage:encyclopediaImage forState:UIControlStateNormal];
    [_quickServiceBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_quickServiceBtn.titleLabel setFont:[UIFont systemFontOfSize:fontSize]];
    [_quickServiceBtn.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [_quickServiceBtn setTag:104];
    [_bottomView addSubview:_quickServiceBtn];
    
}

@end
