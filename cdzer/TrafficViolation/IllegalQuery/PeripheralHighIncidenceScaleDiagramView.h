//
//  PeripheralHighIncidenceScaleDiagramView.h
//  cdzer
//
//  Created by 车队长 on 16/12/8.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PeripheralHighIncidenceScaleDiagramView : UIView

@property (weak, nonatomic) IBOutlet UIView *peripheralHighIncidenceScaleDiagramView;


@property (weak, nonatomic) IBOutlet UIView *chartView;


@property (weak, nonatomic) IBOutlet UILabel *label1;

@property (weak, nonatomic) IBOutlet UILabel *label2;

@property (weak, nonatomic) IBOutlet UILabel *label3;

@property (weak, nonatomic) IBOutlet UILabel *label4;

@property (weak, nonatomic) IBOutlet UIView *view1;

@property (weak, nonatomic) IBOutlet UIView *view2;

@property (weak, nonatomic) IBOutlet UIView *view3;

@property (weak, nonatomic) IBOutlet UIView *view4;



@property (weak, nonatomic) IBOutlet UILabel *violationOfMarkLabel;//违反标志

@property (weak, nonatomic) IBOutlet UILabel *illegallyParkedLabel;//违停

@property (weak, nonatomic) IBOutlet UILabel *speedingLabel;//超速

@property (weak, nonatomic) IBOutlet UILabel *othersLabel;//其他

-(void)upDataWithPercent:(NSDictionary*)dataResult;

@end
