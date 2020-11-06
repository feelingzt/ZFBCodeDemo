//
//  UENScanTool.m
//  TESTDEMO
//
//  Created by 张涛 on 2020/10/30.
//

#import "UENScanTool.h"

@implementation UENScanTool

/*
 * 调整图片尺寸
 * @param image   获取的图片
 * @param maxSize 限制最大的尺寸
 * @return 调整好的尺寸
 */
+ (UIImage *)resizeImage:(UIImage *)image WithMaxSize:(CGSize)maxSize
{
    if (image.size.width < maxSize.width &&
        image.size.height < maxSize.height)
    {
        return image;
    }
    
    maxSize = (maxSize.width == 0)  ?  CGSizeMake(1000, 1000) : maxSize;
    
    CGFloat xScale = maxSize.width / image.size.width;
    CGFloat yScale = maxSize.height / image.size.height;
    CGFloat scale = MIN(xScale, yScale);
    CGSize size = CGSizeMake(image.size.width * scale, image.size.height * scale);
    
    
    // UIGraphicsBeginImageContext(size); // 调整过后的图片会模糊和失真
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return result;
}


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
{
    UIAlertController *alter = [UIAlertController alertControllerWithTitle:titleStr
                                                                   message:messageStr
                                                            preferredStyle:UIAlertControllerStyleAlert];
    if (leftTextStr.length != 0) {
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:leftTextStr
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action){
            !leftClickBlock ? : leftClickBlock();
        }];
        [alter addAction:okAction];
    }
    if (rightTextStr.length != 0) {
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:rightTextStr
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action){
            !rightClickBlock ? : rightClickBlock();
        }];
        [alter addAction:okAction];
    }
    [currentVc presentViewController:alter animated:YES completion:nil];
}


/*
 * 打开手电筒
 */
+ (void)openFlashlight
{
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    if ([captureDevice hasTorch]) {
        BOOL locked = [captureDevice lockForConfiguration:&error];
        if (locked) {
            captureDevice.torchMode = AVCaptureTorchModeOn;
            [captureDevice unlockForConfiguration];
        }
    }
}


/*
 *关闭手电筒
 */
+ (void)closeFlashlight
{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasTorch]) {
        [device lockForConfiguration:nil];
        [device setTorchMode: AVCaptureTorchModeOff];
        [device unlockForConfiguration];
    }
}


@end
