//
//  MaterialScienceCell.h
//  cdzer
//
//  Created by 车队长 on 16/11/18.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSUInteger, MSCellAction) {
    MSCellActionOfUpdatePartName,
    MSCellActionOfUpdateCounting,
    MSCellActionOfUpdatePartPrice,
    MSCellActionOfDeleteRow
};

typedef void(^MSCellActionBlock)(MSCellAction action, NSString *value, NSIndexPath *indexPath);
@interface MaterialScienceCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UITextField *partsTF;

@property (weak, nonatomic) IBOutlet UITextField *numberTF;

@property (weak, nonatomic) IBOutlet UITextField *unitPriceTF;

@property (nonatomic, copy) MSCellActionBlock actionBlock;

@property (nonatomic, strong) NSIndexPath *indexPath;




@end
