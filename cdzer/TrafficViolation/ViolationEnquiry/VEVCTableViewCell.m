//
//  VEVCTableViewCell.m
//  cdzer
//
//  Created by KEns0n on 1/4/16.
//  Copyright © 2016 CDZER. All rights reserved.
//

#import "VEVCTableViewCell.h"
#import "InsetsLabel.h"

@interface VEVCTableViewCell ()

@property (nonatomic, strong) InsetsLabel *datetimeLabel;

@property (nonatomic, strong) InsetsLabel *reasonLabel;

@property (nonatomic, strong) UIImageView *reasonLabelIV;

@property (nonatomic, strong) InsetsLabel *addressLabel;

@property (nonatomic, strong) UIImageView *addressLabelIV;

@property (nonatomic, strong) InsetsLabel *fineLabel;

@property (nonatomic, strong) InsetsLabel *vpLabel;

@property (nonatomic, strong) InsetsLabel *warningLabel;

@end

@implementation VEVCTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initializationUI];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
 
    CGRect reasonLblFrame = self.reasonLabel.frame;
    reasonLblFrame.origin.y = CGRectGetMaxY(self.datetimeLabel.frame);
    reasonLblFrame.size.height = [_reasonLabel heightThatFitsWithSpaceOffset:4.0f];;
    self.reasonLabel.frame = reasonLblFrame;
    self.reasonLabelIV.center = CGPointMake(self.reasonLabelIV.center.x, self.reasonLabel.center.y);
    UIEdgeInsets reasonlEdge = DefaultEdgeInsets;
    reasonlEdge.left = CGRectGetWidth(self.reasonLabelIV.frame);
    self.reasonLabel.edgeInsets = reasonlEdge;
    
    CGRect addressLblFrame = self.addressLabel.frame;
    addressLblFrame.origin.y = CGRectGetMaxY(self.reasonLabel.frame);
    addressLblFrame.size.height = [_addressLabel heightThatFitsWithSpaceOffset:4.0f];
    self.addressLabel.frame = addressLblFrame;
    self.addressLabelIV.center = CGPointMake(self.addressLabelIV.center.x, self.addressLabel.center.y);
    UIEdgeInsets addrLblEdge = DefaultEdgeInsets;
    addrLblEdge.left = CGRectGetWidth(self.reasonLabelIV.frame);
    self.addressLabel.edgeInsets = addrLblEdge;
    
    self.fineLabel.edgeInsets = addrLblEdge;
    self.datetimeLabel.edgeInsets = addrLblEdge;
    
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat totalHeight = CGRectGetHeight(_datetimeLabel.frame);
    totalHeight += CGRectGetHeight(_fineLabel.frame);
    totalHeight += [_reasonLabel heightThatFitsWithSpaceOffset:4.0f];
    totalHeight += [_addressLabel heightThatFitsWithSpaceOffset:4.0f];
    size.height = round(totalHeight);
    return size;
}

