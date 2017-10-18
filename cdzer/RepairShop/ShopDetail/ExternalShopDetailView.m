//
//  ExternalShopDetailView.m
//  cdzer
//
//  Created by KEns0n on 8/29/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//
#define view2ViewSpace (8.0f)
#import "ExternalShopDetailView.h"
#import "InsetsLabel.h"
#import <SDWebImage/UIImageView+WebCache.h>


@interface CertImageTVC : UITableViewCell
@end
@implementation CertImageTVC

- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(0.0f , 0.0f, 60.0f, 60.0f);
    self.imageView.center = CGPointMake(CGRectGetWidth(self.frame)/2.0f, CGRectGetHeight(self.frame)/2.0f);
    self.imageView.autoresizingMask = UIViewAutoresizingNone;
}
@end

@interface ExternalShopDetailView ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) InsetsLabel *titleLabel;

@property (nonatomic, strong) InsetsLabel *introLabel;

@property (nonatomic, strong) InsetsLabel *serviceItems;

@property (nonatomic, strong) UITableView *certsTableView;

@property (nonatomic, strong) NSArray *certsDataArray;

@property (nonatomic, strong) UITableView *equipsTableView;

@property (nonatomic, strong) NSArray *equipsDataArray;

@end

@implementation ExternalShopDetailView

