//
//  AppQACell.m
//  cdzer
//
//  Created by KEns0n on 2/3/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "AppQACell.h"
#import "InsetsLabel.h"
#import "InsetsTextField.h"
#import "MarkerView.h"

@interface AppQAInternalCell : UITableViewCell

@property (nonatomic, strong) MarkerView *markerView;

@end

@implementation AppQAInternalCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.markerView = [[MarkerView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 24.0f, 24.0f)];
        self.markerView.backgroundColor = CDZColorOfWhite;
        [self addSubview:_markerView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect markerFrame = self.markerView.frame;
    markerFrame.origin.x = kIntEdgeInsets.left;
    markerFrame.origin.y = (CGRectGetHeight(self.frame)-CGRectGetHeight(markerFrame))/2.0f;
    self.markerView.frame = markerFrame;
    
    CGRect textFrame = self.textLabel.frame;
    textFrame.origin.y = 0;
    textFrame.origin.x = CGRectGetMaxX(_markerView.frame)+4.0f;
    textFrame.size.width = CGRectGetWidth(self.frame)-CGRectGetMinX(textFrame)-kIntEdgeInsets.right;
    textFrame.size.height = CGRectGetHeight(self.frame);
    self.textLabel.frame = textFrame;
}

@end

@interface AppQACell ()<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *configList;

@property (nonatomic, strong) InsetsLabel *titleLabel;

@property (nonatomic, strong) InsetsLabel *tfTitleLabel;

@property (nonatomic, assign) NSUInteger numberOfCanSelAnswer;

@property (nonatomic, assign) QuestionObject *qObject;

@property (nonatomic, assign) AnswerObject *aObject;

@property (nonatomic, assign) CGRect keyboardRect;
@end

@implementation AppQACell

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [self componentSetting];
        [self initializationUI];
        [self setReactiveRules];
    }
    return self;
}

- (void)setOtherCommentLabel:(InsetsTextField *)otherCommentLabel {
    _otherCommentLabel = nil;
    _otherCommentLabel = otherCommentLabel;
    
}

- (void)keyboardWillShow:(NSNotification *)notifyObject {
    CGRect keyboardRect = [[notifyObject.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSArray *array = [_otherCommentLabel.accessibilityIdentifier componentsSeparatedByString:@","];
    if (array.count>0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[array[1] integerValue] inSection:[array[0] integerValue]];
        if ([indexPath isEqual:_indexPath]&&_otherCommentLabel.isFirstResponder) {
            if (!CGRectEqualToRect(keyboardRect, _keyboardRect)) {
                self.keyboardRect = keyboardRect;
                NSLog(@"Step One");
                CGRect tfConvertedRect = [self.tableView convertRect:_otherCommentLabel.frame toView:self];
                NSDictionary *userInfo = @{@"tfConvertedRect":[NSValue valueWithCGRect:tfConvertedRect],
                                           @"keyboardRect":[NSValue valueWithCGRect:_keyboardRect],
                                           @"cellIndexPath":_indexPath};
                [NSNotificationCenter.defaultCenter postNotificationName:AQATFDidBeginEditingNotification object:nil userInfo:userInfo];
                NSLog(@"activeTF IndexPath::%@", _otherCommentLabel.accessibilityIdentifier);
            }
        }
    }
}

#pragma mark UI Init
- (void)componentSetting {
    @autoreleasepool {
        self.configList = [@[] mutableCopy];
    }
}

- (void)initializationUI {
    @autoreleasepool {
        
        self.tableView = [[UITableView alloc] initWithFrame:self.contentView.bounds];
        _tableView.backgroundColor = CDZColorOfWhite;//[UIColor colorWithRed:0.937f green:0.937f blue:0.957f alpha:1.00f];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.scrollsToTop = YES;
        _tableView.bounces = NO;
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _tableView.translatesAutoresizingMaskIntoConstraints = YES;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.contentView addSubview:_tableView];
        
        self.titleLabel = [[InsetsLabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.frame), 50)
                                          andEdgeInsetsValue:kIntEdgeInsets];
        _titleLabel.edgeInsets = UIEdgeInsetsMake(0.0f, kIntEdgeInsets.left, 2.0f, kIntEdgeInsets.right);
        _titleLabel.numberOfLines = 0;
        
        
        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.frame), 44.0f)];
        [toolbar setBarStyle:UIBarStyleDefault];
        UIBarButtonItem *spaceButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                    target:self
                                                                                    action:nil];
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]initWithTitle:getLocalizationString(@"finish")
                                                                      style:UIBarButtonItemStyleDone
                                                                     target:self
                                                                     action:@selector(hiddenKeyboard)];
        NSArray * buttonsArray = [NSArray arrayWithObjects:spaceButton,doneButton,nil];
        [toolbar setItems:buttonsArray];
        
        self.otherCommentLabel = [[InsetsTextField alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.frame), 40)
                                                     andEdgeInsetsValue:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, kIntEdgeInsets.right)];
        _otherCommentLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _otherCommentLabel.translatesAutoresizingMaskIntoConstraints = YES;
        _otherCommentLabel.inputAccessoryView = toolbar;
        _otherCommentLabel.delegate = self;
        
        self.tfTitleLabel =  [[InsetsLabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 100, 40)
                                             andEdgeInsetsValue:UIEdgeInsetsMake(0.0f, kIntEdgeInsets.left, 0.0f, 0.0f)];
        [_otherCommentLabel addSubview:_tfTitleLabel];
        
    }
}

- (void)hiddenKeyboard {
    [_otherCommentLabel resignFirstResponder];
    self.keyboardRect = CGRectZero;
    if (_asBlock&&_qObject.withOtherComment) {
        _aObject.otherComment = _otherCommentLabel.text;
        _asBlock(_aObject, self.indexPath);
    }
    [NSNotificationCenter.defaultCenter postNotificationName:AQATableViewActiveScrollEnableNotification object:nil];
    
}

