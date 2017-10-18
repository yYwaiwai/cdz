//
//  ElectronicDialog.h
//  iCars
//
//  Created by xuhu on 14-10-9.
//  Copyright (c) 2014年 zciot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EnectronicElement.h"

#pragma mark 对话弹出视图的触发协议
@protocol DialogViewDelegate <NSObject>

/*
 * 确定添加电子围栏的方法
 */
- (void)dialogViewSubmit:(EnectronicElement *) element ;

/*
 * 取消电子围栏的设置
 */
- (void)dialogViewCancel ;

@end

@interface ElectronicDialog : UIView

@property (strong ,nonatomic) IBOutlet UIView *dialogView ;
@property (strong ,nonatomic) id<DialogViewDelegate> delegate ;
@property (strong ,nonatomic) IBOutlet UITextField *distanceTf ;
@property (strong ,nonatomic) IBOutlet UIImageView *disImg ;
@property (strong ,nonatomic) IBOutlet UILabel *lanLa ;
@property (strong ,nonatomic) IBOutlet UILabel *lonLa ;
@property (strong ,nonatomic) IBOutlet UIButton *inBtn ;
@property (strong ,nonatomic) IBOutlet UIButton *outBtn ;
@property (strong ,nonatomic) EnectronicElement *element ;

#pragma mark -按钮事件的点击方法
-(IBAction)clickEvent:(id)sender ;

#pragma mark -设置电子围栏数据方法
- (void)setScopeData:(NSString *) lan AndLon:(NSString *) lon ;

#pragma mark -电子围栏类型设置
-(IBAction)clickTypeEvent:(id)sender ;

@end
