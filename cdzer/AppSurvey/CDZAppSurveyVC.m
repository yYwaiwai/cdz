//
//  CDZAppSurveyVC.m
//  cdzer
//
//  Created by KEns0n on 1/30/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "CDZAppSurveyVC.h"
#import "QuestionObject.h"
#import "AnswerObject.h"
#import "AppQACell.h"
#import "InsetsLabel.h"
#import "InsetsTextField.h"

@interface CDZASHFView : UITableViewHeaderFooterView

@property (nonatomic, strong) UIImageView *imageView;

@end

@interface CDZAppSurveyVC ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) NSMutableArray *configList;

@property (nonatomic, strong) NSMutableArray *selectedAnswerList;

@property (nonatomic, strong) NSMutableArray *headDetailList;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) InsetsTextField *qaOtherCommentTF;

@property (nonatomic, strong) InsetsTextField *userNameTF;

@property (nonatomic, strong) InsetsTextField *userContactTF;

@property (nonatomic, strong) InsetsTextField *userLPTF;

@property (nonatomic, strong) InsetsTextField *userAutosModelTF;

@property (nonatomic, strong) UIButton *submitButton;

@property (nonatomic, assign) CGRect keyboardRect;


@end

@implementation CDZAppSurveyVC


- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self componentSetting];
    [self initializationUI];
    [self setReactiveRules];
    self.title = @"问卷调查";
    // Do any additional setup after loading the view.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}


