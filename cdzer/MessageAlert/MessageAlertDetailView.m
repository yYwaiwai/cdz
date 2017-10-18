//
//  MessageAlertDetailView.m
//  cdzer
//
//  Created by KEns0n on 12/19/15.
//  Copyright © 2015 CDZER. All rights reserved.
//  信息详情数据视图

#import "InsetsLabel.h"
#import "MessageAlertDetailView.h"

@interface MessageAlertDetailView ()
/// 白色View
@property (nonatomic, strong) UIView *contentView;
/// 返回按键
@property (nonatomic, strong) UIButton *cancelButton;
/// 信息视图
@property (nonatomic, strong) UITextView *textView;

@end

@implementation MessageAlertDetailView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (instancetype)init {
    self = [self initWithFrame:CGRectZero];
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:UIScreen.mainScreen.bounds];
    if (self) {
        [self initializationUI];
    }
    return self;
}

- (void)initializationUI {
    @autoreleasepool {
        [self addTarget:self action:@selector(hiddenItemListView) forControlEvents:UIControlEventTouchUpInside];
        
        self.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.75f];
        
        CGFloat offset = CGRectGetWidth(self.frame)*0.05;
        self.contentView = [[UIView alloc] initWithFrame:CGRectMake(offset, offset*2.5f,
                                                                    CGRectGetWidth(self.bounds)-offset*2.0f,
                                                                    CGRectGetHeight(self.bounds)-offset*5.0f)];
        _contentView.backgroundColor = CDZColorOfWhite;
        _contentView.userInteractionEnabled = NO;
        CGPoint point = _contentView.center;
//        point.y = CGRectGetHeight(self.frame)*1.5f;
        _contentView.center = point;
        [_contentView setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:5.0f];
        [self addSubview:_contentView];
        
        InsetsLabel *title = [[InsetsLabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(_contentView.frame), 40.0f)
                                             andEdgeInsetsValue:DefaultEdgeInsets];
        title.text = @"信息详情";
        title.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfBold, 18.0f, NO);
        BorderOffsetObject *borderOffset = BorderOffsetObject.new;
        borderOffset.bottomLeftOffset = DefaultEdgeInsets.left;
        borderOffset.bottomRightOffset = DefaultEdgeInsets.right;
        [title setViewBorderWithRectBorder:UIRectBorderBottom borderSize:1.0f withColor:CDZColorOfSeperateLineDeepColor withBroderOffset:borderOffset];
        [_contentView addSubview:title];
        
        self.textView = [[UITextView alloc] initWithFrame:CGRectMake(DefaultEdgeInsets.left, CGRectGetMaxY(title.frame),
                                                                     CGRectGetWidth(_contentView.frame)-DefaultEdgeInsets.left-DefaultEdgeInsets.right,
                                                                     CGRectGetHeight(_contentView.frame)-CGRectGetMaxY(title.frame))];;
        _textView.editable = NO;
        _textView.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 16.0f, NO);
        _textView.text = @"大家啊圣诞节啊圣诞节啊是；大家；圣诞节阿里斯顿叫阿双方开始 v 把纠结啊解放军啊就是煎熬死的；纪念碑上空";
        _textView.userInteractionEnabled = NO;
        [_contentView addSubview:_textView];
        
        for (UIGestureRecognizer *recognizer in _textView.gestureRecognizers) {
            if ([recognizer isKindOfClass:[UILongPressGestureRecognizer class]]){
                recognizer.enabled = NO;
            }
        }
        
        CGFloat cancelButtonSize = 40.0f;
        self.cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _cancelButton.hidden = YES;
        _cancelButton.frame = CGRectMake(CGRectGetWidth(self.frame)-cancelButtonSize, 0.0f, cancelButtonSize, cancelButtonSize);
        _cancelButton.titleLabel.font = systemFontBoldWithoutRatio(45.0f);
        [_cancelButton setTitle:@"X" forState:UIControlStateNormal];
        [_cancelButton setTitleColor:CDZColorOfWhite forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(hiddenItemListView) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_cancelButton];
        
        [self hiddenItemListView];
    }
}

- (void)showMessageViewWith:(NSString *)content {
    if (!content||[content isEqualToString:@""]) return;
    _textView.text = content;
    UIWindow *window = UIApplication.sharedApplication.keyWindow;
    [window addSubview:self];
    @weakify(self);
    [UIView animateWithDuration:0.20 animations:^{
        @strongify(self);
        self.alpha = 1;
        CGPoint point = self.contentView.center;
        point.y = CGRectGetHeight(self.frame)/2.0f;
        self.contentView.center = point;
    }completion:^(BOOL finished) {
        @strongify(self);
        self.isShowView = YES;
    }];
}


- (void)hiddenItemListView {
    @weakify(self);
    [UIView animateWithDuration:0.20 animations:^{
        @strongify(self);
        CGPoint point = self.contentView.center;
        point.y += CGRectGetHeight(self.frame);
        self.contentView.center = point;
        self.self.alpha = 0;
    }completion:^(BOOL finished) {
        @strongify(self);
        self.isShowView = NO;
        [self removeFromSuperview];
    }];
}

- (void)setIsShowView:(BOOL)isShowView {
    _isShowView = isShowView;
}

@end
