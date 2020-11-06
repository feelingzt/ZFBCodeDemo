//
//  ScanViewController.m
//  ScanTestDemo
//
//  Created by 张涛 on 2020/11/5.
//

#import "ScanViewController.h"
#import "UENScanTool.h"
#import "UENFlashButton.h"
#import <AVFoundation/AVFoundation.h>

// TopView的高度
static CGFloat const TopViewHeight = 40;
// BottomOneView的高度
static CGFloat const BottomOneViewHeight = 40;

@interface ScanViewController ()
<
UINavigationControllerDelegate, UIImagePickerControllerDelegate, //相册代理回调
AVCaptureMetadataOutputObjectsDelegate, // 有效区域扫描代理回调
AVCaptureVideoDataOutputSampleBufferDelegate // 识别光线强弱代理回调
>

@property(nonatomic, strong) UIView * NavView;
@property(nonatomic, strong) UIButton *navLeftButton;
@property(nonatomic, strong) UILabel  *navTitleLabel;

@property(nonatomic, strong) UIView * TopView;

@property(nonatomic, strong) UIView * BottomOneView;
@property(nonatomic, strong) UILabel  *BottomOneLabel;//提示文字

@property(nonatomic, strong) UIView * BottomTwoView;
@property(nonatomic, strong) UIButton *BottomTwoLeftButton;
@property(nonatomic, strong) UIButton *BottomTwoRightButton;


#pragma mark 识别区域等布局控件
// 识别区域view
@property(nonatomic, strong) UIView * ScanView;

// 定时器
@property (strong , nonatomic)NSTimer *timer;

// 图片起始Y
@property (assign , nonatomic)CGFloat qrImageLineY;

// 扫描图片
@property (strong , nonatomic)UIImageView *sqrImageView;

// 闪光灯按钮
@property (nonatomic, strong) UENFlashButton *flashButton;


#pragma mark 相机设备等扫描控件
// 设备
@property (strong,nonatomic)AVCaptureDevice *device;

// 背景
@property (strong,nonatomic)AVCaptureVideoPreviewLayer *ffView;

// 用来捕捉管理活动的对象
@property (strong,nonatomic)AVCaptureSession *session;

// 捕获输入
@property (strong,nonatomic)AVCaptureDeviceInput *input;

// 捕获输出
@property (strong,nonatomic)AVCaptureMetadataOutput *output;

// 输出流
@property (strong,nonatomic)AVCaptureVideoDataOutput *videoDataOutput;


@end

@implementation ScanViewController {
    CGFloat statusHeight;//状态栏的高度
}

- (void)dealloc {
    UENNSLog(@"");
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_timer invalidate]; // 真正销毁NSTimer对象的地方
    _timer = nil; // 对象置nil是一种规范和习惯
    
    [self stopDeviceScanning];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    // Do any additional setup after loading the view.
    CGRect statusRect = [[UIApplication sharedApplication] statusBarFrame];//获取状态栏的rect
    if (statusRect.size.height == 44) {
        statusHeight = 44 ;
    }else{
        statusHeight = 20;
    }
    
    [self setUpPage];
    [self setUpBase];
    [self setupCamera];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    NSLog(@"%@", self.ScanView);
    NSLog(@"%@", self.sqrImageView);
    
    // 光标图片起始Y
    self.qrImageLineY = self.sqrImageView.frame.origin.y;
    
    /*
     * 设置扫描区域:
     * ScanView的frame是设定的扫描区域、扫描框框;
     * AVCaptureMetadataOutput的属性rectOfInterest(CGRect类型)是能够识别码的有效区域(也要限于框框内部);
     > 需要知道rectOfInterest所在的坐标系;
     > 1. 其坐标原点是图像的左上角(不是设备的左上角), 其值介于0 - 1;
     > 2. 如果设置为CGRectMake(0, 0, 1, 1)将是全屏幕扫描;
     > 3. 经实践发现(0,0,,1,1)这个写法有点坑, 实际为(y,x,h,w)即:坐标(y,x)高宽(h,w);
     > 3. 所以需要将我们的扫描框的坐标(相对于设备), 转换为0-1之间的值(相对于图像).

     * 转换方式:
     * 加入屏幕的frame 为 x , y, w, h
     * 要设置的矩形快的frame 为 x1, y1, w1, h1
     * 那么rectOfInterest 应该设置为 CGRectMake(y1/y, x1/x, h1/h, w1/w)。
     */
    
    
    // 加入屏幕的frame
    //CGSize size = self.view.bounds.size;
    // 设置的矩形快的frame
    //CGRect cropRect = CGRectMake(SCREEN_WIDTH/2-110,100,220,220);
    // 转换成rectOfInterest的坐标
    //_output.rectOfInterest =  CGRectMake(cropRect.origin.y/SCREEN_HEIGHT,
                                        //cropRect.origin.x/size.width,
                                        //cropRect.size.height/size.height,
                                        //cropRect.size.width/size.width);
    // 加入屏幕的frame
    CGSize size = self.view.bounds.size;
    // 设置的矩形快的frame
    CGRect cropRect = self.ScanView.frame;
    
    // p1为设备屏幕的height/width
    CGFloat p1 = size.height/size.width;
    // p2为图像的分辨率 height/width
    CGFloat p2 = 1920./1080.; //使用了1080p的图像输出
    
    if (p1 < p2) {
        CGFloat fixHeight = DCScreenW * 1920. / 1080.;
        CGFloat fixPadding = (fixHeight - size.height)/2;
        _output.rectOfInterest = CGRectMake((cropRect.origin.y + fixPadding)/fixHeight,
                                            cropRect.origin.x/size.width,
                                            cropRect.size.height/fixHeight,
                                            cropRect.size.width/size.width);
    }else{
        CGFloat fixWidth = self.view.frame.size.height * 1080. / 1920.;
        CGFloat fixPadding = (fixWidth - size.width)/2;
        _output.rectOfInterest = CGRectMake(cropRect.origin.y/size.height,
                                            (cropRect.origin.x + fixPadding)/fixWidth,
                                            cropRect.size.height/size.height,
                                            cropRect.size.width/fixWidth);
    }

    
}

