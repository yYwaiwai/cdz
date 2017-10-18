//
//  NetProgressImageView.m
//  cdzer
//
//  Created by KEns0n on 4/22/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#import <AFNetworking/AFNetworking.h>
#import "NetProgressImageView.h"
#import "UIView+LayoutConstraintHelper.h"
#import "FileManager.h"
#import "AMTumblrHud.h"
#import "ExifContainer.h"
#import "ExifReader.h"
@interface NetProgressImageView ()

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) NSURLSessionDataTask *operation;

@property (nonatomic, strong) AMTumblrHud *loadingHUD;
@end

static UIImage *placeHolderImage = nil;
@implementation NetProgressImageView

- (void)setPlaceHolderImage {
    placeHolderImage = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"pcmvc_default_ portrait_icon@3x" ofType:@"png"]];
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)initHUDUIWithFrame:(CGRect)frame {
    if (!self.loadingHUD) {
        self.loadingHUD = [[AMTumblrHud alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 55, 20)];
        [self addSubview:self.loadingHUD];
    }
    [self.loadingHUD setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin];
    self.loadingHUD.hudColor = UIColorFromRGB(0xF1F2F3);
    if (!CGRectEqualToRect(frame, CGRectZero)) {
        [self.loadingHUD setCenter:CGPointMake(CGRectGetWidth(frame)/2.0f, CGRectGetHeight(frame)/2.0f)];
    }
    [self.loadingHUD hide];
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.loadingHUD) {
        [self.loadingHUD setCenter:CGPointMake(CGRectGetWidth(self.frame)/2.0f, CGRectGetHeight(self.frame)/2.0f)];
    }
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = CGRectGetHeight(self.frame)/2.0f;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setPlaceHolderImage];
        self.imageView = [[UIImageView alloc] initWithImage:placeHolderImage];
        self.imageView.contentMode = UIViewContentModeCenter;
        [self.imageView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin];
        [self addSubview:self.imageView];
        [self initHUDUIWithFrame:CGRectZero];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        [self setPlaceHolderImage];
        self.imageView = [[UIImageView alloc] initWithImage:placeHolderImage];
        self.imageView.contentMode = UIViewContentModeCenter;
        self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
        self.imageView.frame = self.bounds;
        [self.imageView addSelfByFourMarginToSuperview:self];
        [self addSubview:self.imageView];
        [self initHUDUIWithFrame:CGRectZero];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setPlaceHolderImage];
        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.imageView.contentMode = UIViewContentModeCenter;
        [self.imageView setImage:placeHolderImage];
        [self.imageView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin];
        [self addSubview:self.imageView];
        [self initHUDUIWithFrame:frame];
    }
    return self;
}

- (instancetype)initWithImageURL:(NSString *)imageURL frame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setPlaceHolderImage];
        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.imageView.contentMode = UIViewContentModeCenter;
        [self.imageView setImage:placeHolderImage];
        [self.imageView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin];
        [self addSubview:self.imageView];
        [self initHUDUIWithFrame:frame];
    }
    return self;
}

- (void)dealloc {
    if (_operation.state!=NSURLSessionTaskStateCompleted) {
        [_operation cancel];
    }
    _operation = nil;
}

- (void)clearImage {
    [self.imageView setImage:nil];
    [self.imageView setImage:placeHolderImage];
    self.imageView.contentMode = UIViewContentModeCenter;
    [self.loadingHUD hide];
}

- (BOOL)imageCacheFileExistAndVaildWithFileName:(NSString *)fileName extType:(NSString *)extType isUserPortrait:(BOOL)isPortrait sourceImageURL:(NSString *)urlStr{

    if (!_imageURL||!fileName||!extType) {
        return NO;
    }
    
    @autoreleasepool {
        if ([FileManager checkFileIsExistWithtRootType:FMRootFolderTypeOfCache
                                               subPath:kUserPortraitCaches
                                               theFile:[FileManager convertImageNameByScale:fileName]
                                               extType:extType
                                           isDirectory:NO]) {
            NSString *fullPath = [FileManager getFileFullPathFromCacheWithRootFolder:FMRootFolderTypeOfCache fileName:fileName extType:extType subFolder:kUserPortraitCaches isImage:YES];
            
            ExifReader * imageInfo = [[ExifReader alloc]initWithURL:[NSURL fileURLWithPath:fullPath]];
            NSDictionary *exifInfo = imageInfo.imageExifDictionary;
            if (exifInfo&&[exifInfo objectForKey:(NSString*)kCGImagePropertyExifUserComment]) {
                return [[exifInfo objectForKey:(NSString*)kCGImagePropertyExifUserComment] isEqualToString:urlStr];
            }
            
        }
    }
    
    return NO;
}

