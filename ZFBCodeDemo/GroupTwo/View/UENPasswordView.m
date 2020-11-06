//
//  UENPasswordView.m
//  TESTDEMO
//
//  Created by 张涛 on 2020/11/6.
//

#import "UENPasswordView.h"
#import "UENConst.h"
#import "UIView+UENExtension.h"
#import "UENPasswordInputView.h"

#define kPWDLength 6

@interface UENPasswordView ()<UITextFieldDelegate, UIGestureRecognizerDelegate>

// 朦板View
@property (nonatomic, strong) UIControl *coverView;

// 加载效果文字
@property (nonatomic, strong) UILabel *lblMessage;

// 加载效果视图
@property (nonatomic, strong) UIImageView *imgRotation;

// 输入框: 响应者
@property (nonatomic, strong) UITextField *txfResponsder;

// 输入框View
@property (nonatomic, strong) UENPasswordInputView *passwordInputView;

@end


@implementation UENPasswordView

#pragma mark  - 常量区
static NSString *tempStr;


#pragma mark  - 生命周期方法
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:WYScreen.bounds];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"%s dealloc",object_getClassName(self));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupUI {
    self.backgroundColor = [UIColor clearColor];
    // 朦板View
    [self addSubview:self.coverView];
    // 响应者
    [self addSubview:self.txfResponsder];
    // 输入框View
    [self addSubview:self.passwordInputView];

    [self.passwordInputView addSubview:self.imgRotation];
    [self.passwordInputView addSubview:self.lblMessage];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.imgRotation.centerX = self.passwordInputView.centerX;
    self.imgRotation.centerY = self.passwordInputView.height * 0.5;
    
    self.lblMessage.centerX = self.passwordInputView.centerX;
    self.lblMessage.centerY = CGRectGetMaxY(self.imgRotation.frame) + WYPasswordViewTextFieldMarginTop;
    self.lblMessage.x = 0;
    self.lblMessage.width = WYScreenWith;
}

#pragma mark  - 公开方法
// 关闭键盘
- (void)hideKeyboard
{
    [self hideKeyboard:nil];
}

- (void)dismissView
{
    [self removeFromSuperview];
}

- (void)showInView
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ViewTapClick:)];
    tap.delegate = self;
    [self addGestureRecognizer:tap];
    
    /** 输入框起始frame */
    self.passwordInputView.height = UENPasswordInputViewHeight;
    self.passwordInputView.y = self.height;
    self.passwordInputView.width = WYScreenWith;
    self.passwordInputView.x = 0;
    /** 弹出键盘 */
    [self showKeyboard];
    
    CGFloat textfieldY = WYPasswordViewTitleHeight + WYPasswordViewTextFieldMarginTop;
    CGFloat textfieldW = WYPasswordViewTextFieldWidth;
    CGFloat textfieldX = (WYScreenWith - textfieldW) * 0.5;
    CGFloat textfieldH = WYPasswordViewTextFieldHeight;
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(textfieldX, textfieldY, textfieldW, textfieldH)];
    button.backgroundColor = [UIColor redColor];
    button.alpha = 0.5;
    [self.passwordInputView addSubview:button];
    [button addTarget:self action:@selector(clickRemove) forControlEvents:UIControlEventTouchUpInside];
    
}

#pragma mark  - 私有方法
// 键盘弹出
- (void)showKeyboard {
    [self.txfResponsder becomeFirstResponder];
    [UIView animateWithDuration:WYPasswordViewAnimationDuration delay:0 options:UIViewAnimationOptionTransitionNone animations:^{
        self.passwordInputView.y = (self.height - self.passwordInputView.height);
    } completion:^(BOOL finished) {
       
    }];
}

// 键盘退下
- (void)hideKeyboard:(void (^)(BOOL finished))completion {
    [self.txfResponsder endEditing:NO];
    [UIView animateWithDuration:WYPasswordViewAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.inputView.transform = CGAffineTransformIdentity;
    } completion:completion];
}

#pragma mark - Set 方法
- (void)setTitle:(NSString *)title {
    _title = [title copy];
    self.passwordInputView.title = title;
}

- (void)setLoadingText:(NSString *)loadingText {
    _loadingText = [loadingText copy];
    self.lblMessage.text = loadingText;
}

#pragma mark  - <UITextFieldDelegate> // 处理字符串和删除键
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (!tempStr) {
        tempStr = string;
    } else {
        tempStr = [NSString stringWithFormat:@"%@%@",tempStr,string];
    }
    if ([string isEqualToString:@""]) {
        [WYNotificationCenter postNotificationName:WYPasswordViewDeleteButtonClickNotification object:self];
        if (tempStr.length > 0) { // 删除最后一个字符串
            NSString *lastStr = [tempStr substringToIndex:[tempStr length] - 1];
            tempStr = lastStr;
        }
    } else {
        if (tempStr.length == kPWDLength) {
            if (self.finish) {
                self.finish(tempStr);
                //self.finish = nil;
            }
            tempStr = @"";
        }
        NSMutableDictionary *userInfoDict = [NSMutableDictionary dictionary];
        userInfoDict[WYPasswordViewKeyboardNumberKey] = string;
        [WYNotificationCenter postNotificationName:WYPasswordViewNumberButtonClickNotification object:self userInfo:userInfoDict];
    }
    return YES;
}


