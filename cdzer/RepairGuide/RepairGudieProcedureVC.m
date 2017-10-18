//
//  RepairGudieProcedureVC.m
//  cdzer
//
//  Created by KEns0n on 16/4/1.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "RepairGudieProcedureVC.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVPlayerViewController.h>

@interface RepairGudieProcedureCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *stepLabel;

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;

@property (nonatomic, weak) IBOutlet UIImageView *stepImageView;


@end

@implementation RepairGudieProcedureCell

@end

@interface RepairGudieProcedureVC ()

@property (nonatomic, weak) IBOutlet UIControl *videoView;
@property (nonatomic, weak) IBOutlet UIImageView *playIV;
@property (nonatomic, weak) IBOutlet UIImageView *previewIV;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *loadingView;

@property (nonatomic, weak) IBOutlet UILabel *alertMarkView;

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, weak) IBOutlet UILabel *detailLabel;

@property (nonatomic, weak) IBOutlet UIButton *partButton;
@property (nonatomic, strong) NSString *partListString;

@property (nonatomic, weak) IBOutlet UIButton *toolButton;
@property (nonatomic, strong) NSString *toolListString;

@property (nonatomic, weak) IBOutlet UIButton *levelButton;
@property (nonatomic, strong) NSString *levelListString;

@property (nonatomic, assign) NSUInteger currentOptionIdx;

@property (nonatomic, strong) NSArray *dataList;
@property (nonatomic, strong) NSMutableArray *imageList;
@property (nonatomic, strong) NSMutableArray *downloaderList;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *videoViewHeight;

@end

@implementation RepairGudieProcedureVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self componentSetting];
    [self initializationUI];
    [self setReactiveRules];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)setReactiveRules {
    @autoreleasepool {
        
    }
    
}

- (void)componentSetting {
    @autoreleasepool {
        @weakify(self);
        
        UINib *nib = [UINib nibWithNibName:@"RepairGudieProcedureCell" bundle:nil];
        [self.tableView registerNib:nib forCellReuseIdentifier:@"RepairGudieProcedureCell"];
        
        self.dataList = _procedureDetail[@"slist"];
        
        [self.alertMarkView setBorderWithColor:self.alertMarkView.textColor borderWidth:1.0f];
        [self.alertMarkView setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:CGRectGetHeight(_alertMarkView.frame)/2.0f];
        self.partListString = @"此指导教程无任何配件要求";
        self.toolListString = @"此指导教程无任何工具要求";
        self.levelListString = _procedureDetail[@"difficultyLevel"];
        NSArray *tList = _procedureDetail[@"tlist"];
        NSArray *pList = _procedureDetail[@"plist"];
        if (tList.count>0) {
            self.toolListString = [[tList valueForKey:@"tool"] componentsJoinedByString:@"、"];
        }
        if (pList.count>0) {
            self.partListString = [[pList valueForKey:@"partName"] componentsJoinedByString:@"、"];
        }
        self.detailLabel.text = self.partListString;
        self.currentOptionIdx = 1;
        self.partButton.selected = YES;
        [self.partButton setImage:[ImageHandler getImageFromCacheWithByFixdeRatioFileRootPath:nil fileName:@"guide_part2" type:FMImageTypeOfPNG needToUpdate:YES] forState:UIControlStateNormal];
        [self.partButton setImage:[ImageHandler getImageFromCacheWithByFixdeRatioFileRootPath:nil fileName:@"guide_part1" type:FMImageTypeOfPNG needToUpdate:YES] forState:UIControlStateSelected];
        
        [self.toolButton setImage:[ImageHandler getImageFromCacheWithByFixdeRatioFileRootPath:nil fileName:@"guide_tool2" type:FMImageTypeOfPNG needToUpdate:YES] forState:UIControlStateNormal];
        [self.toolButton setImage:[ImageHandler getImageFromCacheWithByFixdeRatioFileRootPath:nil fileName:@"guide_tool1" type:FMImageTypeOfPNG needToUpdate:YES] forState:UIControlStateSelected];
        
        [self.levelButton setImage:[ImageHandler getImageFromCacheWithByFixdeRatioFileRootPath:nil fileName:@"guide_level2" type:FMImageTypeOfPNG needToUpdate:YES] forState:UIControlStateNormal];
        [self.levelButton setImage:[ImageHandler getImageFromCacheWithByFixdeRatioFileRootPath:nil fileName:@"guide_level1" type:FMImageTypeOfPNG needToUpdate:YES] forState:UIControlStateSelected];
        
        NSString *previewImageURL = _procedureDetail[@"image"];
        if ([previewImageURL isContainsString:@"http"]) {
            self.videoViewHeight.constant = 150;
            self.playIV.image = [ImageHandler getImageFromCacheWithByFixdeRatioFileRootPath:nil fileName:@"v_play" type:FMImageTypeOfPNG needToUpdate:YES];
            self.loadingView.hidden = NO;
            [self.previewIV sd_setImageWithURL:[NSURL URLWithString:previewImageURL] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                @strongify(self);
                self.loadingView.hidden = YES;
                self.playIV.hidden = NO;
                self.previewIV.image = image;
                
            }];
        }
        self.downloaderList = [NSMutableArray array];
        self.imageList = [NSMutableArray array];
        [self.dataList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            @strongify(self);
            [self.imageList addObject:[NSNull null]];
            [self.downloaderList addObject:[NSNull null]];
        }];
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 100;
        [self.tableView reloadData];
        [self.view updateConstraintsIfNeeded];
        
        
    }
}