#pragma mark UI Init
- (void)componentSetting {
    @autoreleasepool {
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(tableViewActiveScrollEnable) name:AQATableViewActiveScrollEnableNotification object:nil];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(textFieldTextDidBeginEditingWithNoti:) name:AQATFDidBeginEditingNotification object:nil];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardDidShowNotification object:nil];
        
        self.configList = [@[] mutableCopy];
        self.selectedAnswerList = [@[] mutableCopy];
        self.headDetailList = [@[] mutableCopy];
        NSArray *cfigList = @[@{@"titleImage":@"surver_title1", @"title":@"关于应用", @"subList":@[@{@"sortID":@1, @"title":@"车队长APP是一个关于什么的应用？",
                                                                                    @"selectLimit":@0, @"commentTitle":@"",  /////section1
                                                                 @"answerList":@[@"汽车后市场服务平台",
                                                                                 @"力求实现汽车维修价格、配件质量控制",
                                                                                 @"“E代服务”开启不一样的用车体验",
                                                                                 @"提供硬件与平台服务的友好对接"]},
                                                               @{@"sortID":@2, @"title":@"您对APP的界面设计第一印象是？", @"selectLimit":@1, @"commentTitle":@"我有话说：",
                                                                 @"answerList":@[@"简单实用",
                                                                                 @"有点花",
                                                                                 @"复杂，让人不知头绪",
                                                                                 @"还可以，但要不断改进",]}]},
                              
                              @{@"titleImage":@"surver_title2", @"title":@"关于设备", @"subList":@[@{@"sortID":@3, @"title":@"您希望车载GPS/北斗定位终端有什么功能？",
                                                                                    @"selectLimit":@0, @"commentTitle":@"", /////section2
                                                                 @"answerList":@[@"车辆实时定位",
                                                                                 @"车辆轨迹回放",
                                                                                 @"断电、碰撞报警",
                                                                                 @"故障诊断"]},
                                                               @{@"sortID":@4, @"title":@"您希望通过哪种方式领取车队长车载GPS/北斗定位终端设备（免平台服务费）？", @"selectLimit":@1, @"commentTitle":@"",
                                                                 @"answerList":@[@"交设备保证金免费租赁实用（退机退款）",
                                                                                 @"通过平台购车辆保险送设备、送积分",
                                                                                 @"参加车队长推广活动有机会免费获取设备及一年的流量卡",
                                                                                 @"设备可以随时领取，不用退还"]},
                                                               
                                                               @{@"sortID":@5, @"title":@"参加车队长APP推广活动您希望获取哪些免费项目？", @"selectLimit":@0, @"commentTitle":@"",
                                                                 @"answerList":@[@"车载GPS/北斗定位终端设备及一年的流量卡（免平台服务费）",
                                                                                 @"OBD汽车故障智能检测设备",
                                                                                 @"车队长WIFI行车记录仪",
                                                                                 @"100元的加油卡"]},
                                                               @{@"sortID":@6, @"title":@"您希望车队长WIFI行车记录仪提供什么功能（新产品）？", @"selectLimit":@0, @"commentTitle":@"我有话说：",
                                                                 @"answerList":@[@"手机WIFI下载视频（不耗流量）",
                                                                                 @"手机远程拍照（耗流量）",
                                                                                 @"手机远程视频（耗流量）",
                                                                                 @"车辆碰撞自动拍照上传视频"]}]},
                              
                              @{@"titleImage":@"surver_title3", @"title":@"关于模版", @"subList":@[@{@"sortID":@7, @"title":@"“我的违章”您希望提供哪些功能？",
                                                                                    @"selectLimit":@0, @"commentTitle":@"", /////section3
                                                                 @"answerList":@[@"实时抓取并分析每一条违章信息",
                                                                                 @"在自己的朋友圈中与人分享自己的违章信息",
                                                                                 @"了解自己工作城市的主要违章高发点",
                                                                                 @"出行时，了解出行途中的主要违章高发点"
                                                                                 ]},
                                                               @{@"sortID":@8, @"title":@"“我的保险”您希望提供哪些功能？", @"selectLimit":@0, @"commentTitle":@"",
                                                                 @"answerList":@[@"有不同的保险套餐供我选择",
                                                                                 @"希望向大保险公司投保",
                                                                                 @"有专人负责我的保险理赔服务",
                                                                                 @"提供一些相关的保险知识"]},
                                                               
                                                               @{@"sortID":@9, @"title":@"“驾驶宝典”您希望提供哪些功能？", @"selectLimit":@0, @"commentTitle":@"",
                                                                 @"answerList":@[@"答题结果希望能与朋友一起分享",
                                                                                 @"采用游戏的方式与会员朋友一起在线答题",
                                                                                 @"开展答题竞赛活动",
                                                                                 @"希望参与时有更多奖品和积分送"]},
                                                               @{@"sortID":@10, @"title":@"“用车资讯”您对哪些知识感兴趣？", @"selectLimit":@0, @"commentTitle":@"我有话说：",
                                                                 @"answerList":@[@"用车头条（汽车后市场的一些及时性资讯）",
                                                                                 @"汽车文化",
                                                                                 @"汽车维修、保养",
                                                                                 @"保险与理赔"]}]},
                              
                              @{@"titleImage":@"surver_title4", @"title":@"关于模版（新）", @"subList":@[@{@"sortID":@11, @"title":@"“我要修车”您希望实现哪些功能？",
                                                                                       @"selectLimit":@0, @"commentTitle":@"", /////section4
                                                                    @"answerList":@[@"汽车维修结算价格标准并透明",
                                                                                    @"自主网上诊断车辆故障并能分析预期费用",
                                                                                    @"更多维修案例供我参考",
                                                                                    @"平台实行先行赔付，我不在维修车而烦恼",]},
                                                                  @{@"sortID":@12, @"title":@"“配件超市”您希望实现哪些功能？", @"selectLimit":@0, @"commentTitle":@"",
                                                                    @"answerList":@[@"配件来源于正规渠道",
                                                                                    @"配件价格透明并可以在网上对比",
                                                                                    @"有专业人员为我们辨别正品",
                                                                                    @"维修商采购配件和自主采购配件同质同价"
                                                                                    ]},
                                                                  
                                                                  @{@"sortID":@13, @"title":@"“维修指南”您最希望了解哪些维修知识？", @"selectLimit":@0, @"commentTitle":@"",
                                                                    @"answerList":@[@"更多维修视频可供选择",
                                                                                    @"哪些简单维修可以自己动手",
                                                                                    @"哪些属于汽车易损件，多少里程或时间该更换",
                                                                                    @"4S点与普通维修厂的区别"]},
                                                                  @{@"sortID":@14, @"title":@"“二手车”您最希望实现哪些功能？", @"selectLimit":@0, @"commentTitle":@"",
                                                                    @"answerList":@[@"会员之间能实现自由交易，交易费为零",
                                                                                    @"车辆检测评估机构公正、透明",
                                                                                    @"能看到交易车辆的维修、理赔记录",
                                                                                    @"更多服务提供商，收费透明有保障"]},
                                                                  
                                                                  @{@"sortID":@15, @"title":@"“爱车维权”您最希望实现哪些功能？", @"selectLimit":@0, @"commentTitle":@"",
                                                                    @"answerList":@[@"汽车质量投诉能收到及时反馈",
                                                                                    @"平台内的服务能享受先行赔付",
                                                                                    @"平台代表我们一起发起诉讼",
                                                                                    @"诉讼资金可以大家一起众筹解决",]},
                                                                  @{@"sortID":@16, @"title":@"“E代服务”您最希望实现哪些功能？", @"selectLimit":@0, @"commentTitle":@"我有话说：",
                                                                    @"answerList":@[@"提供代步车服务",
                                                                                    @"专业人员代我去修理厂修车",
                                                                                    @"汽车年检，有专人代办，价格优惠透明",
                                                                                    @"车辆发生事故后，有专业人员代我处理",]}]},
                              
                              @{@"titleImage":@"surver_title5", @"title":@"关于服务", @"subList":@[@{@"sortID":@17, @"title":@"“一键客服”您私人的爱车管家包含什么服务？",
                                                                                    @"selectLimit":@0, @"commentTitle":@"", /////section5
                                                                 @"answerList":@[@"任何的平台使用疑问",
                                                                                 @"平台服务投诉及建议",
                                                                                 @"用车途中的紧急情况解决及帮助",
                                                                                 @"业务咨询"]},
                                                               @{@"sortID":@18, @"title":@"您对哪种沟通方式更感兴趣？", @"selectLimit":@1, @"commentTitle":@"我有话说：",
                                                                 @"answerList":@[@"电话服务回访",
                                                                                 @"邮件、短信",
                                                                                 @"平台消息",
                                                                                 @"微信QQ",]}]},
                              
                              @{@"titleImage":@"surver_title6", @"title":@"商务合作", @"subList":@[@{@"sortID":@19, @"title":@"您希望车队长E服务专员是种什么工作模式？",
                                                                                    @"selectLimit":@0, @"commentTitle":@"", /////section6
                                                                 @"answerList":@[@"E代修服务专员兼职，接受平台随时抢单或派单",
                                                                                 @"E代检服务专员兼职，接受平台随时抢单或派单",
                                                                                 @"E代赔服务专员兼职，接受平台随时抢单或派单",
                                                                                 @"平台培训、平台认证（有3年以上驾龄）",]},
                                                               @{@"sortID":@20, @"title":@"车队长平台有什么合作商机？", @"selectLimit":@0, @"commentTitle":@"",
                                                                 @"answerList":@[@"平台认证合作、品牌授权加盟维修服务商",
                                                                                 @"平台异地运营合作代理服务商",
                                                                                 @"平台认证合作汽车配件服务商",
                                                                                 @"车载GPS北斗定位终端、WIFI行车记录仪运营合作"]},
                                                               
                                                               @{@"sortID":@21, @"title":@"您喜欢通过何种方式联系车队长？", @"selectLimit":@1, @"commentTitle":@"我有话说：",
                                                                 @"answerList":@[@"电话",
                                                                                 @"企业邮箱",
                                                                                 @"您的“一键客服”",
                                                                                 @"车队长总部实地考察",]}]},];
        @weakify(self);
        [cfigList enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull cfigSubDetail, NSUInteger idx, BOOL * _Nonnull stop) {
            @strongify(self);
            NSMutableArray <QuestionObject *> *subList = [@[] mutableCopy];
            NSMutableArray <AnswerObject *> *subAnswerList = [@[] mutableCopy];
            NSArray *cfigSubList = cfigSubDetail[@"subList"];
            [self.headDetailList addObject:cfigSubDetail[@"titleImage"]];
            [cfigSubList enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull cfigDetail, NSUInteger idx, BOOL * _Nonnull stop) {
                
                QuestionObject *qObject = [QuestionObject new];
                qObject.qid = cfigDetail[@"sortID"];
                qObject.question = cfigDetail[@"title"];
                qObject.anwserSelectionList = cfigDetail[@"answerList"];
                qObject.numberOfCanSelAnswer = [cfigDetail[@"selectLimit"] unsignedIntegerValue];
                qObject.commentTitle = cfigDetail[@"commentTitle"];
                qObject.withOtherComment = ![qObject.commentTitle isEqualToString:@""];
                [subList addObject:qObject];
                
                AnswerObject *aObject = [AnswerObject new];
                aObject.qid = qObject.qid;
                [subAnswerList addObject:aObject];
                
            }];
            [self.selectedAnswerList addObject:subAnswerList];
            [self.configList addObject:subList];
        }];
    }
}

