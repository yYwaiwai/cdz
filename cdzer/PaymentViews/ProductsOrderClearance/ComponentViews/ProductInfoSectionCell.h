//
//  ProductInfoSectionCell.h
//  cdzer
//
//  Created by KEns0nLau on 9/22/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CDZOPCObjectComponents.h"

//typedef void(^PISCDataReloadBlock)(NSIndexPath *indexPath, BOOL showPayeeNameLabel);

@interface ProductInfoSectionCell : UITableViewCell

@property (nonatomic, weak) UITableView *tvContainerView;

@property (nonatomic, strong) NSIndexPath *indexPath;

//@property (nonatomic, copy) PISCDataReloadBlock reloadBlock;

- (void)updateUIDataConfig:(PISCConfigObject *)configObject;

@end