- (IBAction)playMovie:(id)sender {
    NSString *videoURLStr =_procedureDetail[@"video"];
    if ([videoURLStr isContainsString:@"http"]) {
        AVPlayerViewController *vc = [AVPlayerViewController new];
        vc.player = [AVPlayer playerWithURL:[NSURL URLWithString:videoURLStr]];
        [self.navigationController presentViewController:vc animated:YES completion:nil];
        NSError *setCategoryErr = nil;
        NSError *activationErr  = nil;
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&setCategoryErr];
        [[AVAudioSession sharedInstance] setActive:YES error:&activationErr];
    }
}

- (IBAction)centerDetailOption:(UIControl *)sender {
    if (sender.tag==_currentOptionIdx) return;
    self.currentOptionIdx = sender.tag;
    self.partButton.selected = NO;
    self.toolButton.selected = NO;
    self.levelButton.selected = NO;
    switch (sender.tag) {
        case 1:
            self.partButton.selected = YES;
            self.detailLabel.text = self.partListString;
            break;
            
        case 2:
            self.toolButton.selected = YES;
            self.detailLabel.text = self.toolListString;
            break;
            
        case 3:
            self.levelButton.selected = YES;
            self.detailLabel.text = self.levelListString;
            break;
            
        default:
            break;
    }
}

- (void)initializationUI {
    @autoreleasepool {
 
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return _dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *ident = @"RepairGudieProcedureCell";
    RepairGudieProcedureCell *cell = [tableView dequeueReusableCellWithIdentifier:ident forIndexPath:indexPath];
    [cell.stepLabel setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:CGRectGetWidth(cell.stepLabel.frame)/2.0f];
    cell.titleLabel.text = nil;
    cell.titleLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfMedium, 15, NO);
    cell.titleLabel.attributedText = nil;
    cell.stepImageView.image = nil;
    NSDictionary *detail = _dataList[indexPath.row];
    NSString *title = detail[@"des"];
    cell.titleLabel.text = title;
    NSString *step = detail[@"step"];
    cell.stepLabel.text = step;
    
    NSString *imageURL = detail[@"imgurl"];
    UIImage *preLoadedImage = _imageList[indexPath.row];
    if ([imageURL isContainsString:@"http"]) {
        if ([preLoadedImage isKindOfClass:NSNull.class]) {
            [self downloadImage:imageURL withIndex:indexPath];
        }else {
            cell.stepImageView.image = preLoadedImage;
        }
    }
    [cell updateConstraintsIfNeeded];
    
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
    id downloader = [SDWebImageDownloader.sharedDownloader downloadImageWithURL:[NSURL URLWithString:urlString] options:SDWebImageDelayPlaceholder|SDWebImageAvoidAutoSetImage progress:nil completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
        @strongify(self);
        if (!error&&image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                // code here
                @strongify(self);
                UIImage *resizedImage = image;
                if (image.size.width>SCREEN_WIDTH) {
                    CGFloat height = roundf(image.size.height*SCREEN_WIDTH/image.size.width);
                    resizedImage = [ImageHandler imageWithImage:image convertToSize:CGSizeMake(SCREEN_WIDTH, height)];
                }
                [self.imageList replaceObjectAtIndex:indexPath.row withObject:resizedImage];
                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
