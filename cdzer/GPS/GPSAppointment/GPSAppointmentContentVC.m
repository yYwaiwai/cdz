//
//  GPSAppointmentContentVC.m
//  cdzer
//
//  Created by KEns0n on 10/27/15.
//  Copyright © 2015 CDZER. All rights reserved.
//  预约GPS设备VC


#define kTitle @"title"
#define kPrice @"price"
#define kDescription @"description"

#import "GPSAppointmentContentVC.h"
#import "InsetsLabel.h"
#import "UserInfosDTO.h"
#import "UserAutosInfoDTO.h"

@implementation GPSAppointmentNavVC

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self componentSetting];
    [self initializationUI];
    [self setReactiveRules];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)componentSetting {
    
}

- (void)initializationUI {
    
}

- (void)setReactiveRules {
    
}

- (void)retryAppointmentRequest {
    if ([self.visibleViewController isKindOfClass:GPSAppointmentContentVC.class]&&[(GPSAppointmentContentVC *)self.visibleViewController currentStep]==3) {
        [(GPSAppointmentContentVC *)self.visibleViewController retryAppointmentRequest];
    }
}

@end





@interface GPSACCell : UITableViewCell

@property (nonatomic, strong) UIImageView *checkMarkIV;

@property (nonatomic, strong) UIImageView *uncheckCheckMarkIV;

@property (nonatomic, strong) InsetsLabel *descriptionLabel;

@end

@implementation GPSACCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        if (!_checkMarkIV) {
            UIImage *checkMarkImage = [ImageHandler getImageFromCacheWithByFixdeRatioFileRootPath:kSysImageCaches fileName:@"checkmark" type:FMImageTypeOfPNG needToUpdate:YES];
            self.checkMarkIV = [[UIImageView alloc] initWithImage:checkMarkImage];
        }
        if (!_uncheckCheckMarkIV) {
            UIImage *uncheckCheckMarkImage = [ImageHandler getImageFromCacheWithByFixdeRatioFileRootPath:kSysImageCaches fileName:@"checkmark_unchecked" type:FMImageTypeOfPNG needToUpdate:YES];
            self.uncheckCheckMarkIV = [[UIImageView alloc] initWithImage:uncheckCheckMarkImage];
        }
        
        [self initializationUI];
    }
    return self;
}


- (void)initializationUI {
    
    self.textLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfBold, 19.0f, NO);
    self.textLabel.textColor = CDZColorOfDeepGray;
    self.detailTextLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 15.0f, NO);
    self.detailTextLabel.textColor = CDZColorOfDarkBlue;
    self.detailTextLabel.numberOfLines = 0;
    
    self.descriptionLabel = [[InsetsLabel alloc] initWithFrame:self.bounds];
    _descriptionLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfBold, 16.0f, NO);
    _descriptionLabel.textColor = CDZColorOfRed;
    _descriptionLabel.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:_descriptionLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect frame = self.detailTextLabel.frame;
    frame.size.width = CGRectGetWidth(self.frame)*0.6f;
    self.detailTextLabel.frame = frame;
    
    UIEdgeInsets insetsValue = DefaultEdgeInsets;
    if (self.accessoryView) {
        insetsValue.right = CGRectGetWidth(self.frame)-CGRectGetMinX(self.accessoryView.frame)+10.0f;
    }
    self.descriptionLabel.frame = self.bounds;
    self.descriptionLabel.edgeInsets = insetsValue;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    self.accessoryView = nil;
    self.accessoryView = selected?_checkMarkIV:_uncheckCheckMarkIV;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
    self.accessoryView = nil;
    self.accessoryView = selected?_checkMarkIV:_uncheckCheckMarkIV;
}


@end

@interface GPSAppointmentContentVC ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *configList;

@property (nonatomic, strong) UIView *bottomView;

@property (nonatomic, strong) UIButton *nextStepBtn;

@end

@implementation GPSAppointmentContentVC

