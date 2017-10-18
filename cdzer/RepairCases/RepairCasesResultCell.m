//
//  RepairCasesResultCell.m
//  cdzer
//
//  Created by KEns0n on 6/23/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#define buttonHeight 30.0f
#define normalHeight 26.0f
#define extHeight 5.0f
#define subExtHeight 10.0f

#define kLeftValue @"leftValue"
#define kCenterValue @"centerValue"
#define kRightValue @"rightValue"
#define kDataList @"dataList"

#define kSID @"sid"
#define kIsDisplay @"isDisplay"
#define kRepairDetail @"repairDetail"

#import "RepairCasesResultCell.h"
#import "InsetsLabel.h"
#import "InsetsLabelWithTLabel.h"

@interface RepairCasesResultCell ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, assign) BOOL wasFirstCell;

@property (nonatomic, assign) BOOL wasShowDetail;

@property (nonatomic, strong) UIView *subContentView;

@property (nonatomic, strong) UIView *repairDetailView;

@property (nonatomic, strong) InsetsLabel *userName;

@property (nonatomic, strong) InsetsLabel *dateTime;

@property (nonatomic, strong) InsetsLabel *repairShopName;

@property (nonatomic, strong) InsetsLabelWithTLabel *priceLabel;

@property (nonatomic, strong) InsetsLabelWithTLabel *repairItemName;

@property (nonatomic, strong) InsetsLabelWithTLabel *shopAddress;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *dataList;

@end

@implementation RepairCasesResultCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initializationUI];
        [self setReactiveRules];
    }
    return self;
}

- (CGFloat)getLabelTextHeight:(InsetsLabel *)label {
    CGFloat height = 0.0f;
    CGFloat width = SCREEN_WIDTH;
    height = [SupportingClass getStringSizeWithString:label.text font:label.font widthOfView:CGSizeMake(width, CGFLOAT_MAX)withEdgeInset:label.edgeInsets].height;
    return height;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.backgroundColor = CDZColorOfWhite;
    self.contentView.backgroundColor = CDZColorOfGray;
    _subContentView.opaque = NO;
    _subContentView.backgroundColor = CDZColorOfWhite;
    
    CGRect shopNameFrame = _repairShopName.frame;
    shopNameFrame.size.width = CGRectGetWidth(_subContentView.frame);
    shopNameFrame.size.height = round(normalHeight*1.1);
    if (CGRectGetHeight(shopNameFrame)<[self getLabelTextHeight:_repairShopName]) {
        shopNameFrame.size.height = [self getLabelTextHeight:_repairShopName];
        shopNameFrame.size.height += extHeight;
    }
    _repairShopName.frame = shopNameFrame;
    
    CGRect userFrame = _userName.frame;
    userFrame.origin.y = CGRectGetMaxY(_repairShopName.frame);
    userFrame.size.width = CGRectGetWidth(_subContentView.frame);
    userFrame.size.height = normalHeight;
    if (CGRectGetHeight(userFrame)<[self getLabelTextHeight:_userName]) {
        userFrame.size.height = [self getLabelTextHeight:_userName];
        userFrame.size.height += extHeight;
    }
    _userName.frame = userFrame;
    _dateTime.frame = _userName.frame;
    
    
    CGRect priceLabelFrame = _priceLabel.frame;
    priceLabelFrame.origin.y = CGRectGetMaxY(_userName.frame);
    priceLabelFrame.size.width = CGRectGetWidth(_subContentView.frame);
    priceLabelFrame.size.height = normalHeight;
    if (CGRectGetHeight(priceLabelFrame)<[self getLabelTextHeight:_priceLabel]) {
        priceLabelFrame.size.height = [self getLabelTextHeight:_priceLabel];
        priceLabelFrame.size.height += extHeight;
    }
    _priceLabel.frame = priceLabelFrame;
    
    
    CGRect itemsFrame = _repairItemName.frame;
    itemsFrame.origin.y = CGRectGetMaxY(_priceLabel.frame);
    itemsFrame.size.width = CGRectGetWidth(_subContentView.frame);
    itemsFrame.size.height = normalHeight;
    if (CGRectGetHeight(itemsFrame)<[self getLabelTextHeight:_repairItemName]) {
        itemsFrame.size.height = [self getLabelTextHeight:_repairItemName];
        itemsFrame.size.height += extHeight;
    }
    _repairItemName.frame = itemsFrame;
    
    CGRect addrRect = _shopAddress.frame;
    addrRect.origin.y = CGRectGetMaxY(_repairItemName.frame);
    addrRect.size.width = CGRectGetWidth(_subContentView.frame);
    addrRect.size.height = normalHeight;
    if (CGRectGetHeight(addrRect)<[self getLabelTextHeight:_shopAddress]) {
        addrRect.size.height = [self getLabelTextHeight:_shopAddress];
        addrRect.size.height += extHeight;
    }
    _shopAddress.frame = addrRect;
    
    
    CGRect rect = _subContentView.frame;
    rect.origin.y = 5.0f;
    if (_wasFirstCell) {
        rect.origin.y = 0.0f;
    }
    rect.size.height = CGRectGetMaxY(_shopAddress.frame)+subExtHeight;
    _subContentView.frame = rect;

    CGRect detailRect = _repairDetailView.frame;
    detailRect.origin.y = CGRectGetMaxY(_subContentView.frame);
    detailRect.size.height = (self.wasShowDetail?CGRectGetHeight(self.tableView.frame):0)+buttonHeight;
    _repairDetailView.frame = detailRect;
    
    
    BorderOffsetObject *offset = BorderOffsetObject.new;
    offset.upperLeftOffset = DefaultEdgeInsets.left;
    offset.upperRightOffset = DefaultEdgeInsets.right;
    [_repairDetailView setViewBorderWithRectBorder:UIRectBorderTop borderSize:0.5f withColor:CDZColorOfSeperateLineColor withBroderOffset:offset];
    
    
}

