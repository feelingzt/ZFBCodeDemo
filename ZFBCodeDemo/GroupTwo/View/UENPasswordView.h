//
//  UENPasswordView.h
//  TESTDEMO
//
//  Created by 张涛 on 2020/11/6.
//

#import <UIKit/UIKit.h>

@interface UENPasswordView : UIView

// 密码框的标题
@property (nonatomic, copy) NSString *title;

// 正在请求时显示的文本
@property (nonatomic, copy) NSString *loadingText;

// 完成的回调block
@property (nonatomic, copy) void (^finish) (NSString *password);

// 弹出密码框
- (void)showInView;

// 隐藏密码框
- (void)dismissView;

// 隐藏键盘
- (void)hideKeyboard;

// 开始加载
- (void)startLoading;

// 加载完成
- (void)stopLoading;

// 请求完成
- (void)requestComplete:(BOOL)state;
- (void)requestComplete:(BOOL)state message:(NSString *)message;

@end
