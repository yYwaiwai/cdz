//
//  EServiceMapPointAnnotation.h
//  cdzer
//
//  Created by KEns0nLau on 6/13/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <Foundation/Foundation.h>

@interface EServiceMapPointAnnotation : BMKPointAnnotation

@property (nonatomic, strong) NSString *consultantID;

@property (nonatomic, strong) NSString *consultantPortraitString;

@property (nonatomic, strong) NSString *consultantName;

@property (nonatomic, strong) NSNumber *starValue;

@end
