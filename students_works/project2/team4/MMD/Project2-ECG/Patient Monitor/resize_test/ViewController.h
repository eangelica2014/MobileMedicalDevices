//
//  ViewController.h
//  resize_test
//
//  Created by Inbar Fried on 11/6/14.
//  Copyright (c) 2014 Team4. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingsViewController.h"
#import "RecordsViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController : UIViewController {
    UIColor *my_green;
    UIColor *my_blue;
    UIColor *my_yellow;
    UIColor *my_pink;
    UIColor *my_orange;
    UIColor *my_black;
    UIColor *my_white;
    UIColor *my_white_opaque;
    UIColor *my_red;
    UIColor *my_clear;
    
    int     num_orig_buttons;
    int     button_gap;
    int     dist_from_top;
    int     screen_space;
    int     orig_font_size;
    float   currentTemperatureThreshold;
    
    NSMutableDictionary *buttonsDict;
    NSMutableDictionary *viewsDict;
    NSMutableDictionary *labelsDict;
    NSMutableDictionary *numbersDict;
    NSArray *buttonsArrayByTag;

    AVAudioPlayer *alarmNoise;
    
}

@property (strong, nonatomic) IBOutlet UIImageView *batteryIconView;
@property (strong, nonatomic) IBOutlet UIImageView *wifiIcon;
@property (strong, nonatomic) IBOutlet UIButton    *messages;
@property (strong, nonatomic) IBOutlet UIButton    *settings;
@property (strong, nonatomic) IBOutlet UIButton    *records;
@property (strong, nonatomic) IBOutlet UIButton    *accounts;
@property (strong, nonatomic) IBOutlet UIButton    *patients;
@property (strong, nonatomic) IBOutlet UIButton    *FCToggle;
@property (strong, nonatomic) IBOutlet UIButton    *alarmButton;
@property (strong, nonatomic) IBOutlet UIButton    *totalCover;
@property (strong, nonatomic) UIButton *topBar;
@property (strong, nonatomic) SettingsViewController *settingsVC;
@property (strong, nonatomic) RecordsViewController  *recordsVC;
@property (strong, nonatomic) UILabel              *patientLabel;
@property (strong, nonatomic) NSDictionary         *wifiData;

@property (strong, nonatomic) UILabel *PULSEunits;
@property (strong, nonatomic) UILabel *PULSEnumber;

@property (strong, nonatomic) UILabel *BPunits;
@property (strong, nonatomic) UILabel *BPnumber;
@property (strong, nonatomic) UILabel *BPnumber2;

@property BOOL increment;

@property int lockTimer;
@property float lockThreshold;
@property BOOL alarmHasBeenSetOffForCurrentThreshold;
 
@end