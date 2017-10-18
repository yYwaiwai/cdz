//
//  SelfInspectVC.m
//  cdzer
//
//  Created by KEns0n on 16/4/5.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "SelfInspectVC.h"
#import "SelfInspectSuggestionVC.h"
#import "UserSelectedAutosInfoDTO.h"
#import <BEMCheckBox/BEMCheckBox.h>

@interface SelfInspectCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *stepLabel;

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;

@end

@implementation SelfInspectCell


@end

@interface SelfInspectVC () <BEMCheckBoxDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, weak) IBOutlet UIView *tableHeaderView;

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;

@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;

@property (nonatomic, weak) IBOutlet UILabel *questionLabel;

@property (nonatomic, weak) IBOutlet UILabel *displayLabelView;

@property (nonatomic, weak) IBOutlet UIView *displayBarView;

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
    NSLog(@"%@", _repairGuideDetail);
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
    [self.nextStepBtn setViewBorderWithRectBorder:UIRectBorderLeft borderSize:0.5f withColor:nil withBroderOffset:nil];
    [self.reDiagnosisBtn setViewBorderWithRectBorder:UIRectBorderRight borderSize:0.5f withColor:nil withBroderOffset:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.nextStepBtn setViewBorderWithRectBorder:UIRectBorderLeft borderSize:0.5f withColor:nil withBroderOffset:nil];
    [self.reDiagnosisBtn setViewBorderWithRectBorder:UIRectBorderRight borderSize:0.5f withColor:nil withBroderOffset:nil];
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
        [self.displayLabelView setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:CGRectGetHeight(self.displayLabelView.frame)/2.0f];
        [self.displayBarView setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:CGRectGetHeight(self.displayBarView.frame)/2.0f];
        
        if (description&&![description isEqualToString:@""]) {
            CGRect frame = self.tableView.tableHeaderView.frame;
            frame.size.height += [SupportingClass getStringSizeWithString:description font:_descriptionLabel.font widthOfView:CGSizeMake(SCREEN_WIDTH, CGFLOAT_MAX)].height;
            self.tableView.tableHeaderView.frame = frame;
        }
        [self.tableHeaderView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
        
        [self.tableView reloadData];
        
        UINib *nib = [UINib nibWithNibName:@"SelfInspectCell" bundle:nil];
        [self.tableView registerNib:nib forCellReuseIdentifier:@"SelfInspectCell"];
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
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)restartDiagnosisProcedure {
    
    [NSNotificationCenter.defaultCenter postNotificationName:CDZNotiKeyOfSDVCResetSelection object:nil];
    [self.navigationController popViewControllerAnimated:YES];
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
    if (!autoData.modelID||!autoData.seriesID||!_procedureDetailID||[_procedureDetailID isEqualToString:@""]) {
        NSLog(@"Missing Parameters");
        return;
    }
        
    [ProgressHUDHandler showHUD];
    @weakify(self);
    [APIsConnection.shareConnection repairGuideAPIsGetRepairStepGuideFinalResultWithProcedureDetailID:_procedureDetailID seriesID:autoData.seriesID autoModelID:autoData.modelID success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
        
        SelfInspectSuggestionVC *vc = [SelfInspectSuggestionVC new];
        vc.detail = responseObject[CDZKeyOfResultKey];
        vc.title = @"维修建议";
        vc.procedureDetailID = self.procedureDetailID;
        vc.titleName = self.titleName;
        vc.stepTitle = self.repairGuideDetail[@"name"];
        [self setNavBarBackButtonTitleOrImage:nil titleColor:nil];
        [self.navigationController pushViewController:vc animated:YES];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
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
