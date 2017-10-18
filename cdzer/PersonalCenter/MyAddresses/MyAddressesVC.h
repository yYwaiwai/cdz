//
//  MyAddressesVC.h
//  cdzer
//
//  Created by 车队长 on 16/9/9.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "XIBBaseViewController.h"
#import "AddressDTO.h"

typedef void(^MyAddressSelectedResultBlock)(AddressDTO *selectedDTO);

@interface MyAddressesVC : XIBBaseViewController

@property (nonatomic, assign) BOOL isForSelection;

@property (nonatomic, strong) AddressDTO *selectedDTO;

@property (nonatomic, copy) MyAddressSelectedResultBlock resultBlock;

@end
