//
//  InfoTabBtns.m
//  cdzer
//
//  Created by KEns0n on 9/24/15.
//  Copyright © 2015 CDZER. All rights reserved.
//

#import "InfoTabBtns.h"


@implementation ButtonObject

- (instancetype)init {
    
    self = [super init];
    if (self) {
        self.action = nil;
        self.target = nil;
        self.title = nil;
        self.button = nil;
    }
    return self;
}

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
    self.action = nil;
    self.target = nil;
    self.title = nil;
    self.button = nil;
}

@end

@interface InfoTabBtns ()

@property (nonatomic, strong) NSMutableArray *btnList;

@property (nonatomic, copy) ButtonIndexBlock btnIndexBlock;

@end

@implementation InfoTabBtns


- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
    self.btnList = nil;
    self.btnIndexBlock = nil;
}

- (void)setBtnIndex:(NSUInteger)btnIndex {
    _btnIndex = btnIndex;
}

- (void)initializationUIWithButtonObject:(NSArray *)btnList withBtnActionBlock:(ButtonIndexBlock)block {
    self.btnIndex = 0;
    self.backgroundColor = CDZColorOfBackgroudColor;
    self.btnList = btnList.mutableCopy;
    self.btnIndexBlock = block;
    @weakify(self);
    [self setViewBorderWithRectBorder:UIRectBorderTop|UIRectBorderBottom borderSize:1 withColor:CDZColorOfSeperateLineColor withBroderOffset:nil];
    NSUInteger count = btnList.count;
    CGFloat width = CGRectGetWidth(self.frame)/count;
    CGFloat sideOffset = CGRectGetHeight(self.frame)*0.15f;
    [btnList enumerateObjectsUsingBlock:^(id   obj, NSUInteger idx, BOOL *  stop) {
        if ([obj isKindOfClass:ButtonObject.class]) {
            @strongify(self);
            ButtonObject *btnObject = (ButtonObject*)obj;
            UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
            button.tag = idx;
            button.frame = CGRectMake(width*idx, 0.0f, width, CGRectGetHeight(self.frame));
            [button setTitle:btnObject.title forState:UIControlStateNormal];
            [button setTitle:btnObject.title forState:UIControlStateDisabled];
            [button setTitleColor:CDZColorOfDefaultColor forState:UIControlStateNormal];
            [button setTitleColor:CDZColorOfOrangeColor forState:UIControlStateDisabled];
            
            
            [button addTarget:self action:@selector(updateBtnAction:) forControlEvents:UIControlEventTouchUpInside];
            if (btnObject.action&&btnObject.target) {
                SEL selector = NSSelectorFromString(btnObject.action);
                if ([btnObject.target respondsToSelector:selector]) {
                    [button addTarget:btnObject.target action:selector forControlEvents:UIControlEventTouchUpInside];
                }
            }
            
            BorderOffsetObject *offset = BorderOffsetObject.new;
            UIRectBorder border = UIRectBorderNone;
            if (btnObject==btnList.firstObject&&btnObject!=btnList.lastObject) {
                offset.rightUpperOffset = sideOffset;
                offset.rightBottomOffset = sideOffset;
                border = UIRectBorderRight;
            }else if(btnObject!=btnList.firstObject&&btnObject==btnList.lastObject) {
                offset.leftBottomOffset = sideOffset;
                offset.leftUpperOffset = sideOffset;
                border = UIRectBorderLeft;
            }else if(btnObject!=btnList.firstObject&&btnObject!=btnList.lastObject) {
                offset.rightUpperOffset = sideOffset;
                offset.rightBottomOffset = sideOffset;
                
                offset.leftBottomOffset = sideOffset;
                offset.leftUpperOffset = sideOffset;
                border = UIRectBorderLeft|UIRectBorderRight;
            }
            if (!(border&UIRectBorderNone)) {
                [button setViewBorderWithRectBorder:border borderSize:0.5 withColor:CDZColorOfSeperateLineDeepColor withBroderOffset:offset];
            }
            
            if (count>1&&btnObject==btnList.firstObject) {
//                button.backgroundColor = CDZColorOfDeepGray;
                button.enabled = NO;
            }
            
            [self addSubview:button];
            btnObject.button = button;
            [self.btnList replaceObjectAtIndex:idx withObject:btnObject];
        }
    }];
    
}

#pragma mark -  产品信息 和 图文详情 点击的按钮事件
- (void)updateBtnAction:(UIButton *)button {
    @autoreleasepool {
        NSArray *btnList = self.btnList;
//        @weakify(self);
        [btnList enumerateObjectsUsingBlock:^(id   obj, NSUInteger idx, BOOL *  stop) {
            if ([obj isKindOfClass:ButtonObject.class]) {
                ButtonObject *btnObject = (ButtonObject*)obj;
                btnObject.button.backgroundColor = CDZColorOfClearColor;
                btnObject.button.enabled = YES;
                
            }
        }];
        
    }
    
//    button.backgroundColor = CDZColorOfDeepGray;
    button.enabled = NO;
    if (_btnIndexBlock) {
        self.btnIndex = button.tag;
        // 通知block调用
        _btnIndexBlock(button.tag);
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
