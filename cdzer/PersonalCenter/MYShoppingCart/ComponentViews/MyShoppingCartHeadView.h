//
//  MyShoppingCartHeadView.h
//  cdzer
//
//  Created by KEns0nLau on 10/10/16.
//  Copyright © 2016 CDZER. All rights reserved.
//
typedef void(^MyShoppingCartHeadViewSelectionBlock)(BOOL selected, NSUInteger sectionIdx);
#import <UIKit/UIKit.h>

@interface MyShoppingCartHeadView : UITableViewHeaderFooterView

@property (weak, nonatomic) IBOutlet UIButton *sectionSelectAllBtn;

@property (weak, nonatomic) IBOutlet UILabel *centerNameLabel;

@property (nonatomic, copy) MyShoppingCartHeadViewSelectionBlock selectionBlock;

@property (nonatomic, assign) NSUInteger sectionIdx;

@end
