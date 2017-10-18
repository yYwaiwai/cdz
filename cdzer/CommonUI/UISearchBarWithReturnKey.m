//
//  UISearchBarWithReturnKey.m
//  cdzer
//
//  Created by KEns0nLau on 8/27/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "UISearchBarWithReturnKey.h"

@interface UISearchBarWithReturnKey ()<UITextFieldDelegate> {
   __weak id <UISearchBarWithReturnKeyDelegate> _delegate;
}

@end

@implementation UISearchBarWithReturnKey
@dynamic delegate;

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id<UISearchBarWithReturnKeyDelegate>)delegate {
    return _delegate;
}

- (void)setDelegate:(id<UISearchBarWithReturnKeyDelegate>)delegate {
    [super setDelegate:delegate];
    _delegate = delegate;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (self.delegate&&[self.delegate respondsToSelector:@selector(searchBarReturnKey:)]){
        [self.delegate searchBarReturnKey:self];
    }
    return YES;
}

@end
