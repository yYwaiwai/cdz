//
//  GPSAutosLocationBMKAnnotationView.m
//  cdzer
//
//  Created by KEns0nLau on 6/23/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "GPSAutosLocationBMKAnnotationView.h"
#import "GPSAutosCurrentInfoView.h"

@interface GPSAutosLocationBMKAnnotationView ()

@property (nonatomic, strong) IBOutlet GPSAutosCurrentInfoView *infoView;

@end

@implementation GPSAutosLocationBMKAnnotationView

- (id)initWithAnnotation:(id<BMKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        self.bounds = CGRectMake(0.f, 0.f, 203.f, 170.f);
        [self setBackgroundColor:[UIColor clearColor]];
        UINib *nib = [UINib nibWithNibName:@"GPSAutosCurrentInfoView" bundle:nil];
        [nib instantiateWithOwner:self options:nil];
        [self addSubview:self.infoView];
        self.centerOffset = CGPointMake(0.0f, -(CGRectGetMidY(self.bounds)-20));
        self.userInteractionEnabled = NO;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    NSLog(@"%d", self.isUserInteractionEnabled);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