- (void)setReactiveRules {
    @weakify(self);
    [RACObserve(self, tableView.contentSize) subscribeNext:^(id size) {
        @strongify(self);
        CGSize contentSize = [size CGSizeValue];
        CGRect frame = self.tableView.frame;
        frame.size.height = contentSize.height;
        self.tableView.frame = frame;
        
        
        CGRect rdvframe = self.repairDetailView.frame;
        rdvframe.size.height = (self.wasShowDetail?contentSize.height:0)+buttonHeight;
        self.repairDetailView.frame = rdvframe;
    }];
}

- (void)initializationUI {
    // Initialization code
    UIEdgeInsets insetValueLR = DefaultEdgeInsets;
    UIFont *commonFont = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 14.0f, NO);
    @autoreleasepool {
        
        if (!_subContentView) {
            CGRect rect = self.bounds;
            rect.origin.y = 5.0f;
            self.subContentView = [[UIView alloc]initWithFrame:rect];
            self.subContentView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            _subContentView.backgroundColor = CDZColorOfWhite;
            [self.contentView addSubview:_subContentView];
        }
        
        if (!_repairShopName) {
            CGRect rect = self.contentView.bounds;
            rect.size.height = round(normalHeight*1.1);
            UIFont *otherFont = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfBold, 16.0f, NO);
            self.repairShopName = [[InsetsLabel alloc] initWithFrame:rect andEdgeInsetsValue:insetValueLR];
            _repairShopName.text = @"是多哈时代；阿华盛顿；哈大；谁的";
            _repairShopName.font = otherFont;
            _repairShopName.numberOfLines = 0;
            [_subContentView addSubview:_repairShopName];
        }
        
        
        if (!_userName) {
            CGRect rect = self.contentView.bounds;
            rect.origin.y = CGRectGetMaxY(_repairShopName.frame);
            rect.size.height = normalHeight;
            self.userName = [[InsetsLabel alloc] initWithFrame:rect andEdgeInsetsValue:insetValueLR];
            _userName.text = @"用户：";
            _userName.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 13.0f, NO);
            [_subContentView addSubview:_userName];
        }
        
        if (!_dateTime) {
            self.dateTime = [[InsetsLabel alloc] initWithFrame:_userName.frame andEdgeInsetsValue:insetValueLR];
            _dateTime.text = @"2015-06-27 15:42:43";
            _dateTime.textAlignment = NSTextAlignmentRight;
            _dateTime.textColor = CDZColorOfDeepGray;
            _dateTime.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 12.0f, NO);
            [_subContentView addSubview:_dateTime];
        }
        
        if (!_priceLabel) {
            CGRect rect = self.contentView.bounds;
            rect.origin.y = CGRectGetMaxY(_userName.frame);
            rect.size.height = normalHeight;
            
            self.priceLabel = [[InsetsLabelWithTLabel alloc] initWithFrame:rect andEdgeInsetsValue:insetValueLR];
            _priceLabel.text = @"";
            _priceLabel.font = commonFont;
            _priceLabel.numberOfLines = 0;
            _priceLabel.textColor = CDZColorOfRed;
            _priceLabel.titleLabel.textColor = CDZColorOfDeepGray;
            _priceLabel.titleLabel.text =  @"维修费用：";
            _priceLabel.titleLabel.font = commonFont;
            [_subContentView addSubview:_priceLabel];
        }
        if (!_repairItemName) {
            CGRect rect = self.contentView.bounds;
            rect.origin.y = CGRectGetMaxY(_priceLabel.frame);
            rect.size.height = normalHeight;
            
            self.repairItemName = [[InsetsLabelWithTLabel alloc] initWithFrame:rect andEdgeInsetsValue:insetValueLR];
            _repairItemName.text = @"是多哈时代；阿华盛顿；哈大；谁的";
            _repairItemName.font = commonFont;
            _repairItemName.numberOfLines = 0;
            _repairItemName.titleLabel.textColor = CDZColorOfDeepGray;
            _repairItemName.titleLabel.text =  @"维修项目：";
            _repairItemName.titleLabel.font = commonFont;
            [_subContentView addSubview:_repairItemName];
        }
        
        if (!_shopAddress) {
            CGRect rect = self.contentView.bounds;
            rect.origin.y = CGRectGetMaxY(_repairItemName.frame);
            rect.size.height = normalHeight;
            
            self.shopAddress = [[InsetsLabelWithTLabel alloc] initWithFrame:rect andEdgeInsetsValue:insetValueLR];
            _shopAddress.text = @"";
            _shopAddress.font = commonFont;
            _shopAddress.numberOfLines = 0;
            _shopAddress.titleLabel.textColor = CDZColorOfDeepGray;
            _shopAddress.titleLabel.text =  @"地址：";
            _shopAddress.titleLabel.font = commonFont;
            [_subContentView addSubview:_shopAddress];
        }
        
        if (!_repairDetailView) {
            CGRect rect = self.contentView.bounds;
            rect.origin.y = CGRectGetMaxY(_subContentView.frame);
            rect.size.height = buttonHeight;
            self.repairDetailView = [[UIView alloc] initWithFrame:rect];
            self.repairDetailView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            _repairDetailView.backgroundColor = CDZColorOfWhite;
            [self.contentView addSubview:_repairDetailView];
        }
        
        if(!_moreButton) {
            CGRect rect = _repairDetailView.bounds;
            self.moreButton = [UIButton buttonWithType:UIButtonTypeSystem];
            _moreButton.frame = rect;
            _moreButton.tintColor = CDZColorOfClearColor;
            [_moreButton setTitle:@"查看详情" forState:UIControlStateNormal];
            [_moreButton setTitle:@"查看详情" forState:UIControlStateNormal|UIControlStateHighlighted];
            [_moreButton setTitleColor:CDZColorOfDefaultColor forState:UIControlStateNormal];
            
            [_moreButton setTitle:@"隐藏详情" forState:UIControlStateSelected];
            [_moreButton setTitle:@"隐藏详情" forState:UIControlStateSelected|UIControlStateHighlighted];
            [_moreButton setTitleColor:CDZColorOfLightGray forState:UIControlStateSelected|UIControlStateHighlighted];
            [_moreButton setTitleColor:CDZColorOfOrangeColor forState:UIControlStateSelected];
            [_moreButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
            _moreButton.titleEdgeInsets = DefaultEdgeInsets;
            [_repairDetailView addSubview:_moreButton];
        }
        
        if(!_tableView) {
            self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(_moreButton.frame),
                                                                           CGRectGetWidth(self.contentView.frame), CGRectGetHeight(self.contentView.frame))];
            _tableView.bounces = NO;
            _tableView.backgroundColor = CDZColorOfClearColor;
            _tableView.showsHorizontalScrollIndicator = NO;
            _tableView.showsVerticalScrollIndicator = NO;
            _tableView.delegate = self;
            _tableView.dataSource = self;
            _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            [_repairDetailView addSubview:_tableView];
        }
        
    }
}