- (instancetype)initWithStepID:(NSUInteger)stepID {
    self = [self init];
    if (stepID>6) stepID = 0;
    if (self) {
        _currentStep = stepID;
    }
    return self;
}

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self componentSetting];
    [self initializationUI];
    [self setReactiveRules];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)componentSetting {
    if (_currentStep>=1&&_currentStep<=3) {
        self.configList = nil;
        if (_currentStep==1) {
            self.configList = @[@{kTitle:@"GPS普通版", kPrice:@"0元", kDescription:@"支持任何车型"},
                                @{kTitle:@"GPS+ODB普通版", kPrice:@"300元", kDescription:@"支持车型故障检测、支持原车防盗、耗油统计分析"},
//                                @{kTitle:@"GPS+ODB专业版", kPrice:@"500元", kDescription:@"目前支持专业版的车型"},
                                ];
        }
        
        if (_currentStep==2) {
            self.configList = @[@{kTitle:@"SIM卡流量卡", kDescription:@"100元/年\n设备物流费用：10元（湖南省内），20元（湖南省外）"}];
        }
        
        if (_currentStep==3) {
            self.configList = @[@{kTitle:@"终端租赁保证金", kPrice:@"500元", kDescription:@"无人为损坏，\n支持随时退机退款"},
                                @{kTitle:@"保险预约保证金", kPrice:@"500元", kDescription:@"团购平台保险免费送GPS设备，实惠、惊喜连连"},];
        }
    }
}