- (void)initializationUI {
    @autoreleasepool {
        
        CGFloat topLblHeight = 26.0f;
        self.datetimeLabel = [[InsetsLabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.frame), topLblHeight)
                                             andEdgeInsetsValue:DefaultEdgeInsets];
        _datetimeLabel.text = @"";
        _datetimeLabel.textColor = CDZColorOfDefaultColor;
        _datetimeLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 14, NO);
        _datetimeLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
        _datetimeLabel.translatesAutoresizingMaskIntoConstraints = YES;
        [self.contentView addSubview:_datetimeLabel];
        
        
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        self.reasonLabel = [[InsetsLabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.frame), topLblHeight)
                                           andEdgeInsetsValue:DefaultEdgeInsets];
        _reasonLabel.text = @"";
        _reasonLabel.numberOfLines = 0;
        _reasonLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _reasonLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 15, NO);
        _reasonLabel.translatesAutoresizingMaskIntoConstraints = YES;
        [self.contentView addSubview:_reasonLabel];
        
        UIImage *reasonImage = [ImageHandler getImageFromCacheByScreenRatioWithFileRootPath:kSysImageCaches fileName:@"ve_01" type:FMImageTypeOfPNG scaleWithPhone4:NO
                                                                           offsetRatioForP4:0 needToUpdate:YES];
        self.reasonLabelIV = [[UIImageView alloc] initWithImage:reasonImage];
        [self.contentView addSubview:_reasonLabelIV];
        

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        self.addressLabel = [[InsetsLabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.frame), topLblHeight)
                                                             andEdgeInsetsValue:DefaultEdgeInsets];
        _addressLabel.text = @"";
        _addressLabel.numberOfLines = 0;
        _addressLabel.translatesAutoresizingMaskIntoConstraints = YES;
        _addressLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _addressLabel.font = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 15, NO);
        [self.contentView addSubview:_addressLabel];

        
        UIImage *addressImage = [ImageHandler getImageFromCacheByScreenRatioWithFileRootPath:kSysImageCaches fileName:@"ve_02" type:FMImageTypeOfPNG scaleWithPhone4:NO
                                                                            offsetRatioForP4:0 needToUpdate:YES];
        self.addressLabelIV = [[UIImageView alloc] initWithImage:addressImage];
        [self.contentView addSubview:_addressLabelIV];
        
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

        
        self.fineLabel = [[InsetsLabel alloc] initWithFrame:CGRectMake(0.0f, CGRectGetHeight(self.frame)-topLblHeight, CGRectGetWidth(self.frame)/2.0f, topLblHeight)
                                       andEdgeInsetsValue:DefaultEdgeInsets];
        _fineLabel.text = @"";
        _fineLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin;
        _fineLabel.translatesAutoresizingMaskIntoConstraints = YES;
        [self.contentView addSubview:_fineLabel];
        
        self.vpLabel = [[InsetsLabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame)/2.0f, CGRectGetHeight(self.frame)-topLblHeight, CGRectGetWidth(self.frame)/2.0f, topLblHeight)
                                             andEdgeInsetsValue:DefaultEdgeInsets];
        _vpLabel.text = @"";
        _vpLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
        _vpLabel.translatesAutoresizingMaskIntoConstraints = YES;
        [self.contentView addSubview:_vpLabel];
        
        self.warningLabel = [[InsetsLabel alloc] initWithFrame:self.contentView.bounds
                                            andEdgeInsetsValue:DefaultEdgeInsets];
        _warningLabel.text = @"";
        _warningLabel.hidden = YES;
        _warningLabel.numberOfLines = 0;
        _warningLabel.backgroundColor = CDZColorOfWhite;
        _warningLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _warningLabel.translatesAutoresizingMaskIntoConstraints = YES;
        [self.contentView addSubview:_warningLabel];
    }
}

- (void)updateUIData:(NSDictionary *)detailData withWarningLabel:(NSString *)warningText {
    @autoreleasepool {
        if (detailData.count==0) {
            _datetimeLabel.text = @"";
            _reasonLabel.text = @"";
            _addressLabel.text = @"";
            _fineLabel.text = @"";
            _vpLabel.text = @"";
            _warningLabel.hidden = NO;
            _warningLabel.text = warningText;
        }else {
            _warningLabel.hidden = YES;
            _datetimeLabel.text = detailData[@"violation_time"];
            _reasonLabel.text = detailData[@"violation_content"];
            _addressLabel.text = detailData[@"violation_place"];
            
            UIFont *tfont = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfRegular, 14, NO);
            UIFont *cfont = vGetHelveticaNeueFont(HelveticaNeueFontTypeOfBold, 14, NO);
            NSMutableAttributedString *fineString = NSMutableAttributedString.new;
            [fineString appendAttributedString:[[NSAttributedString alloc] initWithString:@"罚款："
                                                                               attributes:@{NSForegroundColorAttributeName:CDZColorOfBlack,
                                                                                            NSFontAttributeName:tfont}]];
            [fineString appendAttributedString:[[NSAttributedString alloc] initWithString:[SupportingClass verifyAndConvertDataToString:detailData[@"violation_price"]]
                                                                               attributes:@{NSForegroundColorAttributeName:CDZColorOfTureRed,
                                                                                            NSFontAttributeName:cfont}]];
            _fineLabel.attributedText = fineString;
            
            
            
            NSMutableAttributedString *vpLabelString = NSMutableAttributedString.new;
            [vpLabelString appendAttributedString:[[NSAttributedString alloc] initWithString:@"扣分："
                                                                                  attributes:@{NSForegroundColorAttributeName:CDZColorOfBlack,
                                                                                               NSFontAttributeName:tfont}]];
            [vpLabelString appendAttributedString:[[NSAttributedString alloc] initWithString:[SupportingClass verifyAndConvertDataToString:detailData[@"violation_point"]]
                                                                                  attributes:@{NSForegroundColorAttributeName:CDZColorOfTureRed,
                                                                                               NSFontAttributeName:cfont}]];
            _vpLabel.attributedText = vpLabelString;
        }
    }
}


@end
