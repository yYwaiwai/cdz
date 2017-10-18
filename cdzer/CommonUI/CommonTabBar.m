//
//  CommonTabBar.m
//  cdzer
//
//  Created by KEns0n on 2/10/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#import "CommonTabBar.h"
#import "FileManager.h"

@interface CommonTabBar ()<UITabBarDelegate>

@property (nonatomic, assign) NSInteger currentSelectID;

@end

@implementation CommonTabBar

static CGFloat tabBarFixHeight = 49.0f;
static CGFloat navBarFixHeight = 44.0f;

- (instancetype)init {
    self = [self initWithFrame:CGRectZero];
    if (self) {
    
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    CGRect rect = [[UIScreen mainScreen] bounds];
    self = [super initWithFrame:CGRectMake(0.0f,
                                           CGRectGetHeight(rect)-tabBarFixHeight-navBarFixHeight,
                                           (CGRectGetWidth(frame)<=0.0f)?CGRectGetWidth(rect):CGRectGetWidth(frame),
                                           tabBarFixHeight)];
    if (self) {}
    return self;
}

BOOL isSetUI = NO;

- (void)initializationUIWithID:(NSInteger)theID {
    @autoreleasepool {
        if (isSetUI) {
            return;
        }
        if (theID>2) {
            theID = 2;
        }else if (theID<0){
            theID = 0;
        }
        
        [self setDelegate:self];
        
        UIImage *imageTab1 = [ImageHandler getImageFromCacheWithByFixdeRatioFileRootPath:kSysImageCaches fileName:@"home_off" type:FMImageTypeOfPNG needToUpdate:YES];
        UIImage *imageTab2 = [ImageHandler getImageFromCacheWithByFixdeRatioFileRootPath:kSysImageCaches fileName:@"shopping_cart_off" type:FMImageTypeOfPNG needToUpdate:YES];
        UIImage *imageTab3 = [ImageHandler getImageFromCacheWithByFixdeRatioFileRootPath:kSysImageCaches fileName:@"personal_center_off" type:FMImageTypeOfPNG needToUpdate:YES];
        
        UITabBarItem *tabBarItem1 = [[UITabBarItem alloc] initWithTitle:getLocalizationString(@"home") image:imageTab1 tag:0];
        UITabBarItem *tabBarItem2 = [[UITabBarItem alloc] initWithTitle:getLocalizationString(@"shopping_cart") image:imageTab2 tag:1];
        UITabBarItem *tabBarItem3 = [[UITabBarItem alloc] initWithTitle:getLocalizationString(@"personal_center") image:imageTab3 tag:2];
        
        NSArray * tabBarItems = [NSArray arrayWithObjects:tabBarItem1, tabBarItem2, tabBarItem3, nil];
        
        [self setItems:tabBarItems animated:NO];
        [self setCurrentSelectID:theID];
        self.selectedItem = [tabBarItems objectAtIndex:theID];
    }
}

// TabBar Delegate
- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
    if (_currentSelectID==item.tag) return;
    
    [self setCurrentSelectID:item.tag];
    NSLog(@"CurrentID: %02ld", (long)item.tag);
    
    if ([_CTBDelegate respondsToSelector:@selector(commonTabBar:didSelectItemID:)]) {
        [_CTBDelegate commonTabBar:self didSelectItemID:item.tag];
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
