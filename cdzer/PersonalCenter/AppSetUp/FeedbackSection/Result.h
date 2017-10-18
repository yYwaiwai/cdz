//
//  Result.h
//
//  Created by 队长 车 on 16/1/30
//  Copyright (c) 2016 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface Result : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) NSString *resultIdentifier;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *reply;
@property (nonatomic, strong) NSString *tel;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