#pragma -mark UITableViewDelgate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return _dataList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [[_dataList[section] objectForKey:kDataList] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CDZKeyOfCellIdentKey];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CDZKeyOfCellIdentKey];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.frame = CGRectMake(0.0f, 0.0f, SCREEN_WIDTH, 44.0f);
        cell.contentView.backgroundColor = CDZColorOfWhite;
        UIEdgeInsets onlyLeftInsets = DefaultEdgeInsets;
        onlyLeftInsets.right = 0.0f;
        UIEdgeInsets onlyRightInsets = DefaultEdgeInsets;
        onlyRightInsets.left = 0.0f;
        
        UIFont *commonFont = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 14.0f, NO);
        
        InsetsLabel *leftLabel = [[InsetsLabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f,
                                                                               CGRectGetWidth(cell.contentView.frame)*0.5, CGRectGetHeight(cell.contentView.frame))
                                                 andEdgeInsetsValue:onlyLeftInsets];
        leftLabel.font = commonFont;
//        leftLabel.textColor = CDZColorOfDeepGray;
        leftLabel.textAlignment = NSTextAlignmentCenter;
        leftLabel.tag = 10;
        leftLabel.numberOfLines = 0;
        leftLabel.translatesAutoresizingMaskIntoConstraints = YES;
        leftLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [cell addSubview:leftLabel];
        
        InsetsLabel *centerLabel = [[InsetsLabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(leftLabel.frame), 0.0f,
                                                                                 CGRectGetWidth(cell.contentView.frame)*0.25, CGRectGetHeight(cell.contentView.frame))];
        centerLabel.font = commonFont;
