//
//  RepairItemCell.h
//  cdzer
//
//  Created by KEns0nLau on 8/25/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RepairItemCell : UITableViewCell

@property (nonatomic, assign) BOOL hiddenDistanceNShopNameView;

- (void)updateUIData:(NSDictionary *)dataDetail;

@end
