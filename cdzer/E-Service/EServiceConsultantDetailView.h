//
//  EServiceConsultantDetailView.h
//  cdzer
//
//  Created by KEns0nLau on 6/13/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^EServiceConsultantDetailBtnAction)(NSString *consultantID, NSString *consultantName, NSString *consultantPhone);

@interface EServiceConsultantDetailView : UIControl

@property (nonatomic, assign) CLLocationCoordinate2D userCurrentCoordinate;

@property (nonatomic, strong) NSString *consultantID;

@property (nonatomic, copy) EServiceConsultantDetailBtnAction btnAction;

- (void)showDetailView;

@end
