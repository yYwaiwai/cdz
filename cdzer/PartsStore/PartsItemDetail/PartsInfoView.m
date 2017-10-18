//
//  PartsInfoView.m
//  cdzer
//
//  Created by KEns0n on 7/24/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//
#define vStartSpace (15.0f)
#import "PartsInfoView.h"
#import "InsetsLabel.h"
#import "HCSStarRatingView.h"
#import "InfoTabBtns.h"
#import "ImageFallsTV.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UserSelectedAutosInfoDTO.h"

@interface PIVTVCel : UITableViewCell
@end
@implementation PIVTVCel

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self setViewBorderWithRectBorder:UIRectBorderTop borderSize:0.5f withColor:CDZColorOfLightGray withBroderOffset:nil];

}
@end

@interface ManufacturerInfoTVC : UITableViewCell
@end
@implementation ManufacturerInfoTVC

- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(15.0f , 0.0f, 70.0f, 70.0f);
    self.imageView.center = CGPointMake(self.imageView.center.x, CGRectGetHeight(self.frame)/2.0f);
    
    CGRect textFrame = self.textLabel.frame;
    textFrame.origin.x = CGRectGetMaxX(self.imageView.frame)+10.0f;
    self.textLabel.frame = textFrame;
    
    CGRect detailTextFrame = self.detailTextLabel.frame;
    detailTextFrame.origin.x = CGRectGetMaxX(self.imageView.frame)+10.0f;
    self.detailTextLabel.frame = detailTextFrame;
    
    self.imageView.autoresizingMask = UIViewAutoresizingNone;
}

@end


@interface PartsInfoView () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) ManufacturerInfoTVC *manufacturerView;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataList;

@property (nonatomic, strong) InfoTabBtns *tabView;

@property (nonatomic, assign) id target;

@property (nonatomic, assign) SEL action;

@property (nonatomic, strong) ImageFallsTV *imageFallsView;

@end

@implementation PartsInfoView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.dataList = [@[] mutableCopy];
        [self initializationUI];
        [self setReactiveRules];
    }
    return self;
}

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
    self.target = nil;
    self.action = nil;
}