- (void)fire {
    @autoreleasepool {
        
        if (!_imageURL) {
            NSLog(@"Did not setup imageURL!");
            return;
        }
        [self.loadingHUD showAnimated:YES];
        __weak __typeof(self)weakSelf = self;
        NSString *fileName = [[_imageURL lastPathComponent] stringByDeletingPathExtension];
        NSString *extType = [_imageURL pathExtension];
        BOOL isExist = [self imageCacheFileExistAndVaildWithFileName:fileName extType:extType isUserPortrait:YES sourceImageURL:_imageURL];
        
        if (isExist) {
            NSString *path = [FileManager getFileFullPathFromCacheWithRootFolder:FMRootFolderTypeOfCache fileName:fileName extType:extType subFolder:kUserPortraitCaches isImage:NO];
            UIImage *imageTab = nil;
            imageTab = [UIImage imageWithContentsOfFile:path];
            [self.imageView setImage:nil];
            [self.imageView setImage:imageTab];
            [self.loadingHUD hide];
            return;
        }
        
        // 1.创建NSURLSession
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:_imageURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
        
        // 2.创建Task
        self.operation = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            if(!error&&data) {
                ExifContainer *exifData = [ExifContainer new];
                if (strongSelf.imageURL) {
                    [exifData addUserComment:strongSelf.imageURL];
                }
                
                UIImage *image = [ImageHandler getImageFromCacheByRatioFromImage:[UIImage imageWithData:data]
                                                                    fileRootPath:kUserPortraitCaches
                                                                        fileName:fileName
                                                                            type:[FileManager getImageTypeNumWithString:extType]
                                                                        exifData:exifData
                                                                    needToUpdate:YES];
                
                [strongSelf.imageView setImage:image];
                strongSelf.imageView.contentMode = UIViewContentModeScaleAspectFit;
                [strongSelf.loadingHUD hide];
                
            }else {
                __strong __typeof(weakSelf)strongSelf = weakSelf;
                
                NSLog(@"%@",error);
                [strongSelf.loadingHUD hide];
            }
        }];
        
        // 3.启动任务
        [self.operation resume];
        
        
//        self.operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
//        [_operation setResponseSerializer:[[AFImageResponseSerializer alloc] init]];
//        [_operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//            __strong __typeof(weakSelf)strongSelf = weakSelf;
//            
//            ExifContainer *exifData = [ExifContainer new];
//            if (strongSelf.imageURL) {
//                [exifData addUserComment:strongSelf.imageURL];
//            }
//            
//            UIImage *image = [ImageHandler getImageFromCacheByRatioFromImage:responseObject
//                                                                fileRootPath:kUserPortraitCaches
//                                                                    fileName:fileName
//                                                                        type:[FileManager getImageTypeNumWithString:extType]
//                                                                    exifData:exifData
//                                                                needToUpdate:YES];
//            
//            [strongSelf.imageView setImage:image];
//            strongSelf.imageView.contentMode = UIViewContentModeScaleAspectFit;
//            [strongSelf.loadingHUD hide];
//            
//        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//            __strong __typeof(weakSelf)strongSelf = weakSelf;
//
//            NSLog(@"%@",error);
//            [strongSelf.loadingHUD hide];
//        }];
//        [_operation start];

    }
}

- (void)setImageURL:(NSString *)imageURL
{
    if ([imageURL isEqualToString:@""]||[imageURL rangeOfString:@"http"].location == NSNotFound) {
        NSLog(@"No Portrait URL Was Found!");
        return;
    }
    _imageURL = nil;
    _imageURL = imageURL;
    [self fire];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