#pragma mark - initialize
// 初始化界面布局
- (void)setUpPage {
    __weak typeof (self) weakSelf = self;
    [self.view addSubview:self.NavView];
    [self.NavView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.view).offset(statusHeight);
        make.left.right.equalTo(weakSelf.view);
        make.height.mas_equalTo(44);
    }];
    
    [self.NavView addSubview:self.navLeftButton];
    [self.navLeftButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakSelf.NavView);
        make.left.equalTo(weakSelf.NavView).offset(16);
        make.height.equalTo(@35);
        make.width.equalTo(@35);
    }];
    
    [self.NavView addSubview:self.navTitleLabel];
    [self.navTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakSelf.NavView);
        make.left.equalTo(weakSelf.navLeftButton.mas_right).offset(16);
    }];
    
    [self.view addSubview:self.TopView];
    [self.TopView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.NavView.mas_bottom).offset(0);
        make.left.right.equalTo(weakSelf.view).offset(0);
        make.height.mas_equalTo(TopViewHeight);
    }];
    
    [self.view addSubview:self.ScanView];
    [self.ScanView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.TopView.mas_bottom).offset(0);
        make.left.right.equalTo(weakSelf.view).offset(0);
        make.height.mas_equalTo((DCScreenH - TopViewHeight)/2);
    }];
    
    [self.ScanView addSubview:self.sqrImageView];
    [self.sqrImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(weakSelf.ScanView).offset(0);
        make.height.mas_equalTo(4);
    }];
    
    [self.ScanView addSubview:self.flashButton];
    [self.flashButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakSelf.ScanView);
        // 距底部为0,按钮文字会超了出去
        make.bottom.equalTo(weakSelf.ScanView).offset(-10);
        make.width.mas_equalTo(15);
        make.height.mas_equalTo(20);
    }];
    
    
    [self.view addSubview:self.BottomOneView];
    [self.BottomOneView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.ScanView.mas_bottom).offset(0);
        make.left.right.equalTo(weakSelf.view).offset(0);
        make.height.mas_equalTo(BottomOneViewHeight);
    }];
    
    [self.BottomOneView addSubview:self.BottomOneLabel];
    [self.BottomOneLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.BottomOneView);
        make.bottom.equalTo(weakSelf.BottomOneView).offset(0);
    }];
    
    
    [self.view addSubview:self.BottomTwoView];
    [self.BottomTwoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.BottomOneView.mas_bottom).offset(0);
        make.bottom.equalTo(weakSelf.view).offset(0);
        make.left.right.equalTo(weakSelf.view).offset(0);
    }];
    
    [self.BottomTwoView addSubview:self.BottomTwoLeftButton];
    [self.BottomTwoLeftButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.BottomTwoView);
        make.left.equalTo(self.BottomTwoView).offset(60);
    }];
    
    [self.BottomTwoView addSubview:self.BottomTwoRightButton];
    [self.BottomTwoRightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.BottomTwoView);
        make.right.equalTo(self.BottomTwoView).offset(-60);
    }];
}

