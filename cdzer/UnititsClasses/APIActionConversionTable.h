//
//  APIActionConversionTable.h
//  cdzer
//
//  Created by KEns0n on 1/30/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APIActionConvertedObject : NSObject

@property (nonatomic, strong, readonly) NSString *actionString;

@property (nonatomic, strong, readonly) NSString *title;

@property (nonatomic, strong, readonly) id objects;

@property (nonatomic, assign, readonly) Class targetViewClass;

@property (nonatomic, assign, readonly) BOOL shouldLogin;

@property (nonatomic, assign, readonly) BOOL shouldNavPush;

@property (nonatomic, assign, readonly) BOOL withAnimation;

@end

@interface APIActionConversionTable : NSObject

+ (void)runTheAction:(APIActionConvertedObject *)config;

+ (APIActionConvertedObject *)getAPIActionConversionDetailWithActionString:(NSString*)actionString withObjects:(id)objects title:(NSString*)title;
@end