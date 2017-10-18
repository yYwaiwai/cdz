//
//  EngineerDetailVC.m
//  cdzer
//
//  Created by KEns0n on 3/12/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#import "EngineerDetailVC.h"
#import "EngineerInfoDetail.h"
#import "InsetsLabel.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface EngineerDetailVC () <UIScrollViewDelegate>

@property (nonatomic, strong) EngineerInfoDetail *infoDetail;

@property (nonatomic, strong) UIView *skillsListView;

@property (nonatomic, strong) UIView *brandsListView;

@property (nonatomic, strong) UIView *resumesListView;

@property (nonatomic, strong) NSDictionary *dataDetail;

@end

@implementation EngineerDetailVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:getLocalizationString(@"技师详情")];
    [self.contentView setBackgroundColor:[UIColor colorWithRed:0.953f green:0.953f blue:0.953f alpha:1.00f]];
    [self initializationUI];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    if (!_dataDetail) {
        [self getMaintenanceShopsTechnicianDetail];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)skillViewInitialization{
    if (_skillsListView)return;
    CGRect slvRect = CGRectZero;
    slvRect.origin.y = CGRectGetMaxY(_infoDetail.frame)+vAdjustByScreenRatio(vO2OSpaceSpace);
    slvRect.size = CGSizeMake(CGRectGetWidth(self.scrollView.frame), vAdjustByScreenRatio(40.0f));
    [self setSkillsListView:[[UIView alloc] initWithFrame:slvRect]];
    [_skillsListView setBackgroundColor:CDZColorOfClearColor];
    [self.scrollView addSubview:_skillsListView];
    
    CGRect titleLabelRect = _skillsListView.bounds;
    titleLabelRect.size.height = vAdjustByScreenRatio(20.0f);
    InsetsLabel *titleLabel = [[InsetsLabel alloc] initWithFrame:titleLabelRect andEdgeInsetsValue:UIEdgeInsetsMake(0.0f, vAdjustByScreenRatio(14.0f), 0.0f, 0.0f)];
    titleLabel.text = getLocalizationString(@"expertise_skills");
    titleLabel.textColor = [UIColor colorWithRed:0.353f green:0.345f blue:0.349f alpha:1.00f];
    titleLabel.font = systemFontBold(15.0f);
    [_skillsListView addSubview:titleLabel];
    
    
    CGRect listViewRect = CGRectZero;
    listViewRect.origin.y = CGRectGetMaxY(titleLabelRect)+vAdjustByScreenRatio(vO2OSpaceSpace);
    listViewRect.size = CGSizeMake(CGRectGetWidth(self.scrollView.frame), vAdjustByScreenRatio(40.0f));
    UIView *listView =[[UIView alloc] initWithFrame:listViewRect];
    [listView setBackgroundColor:CDZColorOfWhite];
    [listView setBorderWithColor:[UIColor colorWithRed:0.910f green:0.910f blue:0.910f alpha:1.00f] borderWidth:(0.5f)];
    [_skillsListView addSubview:listView];
    
    
    
    NSArray *array = _dataDetail[@"speciality_name"];
    UIFont *font = [UIFont systemFontOfSize:vAdjustByScreenRatio(14.0f)];
    CGFloat startX = vAdjustByScreenRatio(14.0f);
    CGFloat labelSapce = vAdjustByScreenRatio(10.0f);
    CGFloat extWidth = vAdjustByScreenRatio(16.0f);
    CGRect previousRect = CGRectZero;
    previousRect.origin.x = startX-labelSapce;
    NSInteger nextRow = 0;
    for (int i=0; i<[array count]; i++) {
        NSString *text = [array[i] objectForKey:@"speciality_name"];
        CGSize sizeString = [SupportingClass getStringSizeWithString:text font:font widthOfView:CGSizeMake(CGFLOAT_MAX, vAdjustByScreenRatio(24.0f))];
        sizeString.width += extWidth;
        
        if ((sizeString.width+CGRectGetMaxX(previousRect)+labelSapce) > CGRectGetWidth(_skillsListView.frame)) {
            previousRect.origin.x = vAdjustByScreenRatio(14.0f)-labelSapce;
            previousRect.size.width = 0.0f;
            nextRow++;
        }
        
        CGRect labelRect = CGRectZero;
        labelRect.size = CGSizeMake(sizeString.width, vAdjustByScreenRatio(24.0f));
        labelRect.origin.x = CGRectGetMaxX(previousRect)+labelSapce;
        labelRect.origin.y = (CGRectGetHeight(_skillsListView.frame)-CGRectGetHeight(labelRect))/2.0f+CGRectGetHeight(_skillsListView.frame)*nextRow;
        previousRect = labelRect;
        
        UILabel *label = [[UILabel alloc] initWithFrame:labelRect];
        [label setBackgroundColor:[UIColor colorWithRed:0.122f green:0.682f blue:0.929f alpha:1.00f]];
        [label setTextColor:CDZColorOfWhite];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setFont:font];
        [label setText:text];
        [listView addSubview:label];
    }
    listViewRect.size.height = CGRectGetHeight(slvRect)*(nextRow+1);
    listView.frame = listViewRect;
    slvRect.size.height = CGRectGetMaxY(listView.frame);
    _skillsListView.frame = slvRect;
}

