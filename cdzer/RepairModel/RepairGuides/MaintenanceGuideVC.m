//
//  MaintenanceGuideVC.m
//  cdzer
//
//  Created by 车队长 on 16/10/28.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "MaintenanceGuideVC.h"
#import "MaintenanceGuideButtonView.h"
#import "MaintenanceGuideCell.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVPlayerViewController.h>
#import <SDWebImage/UIImageView+WebCache.h>




@interface MaintenanceGuideVC ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIColor *headView;

@property (weak, nonatomic) IBOutlet UIButton *playButton;

@property (weak, nonatomic) IBOutlet UIView *noVideoView;

@property (weak, nonatomic) IBOutlet UIImageView *previewIV;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingView;


@property (weak, nonatomic) IBOutlet UIView *zhuLabelView;
@property (weak, nonatomic) IBOutlet UILabel *zhuLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *zhuLabelViewTopConstraint;

@property (weak, nonatomic) IBOutlet UIView *buttonBgView;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeightConstraint;

@property (weak, nonatomic) IBOutlet UIControl *partsControl;//配件

@property (weak, nonatomic) IBOutlet UIControl *toolControl;//工具

@property (weak, nonatomic) IBOutlet UIControl *difficultyLevelControl;//难易程度

@property (strong, nonatomic) IBOutlet MaintenanceGuideButtonView *maintenanceGuideButtonView;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (nonatomic, strong) NSArray *dataList;
@property (nonatomic, strong) NSMutableArray *imageList;
@property (nonatomic, strong) NSMutableArray *downloaderList;

@property (nonatomic, strong) NSString *partListString;
@property (nonatomic, strong) NSString *toolListString;
@property (nonatomic, strong) NSAttributedString *partListAttrString;
@property (nonatomic, strong) NSAttributedString *toolListAttrString;
@property (nonatomic, strong) NSString *levelListString;

@end