- (void)setReactiveRules {
    @weakify(self);
    [RACObserve(self, tableView.contentSize) subscribeNext:^(id size) {
        @strongify(self);
        CGRect frame = self.tableView.frame;
        frame.size.height = [size CGSizeValue].height;
        self.tableView.frame = frame;
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    UIColor *color = [UIColor colorWithHexString:@"d6d7dc"];
    [self.tableView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:color withBroderOffset:nil];
}

- (CGSize)sizeThatFits:(CGSize)size {
    size.height = CGRectGetHeight(_tableView.frame);
    return size;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return _configList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AppQAInternalCell *cell = [tableView dequeueReusableCellWithIdentifier:CDZKeyOfCellIdentKey];
    if (!cell) {
        cell = [[AppQAInternalCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CDZKeyOfCellIdentKey];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell setBackgroundColor:CDZColorOfClearColor];
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 14, NO);
        
    }
    NSString *markStr = @"";
    switch (indexPath.row) {
        case 0:
            markStr = @"A";
            break;
        case 1:
            markStr = @"B";
            break;
        case 2:
            markStr = @"C";
            break;
        case 3:
            markStr = @"D";
            break;
        case 4:
            markStr = @"E";
            break;
        case 5:
            markStr = @"F";
            break;
        case 6:
            markStr = @"G";
            break;
        case 7:
            markStr = @"H";
            break;
            
        default:
            break;
    }
    NSString *selectionItem = _configList[indexPath.row];
    cell.textLabel.text = selectionItem;
    cell.markerView.title = markStr;
    [cell.markerView showNormalView];
    if ([_aObject.selectedAnswerSet containsObject:indexPath]) {
        [cell.markerView showSuccessWarningView];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 40.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {    
    if ([_aObject.selectedAnswerSet containsObject:indexPath]) {
        [_aObject.selectedAnswerSet removeObject:indexPath];
    }else {
        if (_aObject.selectedAnswerSet.count>=_qObject.numberOfCanSelAnswer&&_qObject.numberOfCanSelAnswer>0) {
            NSInteger loopCount = (_aObject.selectedAnswerSet.count-(_qObject.numberOfCanSelAnswer-1));
            for (int i=0; i<loopCount; i++) {
                if (_aObject.selectedAnswerSet.count>0) {
                    NSIndexPath *willRemovedIdxPath = _aObject.selectedAnswerSet.allObjects.firstObject;
                    [_aObject.selectedAnswerSet removeObject:willRemovedIdxPath];
                    [tableView reloadRowsAtIndexPaths:@[willRemovedIdxPath] withRowAnimation:UITableViewRowAnimationNone];
                }
            }
        }
        [_aObject.selectedAnswerSet addObject:indexPath];
    }
    if (_asBlock) {
        if (_qObject.withOtherComment) {
            _aObject.otherComment = _otherCommentLabel.text;
        }
        _asBlock(_aObject, self.indexPath);
    }
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)setAnswerSelectionBlock:(AQACAnswerSelectionBlock)asBlock {
    _asBlock = nil;
    _asBlock = asBlock;
}

- (void)updateUIData:(QuestionObject *)qObject andAnswerObject:(AnswerObject *)aObject {
    _tableView.tableHeaderView = nil;
    _tableView.tableFooterView = nil;
    [_configList removeAllObjects];
    self.qObject = nil;
    self.qObject = qObject;
    
    self.aObject = nil;
    self.aObject = aObject;
    
    self.numberOfCanSelAnswer = qObject.numberOfCanSelAnswer;
    
    [_configList addObjectsFromArray:qObject.anwserSelectionList];
    _titleLabel.text = [NSString stringWithFormat:@"%@.%@", qObject.qid, qObject.question];
    CGRect titleFrame = _titleLabel.frame;
    titleFrame.size.height = [_titleLabel heightThatFitsWithSpaceOffset:26.0f];
    _titleLabel.frame = titleFrame;
    _tableView.tableHeaderView = _titleLabel;
    
    if (qObject.withOtherComment) {
        _tfTitleLabel.text = @"";
        _tfTitleLabel.text = qObject.commentTitle;
        CGRect tfTitleFrame = _tfTitleLabel.frame;
        tfTitleFrame.size.width = [_tfTitleLabel widthThatFitsWithSpaceOffset:0.0f];
        _tfTitleLabel.frame = tfTitleFrame;
        
        UIEdgeInsets insetsValue = _otherCommentLabel.edgeInsets;
        insetsValue.left = CGRectGetWidth(_tfTitleLabel.frame);
        _otherCommentLabel.edgeInsets = insetsValue;
        
        _otherCommentLabel.text = @"";
        _otherCommentLabel.text = _aObject.otherComment;
        _tableView.tableFooterView = _otherCommentLabel;
        
        BorderOffsetObject *borderObject = [BorderOffsetObject new];
        borderObject.bottomRightOffset = kIntEdgeInsets.right;
        borderObject.bottomOffset = 8.0f;
        borderObject.bottomLeftOffset = _otherCommentLabel.edgeInsets.left;
        [_otherCommentLabel setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:CDZColorOfBlack withBroderOffset:borderObject];
    }
    
    _tableView.backgroundColor = CDZColorOfWhite;//[UIColor colorWithRed:0.937f green:0.937f blue:0.957f alpha:1.00f];
    if ((qObject.qid.integerValue%2)!=0) {
        _tableView.backgroundColor = CDZColorOfWhite;//[UIColor colorWithWhite:0.912 alpha:1];
    }

    [_tableView reloadData];
}

@end
