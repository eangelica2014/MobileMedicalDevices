//
//  AlarmOptions.h
//  Patient Monitor
//
//  Created by Ryan Dougherty on 12/2/14.
//  Copyright (c) 2014 team3. All rights reserved.
//

//#ifndef Patient_Monitor_AlarmOptions_h
//#define Patient_Monitor_AlarmOptions_h

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@interface AlarmOptions : NSObject{
    UIView *main_screen;
    UIWindow *window;
    
    // Inputs
   // float bloodPressure;
    //float temperature;
    //float pulse;
    //float spo2;
    
    // Thresholds
    float highBloodPressure;
    float highTemperature;
    float highPulse;
    float highSPO2;
    
    float lowBloodPressure;
    float lowTemperature;
    float lowPulse;
    float lowSPO2;
    
    // Enable/Disables
    BOOL isBloodPressureOn;
    BOOL isTemperatureOn;
    BOOL isPulseOn;
    BOOL isSPO2On;
    BOOL isAlarmShowing;
    
    // Window Options
    bool isWindowUp;
    float window_width;
    float window_height;
    float frame_height;
    float margin;
    
    UIView *alarmOptionsWindow;
    UIScrollView *alarmScroll;
    
    UILabel *alarmText;
    UIButton *alarmButton;
    
    // Labels
    float label_height;
    float high_label_offset;
    float low_label_offset;
    
    UILabel* BloodPressureLabel;
    UILabel* highBloodLabel;
    UILabel* lowBloodLabel;
    
    UILabel* TemperatureLabel;
    UILabel* highTempLabel;
    UILabel* lowTempLabel;
    
    UILabel* PulseLabel;
    UILabel* highPulseLabel;
    UILabel* lowPulseLabel;
    
    UILabel* SpO2Label;
    UILabel* highSpO2Label;
    UILabel* lowSpO2Label;
    
    // Edit Buttons
    float edit_button_width;
    float edit_button_height;
    float edit_high_offset;
    float edit_low_offset;
    
    UIButton* editHighBloodPressure;
    UIButton* editLowBloodPressure;
    
    UIButton* editHighTemperature;
    UIButton* editLowTemperature;

    UIButton* editHighPulse;
    UIButton* editLowPulse;
    
    UIButton* editHighSPO2;
    UIButton* editLowSPO2;
    
    // Toggles
    float toggle_width;
    float toggle_height;
    
    UISwitch *BloodPressureToggle;
    UISwitch *TemperatureToggle;
    UISwitch *PulseToggle;
    UISwitch *SPO2Toggle;
    
    UIButton *showButton;
    
}
@property (assign) float bloodPressure;
@property (assign) float temperature;
@property (assign) float pulse;
@property (assign) float spo2;
@property (assign) bool isAlarmWindowUp;

- (void) initializeAlarms;
- (void) setMainView:(UIView*)view window:(UIWindow*)screen;
- (void) setButton:(UIButton*)button;

@end

//#endif
