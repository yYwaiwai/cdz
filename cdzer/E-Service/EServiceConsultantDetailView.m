//
//  EServiceConsultantDetailView.m
//  cdzer
//
//  Created by KEns0nLau on 6/13/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "EServiceConsultantDetailView.h"
#import "HCSStarRatingView.h"
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>

@interface EServiceConsultantCommentCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *dateTimeLabel;

@property (nonatomic, weak) IBOutlet UILabel *commentContentLabel;

@property (nonatomic, weak) IBOutlet HCSStarRatingView *ratingView;

@end

@implementation EServiceConsultantCommentCell


@end

@interface EServiceConsultantDetailView ()<UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource,DZNEmptyDataSetDelegate>


@property (nonatomic, strong) NSMutableArray *dataList;

@property (nonatomic, strong) NSDictionary *consultantDetail;

@property (nonatomic, weak) IBOutlet UIView *contentView;

@property (nonatomic, weak) IBOutlet UIButton *orderButton;

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, weak) IBOutlet UIImageView *consultantPortrait;

@property (nonatomic, weak) IBOutlet UILabel *consultantNameLabel;

@property (nonatomic, weak) IBOutlet UILabel *consultantWorkingNumLabel;

@property (nonatomic, weak) IBOutlet UILabel *consultantServiceNumLabel;

@property (nonatomic, weak) IBOutlet UILabel *consultantTimeLabel;

@property (nonatomic, weak) IBOutlet UILabel *consultantDistanceLabel;

@property (nonatomic, weak) IBOutlet HCSStarRatingView *consultantRatingView;

@property (nonatomic, strong) NSNumber *pageNums;

@property (nonatomic, strong) NSNumber *pageSizes;

@property (nonatomic, strong) NSNumber *totalPageSizes;

@end

@implementation EServiceConsultantDetailView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.alpha = 0;
    self.frame = UIApplication.sharedApplication.keyWindow.bounds;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.translatesAutoresizingMaskIntoConstraints = YES;
    [self addTarget:self action:@selector(dismissDetailView) forControlEvents:UIControlEventTouchUpInside];
    self.pageNums = @1;
    self.pageSizes = @10;
    self.totalPageSizes = @0;
    self.dataList = [@[] mutableCopy];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 44;
    UINib *nib = [UINib nibWithNibName:@"EServiceConsultantCommentCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"cell"];
    self.tableView.tableFooterView = UIView.new;
    
    [self.contentView setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:5.0f];
}

- (IBAction)orderSubmit{
    if(self.btnAction&&self.consultantDetail[@"real_name"]){
        self.alpha = 0;
        [self removeFromSuperview];
        self.btnAction (self.consultantID, self.consultantDetail[@"real_name"], self.consultantDetail[@"telphone"]);
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.contentView.bounds];
    self.contentView.layer.masksToBounds = NO;
    self.contentView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.contentView.layer.shadowOffset = CGSizeMake(0.0f, 5.0f);
    self.contentView.layer.shadowOpacity = 0.5f;
    self.contentView.layer.shadowPath = shadowPath.CGPath;
    
    [self.consultantPortrait setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:CGRectGetHeight(self.consultantPortrait.frame)/2.0];
    [self.orderButton setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:5.0f];
    BorderOffsetObject *offset = [BorderOffsetObject new];
    offset.rightUpperOffset = 5.0f;
    offset.rightBottomOffset = 5.0f;
    
    offset.leftUpperOffset = 5.0f;
    offset.leftBottomOffset = 5.0f;
    [self.consultantTimeLabel setViewBorderWithRectBorder:UIRectBorderLeft|UIRectBorderRight borderSize:0.5f withColor:nil withBroderOffset:offset];
}

- (void)showDetailView {
    [self getConsultantDetail];
    [UIApplication.sharedApplication.keyWindow addSubview:self];
    @weakify(self);
    [self setNeedsLayout];
    [UIView animateWithDuration:0.25 animations:^{
        @strongify(self);
        self.alpha = 1;
    }completion:^(BOOL finished) {
        @strongify(self);
        [self setNeedsLayout];
    }];
}

- (IBAction)dismissDetailView {
    @weakify(self);
    [UIView animateWithDuration:0.25 animations:^{
        @strongify(self);
        self.alpha = 0;
    } completion:^(BOOL finished) {
        @strongify(self);
        [self removeFromSuperview];
    }];
}