- (void)initializationUI {
    
    
//    UIEdgeInsets insetsValue = UIEdgeInsetsMake(0.0f, vStartSpace, 0.0f, vStartSpace);
    
    ButtonObject *btnObj1 = [ButtonObject new];
    btnObj1.title = @"产品信息";
    ButtonObject *btnObj2 = [ButtonObject new];
    btnObj2.title = @"图文详情";
    @weakify(self);
    self.tabView = [[InfoTabBtns alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.frame), 40.0f)];
    [_tabView initializationUIWithButtonObject:@[btnObj1, btnObj2] withBtnActionBlock:^(NSUInteger btnIndex) {
        @strongify(self);
        CGFloat height = CGRectGetMaxY(self.tableView.frame);
        self.tableView.hidden = NO;
        self.imageFallsView.hidden = YES;
        if (btnIndex==1) {
            self.tableView.hidden = YES;
            self.imageFallsView.hidden = NO;
            height = CGRectGetMaxY(self.imageFallsView.frame);
        }
        CGRect frame = self.frame;
        frame.size.height = height;
        self.frame = frame;
        [self setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5f withColor:CDZColorOfLightGray withBroderOffset:nil];
    }];
    [self addSubview:_tabView];
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    CGRect manufacturerViewRect = CGRectZero;
    manufacturerViewRect.size.width = CGRectGetWidth(self.frame);
    manufacturerViewRect.size.height = 80.0f;
    self.manufacturerView = [[ManufacturerInfoTVC alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    _manufacturerView.frame = manufacturerViewRect;
    
    CGRect tvFrame = self.bounds;
    tvFrame.origin.y = CGRectGetMaxY(_tabView.frame);
    self.tableView = [[UITableView alloc] initWithFrame:tvFrame];
    _tableView.bounces = NO;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableHeaderView = _manufacturerView;
    [self addSubview:_tableView];
    
    self.imageFallsView = [[ImageFallsTV alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(_tabView.frame), CGRectGetWidth(self.frame), 100)];
    _imageFallsView.hidden = YES;
    [self addSubview:_imageFallsView];
}

- (void)setShowCommnetViewTarget:(id)target action:(SEL)action {
    self.target = target;
    self.action = action;
}
#pragma -mark UITableViewDelgate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return _dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PIVTVCel *cell = [tableView dequeueReusableCellWithIdentifier:CDZKeyOfCellIdentKey];
    if (!cell) {
        cell = [[PIVTVCel alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CDZKeyOfCellIdentKey];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        
        InsetsLabel *leftLabel = [[InsetsLabel alloc] initWithFrame:cell.bounds andEdgeInsetsValue:UIEdgeInsetsMake(0.0f, vStartSpace, 0.0f, vStartSpace)];
        leftLabel.tag = 100;
        leftLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        leftLabel.translatesAutoresizingMaskIntoConstraints = YES;
        [cell addSubview:leftLabel];
        
        CGRect ratingViewRect = cell.bounds;
        ratingViewRect.origin.x = 100.0f;
        ratingViewRect.size.width = (100.0f);
        HCSStarRatingView *starRatingView = [[HCSStarRatingView alloc] initWithFrame:ratingViewRect];
        starRatingView.tag = 102;
        [starRatingView setAllowsHalfStars:NO];
        [starRatingView setMaximumValue:5.0f];
        [starRatingView setMinimumValue:0.0f];
        [starRatingView setTintColor:[UIColor redColor]];
        [starRatingView setUserInteractionEnabled:NO];
        starRatingView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        starRatingView.translatesAutoresizingMaskIntoConstraints = YES;
        [cell addSubview:starRatingView];
        
        
        InsetsLabel *rightLabel = [[InsetsLabel alloc] initWithFrame:cell.bounds andEdgeInsetsValue:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, vStartSpace)];
        rightLabel.tag = 101;
        rightLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        rightLabel.translatesAutoresizingMaskIntoConstraints = YES;
        [cell addSubview:rightLabel];
        
        
        
    }
    // Configure the cell...
    
    NSDictionary *detail = _dataList[indexPath.row];
    InsetsLabel *leftLabel = (InsetsLabel *)[cell viewWithTag:100];
    InsetsLabel *rightLabel = (InsetsLabel *)[cell viewWithTag:101];
    rightLabel.strikeThroughEnabled = NO;
    HCSStarRatingView *starRatingView = (HCSStarRatingView *)[cell viewWithTag:102];
    starRatingView.hidden = YES;
    if ([_dataList[indexPath.row] isKindOfClass:NSArray.class]) {
        detail = [_dataList[indexPath.row] objectAtIndex:0];
        NSMutableAttributedString* leftAttrText = [NSMutableAttributedString new];
        [leftAttrText appendAttributedString:[[NSAttributedString alloc]
                                              initWithString:detail[@"text"]
                                              attributes:@{NSForegroundColorAttributeName:detail[@"textColor"],
                                                           NSFontAttributeName:detail[@"textFont"]}]];
        
        [leftAttrText appendAttributedString:[[NSAttributedString alloc]
                                              initWithString:detail[@"subText"]
                                              attributes:@{NSForegroundColorAttributeName:detail[@"subTextColor"],
                                                           NSFontAttributeName:detail[@"textFont"]}]];
        
        leftLabel.attributedText = leftAttrText;
        CGFloat finalwidth = [SupportingClass getAttributedStringSizeWithString:leftLabel.attributedText widthOfView:CGSizeMake(CGFLOAT_MAX, CGRectGetHeight(leftLabel.frame))].width;
        finalwidth += leftLabel.edgeInsets.left+10.0f;
        
    
        
        NSDictionary *subDetail = [_dataList[indexPath.row] objectAtIndex:1];
        NSMutableAttributedString* rightAttrText = [NSMutableAttributedString new];
        [rightAttrText appendAttributedString:[[NSAttributedString alloc]
                                               initWithString:subDetail[@"text"]
                                               attributes:@{NSForegroundColorAttributeName:subDetail[@"textColor"],
                                                            NSFontAttributeName:subDetail[@"textFont"]}]];
        
        [rightAttrText appendAttributedString:[[NSAttributedString alloc]
                                               initWithString:subDetail[@"subText"]
                                               attributes:@{NSForegroundColorAttributeName:subDetail[@"subTextColor"],
                                                            NSFontAttributeName:subDetail[@"textFont"]}]];
        
        rightLabel.attributedText = leftAttrText;

        CGRect frame = rightLabel.frame;
        frame.origin.x = finalwidth;
        frame.size.width = CGRectGetWidth(cell.frame)-finalwidth;
        rightLabel.frame = frame;
        rightLabel.attributedText = rightAttrText;
    }else {
        
        leftLabel.text = detail[@"text"];
        leftLabel.textColor = detail[@"textColor"];
        leftLabel.font = detail[@"textFont"];
        CGFloat finalwidth = [SupportingClass getStringSizeWithString:leftLabel.text font:leftLabel.font widthOfView:CGSizeMake(CGFLOAT_MAX, CGRectGetHeight(leftLabel.frame))].width;
        finalwidth += leftLabel.edgeInsets.left;
        
        if (detail[@"star"]) {
            id starValue = detail[@"star"];
            if ([starValue isKindOfClass:[NSNumber class]]) {
                starRatingView.value = [starValue floatValue];
            }else if ([starValue isKindOfClass:[NSString class]]) {
                if ([starValue isEqualToString:@""]) {
                    starRatingView.value = 0.0f;
                }else {
                    starRatingView.value = [starValue floatValue];
                }
            }
            starRatingView.hidden = NO;
            CGRect frame = starRatingView.frame;
            frame.origin.x = finalwidth;
            starRatingView.frame = frame;
            
            finalwidth = CGRectGetMaxX(starRatingView.frame);
        }
        
        
        CGRect frame = rightLabel.frame;
        frame.origin.x = finalwidth;
        frame.size.width = CGRectGetWidth(cell.frame)-finalwidth;
        rightLabel.frame = frame;
        rightLabel.text = detail[@"subText"];
        rightLabel.textColor = detail[@"subTextColor"];
        rightLabel.font = detail[@"subTextFont"];
        if (detail[@"subTextShowLine"]) {
            rightLabel.strikeThroughEnabled = [detail[@"subTextShowLine"] boolValue];
        }
        cell.accessoryType = UITableViewCellAccessoryNone;
        if (detail[@"arrow"]&&[detail[@"arrow"] boolValue]) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }

    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 36;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_dataList[indexPath.row] isKindOfClass:NSDictionary.class]) {        
        NSDictionary *detail = _dataList[indexPath.row];
        if (detail[@"arrow"]&&[detail[@"arrow"] boolValue]) {
            if (_target&&_action) {
                if ([(BaseViewController *)_target respondsToSelector:_action]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                    [_target performSelector:_action withObject:nil];
#pragma clang diagnostic pop
                }
            }
        }
    }
}