- (void)initializationUI {
    @autoreleasepool {
        
        self.tableView = [[UITableView alloc] initWithFrame:self.contentView.bounds];
        _tableView.backgroundColor = CDZColorOfWhite;//[UIColor colorWithRed:0.937f green:0.937f blue:0.957f alpha:1.00f];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.scrollsToTop = YES;
        _tableView.bounces = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.contentView addSubview:_tableView];
        
        
//        InsetsLabel *headerView = [[InsetsLabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(_tableView.frame), CGRectGetHeight(_tableView.frame))
//                                                  andEdgeInsetsValue:kIntEdgeInsets];
//        headerView.numberOfLines = 0;
//        headerView.text = @"亲爱的用户：\n\n感谢您参与车队长的问卷调查，我们将不断优化产品，为你提供更好的服务，登录后首次提交问卷，您将可以获得50点积分奖励哦！";
//        headerView.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(_tableView.frame), [headerView heightThatFitsWithSpaceOffset:30.0f]);

        UIImage *image = [ImageHandler getImageFromCacheByScreenRatioWithFileRootPath:nil fileName:@"surver_banner" type:FMImageTypeOfPNG scaleWithPhone4:NO offsetRatioForP4:0 needToUpdate:YES];
        UIImageView *headerView = [[UIImageView alloc] initWithImage:image];
        _tableView.tableHeaderView = headerView;
        
        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(_tableView.frame), 44.0f)];
        [toolbar setBarStyle:UIBarStyleDefault];
        UIBarButtonItem *spaceButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                    target:self
                                                                                    action:nil];
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]initWithTitle:getLocalizationString(@"finish")
                                                                      style:UIBarButtonItemStyleDone
                                                                     target:self
                                                                     action:@selector(hiddenKeyboard)];
        NSArray * buttonsArray = [NSArray arrayWithObjects:spaceButton,doneButton,nil];
        [toolbar setItems:buttonsArray];
        
        
        
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(_tableView.frame), CGRectGetHeight(_tableView.frame))];
        InsetsLabel *qaOtherCommentTitle = [[InsetsLabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(footerView.frame), CGRectGetHeight(_tableView.frame))
                                                  andEdgeInsetsValue:kIntEdgeInsets];
        qaOtherCommentTitle.numberOfLines = 0;
        qaOtherCommentTitle.text = @"22.针对车队长APP您还有什么其他的建议和意见？";
        qaOtherCommentTitle.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(_tableView.frame), [qaOtherCommentTitle heightThatFitsWithSpaceOffset:10.0f]);
        [footerView addSubview:qaOtherCommentTitle];

        BorderOffsetObject *borderObject = [BorderOffsetObject new];
        borderObject.bottomLeftOffset = kIntEdgeInsets.left;
        borderObject.bottomOffset = 8.0f;
        borderObject.bottomRightOffset = kIntEdgeInsets.right;
        
        self.qaOtherCommentTF = [[InsetsTextField alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(qaOtherCommentTitle.frame), CGRectGetWidth(footerView.frame), 36)
                                                     andEdgeInsetsValue:kIntEdgeInsets];
        _qaOtherCommentTF.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _qaOtherCommentTF.translatesAutoresizingMaskIntoConstraints = YES;
        _qaOtherCommentTF.inputAccessoryView = toolbar;
        _qaOtherCommentTF.delegate = self;
        [_qaOtherCommentTF setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:CDZColorOfBlack withBroderOffset:borderObject];
        [footerView addSubview:_qaOtherCommentTF];
        
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        InsetsLabel *userInfoTitle = [[InsetsLabel alloc] initWithFrame:CGRectMake(0.0f, 8.0f, CGRectGetWidth(footerView.frame), CGRectGetHeight(_tableView.frame))
                                                           andEdgeInsetsValue:kIntEdgeInsets];
        userInfoTitle.numberOfLines = 0;
        userInfoTitle.text = @"23.个人资料";
        userInfoTitle.frame = CGRectMake(0.0f, CGRectGetMaxY(_qaOtherCommentTF.frame), CGRectGetWidth(footerView.frame), [userInfoTitle heightThatFitsWithSpaceOffset:10.0f]);
        [footerView addSubview:userInfoTitle];
        
        self.userNameTF = [[InsetsTextField alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(userInfoTitle.frame), CGRectGetWidth(footerView.frame), 40)
                                                    andEdgeInsetsValue:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, kIntEdgeInsets.right)];
        _userNameTF.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _userNameTF.translatesAutoresizingMaskIntoConstraints = YES;
        _userNameTF.inputAccessoryView = toolbar;
        _userNameTF.delegate = self;
        [footerView addSubview:_userNameTF];
        
        InsetsLabel *userNameTitleLabel = [[InsetsLabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 100, 40)
                                             andEdgeInsetsValue:UIEdgeInsetsMake(0.0f, kIntEdgeInsets.left, 0.0f, 0.0f)];
        userNameTitleLabel.text = @"尊姓大名：";
        userNameTitleLabel.frame = CGRectMake(0.0f, 0.0f, [userNameTitleLabel widthThatFitsWithSpaceOffset:2.0f], 40);
        [_userNameTF addSubview:userNameTitleLabel];
        _userNameTF.edgeInsets = UIEdgeInsetsMake(0.0f, CGRectGetMaxX(userNameTitleLabel.frame), 0.0f, kIntEdgeInsets.right);
        borderObject.bottomLeftOffset = _userNameTF.edgeInsets.left;
        [_userNameTF setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:CDZColorOfBlack withBroderOffset:borderObject];

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        self.userContactTF = [[InsetsTextField alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(_userNameTF.frame)+6.0f, CGRectGetWidth(footerView.frame), 40)
                                                    andEdgeInsetsValue:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, kIntEdgeInsets.right)];
        _userContactTF.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _userContactTF.translatesAutoresizingMaskIntoConstraints = YES;
        _userContactTF.inputAccessoryView = toolbar;
        _userContactTF.delegate = self;
        _userContactTF.keyboardType = UIKeyboardTypePhonePad;
        [footerView addSubview:_userContactTF];
        
        InsetsLabel *userContactTFTitleLabel = [[InsetsLabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 100, 40)
                                                          andEdgeInsetsValue:UIEdgeInsetsMake(0.0f, kIntEdgeInsets.left, 0.0f, 0.0f)];
        userContactTFTitleLabel.text = @"联系方式：";
        userContactTFTitleLabel.frame = CGRectMake(0.0f, 0.0f, [userContactTFTitleLabel widthThatFitsWithSpaceOffset:2.0f], 40);
        [_userContactTF addSubview:userContactTFTitleLabel];
        _userContactTF.edgeInsets = UIEdgeInsetsMake(0.0f, CGRectGetMaxX(userContactTFTitleLabel.frame), 0.0f, kIntEdgeInsets.right);
        borderObject.bottomLeftOffset = _userContactTF.edgeInsets.left;
        [_userContactTF setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:CDZColorOfBlack withBroderOffset:borderObject];

        
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        self.userLPTF = [[InsetsTextField alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(_userContactTF.frame)+6.0f, CGRectGetWidth(footerView.frame), 40)
                                                    andEdgeInsetsValue:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, kIntEdgeInsets.right)];
        _userLPTF.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _userLPTF.translatesAutoresizingMaskIntoConstraints = YES;
        _userLPTF.inputAccessoryView = toolbar;
        _userLPTF.delegate = self;
        [footerView addSubview:_userLPTF];
        
        InsetsLabel *userLPTitleLabel = [[InsetsLabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 100, 40)
                                                          andEdgeInsetsValue:UIEdgeInsetsMake(0.0f, kIntEdgeInsets.left, 0.0f, 0.0f)];
        userLPTitleLabel.text = @"爱车车牌：";
        userLPTitleLabel.frame = CGRectMake(0.0f, 0.0f, [userLPTitleLabel widthThatFitsWithSpaceOffset:2.0f], 40);
        [_userLPTF addSubview:userLPTitleLabel];
        _userLPTF.edgeInsets = UIEdgeInsetsMake(0.0f, CGRectGetMaxX(userLPTitleLabel.frame), 0.0f, kIntEdgeInsets.right);
        borderObject.bottomLeftOffset = _userLPTF.edgeInsets.left;
        [_userLPTF setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:CDZColorOfBlack withBroderOffset:borderObject];

   
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        self.userAutosModelTF = [[InsetsTextField alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(_userLPTF.frame)+6.0f, CGRectGetWidth(footerView.frame), 40)
                                                    andEdgeInsetsValue:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, kIntEdgeInsets.right)];
        _userAutosModelTF.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _userAutosModelTF.translatesAutoresizingMaskIntoConstraints = YES;
        _userAutosModelTF.inputAccessoryView = toolbar;
