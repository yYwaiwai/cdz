//
//  EServiceConsultantMapAnnotationView.h
//  cdzer
//
//  Created by KEns0nLau on 6/3/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import "HCSStarRatingView.h"

typedef void(^ESMAnnotationViewActionBlock)(NSString *consultantID);

@interface EServiceConsultantMapAnnotationView : BMKAnnotationView

@property (nonatomic, strong) NSString *consultantID;

@property (nonatomic, weak) IBOutlet UILabel *consultantNameLabel;

@property (nonatomic, weak) IBOutlet HCSStarRatingView *consultantRatingView;

@property (nonatomic, weak) IBOutlet UIImageView *consultantPortrait;

@property (nonatomic, copy) ESMAnnotationViewActionBlock actionBlock;
@end
