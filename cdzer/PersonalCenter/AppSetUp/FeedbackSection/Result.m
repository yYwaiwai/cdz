//
//  Result.m
//
//  Created by 队长 车 on 16/1/30
//  Copyright (c) 2016 __MyCompanyName__. All rights reserved.
//

#import "Result.h"


NSString *const kResultId = @"id";
NSString *const kResultContent = @"content";
NSString *const kResultReply = @"reply";
NSString *const kResultTel = @"tel";


@interface Result ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation Result

@synthesize resultIdentifier = _resultIdentifier;
@synthesize content = _content;
@synthesize reply = _reply;
@synthesize tel = _tel;


+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict
{
    return [[self alloc] initWithDictionary:dict];
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
            self.resultIdentifier = [self objectOrNilForKey:kResultId fromDictionary:dict];
            self.content = [self objectOrNilForKey:kResultContent fromDictionary:dict];
            self.reply = [self objectOrNilForKey:kResultReply fromDictionary:dict];
            self.tel = [self objectOrNilForKey:kResultTel fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.resultIdentifier forKey:kResultId];
    [mutableDict setValue:self.content forKey:kResultContent];
    [mutableDict setValue:self.reply forKey:kResultReply];
    [mutableDict setValue:self.tel forKey:kResultTel];

    return [NSDictionary dictionaryWithDictionary:mutableDict];
}

- (NSString *)description 
{
    return [NSString stringWithFormat:@"%@", [self dictionaryRepresentation]];
}

#pragma mark - Helper Method
- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict
{
    id object = [dict objectForKey:aKey];
    return [object isEqual:[NSNull null]] ? nil : object;
}


#pragma mark - NSCoding Methods

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];

    self.resultIdentifier = [aDecoder decodeObjectForKey:kResultId];
    self.content = [aDecoder decodeObjectForKey:kResultContent];
    self.reply = [aDecoder decodeObjectForKey:kResultReply];
    self.tel = [aDecoder decodeObjectForKey:kResultTel];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_resultIdentifier forKey:kResultId];
    [aCoder encodeObject:_content forKey:kResultContent];
    [aCoder encodeObject:_reply forKey:kResultReply];
    [aCoder encodeObject:_tel forKey:kResultTel];
}

- (id)copyWithZone:(NSZone *)zone
{
    Result *copy = [[Result alloc] init];
    
    if (copy) {

        copy.resultIdentifier = [self.resultIdentifier copyWithZone:zone];
        copy.content = [self.content copyWithZone:zone];
        copy.reply = [self.reply copyWithZone:zone];
        copy.tel = [self.tel copyWithZone:zone];
    }
    
    return copy;
}


@end
