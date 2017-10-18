//
//  MyAutosInfoInputView.h
//  cdzer
//
//  Created by KEns0n on 4/25/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#define kNullString @"null"

typedef NS_ENUM(NSInteger, MAIInputType) {
    MAIInputTypeOfNone,
    MAIInputTypeOfLicensePlate,
    MAIInputTypeOfAutosSelection,
    MAIInputTypeOfAutosBodyColor,
    MAIInputTypeOfAutosFrameNumber,
    MAIInputTypeOfAutosEngineNumber,
    MAIInputTypeOfInitialMileage,
    MAIInputTypeOfAutosInsuranceNumber,
    MAIInputTypeOfAutosInsuranceDate,
    MAIInputTypeOfAutosAnniversaryCheckDate,
    MAIInputTypeOfAutosMaintenanceDate,
    MAIInputTypeOfAutosRegisterDate,
};

typedef void (^MAICompletionBlock)(MAIInputType type, NSDictionary *result);
#import <UIKit/UIKit.h>

static NSString * const MAIInputKeyFirstValue = @"MAIInputKeyFirstValue";
static NSString * const MAIInputKeySecondValue = @"MAIInputKeySecondValue";
static NSString * const MAIInputKeyThirdValue = @"MAIInputKeyThirdValue";
static NSString * const MAIInputKeyFourthValue = @"MAIInputKeyFourthValue";

@interface MyAutosInfoInputView : UIControl

@property (nonatomic, strong) NSString *userAutosID;

- (void)initAutoDataAndSelect:(NSString *)theIDsString;

- (void)setInputType:(MAIInputType)inputType withOriginalValue:(NSString *)originalValue;

- (void)setMAICompletionBlock:(MAICompletionBlock)completionBlock;

- (void)showView;

@end
