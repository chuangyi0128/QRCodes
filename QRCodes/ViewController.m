//
//  ViewController.m
//  QRCodes
//
//  Created by SongLi on 1/8/15.
//  Copyright (c) 2015 SongLi. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <AVCaptureMetadataOutputObjectsDelegate>
@property (strong, nonatomic) AVCaptureSession *session;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.scannerTipLabel.hidden = YES;
    self.scannerResultView.hidden = YES;
    self.scannerResultView.layer.cornerRadius = 5.0f;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self setupCamera];
    [self.session startRunning];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.session stopRunning];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setupCamera
{
    // Device
    AVCaptureDevice *device = [self backCamera];
    if (device == nil) {
        self.scannerTipLabel.text = @"你的设备貌似没有摄像头啊";
        self.scannerTipLabel.hidden = NO;
        return;
    }
    
    // Input
    NSError *error;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (error) {
        self.scannerTipLabel.text = [NSString stringWithFormat:@"获取摄像头失败\nError:%@\n%@", error.domain, error.description];
        self.scannerTipLabel.hidden = NO;
        return;
    }
    
    // Output
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    // Session
    self.session = [[AVCaptureSession alloc] init];
    [self.session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([self.session canAddInput:input]) {
        [self.session addInput:input];
    }
    if ([self.session canAddOutput:output]) {
        [self.session addOutput:output];
    }
    
    output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode]; // 条码类型
    
    // Preview
    AVCaptureVideoPreviewLayer *preview = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    preview.frame = self.scannerView.bounds;
    [self.scannerView.layer addSublayer:preview];
}

- (AVCaptureDevice*)backCamera
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if (device.position == AVCaptureDevicePositionBack) {
            return device;
        }
    }
    return [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
}


#pragma mark AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if ([metadataObjects count] > 0) {
        NSMutableString *stringValue = [NSMutableString string];
        for (AVMetadataMachineReadableCodeObject *metadataObject in metadataObjects) {
            [stringValue appendFormat:@"%@\n", metadataObject.stringValue];
        }
        self.scannerResultView.hidden = NO;
        
        NSString *originText = self.scannerResultView.text;
        self.scannerResultView.text = [stringValue copy];
        
        if (![originText isEqualToString:self.scannerResultView.text]) {
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
            [animation setDuration:0.2f];
            [animation setRemovedOnCompletion:YES];
            [animation setFillMode:kCAFillModeBoth];
            [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
            [animation setFromValue:(id)[UIColor colorWithWhite:1.0f alpha:0.8f].CGColor];
            [self.scannerResultView.layer addAnimation:animation forKey:@"AppearAnimation"];
        }
    }
}

@end