// 初始化其它
- (void)setUpBase{
    //定时器
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.01
                                              target:self
                                            selector:@selector(sliding)
                                            userInfo:nil repeats:YES];
    
    //开启定时器
    [_timer setFireDate:[NSDate distantPast]];
    
    //关闭定时器
    //[_timer setFireDate:[NSDate distantFuture]];
}

// 滑动
- (void)sliding {
    __weak typeof(self)weakSelf = self;
    [UIView animateWithDuration:0.01 animations:^{
        CGRect rect = weakSelf.sqrImageView.frame;
        rect.origin.y = weakSelf.qrImageLineY;
        weakSelf.sqrImageView.frame = rect;
    } completion:^(BOOL finished) {
        CGFloat maxH = weakSelf.ScanView.frame.size.height;
        if (weakSelf.qrImageLineY > maxH) {
            weakSelf.qrImageLineY = 0;
        }
        weakSelf.qrImageLineY++;
    }];
}

#pragma mark - 按钮的点击事件
// 导航栏返回按钮
- (void)NavLeftButtonClick {
    [self.navigationController popViewControllerAnimated:YES];
}

// 底部左侧按钮
- (void)BottomTwoLeftButtonClick {
    UENNSLog(@"点击了付款码");
}

// 底部右侧按钮: 跳转到相册
- (void)BottomTwoRightButtonClick {
    UENNSLog(@"点击了相册");
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIAlertController *alter = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"无法访问相册" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        }];
        [alter addAction:okAction];
        
        [self presentViewController:alter animated:YES completion:nil];
        
        return;
    }
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    [picker.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigationbarScanBg"] forBarMetrics:UIBarMetricsDefault];
    picker.view.backgroundColor = [UIColor whiteColor];
    picker.delegate = self;
    [self showDetailViewController:picker sender:nil];
}

#pragma mark - <UIImagePickerControllerDelegate>  //相册回调
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *image = [UENScanTool resizeImage:info[UIImagePickerControllerOriginalImage] WithMaxSize:CGSizeMake(1000, 1000)];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{ //异步
        CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy : CIDetectorAccuracyHigh}];
        CIImage *selImage = [[CIImage alloc] initWithImage:image];
        NSArray *features = [detector featuresInImage:selImage];
        
        NSMutableArray *arrayM = [NSMutableArray arrayWithCapacity:features.count];
        for (CIQRCodeFeature *feature in features) {
            [arrayM addObject:feature.messageString];
        }
        __weak typeof(self)weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (arrayM.copy != nil && ![arrayM isKindOfClass:[NSNull class]] && arrayM.count != 0) {
                [weakSelf dismissViewControllerAnimated:YES completion:nil];
                [weakSelf stopDeviceScanning]; //停止扫描
                [UENScanTool showAlterViewWithVC:self
                                   WithReadTitle:@"温馨提示"
                                 WithReadMessage:[NSString stringWithFormat:@"扫描结果：%@",arrayM[0]]
                                    WithLeftText:@"重新扫描" LeftBlock:^{
                    
                } WithRightText:@"确定返回" RightBliock:^{
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                }];
            }else{
                [UENScanTool showAlterViewWithVC:self
                                   WithReadTitle:@"温馨提示"
                                 WithReadMessage:@"未能识别到任何二维码、条形码，请重新识别!"
                                    WithLeftText:@"重新扫描" LeftBlock:^{
                    
                } WithRightText:@"确定返回" RightBliock:^{
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                }];
            }
        });
    });
}


#pragma mark - LazyLoad
- (UIView *)NavView {
    if (_NavView == nil) {
        _NavView = [[UIView alloc] init];
        _NavView.backgroundColor = [UIColor clearColor];
    }
    return _NavView;
}

-(UIButton *)navLeftButton {
    if (_navLeftButton == nil) {
        _navLeftButton  = [UIButton buttonWithType:UIButtonTypeCustom];
        [_navLeftButton setImage:[UIImage imageNamed:@"bs_arrowL"] forState:UIControlStateNormal];
        [_navLeftButton addTarget:self
                           action:@selector(NavLeftButtonClick)
                 forControlEvents:UIControlEventTouchUpInside];
    }
    return _navLeftButton;
}

-(UILabel *)navTitleLabel {
    if (_navTitleLabel == nil) {
        _navTitleLabel = [[UILabel alloc] init];
        _navTitleLabel.text = @"扫一扫";
        _navTitleLabel.textColor = [UIColor whiteColor];;
        _navTitleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:20];
    }
    return _navTitleLabel;
}



