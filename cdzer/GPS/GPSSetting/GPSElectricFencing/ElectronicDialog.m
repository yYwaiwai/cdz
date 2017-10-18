//
//  ElectronicDialog.m
//  iCars
//
//  Created by xuhu on 14-10-9.
//  Copyright (c) 2014年 zciot. All rights reserved.
//

#import "ElectronicDialog.h"

@implementation ElectronicDialog

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    self.dialogView.clipsToBounds = YES ;
    self.dialogView.layer.cornerRadius = 8 ;
    self.disImg.image = [ImageHandler getImageScale:@"c_edit.png"];
    self.inBtn.selected = YES ;
    self.element = [[EnectronicElement alloc] init];
    self.element.type = @"in";
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.translatesAutoresizingMaskIntoConstraints = YES;
}

#pragma mark -按钮事件的点击方法
-(IBAction)clickEvent:(id)sender{
    UIButton *btn = (UIButton *)sender ;
    NSInteger tagValue = btn.tag ;
    if(tagValue == 10){
        NSString *distance = self.distanceTf.text ;
        self.element.radius = distance ;
        [self.delegate dialogViewSubmit:self.element];
    }else{
        [self.delegate dialogViewCancel];
    }
    [self removeFromSuperview];
}

#pragma mark -设置电子围栏数据方法
- (void)setScopeData:(NSString *) lan AndLon:(NSString *) lon{
    self.lonLa.text = [NSString stringWithFormat:@"经度    %@",lon] ;
    self.lanLa.text = [NSString stringWithFormat:@"纬度    %@",lan] ;
    self.element.longitude = lon ;
    self.element.latitude = lan ;
    self.distanceTf.text = @"1";
}


#pragma mark -电子围栏类型设置
-(IBAction)clickTypeEvent:(id)sender {
    UIButton *btn = (UIButton *)sender ;
    NSInteger tagValue = btn.tag ;
    if(tagValue == 12){
        self.inBtn.selected = YES;
        self.outBtn.selected = !self.inBtn ;
        self.element.type = @"in";
    }else{
        self.outBtn.selected = YES;
        self.inBtn.selected = !self.outBtn ;
        self.element.type = @"out";
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
