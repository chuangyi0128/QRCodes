//
//  ViewController.h
//  QRCodes
//
//  Created by SongLi on 1/8/15.
//  Copyright (c) 2015 SongLi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIView *scannerView;
@property (strong, nonatomic) IBOutlet UILabel *scannerTipLabel;
@property (strong, nonatomic) IBOutlet UITextView *scannerResultView;

@end

