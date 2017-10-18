//
//  PeripheralHighIncidenceScaleDiagramView.m
//  cdzer
//
//  Created by 车队长 on 16/12/8.
//  Copyright © 2016年 CDZER. All rights reserved.
//
#define CHARTRed          [UIColor colorWithRed:247.0 / 255.0 green:151.0 / 255.0 blue:123.0 / 255.0 alpha:1.0f]
#define CHARTOrange     [UIColor colorWithRed:255.0 / 255.0 green:195.0 / 255.0 blue:79.0 / 255.0 alpha:1.0f]
#define CHARTGreen         [UIColor colorWithRed:105.0 / 255.0 green:233.0 / 255.0 blue:204.0 / 255.0 alpha:1.0f]
#define CHARTBlue    [UIColor colorWithRed:73.0 / 255.0 green:199.0 / 255.0 blue:245.0 / 255.0 alpha:1.0f]

#import "PeripheralHighIncidenceScaleDiagramView.h"
#import "UIView+LayoutConstraintHelper.h"
#import "PNChart.h"
#import <GPXParser/GPXParser.h>



@interface PeripheralHighIncidenceScaleDiagramView ()

@property (nonatomic, strong) NSArray *constraints;

@property (nonatomic, strong) NSMutableArray *chartList;

@property (nonatomic, strong) NSMutableArray *percentArr;

@end

@implementation PeripheralHighIncidenceScaleDiagramView

- (void)dealloc {
    NSLog(@"Passing Dealloc At %@", NSStringFromClass([self class]));
}

- (void)awakeFromNib {
    [super awakeFromNib];
    NSLog(@"%@", NSStringFromCGRect(self.frame));

}


-(void)upDataWithPercent:(NSDictionary*)dataResult{
    if (dataResult!=nil) {
        
    
    self.chartList = [@[] mutableCopy];
    self.percentArr=[@[] mutableCopy];
    NSArray *tmpList = dataResult[@"listMap"];
    if (dataResult[@"list_info"]&&[dataResult[@"list_info"] count]>0) {
        tmpList = dataResult[@"list_info"];
    }
        NSMutableArray *colorList = [@[CHARTRed, CHARTOrange, CHARTGreen, CHARTBlue, PNGreen, PNBrown, PNWeiboColor,
                                                   PNBlack, PNPinkGrey, PNMauve, PNTitleColor, PNTwitterColor] mutableCopy];
     @weakify(self);
        [tmpList enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull detail, NSUInteger idx, BOOL * _Nonnull stop) {
           @strongify(self);
            [self.percentArr addObject:detail];
         NSNumber *value = [SupportingClass verifyAndConvertDataToNumber:detail[@"percent"]];
         UIColor *color = nil;
         
        if (idx+1>colorList.count) {
              NSUInteger randomNum = (arc4random() % colorList.count);
              color = colorList[randomNum];
         }else {
               color = colorList[idx];
        }
          PNPieChartDataItem *object = [PNPieChartDataItem dataItemWithValue:value.floatValue color:color description:detail[@"name"]];
          [self.chartList addObject:object];
            
            
                        }];
    
    
    CGFloat chartOffsetX = (CGRectGetWidth(self.chartView.frame)-CGRectGetWidth(self.chartView.frame)*0.5)/2;
    CGFloat chartOffsetY = (CGRectGetHeight(self.frame)-CGRectGetHeight(self.chartView.frame)*0.5)/2;
    CGPoint center=self.chartView.center;
    center.x=self.chartView.frame.size.width/2;
    center.y=self.chartView.frame.size.height/2;
    self.chartView.center=center;
    
    PNPieChart *pieChart = [[PNPieChart alloc] initWithFrame:CGRectMake(chartOffsetX , chartOffsetY, CGRectGetWidth(self.chartView.frame)*0.5, CGRectGetWidth(self.chartView.frame)*0.5) items:_chartList];
    pieChart.center=center;
    pieChart.descriptionTextColor = [UIColor whiteColor];
    pieChart.descriptionTextFont  = [UIFont fontWithName:@"Avenir-Medium" size:0.0];
    [pieChart strokeChart];
    [self.chartView addSubview:pieChart];
    if (self.percentArr.count==1) {
        self.view2.hidden=YES;
        self.illegallyParkedLabel.hidden=YES;
        self.label2.hidden=YES;
        self.view3.hidden=YES;
        self.speedingLabel.hidden=YES;
        self.view4.hidden=YES;
        self.label3.hidden=YES;
        self.othersLabel.hidden=YES;
        self.label4.hidden=YES;
    }if (self.percentArr.count==2) {
        
        self.view2.hidden=NO;
        self.illegallyParkedLabel.hidden=NO;
        self.label2.hidden=NO;
        
        self.view3.hidden=YES;
        self.speedingLabel.hidden=YES;
        self.label3.hidden=YES;
        self.view4.hidden=YES;
        self.othersLabel.hidden=YES;
        self.label4.hidden=YES;
    }if (self.percentArr.count==3) {
        
        self.view2.hidden=NO;
        self.illegallyParkedLabel.hidden=NO;
        self.label2.hidden=NO;
        self.view3.hidden=NO;
        self.speedingLabel.hidden=NO;
        self.view4.hidden=NO;
        
        self.view4.hidden=YES;
        self.othersLabel.hidden=YES;
        self.label4.hidden=YES;
    }
    
    [self.percentArr enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull detail, NSUInteger idx, BOOL * _Nonnull stop) {
        @strongify(self);
        if (idx==0) {
            self.violationOfMarkLabel.text=[NSString stringWithFormat:@"%@%%",detail[@"percent"]];
            self.label1.text=[NSString stringWithFormat:@"%@",detail[@"name"]];
        }if (idx==1) {
            self.illegallyParkedLabel.text=[NSString stringWithFormat:@"%@%%",detail[@"percent"]];
            self.label2.text=[NSString stringWithFormat:@"%@",detail[@"name"]];
        }
        if (idx==2) {
            self.speedingLabel.text=[NSString stringWithFormat:@"%@%%",detail[@"percent"]];
            self.label3.text=[NSString stringWithFormat:@"%@",detail[@"name"]];
        }if (idx==3) {
            self.othersLabel.text=[NSString stringWithFormat:@"%@%%",detail[@"percent"]];
            self.label4.text=[NSString stringWithFormat:@"%@",detail[@"name"]];
        }
        
        
    }];
    }else{
        return;
    }
    
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
