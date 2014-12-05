//
//  AlarmOptions.m
//  Patient Monitor
//
//  Created by Ryan Dougherty on 12/2/14.
//  Copyright (c) 2014 team3. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AlarmOptions.h"

@interface AlarmOptions ()

@end

@implementation AlarmOptions

- (void)initializeAlarms{
    [self initializeDimentions];
    
    isBloodPressureOn = YES;
    isTemperatureOn = YES;
    isPulseOn = YES;
    isSPO2On = YES;
    [self makeAlarmWindow];
    [self addLabels];
    [self addToggles];
    [self addButtons];
    
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(checkThresholds:) userInfo:nil repeats:YES];
    
    alarmOptionsWindow.frame = CGRectMake(window.frame.size.width/2-window_width/2,window.frame.size.height,alarmOptionsWindow.frame.size.width,alarmOptionsWindow.frame.size.height);
    self.isAlarmWindowUp = isAlarmShowing;
}

-(void)initializeDimentions{
    highBloodPressure = 300;
    highTemperature = 100;
    highPulse = 130;
    highSPO2 = 3;
    
    lowBloodPressure = 10;
    lowTemperature = 97;
    lowPulse = 20;
    lowSPO2 = .4;
    
    window_width = window.frame.size.width*.75;
    window_height = window.frame.size.height*.75;
    frame_height = 150;
    
    toggle_width = 50;
    toggle_height = 25;
    
    label_height = 25;
    
    margin = 10;
    high_label_offset = 70;
    low_label_offset = 470;
    
    edit_button_width = 20;
    edit_button_height = 20;
    edit_high_offset = 180;
    edit_low_offset = 570;
    
}

-(void) makeAlarmWindow{
    // Create the window frame
    alarmOptionsWindow = [[UIView alloc]initWithFrame:CGRectMake(0, 0, window_width, window_height)];
    [alarmOptionsWindow setBackgroundColor:[UIColor whiteColor]];
    [main_screen addSubview:alarmOptionsWindow];
    
    // Create Menu Bar
    alarmText = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, alarmOptionsWindow.frame.size.width, frame_height)];
    
    // Change settings of menu bar
    [alarmText setTextAlignment:NSTextAlignmentCenter];
    [alarmText setText:@"Alarm Settings"];
    [alarmText setBackgroundColor:[UIColor colorWithRed:20/255.0 green:120/255.0 blue:200/255.0 alpha:1]];
    [alarmText setFont:[alarmText.font fontWithSize:64]];
    [alarmText setTextColor:[UIColor whiteColor]];
    // Add menu bar to view
    [alarmOptionsWindow addSubview:alarmText];
    
    // Create List Scrollable options List
    alarmScroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, frame_height, window_width, window_height-frame_height)];
    alarmScroll.contentSize=CGSizeMake(alarmScroll.frame.size.width,600);
   // [alarmScroll setBackgroundColor:[UIColor clearColor]];
    [alarmOptionsWindow addSubview:alarmScroll];
    

    alarmScroll.scrollEnabled = true;
    
    
    // Set up display toggle in options bar
    isWindowUp = false;
    [main_screen sendSubviewToBack:alarmOptionsWindow];
}

