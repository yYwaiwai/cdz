//
//  VRLVTableViewCell.h
//  cdzer
//
//  Created by KEns0n on 1/5/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VRLVTableViewCell : UITableViewCell

- (void)updateUIData:(NSDictionary *)detailData withWarningLabel:(NSString *)warningText fullSzie:(NSNumber *)fullSize;
@end
