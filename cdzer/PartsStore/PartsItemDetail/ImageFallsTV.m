//
//  ImageFallsTV.m
//  cdzer
//
//  Created by KEns0n on 9/25/15.
//  Copyright © 2015 CDZER. All rights reserved.
//

#import "ImageFallsTV.h"
#import "InsetsLabel.h"
#import <SDWebImage/SDWebImageManager.h>
#import <SDWebImage/SDWebImageOperation.h>
@interface ImageFallsTV () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *imageList;

@property (nonatomic, strong) NSMutableArray *downloaderList;

@end

@implementation ImageFallsTV

- (void)dealloc {
    [_downloaderList enumerateObjectsUsingBlock:^(id  _Nonnull downloader, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![downloader isKindOfClass:NSNull.class]) {
            if ([downloader respondsToSelector:@selector(cancel)]) {
                [downloader cancel];
            }
        }
    }];
    [self.downloaderList removeAllObjects];
    [self.imageList removeAllObjects];
    
    self.downloaderList = nil;
    self.imageList = nil;
}

- (instancetype)init{
    self = [self initWithFrame:CGRectZero];
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setReactiveRules];
        self.delegate = self;
        self.dataSource = self;
        if (!self.imageList) {
            self.imageList = [@[] mutableCopy];
        }
        if (!self.downloaderList) {
            self.downloaderList = [@[] mutableCopy];
        }
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self setReactiveRules];
    self.delegate = self;
    self.dataSource = self;
    if (!self.imageList) {
        self.imageList = [@[] mutableCopy];
    }
    if (!self.downloaderList) {
        self.downloaderList = [@[] mutableCopy];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];

    
}

- (void)setReactiveRules {
    @weakify(self);
    [RACObserve(self, contentSize) subscribeNext:^(id size) {
        @strongify(self);
        CGSize contentSize = [size CGSizeValue];
        CGRect frame = self.frame;
        frame.size.height = contentSize.height;
        self.frame = frame;
    }];
}

- (void)setupImageList:(NSArray *)imageList {
    
    [_downloaderList removeAllObjects];
    [_imageList removeAllObjects];
    if (imageList.count==0||!imageList) {
        [_imageList addObject:@"NoList"];
        [_downloaderList addObject:@"NoList"];
    }else {
        @weakify(self);
        [imageList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL * stop) {
            NSString *imageURL = obj;
            @strongify(self);
            if (![imageURL isEqualToString:@""]&&imageURL&&[imageURL rangeOfString:@"http"].location!=NSNotFound) {
                [self.downloaderList addObject:[NSNull null]];
                [self.imageList addObject:@{@"url":imageURL,@"image":[NSNull null],@"downloading":@NO,@"downloadFail":@NO}];
            }
        }];
    }
    [self reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return _imageList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CDZKeyOfCellIdentKey];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CDZKeyOfCellIdentKey];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:cell.contentView.bounds];
        imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        imageView.translatesAutoresizingMaskIntoConstraints = YES;
        imageView.tag = 1010;
        [cell.contentView addSubview:imageView];
        
        UIView *hudView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(cell.frame)*0.25, 0.0f, CGRectGetWidth(cell.frame)*0.5, CGRectGetHeight(cell.frame))];
        hudView.tag = 1011;
        [cell.contentView addSubview:hudView];
        
        UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        indicatorView.center = CGPointMake(indicatorView.center.x, CGRectGetHeight(hudView.frame)/2.0f);
        indicatorView.tag = 1100;
        indicatorView.color = [UIColor grayColor];
        [indicatorView startAnimating];
        indicatorView.hidesWhenStopped = NO;
        [hudView addSubview:indicatorView];
        
        UIProgressView *progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        CGRect progressViewFrame = progressView.frame;
        progressViewFrame.size.width = CGRectGetWidth(hudView.frame)-CGRectGetMaxX(indicatorView.frame)-10.0f;
        progressViewFrame.origin.x = CGRectGetMaxX(indicatorView.frame)+5.0f;
        progressView.frame = progressViewFrame;
        progressView.center = CGPointMake(progressView.center.x, CGRectGetHeight(hudView.frame)/2.0f);
        progressView.tag = 1101;
        progressView.progress = 0.0f;
        progressView.progressTintColor = CDZColorOfDefaultColor;
        progressView.trackTintColor = CDZColorOfGray;
        [hudView addSubview:progressView];
        
        InsetsLabel *label = [[InsetsLabel alloc] initWithFrame:cell.contentView.bounds
                                             andEdgeInsetsValue:DefaultEdgeInsets];
        label.tag = 1012;
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"抱歉！暂无更多图文信息！";
        label.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfBold, 18.0f, NO);
        label.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        label.translatesAutoresizingMaskIntoConstraints = YES;
        label.hidden = YES;
        [cell.contentView addSubview:label];
    }
    // Configure the cell...
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:1010];
    imageView.image = nil;
    imageView.hidden = NO;
    UIView *hudView = (UIView *)[cell viewWithTag:1011];
    hudView.hidden = NO;
    InsetsLabel *label = (InsetsLabel *)[cell viewWithTag:1012];
    label.hidden = YES;
    
    if ([_imageList[indexPath.row] isKindOfClass:NSString.class]) {
        imageView.hidden = YES;
        hudView.hidden = YES;
        label.hidden = NO;
    }else {
        label.hidden = YES;
        NSMutableDictionary *deatil = [_imageList[indexPath.row] mutableCopy];
        NSString *urlString = deatil[@"url"];
        if (![deatil[@"image"] isKindOfClass:NSNull.class]) {
            imageView.image = deatil[@"image"];
            hudView.hidden = YES;
            imageView.hidden = NO;
        }else {
            hudView.hidden = NO;
            imageView.hidden = YES;
            BOOL downloading = [deatil[@"downloading"] boolValue];
            if (!downloading) {
                [self downloadImage:urlString withIndex:indexPath];
                [deatil setObject:@YES forKey:@"downloading"];
                [_imageList replaceObjectAtIndex:indexPath.row withObject:deatil];
            }
        }
    }
    
    
    return cell;
}

