//
//  SelfDiagnosisModuleBottomView.h
//  cdzer
//
//  Created by KEns0n on 08/11/2016.
//  Copyright © 2016 CDZER. All rights reserved.
//
typedef void(^SDMBVDidSelectItemReponseBlock)(NSIndexPath *indexPath);
#import <UIKit/UIKit.h>
@interface SelfDiagnosisModuleBottomView : UIView

@property (nonatomic, strong) NSArray *dataSources;

@property (nonatomic, copy) SDMBVDidSelectItemReponseBlock reponseBlock;

- (void)reloadCollectionView;

@end
