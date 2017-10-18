//
//  RepairItemNWorkingPriceInfoView.h
//  cdzer
//
//  Created by KEns0nLau on 9/30/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RepairItemNWorkingPriceInfoView : UIView

@property (nonatomic, readonly) BOOL isNeedInvoice;

@property (nonatomic, strong, readonly) NSString *payeeNameString;

- (void)updateUIData:(NSDictionary *)sourceData;

@end