- (UIView *)TopView {
    if (_TopView == nil) {
        _TopView = [[UIView alloc] init];
        _TopView.backgroundColor = [UIColor clearColor];
    }
    return _TopView;;
}


- (UIView *)ScanView {
    if (_ScanView == nil) {
        _ScanView = [[UIView alloc] init];
        _ScanView.backgroundColor = [UIColor clearColor];
    }
    return _ScanView;
}

- (UIView *)BottomOneView {
    if (_BottomOneView == nil) {
        _BottomOneView = [[UIView alloc] init];
        _BottomOneView.backgroundColor = [UIColor clearColor];
    }
    return _BottomOneView;;
}

-(UILabel *)BottomOneLabel {
    if (_BottomOneLabel == nil) {
        _BottomOneLabel = [[UILabel alloc] init];
        _BottomOneLabel.text = @"支持扫二维码、条形码";
        _BottomOneLabel.textColor = [UIColor whiteColor];;
        _BottomOneLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    }
    return _BottomOneLabel;
}


- (UIView *)BottomTwoView {
    if (_BottomTwoView == nil) {
        _BottomTwoView = [[UIView alloc] init];
        _BottomTwoView.backgroundColor = [UIColor clearColor];
    }
    return _BottomTwoView;;
}

-(UIButton *)BottomTwoLeftButton {
    if (_BottomTwoLeftButton == nil) {
        _BottomTwoLeftButton  = [UIButton buttonWithType:UIButtonTypeCustom];
        [_BottomTwoLeftButton setImage:[UIImage imageNamed:@"付款码Image"] forState:UIControlStateNormal];
        [_BottomTwoLeftButton addTarget:self
                                 action:@selector(BottomTwoLeftButtonClick)
                       forControlEvents:UIControlEventTouchUpInside];
    }
    return _BottomTwoLeftButton;
}



-(UIButton *)BottomTwoRightButton {
    if (_BottomTwoRightButton == nil) {
        _BottomTwoRightButton  = [UIButton buttonWithType:UIButtonTypeCustom];
        [_BottomTwoRightButton setImage:[UIImage imageNamed:@"相册Image"] forState:UIControlStateNormal];
        [_BottomTwoRightButton addTarget:self
                                  action:@selector(BottomTwoRightButtonClick)
                        forControlEvents:UIControlEventTouchUpInside];
    }
    return _BottomTwoRightButton;
}