//        centerLabel.textColor = CDZColorOfDeepGray;
        centerLabel.textAlignment = NSTextAlignmentCenter;
        centerLabel.tag = 11;
        centerLabel.numberOfLines = 0;
        centerLabel.translatesAutoresizingMaskIntoConstraints = YES;
        centerLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [cell addSubview:centerLabel];
        
        InsetsLabel *rightLabel = [[InsetsLabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(centerLabel.frame), 0.0f,
                                                                                CGRectGetWidth(cell.contentView.frame)*0.25, CGRectGetHeight(cell.contentView.frame))
                                                  andEdgeInsetsValue:onlyRightInsets];
        rightLabel.font = commonFont;
//        rightLabel.textColor = CDZColorOfDeepGray;
        rightLabel.textAlignment = NSTextAlignmentCenter;
        rightLabel.tag = 12;
        rightLabel.numberOfLines = 0;
        rightLabel.translatesAutoresizingMaskIntoConstraints = YES;
        rightLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [cell addSubview:rightLabel];
        
    }
    
    
    InsetsLabel *leftLabel = (InsetsLabel *)[cell viewWithTag:10];
    InsetsLabel *centerLabel = (InsetsLabel *)[cell viewWithTag:11];
    InsetsLabel *rightLabel = (InsetsLabel *)[cell viewWithTag:12];
    
    leftLabel.frame = CGRectMake(0.0f, 0.0f,CGRectGetWidth(cell.contentView.frame)*0.5, CGRectGetHeight(cell.contentView.frame));
    
    centerLabel.frame = CGRectMake(CGRectGetMaxX(leftLabel.frame), 0.0f,                                                    CGRectGetWidth(cell.contentView.frame)*0.25, CGRectGetHeight(cell.contentView.frame));
    
    rightLabel.frame = CGRectMake(CGRectGetMaxX(centerLabel.frame), 0.0f, CGRectGetWidth(cell.contentView.frame)*0.25, CGRectGetHeight(cell.contentView.frame));
    
    NSDictionary *detail = [[_dataList[indexPath.section] objectForKey:kDataList] objectAtIndex:indexPath.row];
    BOOL isFirstIndex = (indexPath.section == 0);
    leftLabel.text = detail[isFirstIndex?kLeftValue:@"part"];
    centerLabel.text = [SupportingClass verifyAndConvertDataToString:detail[isFirstIndex?kCenterValue:@"num"]];
    rightLabel.text = [SupportingClass verifyAndConvertDataToString:detail[isFirstIndex?kRightValue:@"price"]];
    
    
    
    BorderOffsetObject *offset = BorderOffsetObject.new;
    offset.upperLeftOffset = DefaultEdgeInsets.left;
    [leftLabel setViewBorderWithRectBorder:UIRectBorderTop borderSize:0.5f withColor:CDZColorOfSeperateLineColor withBroderOffset:offset];
    offset.upperLeftOffset = 0.0f;
    [centerLabel setViewBorderWithRectBorder:UIRectBorderTop borderSize:0.5f withColor:CDZColorOfSeperateLineColor withBroderOffset:offset];
    offset.upperRightOffset = DefaultEdgeInsets.right;
    [rightLabel setViewBorderWithRectBorder:UIRectBorderTop borderSize:0.5f withColor:CDZColorOfSeperateLineColor withBroderOffset:offset];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    @autoreleasepool {
        NSArray *array = [_dataList[indexPath.section] objectForKey:kDataList];
        NSDictionary *detail = array[indexPath.row];
        CGFloat localProjectFullWidth = SCREEN_WIDTH*0.5f-DefaultEdgeInsets.left;
        UIFont *commonFont = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 14.0f, NO);
        NSString *text = detail[kLeftValue];
        if (indexPath.section > 0) text = detail[@"part"];
        
        CGFloat theHeight = [SupportingClass getStringSizeWithString:text font:commonFont widthOfView:CGSizeMake(localProjectFullWidth, CGFLOAT_MAX)].height;
        if (theHeight<normalHeight) {
            theHeight = normalHeight;
        }else {
            theHeight += extHeight;
        }
        
        return theHeight;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return normalHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    static NSString *headerIdentifier = @"header";
    UITableViewHeaderFooterView *myHeader = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerIdentifier];
    if(!myHeader) {
        myHeader = [[UITableViewHeaderFooterView alloc]initWithReuseIdentifier:headerIdentifier];
        myHeader.frame = CGRectMake(0.0f, 0.0f, SCREEN_WIDTH, 44.0f);
        myHeader.contentView.backgroundColor = CDZColorOfWhite;
        UIEdgeInsets onlyLeftInsets = DefaultEdgeInsets;
        onlyLeftInsets.right = 0.0f;
        UIEdgeInsets onlyRightInsets = DefaultEdgeInsets;
        onlyRightInsets.left = 0.0f;

        UIFont *commonFont = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 14.0f, NO);
        
        InsetsLabel *leftLabel = [[InsetsLabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f,
                                                                                CGRectGetWidth(myHeader.contentView.frame)*0.5, CGRectGetHeight(myHeader.contentView.frame))
                                                  andEdgeInsetsValue:onlyLeftInsets];
        leftLabel.font = commonFont;
        leftLabel.textColor = CDZColorOfDeepGray;
        leftLabel.textAlignment = NSTextAlignmentCenter;
        leftLabel.tag = 10;
        leftLabel.numberOfLines = 0;
        leftLabel.translatesAutoresizingMaskIntoConstraints = YES;
        leftLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [myHeader addSubview:leftLabel];
        
        InsetsLabel *centerLabel = [[InsetsLabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(leftLabel.frame), 0.0f,
                                                                                CGRectGetWidth(myHeader.contentView.frame)*0.25, CGRectGetHeight(myHeader.contentView.frame))];
        centerLabel.font = commonFont;
        centerLabel.textColor = CDZColorOfDeepGray;
        centerLabel.textAlignment = NSTextAlignmentCenter;
        centerLabel.tag = 11;
        centerLabel.numberOfLines = 0;
        centerLabel.translatesAutoresizingMaskIntoConstraints = YES;
        centerLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [myHeader addSubview:centerLabel];
        
        InsetsLabel *rightLabel = [[InsetsLabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(centerLabel.frame), 0.0f,
                                                                                 CGRectGetWidth(myHeader.contentView.frame)*0.25, CGRectGetHeight(myHeader.contentView.frame))
                                                   andEdgeInsetsValue:onlyRightInsets];
        rightLabel.font = commonFont;
        rightLabel.textColor = CDZColorOfDeepGray;
        rightLabel.textAlignment = NSTextAlignmentCenter;
        rightLabel.tag = 12;
        rightLabel.numberOfLines = 0;
        rightLabel.translatesAutoresizingMaskIntoConstraints = YES;
        rightLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [myHeader addSubview:rightLabel];
        
        [myHeader setNeedsUpdateConstraints];
        [myHeader updateConstraintsIfNeeded];
        [myHeader setNeedsLayout];
        [myHeader layoutIfNeeded];
    }
    InsetsLabel *leftLabel = (InsetsLabel *)[myHeader viewWithTag:10];
    InsetsLabel *centerLabel = (InsetsLabel *)[myHeader viewWithTag:11];
    InsetsLabel *rightLabel = (InsetsLabel *)[myHeader viewWithTag:12];
    NSDictionary *detail = _dataList[section];
    leftLabel.text = detail[kLeftValue];
    centerLabel.text = detail[kCenterValue];
    rightLabel.text = detail[kRightValue];
    
    
