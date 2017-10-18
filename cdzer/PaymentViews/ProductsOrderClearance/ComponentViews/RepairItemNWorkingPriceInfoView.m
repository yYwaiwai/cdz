//
//  RepairItemNWorkingPriceInfoView.m
//  cdzer
//
//  Created by KEns0nLau on 9/30/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "RepairItemNWorkingPriceInfoView.h"
#import "CDZOPCObjectComponents.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>

@interface PINWPInfoViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *leftInfoLabel;

@property (weak, nonatomic) IBOutlet UILabel *centerInfoLabel;

@property (weak, nonatomic) IBOutlet UILabel *rightInfoLabel;

@end

@implementation PINWPInfoViewCell

@end


@interface RepairItemNWorkingPriceInfoView()<UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property (strong, nonatomic) NSArray *wxItemInfoList;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *wxItemTitleViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *wxItemTableViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *wxItemTotalInfoTopConstraint;
@property (weak, nonatomic) IBOutlet UITableView *wxItemTableView;
@property (weak, nonatomic) IBOutlet UILabel *totalWorkingHourCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *wxItemTotalPriceLabel;

@property (strong, nonatomic) NSArray *partsInfoList;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *partsListTitleViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *partsListTableViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *partsListTotalInfoTopConstraint;
@property (weak, nonatomic) IBOutlet UITableView *partsListTableView;
@property (weak, nonatomic) IBOutlet UILabel *totalPartsListCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *partsListTotalPriceLabel;


@property (weak, nonatomic) IBOutlet UISwitch *invoiceSwitch;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *payeeNameViewTopConstraint;
@property (weak, nonatomic) IBOutlet UITextField *payeeNameTF;
@property (weak, nonatomic) IBOutlet UIView *payeeNameContainerView;

@end

@implementation RepairItemNWorkingPriceInfoView

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [[[self.wxItemTableView.superview viewWithTag:1] viewWithTag:10] setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    [[[self.partsListTableView.superview viewWithTag:1] viewWithTag:10] setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    
    [[self.wxItemTableView.superview viewWithTag:1] setViewBorderWithRectBorder:UIRectBorderTop borderSize:0.5 withColor:nil withBroderOffset:nil];
    [[self.partsListTableView.superview viewWithTag:1] setViewBorderWithRectBorder:UIRectBorderTop borderSize:0.5 withColor:nil withBroderOffset:nil];
    
    [[self.wxItemTableView.superview viewWithTag:3] setViewBorderWithRectBorder:UIRectBorderBottom|UIRectBorderTop borderSize:0.5 withColor:nil withBroderOffset:nil];
    [[self.partsListTableView.superview viewWithTag:3] setViewBorderWithRectBorder:UIRectBorderBottom|UIRectBorderTop borderSize:0.5 withColor:nil withBroderOffset:nil];
    
    [self.invoiceSwitch.superview setViewBorderWithRectBorder:UIRectBorderTop|UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    [self.payeeNameContainerView setViewBorderWithRectBorder:UIRectBorderBottom borderSize:0.5 withColor:nil withBroderOffset:nil];
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.translatesAutoresizingMaskIntoConstraints = NO;
    UINib *nib = [UINib nibWithNibName:@"PINWPInfoViewCell" bundle:nil];
    self.wxItemTableView.rowHeight = UITableViewAutomaticDimension;
    self.wxItemTableView.estimatedRowHeight = 100;
    [self.wxItemTableView registerNib:nib forCellReuseIdentifier:CDZKeyOfCellIdentKey];
    self.partsListTableView.rowHeight = UITableViewAutomaticDimension;
    self.partsListTableView.estimatedRowHeight = 100;
    [self.partsListTableView registerNib:nib forCellReuseIdentifier:CDZKeyOfCellIdentKey];
    
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(textFieldTextDidChange:) name:UITextFieldTextDidChangeNotification object:self.payeeNameTF];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillAppear:) name:UIKeyboardWillShowNotification object:nil];
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.frame), 44.0f)];
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
    self.payeeNameTF.inputAccessoryView = toolbar;
    
    
    [self setReactiveRules];
}

- (void)setReactiveRules {
    @weakify(self);
    [RACObserve(self, wxItemTableView.contentSize) subscribeNext:^(id size) {
        @strongify(self);
        CGSize contentSize = [size CGSizeValue];
        BOOL isDataEmpty = (self.wxItemInfoList.count==0);
        self.wxItemTableViewHeightConstraint.constant = isDataEmpty?44.0f:contentSize.height;
        UIRectBorder border = isDataEmpty?UIRectBorderBottom:UIRectBorderNone;
        [self.wxItemTableView setViewBorderWithRectBorder:border borderSize:0.5 withColor:nil withBroderOffset:nil];
    }];
    
    [RACObserve(self, partsListTableView.contentSize) subscribeNext:^(id size) {
        @strongify(self);
        CGSize contentSize = [size CGSizeValue];
        BOOL isDataEmpty = (self.partsInfoList.count==0);
        self.partsListTableViewHeightConstraint.constant = isDataEmpty?44.0f:contentSize.height;
        UIRectBorder border = isDataEmpty?UIRectBorderBottom:UIRectBorderNone;
        [self.partsListTableView setViewBorderWithRectBorder:border borderSize:0.5 withColor:nil withBroderOffset:nil];
    }];
    
}

- (void)setPayeeNameString:(NSString *)payeeNameString {
    _payeeNameString = payeeNameString;
}