- (void)initializationUIWithShopDetail:(NSDictionary *)shopDetail {
    
    [self setBackgroundColor:CDZColorOfWhite];
    [self setBorderWithColor:[UIColor lightGrayColor] borderWidth:(0.5f)];
    
    CGFloat lastHeight = 0.0f;
    BorderOffsetObject *offset = [BorderOffsetObject new];
    offset.bottomLeftOffset = 10.0f;
    offset.bottomRightOffset = 10.0f;
    
    @autoreleasepool {
        UIColor *commonTextColor = [UIColor colorWithRed:0.353f green:0.345f blue:0.349f alpha:1.00f];
        UIEdgeInsets insetsValue = DefaultEdgeInsets;
        CGFloat width = CGRectGetWidth(self.frame)-insetsValue.left-insetsValue.right;
        CGSize standardSize = CGSizeMake(width, CGFLOAT_MAX);
        
        if (!_titleLabel) {
            self.titleLabel = [[InsetsLabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.frame), 32.0f)
                                              andEdgeInsetsValue:insetsValue];
            _titleLabel.text = @"关于此店";
            _titleLabel.textAlignment = NSTextAlignmentCenter;
            [self addSubview:_titleLabel];
            lastHeight = CGRectGetMaxY(_titleLabel.frame);
            [_titleLabel setViewBorderWithRectBorder:UIRectBorderBottom borderSize:1.0f withColor:UIColor.lightGrayColor withBroderOffset:nil];
        }
        
        NSString *htmlCode = shopDetail[@"user_content"];
        BOOL codeExist = (htmlCode&&![htmlCode isEqualToString:@""]);
        if (!_introLabel&&codeExist) {

            
            CGRect titleRect = self.bounds;
            titleRect.origin.y = lastHeight+view2ViewSpace;
            titleRect.size.height = 30.0f;
            InsetsLabel *serviceTitle = [[InsetsLabel alloc] initWithFrame:titleRect andEdgeInsetsValue:insetsValue];
            serviceTitle.text =  @"简介：";
            [self addSubview:serviceTitle];
            
            NSString *text = [[SupportingClass removeHTML:htmlCode] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            UIFont *font = [UIFont systemFontOfSize:(15.0f)];
            CGRect rect = self.bounds;
            rect.origin.y = CGRectGetMaxY(serviceTitle.frame);
            rect.size.height = [SupportingClass getStringSizeWithString:text font:font widthOfView:standardSize].height+10.0f;
            
            self.introLabel = [[InsetsLabel alloc] initWithFrame:rect andEdgeInsetsValue:insetsValue];
            _introLabel.numberOfLines = 0;
            _introLabel.textAlignment = NSTextAlignmentLeft;
            [_introLabel setText:text];
            [_introLabel setTextColor:commonTextColor];
            [_introLabel setFont:font];
            [self addSubview:_introLabel];
            
            lastHeight = CGRectGetMaxY(_introLabel.frame);
        }
        
        if (!_serviceItems) {
            [_introLabel setViewBorderWithRectBorder:UIRectBorderBottom borderSize:1.0f withColor:UIColor.lightGrayColor withBroderOffset:offset];
            
            CGRect titleRect = self.bounds;
            titleRect.origin.y = lastHeight+view2ViewSpace;
            titleRect.size.height = 30.0f;
            InsetsLabel *serviceTitle = [[InsetsLabel alloc] initWithFrame:titleRect andEdgeInsetsValue:insetsValue];
            serviceTitle.text =  @"商店设施：";
            [self addSubview:serviceTitle];
            
            NSArray *itemsList = shopDetail[@"list_delivery_facility_name"];
            NSString *text = @"";
            if (itemsList&&itemsList.count>0) {
                NSArray *convertList = [itemsList valueForKey:@"delivery_facility_name"];
                text = [convertList componentsJoinedByString:@","];
            }
            
            UIFont *font = [UIFont systemFontOfSize:(15.0f)];
            CGRect rect = self.bounds;
            rect.origin.y = CGRectGetMaxY(serviceTitle.frame);
            rect.size.height = [SupportingClass getStringSizeWithString:text font:font widthOfView:standardSize].height+10.0f;
            
            self.serviceItems = [[InsetsLabel alloc] initWithFrame:rect andEdgeInsetsValue:insetsValue];
            _serviceItems.numberOfLines = 0;
            _serviceItems.textAlignment = NSTextAlignmentLeft;
            [_serviceItems setText:text];
            [_serviceItems setTextColor:commonTextColor];
            [_serviceItems setFont:font];
            [self addSubview:_serviceItems];
            
            lastHeight = CGRectGetMaxY(_serviceItems.frame);
            
        }
        
        
        self.certsDataArray = @[];
        if (shopDetail[@"certificate_honor_list"]&&[shopDetail[@"certificate_honor_list"] isKindOfClass:NSArray.class]) {
            self.certsDataArray = shopDetail[@"certificate_honor_list"];
        }
        if (!_certsTableView&&_certsDataArray.count>0) {
            [_serviceItems setViewBorderWithRectBorder:UIRectBorderBottom borderSize:1.0f withColor:UIColor.lightGrayColor withBroderOffset:offset];
            CGRect titleRect = self.bounds;
            titleRect.origin.y = lastHeight+view2ViewSpace+5.0f;
            titleRect.size.height = 30.0f;
            InsetsLabel *serviceTitle = [[InsetsLabel alloc] initWithFrame:titleRect andEdgeInsetsValue:insetsValue];
            serviceTitle.text =  @"荣誉证书：";
            [self addSubview:serviceTitle];
            
            
            CGRect serviceCommentRect = self.bounds;
            serviceCommentRect.origin.y =  CGRectGetMaxY(serviceTitle.frame);
            serviceCommentRect.size.height = 70.0f;
            self.certsTableView = [[UITableView alloc] init];
            _certsTableView.backgroundColor = CDZColorOfClearColor;
            [_certsTableView setTransform:CGAffineTransformMakeRotation(-M_PI_2)];
            [_certsTableView setFrame:serviceCommentRect];
            [_certsTableView setBounces:NO];
            [_certsTableView setShowsHorizontalScrollIndicator:NO];
            [_certsTableView setShowsVerticalScrollIndicator:NO];
            [_certsTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
            [_certsTableView setDelegate:self];
            [_certsTableView setDataSource:self];
            [self addSubview:_certsTableView];
            
            _certsTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetHeight(_certsTableView.frame), 15.0f)];
            lastHeight = CGRectGetMaxY(_certsTableView.frame);
        }
        
        self.equipsDataArray = @[];
        if (shopDetail[@"list_img"]&&[shopDetail[@"list_img"] isKindOfClass:NSArray.class]) {
            self.equipsDataArray = shopDetail[@"list_img"];
        }
        if (!_equipsTableView&&_equipsDataArray.count>0) {
            [_serviceItems setViewBorderWithRectBorder:UIRectBorderBottom borderSize:1.0f withColor:UIColor.lightGrayColor withBroderOffset:offset];
            CGRect titleRect = self.bounds;
            titleRect.origin.y = lastHeight+view2ViewSpace+5.0f;
            titleRect.size.height = 30.0f;
            InsetsLabel *serviceTitle = [[InsetsLabel alloc] initWithFrame:titleRect andEdgeInsetsValue:insetsValue];
            serviceTitle.text =  @"硬件、设备：";
            [self addSubview:serviceTitle];
            
            
            CGRect serviceCommentRect = self.bounds;
            serviceCommentRect.origin.y =  CGRectGetMaxY(serviceTitle.frame);
            serviceCommentRect.size.height = 70.0f;
            self.equipsTableView = [[UITableView alloc] init];
            _equipsTableView.backgroundColor = CDZColorOfClearColor;
            [_equipsTableView setTransform:CGAffineTransformMakeRotation(-M_PI_2)];
            [_equipsTableView setFrame:serviceCommentRect];
            [_equipsTableView setBounces:NO];
            [_equipsTableView setShowsHorizontalScrollIndicator:NO];
            [_equipsTableView setShowsVerticalScrollIndicator:NO];
            [_equipsTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
            [_equipsTableView setDelegate:self];
            [_equipsTableView setDataSource:self];
            [self addSubview:_equipsTableView];
            
            _equipsTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetHeight(_equipsTableView.frame), 15.0f)];
            lastHeight = CGRectGetMaxY(_equipsTableView.frame);
        }
        
        
        CGRect frame = self.frame;
        frame.size.height = lastHeight+10.0f;
        self.frame = frame;
    }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (tableView==_certsTableView) {
        return _certsDataArray.count;
    }
    if (tableView==_equipsTableView) {
        return _equipsDataArray.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CertImageTVC *cell = [tableView dequeueReusableCellWithIdentifier:CDZKeyOfCellIdentKey];
    if (!cell) {
        cell = [[CertImageTVC alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CDZKeyOfCellIdentKey];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell setBackgroundColor:CDZColorOfClearColor];
        [cell.contentView setBackgroundColor:CDZColorOfClearColor];
        [cell setTransform:CGAffineTransformMakeRotation(M_PI_2)];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.hidden = YES;
    }
    cell.imageView.image = ImageHandler.getWhiteLogo;
    if (_certsDataArray.count>0&&tableView==_certsTableView) {
        NSString *url = _certsDataArray[indexPath.row];
        if ([url rangeOfString:@"http"].location!=NSNotFound) {
            [cell.imageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:cell.imageView.image];
        }
    }
    if (_equipsDataArray.count>0&&tableView==_equipsTableView) {
        NSString *url = [_equipsDataArray[indexPath.row] valueForKey:@"equipment_img"];
        if ([url rangeOfString:@"http"].location!=NSNotFound) {
            [cell.imageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:cell.imageView.image];
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CGRectGetHeight(tableView.frame);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}



@end