#pragma mark  - LazyLoad
- (UIControl *)coverView {
    if (_coverView == nil) {
        _coverView = [[UIControl alloc] init];
        [_coverView setBackgroundColor:[UIColor blackColor]];
        _coverView.alpha = 0.4;
        _coverView.frame = self.bounds;
    }
    return _coverView;
}

- (UENPasswordInputView *)passwordInputView {
    if (_passwordInputView == nil) {
        _passwordInputView = [[UENPasswordInputView alloc] init];
        
        // 注册取消按钮点击的通知
        [WYNotificationCenter addObserver:self selector:@selector(cancleButtonClick) name:WYPasswordViewCancleButtonClickNotification object:nil];
        // 注册取消按钮点击的通知
        
    }
    return _passwordInputView;
}

- (UITextField *)txfResponsder {
    if (_txfResponsder == nil) {
        _txfResponsder = [[UITextField alloc] init];
        _txfResponsder.delegate = self;
        _txfResponsder.keyboardType = UIKeyboardTypeNumberPad;
        _txfResponsder.secureTextEntry = YES;
    }
    return _txfResponsder;
}

- (UIImageView *)imgRotation {
    if (_imgRotation == nil) {
        _imgRotation = [[UIImageView alloc] init];
        _imgRotation.image = [UIImage imageNamed:WYPasswordViewSrcName(@"password_loading_a")];
        [_imgRotation sizeToFit];
        _imgRotation.hidden = YES;
    }
    return _imgRotation;
}

- (UILabel *)lblMessage {
    if (_lblMessage == nil) {
        _lblMessage = [[UILabel alloc] init];
        _lblMessage.text = @"支付中...";
        _lblMessage.hidden = YES;
        _lblMessage.textColor = [UIColor darkGrayColor];
        _lblMessage.font = WYLabelFont;
        _lblMessage.textAlignment = NSTextAlignmentCenter;
        [_lblMessage sizeToFit];
    }
    return _lblMessage;
}


#pragma mark - 加载视图效果
- (void)startLoading {
    [self startRotation:self.imgRotation];
    [WYNotificationCenter postNotificationName:WYPasswordViewDisEnabledUserInteractionNotification
                                        object:@{@"enable":@(NO)}];
}

- (void)stopLoading {
    [self stopRotation:self.imgRotation];
    [WYNotificationCenter postNotificationName:WYPasswordViewEnabledUserInteractionNotification
                                        object:@{@"enable":@(YES)}];
}

// 开始旋转
- (void)startRotation:(UIView *)view {
    _imgRotation.hidden = NO;
    _lblMessage.hidden = NO;
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
    rotationAnimation.duration = 2.0;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = MAXFLOAT;
    [view.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

// 结束旋转
- (void)stopRotation:(UIView *)view {
    //_imgRotation.hidden = YES;
    //_lblMessage.hidden = YES;
    [view.layer removeAllAnimations];
}




#pragma mark - 模拟支付请求
- (void)requestComplete:(BOOL)state {
    if (state) {
        [self requestComplete:state message:@"支付成功"];
    } else {
        [self requestComplete:state message:@"支付失败"];
    }
}


- (void)requestComplete:(BOOL)state message:(NSString *)message {
    if (state) {
        // 请求成功
        self.lblMessage.text = message;
        self.imgRotation.image = [UIImage imageNamed:WYPasswordViewSrcName(@"password_success")];
    } else {
        // 请求失败
        self.lblMessage.text = message;
        self.imgRotation.image = [UIImage imageNamed:WYPasswordViewSrcName(@"password_error")];
    }
}


#pragma mark - 点击事件
// 输入框左上角取消按钮点击
- (void)cancleButtonClick {
    [self hideKeyboard:^(BOOL finished) {
        self.inputView.hidden = YES;
        tempStr = nil;
        [self removeFromSuperview];
        [self hideKeyboard:nil];
        [self.inputView setNeedsDisplay];
    }];
}

// 当前view的手势点击事件
- (void)ViewTapClick:(UITapGestureRecognizer *)tap {
    [self dismissView];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    // 点击UENPasswordInputView不执行Touch事件
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UENPasswordInputView"]) {
        return NO;
    }
    return  YES;
}

// 6位密码框区域上的点击事件
- (void)clickRemove {
    [self.passwordInputView removeNumber];
    [self showKeyboard];
    tempStr = @"";
    _imgRotation.image = [UIImage imageNamed:WYPasswordViewSrcName(@"password_loading_a")];
    _imgRotation.hidden = YES;
    _lblMessage.hidden = YES;
    [self.inputView setNeedsDisplay];
    
}

@end