- (void)setReactiveRules {
    
    @weakify(self);
    [RACObserve(self, imageFallsView.contentSize) subscribeNext:^(id theSize) {
        @strongify(self);
        CGSize size = [theSize CGSizeValue];
        CGRect imageTVFrame = self.imageFallsView.frame;
        imageTVFrame.size.height = size.height;
        self.imageFallsView.frame = imageTVFrame;
        if (self.tabView.btnIndex==1) {
            CGRect frame = self.frame;
            frame.size.height = CGRectGetMaxY(self.imageFallsView.frame);
            self.frame = frame;
        }
    }];
    
    [RACObserve(self, tableView.contentSize) subscribeNext:^(id theSize) {
        @strongify(self);
        CGSize size = [theSize CGSizeValue];
        CGRect tvFrame = self.tableView.frame;
        tvFrame.size.height = size.height;
        self.tableView.frame = tvFrame;
        
        CGRect frame = self.frame;
        frame.size.height = CGRectGetMaxY(self.tableView.frame);
        self.frame = frame;
        [self setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5f withColor:CDZColorOfLightGray withBroderOffset:nil];
    }];
}

- (void)updateUIDataWithDetailData:(NSDictionary *)itemDetail {
    
    [_dataList removeAllObjects];
    
    
    NSString *imageURL = [SupportingClass verifyAndConvertDataToString:itemDetail[@"pjs_logo"]];
    if ([imageURL isEqualToString:@""]||!imageURL||[imageURL rangeOfString:@"http"].location==NSNotFound) {
        _manufacturerView.imageView.image = [ImageHandler getWhiteLogo];
    }else {
        [_manufacturerView.imageView sd_setImageWithURL:[NSURL URLWithString:imageURL] placeholderImage:[ImageHandler getWhiteLogo]];
    }
    
    NSString *manufacturerName = [SupportingClass verifyAndConvertDataToString:itemDetail[@"factoryName"]];
    if (!manufacturerName||[manufacturerName isKindOfClass:NSNull.class]) manufacturerName = @"--";
    _manufacturerView.textLabel.text = [@"生产商：" stringByAppendingString:manufacturerName];
    
    NSString *productName = [SupportingClass verifyAndConvertDataToString:itemDetail[@"name"]];
    
    if (productName&&![productName isEqualToString:@""]) {
        [_dataList addObject:@{@"text":@"产品名称：", @"textFont":vGetHelveticaNeueFont(HelveticaNeueFontTypeOfBold, 16.0f, NO), @"textColor":CDZColorOfBlack,
                               @"subText":productName,  @"subTextFont":vGetHelveticaNeueFont(HelveticaNeueFontTypeOfBold, 16.0f, NO), @"subTextColor":CDZColorOfBlack}];
    }
    
    NSString *productType = [SupportingClass verifyAndConvertDataToString:itemDetail[@"autopartinfoName"]];
    
    if (productType&&![productType isEqualToString:@""]) {
        [_dataList addObject:@{@"text":@"配件种类：", @"textFont":vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 14.0f, NO), @"textColor":CDZColorOfBlack,
                               @"subText":productType,  @"subTextFont":vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 14.0f, NO), @"subTextColor":CDZColorOfBlack}];
    }
    
    
    NSString *centerName = [SupportingClass verifyAndConvertDataToString:itemDetail[@"center_name"]];
    
    if (centerName&&![centerName isEqualToString:@""]) {
        [_dataList addObject:@{@"text":@"采购中心：", @"textFont":vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 14.0f, NO), @"textColor":CDZColorOfBlack,
                               @"subText":centerName,  @"subTextFont":vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 14.0f, NO), @"subTextColor":CDZColorOfBlack}];
    }
    
    NSString *storeName = [SupportingClass verifyAndConvertDataToString:itemDetail[@"store_name"]];
    
    if (storeName&&![storeName isEqualToString:@""]) {
        [_dataList addObject:@{@"text":@"经销商：", @"textFont":vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 14.0f, NO), @"textColor":CDZColorOfBlack,
                               @"subText":storeName,  @"subTextFont":vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 14.0f, NO), @"subTextColor":CDZColorOfBlack}];
    }
    
    NSString *itemPriceText = [NSString stringWithFormat:@"会员价：¥%@.00  ",  [SupportingClass verifyAndConvertDataToString:itemDetail[@"memberprice"]]];
    NSString *oldPriceString = [SupportingClass verifyAndConvertDataToString:itemDetail[@"marketprice"]];
    if (!oldPriceString||[oldPriceString isEqualToString:@""]||[oldPriceString isEqualToString:@"0"]) {
        oldPriceString = @"";
    }else {
        oldPriceString = [NSString stringWithFormat:@"零售价¥%@.00",oldPriceString];
    }
    [_dataList addObject:@{@"text":itemPriceText, @"textFont":vGetHelveticaNeueFont(HelveticaNeueFontTypeOfBold, 18.0f, NO), @"textColor":UIColor.redColor,
                          @"subText":oldPriceString,  @"subTextFont":vGetHelveticaNeueFont(HelveticaNeueFontTypeOfBold, 14.0f, NO), @"subTextColor":CDZColorOfBlack, @"subTextShowLine":@YES,}];
    
    
    
    NSString *totalSale = [SupportingClass verifyAndConvertDataToString:itemDetail[@"leng"]];
    NSString *stockCount = [SupportingClass verifyAndConvertDataToString:itemDetail[@"stocknum"]];
    
    [_dataList addObject:@[@{@"text":@"库存：", @"textFont":vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 14.0f, NO), @"textColor":CDZColorOfBlack,
                             @"subText":stockCount,  @"subTextFont":vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 14.0f, NO), @"subTextColor":CDZColorOfBlack},
                           @{@"text":@"累计销量：", @"textFont":vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 14.0f, NO), @"textColor":CDZColorOfBlack,
                             @"subText":totalSale,  @"subTextFont":vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 14.0f, NO), @"subTextColor":UIColor.redColor}]];
    
    
    
    NSString *starVlaue = @([itemDetail[@"allstar"] floatValue]).stringValue ;
    NSString *totalComment = [SupportingClass verifyAndConvertDataToString:itemDetail[@"all"]];
    [_dataList addObject:@{@"text":@"商品评价：", @"textFont":vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 14.0f, NO), @"textColor":CDZColorOfBlack,
                           @"star":starVlaue,
                           @"subText":[NSString stringWithFormat:@"（%@人评论）", totalComment],  @"subTextFont":vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 14.0f, NO), @"subTextColor":CDZColorOfBlack,
                           @"arrow":@((totalComment.longLongValue>0))}];
    
    
    NSString *expressName = [SupportingClass verifyAndConvertDataToString:itemDetail[@"sendcostName"]];

    if (expressName&&![expressName isEqualToString:@""]) {
        [_dataList addObject:@{@"text":@"运费承担着：", @"textFont":vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 14.0f, NO), @"textColor":CDZColorOfBlack,
                              @"subText":expressName,  @"subTextFont":vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 14.0f, NO), @"subTextColor":CDZColorOfBlack}];
    }
