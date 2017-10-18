//
//  ShopInfoDetail.m
//  cdzer
//
//  Created by KEns0n on 3/10/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//
#define view2ViewSpace (8.0f)
#import "ShopInfoDetail.h"
#import "InsetsLabel.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface BrandSupportTVC : UITableViewCell
@end
@implementation BrandSupportTVC

- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(0.0f , 5.0f, 30.0f, 30.0f);
    self.imageView.center = CGPointMake(CGRectGetWidth(self.frame)/2.0f, self.imageView.center.y);
    
    CGRect textFrame = CGRectZero;
    textFrame.origin.y = CGRectGetMaxY(self.imageView.frame);
    textFrame.size = CGSizeMake(CGRectGetWidth(self.frame), 20.0f);
    self.textLabel.frame = textFrame;
    
    self.imageView.autoresizingMask = UIViewAutoresizingNone;
}

@end

@interface ShopInfoDetail ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIImageView *certificationLogo;

@property (nonatomic, strong) InsetsLabel *storeTitleLabel;

@property (nonatomic, strong) InsetsLabel *typeLabel;

@property (nonatomic, strong) InsetsLabel *addreeLabel;

@property (nonatomic, strong) InsetsLabel *telLabel;

@property (nonatomic, strong) InsetsLabel *priceLabel;

@property (nonatomic, strong) InsetsLabel *totalBookmark;

@property (nonatomic, strong) InsetsLabel *totalTransaction;

@property (nonatomic, strong) InsetsLabel *businessTime;

@property (nonatomic, strong) InsetsLabel *serviceItems;

@property (nonatomic, strong) InsetsLabel *titl;

@property (nonatomic, strong) UITableView *brandSupportTV;

@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation ShopInfoDetail

