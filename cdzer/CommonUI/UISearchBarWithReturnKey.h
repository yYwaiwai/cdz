//
//  UISearchBarWithReturnKey.h
//  cdzer
//
//  Created by KEns0nLau on 8/27/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UISearchBarWithReturnKeyDelegate <UISearchBarDelegate>
@optional
- (void)searchBarReturnKey:( UISearchBar * _Nonnull )searchBar;

@end

@interface UISearchBarWithReturnKey : UISearchBar

@property(nullable, nonatomic, weak) id <UISearchBarWithReturnKeyDelegate> delegate;

@end