- (void)brandViewInitialization{
    if (_brandsListView)return;
    CGRect blvRect = CGRectZero;
    blvRect.origin.y = CGRectGetMaxY(_skillsListView.frame)+vAdjustByScreenRatio(vO2OSpaceSpace);
    blvRect.size = CGSizeMake(CGRectGetWidth(self.scrollView.frame), vAdjustByScreenRatio(40.0f));
    [self setBrandsListView:[[UIView alloc] initWithFrame:blvRect]];
    [_brandsListView setBackgroundColor:CDZColorOfClearColor];
    [self.scrollView addSubview:_brandsListView];
    
    CGRect titleLabelRect = _brandsListView.bounds;
    titleLabelRect.size.height = vAdjustByScreenRatio(20.0f);
    InsetsLabel *titleLabel = [[InsetsLabel alloc] initWithFrame:titleLabelRect andEdgeInsetsValue:UIEdgeInsetsMake(0.0f, vAdjustByScreenRatio(14.0f), 0.0f, 0.0f)];
    titleLabel.text = getLocalizationString(@"main_repair_brand");
    titleLabel.textColor = [UIColor colorWithRed:0.353f green:0.345f blue:0.349f alpha:1.00f];
    titleLabel.font = systemFontBold(15.0f);
    [_brandsListView addSubview:titleLabel];
    
    
    CGRect listViewRect = CGRectZero;
    listViewRect.origin.y = CGRectGetMaxY(titleLabelRect)+vAdjustByScreenRatio(vO2OSpaceSpace);
    listViewRect.size = CGSizeMake(CGRectGetWidth(self.scrollView.frame), vAdjustByScreenRatio(40.0f));
    UIView *listView =[[UIView alloc] initWithFrame:listViewRect];
    [listView setBackgroundColor:CDZColorOfWhite];
    [listView setBorderWithColor:[UIColor colorWithRed:0.910f green:0.910f blue:0.910f alpha:1.00f] borderWidth:(0.5f)];
    [_brandsListView addSubview:listView];
    
    
    
    NSArray *array = _dataDetail[@"repair_brand_name"];
    NSInteger columnNum = IS_IPHONE_6P?5:4;
    NSInteger nextRow = 0;
    CGSize size = CGSizeMake(62.0f, 62.0f);
    CGFloat startX = (CGRectGetWidth(_brandsListView.frame)-size.width*columnNum)/(columnNum+1);
    
    for (int i=0; i<[array count]; i++) {
        NSString *text = [array[i] objectForKey:@"repair_brand_name"];
        nextRow = i/columnNum;
        NSInteger nextcolumn = i%columnNum;

        CGRect viewRect = CGRectZero;
        viewRect.size = size;
        viewRect.origin.x = startX+(CGRectGetWidth(viewRect)+startX)*nextcolumn;
        viewRect.origin.y = vAdjustByScreenRatio(8.0f)+nextRow*(CGRectGetHeight(viewRect)+vAdjustByScreenRatio(8.0f));
        
        UIView *view = [[UIView alloc] initWithFrame:viewRect];
        [view setBackgroundColor:CDZColorOfWhite];
        [view.layer setCornerRadius:8.0f];
        [view.layer setMasksToBounds:YES];
        [view setBorderWithColor:[UIColor colorWithRed:0.122f green:0.682f blue:0.929f alpha:1.00f] borderWidth:(1)];
        [listView addSubview:view];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(view.frame), 22.0f)];
        [label setText:text];
        [label setFont:[UIFont systemFontOfSize:14]];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setBackgroundColor:[UIColor colorWithRed:0.122f green:0.682f blue:0.929f alpha:1.00f]];
        [label setTextColor:CDZColorOfWhite];
        [view addSubview:label];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f,  CGRectGetMaxY(label.frame), CGRectGetHeight(viewRect)-CGRectGetHeight(label.frame), CGRectGetHeight(viewRect)-CGRectGetHeight(label.frame))];
        imageView.center = CGPointMake(label.center.x, imageView.center.y);
        NSString *brandImgURL = [array[i] objectForKey:@"repair_brand_image"];
        imageView.image = [ImageHandler getColorLogo];
        if ([brandImgURL isContainsString:@"http"]) {
            [imageView sd_setImageWithURL:[NSURL URLWithString:brandImgURL] placeholderImage:[ImageHandler getWhiteLogo]];
        }
        [view addSubview:imageView];

    }
    listViewRect.size.height = (size.height+vAdjustByScreenRatio(8.0f))*(nextRow+1)+vAdjustByScreenRatio(8.0f);
    listView.frame = listViewRect;
    blvRect.size.height = CGRectGetMaxY(listView.frame);
    _brandsListView.frame = blvRect;
}