//        _userAutosModelTF.keyboardType = UIKeyboardTypeASCIICapable;
        _userAutosModelTF.delegate = self;
        [footerView addSubview:_userAutosModelTF];
        
        InsetsLabel *userAutosModelTitleLabel = [[InsetsLabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 100, 40)
                                                          andEdgeInsetsValue:UIEdgeInsetsMake(0.0f, kIntEdgeInsets.left, 0.0f, 0.0f)];
        userAutosModelTitleLabel.text = @"爱车车型：";
        userAutosModelTitleLabel.frame = CGRectMake(0.0f, 0.0f, [userAutosModelTitleLabel widthThatFitsWithSpaceOffset:2.0f], 40);
        [_userAutosModelTF addSubview:userAutosModelTitleLabel];
        _userAutosModelTF.edgeInsets = UIEdgeInsetsMake(0.0f, CGRectGetMaxX(userAutosModelTitleLabel.frame), 0.0f, kIntEdgeInsets.right);
        borderObject.bottomLeftOffset = _userAutosModelTF.edgeInsets.left;
        [_userAutosModelTF setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:CDZColorOfBlack withBroderOffset:borderObject];

        
        self.submitButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _submitButton.frame = CGRectMake(CGRectGetWidth(footerView.frame)*0.1f, CGRectGetMaxY(_userAutosModelTF.frame)+20.0f, CGRectGetWidth(footerView.frame)*0.8f, 40.0f);
        _submitButton.backgroundColor = CDZColorOfDefaultColor;
        [_submitButton setTitle:getLocalizationString(@"submit") forState:UIControlStateNormal];
        [_submitButton setTitleColor:CDZColorOfWhite forState:UIControlStateNormal];
        [_submitButton setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:5.0f];
        [_submitButton addTarget:self action:@selector(submitAppSurvey) forControlEvents:UIControlEventTouchUpInside];
        [footerView addSubview:_submitButton];
        
        CGRect footerViewRect = footerView.frame;
        footerViewRect.size.height = CGRectGetMaxY(_submitButton.frame)+20.0f;
        footerView.frame = footerViewRect;
        _tableView.tableFooterView = footerView;
    }
}