- (void)initializationFristStepUI {
    @autoreleasepool {
        InsetsLabel *titleLabel = [[InsetsLabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.contentView.frame), 70.0f)];
        titleLabel.text = @"GPS免费领取";
        titleLabel.textColor = [UIColor colorWithRed:0.698f green:0.271f blue:0.278f alpha:1.00f];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfBoldItalic, 28.0f, YES);
        [self.contentView addSubview:titleLabel];
        
        
        NSMutableAttributedString *contentsString = [NSMutableAttributedString new];
        [contentsString appendAttributedString:[[NSAttributedString alloc] initWithString:@"活动规则："
                                                                               attributes:@{NSFontAttributeName:vGetHelveticaNeueFont(HelveticaNeueFontTypeOfMedium, 18, YES)}]];
        [contentsString appendAttributedString:[[NSAttributedString alloc] initWithString:@"所有会员仅限领取一次\n每个月10号准时发货，记得查收（邮费自理）\n如需了解车队长GPS免费领取活动请点击活动详情"
                                                                               attributes:@{NSFontAttributeName:vGetHelveticaNeueFont(HelveticaNeueFontTypeOfMedium, 15, YES)}]];
        
        InsetsLabel *contentsLabel = [[InsetsLabel alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(titleLabel.frame), CGRectGetWidth(self.contentView.frame), 100.0f)
                                                     andEdgeInsetsValue:UIEdgeInsetsMake(0.0f, 20.0f, 0.0f, 0.0f)];
        contentsLabel.attributedText = contentsString;
        contentsLabel.numberOfLines = 0;
        contentsLabel.textColor = [UIColor colorWithRed:0.698f green:0.271f blue:0.278f alpha:1.00f];
        [self.contentView addSubview:contentsLabel];
        
        
        NSString *btnTitle = @"活动详情";
        NSDictionary *attrDict = @{NSFontAttributeName:vGetHelveticaNeueFont(HelveticaNeueFontTypeOfBold, 20.0f, NO),
                                   NSForegroundColorAttributeName:CDZColorOfWhite};
        NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:btnTitle attributes:attrDict];
        [title addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0,[btnTitle length])];
        
        
        UIButton *moreDetailBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        moreDetailBtn.frame = CGRectMake(20.0f, CGRectGetMaxY(contentsLabel.frame), CGRectGetWidth(self.contentView.frame)*0.25, 36.0f);
        
        [moreDetailBtn setAttributedTitle:title forState:UIControlStateNormal];
        [moreDetailBtn addTarget:self action:@selector(showEventDetail) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:moreDetailBtn];
        
        NSArray *configList = @[@{@"title":@"GPS选择",@"imageName":@"gps_type"},
                                @{@"title":@"流量卡",@"imageName":@"data_card"},
                                @{@"title":@"保证金",@"imageName":@"recognizance"}];
        
        @weakify(self);
        [configList enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull detail, NSUInteger idx, BOOL * _Nonnull stop) {
            @strongify(self);
            NSString *imageTitle = detail[@"title"];
            UIFont *theFont = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 12.0f, NO);
            CGSize fontSize = [SupportingClass getStringSizeWithString:imageTitle font:theFont widthOfView:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
            fontSize.height +=10.0f;
            
            
            UIImage *image = [ImageHandler getImageFromCacheByScreenRatioWithFileRootPath:kSysImageCaches fileName:detail[@"imageName"] type:FMImageTypeOfPNG scaleWithPhone4:NO
                                                                              offsetRatioForP4:1.0f needToUpdate:YES];
            CGRect frame = CGRectZero;
            frame.size = image.size;
            frame.size.height += fontSize.height;
            frame.origin.y = CGRectGetMaxY(moreDetailBtn.frame);
            
            UIButton *imageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            imageBtn.tag = 100+idx;
            imageBtn.frame = frame;
            imageBtn.userInteractionEnabled = NO;
            imageBtn.titleLabel.font = theFont;
            [imageBtn setImage:image forState:UIControlStateNormal];
            [imageBtn setTitle:imageTitle forState:UIControlStateNormal];
            [imageBtn setTitleColor:CDZColorOfDarkBlue forState:UIControlStateNormal];
            imageBtn.imageEdgeInsets = UIEdgeInsetsMake(0.0f, 0.0f, fontSize.height, 0.0f);
            imageBtn.titleEdgeInsets = UIEdgeInsetsMake(image.size.height, -image.size.width, 0.0f, 0.0f);
            [self.contentView addSubview:imageBtn];
            
            CGPoint center = CGPointMake(CGRectGetWidth(self.contentView.frame)*0.5f, imageBtn.center.y);
            if (idx==0) center.x = CGRectGetWidth(self.contentView.frame)*0.2f;
            if (idx==2) center.x = CGRectGetWidth(self.contentView.frame)*0.8f;
            imageBtn.center = center;
            
            
            UIImageView *handStepIV = nil;
            if (idx==0||idx==2) {
                CGPoint hsCenter = CGPointMake(CGRectGetWidth(self.contentView.frame)*0.35f, center.y-fontSize.height/2.0f);
                if (idx==2) hsCenter.x = CGRectGetWidth(self.contentView.frame)*0.65f;
                
                UIImage *hsImage = [ImageHandler getImageFromCacheByScreenRatioWithFileRootPath:kSysImageCaches fileName:@"hand_step" type:FMImageTypeOfPNG scaleWithPhone4:NO
                                                                                    offsetRatioForP4:1.0f needToUpdate:YES];
                handStepIV = [[UIImageView alloc] initWithImage:hsImage];
                handStepIV.center = hsCenter;
                [self.contentView addSubview:handStepIV];
            }
            
        }];
        
        NSString *tcFristString = @"购买即视为同意";
        NSString *tcFullString = @"购买即视为同意\n《车队长有限公司协议的条款和章程》";
        
        NSDictionary *tcAttrDict = @{NSFontAttributeName:vGetHelveticaNeueFont(HelveticaNeueFontTypeOfBold, 15.0f, NO),
                                     NSForegroundColorAttributeName:CDZColorOfDarkBlue};
        NSMutableAttributedString *tcTitle =[[NSMutableAttributedString alloc] initWithString:tcFullString attributes:tcAttrDict];
        [tcTitle addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle]
                        range:NSMakeRange(tcFristString.length,tcTitle.length-tcFristString.length)];
        
        UIButton *imageBtn = (UIButton *)[self.contentView viewWithTag:100];
        UIButton *tcbutton = [UIButton buttonWithType:UIButtonTypeSystem];
        tcbutton.frame = CGRectMake(0.0f, CGRectGetMaxY(imageBtn.frame)+10.0f, CGRectGetWidth(self.contentView.frame), 40.f);
        tcbutton.titleLabel.numberOfLines = 0;
        tcbutton.titleLabel.textAlignment = NSTextAlignmentCenter;
        tcbutton.titleEdgeInsets = DefaultEdgeInsets;
        [tcbutton setAttributedTitle:tcTitle forState:UIControlStateNormal];
        tcbutton.titleLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfBold, 15.0f, NO);
        [tcbutton setTitleColor:CDZColorOfDarkBlue forState:UIControlStateNormal];
        [tcbutton addTarget:self action:@selector(showAgreement) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:tcbutton];
        
        UIButton *nextStepBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        nextStepBtn.frame = CGRectMake(0.0f, CGRectGetMaxY(tcbutton.frame)+vAdjustByScreenRatio(15.0f), CGRectGetWidth(self.contentView.frame)*0.75, 50.f);
        nextStepBtn.center = CGPointMake(CGRectGetWidth(self.contentView.frame)/2.0f, nextStepBtn.center.y);
        nextStepBtn.backgroundColor = [UIColor colorWithRed:0.902f green:0.310f blue:0.110f alpha:1.00f];
        nextStepBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        nextStepBtn.titleLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfBold, 15.0f, NO);
        [nextStepBtn setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:5.0f];
        [nextStepBtn setTitle:getLocalizationString(@"next_step") forState:UIControlStateNormal];
        [nextStepBtn setTitleColor:CDZColorOfWhite forState:UIControlStateNormal];
        [nextStepBtn addTarget:self action:@selector(pushToNextStepVC) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:nextStepBtn];
        
    }
}

