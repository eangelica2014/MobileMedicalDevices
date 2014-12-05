//
//  SettingsViewController.h
//  resize_test
//
//  Created by Inbar Fried on 11/20/14.
//  Copyright (c) 2014 Team4. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController

@property (strong, nonatomic) UILabel   *ThresholdLabel;
@property (strong, nonatomic) NSNumber  *currentThreshold;
@property (strong, nonatomic) UIStepper *stepper;

@property (strong, nonatomic) UILabel   *lockThresholdLabel;
@property (strong, nonatomic) UIStepper *lockStepper;
@property (strong, nonatomic) NSNumber  *currentLockThreshold;

@property int  tempUnits; // 0 = F, 1 = C
@property int  oldTempUnits; // 0 = F, 1 = C

@property BOOL lockNow;

@property (strong, nonatomic) IBOutlet UIPickerView   *alarmPicker;
@property (strong, nonatomic)          NSArray *alarmType;
@property (strong, nonatomic)          NSMutableArray *alarmValue;

- (float) returnCurrentTempThreshold;
- (float) returnCurrentLockThreshold;
    
@end