//    BorderOffsetObject *offset = BorderOffsetObject.new;
//    offset.upperLeftOffset = DefaultEdgeInsets.left;
//    [leftLabel setViewBorderWithRectBorder:UIRectBorderTop borderSize:0.5f withColor:CDZColorOfSeperateLineColor withBroderOffset:offset];
//    offset.upperLeftOffset = 0.0f;
//    [centerLabel setViewBorderWithRectBorder:UIRectBorderTop borderSize:0.5f withColor:CDZColorOfSeperateLineColor withBroderOffset:offset];
//    offset.upperRightOffset = DefaultEdgeInsets.right;
//    [rightLabel setViewBorderWithRectBorder:UIRectBorderTop borderSize:0.5f withColor:CDZColorOfSeperateLineColor withBroderOffset:offset];
//    
    return myHeader;
}

- (void)updateUIDataWithData:(NSDictionary *)dataDetail wasFirstCell:(BOOL)wasFirstCell withRepairDetail:(NSDictionary *)repairDetail {
    //    wxs_name: "湖南百城网络科技有限公司",
    //    project: "发动机不能启动，且无着车征兆",
    //    real_name: "小贺",
    //    fee: "295.0",
    //    add_time: "2015-06-16 11:14:32 ",
    //    address: "湖南省长沙市"
    NSString *shopName = dataDetail[@"wxs_name"];
    NSString *priceName = dataDetail[@"fee"];
    NSString *projectName = dataDetail[@"project"];
    NSString *userName = dataDetail[@"real_name"];
    NSString *addressName = dataDetail[@"address"];
    
    self.wasFirstCell = wasFirstCell;
    _repairShopName.text = shopName;
    _userName.text = userName;//[@"用户：" stringByAppendingString:userName];
    _priceLabel.text = [@"¥" stringByAppendingString:priceName];
    _repairItemName.text = projectName;
    _shopAddress.text = addressName;
    
    self.dataList = @[];
    self.wasShowDetail = NO;
    
    if (repairDetail&&repairDetail.count>0&&[repairDetail[kIsDisplay] boolValue]) self.wasShowDetail = YES;
    
    if (_wasShowDetail) {
        NSDictionary *subRepairDetail = repairDetail[kRepairDetail];
        NSArray *list2 = subRepairDetail[@"list2"];
        if (!list2||list2.count==0) list2 = @[];
        self.dataList = @[@{kLeftValue:@"维修项目",
                            kCenterValue:@"工时",
                            kRightValue:@"工时费",
                            kDataList:@[@{kLeftValue:subRepairDetail[@"project"],
                                          kCenterValue:subRepairDetail[@"man_hour"],
                                          kRightValue:subRepairDetail[@"man_fee"]}]},
                          @{kLeftValue:@"更换配件",
                            kCenterValue:@"数量",
                            kRightValue:@"单价",
                            kDataList:list2,}];
    }
    [_tableView reloadData];
}