- (void)delayRelaodDownloadImage:(NSArray *)objsList {
    [self downloadImage:objsList[0] withIndex:objsList[1]];
    
}

- (void)downloadImage:(NSString *)urlString withIndex:(NSIndexPath *)indexPath {
    @weakify(self);
    if (indexPath.row<=_downloaderList.count-1) {
        if (![_downloaderList[indexPath.row] isKindOfClass:[NSNull class]]) {
            id downloader = _downloaderList[indexPath.row];
            if ([downloader respondsToSelector:@selector(cancel)]) {
                [downloader cancel];
            }
        }
        _downloaderList[indexPath.row] = NSNull.null;
    }
    id downloader = [SDWebImageDownloader.sharedDownloader downloadImageWithURL:[NSURL URLWithString:urlString]  options:SDWebImageDelayPlaceholder|SDWebImageAvoidAutoSetImage progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        @strongify(self);
        UITableViewCell *cell = [self cellForRowAtIndexPath:indexPath];
        UIView *hudView = (UIView *)[cell viewWithTag:1011];
        UIProgressView *progressView = [hudView viewWithTag:1101];
        if (progressView) {
            CGFloat progress = (CGFloat)(receivedSize/expectedSize);
            NSLog(@"progress%f", progress);
            progressView.progress = progress;
        }
    } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
        NSMutableDictionary *deatil = [self.imageList[indexPath.row] mutableCopy];
        [deatil setObject:@YES forKey:@"downloadFail"];
        @strongify(self);
        if (!error&&image) {
            [deatil setObject:image forKey:@"image"];
            [deatil setObject:@NO forKey:@"downloadFail"];
        }
        [deatil setObject:@NO forKey:@"downloading"];
        [self.imageList replaceObjectAtIndex:indexPath.row withObject:deatil];
        if (!error&&image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                // code here
                @strongify(self);
                [self reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            });
        }else {
            @strongify(self);
            [self performSelector:@selector(delayRelaodDownloadImage:)
                       withObject:@[urlString, indexPath] afterDelay:1];
        }
    }];
    if (downloader) {
        _downloaderList[indexPath.row] = downloader;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_imageList[indexPath.row] isKindOfClass:NSDictionary.class]) {
        NSDictionary *deatil = _imageList[indexPath.row];
        if (deatil&&![deatil[@"image"] isKindOfClass:NSNull.class]) {
            UIImage *image = deatil[@"image"];
            CGSize size = CGSizeMake(image.size.width*image.scale, image.size.height*image.scale);
            CGFloat finalHeight = size.height/(size.width/CGRectGetWidth(self.frame));
            return finalHeight;
        }
    }
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
