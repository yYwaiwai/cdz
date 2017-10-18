//
//  InsuranceInfoFormCell.h
//  cdzer
//
//  Created by KEns0n on 10/12/15.
//  Copyright © 2015 CDZER. All rights reserved.
//
typedef NS_ENUM(NSInteger, MAIIFType) {
    MAIIFTypeOfSpace,
    MAIIFTypeOfDate,
    MAIIFTypeOfTextField,
    MAIIFTypeOfSegmentedControl,
    MAIIFTypeOfSwitch,
    MAIIFTypeOfFixInfoDisplay,
    MAIIFTypeOfFixInfoDisplayWithSelection,
};

typedef void (^MAIIFResultBlock)(MAIIFType theType, id result, NSIndexPath *indexPath);

#define kContentList @"contentList"
#define kTitle @"title"
#define kMAIIFType @"type"
#define kTextLimit @"textLimit"
#define kValue @"value"
#define kPlaceholder @"placeholder"
#define kKeyboardType @"keyboardType"
#define kPopAction @"popAction"
#define kTarget @"target"
#define kTitleList @"titleList"
#define kExtraString @"extraString"

#import <UIKit/UIKit.h>

@interface InsuranceInfoFormCell : UITableViewCell

@property (nonatomic, assign) UIScrollView *scrollView;

@property (nonatomic, assign) id actionTarget;

@property (nonatomic) NSIndexPath *indexPath;

@property (nonatomic, copy) MAIIFResultBlock resultBlock;

- (void)updateUIDataWithDate:(NSDictionary *)configDetail;

@end