-(void)addLabels{
    UIColor *bannerColor =[UIColor colorWithRed:220/255.0 green:220/255.0 blue:250/255.0 alpha:1];
    // Section Labels
    BloodPressureLabel = [[UILabel alloc]initWithFrame:CGRectMake(margin, 0, 0, 0)];
    
    [BloodPressureLabel setText:@" Blood Pressure"];
    [BloodPressureLabel setFont:[BloodPressureLabel.font fontWithSize:30]];
    [alarmScroll addSubview:BloodPressureLabel];
    [BloodPressureLabel sizeToFit];
    [BloodPressureLabel setFrame:CGRectMake(0, BloodPressureLabel.frame.origin.y, window_width, BloodPressureLabel.frame.size.height)];
    [BloodPressureLabel setBackgroundColor:bannerColor];
    
    
    TemperatureLabel = [[UILabel alloc]initWithFrame:CGRectMake(margin, frame_height, 0, 0)];
    [TemperatureLabel setText:@" Temperature"];
    [TemperatureLabel setFont:[TemperatureLabel.font fontWithSize:30]];
    [alarmScroll addSubview:TemperatureLabel];
    [TemperatureLabel sizeToFit];
    [TemperatureLabel setFrame:CGRectMake(0, TemperatureLabel.frame.origin.y, window_width, TemperatureLabel.frame.size.height)];
    [TemperatureLabel setBackgroundColor:bannerColor];
    
    PulseLabel = [[UILabel alloc]initWithFrame:CGRectMake(margin, frame_height*2, window_width, label_height)];
    [PulseLabel setText:@" Pulse"];
    [PulseLabel setFont:[PulseLabel.font fontWithSize:30]];
    [alarmScroll addSubview:PulseLabel];
    [PulseLabel sizeToFit];
    [PulseLabel setFrame:CGRectMake(0, PulseLabel.frame.origin.y, window_width, PulseLabel.frame.size.height)];
    [PulseLabel setBackgroundColor:bannerColor];
    
    SpO2Label = [[UILabel alloc]initWithFrame:CGRectMake(margin, frame_height*3, window_width, label_height)];
    [SpO2Label setText:@" SpO2"];
    [SpO2Label setFont:[SpO2Label.font fontWithSize:30]];
    [alarmScroll addSubview:SpO2Label];
    [SpO2Label sizeToFit];
    [SpO2Label setFrame:CGRectMake(0, SpO2Label.frame.origin.y, window_width, SpO2Label.frame.size.height)];
    [SpO2Label setBackgroundColor:bannerColor];
    
    // High Bound Labels
    highBloodLabel = [[UILabel alloc]initWithFrame:CGRectMake(high_label_offset, frame_height/2-label_height/2, 0, 0)];
    
    [highBloodLabel setText:[@"High: " stringByAppendingString:[NSString stringWithFormat:@"%.f",highBloodPressure]]];
    [highBloodLabel setFont:[highBloodLabel.font fontWithSize:24]];
    [alarmScroll addSubview:highBloodLabel];
    [highBloodLabel sizeToFit];
    
    highTempLabel = [[UILabel alloc]initWithFrame:CGRectMake(high_label_offset, frame_height*1.5-label_height/2, 0, 0)];
    [highTempLabel setText:[@"High: " stringByAppendingString:[NSString stringWithFormat:@"%.f",highTemperature]]];
    [highTempLabel setFont:[highTempLabel.font fontWithSize:24]];
    [alarmScroll addSubview:highTempLabel];
    [highTempLabel sizeToFit];
    
    highPulseLabel = [[UILabel alloc]initWithFrame:CGRectMake(high_label_offset, frame_height*2.5-label_height/2, window_width, label_height)];
    [highPulseLabel setText:[@"High: " stringByAppendingString:[NSString stringWithFormat:@"%.f",highPulse]]];
    [highPulseLabel setFont:[highPulseLabel.font fontWithSize:24]];
    [alarmScroll addSubview:highPulseLabel];
    [highPulseLabel sizeToFit];
    
    highSpO2Label = [[UILabel alloc]initWithFrame:CGRectMake(high_label_offset, frame_height*3.5-label_height/2, window_width, label_height)];
    [highSpO2Label setText:[@"High: " stringByAppendingString:[NSString stringWithFormat:@"%.f",highSPO2]]];
    [highSpO2Label setFont:[highSpO2Label.font fontWithSize:24]];
    [alarmScroll addSubview:highSpO2Label];
    [highSpO2Label sizeToFit];
    
    // Low Bound Labels
    lowBloodLabel = [[UILabel alloc]initWithFrame:CGRectMake(low_label_offset, frame_height/2-label_height/2, 0, 0)];
    
    [lowBloodLabel setText:[@"Low: " stringByAppendingString:[NSString stringWithFormat:@"%.f",lowBloodPressure]]];
    [lowBloodLabel setFont:[lowBloodLabel.font fontWithSize:24]];
    [alarmScroll addSubview:lowBloodLabel];
    [lowBloodLabel sizeToFit];
    
    lowTempLabel = [[UILabel alloc]initWithFrame:CGRectMake(low_label_offset, frame_height*1.5-label_height/2, 0, 0)];
    [lowTempLabel setText:[@"Low: " stringByAppendingString:[NSString stringWithFormat:@"%.f",lowTemperature]]];
    [lowTempLabel setFont:[lowTempLabel.font fontWithSize:24]];
    [alarmScroll addSubview:lowTempLabel];
    [lowTempLabel sizeToFit];
    
    lowPulseLabel = [[UILabel alloc]initWithFrame:CGRectMake(low_label_offset, frame_height*2.5-label_height/2, window_width, label_height)];
    [lowPulseLabel setText:[@"Low: " stringByAppendingString:[NSString stringWithFormat:@"%.f",lowPulse]]];
    [lowPulseLabel setFont:[lowPulseLabel.font fontWithSize:24]];
    [alarmScroll addSubview:lowPulseLabel];
    [lowPulseLabel sizeToFit];
    
    lowSpO2Label = [[UILabel alloc]initWithFrame:CGRectMake(low_label_offset, frame_height*3.5-label_height/2, window_width, label_height)];
    [lowSpO2Label setText:[@"Low: " stringByAppendingString:[NSString stringWithFormat:@"%.f",lowSPO2]]];
    [lowSpO2Label setFont:[lowSpO2Label.font fontWithSize:24]];
    [alarmScroll addSubview:lowSpO2Label];
    [lowSpO2Label sizeToFit];
}

