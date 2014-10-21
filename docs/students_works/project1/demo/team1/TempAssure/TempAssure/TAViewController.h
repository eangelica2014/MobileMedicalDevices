//
//  TAViewController.h
//  TempAssure
//
//  Created by Alexander B. Henry on 9/18/14.
//  Copyright (c) 2014 Alexander Henry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface TAViewController : UIViewController <UIAlertViewDelegate> {

    AVAudioPlayer *alarmSound;
    UIImage *alarmOn;
    UIImage *unitFBG;
    UIImage *unitCBG;
    UIImage *alarmOnBG;
    UIImage *alarmOffBG;
    UIImage *alarmOnBanner;
    UIImage *alarmOffBanner;
    UIImage *battery1BG;
    UIImage *battery2BG;
    UIImage *battery3BG;
    UIImage *battery4BG;
}

@property bool unitFlag; // true = C; false = F
@property bool alarmFlag; // true = alarm disabled; false = alarm enabled
@property bool batteryFlag; // true = battery alarm already went off; false = battery alarm not gone off
@property bool newPatientFlag; // false = no new patient waiting; true = new patient loading

@property float currentTemp;
@property float oneSecAvgTemp;
@property float tenSecAvgTemp;
@property float batteryVolt;

@property float thresholdTemp;

@property IBOutlet UIButton *unitButton;
@property IBOutlet UIButton *alarmButton;
@property IBOutlet UIButton *patientButton;

@property IBOutlet UILabel *currentTempLabel;
@property IBOutlet UILabel *oneSecAvgTempLabel;
@property IBOutlet UILabel *tenSecAvgTempLabel;

@property IBOutlet UILabel *currentUnitLabel;
@property IBOutlet UILabel *oneSecAvgUnitLabel;
@property IBOutlet UILabel *tenSecAvgUnitLabel;

@property IBOutlet UIImageView *alarmBanner;
@property IBOutlet UIImageView *alarmButtonBG;
@property IBOutlet UIImageView *unitButtonBG;
@property IBOutlet UIImageView *batteryBG;


- (IBAction)toggleSwitchAndFormatUnits:(id) sender;
- (IBAction)resetAlarm:(id)sender;
- (IBAction)selectNewPatient:(id)sender;
- (void)accessURLData;
- (void)accessTestData;


@end
