//
//  UENFlashButton.m
//  TESTDEMO
//
//  Created by 张涛 on 2020/10/30.
//

#import "UENFlashButton.h"

@implementation UENFlashButton


- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGPoint dcIFrmae = self.imageView.center;
    dcIFrmae.x = self.frame.size.width * 0.5;
    dcIFrmae.y = self.frame.size.height * 0.3;
    self.imageView.center = dcIFrmae;

    [self.titleLabel sizeToFit];
    
    CGPoint dcLFrmae = self.titleLabel.center;
    dcLFrmae.x = self.frame.size.width * 0.5;
    self.titleLabel.center = dcLFrmae;
    
    CGRect rect = self.titleLabel.frame;
    rect.origin.y = self.imageView.frame.origin.y + self.imageView.frame.size.height + self.frame.size.height * 0.12;
    self.titleLabel.frame = rect;
    
}

#pragma mark - Intial
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpFlash];
    }
    return self;
}

- (void)setUpFlash {
    self.titleLabel.font = [UIFont systemFontOfSize:12];
    [self setTitle:@"轻点照亮" forState:UIControlStateNormal];
    [self setTitle:@"轻点关闭" forState:UIControlStateSelected];
    [self setImage:[UIImage imageNamed:@"flsah_normal"] forState:UIControlStateNormal];
    [self setImage:[UIImage imageNamed:@"flash_select"] forState:UIControlStateSelected];
}

@end