- (UIImageView *)sqrImageView{
    if (!_sqrImageView) {
        _sqrImageView = [[UIImageView alloc] init];
        _sqrImageView.image = [UIImage imageNamed:@"sqr_line"];
        _sqrImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _sqrImageView;
}

- (UENFlashButton *)flashButton{
    if (!_flashButton) {
        _flashButton = [UENFlashButton buttonWithType:UIButtonTypeCustom];
        _flashButton.alpha = 0;
        [_flashButton addTarget:self action:@selector(flashButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _flashButton;
}

- (void)flashButtonClick:(UIButton *)button{
    if (button.selected == NO) {
        [UENScanTool openFlashlight];
    } else {
        [UENScanTool closeFlashlight];
    }
    button.selected = !button.selected;
}


#pragma mark - ============== <初始化相机设备等扫描控件> ==============
- (void)setupCamera {
    __weak typeof(self)weakSelf = self;
    [self setUpJudgmentWithScuessBlock:^{
        [weakSelf setUpPutInit];         //初始化
        [weakSelf setUpFullFigureView];  //背景面
        [weakSelf.session startRunning]; //开启扫描
    }]; //设备权限判断
}

#pragma mark - 设备权限判断
- (void)setUpJudgmentWithScuessBlock:(dispatch_block_t)openSession {
    // 获取摄像设备
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    // 获取权限判断
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
        NSLog(@"无权限: do some thing");
    }else if(_device == nil){ //未找到设备
        NSLog(@"未找到设备");
    }else{ //识别到设备以及打开权限成功后回调
        !openSession ? : openSession(); //回调
    }
}

#pragma mark - 停止扫描&清空对象
- (void)stopDeviceScanning{
    if([_session isRunning]) {
        [_session stopRunning];//停止扫描
        _session = nil;
        
        AVCaptureInput* input = [_session.inputs objectAtIndex:0];
        [_session removeInput:input];
        _input = nil;
        
        AVCaptureVideoDataOutput* output0 = (AVCaptureVideoDataOutput*)[_session.outputs objectAtIndex:0];
        [_session removeOutput:output0];
        _output = nil;
        
        AVCaptureMetadataOutput * output1 = (AVCaptureMetadataOutput*)[_session.outputs objectAtIndex:1];
        [_session removeOutput:output1];
        _videoDataOutput = nil;
        
        //⚠️这里不能remove, 会产生空白页面
        //[_ffView removeFromSuperlayer];
        //_ffView = nil;
    }
}


#pragma mark - 全系背景View
- (void)setUpFullFigureView {
    if (_ffView != nil) {
        //⚠️会产生空白页面和全景页面交替的现象
        [_ffView removeFromSuperlayer];
    }
    _ffView = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    _ffView.videoGravity = AVLayerVideoGravityResizeAspectFill;//***有效扫描区域影响因素2
    _ffView.frame = CGRectMake(0,0,DCScreenW,DCScreenH);
    [self.view.layer insertSublayer:_ffView atIndex:0];
}


#pragma mark - 扫描区域
- (void)setUpPutInit {
    // 创建输入流
    _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    // 创建输出流
    _output = [AVCaptureMetadataOutput new];
    // 设置代理 在主线程里刷新
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    

    // 创建设备输出流 //识别光线强弱
    _videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    // 设置代理 在主线程里刷新
    [_videoDataOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    
    
    // 初始化链接对象(管理的对象)
    _session = [AVCaptureSession new];
    
    // 高质量采集率
    [_session setSessionPreset:AVCaptureSessionPresetHigh];//***有效扫描区域影响因素1
    
    // 添加到sesson
    [_session addOutput:_videoDataOutput];
    
    // 添加到sesson
    if ([_session canAddInput:self.input]){
        [_session addInput:self.input];
    }
    
    // 添加到sesson
    if ([_session canAddOutput:self.output]){
        [_session addOutput:self.output];
    }
    
    
    // 设置扫码类型
    [self.output setMetadataObjectTypes:[NSArray arrayWithObjects:AVMetadataObjectTypeEAN13Code,
                                         AVMetadataObjectTypeEAN8Code,
                                         AVMetadataObjectTypeCode128Code,
                                         AVMetadataObjectTypeQRCode, nil]];
}


#pragma mark - <AVCaptureMetadataOutputObjectsDelegate>  //有效扫描区域回调
- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputMetadataObjects:(NSArray *)metadataObjects
       fromConnection:(AVCaptureConnection *)connection
{
    if ([metadataObjects count] >0){
        AVMetadataMachineReadableCodeObject *metadataObject = [metadataObjects objectAtIndex:0];
        NSLog(@"扫描结果：%@",metadataObject.stringValue);
        __weak typeof(self)weakSelf = self;
        if (metadataObject.stringValue.length != 0) {
            [self stopDeviceScanning]; //停止扫描
            [UENScanTool showAlterViewWithVC:self
                               WithReadTitle:@"温馨提示"
                             WithReadMessage:[NSString stringWithFormat:@"扫描结果：%@",metadataObject.stringValue]
                                WithLeftText:@"重新扫描" LeftBlock:^{
                [weakSelf setupCamera];
            } WithRightText:@"确定返回" RightBliock:^{
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }];
        } else {
            [UENScanTool showAlterViewWithVC:self
                               WithReadTitle:@"温馨提示"
                             WithReadMessage:@"未能识别到任何二维码、条形码，请重新识别!"
                                WithLeftText:@"重新扫描" LeftBlock:^{
                
            } WithRightText:@"确定返回" RightBliock:^{
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }];
        }
    }
}

#pragma mark - <AVCaptureVideoDataOutputSampleBufferDelegate> //识别光线强弱代理回调
- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection {
    
    // 内存稳定调用这个方法的时候
    CFDictionaryRef metadataDict = CMCopyDictionaryOfAttachments(NULL,sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    
    NSDictionary *metadata = [[NSMutableDictionary alloc] initWithDictionary:(__bridge NSDictionary*)metadataDict];
    
    CFRelease(metadataDict);
    
    NSDictionary *exifMetadata = [[metadata objectForKey:(NSString *)kCGImagePropertyExifDictionary] mutableCopy];
    
    // 光线强弱度
    float brightnessValue = [[exifMetadata objectForKey:(NSString *)kCGImagePropertyExifBrightnessValue] floatValue];
    
    if (!self.flashButton.selected)
    {
        self.flashButton.alpha = (brightnessValue < 1.0) ? 1 : 0;
    }
}

@end
