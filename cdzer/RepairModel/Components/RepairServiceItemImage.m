//
//  RepairServiceItemImage.m
//  cdzer
//
//  Created by KEns0nLau on 9/19/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "RepairServiceItemImage.h"

@implementation RepairServiceItemImage

+ (UIImage *)specRepairIcon:(NSString *)specRepairName wasSelected:(BOOL)selected {
    UIImage *image = nil;
    NSString *imageName = nil;
    if ([specRepairName isEqualToString:@"普通维修"]) {
        imageName = @"normail_repair_icon_%@@3x";
    }else if ([specRepairName isEqualToString:@"常规保养"]) {
        imageName = @"routine_maintenance_icon_%@@3x";
    }else if ([specRepairName isEqualToString:@"深度保养"]) {
        imageName = @"deep_maintenance_icon_%@@3x";
    }else if ([specRepairName isEqualToString:@"事故车"]) {
        imageName = @"accident_car_icon_%@@3x";
    }else if ([specRepairName isEqualToString:@"钣金喷漆"]) {
        imageName = @"skin_patch_n_painting_%@@3x";
    }else if ([specRepairName isEqualToString:@"轮胎"]) {
        imageName = @"wheel_icon_%@@3x";
    }else if ([specRepairName isEqualToString:@"空调"]) {
        imageName = @"air_conditioning_icon_%@@3x";
    }else if ([specRepairName isEqualToString:@"玻璃"]) {
        imageName = @"windshield_icon_%@@3x";
    }else if ([specRepairName isEqualToString:@"四轮定位"]) {
        imageName = @"4_wheel_adjustment_icon_%@@3x";
    }else if ([specRepairName isEqualToString:@"自动变速器"]) {
        imageName = @"gear_box_icon_%@@3x";
    }else if ([specRepairName isEqualToString:@"电瓶"]) {
        imageName = @"battery_icon_%@@3x";
    }
    
    if (imageName&&![imageName isEqualToString:@""]) {
        image = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:[NSString stringWithFormat:imageName, (selected?@"selected":@"deselected")] ofType:@"png"]];
    }
    return image;
}

@end
