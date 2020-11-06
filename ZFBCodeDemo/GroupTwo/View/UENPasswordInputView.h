//
//  UENPasswordInputView.h
//  TESTDEMO
//
//  Created by 张涛 on 2020/11/6.
//

#import <UIKit/UIKit.h>

@interface UENPasswordInputView : UIView

@property (nonatomic, copy) NSString *title;

// 删除所有密码
- (void)removeNumber;

@end

