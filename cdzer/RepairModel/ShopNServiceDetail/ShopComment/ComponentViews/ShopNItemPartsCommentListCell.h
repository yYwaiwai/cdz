//
//  ShopNItemPartsCommentListCell.h
//  cdzer
//
//  Created by KEns0nLau on 9/2/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ShopMechanicCommentDetailDTO;

@interface ShopNItemPartsCommentListCell : UITableViewCell

- (void)updateUIData:(NSDictionary *)dataDetail;

- (void)updateUIDataByDto:(ShopMechanicCommentDetailDTO *)detailData;
@end