- (void)showEventDetail {
    @autoreleasepool {
        NSString *urlString = [kBaseURLString stringByAppendingString:@"b2bweb-gold/rulesm.jsp"];
        [NSNotificationCenter.defaultCenter postNotificationName:CDZKeyOfShowWebRequestion object:nil userInfo:@{@"url":urlString}];
    }
}

- (void)showAgreement {
    @autoreleasepool {
        NSString *urlString = [kBaseURLString stringByAppendingString:@"b2bweb-gold/agreementm.jsp"];
        [NSNotificationCenter.defaultCenter postNotificationName:CDZKeyOfShowWebRequestion object:nil userInfo:@{@"url":urlString, @"title":@""}];
    }
}

- (void)initializationOtherStepUI {
    @autoreleasepool {
        
        NSArray *settingList = @[@{kTitle:@"GPS选择", @"imageName":@"gps_typeL"},
                                @{kTitle:@"流量卡", @"imageName":@"data_cardL"},
                                @{kTitle:@"保证金", @"imageName":@"recognizanceL"}];
        if (_currentStep>=1&&_currentStep<=3) {
            
            NSDictionary *detail = settingList[_currentStep-1];
            NSString *imageTitle = detail[@"title"];
            self.navigationController.title = imageTitle;
            
            UIFont *theFont = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 12.0f, NO);
            CGSize fontSize = [SupportingClass getStringSizeWithString:imageTitle font:theFont widthOfView:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
            fontSize.height +=10.0f;
            
            
            UIImage *image = [ImageHandler getImageFromCacheByScreenRatioWithFileRootPath:kSysImageCaches fileName:detail[@"imageName"] type:FMImageTypeOfPNG scaleWithPhone4:NO
                                                                              offsetRatioForP4:1.0f needToUpdate:YES];
            CGRect frame = CGRectZero;
            frame.size = image.size;
            frame.size.height += fontSize.height;
            frame.size.height = round(frame.size.height*1)/1+1;
            frame.origin.y = 6.0f;
            
            UIButton *imageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            imageBtn.frame = frame;
            imageBtn.userInteractionEnabled = NO;
            imageBtn.titleLabel.font = theFont;
            [imageBtn setImage:image forState:UIControlStateNormal];
            [imageBtn setTitle:imageTitle forState:UIControlStateNormal];
            [imageBtn setTitleColor:CDZColorOfDarkBlue forState:UIControlStateNormal];
            imageBtn.imageEdgeInsets = UIEdgeInsetsMake(0.0f, 0.0f, fontSize.height, 0.0f);
            imageBtn.titleEdgeInsets = UIEdgeInsetsMake(image.size.height, -image.size.width, 0.0f, 0.0f);
            imageBtn.center = CGPointMake(CGRectGetWidth(self.contentView.frame)*0.5f, imageBtn.center.y);
            [self.contentView addSubview:imageBtn];
            
            
            
            CGRect tvFrame = CGRectMake(0.0f, CGRectGetMaxY(imageBtn.frame),
                                        CGRectGetWidth(self.contentView.frame),
                                        CGRectGetHeight(self.contentView.frame)-CGRectGetMaxY(imageBtn.frame));
            self.tableView = [[UITableView alloc] initWithFrame:tvFrame];
            _tableView.bounces = NO;
            _tableView.delegate = self;
            _tableView.dataSource = self;
            _tableView.allowsSelection = YES;
            _tableView.allowsMultipleSelection = NO;
            _tableView.allowsSelectionDuringEditing = NO;
            _tableView.allowsMultipleSelectionDuringEditing = NO;
            [_tableView setViewBorderWithRectBorder:UIRectBorderAllBorderEdge borderSize:1.0f withColor:CDZColorOfSeperateLineDeepColor withBroderOffset:nil];
            [self.contentView addSubview:_tableView];
            [_tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
            
            self.bottomView = [[UIView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(_tableView.frame), 10.0f)];
            _tableView.tableFooterView = _bottomView;
            
            
            CGFloat width = CGRectGetWidth(self.contentView.frame)*0.8;
            
            if (_currentStep>1) {
                UIButton *previousStepBtn = [UIButton buttonWithType:UIButtonTypeSystem];
                previousStepBtn.frame = CGRectMake((CGRectGetWidth(_bottomView.frame)-width)/2.0f, 0.0f, width/2.0f, 50.f);
                previousStepBtn.center = CGPointMake(previousStepBtn.center.x, CGRectGetHeight(_bottomView.frame)/2.0f);
                previousStepBtn.backgroundColor = CDZColorOfDeepGray;
                previousStepBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
                previousStepBtn.titleLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfBold, 15.0f, NO);
                previousStepBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|
                                                   UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin;
                previousStepBtn.translatesAutoresizingMaskIntoConstraints = YES;
                [previousStepBtn setViewCornerWithRectCorner:UIRectCornerTopLeft|UIRectCornerBottomLeft cornerSize:5.0f];
                [previousStepBtn addTarget:self action:@selector(popBackPreviousStepVC) forControlEvents:UIControlEventTouchUpInside];
                [previousStepBtn setTitle:@"上一步" forState:UIControlStateNormal];
                [previousStepBtn setTitleColor:CDZColorOfWhite forState:UIControlStateNormal];
                [_bottomView addSubview:previousStepBtn];
            }
            
            self.nextStepBtn = [UIButton buttonWithType:UIButtonTypeSystem];
            _nextStepBtn.frame = CGRectMake(CGRectGetWidth(_bottomView.frame)/2.0f, 0.0f, width/2.0f, 50.f);
            _nextStepBtn.center = CGPointMake(_nextStepBtn.center.x, CGRectGetHeight(_bottomView.frame)/2.0f);
            [_nextStepBtn setViewCornerWithRectCorner:UIRectCornerTopRight|UIRectCornerBottomRight cornerSize:5.0f];
            if (_currentStep==1) {
                _nextStepBtn.frame = CGRectMake(0.0f, 0.0f, width, 50.f);
                _nextStepBtn.center = CGPointMake(CGRectGetWidth(_bottomView.frame)/2.0f, CGRectGetHeight(_bottomView.frame)/2.0f);
                [_nextStepBtn setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:5.0f];
            }
            _nextStepBtn.backgroundColor = [UIColor colorWithRed:0.902f green:0.310f blue:0.110f alpha:1.00f];
            _nextStepBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            _nextStepBtn.titleLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfBold, 15.0f, NO);
            _nextStepBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin;
            _nextStepBtn.translatesAutoresizingMaskIntoConstraints = YES;
            [_nextStepBtn setTitleColor:CDZColorOfWhite forState:UIControlStateNormal];
            [_bottomView addSubview:_nextStepBtn];
            if (_currentStep==3) {
                [_nextStepBtn setTitle:@"提交预约" forState:UIControlStateNormal];
                [_nextStepBtn addTarget:self action:@selector(submitGPSAppointment) forControlEvents:UIControlEventTouchUpInside];
            }else {
                [_nextStepBtn setTitle:getLocalizationString(@"next_step") forState:UIControlStateNormal];
                [_nextStepBtn addTarget:self action:@selector(pushToNextStepVC) forControlEvents:UIControlEventTouchUpInside];
            }
        }
    
    }
}

