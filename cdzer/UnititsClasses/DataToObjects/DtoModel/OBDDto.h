//
//  OBDDto.h
//  iCars
//
//  Created by Alex on 13-12-30.
//  Copyright (c) 2013年 zciot. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FaultDto;

@interface OBDDto : NSObject

//imei设备号
@property (strong, nonatomic) NSString *imei;
//cs车速
@property (strong, nonatomic) NSString *cs;
//fdjzs发动机转速
@property (strong, nonatomic) NSString *fdjzs;
//sw水温
@property (strong, nonatomic) NSString *sw;
//dpdy电瓶电压
@property (strong, nonatomic) NSString *dpdy;
//yxzt状态0点火1熄火
@property (strong, nonatomic) NSString *yxzt;
//lc里程
@property (strong, nonatomic) NSString *lc;
//yh瞬时油耗
@property (strong, nonatomic) NSString *yh;
//fdjfh 发动机负荷
@property (strong, nonatomic) NSString *fdjfh;
//jqmkd节气门开度
@property (strong, nonatomic) NSString *jqmkd;
//bglyh百公里油耗
@property (strong, nonatomic) NSString *bglyh;
//xssj行驶时间
@property (strong, nonatomic) NSString *xssj;
// time
@property (strong, nonatomic) NSString *time;

//score
@property (strong, nonatomic) NSString *score;

// 故障列表
@property (strong, nonatomic) NSArray *faults;

@property (strong, nonatomic) NSString *fhjsz;
@property (strong, nonatomic) NSString *fdjlqywd;
@property (strong, nonatomic) NSString *jqwd;
@property (strong, nonatomic) NSString *kqll;
@property (strong, nonatomic) NSString *jqmjdwz;
@property (strong, nonatomic) NSString *kzmkdy;
@property (strong, nonatomic) NSString *hjwd;
@property (strong, nonatomic) NSString *qgdhtqj;
@property (strong, nonatomic) NSString *jqqgjdyl;
@property (strong, nonatomic) NSString *mildlhxsjl;
@property (strong, nonatomic) NSString *qcgzmnjcs;
@property (strong, nonatomic) NSString *qcgzmxsjl;
@property (strong, nonatomic) NSString *gzzsdlyzsj;
@property (strong, nonatomic) NSString *qcgzmfdjyzsj;
@property (strong, nonatomic) NSString *fdjryl;
@property (strong, nonatomic) NSString *bcpfyq;


@end