-(void)addButtons{
    editHighBloodPressure = [[UIButton alloc]initWithFrame:CGRectMake(edit_high_offset, frame_height*.5-edit_button_height/2, edit_button_width, edit_button_height)];
    [editHighBloodPressure addTarget:self action:@selector(EditClicked:) forControlEvents:UIControlEventTouchUpInside];
    [editHighBloodPressure setBackgroundImage:[UIImage imageNamed:@"editicon.png"] forState:UIControlStateNormal];
    [alarmScroll addSubview:editHighBloodPressure];
    
    editHighTemperature = [[UIButton alloc]initWithFrame:CGRectMake(edit_high_offset, frame_height*1.5-edit_button_height/2, edit_button_width, edit_button_height)];
    [editHighTemperature addTarget:self action:@selector(EditClicked:) forControlEvents:UIControlEventTouchUpInside];
    [editHighTemperature setBackgroundImage:[UIImage imageNamed:@"editicon.png"] forState:UIControlStateNormal];
    [alarmScroll addSubview:editHighTemperature];
    
    editHighPulse = [[UIButton alloc]initWithFrame:CGRectMake(edit_high_offset, frame_height*2.5-edit_button_height/2, edit_button_width, edit_button_height)];
    [editHighPulse addTarget:self action:@selector(EditClicked:) forControlEvents:UIControlEventTouchUpInside];
    [editHighPulse setBackgroundImage:[UIImage imageNamed:@"editicon.png"] forState:UIControlStateNormal];
    [alarmScroll addSubview:editHighPulse];
    
    editHighSPO2 = [[UIButton alloc]initWithFrame:CGRectMake(edit_high_offset, frame_height*3.5-edit_button_height/2, edit_button_width, edit_button_height)];
    [editHighSPO2 addTarget:self action:@selector(EditClicked:) forControlEvents:UIControlEventTouchUpInside];
    [editHighSPO2 setBackgroundImage:[UIImage imageNamed:@"editicon.png"] forState:UIControlStateNormal];
    [alarmScroll addSubview:editHighSPO2];
    
    //Low
    
    editLowBloodPressure = [[UIButton alloc]initWithFrame:CGRectMake(edit_low_offset, frame_height*.5-edit_button_height/2, edit_button_width, edit_button_height)];
    [editLowBloodPressure addTarget:self action:@selector(EditClicked:) forControlEvents:UIControlEventTouchUpInside];
    [editLowBloodPressure setBackgroundImage:[UIImage imageNamed:@"editicon.png"] forState:UIControlStateNormal];
    [alarmScroll addSubview:editLowBloodPressure];
    
    editLowTemperature = [[UIButton alloc]initWithFrame:CGRectMake(edit_low_offset, frame_height*1.5-edit_button_height/2, edit_button_width, edit_button_height)];
    [editLowTemperature addTarget:self action:@selector(EditClicked:) forControlEvents:UIControlEventTouchUpInside];
    [editLowTemperature setBackgroundImage:[UIImage imageNamed:@"editicon.png"] forState:UIControlStateNormal];
    [alarmScroll addSubview:editLowTemperature];
    
    editLowPulse = [[UIButton alloc]initWithFrame:CGRectMake(edit_low_offset, frame_height*2.5-edit_button_height/2, edit_button_width, edit_button_height)];
    [editLowPulse addTarget:self action:@selector(EditClicked:) forControlEvents:UIControlEventTouchUpInside];
    [editLowPulse setBackgroundImage:[UIImage imageNamed:@"editicon.png"] forState:UIControlStateNormal];
    [alarmScroll addSubview:editLowPulse];
    
    editLowSPO2 = [[UIButton alloc]initWithFrame:CGRectMake(edit_low_offset, frame_height*3.5-edit_button_height/2, edit_button_width, edit_button_height)];
    [editLowSPO2 addTarget:self action:@selector(EditClicked:) forControlEvents:UIControlEventTouchUpInside];
    [editLowSPO2 setBackgroundImage:[UIImage imageNamed:@"editicon.png"] forState:UIControlStateNormal];
    [alarmScroll addSubview:editLowSPO2];
}

