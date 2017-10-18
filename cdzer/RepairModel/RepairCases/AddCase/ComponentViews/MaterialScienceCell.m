//
//  MaterialScienceCell.m
//  cdzer
//
//  Created by 车队长 on 16/11/18.
//  Copyright © 2016年 CDZER. All rights reserved.
//

#import "MaterialScienceCell.h"

@interface MaterialScienceCell ()<UITextFieldDelegate>

@end

@implementation MaterialScienceCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)deleteRowAction {
    if (self.actionBlock) {
        self.actionBlock(MSCellActionOfDeleteRow, nil, self.indexPath);
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSUInteger maxLenght = 16;
    MSCellAction action = MSCellActionOfUpdatePartName;
    if (textField==self.numberTF) {
        maxLenght = 4;
        action = MSCellActionOfUpdateCounting;
    }
    if (textField==self.unitPriceTF) {
        maxLenght = 7;
        action = MSCellActionOfUpdatePartPrice;
    }
    
    NSString *toBeString = textField.text;
    NSString *lang = [[textField textInputMode] primaryLanguage];
    if ([lang isContainsString:@"zh-Hans"]) {
        UITextRange *selectedRange = [textField markedTextRange];
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        if (!position) {
            if (toBeString.length>maxLenght) {
                textField.text = [toBeString substringToIndex:maxLenght];
            }
        }else {
            
        }
    }else {
        if (toBeString.length>maxLenght) {
            textField.text = [toBeString substringToIndex:maxLenght];
        }
    }
    
    
    if (self.actionBlock) {
        self.actionBlock(action, textField.text, self.indexPath);
    }
    
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (![string isEqualToString:@""]) {
        if ([self stringContainsEmoji:string]) {
            return NO;
        }
        if (textField==self.partsTF&&textField.isFirstResponder) {
            if (textField.text.length>=16) {
                return NO;
            }
        }
        if (textField==self.numberTF&&textField.isFirstResponder) {
            if (textField.text.length>=4) {
                return NO;
            }
        }
        if (textField==self.unitPriceTF&&textField.isFirstResponder) {
            if (textField.text.length>=7) {
                return NO;
            }
        }
    }
    return YES;
}

- (BOOL)stringContainsEmoji:(NSString *)string {
    __block BOOL returnValue = NO;
    
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length])
                               options:NSStringEnumerationByComposedCharacterSequences
                            usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                const unichar hs = [substring characterAtIndex:0];
                                if (0xd800 <= hs && hs <= 0xdbff) {
                                    if (substring.length > 1) {
                                        const unichar ls = [substring characterAtIndex:1];
                                        const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                                        if (0x1d000 <= uc && uc <= 0x1f77f) {
                                            returnValue = YES;
                                        }
                                    }
                                } else if (substring.length > 1) {
                                    const unichar ls = [substring characterAtIndex:1];
                                    if (ls == 0x20e3) {
                                        returnValue = YES;
                                    }
                                } else {
                                    if (0x2100 <= hs && hs <= 0x27ff) {
                                        returnValue = YES;
                                    } else if (0x2B05 <= hs && hs <= 0x2b07) {
                                        returnValue = YES;
                                    } else if (0x2934 <= hs && hs <= 0x2935) {
                                        returnValue = YES;
                                    } else if (0x3297 <= hs && hs <= 0x3299) {
                                        returnValue = YES;
                                    } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                                        returnValue = YES;
                                    }
                                }
                            }];
    
    return returnValue;
}

@end
