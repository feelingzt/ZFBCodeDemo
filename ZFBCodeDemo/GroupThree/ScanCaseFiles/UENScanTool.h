//
//  UENScanTool.h
//  TESTDEMO
//
//  Created by 张涛 on 2020/10/30.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface UENScanTool : NSObject

/*
 * 调整图片尺寸
 * @param image   获取的图片
 * @param maxSize 限制最大的尺寸
 * @return 调整好的尺寸
 */
+ (UIImage *)resizeImage:(UIImage *)image WithMaxSize:(CGSize)maxSize;


/*
 * 展示弹框(UIAlertController)
 * @param currentVc  当前控制器
 * @param titleStr   提示标题
 * @param messageStr 提示内容
 * @param leftTextStr     左边按钮文字
 * @param leftClickBlock  左边按钮回调
 * @param rightTextStr    右边按钮文字
 * @param rightClickBlock 右边按钮回调
 */
+ (void)showAlterViewWithVC:(UIViewController *)currentVc
           WithReadTitle:(NSString *)titleStr
           WithReadMessage:(NSString *)messageStr
               WithLeftText:(NSString *)leftTextStr
                 LeftBlock:(dispatch_block_t)leftClickBlock
              WithRightText:(NSString *)rightTextStr
                RightBliock:(dispatch_block_t)rightClickBlock;

/*
 * 打开手电筒
 */
+ (void)openFlashlight;

/*
 *关闭手电筒
 */
+ (void)closeFlashlight;

@end