//    UserSelectedAutosInfoDTO *dto = [DBHandler.shareInstance getSelectedAutoData];
//    
//    
//    
//    __block NSString *itemSuitForTitle = getLocalizationString(@"item_non_suitable_for");
//    NSString *modelID = [_autoData.modelID stringValue];
//    if (!modelID) {
//        modelID = @"";
//    }
//    NSArray *array = _itemDetail[@"speci_speci_name"];
//    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        NSDictionary *detail = (NSDictionary *)obj;
//        if ([detail[@"speci_str"] isEqualToString:modelID]||[detail[@"speci_str"] isEqualToString:@"适用所有车型id"]) {
//            itemSuitForTitle = getLocalizationString(@"item_suitable_for");
//            if ([modelID isEqualToString:@""]) itemSuitForTitle = [itemSuitForTitle stringByAppendingString:@"适用所有车型"];
//            *stop = YES;
//        }
//    }];

    NSArray *array = [itemDetail[@"speci_speci_name"] valueForKey:@"speci_name_str"];
    NSString *partCompatibility = [array componentsJoinedByString:@"，"];
    
    if (partCompatibility&&![partCompatibility isEqualToString:@""]) {
        [_dataList addObject:@{@"text":@"适用车型：", @"textFont":vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 14.0f, NO), @"textColor":CDZColorOfBlack,
                               @"subText":partCompatibility,  @"subTextFont":vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 14.0f, NO), @"subTextColor":CDZColorOfBlack}];
    }

    
    
    [_tableView reloadData];
    NSArray *imageList = itemDetail[@"description"];
    if ([itemDetail[@"description"] isKindOfClass:NSArray.class]) {
        [_imageFallsView setupImageList:imageList];
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