-(void)addToggles{
    BloodPressureToggle = [[UISwitch alloc]initWithFrame:CGRectMake(margin,-toggle_height/2+frame_height*.5, toggle_width, toggle_height)];
    [BloodPressureToggle addTarget:self action:@selector(ToggleSwitched:) forControlEvents:UIControlEventTouchUpInside];
    [BloodPressureToggle setOn:isBloodPressureOn];
    [alarmScroll addSubview:BloodPressureToggle];
    
    TemperatureToggle = [[UISwitch alloc]initWithFrame:CGRectMake(margin,-toggle_height/2+frame_height*1.5, toggle_width, toggle_height)];
    [TemperatureToggle addTarget:self action:@selector(ToggleSwitched:) forControlEvents:UIControlEventTouchUpInside];
    [TemperatureToggle setOn:isTemperatureOn];
    [alarmScroll addSubview:TemperatureToggle];
    
    PulseToggle = [[UISwitch alloc]initWithFrame:CGRectMake(margin,-toggle_height/2+frame_height*2.5, toggle_width, toggle_height)];
    [PulseToggle addTarget:self action:@selector(ToggleSwitched:) forControlEvents:UIControlEventTouchUpInside];
    [PulseToggle setOn:isPulseOn];
    [alarmScroll addSubview:PulseToggle];
    
    SPO2Toggle = [[UISwitch alloc]initWithFrame:CGRectMake(margin,-toggle_height/2+frame_height*3.5, toggle_width, toggle_height)];
    [SPO2Toggle addTarget:self action:@selector(ToggleSwitched:) forControlEvents:UIControlEventTouchUpInside];
    [SPO2Toggle setOn:isSPO2On];
    [alarmScroll addSubview:SPO2Toggle];
}