- (void)initializationUI {
    @autoreleasepool {
        BOOL isFristStep = (_currentStep==0);
        self.contentView.backgroundColor = isFristStep?[UIColor colorWithRed:0.988 green:0.678 blue:0.404 alpha:1]:CDZColorOfWhite;
        if (isFristStep) {
            [self initializationFristStepUI];
            self.title = getLocalizationString(@"GPS-Appointment");
        }else {
            [self initializationOtherStepUI];
        }
        
    }
}

- (void)setReactiveRules {
    if (_tableView) {
        [RACObserve(self, tableView.contentSize) subscribeNext:^(id theSize) {
            CGSize size = [theSize CGSizeValue];
            if (size.height<CGRectGetHeight(self.tableView.frame)) {
                CGRect frame = self.bottomView.frame;
                frame.size.height = CGRectGetHeight(self.tableView.frame)-size.height;
                self.bottomView.frame = frame;
//                NSLog(@"%@",self.bottomView.description);
//                NSLog(@"%@",self.tableView.description);
            }
            
        }];
    }
}

- (void)popBackPreviousStepVC {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)pushToNextStepVC {
    @autoreleasepool {
        NSUInteger theID = _currentStep+1;
        if (_currentStep==1) {
            [(GPSAppointmentNavVC *)self.navigationController setStepOneID:@(_tableView.indexPathForSelectedRow.row)];
        }
        
        if (_currentStep==2) {
            [(GPSAppointmentNavVC *)self.navigationController setStepTwoID:@(_tableView.indexPathForSelectedRow.row)];
        }
        
        GPSAppointmentContentVC *vc = [[GPSAppointmentContentVC alloc] initWithStepID:theID];
        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)submitGPSAppointment {
    if (!self.accessToken) {
        [NSNotificationCenter.defaultCenter postNotificationName:CDZKeyOfLoginVC object:nil];
        return;
    }
    NSString *userID = UserBehaviorHandler.shareInstance.getUserID;
    UserInfosDTO *dto = [DBHandler.shareInstance getUserInfo];
    UserAutosInfoDTO *autosDto = [DBHandler.shareInstance getUserAutosDetail];
    NSUInteger stepOneID = [[(GPSAppointmentNavVC *)self.navigationController stepOneID] unsignedIntegerValue];
    NSUInteger stepTwoID = [[(GPSAppointmentNavVC *)self.navigationController stepTwoID] unsignedIntegerValue];
    if ([userID isEqualToString:@"0"]||!self.accessToken||!dto.telphone) {
        return;
    }
//    [self setReloadFuncWithAction:_cmd parametersList:nil];
    GPSAppointmentResultBlock resultBlock = [(GPSAppointmentNavVC *)self.navigationController resultBlock];
    [ProgressHUDHandler showHUD];
//    [APIsConnection.shareConnection personalCenterAPIsPostGPSPurchasesAppointmentWithUserID:userID userName:dto.telphone gpsType:stepOneID dataCardType:stepTwoID recognizanceType:self.tableView.indexPathForSelectedRow.row success:^(NSURLSessionDataTask *operation, id responseObject) {
//        NSLog(@"%@", responseObject);
//        NSString *errorString = @"网路失败，请稍后再试！";
//        NSString *message = errorString;
//        NSString *cancelBtnStr = @"ok";
//        NSString *otherBtnStr = nil;
//        if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {
//            return;
//        }
//        GPSAppointmentResultType resultType = GPSAppointmentResultTypeOfUnknowError;
//        if ([responseObject isKindOfClass:NSData.class]) {
//            if ([responseObject length]==0) {
//                resultType = GPSAppointmentResultTypeOfMissingAutosData;
//                message = @"请完善个人车辆信息";//@"遗失车辆信息，请完善个人车辆信息";
//                cancelBtnStr = @"取消";
//                otherBtnStr = @"ok";
//            }else {
//                
//                NSString *statusString = [NSString stringWithUTF8String:[responseObject bytes]];
//                if ([[autosDto.licensePlate stringByReplacingOccurrencesOfString:@" " withString:@""]
//                     rangeOfString:[statusString stringByReplacingOccurrencesOfString:@" " withString:@""]].location!=NSNotFound) {
//                    resultType = GPSAppointmentResultTypeOfWasAppointmented;
//                    errorString = nil;
//                    message = @"你已经预约了GPS设备";
//                }
//                if ([[statusString lowercaseString] isEqualToString:@"success"]) {
//                    resultType = GPSAppointmentResultTypeOfSuccess;
//                    message = @"你已成功预约GPS设备";
//                }
//            }
//
//        }
//        [ProgressHUDHandler dismissHUDWithCompletion:^{
//            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:cancelBtnStr otherButtonTitles:otherBtnStr clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
//                
//                if (btnIdx.integerValue==0) {
//                    if (resultType==GPSAppointmentResultTypeOfWasAppointmented||
//                        resultType==GPSAppointmentResultTypeOfSuccess) {
//                        if (resultBlock) {
//                            resultBlock(resultType, errorString);
//                        }
//                    }
//                    
//                }else if (btnIdx.integerValue>0&&resultType==GPSAppointmentResultTypeOfMissingAutosData) {
//                    if (resultBlock) {
//                        resultBlock(resultType, errorString);
//                    }
//                }
//            }];
//        }];
//    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
//        NSLog(@"%@", error);
//        
//        if (error.code==-1009) {
//            if (resultBlock) {
//                resultBlock(GPSAppointmentResultTypeOfUnknowError, @"网络连接失败，请检查网络设置！");
//            }
//            
//            return;
//        }
//        
//        
//        if (error.code==-1001) {
//            if (resultBlock) {
//                resultBlock(GPSAppointmentResultTypeOfUnknowError, @"网络连接逾时，请稍后再试！");
//            }
//            
//            return;
//        }
//        
//        if (resultBlock) {
//            resultBlock(GPSAppointmentResultTypeOfUnknowError, @"网络错误，请稍后再试！");
//        }
//        
//    }];
    
}

- (void)retryAppointmentRequest {
    [self submitGPSAppointment];
}

#pragma -mark UITableViewDelgate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return _configList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    GPSACCell *cell = [tableView dequeueReusableCellWithIdentifier:CDZKeyOfCellIdentKey];
    if (!cell) {
        cell = [[GPSACCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CDZKeyOfCellIdentKey];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    // Configure the cell...
    NSDictionary *detail = _configList[indexPath.row];
    cell.textLabel.text = detail[kTitle];
    cell.detailTextLabel.text = detail[kDescription];
    cell.descriptionLabel.text = nil;
    if (detail[kPrice]) {
        cell.descriptionLabel.text = detail[kPrice];
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return vAdjustByScreenRatio(80.0f);
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
}

@end

