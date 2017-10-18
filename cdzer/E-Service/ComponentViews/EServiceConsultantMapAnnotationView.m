//
//  EServiceConsultantMapAnnotationView.m
//  cdzer
//
//  Created by KEns0nLau on 6/3/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "EServiceConsultantMapAnnotationView.h"

@interface EServiceConsultantMapAnnotationView ();

@property (nonatomic, strong) IBOutlet UIView *consultantContentView;

//@property (nonatomic, weak) IBOutlet UIButton *actionBtn;

@end

@implementation EServiceConsultantMapAnnotationView

- (id)initWithAnnotation:(id<BMKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setBounds:CGRectMake(0.f, 0.f, 113.f, 56.f)];
        [self setBackgroundColor:[UIColor clearColor]];
        UINib *nib = [UINib nibWithNibName:@"EServiceConsultantMapAnnotationView" bundle:nil];
        [nib instantiateWithOwner:self options:nil];
        [self addSubview:self.consultantContentView];
        self.centerOffset = CGPointMake(11, 0);
        
        [self.consultantPortrait setViewCornerWithRectCorner:UIRectCornerAllCorners cornerSize:CGRectGetHeight(self.consultantPortrait.frame)/2.0f];
        [self.consultantPortrait setBorderWithColor:nil borderWidth:0.5];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    NSLog(@"%d", self.isUserInteractionEnabled);
}

- (IBAction)buttonAction:(UIButton *)sender {
    if (self.actionBlock) {
        self.actionBlock (self.consultantID);
    }
}

@end