- (void)getConsultantDetail {
    if (!vGetUserToken||!self.consultantID||[self.consultantID isEqualToString:@""]) {
        return;
    }
    @weakify(self);
    [ProgressHUDHandler showHUD];

    
    [APIsConnection.shareConnection personalCenterAPIsGetEServiceConsultantDetailAndCommentListsWithAccessToken:vGetUserToken consultantID:self.consultantID pageNums:self.pageNums pageSizes:self.pageSizes success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        NSInteger errorCode = [[responseObject objectForKey:CDZKeyOfErrorCodeKey] integerValue];
        NSString *message = [responseObject objectForKey:CDZKeyOfMessageKey];
        NSString *sing = responseObject[@"sing"];
        NSLog(@"%@",message);
        if (![message isContainsString:@"返回成功"]||errorCode!=0){
            if ([APIsErrorHandler isTokenErrorWithResponseObject:responseObject dismissHUD:YES]) {return;};
            [ProgressHUDHandler dismissHUD];
            [SupportingClass showAlertViewWithTitle:@"alert_remind" message:message isShowImmediate:YES cancelButtonTitle:@"ok" otherButtonTitles:nil clickedButtonAtIndexWithBlock:^(NSNumber *btnIdx, UIAlertView *alertView) {}];
            return;
        }
        
        if ([sing isEqualToString:@"没有改专员"]) {
            [SupportingClass showToast:@"没有找到该专员(或者该专员没有上班)，以下是车队长为您推荐的专员！"];
        }
        
        [ProgressHUDHandler dismissHUD];
        self.consultantDetail = responseObject[CDZKeyOfResultKey];
        NSString *imgURLStr = self.consultantDetail[@"face_img"];
        self.consultantPortrait.image = nil;
        self.consultantNameLabel.text = self.consultantDetail[@"real_name"];
        self.consultantWorkingNumLabel.text = [NSString stringWithFormat:@"工号：%@",[SupportingClass verifyAndConvertDataToString:self.consultantDetail[@"staff_no"]]];
        if ([imgURLStr isContainsString:@"http"]) {
            [self.consultantPortrait setImageWithURL:[NSURL URLWithString:imgURLStr] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        }
        NSNumber *longitude = [SupportingClass verifyAndConvertDataToNumber:self.consultantDetail[@"longitude"]];
        NSNumber *latitude = [SupportingClass verifyAndConvertDataToNumber:self.consultantDetail[@"latitude"]];
        
        BMKMapPoint consultantMapPoint = BMKMapPointForCoordinate(CLLocationCoordinate2DMake(latitude.doubleValue, longitude.doubleValue));
        BMKMapPoint userMapPoint = BMKMapPointForCoordinate(self.userCurrentCoordinate);
        CLLocationDistance distance = BMKMetersBetweenMapPoints(userMapPoint, consultantMapPoint);
        
        NSNumber *driveSpeed = [SupportingClass verifyAndConvertDataToNumber:self.consultantDetail[@"speed"]];
        double time = distance/(driveSpeed.integerValue*1000/60);
        NSString *timeString = @">1";
        NSString *distanceString = @">0.01";
        if (time>=1.0) {
            timeString = [NSString stringWithFormat:@"%.02f", round(time*100)/100];
        }
        if ((distance/1000)>=0.01) {
            distanceString = [NSString stringWithFormat:@"%.02f", round((distance/1000)*100)/100];
        }
        
        NSNumber *starNum = [SupportingClass verifyAndConvertDataToNumber:self.consultantDetail[@"level_all"]];
        self.consultantRatingView.value = starNum.floatValue;
        
        NSMutableAttributedString *serviceNumText = [NSMutableAttributedString new];
        [serviceNumText appendAttributedString:[[NSAttributedString alloc]
                                                initWithString:@"服务次数\n"
                                                attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"ffffff"],
                                                             NSFontAttributeName:[UIFont systemFontOfSize:9]}]];
        [serviceNumText appendAttributedString:[[NSAttributedString alloc]
                                                initWithString:[NSString stringWithFormat:@"%@次", [SupportingClass verifyAndConvertDataToString:self.consultantDetail[@"number"]]]
                                                attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"ffffff"],
                                                             NSFontAttributeName:[UIFont systemFontOfSize:11]}]];
        self.consultantServiceNumLabel.attributedText = serviceNumText;
        
        
        NSMutableAttributedString *timeText = [NSMutableAttributedString new];
        [timeText appendAttributedString:[[NSAttributedString alloc]
                                          initWithString:@"时间\n"
                                          attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"ffffff"],
                                                       NSFontAttributeName:[UIFont systemFontOfSize:9]}]];
        [timeText appendAttributedString:[[NSAttributedString alloc]
                                          initWithString:[NSString stringWithFormat:@"%@分钟", timeString]
                                          attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"ffffff"],
                                                       NSFontAttributeName:[UIFont systemFontOfSize:11]}]];
        self.consultantTimeLabel.attributedText = timeText;
        
        
        NSMutableAttributedString *distanceText = [NSMutableAttributedString new];
        [distanceText appendAttributedString:[[NSAttributedString alloc]
                                              initWithString:@"距离\n"
                                              attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"ffffff"],
                                                           NSFontAttributeName:[UIFont systemFontOfSize:9]}]];
        [distanceText appendAttributedString:[[NSAttributedString alloc]
                                              initWithString:[NSString stringWithFormat:@"%@KM", distanceString]
                                              attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"ffffff"],
                                                           NSFontAttributeName:[UIFont systemFontOfSize:11]}]];
        self.consultantDistanceLabel.attributedText = distanceText;

        
        [self.dataList removeAllObjects];
        [self.dataList addObjectsFromArray:self.consultantDetail[@"comment_info"]];
        [self.tableView reloadData];
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
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
    }];
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *text = @"暂无更多评论记录";
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:15.0f],
                                 NSForegroundColorAttributeName: [UIColor colorWithHexString:@"646464"]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellWithIdentifier = @"cell";
    EServiceConsultantCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:cellWithIdentifier forIndexPath:indexPath];
    NSDictionary *detail = self.dataList[indexPath.row];
    cell.dateTimeLabel.text = [SupportingClass verifyAndConvertDataToString:detail[@"addtime"]];
    cell.commentContentLabel.text = [SupportingClass verifyAndConvertDataToString:detail[@"content"]];
    cell.ratingView.value = [SupportingClass verifyAndConvertDataToNumber:detail[@"level_name"]].floatValue;
    return cell;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