- (void)initializationUIWithDetailData:(NSDictionary *)detailData {
    @autoreleasepool {
        [self setBackgroundColor:CDZColorOfWhite];
        [self setBorderWithColor:[UIColor lightGrayColor] borderWidth:(0.5f)];
        
        UIColor *commonTextColor = [UIColor colorWithRed:0.353f green:0.345f blue:0.349f alpha:1.00f];
        NSTextAlignment standardAlignment = NSTextAlignmentLeft;
        
        UIEdgeInsets insetsValue = DefaultEdgeInsets;
        CGFloat width = CGRectGetWidth(self.frame)-insetsValue.left-insetsValue.right;
        CGSize standardSize = CGSizeMake(width, CGFLOAT_MAX);
        if (!_storeTitleLabel) {
            UIFont *font = systemFontWithoutRatio(19.0f);
            NSString *text = detailData[@"wxs_name"];
            CGRect rect = self.bounds;
            rect.origin.y = 10.0f;
            rect.size.height = [SupportingClass getStringSizeWithString:text font:font widthOfView:CGSizeMake(width, CGFLOAT_MAX)].height;
            
            self.storeTitleLabel = [[InsetsLabel alloc] initWithFrame:rect andEdgeInsetsValue:insetsValue];
            [_storeTitleLabel setText:text];
            [_storeTitleLabel setFont:font];
            [_storeTitleLabel setNumberOfLines:0];
            [_storeTitleLabel setTextAlignment:standardAlignment];
            [self addSubview:_storeTitleLabel];
            
        }
        
        if (!_certificationLogo&&[detailData[@"state"] isEqualToString:@"14111811172655228577"]) {
            UIImage *image = [ImageHandler getImageFromCacheByScreenRatioWithFileRootPath:kSysImageCaches
                                                                                 fileName:@"certification"
                                                                                     type:FMImageTypeOfPNG
                                                                          scaleWithPhone4:NO
                                                                              offsetRatioForP4:1.0f
                                                                             needToUpdate:YES];
            CGRect rect = CGRectZero;
            rect.origin.x = CGRectGetMaxX(_storeTitleLabel.frame);
            rect.origin.y = CGRectGetMinY(_storeTitleLabel.frame)+(4.0f);
            rect.size = image.size;
            [self setCertificationLogo:[[UIImageView alloc] initWithImage:image]];
            [_certificationLogo setFrame:rect];
            [self addSubview:_certificationLogo];
        }
        
        if (!_priceLabel) {
            id defaultValue = detailData[@"supplier_hoursprice"];
            id memberValue = detailData[@"member_hoursprice"];
            NSString *defaultPrice = @"0";
            if ([defaultValue isKindOfClass:[NSNumber class]]) {
                defaultPrice = [defaultValue stringValue];
            }else if ([defaultValue isKindOfClass:[NSString class]]) {
                if(![defaultValue isEqualToString:@""]) defaultPrice = defaultValue;
            }
            NSString *memberPrice = @"0";
            if ([memberValue isKindOfClass:[NSNumber class]]) {
                memberPrice = [memberValue stringValue];
            }else if ([memberValue isKindOfClass:[NSString class]]) {
                if(![memberValue isEqualToString:@""]) memberPrice = memberValue;
            }
            
            NSMutableAttributedString* priceString = [NSMutableAttributedString new];
            [priceString appendAttributedString:[[NSAttributedString alloc]
                                                 initWithString:@"非会员价："
                                                 attributes:@{NSForegroundColorAttributeName:commonTextColor,
                                                              NSFontAttributeName:systemFontWithoutRatio(15.0f)
                                                              }]];
            [priceString appendAttributedString:[[NSAttributedString alloc]
                                                 initWithString:[@"¥" stringByAppendingFormat:@"%@", defaultPrice]
                                                 attributes:@{NSForegroundColorAttributeName:[UIColor redColor],
                                                              NSFontAttributeName:systemFontBoldWithoutRatio(15.0f)
                                                              }]];
            [priceString appendAttributedString:[[NSAttributedString alloc]
                                                 initWithString:@"/工时   "
                                                 attributes:@{NSForegroundColorAttributeName:commonTextColor,
                                                              NSFontAttributeName:systemFontWithoutRatio(15.0f)
                                                              }]];
            
            [priceString appendAttributedString:[[NSAttributedString alloc]
                                                 initWithString:@"会员价："
                                                 attributes:@{NSForegroundColorAttributeName:commonTextColor,
                                                              NSFontAttributeName:systemFontWithoutRatio(15.0f)
                                                              }]];
            [priceString appendAttributedString:[[NSAttributedString alloc]
                                                 initWithString:[@"¥" stringByAppendingFormat:@"%@", memberPrice]
                                                 attributes:@{NSForegroundColorAttributeName:[UIColor redColor],
                                                              NSFontAttributeName:systemFontBoldWithoutRatio(15.0f)
                                                              }]];
            [priceString appendAttributedString:[[NSAttributedString alloc]
                                                 initWithString:@"/工时"
                                                 attributes:@{NSForegroundColorAttributeName:commonTextColor,
                                                              NSFontAttributeName:systemFontWithoutRatio(15.0f)
                                                              }]];
            
            UIEdgeInsets localInsetsValue = insetsValue;
            CGFloat localWidth = CGRectGetWidth(self.frame);
            CGSize localStandardSize = CGSizeMake(localWidth, CGFLOAT_MAX);
            
            CGRect rect = CGRectZero;
            rect.origin.y = CGRectGetMaxY(_storeTitleLabel.frame)+view2ViewSpace;
            rect.size.width = CGRectGetWidth(self.frame);
            rect.size.height = [SupportingClass getAttributedStringSizeWithString:priceString widthOfView:localStandardSize withEdgeInset:localInsetsValue].height;
            self.priceLabel = [[InsetsLabel alloc] initWithFrame:rect andEdgeInsetsValue:localInsetsValue];
            [_priceLabel setAttributedText:priceString];
            [_priceLabel setNumberOfLines:-1];
            [_priceLabel setTextAlignment:NSTextAlignmentLeft];
            [self addSubview:_priceLabel];
        }
        
        
        if (!_typeLabel) {
            UIFont *font = [UIFont systemFontOfSize:(15.0f)];
            NSString *text = [@"商店类型：" stringByAppendingString:detailData[@"user_kind_name"]];
            
            UIEdgeInsets localInsetsValue = insetsValue;
            CGFloat localWidth = CGRectGetWidth(self.frame);
            CGSize localStandardSize = CGSizeMake(localWidth, CGFLOAT_MAX);

            CGRect rect = _priceLabel.frame;
            rect.origin.y = CGRectGetMaxY(_priceLabel.frame)+view2ViewSpace;
            rect.size.width = CGRectGetWidth(self.frame);
            rect.size.height = [SupportingClass getStringSizeWithString:text font:font widthOfView:localStandardSize].height;
            
            self.typeLabel = [[InsetsLabel alloc] initWithFrame:rect andEdgeInsetsValue:localInsetsValue];
            [_typeLabel setText:text];
            [_typeLabel setTextColor:commonTextColor];
            [_typeLabel setFont:font];
            [_typeLabel setTextAlignment:standardAlignment];
            [self addSubview:_typeLabel];
        }
        
        if (!_telLabel) {
            NSString *dataKey = @"wxs_telphone";
            UIFont *font = [UIFont systemFontOfSize:(15.0f)];
            NSString *tel = detailData[dataKey];
            if ([detailData[dataKey] isKindOfClass:NSNumber.class]) {
                tel = [detailData[dataKey] stringValue];
            }
            NSString *text = [@"电话：" stringByAppendingString:tel];
            CGRect rect = _storeTitleLabel.frame;
            rect.origin.y = CGRectGetMaxY(_typeLabel.frame)+view2ViewSpace;
            rect.size.height = [SupportingClass getStringSizeWithString:text font:font widthOfView:standardSize].height;
            
            self.telLabel = [[InsetsLabel alloc] initWithFrame:rect andEdgeInsetsValue:insetsValue];
            [_telLabel setText:text];
            [_telLabel setTextColor:commonTextColor];
            [_telLabel setFont:font];
            [self addSubview:_telLabel];
            
            UIButton *telButton = [UIButton buttonWithType:UIButtonTypeSystem];
            telButton.frame = _telLabel.frame;
            [telButton addTarget:self action:@selector(dialTelphone) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:telButton];
        }
        
        if (!_addreeLabel) {
            UIFont *font = [UIFont systemFontOfSize:(15.0f)];
            NSString *text = [@"地址：" stringByAppendingString:detailData[@"address"]];
            CGRect rect = _storeTitleLabel.frame;
            rect.origin.y = CGRectGetMaxY(_telLabel.frame)+view2ViewSpace;
            rect.size.height = [SupportingClass getStringSizeWithString:text font:font widthOfView:standardSize].height;
            
            self.addreeLabel = [[InsetsLabel alloc] initWithFrame:rect andEdgeInsetsValue:insetsValue];
            [_addreeLabel setText:text];
            _addreeLabel.numberOfLines = 0;
            [_addreeLabel setTextColor:commonTextColor];
            [_addreeLabel setFont:font];
            [self addSubview:_addreeLabel];
        }
        
        if (!_businessTime) {
            UIFont *font = [UIFont systemFontOfSize:(15.0f)];
            NSString *title = @"营业时间：";
            UIEdgeInsets localTitleInsetsValue = insetsValue;
            localTitleInsetsValue.right = 0.0f;
            CGRect titleRect = self.bounds;
            titleRect.size = [SupportingClass getStringSizeWithString:title font:font widthOfView:standardSize];
            titleRect.size.width +=localTitleInsetsValue.left;
            InsetsLabel *businessTitle = [[InsetsLabel alloc] initWithFrame:titleRect andEdgeInsetsValue:localTitleInsetsValue];
            [businessTitle setText:title];
            [businessTitle setTextColor:commonTextColor];
            [businessTitle setFont:font];
            
            UIEdgeInsets localInsetsValue = insetsValue;
            localInsetsValue.left = CGRectGetMaxX(titleRect);
            CGFloat localWidth = CGRectGetWidth(self.frame)-localInsetsValue.left-localInsetsValue.right;
            CGSize localStandardSize = CGSizeMake(localWidth, CGFLOAT_MAX);
            NSString *text = detailData[@"service_time"];
            if (!text) {
                text = @"";
            }else {
                text = [text stringByReplacingOccurrencesOfString:@"," withString:@"  "];
                text = [text stringByReplacingOccurrencesOfString:@"，" withString:@"  "];
                
                text = [text stringByReplacingOccurrencesOfString:@"--" withString:@"－"];
                text = [text stringByReplacingOccurrencesOfString:@"－－" withString:@"－"];
                text = [text stringByReplacingOccurrencesOfString:@"——" withString:@"－"];
            }
            
            CGRect rect = self.bounds;
            rect.origin.y = CGRectGetMaxY(_addreeLabel.frame)+view2ViewSpace;
            rect.size.height = [SupportingClass getStringSizeWithString:text font:font widthOfView:localStandardSize].height;
            
            self.businessTime = [[InsetsLabel alloc] initWithFrame:rect andEdgeInsetsValue:localInsetsValue];
            _businessTime.numberOfLines = 0;
            _businessTime.textAlignment = NSTextAlignmentLeft;
            [_businessTime setText:text];
            [_businessTime setTextColor:commonTextColor];
            [_businessTime setFont:font];
            [_businessTime addSubview:businessTitle];
            [self addSubview:_businessTime];
            
        }
        
        if (!_serviceItems) {
            UIFont *font = [UIFont systemFontOfSize:(15.0f)];
            NSString *title = @"服务项目：";
            UIEdgeInsets localTitleInsetsValue = insetsValue;
            localTitleInsetsValue.right = 0.0f;
            CGRect titleRect = self.bounds;
            titleRect.size = [SupportingClass getStringSizeWithString:title font:font widthOfView:standardSize];
            titleRect.size.width +=localTitleInsetsValue.left;
            InsetsLabel *businessTitle = [[InsetsLabel alloc] initWithFrame:titleRect andEdgeInsetsValue:localTitleInsetsValue];
            [businessTitle setText:title];
            [businessTitle setTextColor:commonTextColor];
            [businessTitle setFont:font];
            
            UIEdgeInsets localInsetsValue = insetsValue;
            localInsetsValue.left = CGRectGetMaxX(titleRect);
            CGFloat localWidth = CGRectGetWidth(self.frame)-localInsetsValue.left-localInsetsValue.right;
            CGSize localStandardSize = CGSizeMake(localWidth, CGFLOAT_MAX);
            NSArray *itemsList = detailData[@"list_service_item_name"];
            NSString *text = @"";
            if (itemsList&&itemsList.count>0) {
                NSArray *convertList = [itemsList valueForKey:@"service_item_name"];
                text = [convertList componentsJoinedByString:@","];
            }
            
            CGRect rect = self.bounds;
            rect.origin.y = CGRectGetMaxY(_businessTime.frame)+view2ViewSpace;
            rect.size.height = [SupportingClass getStringSizeWithString:text font:font widthOfView:localStandardSize].height;
            
            self.serviceItems = [[InsetsLabel alloc] initWithFrame:rect andEdgeInsetsValue:localInsetsValue];
            _serviceItems.numberOfLines = 0;
            _serviceItems.textAlignment = NSTextAlignmentLeft;
            [_serviceItems setText:text];
            [_serviceItems setTextColor:commonTextColor];
            [_serviceItems setFont:font];
            [_serviceItems addSubview:businessTitle];
            [self addSubview:_serviceItems];
            
        }
        
        if (!_totalBookmark) {
            UIEdgeInsets localInsetsValue = insetsValue;
            localInsetsValue.right = 5.0f;
            CGFloat localWidth = CGRectGetWidth(self.frame)/2.0f-localInsetsValue.left-localInsetsValue.right;
            CGSize localStandardSize = CGSizeMake(localWidth, CGFLOAT_MAX);
            
            UIFont *font = [UIFont systemFontOfSize:(15.0f)];
            NSString *text = [@"收藏人数：" stringByAppendingString:detailData[@"favorite_length"]];
            CGRect rect = _storeTitleLabel.frame;
            rect.origin.y = CGRectGetMaxY(_serviceItems.frame)+view2ViewSpace;
            rect.size.width = CGRectGetWidth(self.frame)/2.0f;
            rect.size.height = [SupportingClass getStringSizeWithString:text font:font widthOfView:localStandardSize].height;
            
            self.totalBookmark = [[InsetsLabel alloc] initWithFrame:rect andEdgeInsetsValue:localInsetsValue];
            _totalBookmark.numberOfLines = 0;
            [_totalBookmark setText:text];
            [_totalBookmark setTextColor:commonTextColor];
            [_totalBookmark setFont:font];
            [self addSubview:_totalBookmark];
        }
        
        if (!_totalTransaction) {
            
            UIEdgeInsets localInsetsValue = insetsValue;
            localInsetsValue.left = 5.0f;
            CGFloat localWidth = CGRectGetWidth(self.frame)/2.0f-localInsetsValue.left-localInsetsValue.right;
            CGSize localStandardSize = CGSizeMake(localWidth, CGFLOAT_MAX);
            CGFloat fontSize = 15.0f;
            NSMutableAttributedString* message = [NSMutableAttributedString new];
            [message appendAttributedString:[[NSAttributedString alloc]
                                             initWithString:@"成交量："
                                             attributes:@{NSForegroundColorAttributeName:commonTextColor,
                                                          NSFontAttributeName:systemFontWithoutRatio(fontSize)
                                                          }]];
            [message appendAttributedString:[[NSAttributedString alloc]
                                             initWithString:detailData[@"trading_size"]
                                             attributes:@{NSForegroundColorAttributeName:[UIColor redColor],
                                                          NSFontAttributeName:systemFontBoldWithoutRatio(fontSize)
                                                          }]];
            [message appendAttributedString:[[NSAttributedString alloc]
                                             initWithString:@" 次"
                                             attributes:@{NSForegroundColorAttributeName:commonTextColor,
                                                          NSFontAttributeName:systemFontWithoutRatio(fontSize)
                                                          }]];
            
            CGRect rect = _totalBookmark.frame;
            rect.origin.x = CGRectGetMaxX(_totalBookmark.frame);
            rect.size.width = CGRectGetWidth(self.frame)/2.0f;
            rect.size.height = [SupportingClass getAttributedStringSizeWithString:message widthOfView:localStandardSize].height;
            self.totalTransaction = [[InsetsLabel alloc] initWithFrame:rect andEdgeInsetsValue:localInsetsValue];
            _totalTransaction.numberOfLines = 0;
            [_totalTransaction setAttributedText:message];
            [_totalTransaction setTextAlignment:NSTextAlignmentLeft];
            [self addSubview:_totalTransaction];
        }
        
        if (!_brandSupportTV) {
            UIEdgeInsets localInsetsValue = insetsValue;
            localInsetsValue.right = 0.0f;
            UIFont *font = [UIFont systemFontOfSize:(15.0f)];
            NSString *text = @"主修品牌：";
            CGRect rect = self.bounds;
            rect.origin.y = CGRectGetMaxY(_totalBookmark.frame)+view2ViewSpace;
            rect.size = [SupportingClass getStringSizeWithString:text font:font widthOfView:standardSize];
            rect.size.width += localInsetsValue.left;
            
            InsetsLabel *titleLabel = [[InsetsLabel alloc] initWithFrame:rect andEdgeInsetsValue:localInsetsValue];
            [titleLabel setText:text];
            [titleLabel setTextColor:commonTextColor];
            [titleLabel setFont:font];
            [self addSubview:titleLabel];
            
            self.dataArray = @[];
            if ([detailData[@"list_brand"] isKindOfClass:NSArray.class]) {
                self.dataArray = detailData[@"list_brand"];
            }
            
            CGRect serviceCommentRect = CGRectZero;
            serviceCommentRect.origin = CGPointMake(CGRectGetMaxX(titleLabel.frame), CGRectGetMaxY(_totalBookmark.frame)+view2ViewSpace);
            serviceCommentRect.size.width = CGRectGetWidth(self.frame) - CGRectGetMaxX(titleLabel.frame);
            serviceCommentRect.size.height = 40.0f;
            self.brandSupportTV = [[UITableView alloc] init];
            _brandSupportTV.backgroundColor = CDZColorOfClearColor;
            [_brandSupportTV setTransform:CGAffineTransformMakeRotation(-M_PI_2)];
            [_brandSupportTV setFrame:serviceCommentRect];
            [_brandSupportTV setBounces:NO];
            [_brandSupportTV setShowsHorizontalScrollIndicator:NO];
            [_brandSupportTV setShowsVerticalScrollIndicator:NO];
            [_brandSupportTV setSeparatorStyle:UITableViewCellSeparatorStyleNone];
            [_brandSupportTV setDelegate:self];
            [_brandSupportTV setDataSource:self];
            [self addSubview:_brandSupportTV];

            titleLabel.center = CGPointMake(titleLabel.center.x, CGRectGetMidY(_brandSupportTV.frame));
        }
        
        
        CGRect rect = self.frame;
        rect.size.height = CGRectGetMaxY(_brandSupportTV.frame)+(10.0f);
        [self setFrame:rect];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BrandSupportTVC *cell = [tableView dequeueReusableCellWithIdentifier:CDZKeyOfCellIdentKey];
    if (!cell) {
        cell = [[BrandSupportTVC alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CDZKeyOfCellIdentKey];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell setBackgroundColor:CDZColorOfClearColor];
        [cell.contentView setBackgroundColor:CDZColorOfClearColor];
        [cell setTransform:CGAffineTransformMakeRotation(M_PI_2)];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.hidden = YES;
    }
    cell.imageView.image = ImageHandler.getWhiteLogo;
    cell.textLabel.text = @"";
    if (_dataArray.count>0) {
        NSString *url = [_dataArray[indexPath.row] objectForKey:@"brand_img"];
        if ([url rangeOfString:@"http"].location!=NSNotFound) {
            [cell.imageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:cell.imageView.image];
        }
        cell.textLabel.text =  [_dataArray[indexPath.row] objectForKey:@"majora_brand"];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CGRectGetHeight(tableView.frame);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)dialTelphone {
    if (![_telLabel.text isEqualToString:@""]) {
        @autoreleasepool {
            NSString *telNum = [_telLabel.text stringByTrimmingCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet]];
            [SupportingClass makeACall:telNum];
        }
    }
}

@end
