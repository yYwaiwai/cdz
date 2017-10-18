//
//  SNSSLViewFilterViewConfig.h
//  cdzer
//
//  Created by KEns0n on 24/10/2016.
//  Copyright © 2016 CDZER. All rights reserved.
//

#ifndef SNSSLViewFilterViewConfig_h
#define SNSSLViewFilterViewConfig_h


typedef NS_ENUM(NSUInteger, SNSSLVFilterType) {
    SNSSLVFilterTypeOfAll = 1,
    SNSSLVFilterTypeOfBrandOption = 2,
    SNSSLVFilterTypeOfSpecRepairOption = 3,
};

typedef void(^SNSSLViewFilterViewResultBlock)();

#endif /* SNSSLViewFilterViewConfig_h */