@implementation MaintenanceGuideVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    [self.zhuLabelView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5f withColor:nil withBroderOffset:nil];
    [self.buttonBgView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5f withColor:nil withBroderOffset:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [[UINib nibWithNibName:@"MaintenanceGuideButtonView" bundle:nil] instantiateWithOwner:self options:nil];
    
    self.scrollView.bounces=NO;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 100.0f;
    self.tableView.bounces=NO;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor=self.view.backgroundColor;
    UINib*nib = [UINib nibWithNibName:@"MaintenanceGuideCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"MaintenanceGuideCell"];
    
    [self componentSetting];
    [self setReactiveRules];
}


- (void)sss {
    //   NSParagraphStyleAttributeName 段落的风格（设置首行，行间距，对齐方式什么的）看自己需要什么属性，写什么
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;//结尾部分的内容以……方式省略 ( "...wxyz" ,"abcd..." ,"ab...yz")
    paragraphStyle.alignment = NSTextAlignmentCenter;//（两端对齐的）文本对齐方式：（左，中，右，两端对齐，自然）
    paragraphStyle.baseWritingDirection = NSWritingDirectionLeftToRight;//从左到右的书写方向（一共➡️三种）
    paragraphStyle.minimumLineHeight = 10;//最低行高
    paragraphStyle.maximumLineHeight = 20;//最大行高
    paragraphStyle.hyphenationFactor = 1;//连字属性 在iOS，唯一支持的值分别为0和1
    
    paragraphStyle.paragraphSpacing = 7;//段与段之间的间距
    //        paragraphStyle.lineHeightMultiple = 15;/* Natural line height is multiplied by this factor (if positive) before being constrained by minimum and maximum line height. */
    //        paragraphStyle.firstLineHeadIndent = 20.0f;//首行缩进
    //        paragraphStyle.headIndent = 20;//整体缩进(首行除外)
    //        paragraphStyle.tailIndent = 20;//
    //        paragraphStyle.paragraphSpacingBefore = 22.0f;//段首行空白空间/* Distance between the bottom of the previous paragraph (or the end of its paragraphSpacing, if any) and the top of this paragraph. */
    
    NSArray *pList = _procedureDetail[@"plist"];
    NSString *partString =[[pList valueForKey:@"partName"] componentsJoinedByString:@"\n"];
    self.partListAttrString= [[NSAttributedString new] initWithString:partString attributes:@{NSParagraphStyleAttributeName:paragraphStyle}];
    
    NSArray *tList = _procedureDetail[@"tlist"];
    NSString *toolString = [[tList valueForKey:@"tool"] componentsJoinedByString:@"\n"];
    self.toolListAttrString = [[NSAttributedString new] initWithString:toolString attributes:@{NSParagraphStyleAttributeName:paragraphStyle}];
}


- (void)componentSetting {
    @autoreleasepool {
        @weakify(self);
        self.dataList = _procedureDetail[@"slist"];
        self.levelListString = _procedureDetail[@"difficultyLevel"];
        NSArray *tList = _procedureDetail[@"tlist"];
        NSArray *pList = _procedureDetail[@"plist"];
        if (tList.count>0) {
            self.toolListString = [[tList valueForKey:@"tool"] componentsJoinedByString:@"\n"];
            [self sss];
        }
        if (pList.count>0) {
            self.partListString = [[pList valueForKey:@"partName"] componentsJoinedByString:@"\n"];
            [self sss];
        }
        self.zhuLabelView.hidden = YES;
        self.zhuLabel.text = @"";
        self.zhuLabelViewTopConstraint.constant = -CGRectGetHeight(self.zhuLabelView.frame);
        if (_procedureDetail[@"notice"]&&![_procedureDetail[@"notice"] isEqualToString:@""]) {
            self.zhuLabelViewTopConstraint.constant = 0;
            self.zhuLabelView.hidden = NO;
            self.zhuLabel.text = [_procedureDetail[@"notice"] stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        }
        NSString *previewImageURL = _procedureDetail[@"image"];
        self.loadingView.hidden = YES;
        self.playButton.hidden = YES;
        self.noVideoView.hidden = NO;
        self.previewIV.highlighted=YES;
        if ([previewImageURL isContainsString:@"http"]) {
            self.noVideoView.hidden = YES;
            self.loadingView.hidden = NO;
            self.previewIV.highlighted=NO;
            [self.previewIV sd_setImageWithURL:[NSURL URLWithString:previewImageURL] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                @strongify(self);
                self.loadingView.hidden = YES;
                self.playButton.hidden = NO;
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

        
        
    }
}

- (void)setReactiveRules {
    @weakify(self);
    [RACObserve(self, tableView.contentSize) subscribeNext:^(id size) {
        @strongify(self);
        CGSize contentSize = [size CGSizeValue];
        self.tableViewHeightConstraint.constant = contentSize.height;
    }];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ident = @"MaintenanceGuideCell";
    MaintenanceGuideCell *cell = [tableView dequeueReusableCellWithIdentifier:ident forIndexPath:indexPath];
    
    [cell.stepLabel setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:CGRectGetWidth(cell.stepLabel.frame)/2.0f];
    cell.titleLabel.text = nil;
    cell.titleLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfMedium, 15, NO);
    cell.titleLabel.attributedText = nil;
    cell.stepImageView.image = nil;
    
    cell.stepLabel.text=[NSString stringWithFormat:@"%ld",(long)indexPath.row];
    cell.titleLabel.text=@"找到轮胎的气嘴";
    
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

- (void)delayRelaodDownloadImage:(NSArray *)objsList {
    [self downloadImage:objsList[0] withIndex:objsList[1]];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataList.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (IBAction)controlClick:(id)sender {
    [self.maintenanceGuideButtonView setNeedsUpdateConstraints];
    [self.maintenanceGuideButtonView setNeedsDisplay];
    [self.maintenanceGuideButtonView setNeedsLayout];
    [self.maintenanceGuideButtonView showView];
    
    if (self.partsControl==sender) {
        self.maintenanceGuideButtonView.titleImageView.image=[UIImage imageNamed:@"weixiuzhinan-peijianchahua"];
        if (self.partListAttrString.length==0||self.partListAttrString==nil) {
            self.maintenanceGuideButtonView.titleLabel.text=@"此指导教程无任何配件要求";
        }else{
        self.maintenanceGuideButtonView.titleLabel.attributedText=self.partListAttrString;
        }
    }
    if (self.toolControl==sender) {
        self.maintenanceGuideButtonView.titleImageView.image=[UIImage imageNamed:@"weixiuzhinan-gongjuchahua"];
        if (self.toolListAttrString.length==0||self.toolListAttrString==nil) {
            self.maintenanceGuideButtonView.titleLabel.text=@"此指导教程无任何工具要求";
        }else{
            self.maintenanceGuideButtonView.titleLabel.attributedText=self.toolListAttrString;}
    }
    if (self.difficultyLevelControl==sender) {
        if ([self.levelListString isEqualToString:@"简单"]||[self.levelListString isEqualToString:@"一般"]) {
            self.maintenanceGuideButtonView.titleImageView.image=[UIImage imageNamed:@"weixiuzhinan-nanyichengdu-jiandan"];
            self.maintenanceGuideButtonView.contentLabel.text=@"赶快自己动手试试吧O(∩_∩)O";
        }
        if ([self.levelListString isEqualToString:@"中等"]) {
            self.maintenanceGuideButtonView.titleImageView.image=[UIImage imageNamed:@"weixiuzhinan-nanyichengdu-yiban"];
            self.maintenanceGuideButtonView.contentLabel.text=@"动动脑想想再操作(∩_∩)";
        }
        if ([self.levelListString isEqualToString:@"难"]) {
            self.maintenanceGuideButtonView.titleImageView.image=[UIImage imageNamed:@"weixiuzhinan-nanyichengdu-kunnan"];
            self.maintenanceGuideButtonView.contentLabel.text=@"去找找专业的维修店( ^_^ )";
        }
        
        self.maintenanceGuideButtonView.titleLabel.text=self.levelListString;
    }
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)playVideo {
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
