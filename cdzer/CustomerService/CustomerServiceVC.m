//
//  CustomerServiceVC.m
//  cdzer
//
//  Created by 车队长 on 16/10/11.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "CustomerServiceVC.h"
#import "CustomerServiceCell.h"
#define kIntEdgeInsets UIEdgeInsetsMake(0.0f, 12.0f, 0.0f, 12.0f)

@interface CustomerServiceVC ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIControl *customerServiceControl;//客服

@property (weak, nonatomic) IBOutlet UIView *buttonBgView;

@property (weak, nonatomic) IBOutlet UIView *cjControl;


@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIButton *buttonOne;

@property (weak, nonatomic) IBOutlet UIButton *buttonTwo;

@property (weak, nonatomic) IBOutlet UIButton *buttonThree;

@property (weak, nonatomic) IBOutlet UIButton *buttonFour;

@property (nonatomic, strong) NSArray *sectionDataArray;

@property (nonatomic, strong) NSArray *rowDataArray;

@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;

@property (nonatomic, strong) IBOutlet NSLayoutConstraint *topConstraint;

@property (nonatomic,strong) NSNumber *status;

@end

@implementation CustomerServiceVC
{
    BOOL _isOpen[8];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[UINib nibWithNibName:@"CustomerServiceVC" bundle:nil] instantiateWithOwner:self options:nil];
    self.title=@"客服";
    self.tableView.backgroundColor=self.view.backgroundColor;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 110.0f;
    self.tableView.tableFooterView = [UIView new];
    UINib*nib = [UINib nibWithNibName:@"CustomerServiceCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"CustomerServiceCell"];
    
    [self.buttonOne setViewBorderWithRectBorder:UIRectBorderBottom borderSize:1 withColor:[UIColor colorWithHexString:@"f8af30"] withBroderOffset:nil];
    if (self.navigationController&&!self.tabBarController) {
        self.navBar.hidden = YES;
        self.topConstraint.constant = -CGRectGetHeight(self.navBar.bounds);
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.status = @(1);
    [self statusDate];
    self.tabBarController.navigationItem.leftBarButtonItem = nil;
    self.tabBarController.navigationItem.rightBarButtonItem = nil;
    self.tabBarController.navigationItem.leftBarButtonItems = nil;
    self.tabBarController.navigationItem.rightBarButtonItems = nil;
    self.tabBarController.automaticallyAdjustsScrollViewInsets = NO;
    self.tabBarController.extendedLayoutIncludesOpaqueBars = YES;
    self.tabBarController.navigationController.navigationBar.hidden = YES;
    
    [self.tabBarController.view setNeedsLayout];
    [self.navigationController.view setNeedsLayout];
    [UIApplication.sharedApplication setStatusBarStyle:UIStatusBarStyleDefault];
    NSLog(@"%@", self.accessToken);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self.buttonBgView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    
    self.customerServiceControl.layer.cornerRadius=3.0;
    self.customerServiceControl.layer.masksToBounds=YES;
    BorderOffsetObject *offset = [BorderOffsetObject new];
    offset.rightUpperOffset = 8;
    offset.rightBottomOffset = offset.rightUpperOffset;
    [self.cjControl setViewBorderWithRectBorder:UIRectBorderRight borderSize:0.5 withColor:nil withBroderOffset:offset];
}

- (void)statusDate {
    if ([self.status isEqual:@(1)]) {
        self.sectionDataArray=[NSArray arrayWithObjects:@"如何选择汽车型号？",@"如何查看轮胎型号？",@"如何查看车架号、发动机号及年检日期？", nil];
        self.rowDataArray=[NSArray arrayWithObjects:@"答：您可以通过在车头盖发动机旁边或是左右车门旁边的汽车铭牌上进行查看。如下图所示",@"答：如下图所示",@"答：您可以通过驾驶证上的信息进行查看。如下图所示", nil];
    }
    if ([self.status isEqual:@(2)]) {
        self.sectionDataArray=[NSArray arrayWithObjects:@"在车队长app里有几种途径购买商品？",@"可以开发票吗？",@"如何取消订单？",@"订单提交成功后还可以修改订单信息吗？",@"申请退款会全额退款吗？要承担运费吗？",@"有几种支付方式？", nil];
        self.rowDataArray=[NSArray arrayWithObjects:@"答：\n如果您的爱车需要维修：\n① 您可以通过“快速维修”模块进行筛选轮胎、电瓶、玻璃等产品直接购买维修商家的产品，享受免费安装服务；\n② 您也可以直接通过“专修服务”下找到您想要的产品模块直接购买维修商家的产品，享受免费安装服务；\n③ 如果您不想去直接去商家，也可以通过“查找配件”进行搜索自己想要的维修产品直接购买与车队长平台合作的配件中心的产品，送货上门；\n如果您的爱车需要保养：\n① 您可以直接通过“快捷保养”进行服务项目选择，车队长会为您推荐与之相对应的产品或者您自己更换满意的产品，并且可享受商家的保养服务；\n② 如果您不想直接去商家，也可以通过“查找配件”进行搜索自己想要的保养产品直接购买与车队长平台合作的配件中心的产品，送货上门；",@"答：\n车队长所售商品都是正品行货，均可开具正规纸质发票，发票金额不含配送费金额，另有说明的除外。如何获得普通纸质发票：下单时需要获取发票，请选择发票一栏，填写发票抬头，发票会同您购买的商品一起给您。如果是维修商家的商品，维修商会开具发票给您。",@"答：\n① 如果未付款或已付款但还未发货，可以直接“取消订单”操作，可以通过“返修/退换”查看退款进度；\n② 如果订单已发货进入配送环节但还未收到货，可以进入""我的—订单列表—订单详情-申请退款""进行“申请退款”操作自行操作申请退款/货，或致电客服为您取消订单，可以通过“返修/退换”查看退款进度；如果已申请退货，物流配送上门时请拒收，感谢您的配合。\n③ 如果是在商家购买的商品，处于待安装的状态，也可以直接“取消订单”操作，可以通过“返修/退换”查看退款进度；",@"答：\n很抱歉，订单一旦提交后将无法修改，请您取消订单重新购买。",@"答：\n如果未发货及在商家购买的商品，会进行全额退款，如果已发货，需要您承担相应的运费。",@"答：\n如果您是直接在商家购买商品或购买商品配送到店，可以选择支付宝或微信支付两种在线支付方式；\n如果您是配送到收货地址自己签收，可以选择支付宝、微信或货到付款三种支付方式。", nil];
    }
    if ([self.status isEqual:@(3)]) {
        self.sectionDataArray=[NSArray arrayWithObjects:@"如何获取积分？",@"积分使用规则是怎样的？",@"优惠券在哪里查看？",@"优惠券可以和积分同时使用吗？", nil];
        self.rowDataArray=[NSArray arrayWithObjects:@"答：\n① 在车队长平台进行任意消费，即可获得相应积分。积分赠送额度由您所实际购买的商品决定。\n② 参加平台活动，即可获得相应积分。\n③ 在车队长平台进行维修操作可获取相应积分。\n④ 预缴保险费或购买保险可获赠相应积分。我们会在后续推出使用细则和积分换礼活动，请大家攒好积分等着我们来派送惊喜礼包。",@"答：\n您可使用原有积分进行支付购买，积分专属车队长平台，仅限车队长平台内使用。积分可以累积使用，在车队长平台购物可以100积分=1元抵扣现金（暂不支持虚拟类目）。",@"答：\n您可通过“我的”-“我的优惠券”进行查看。",@"答：\n不可以。只能选其一，并且一个订单只能用一张优惠券。", nil];
    }
    if ([self.status isEqual:@(4)]) {
        self.sectionDataArray=[NSArray arrayWithObjects:@"车队长如何保证汽车配件质量？",@"如何才能在汽车消费过程中的进行维权？",@"签收时发现商品包装破损，该如何处理？", nil];
        self.rowDataArray=[NSArray arrayWithObjects:@"答：\n车队长建设了一个相当于超市的汽车配件管理平台。第一，任何配件商家的商品进入超市必须经过车队长质检人员的严格把关。假冒产品、三无产品完全排除在超市之外；第二，车队长出货产品均经过车队长质检人员的严格把关检验；第三，配件结算费用由车队长平台代收。任何质量问题会员可以向平台投诉，情况属实平台承诺先行赔付。",@"答：\n会员遇到任何问题，可以通过以下途径进行申诉解决。\n① 向您的专职服务管家投诉；\n② 在工作时间内直接拨打平台服务电话0731-88865777。您的任何投诉意见我们将在24小时内给您回复。",@"答：\n商品签收时如包装有破损，可以直接拒收；商品签收后如发现商品本身有质量问题，可在“我的—订单列表—订单详情-申请售后”，将有专业售后人员解决。可在”返修/退换“进行查看退款进度。", nil];
    }
    
    
    
    
    
    
    
}
//电话咨询专属客服
- (IBAction)customerServiceControlClick:(id)sender {
    NSString *telNum = UserBehaviorHandler.shareInstance.getCSHotline;
    if (!telNum||[telNum isEqualToString:@""]) telNum = @"073188865777";
    [SupportingClass makeACall:telNum andContents:@"是否拨打以下客服号码" withTitle:@"你的专属客服"];
    
}

- (IBAction)butttonClick:(UIButton *)button {
    self.status=@(button.tag);
    
    [self removeAllEmbellish];
    [button setTitleColor:[UIColor colorWithHexString:@"f8af30"] forState:UIControlStateNormal];
    [button setViewBorderWithRectBorder:UIRectBorderBottom borderSize:1 withColor:[UIColor colorWithHexString:@"f8af30"] withBroderOffset:nil];
    [self statusDate];
    [self.tableView reloadData];
}

- (void)removeAllEmbellish {
    [self.buttonOne setViewBorderWithRectBorder:UIRectBorderBottom borderSize:1 withColor:nil withBroderOffset:nil];
    [self.buttonTwo setViewBorderWithRectBorder:UIRectBorderBottom borderSize:1 withColor:nil withBroderOffset:nil];
    [self.buttonThree setViewBorderWithRectBorder:UIRectBorderBottom borderSize:1 withColor:nil withBroderOffset:nil];
    [self.buttonFour setViewBorderWithRectBorder:UIRectBorderBottom borderSize:1 withColor:nil withBroderOffset:nil];
    
    [self.buttonOne setTitleColor:[UIColor colorWithHexString:@"646464"] forState:UIControlStateNormal];
    [self.buttonTwo setTitleColor:[UIColor colorWithHexString:@"646464"] forState:UIControlStateNormal];
    [self.buttonThree setTitleColor:[UIColor colorWithHexString:@"646464"] forState:UIControlStateNormal];
    [self.buttonFour setTitleColor:[UIColor colorWithHexString:@"646464"] forState:UIControlStateNormal];
  
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ident = @"CustomerServiceCell";
    CustomerServiceCell *cell = [tableView dequeueReusableCellWithIdentifier:ident forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    
    cell.answerLabel.text=self.rowDataArray[indexPath.section];
    cell.imageViewBgView.hidden=YES;
    cell.imageViewTopLayoutConstraint.constant=0;
    cell.imageViewTopLayoutConstraint.constant=-cell.answerImageView.frame.size.height;
    cell.imageViewBgViewLayoutConstraint.constant=0;
    cell.imageViewBgViewBottomLayoutConstraint.constant=0;
    if ([self.status isEqual:@(1)] ) {
        cell.imageViewBgView.hidden=NO;
        
        cell.imageViewBgView.frame=cell.imageViewBgView.frame;
        cell.imageViewTopLayoutConstraint.constant=10;
        cell.imageViewBgViewLayoutConstraint.constant=12;
        cell.imageViewBgViewBottomLayoutConstraint.constant=12;
        if (indexPath.section==0) {
            cell.answerImageView.image=[UIImage imageNamed:@"HowToChooseACarModel@3x"];
        }
        if (indexPath.section==1) {
            cell.answerImageView.image=[UIImage imageNamed:@"TireSpecifications@3x"];
            
        }
        if (indexPath.section==2) {
            cell.answerImageView.image=[UIImage imageNamed:@"Driver'slicense@3x"];
        }
    }
    if (![self.status isEqual:@(1)] ) {
        cell.imageViewBgView.hidden=YES;
        cell.imageViewTopLayoutConstraint.constant=-cell.answerImageView.frame.size.height;
        if (cell.imageViewTopLayoutConstraint.constant==0) {
            cell.imageViewTopLayoutConstraint.constant=-cell.answerImageView.frame.size.height;
        }
    }
    return cell;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 40)];
    headView.backgroundColor=CDZColorOfWhite;
    UILabel *titleLabel=[[UILabel alloc]initWithFrame:CGRectMake(12, 12, CGRectGetWidth(self.view.frame)-24, 14)];
    titleLabel.font=[UIFont systemFontOfSize:13];
    titleLabel.textColor=[UIColor colorWithHexString:@"323232" alpha:1.0];
    [headView addSubview:titleLabel];
    titleLabel.text=self.sectionDataArray[section];
    
    UIImageView *jtImageView=[[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)-24, 12, 12, 7)];
    [headView addSubview:jtImageView];
    jtImageView.image=[UIImage imageNamed:@"CustomerServiceArrow@3x"];
    
    [headView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    UIButton *button=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 40)];
    [headView addSubview:button];
    [button addTarget:self action:@selector(sectionButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [headView addSubview:button];
    button.tag=section;
    
    if (_isOpen[section] == YES)
    {
        //让imageView旋转90°
        jtImageView.transform = CGAffineTransformMakeRotation(M_PI);
    }
    else
    {
        //把图片旋转到原来的位置
        jtImageView.transform = CGAffineTransformIdentity;
    }
    
    
    
    return headView;
}

- (void)sectionButtonClick:(UIButton*)button {
    _isOpen[button.tag] = !_isOpen[button.tag];
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:button.tag];
    [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_isOpen[section] == NO) {
        return 0;
        
    }else{
        return 1;
    }
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sectionDataArray.count;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