- (void)EditClicked:(UIButton*)sender{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Change Alarm Threshold" message:@"Please enter a new threshold:" delegate:self cancelButtonTitle:@"Update" otherButtonTitles:nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField * alertTextField = [alert textFieldAtIndex:0];
    alertTextField.keyboardType = UIKeyboardTypeNumberPad;
    alertTextField.placeholder = @"Enter new value";
    
    // High bounds
    if(sender == editHighBloodPressure){
        [alert setTag:1];
    }
    if(sender == editHighPulse){
        [alert setTag:2];
    }
    if(sender == editHighTemperature){
        [alert setTag:3];
    }
    if(sender == editHighSPO2){
        [alert setTag:4];
    }
    
    // Low bounds
    if(sender == editLowBloodPressure){
        [alert setTag:5];
    }
    if(sender == editLowPulse){
        [alert setTag:6];
    }
    if(sender == editLowTemperature){
        [alert setTag:7];
    }
    if(sender == editLowSPO2){
        [alert setTag:8];
    }
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{

    // Changes from menu
    if(alertView.tag == 1){
        highBloodPressure = [[[alertView textFieldAtIndex:0]text] floatValue];
        
        [highBloodLabel setText:[@"High: " stringByAppendingString:[NSString stringWithFormat:@"%.f",highBloodPressure]]];
    }
    if(alertView.tag == 2){
        highPulse = [[[alertView textFieldAtIndex:0]text] floatValue];
        
        [highPulseLabel setText:[@"High: " stringByAppendingString:[NSString stringWithFormat:@"%.f",highPulse]]];
    }
    if(alertView.tag == 3){
        highTemperature = [[[alertView textFieldAtIndex:0]text] floatValue];
        
        [highTempLabel setText:[@"High: " stringByAppendingString:[NSString stringWithFormat:@"%.f",highTemperature]]];
    }
    if(alertView.tag == 4){
        highSPO2 = [[[alertView textFieldAtIndex:0]text] floatValue];;
        
        [highSpO2Label setText:[@"High: " stringByAppendingString:[NSString stringWithFormat:@"%.f",highSPO2]]];
    }
    if(alertView.tag == 5){
        lowBloodPressure = [[[alertView textFieldAtIndex:0]text] floatValue];;
        
        [lowBloodLabel setText:[@"Low: " stringByAppendingString:[NSString stringWithFormat:@"%.f",lowBloodPressure]]];
    }
    if(alertView.tag == 6){
        lowPulse = [[[alertView textFieldAtIndex:0]text] floatValue];;
        
        [lowPulseLabel setText:[@"Low: " stringByAppendingString:[NSString stringWithFormat:@"%.f",lowPulse]]];
    }
    if(alertView.tag == 7){
        lowTemperature = [[[alertView textFieldAtIndex:0]text] floatValue];;
        
        [lowTempLabel setText:[@"Low: " stringByAppendingString:[NSString stringWithFormat:@"%.f",lowTemperature]]];
    }
    if(alertView.tag == 8){
        lowSPO2 = [[[alertView textFieldAtIndex:0]text] floatValue];;
        
        [lowSpO2Label setText:[@"Low: " stringByAppendingString:[NSString stringWithFormat:@"%.f",lowSPO2]]];
    }
    if(alertView.tag == 9){
        if(buttonIndex == 0){
            isBloodPressureOn = false;
            [BloodPressureToggle setOn:isBloodPressureOn];
            isAlarmShowing = false;
        }else{
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Change Alarm Threshold" message:@"Please enter a new threshold:" delegate:self cancelButtonTitle:@"Update" otherButtonTitles:nil];
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            UITextField * alertTextField = [alert textFieldAtIndex:0];
            alertTextField.keyboardType = UIKeyboardTypeNumberPad;
            alertTextField.placeholder = @"Enter new value";
            [alert setTag:1];
            [alert show];
        }
    }
    
    // Changes from alerts
    if(alertView.tag == 10){
        if(buttonIndex == 0){
            isBloodPressureOn = false;
            [BloodPressureToggle setOn:isBloodPressureOn];
            isAlarmShowing = false;
        }else{
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Change Alarm Threshold" message:@"Please enter a new threshold:" delegate:self cancelButtonTitle:@"Update" otherButtonTitles:nil];
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            UITextField * alertTextField = [alert textFieldAtIndex:0];
            alertTextField.keyboardType = UIKeyboardTypeNumberPad;
            alertTextField.placeholder = @"Enter new value";
            [alert setTag:5];
            [alert show];
        }
    }
    if(alertView.tag == 11){
        if(buttonIndex == 0){
            isTemperatureOn = false;
            [TemperatureToggle setOn:isTemperatureOn];
            isAlarmShowing = false;
        }else{
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Change Alarm Threshold" message:@"Please enter a new threshold:" delegate:self cancelButtonTitle:@"Update" otherButtonTitles:nil];
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            UITextField * alertTextField = [alert textFieldAtIndex:0];
            alertTextField.keyboardType = UIKeyboardTypeNumberPad;
            alertTextField.placeholder = @"Enter new value";
            [alert setTag:3];
            [alert show];
        }
    }
    if(alertView.tag == 12){
        if(buttonIndex == 0){
            isTemperatureOn = false;
            [TemperatureToggle setOn:isTemperatureOn];
            isAlarmShowing = false;
        }else{
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Change Alarm Threshold" message:@"Please enter a new threshold:" delegate:self cancelButtonTitle:@"Update" otherButtonTitles:nil];
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            UITextField * alertTextField = [alert textFieldAtIndex:0];
            alertTextField.keyboardType = UIKeyboardTypeNumberPad;
            alertTextField.placeholder = @"Enter new value";
            [alert setTag:7];
            [alert show];
        }
    }
    if(alertView.tag == 13){
        if(buttonIndex == 0){
            isPulseOn = false;
            [PulseToggle setOn:isPulseOn];
            isAlarmShowing = false;
        }else{
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Change Alarm Threshold" message:@"Please enter a new threshold:" delegate:self cancelButtonTitle:@"Update" otherButtonTitles:nil];
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            UITextField * alertTextField = [alert textFieldAtIndex:0];
            alertTextField.keyboardType = UIKeyboardTypeNumberPad;
            alertTextField.placeholder = @"Enter new value";
            [alert setTag:2];
            [alert show];
        }
    }
    if(alertView.tag == 14){
        if(buttonIndex == 0){
            isPulseOn = false;
            [PulseToggle setOn:isPulseOn];
            isAlarmShowing = false;
        }else{
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Change Alarm Threshold" message:@"Please enter a new threshold:" delegate:self cancelButtonTitle:@"Update" otherButtonTitles:nil];
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            UITextField * alertTextField = [alert textFieldAtIndex:0];
            alertTextField.keyboardType = UIKeyboardTypeNumberPad;
            alertTextField.placeholder = @"Enter new value";
            [alert setTag:6];
            [alert show];
        }
    }
    if(alertView.tag == 15){
        if(buttonIndex == 0){
            isSPO2On = false;
            [SPO2Toggle setOn:isSPO2On];
            isAlarmShowing = false;
        }else{
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Change Alarm Threshold" message:@"Please enter a new threshold:" delegate:self cancelButtonTitle:@"Update" otherButtonTitles:nil];
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            UITextField * alertTextField = [alert textFieldAtIndex:0];
            alertTextField.keyboardType = UIKeyboardTypeNumberPad;
            alertTextField.placeholder = @"Enter new value";
            [alert setTag:4];
            [alert show];
        }
    }
    if(alertView.tag == 16){
        if(buttonIndex == 0){
            isSPO2On = false;
            [SPO2Toggle setOn:isSPO2On];
            isAlarmShowing = false;
        }else{
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Change Alarm Threshold" message:@"Please enter a new threshold:" delegate:self cancelButtonTitle:@"Update" otherButtonTitles:nil];
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            UITextField * alertTextField = [alert textFieldAtIndex:0];
            alertTextField.keyboardType = UIKeyboardTypeNumberPad;
            alertTextField.placeholder = @"Enter new value";
            [alert setTag:8];
            [alert show];
        }
    }
    
    if(alertView.tag < 9){
        isAlarmShowing = false;
    }
}


- (void)ToggleSwitched:(UISwitch*)sender{
    if(sender == BloodPressureToggle){
        isBloodPressureOn = !isBloodPressureOn;
    }
    if(sender == TemperatureToggle){
        isTemperatureOn = !isTemperatureOn;
    }
    if(sender == PulseToggle){
        isPulseOn = !isPulseOn;
    }
    if(sender == SPO2Toggle){
        isSPO2On = !isSPO2On;
    }
}

- (void)ViewButtonPressed:(UIButton*)sender{
    [main_screen bringSubviewToFront:alarmOptionsWindow];
    if(!isWindowUp){
        
       // alarmOptionsWindow.frame = CGRectMake(window.frame.size.width/2-window_width/2,bottom_bar_y,alarmOptionsWindow.frame.size.width,alarmOptionsWindow.frame.size.height);
        alarmOptionsWindow.frame = CGRectMake(window.frame.size.width/2-window_width/2,window.frame.size.height,alarmOptionsWindow.frame.size.width,alarmOptionsWindow.frame.size.height);
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:.5];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        
        alarmOptionsWindow.frame = CGRectMake(window.frame.size.width/2-window_width/2, window.frame.size.height/2-window_height/2, window_width, window_height);
        
        [UIView commitAnimations];
    }else{
        
        alarmOptionsWindow.frame = CGRectMake(window.frame.size.width/2-window_width/2, window.frame.size.height/2-window_height/2, window_width, window_height);
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:.5];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        alarmOptionsWindow.frame = CGRectMake(window.frame.size.width/2-window_width/2,window.frame.size.height,alarmOptionsWindow.frame.size.width,alarmOptionsWindow.frame.size.height);
        [UIView commitAnimations];
        
    }
    isWindowUp = !isWindowUp;
    self.isAlarmWindowUp = isWindowUp;
}

