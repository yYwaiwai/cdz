//
//  NetProgressImageView.h
//  cdzer
//
//  Created by KEns0n on 4/22/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NetProgressImageView : UIView

@property (nonatomic, strong) NSString *imageURL;

@property (nonatomic, strong) NSString *fileName;

@property (nonatomic, strong) NSString *type;

- (instancetype)initWithImageURL:(NSString *)imageURL frame:(CGRect)frame;

- (void)clearImage;
@end