- (void)setIsNeedInvoice:(BOOL)isNeedInvoice {
    _isNeedInvoice = isNeedInvoice;
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *text = @"该订单不含维修项目信息！";
    if (self.partsListTableView==scrollView) {
        text = @"该订单不含维修材料信息！";
    }
        
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:15.0f],
                                 NSForegroundColorAttributeName:[UIColor colorWithHexString:@"646464"]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PINWPInfoViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CDZKeyOfCellIdentKey forIndexPath:indexPath];
    if (self.partsListTableView==tableView) {
        NSDictionary *detail = self.partsInfoList[indexPath.row];
        cell.leftInfoLabel.text = detail[@"name"];
        cell.centerInfoLabel.text = [NSString stringWithFormat:@"x%@", [SupportingClass verifyAndConvertDataToString:detail[@"num"]]];
        cell.rightInfoLabel.text = [NSString stringWithFormat:@"¥%0.02f", [SupportingClass verifyAndConvertDataToString:detail[@"price"]].floatValue];
    }else if (self.wxItemTableView==tableView){
        NSDictionary *detail = self.wxItemInfoList[indexPath.row];
        cell.leftInfoLabel.text = detail[@"name"];
        cell.centerInfoLabel.text = [NSString stringWithFormat:@"x%@", [SupportingClass verifyAndConvertDataToString:detail[@"hour"]]];
        cell.rightInfoLabel.text = [NSString stringWithFormat:@"¥%0.02f", [SupportingClass verifyAndConvertDataToString:detail[@"price"]].floatValue];
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.partsListTableView==tableView) {
        return self.partsInfoList.count;
    }
    return self.wxItemInfoList.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
  
}

- (void)updateUIData:(NSDictionary *)sourceData {
    self.wxItemInfoList = sourceData[@"repair_item"];
    self.partsInfoList = sourceData[@"repair_materials"];
    
    BOOL isWXDataEmpty = (self.wxItemInfoList.count==0);
    UIView *wxItemTitleView = [self.wxItemTableView.superview viewWithTag:2];
    UIView *wxItemInfoVIew = [self.wxItemTableView.superview viewWithTag:3];
    wxItemTitleView.hidden = isWXDataEmpty;
    wxItemInfoVIew.hidden = isWXDataEmpty;
    self.wxItemTitleViewBottomConstraint.constant = isWXDataEmpty?-CGRectGetHeight(wxItemTitleView.frame):0;
    self.wxItemTotalInfoTopConstraint.constant = isWXDataEmpty?-CGRectGetHeight(wxItemInfoVIew.frame):0;
    
    BOOL isPLDataEmpty = (self.partsInfoList.count==0);
    UIView *partsListTitleView = [self.partsListTableView.superview viewWithTag:2];
    UIView *partsListInfoVIew = [self.partsListTableView.superview viewWithTag:3];
    partsListTitleView.hidden = isPLDataEmpty;
    partsListInfoVIew.hidden = isPLDataEmpty;
    self.partsListTitleViewBottomConstraint.constant = isPLDataEmpty?-CGRectGetHeight(partsListTitleView.frame):0;
    self.partsListTotalInfoTopConstraint.constant = isPLDataEmpty?-CGRectGetHeight(partsListInfoVIew.frame):0;
    
    
    [self.wxItemTableView reloadData];
    [self.partsListTableView reloadData];
    
    self.totalWorkingHourCountLabel.text = [SupportingClass verifyAndConvertDataToString:sourceData[@"work_hour"]];
    self.wxItemTotalPriceLabel.text = [NSString stringWithFormat:@"%0.02f", [SupportingClass verifyAndConvertDataToString:sourceData[@"work_price"]].floatValue];
    self.totalPartsListCountLabel.text = [SupportingClass verifyAndConvertDataToString:sourceData[@"product_num"]];
    self.partsListTotalPriceLabel.text = [NSString stringWithFormat:@"%0.02f", [SupportingClass verifyAndConvertDataToString:sourceData[@"product_price"]].floatValue];
}

- (IBAction)showPayeeNameTF:(UISwitch *)theSwitch {
    self.isNeedInvoice = theSwitch.on;
    self.payeeNameViewTopConstraint.constant = (theSwitch.on?0:-(CGRectGetHeight(self.payeeNameContainerView.frame)));
    self.payeeNameContainerView.hidden = !theSwitch.on;
}

- (void)hiddenKeyboard {
    [self.payeeNameTF resignFirstResponder];
}

- (void)keyboardWillAppear:(NSNotification *)notiObj {
    if ([self.payeeNameTF isFirstResponder]) {
        NSMutableDictionary *userInfo = [notiObj.userInfo mutableCopy];
        userInfo[@"tf"] = self.payeeNameTF;
        [NSNotificationCenter.defaultCenter postNotificationName:PISCTextViewAdjustPositionNotification object:nil userInfo:userInfo];
    }
}

- (void)textFieldTextDidChange:(NSNotification *)notiObj {
    NSUInteger maxLenght = 8;
    UITextField *textField = (UITextField *)notiObj.object;
    NSString *toBeString = textField.text;
    NSString *lang = [[textField textInputMode] primaryLanguage];
    if ([lang isContainsString:@"zh-Hans"]) {
        UITextRange *selectedRange = [textField markedTextRange];
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        if (!position) {
            if (toBeString.length>maxLenght) {
                textField.text = [toBeString substringToIndex:maxLenght];
            }
        }else {
            
        }
    }else {
        if (toBeString.length>maxLenght) {
            textField.text = [toBeString substringToIndex:maxLenght];
        }
    }
    if (textField==self.payeeNameTF) {
        self.payeeNameString = textField.text;
    }
}


@end