- (void)resumesViewInitialization{
    if (_resumesListView)return;
    CGRect blvRect = CGRectZero;
    blvRect.origin.y = CGRectGetMaxY(_brandsListView.frame)+vAdjustByScreenRatio(vO2OSpaceSpace);
    blvRect.size = CGSizeMake(CGRectGetWidth(self.brandsListView.frame), vAdjustByScreenRatio(40.0f));
    [self setResumesListView:[[UIView alloc] initWithFrame:blvRect]];
    [_resumesListView setBackgroundColor:CDZColorOfClearColor];
    [self.scrollView addSubview:_resumesListView];
    
    CGRect titleLabelRect = _resumesListView.bounds;
    titleLabelRect.size.height = vAdjustByScreenRatio(20.0f);
    InsetsLabel *titleLabel = [[InsetsLabel alloc] initWithFrame:titleLabelRect andEdgeInsetsValue:UIEdgeInsetsMake(0.0f, vAdjustByScreenRatio(14.0f), 0.0f, 0.0f)];
    titleLabel.text = getLocalizationString(@"work_experience");
    titleLabel.textColor = [UIColor colorWithRed:0.353f green:0.345f blue:0.349f alpha:1.00f];
    titleLabel.font = systemFontBold(15.0f);
    [_resumesListView addSubview:titleLabel];
    
    
    
    NSString *text = _dataDetail[@"resumes"];
    UIFont *font = systemFont(18.f);
    CGSize size = [SupportingClass getStringSizeWithString:text font:font widthOfView:CGSizeMake(CGRectGetWidth(_resumesListView.frame)-vAdjustByScreenRatio(14.0f)*2.0f, CGFLOAT_MAX)];
    size.height += vAdjustByScreenRatio(12.0f);
    CGRect contentLabelRect = CGRectZero;
    contentLabelRect.origin.y = CGRectGetMaxY(titleLabelRect)+vAdjustByScreenRatio(vO2OSpaceSpace);
    contentLabelRect.size = CGSizeMake(CGRectGetWidth(self.scrollView.frame), size.height);
    InsetsLabel *contentLabel = [[InsetsLabel alloc] initWithFrame:contentLabelRect andEdgeInsetsValue:UIEdgeInsetsMake(0.0f, vAdjustByScreenRatio(14.0f), 0.0f, vAdjustByScreenRatio(14.0f))];
    [contentLabel setBackgroundColor:CDZColorOfWhite];
    [contentLabel setText:_dataDetail[@"resumes"]];
    [contentLabel setNumberOfLines:0];
    [contentLabel setBorderWithColor:[UIColor colorWithRed:0.910f green:0.910f blue:0.910f alpha:1.00f] borderWidth:(0.5f)];
    [_resumesListView addSubview:contentLabel];

    
    blvRect.size.height = CGRectGetMaxY(contentLabel.frame);
    _resumesListView.frame = blvRect;
}

