//
//  SelectedAutosDispalyView.m
//  cdzer
//
//  Created by KEns0n on 3/3/15.
//  Copyright (c) 2015 CDZER. All rights reserved.
//

#define vStandardHeight 50.0f
#import "SelectedAutosDispalyView.h"
#import "InsetsLabel.h"
#import "UserSelectedAutosInfoDTO.h"

@interface SelectedAutosDispalyView ()

@property (nonatomic, strong) InsetsLabel *carDescription;

@end

@implementation SelectedAutosDispalyView

- (instancetype)initWithFrame:(CGRect)frame {
    if (frame.size.height<vStandardHeight) {
        frame.size.height = vStandardHeight;
    }
    self = [super initWithFrame:frame];
    if (self) {
        [self initializationUI];
    }
    return self;
}

- (void)initializationUI {
    @autoreleasepool {
        [self setBackgroundColor:[UIColor colorWithRed:0.933f green:0.933f blue:0.933f alpha:1.00f]];
        [self setBorderWithColor:[UIColor colorWithRed:0.882f green:0.882f blue:0.882f alpha:1.00f] borderWidth:1.0f];
        
        CGFloat offset = 8.0f;
        self.carDescription = [[InsetsLabel alloc] initWithFrame:CGRectMake(offset, offset,
                                                                            CGRectGetWidth(self.frame)-offset*2.0f,
                                                                            CGRectGetHeight(self.frame)-offset*2.0f)
                                                       andEdgeInsetsValue:UIEdgeInsetsMake(4.0f, 6.0f, 4.0f, 6.0f)];
        _carDescription.textAlignment = NSTextAlignmentCenter;
        _carDescription.text = getLocalizationString(@"carSelectRemind");
        _carDescription.font = systemFontWithoutRatio(14.0f);
        _carDescription.textColor = CDZColorOfBlack;
        _carDescription.backgroundColor = CDZColorOfWhite;
        _carDescription.numberOfLines = 0;
        [self addSubview:_carDescription];
        
    }
    [self reloadUIData];
}

- (void)reloadUIData {
    @autoreleasepool {
        self.autoData = [[DBHandler shareInstance] getSelectedAutoData];
        if (_autoData) {
            NSMutableString *string = [NSMutableString string];//WithFormat:@"%@\n%@\n",_autoData[CDZAutosKeyOfBrandName],_autoData[CDZAutosKeyOfDealershipName]];
            [string appendFormat:@"%@ %@",_autoData.seriesName, _autoData.modelName];
            _carDescription.text = string;
        }
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
