//
//  BottomPopView.m
//  TESTDEMO
//
//  Created by 张涛 on 2020/10/27.
//

#import "BottomPopView.h"

@interface BottomPopView ()

/* 朦版view */
@property (nonatomic, strong) UIView *coverView;

@end

@implementation BottomPopView


#pragma mark - Intial
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        [self setUpUI];
    }
    return self;
}

-(void)setUpUI {
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:self.coverView];// 朦版view
}


// 展示当前View
- (void)showInView{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self];
    
    /* 这里设置需要加载view的frame */
    
}

// 取消当前View
- (void)dismissView {
    [self removeFromSuperview];
}

#pragma mark  - 懒加载
- (UIView *)coverView {
    if (_coverView == nil){
        _coverView = [[UIView alloc] init];
        [_coverView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.25]];
        _coverView.alpha = 0.4;
        _coverView.frame = self.bounds;
    }
    return _coverView;
}

@end