- (void)initializationUI {
    @autoreleasepool {
        self.scrollView.hidden = NO;
        self.scrollView.backgroundColor = sCommonBGColor;
        self.scrollView.delegate = self;
        self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.frame), CGRectGetHeight(self.scrollView.frame)*2.0f);
        
        
        UIImage *rmpImage = [ImageHandler getImageFromCacheByScreenRatioWithFileRootPath:kSysImageCaches
                                                                                fileName:@"repair_mp_image"
                                                                                    type:FMImageTypeOfPNG
                                                                         scaleWithPhone4:NO
                                                                             offsetRatioForP4:1.0f
                                                                            needToUpdate:YES];
        UIImageView *rmpimageView = [[UIImageView alloc]initWithImage:rmpImage];
        [rmpimageView setFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.contentView.frame), rmpImage.size.height)];
        [self.scrollView addSubview:rmpimageView];
        
        
        [self setInfoDetail:[[EngineerInfoDetail alloc] initWithFrame:CGRectMake(0.0f,
                                                                                 CGRectGetMaxY(rmpimageView.frame),
                                                                                 CGRectGetWidth(self.scrollView.frame),
                                                                                 118.0f)]];
        [_infoDetail initializationUI];
        
        [self.scrollView addSubview:_infoDetail];
        
//        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(30, 30, 65, 65)];
//        [view setBackgroundColor:CDZColorOfWhite];
//        [view.layer setCornerRadius:8.0f];
//        [view.layer setMasksToBounds:YES];
//        [view setBorderWithColor:[UIColor colorWithRed:0.122f green:0.682f blue:0.929f alpha:1.00f] borderWidth:(1)];
//        [self.scrollView addSubview:view];
//        
//        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(view.frame), CGRectGetHeight(view.frame)*0.35)];
//        [label setText:@"兰博基尼"];
//        [label setFont:[UIFont systemFontOfSize:14]];
//        [label setTextAlignment:NSTextAlignmentCenter];
//        [label setBackgroundColor:[UIColor colorWithRed:0.122f green:0.682f blue:0.929f alpha:1.00f]];
//        [label setTextColor:CDZColorOfWhite];
//        [view addSubview:label];
//        
//        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,  CGRectGetMaxY(label.frame), CGRectGetWidth(view.frame), CGRectGetHeight(view.frame)*0.65)];
//        [imageView setBackgroundColor:CDZColorOfWhite];
//        [view addSubview:imageView];
        
    }
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat baseLine = scrollView.contentSize.height-CGRectGetHeight(scrollView.frame);
    [scrollView setBounces:(scrollView.contentOffset.y >= baseLine*0.45f)];
}

- (void)updateUIData {
    if (!_dataDetail) return;
    [_infoDetail updateUIDataWithData:_dataDetail];
    
    [self skillViewInitialization];
    
    [self brandViewInitialization];
    
    [self resumesViewInitialization];
}

- (void)getMaintenanceShopsTechnicianDetail {
    [ProgressHUDHandler showHUD];
    
//    [[APIsConnection shareConnection] maintenanceShopsAPIsGetMaintenanceShopsTechnicianDetailWithTechnicianID:_technicianID success:^(NSURLSessionDataTask *operation, id responseObject) {
//        [self requestResultHandle:operation responseObject:responseObject withError:nil];
//    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
//        [self requestResultHandle:operation responseObject:nil withError:error];
//    }];
}


- (void)requestResultHandle:(NSURLSessionDataTask *)operation responseObject:(id)responseObject withError:(NSError *)error {
    [ProgressHUDHandler dismissHUD];
    
    if (error&&!responseObject) {
        NSLog(@"%@",error);
        [ProgressHUDHandler dismissHUD];
        if (error.code==-1009) {
            [SupportingClass showAlertViewWithTitle:@"error" message:@"网络连接失败，请检查网络设置！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            }];
            return;
        }
        
        
        if (error.code==-1001) {
            [SupportingClass showAlertViewWithTitle:@"error" message:@"网络连接逾时，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            }];
            return;
        }
        
        [SupportingClass showAlertViewWithTitle:@"error" message:@"网络错误，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
        }];
    }else if (!error&&responseObject) {
        
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        
        switch (errorCode) {
            case 0:{
                _dataDetail = responseObject[CDZKeyOfResultKey];
                [self updateUIData];
            }
                break;
            case 1:
            case 2:
                [SupportingClass showAlertViewWithTitle:@"error" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                    
                }];

                break;
                
            default:
                break;
        }
        
    }
    
}

/*
 #pragma mark- Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