- (void)checkThresholds:(NSTimer *)timer{
//   NSLog([NSString stringWithFormat:@"%f", _bloodPressure]);
//    NSLog([NSString stringWithFormat:@"%f", _temperature]);
//    NSLog([NSString stringWithFormat:@"%f", _pulse]);
//    NSLog([NSString stringWithFormat:@"%f", _spo2]);
   // NSLog(self.temperature);

    NSLog(@"checking");
    if(isAlarmShowing){
        NSLog(@"alarm is showing");
        return;
    }
    if(isBloodPressureOn){
        if(_bloodPressure > highBloodPressure){
            isAlarmShowing = YES;
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"High Blood Pressure" message:@"Blood pressure exceeded threshold" delegate:self cancelButtonTitle:@"Disable" otherButtonTitles:@"Change",nil];
            [alert setTag:9];
            [alert show];
        }
        if(_bloodPressure < lowBloodPressure){
            isAlarmShowing = YES;
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Low Blood Pressure" message:@"Blood pressure below threshold" delegate:self cancelButtonTitle:@"Disable" otherButtonTitles:@"Change",nil];
            [alert setTag:10];
            [alert show];
        }
    }
    if(isTemperatureOn){
        if(_temperature > highTemperature){
            isAlarmShowing = YES;
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"High Temperature" message:@"Temperature exceeded threshold" delegate:self cancelButtonTitle:@"Disable" otherButtonTitles:@"Change",nil];
            [alert setTag:11];
            [alert show];
        }
        if(_temperature < lowTemperature){
            isAlarmShowing = YES;
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Low Temperature" message:@"Temperature below threshold" delegate:self cancelButtonTitle:@"Disable" otherButtonTitles:@"Change",nil];
            [alert setTag:12];
            [alert show];
        }
    }
    if(isPulseOn){
        if(_pulse > highPulse){
            isAlarmShowing = YES;
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"High Heart Rate" message:@"Heart rate exceeded threshold" delegate:self cancelButtonTitle:@"Disable" otherButtonTitles:@"Change",nil];
            [alert setTag:13];
            [alert show];
        }
        if(_pulse < lowPulse){
            isAlarmShowing = YES;
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Low Heart Rate" message:@"Heart rate below threshold" delegate:self cancelButtonTitle:@"Disable" otherButtonTitles:@"Change",nil];
            [alert setTag:14];
            [alert show];
        }
    }
    if(isSPO2On){
        if(_spo2 > highSPO2){
            isAlarmShowing = YES;
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"High SpO2" message:@"SpO2 exceeded threshold" delegate:self cancelButtonTitle:@"Disable" otherButtonTitles:@"Change",nil];
            [alert setTag:15];
            [alert show];
        }
        if(_spo2 < lowSPO2){
            isAlarmShowing = YES;
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Low SpO2" message:@"SpO2 below threshold" delegate:self cancelButtonTitle:@"Disable" otherButtonTitles:@"Change",nil];
            [alert setTag:16];
            [alert show];
        }
    }


}

- (void) loadSoundFiles{
    // No sound files used...could do this if had more time
}

- (void) setMainView:(UIView*)view window:(UIWindow *)screen{
    main_screen = view;
    window = screen;
}

- (void) setButton:(UIButton*)button{
    showButton = button;
    [showButton addTarget:self action:@selector(ViewButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
}

@end