+ (CGFloat)getCellHieght:(NSDictionary *)detail wasFirstCell:(BOOL)wasFirstCell withRepairDetail:(NSDictionary *)repairDetail{
    NSString *shopName = detail[@"wxs_name"];
    NSString *priceName = detail[@"fee"];
    NSString *projectName = detail[@"project"];
    NSString *userName = detail[@"real_name"];
    NSString *addressName = detail[@"address"];
    
    
    BOOL wasShowDetail = NO;
    if (repairDetail&&repairDetail.count>0&&[repairDetail[kIsDisplay] boolValue]) wasShowDetail = YES;
    
    UIFont *commonFont = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 14.0f, NO);
    UIFont *shopFont = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfBold, 16.0f, NO);
    UIFont *userFont = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 13.0f, NO);
    CGFloat fullWidth = SCREEN_WIDTH-DefaultEdgeInsets.left-DefaultEdgeInsets.right;
    
    
    CGFloat shopNameHeight = [SupportingClass getStringSizeWithString:shopName font:shopFont widthOfView:CGSizeMake(fullWidth, CGFLOAT_MAX)].height;
    if (shopNameHeight<round(normalHeight*1.1)) {
        shopNameHeight = round(normalHeight*1.1);
    }else {
        shopNameHeight += extHeight;
    }
    
    
    CGFloat userNameHeight = [SupportingClass getStringSizeWithString:userName font:userFont widthOfView:CGSizeMake(fullWidth, CGFLOAT_MAX)].height;
    if (userNameHeight<normalHeight) {
        userNameHeight = normalHeight;
    }else {
        userNameHeight += extHeight;
    }
    
    
    
    CGFloat priceTitleWidth = [SupportingClass getStringSizeWithString:@"维修费用：" font:commonFont widthOfView:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)].width;
    CGFloat priceNameHeight = [SupportingClass getStringSizeWithString:priceName font:commonFont widthOfView:CGSizeMake(fullWidth-priceTitleWidth, CGFLOAT_MAX)].height;
    if (priceNameHeight<normalHeight) {
        priceNameHeight = normalHeight;
    }else {
        priceNameHeight += extHeight;
    }
    
    
    CGFloat projectTitleWidth = [SupportingClass getStringSizeWithString:@"维修项目：" font:commonFont widthOfView:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)].width;
    CGFloat projectNameHeight = [SupportingClass getStringSizeWithString:projectName font:commonFont widthOfView:CGSizeMake(fullWidth-projectTitleWidth, CGFLOAT_MAX)].height;
    if (projectNameHeight<normalHeight) {
        projectNameHeight = normalHeight;
    }else {
        projectNameHeight += extHeight;
    }
    
    
    CGFloat addressTitleWidth = [SupportingClass getStringSizeWithString:@"地址：" font:commonFont widthOfView:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)].width;
    CGFloat addressNameHeight = [SupportingClass getStringSizeWithString:addressName font:commonFont widthOfView:CGSizeMake(fullWidth-addressTitleWidth, CGFLOAT_MAX)].height;
    if (addressNameHeight<normalHeight) {
        addressNameHeight = normalHeight;
    }else {
        addressNameHeight += extHeight;
    }
    
    __block CGFloat totalHeight = userNameHeight+priceNameHeight+shopNameHeight+addressNameHeight+projectNameHeight+subExtHeight+(wasFirstCell?0.0f:5.0f)+buttonHeight;
    if (wasShowDetail) {
        NSDictionary *subRepairDetail = repairDetail[kRepairDetail];
        totalHeight += normalHeight*2;
        CGFloat localProjectFullWidth = SCREEN_WIDTH*0.5f-DefaultEdgeInsets.left;
        CGFloat projectNameHeight = [SupportingClass getStringSizeWithString:subRepairDetail[@"project"] font:commonFont widthOfView:CGSizeMake(localProjectFullWidth, CGFLOAT_MAX)].height;
        if (projectNameHeight<normalHeight) {
            projectNameHeight = normalHeight;
        }else {
            projectNameHeight += extHeight;
        }
        totalHeight += projectNameHeight;
        
        NSArray *list2 = subRepairDetail[@"list2"];
        if (list2&&list2.count>0) {
            [list2 enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *part = obj[@"part"];
                CGFloat itemsNameHeight = [SupportingClass getStringSizeWithString:part font:commonFont widthOfView:CGSizeMake(localProjectFullWidth, CGFLOAT_MAX)].height;
                if (itemsNameHeight<normalHeight) {
                    itemsNameHeight = normalHeight;
                }else {
                    itemsNameHeight += extHeight;
                }
                totalHeight += itemsNameHeight;
                
            }];
        }
        
    }
    return totalHeight;
}

@end
