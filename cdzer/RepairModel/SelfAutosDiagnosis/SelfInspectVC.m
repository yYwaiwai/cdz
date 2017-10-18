//
//  SelfInspectVC.m
//  cdzer
//
//  Created by KEns0n on 16/4/5.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "SelfInspectVC.h"
#import "UserSelectedAutosInfoDTO.h"
#import <BEMCheckBox/BEMCheckBox.h>
#import "SelfDiagnosisModuleVC.h"
#import "MaintenanceSuggestionVC.h"

@interface SelfInspectCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *stepLabel;

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;

@end

@implementation SelfInspectCell


@end

@interface SelfInspectVC () <BEMCheckBoxDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, strong) IBOutlet UIView *tableHeaderView;

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;

@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;

@property (nonatomic, weak) IBOutlet UILabel *questionLabel;

@property (nonatomic, weak) IBOutlet UIButton *reDiagnosisBtn;

@property (nonatomic, weak) IBOutlet UIButton *nextStepBtn;

@property (nonatomic, weak) IBOutlet UIView *leftCheckBoxContainer;

@property (nonatomic, weak) IBOutlet UIView *rightCheckBoxContainer;

@property (nonatomic, strong) BEMCheckBox *leftCheckBox;

@property (nonatomic, strong) BEMCheckBox *rightCheckBox;

@property (nonatomic, strong) NSArray *dataList;

@end

@implementation SelfInspectVC

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

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self.tableHeaderView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    
    [self.questionLabel.superview setViewBorderWithRectBorder:UIRectBorderTop|UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    
    [self.nextStepBtn setViewBorderWithRectBorder:UIRectBorderLeft borderSize:0.5f withColor:nil withBroderOffset:nil];
    
    [self.nextStepBtn.superview setViewBorderWithRectBorder:UIRectBorderTop borderSize:0.5 withColor:nil withBroderOffset:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)setReactiveRules {
    @autoreleasepool {
        
    }
    
}

- (void)componentSetting {
    @autoreleasepool {
        NSString *title = _repairGuideDetail[@"name"];
        NSString *description = _repairGuideDetail[@"des"];
        NSString *question = _repairGuideDetail[@"problem"];
        question = [[question stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        self.dataList = _repairGuideDetail[@"slist"];
        
        self.questionLabel.text = question;
        self.titleLabel.text = title;
        self.descriptionLabel.text = description;
        if (self.descriptionLabel.text&&![self.descriptionLabel.text isEqualToString:@""]) {
            CGRect frame = self.tableView.tableHeaderView.bounds;
            frame.size.height = [SupportingClass getStringSizeWithString:self.descriptionLabel.text font:_descriptionLabel.font widthOfView:CGSizeMake(SCREEN_WIDTH-24, CGFLOAT_MAX)].height+58;
            self.tableView.tableHeaderView.bounds = frame;
        }
        
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 100;
        UINib *nib = [UINib nibWithNibName:@"SelfInspectCell" bundle:nil];
        [self.tableView registerNib:nib forCellReuseIdentifier:@"SelfInspectCell"];
        [self.tableView reloadData];
    }
}

- (void)initializationUI {
    @autoreleasepool {
        self.leftCheckBox = [[BEMCheckBox alloc] initWithFrame:self.leftCheckBoxContainer.bounds];
        _leftCheckBox.on = YES;
        _leftCheckBox.boxType = BEMBoxTypeCircle;
        _leftCheckBox.animationDuration = 0.1f;
        _leftCheckBox.onAnimationType = BEMAnimationTypeFill;
        _leftCheckBox.offAnimationType = BEMAnimationTypeFill;
        _leftCheckBox.delegate = self;
        [self.leftCheckBoxContainer addSubview:_leftCheckBox];
        
        self.rightCheckBox = [[BEMCheckBox alloc] initWithFrame:self.rightCheckBoxContainer.bounds];
        _rightCheckBox.boxType = _leftCheckBox.boxType;
        _rightCheckBox.animationDuration = _leftCheckBox.animationDuration;
        _rightCheckBox.onAnimationType = _leftCheckBox.onAnimationType;
        _rightCheckBox.offAnimationType = _leftCheckBox.offAnimationType;
        _rightCheckBox.delegate = self;
        [self.rightCheckBoxContainer addSubview:_rightCheckBox];
    }
}

- (void)didTapCheckBox:(BEMCheckBox *)checkBox {
    if (_leftCheckBox==checkBox) {
        _leftCheckBox.on = YES;
        [_rightCheckBox setOn:NO animated:YES];
    }
    if (_rightCheckBox==checkBox) {
        _rightCheckBox.on = YES;
        [_leftCheckBox setOn:NO animated:YES];
    }
}

- (IBAction)nextStepAction {
    if (!_rightCheckBox.on&&_leftCheckBox.on) {
        [self getInspectSuggestionResult];
    }else {
        [self restartDiagnosisProcedure];
    }
}

- (IBAction)restartDiagnosisProcedure {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.class == %@", SelfDiagnosisModuleVC.class];
    NSArray *result = [self.navigationController.viewControllers filteredArrayUsingPredicate:predicate];
    if (result&&result.count>0) {
        [self.navigationController popToViewController:result.firstObject animated:YES];
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
    
    static NSString *ident = @"SelfInspectCell";
    SelfInspectCell *cell = [tableView dequeueReusableCellWithIdentifier:ident forIndexPath:indexPath];
    [cell.stepLabel setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:CGRectGetWidth(cell.stepLabel.frame)/2.0f];
    cell.titleLabel.text = nil;
    cell.titleLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfMedium, 15, NO);
    cell.titleLabel.attributedText = nil;
    NSDictionary *detail = _dataList[indexPath.row];
    NSString *title = detail[@"des"];
    cell.titleLabel.text = title;
    NSString *step = detail[@"step"];
    cell.stepLabel.text = step;
    [cell updateConstraintsIfNeeded];
    
    return cell;
}

- (void)getInspectSuggestionResult {
    UserSelectedAutosInfoDTO *autoData = [[DBHandler shareInstance] getSelectedAutoData];
    if (!autoData.modelID||!autoData.seriesID||
        !_procedureDetailID||[_procedureDetailID isEqualToString:@""]||
        !self.titleName||[self.titleName isEqualToString:@""]) {
        NSLog(@"Missing Parameters");
        return;
    }
        
    [ProgressHUDHandler showHUD];
    @weakify(self);
    [APIsConnection.shareConnection repairGuideAPIsGetRepairStepGuideFinalResultWithProcedureDetailID:_procedureDetailID seriesID:autoData.seriesID autoModelID:autoData.modelID repairName:self.titleName success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSLog(@"%@",message);
        [ProgressHUDHandler dismissHUD];
        if (errorCode!=0&&![message isEqualToString:@"返回成功"]) {
            [ProgressHUDHandler dismissHUD];
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
            return;
        }
        
        MaintenanceSuggestionVC *vc = [MaintenanceSuggestionVC new];
        vc.procedureDetailID = self.procedureDetailID;
        vc.titleName = self.titleName;
        vc.resultData = responseObject[CDZKeyOfResultKey];
        vc.repairItem = self.repairItem;

        [self setDefaultNavBackButtonWithoutTitle];
        [self.navigationController pushViewController:vc animated:YES];
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        NSLog(@"%@",error);
        [ProgressHUDHandler showError];
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
        return;
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
