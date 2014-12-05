//
//  ViewController.h
//  DigitalThermometer
//
//  Created by Emily Quigley on 9/20/14.
//  Copyright (c) 2014 Emily Quigley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>


@interface ViewController : UIViewController{
    AVAudioPlayer *alarmNoise;
}

@property (strong, nonatomic) IBOutlet UIButton *doneButton;

@end