- (void)keyboardWillShow:(NSNotification *)notifyObject {
    CGRect keyboardRect = [[notifyObject.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    if(_qaOtherCommentTF.isFirstResponder||_userNameTF.isFirstResponder||
       _userContactTF.isFirstResponder||_userLPTF.isFirstResponder||_userAutosModelTF.isFirstResponder) {
        if (!CGRectEqualToRect(keyboardRect, _keyboardRect)) {
            self.keyboardRect = keyboardRect;
            if(_qaOtherCommentTF.isFirstResponder) {
                [self shiftScrollViewWithAnimation:_qaOtherCommentTF];
            }
            
            if(_userNameTF.isFirstResponder) {
                [self shiftScrollViewWithAnimation:_userNameTF];
            }
            
            if(_userContactTF.isFirstResponder) {
                [self shiftScrollViewWithAnimation:_userContactTF];
            }
            
            if(_userLPTF.isFirstResponder) {
                [self shiftScrollViewWithAnimation:_userLPTF];
            }
            
            if(_userAutosModelTF.isFirstResponder) {
                [self shiftScrollViewWithAnimation:_userAutosModelTF];
            }
            NSLog(@"VC Step One");
        }
    }
}

- (void)shiftScrollViewWithAnimation:(UITextField *)textField {
    UIView *theView = self.tableView;
    CGPoint point = CGPointZero;
    CGFloat contanierViewMaxY = CGRectGetMidY([textField.superview convertRect:textField.frame toView:theView]);
    CGFloat visibleContentsHeight = (CGRectGetHeight(theView.frame)-CGRectGetHeight(_keyboardRect))/2.0f;
    if (contanierViewMaxY > visibleContentsHeight) {
        CGFloat offsetY = contanierViewMaxY-visibleContentsHeight;
        point.y = offsetY;
    }
    [self.tableView setContentOffset:point animated:NO];
    self.tableView.scrollEnabled = NO;
}

- (void)tableViewActiveScrollEnable {
    self.tableView.scrollEnabled = YES;
}

- (void)textFieldTextDidBeginEditingWithNoti:(NSNotification *)notify {
    NSLog(@"%@",notify.userInfo);
    CGRect tfConvertedRect = [notify.userInfo[@"tfConvertedRect"] CGRectValue];
    CGRect keyboardRect = [notify.userInfo[@"keyboardRect"] CGRectValue];
    NSIndexPath *indexPath = notify.userInfo[@"cellIndexPath"];
    AppQACell *cell = [_tableView cellForRowAtIndexPath:indexPath];
    CGPoint point = CGPointZero;
    CGFloat contanierViewMaxY = CGRectGetMidY([cell convertRect:tfConvertedRect toView:_tableView]);
    CGFloat visibleContentsHeight = (CGRectGetHeight(self.tableView.frame)-CGRectGetHeight(keyboardRect))/2.0f;
    if (contanierViewMaxY > visibleContentsHeight) {
        CGFloat offsetY = contanierViewMaxY-visibleContentsHeight;
        point.y = offsetY;
    }
    [self.tableView setContentOffset:point animated:NO];
    self.tableView.scrollEnabled = NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (!CGRectEqualToRect(CGRectZero, _keyboardRect)) {
        [self shiftScrollViewWithAnimation:textField];
    }
}

- (void)hiddenKeyboard {
    [_qaOtherCommentTF resignFirstResponder];
    [_userNameTF resignFirstResponder];
    [_userContactTF resignFirstResponder];
    [_userLPTF resignFirstResponder];
    [_userAutosModelTF resignFirstResponder];
    self.keyboardRect = CGRectZero;
    UIScrollView *theView = self.tableView;
    CGPoint point = CGPointZero;
    point.y = theView.contentSize.height - CGRectGetHeight(theView.frame);
    [self.tableView setContentOffset:point animated:NO];
    [self tableViewActiveScrollEnable];
}

- (void)setReactiveRules {
    @autoreleasepool {
        
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return _configList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [(NSArray *)_configList[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AppQACell *cell = [tableView dequeueReusableCellWithIdentifier:CDZKeyOfCellIdentKey];
    if (!cell) {
        cell = [[AppQACell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CDZKeyOfCellIdentKey];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell setBackgroundColor:CDZColorOfClearColor];
        
    }
    cell.otherCommentLabel.accessibilityIdentifier = [NSString stringWithFormat:@"%d,%d", indexPath.section, indexPath.row];
    cell.indexPath = indexPath;
    if (!cell.asBlock) {
        @weakify(self);
        [cell setAnswerSelectionBlock:^(AnswerObject *aObject, NSIndexPath *theIdxPath) {
            @strongify(self);
            @autoreleasepool {
                NSMutableArray <AnswerObject *> *subAnswerList = [self.selectedAnswerList[theIdxPath.section] mutableCopy];
                [subAnswerList replaceObjectAtIndex:theIdxPath.row withObject:aObject];
                [self.selectedAnswerList replaceObjectAtIndex:theIdxPath.section withObject:subAnswerList];
            }
        }];
    }
    
    QuestionObject *qObject = [_configList[indexPath.section] objectAtIndex:indexPath.row];
    AnswerObject *aObject = [_selectedAnswerList[indexPath.section] objectAtIndex:indexPath.row];
    [cell updateUIData:qObject andAnswerObject:aObject];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    
    return 210;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section {
    return 36.0f;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    
//    return 36.0f;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
//    
//    return 0.0f;
//}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    static NSString *headerIdentifier = @"header";
    CDZASHFView *myHeader = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerIdentifier];
    if(!myHeader) {
        myHeader = [[CDZASHFView alloc]initWithReuseIdentifier:headerIdentifier];
        myHeader.contentView.backgroundColor = CDZColorOfWhite;
//        InsetsLabel *titleLabel = [[InsetsLabel alloc] initWithFrame:CGRectZero
//                                                  andEdgeInsetsValue:UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 10.0f)];
//        titleLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfBold, 19.0f, NO);
//        titleLabel.textAlignment = NSTextAlignmentLeft;
//        titleLabel.tag = 10;
//        titleLabel.translatesAutoresizingMaskIntoConstraints = YES;
//        titleLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
//        [myHeader addSubview:titleLabel];
//        
//        [myHeader setNeedsUpdateConstraints];
//        [myHeader updateConstraintsIfNeeded];
//        [myHeader setNeedsLayout];
//        [myHeader layoutIfNeeded];
    }
//    InsetsLabel *titleLabel = (InsetsLabel *)[myHeader viewWithTag:10];
//    NSString *title = _headDetailList[section];
//    titleLabel.text = title;
    myHeader.imageView.image = nil;
    NSString *imageName = _headDetailList[section];
    UIImage *image = [ImageHandler getImageFromCacheWithByFixdeRatioFileRootPath:nil fileName:imageName type:FMImageTypeOfPNG needToUpdate:YES];
    myHeader.imageView.image = image;
    return myHeader;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableArray <NSNumber *>*)checkAllQuestionWasSelected {
    NSMutableArray *diselectedQuestionList = [@[] mutableCopy];
    [_selectedAnswerList enumerateObjectsUsingBlock:^(NSMutableArray * _Nonnull sectionList, NSUInteger sectionIdx, BOOL * _Nonnull sectionStop) {
        [sectionList enumerateObjectsUsingBlock:^(AnswerObject * _Nonnull aObject, NSUInteger rowIdx, BOOL * _Nonnull rowStop) {
            if (aObject.selectedAnswerSet.count==0) {
                [diselectedQuestionList addObject:aObject.qid];
            }
        }];
    }];
    return diselectedQuestionList;
}

- (void)submitAppSurvey {
    @weakify(self);
    NSMutableArray <NSNumber *> *diselectedQuestionList = [self checkAllQuestionWasSelected];
    if (diselectedQuestionList.count>0) {
        NSString *qidListString = [diselectedQuestionList componentsJoinedByString:@"，"];
        [SupportingClass showAlertViewWithTitle:nil message:[@"以下问题还没有回答：\n" stringByAppendingString:qidListString] isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
//            @strongify(self);
            
        }];
        return;
    }
    NSString *accessToken = self.accessToken;
    if (!accessToken) accessToken = @"";
    NSMutableArray *answerList = [@[] mutableCopy];
    NSMutableArray *otherAdviceList = [@[] mutableCopy];
    [_selectedAnswerList enumerateObjectsUsingBlock:^(NSMutableArray * _Nonnull sectionList, NSUInteger sectionIdx, BOOL * _Nonnull sectionStop) {
        [sectionList enumerateObjectsUsingBlock:^(AnswerObject * _Nonnull aObject, NSUInteger rowIdx, BOOL * _Nonnull rowStop) {
            @strongify(self);
            QuestionObject *qObject = [self.configList[sectionIdx] objectAtIndex:rowIdx];
            NSMutableArray *tmpArray = [@[] mutableCopy];
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:nil ascending:YES];
            NSArray *sortDescriptors=[NSArray arrayWithObject:sortDescriptor];
            NSArray *reorderArray = [aObject.selectedAnswerSet.allObjects sortedArrayUsingDescriptors:sortDescriptors];
            [reorderArray enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull aid, NSUInteger aidIdx, BOOL * _Nonnull aidStop) {
                
                NSString *markStr = @"";
                NSString *answer = qObject.anwserSelectionList[aid.row];
                switch (aid.row) {
                    case 0:
                        markStr = @"A";
                        break;
                    case 1:
                        markStr = @"B";
                        break;
                    case 2:
                        markStr = @"C";
                        break;
                    case 3:
                        markStr = @"D";
                        break;
                    case 4:
                        markStr = @"E";
                        break;
                    case 5:
                        markStr = @"F";
                        break;
                    case 6:
                        markStr = @"G";
                        break;
                    case 7:
                        markStr = @"H";
                        break;
                        
                    default:
                        break;
                }
                
                [tmpArray addObject:[NSString stringWithFormat:@"%@.%@", markStr, answer]];
            }];
            
            [answerList addObject:[tmpArray componentsJoinedByString:@"-"]];
            
            if (qObject.withOtherComment) {
                NSString *otherSubComment = @"没填";
                if (aObject.otherComment&&![aObject.otherComment isEqualToString:@""]) {
                    otherSubComment = aObject.otherComment;
                }
                [otherAdviceList addObject:otherSubComment];
            }
            
        }];
    }];
    NSString *otherComment = @"没填";
    if (_qaOtherCommentTF.text&&![_qaOtherCommentTF.text isEqualToString:@""]) {
        otherComment = _qaOtherCommentTF.text;
    }
    NSString *userName = @"没填";
    if (_userNameTF.text&&![_userNameTF.text isEqualToString:@""]) {
        userName = _userNameTF.text;
    }
    NSString *userContact = @"没填";
    if (_userContactTF.text&&![_userContactTF.text isEqualToString:@""]) {
        userContact = _userContactTF.text;
    }
    NSString *userLP = @"没填";
    if (_userLPTF.text&&![_userLPTF.text isEqualToString:@""]) {
        userLP = _userLPTF.text;
    }
    NSString *userAutosModel = @"没填";
    if (_userAutosModelTF.text&&![_userAutosModelTF.text isEqualToString:@""]) {
        userAutosModel = _userAutosModelTF.text;
    }
    [otherAdviceList addObject:otherComment];
    [otherAdviceList addObject:userName];
    [otherAdviceList addObject:userContact];
    [otherAdviceList addObject:userLP];
    [otherAdviceList addObject:userAutosModel];
    
    NSString *answerListString = [answerList componentsJoinedByString:@"|"];
    NSString *otherAdviceListString = [otherAdviceList componentsJoinedByString:@"-"];
    
    [ProgressHUDHandler showHUD];
    [APIsConnection.shareConnection personalCenterAPIsGetMyPFeedbackToShowWithAccessToken:accessToken answerListString:answerListString otherAdviceListString:otherAdviceListString success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        
        if (errorCode==0) {
            [ProgressHUDHandler dismissHUD];
            [SupportingClass showAlertViewWithTitle:nil message:@"提交成功！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                [self.navigationController popToRootViewControllerAnimated:YES];
            }];
            return;
        }
        [ProgressHUDHandler dismissHUD];
        [SupportingClass showAlertViewWithTitle:nil message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:nil];
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        if (error.code==-1009) {
            [SupportingClass showAlertViewWithTitle:@"error" message:@"网络连接失败，请检查网络设置！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                [ProgressHUDHandler dismissHUD];
            }];
            return;
        }
        
        
        if (error.code==-1001) {
            [SupportingClass showAlertViewWithTitle:@"error" message:@"网络连接逾时，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
                [ProgressHUDHandler dismissHUD];
            }];
            return;
        }
        
        [SupportingClass showAlertViewWithTitle:@"error" message:@"网络错误，请稍后再试！" isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {
            [ProgressHUDHandler dismissHUD];
        }];
    }];
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

@implementation CDZASHFView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        self.imageView = [UIImageView new];
        [self.contentView addSubview:self.imageView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.imageView sizeToFit];
    self.imageView.center = CGPointMake(CGRectGetWidth(self.frame)/2.0f, CGRectGetHeight(self.frame)/2.0f);
}

- (CGSize)sizeThatFits:(CGSize)size {
    size.height = CGRectGetHeight(_imageView.frame)+20.0f;
    return size;
}

@end


