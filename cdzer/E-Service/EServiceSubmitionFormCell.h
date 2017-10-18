//
//  EServiceSubmitionFormCell.h
//  cdzer
//
//  Created by KEns0nLau on 6/7/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kTitle @"title"
#define kValue @"value"
#define kType @"type"
#define vKeyboardType @"keyboardType"
#define kPlaceHolder @"placeHolder"
#define kMaxStringLength @"maxStringLength"
#define kSelectionList @"SelectionList"
#define kSCSelectedList @"SCSelectedList"
#define kSeletor @"seletor"

typedef NS_ENUM(NSUInteger, EServiceFormAction) {
    EServiceFormActionOfDisplayOnly = 0,
    EServiceFormActionOfTextField,
    EServiceFormActionOfDateTime,
    EServiceFormActionOfSelector,
    EServiceFormActionOfPickerSelection,
    EServiceFormActionOfSegmentedControl,
};

typedef void(^EServiceSubmitionFormCellResponse)(NSIndexPath *indexPath, NSString *value);

@interface EServiceSubmitionFormCell : UITableViewCell

@property (nonatomic, assign) BOOL showDisplayView;

@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, copy) EServiceSubmitionFormCellResponse responseBlock;

- (void)configViewDisplay:(NSDictionary *)dataConfig withValue:(NSString *)valueString;

@end
