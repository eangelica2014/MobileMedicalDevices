//
//  TAViewController.m
//  TempAssure
//
//  Created by Alexander B. Henry on 9/18/14.
//  Copyright (c) 2014 Alexander Henry. All rights reserved.
//

#import "TAViewController.h"

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0)
#define arduinoTemperatureURL [NSURL URLWithString: @"http://10.3.14.177/"]

@interface TAViewController ()

@end

@implementation TAViewController

// viewDidLoad is called when the View Controller is loaded
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    alarmOn = [UIImage imageNamed:@"SoundON.png"];
    unitFBG = [UIImage imageNamed: @"MMD_0005_F_C.png"];
    unitCBG = [UIImage imageNamed: @"MMD_0006_C_F.png"];
    alarmOnBG = [UIImage imageNamed: @"MMD_0014_Cancel-Alarm.png"];
    alarmOffBG = [UIImage imageNamed: @"MMD_0015_Set-Alarm.png"];
    alarmOnBanner = [UIImage imageNamed:@"MMD_0004_Alarm-On-Banner.png"];
    alarmOffBanner = [UIImage imageNamed:@"MMD_0003_Alarm-Off-Banner.png"];
    battery1BG = [UIImage imageNamed:@"MMD_0012_battery1BG.png"];
    battery2BG = [UIImage imageNamed:@"MMD_0011_battery2BG.png"];
    battery3BG = [UIImage imageNamed:@"MMD_0010_battery3BG.png"];
    battery4BG = [UIImage imageNamed:@"MMD_0009_battery4BG.png"];
    
    self.alarmFlag = false; // alarm has not gone off yet
    alarmSound = [self setupAudioPlayerWithFile:@"alarm" type:@"mp3"];
    self.alarmButtonBG.image = alarmOnBG;
    self.alarmBanner.image = alarmOnBanner;
    
    self.unitFlag = false;
    self.unitButtonBG.image = unitFBG;
    
    self.batteryFlag = false;
    self.newPatientFlag = false;
    
    self.thresholdTemp = 90.0;
    
    //[self accessTestData];
    //[self accessURLData];
    //[NSTimer scheduledTimerWithTimeInterval: 1.0 target:self selector:@selector(accessTestData) userInfo: nil repeats:YES];
    [NSTimer scheduledTimerWithTimeInterval: 3.0 target:self selector:@selector(accessURLData) userInfo: nil repeats:YES];
}

// accessURLData sends a get request to the URL and calls displayData if data is valid
- (void)accessURLData {
    NSLog(@"Attempting to access URL data ...");
    dispatch_async(kBgQueue, ^{
        //NSURLSession?
        NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:arduinoTemperatureURL];
        [request setHTTPMethod:@"GET"];
        [request setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"content-type"];
    
        NSError *err;
        NSURLResponse *response;
    
        NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
        if (responseData == nil) {
            NSLog(@"Failed.");
            return;
        }
        
        NSError* error;
        NSDictionary* jsonData = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];

        [self performSelectorOnMainThread:@selector(setData:) withObject:jsonData waitUntilDone:YES];
    });
}

// accessTestData creates test data
- (void)accessTestData {
    
    // Create the dictionary of test values
    NSDictionary *jsonData = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"90.6",@"currentTemp",@"91.2",@"oneTemp",@"89.1",@"tenTemp",@"60",@"batteryVolt",nil];

    [self performSelectorOnMainThread:@selector(setData:) withObject:jsonData waitUntilDone:YES];
}

// setData will temporarily store incoming temperature readings
- (void)setData:(NSDictionary *) jsonData {
    
    // Get the temperatures from dictionary
    self.currentTemp = [[jsonData objectForKey:@"currentTemp"] floatValue];
    self.oneSecAvgTemp = [[jsonData objectForKey:@"oneTemp"] floatValue];
    self.tenSecAvgTemp = [[jsonData objectForKey:@"tenTemp"] floatValue];
    self.batteryVolt = [[jsonData objectForKey:@"batteryVolt"] floatValue];

    [self displayConvertData];
    [self displayBattery];
    
    if ((self.oneSecAvgTemp >= self.thresholdTemp) && (self.alarmFlag == false)) {
        [self activateAlarm];
    }

}

// displayConvertData will display the readings on the storyboard depending on unitFlag
- (void) displayConvertData {
    if (self.newPatientFlag == false) {
        if (self.unitFlag == false) {
            self.currentTempLabel.text = [NSString stringWithFormat:@"%1.1f", self.currentTemp];
            self.oneSecAvgTempLabel.text = [NSString stringWithFormat:@"%1.1f", self.oneSecAvgTemp];
            self.tenSecAvgTempLabel.text = [NSString stringWithFormat:@"%1.1f", self.tenSecAvgTemp];
            self.currentUnitLabel.text = @"°F";
            self.oneSecAvgUnitLabel.text = @"°F";
            self.tenSecAvgUnitLabel.text = @"°F";
            self.unitButtonBG.image = unitFBG;
        }
        else {
            self.currentTempLabel.text = [NSString stringWithFormat:@"%1.1f", (self.currentTemp-32)*5/9];
            self.oneSecAvgTempLabel.text = [NSString stringWithFormat:@"%1.1f", (self.oneSecAvgTemp-32)*5/9];
            self.tenSecAvgTempLabel.text = [NSString stringWithFormat:@"%1.1f", (self.tenSecAvgTemp-32)*5/9];
            self.currentUnitLabel.text = @"°C";
            self.oneSecAvgUnitLabel.text = @"°C";
            self.tenSecAvgUnitLabel.text = @"°C";
            self.unitButtonBG.image = unitCBG;
        }
    }
}

// displayBattery will display the appropriate battery image
- (void) displayBattery {
    if (self.batteryVolt < 25) {
        self.batteryBG.image = battery1BG;
        if (!self.batteryFlag) {
            [self activateBatteryWarning];
            self.batteryFlag = true;
        }
    }
    else if (self.batteryVolt < 50) {
        self.batteryBG.image = battery2BG;
    }
    else if (self.batteryVolt < 75) {
        self.batteryBG.image = battery3BG;
    }
    else {
        self.batteryBG.image = battery4BG;
    }
}

// displayAlarm will display the appropriate alarm banner and button views
- (void) displayAlarm {
    if (self.alarmFlag) {
        self.alarmButtonBG.image = alarmOffBG;
        self.alarmBanner.image = alarmOffBanner;
    }
    else {
        self.alarmButtonBG.image = alarmOnBG;
        self.alarmBanner.image = alarmOnBanner;
    }
}

// activateBatteryWarning is called when battery is low
- (void)activateBatteryWarning {
    UIAlertView *batteryWindow = [[UIAlertView alloc] initWithTitle:@"Low Battery"
                                                          message:@"The armband battery is low, please replace"
                                                         delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    [batteryWindow setTag:2];
    [batteryWindow show];
}

// activateAlarm is called when alarm turns on
- (void)activateAlarm {
    UIAlertView *alarmWindow = [[UIAlertView alloc] initWithTitle:@"Patient has a fever!"
                                                message:[NSString stringWithFormat:@"Temperature is %1.1f °F", self.oneSecAvgTemp]
                                                delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    [alarmWindow setTag:1];
    self.alarmFlag = true; // alarm is currently going off
    [alarmWindow show];
    [alarmSound play];
}

// activateThreshold creates an alert view that requests a temperature threshold as input
- (void) activateThreshold {
    NSString * thresholdMessage = @"°F";
    if (self.unitFlag) {
        thresholdMessage = @"°C";
    }
    
    UIAlertView *thresholdWindow = [[UIAlertView alloc] initWithTitle: @"Alarm" message:[NSString stringWithFormat:@"Set new alarm threshold in %@",thresholdMessage] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Set",nil];
    thresholdWindow.alertViewStyle = UIAlertViewStylePlainTextInput;
    [thresholdWindow setTag:4];
    
    UITextField *textField = [thresholdWindow textFieldAtIndex:0];
    textField.keyboardType = UIKeyboardTypeNumberPad;
    
    [thresholdWindow show];
}

// activateNewPatient is called when new patient button is pressed to load alert window
- (void) activateNewPatient {
    self.newPatientFlag = true;
    
    UIAlertView *patientWindow = [[UIAlertView alloc] initWithTitle: @"Please wait" message: @"Loading..." delegate:self cancelButtonTitle: nil otherButtonTitles: nil];
    [patientWindow setTag:3];

    self.currentTempLabel.text = @"---";
    self.oneSecAvgTempLabel.text = @"---";
    self.tenSecAvgTempLabel.text = @"---";
    
    [patientWindow show];
    [self performSelector:@selector(dismissNewPatient:) withObject:patientWindow afterDelay:10];
}

// dismissNewPatient hides new patient window
- (void)dismissNewPatient:(UIAlertView*)alertView {
	[alertView dismissWithClickedButtonIndex:-1 animated:YES];
    self.newPatientFlag = false;
}

// alertView: clickedButtonAtIndex: is called when any alertView is clicked ... identifiers below
// tag 1: alarmWindow; tag 2: batteryWindow; tag 3: patientWindow; tag 4: thresholdWindow;
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([alertView tag] == 1) {
        [alarmSound stop];
        self.alarmFlag = true;
        [self displayAlarm];
    }
    if ( ([alertView tag] == 4) && (buttonIndex == 1) ){
        NSScanner *scanner = [NSScanner scannerWithString:[[alertView textFieldAtIndex:0] text]];
        bool isNumeric = [scanner scanDouble:NULL] && [scanner isAtEnd];
        
        if (isNumeric) {
            self.thresholdTemp = [[[alertView textFieldAtIndex:0] text] floatValue];
            if (self.unitFlag) {
                self.thresholdTemp = (self.thresholdTemp*9/5)+32;
            }
            self.alarmFlag = !self.alarmFlag;
            [self displayAlarm];
        }
    }
}

// resetAlarm is called when reset alarm button is pushed (ie. when nurse leaves room)
- (IBAction) resetAlarm:(id)sender {
    if (self.alarmFlag) { // trying to turn on the alarm
        [self activateThreshold];
    }
    else {
        self.alarmFlag = !self.alarmFlag;
        [self displayAlarm];
    }
}

// toggleEnabledForSwitchUnit is called when the C/F button is pushed and changes units
- (IBAction) toggleSwitchAndFormatUnits:(id)sender  {
    self.unitFlag = !self.unitFlag;
    [self displayConvertData];
}

// selectNewPatient is called when new patient button is pushed
- (IBAction)selectNewPatient:(id)sender {
    [self activateNewPatient];
}

// setupAudioPlayerWithFile sets up the audio file
- (AVAudioPlayer *)setupAudioPlayerWithFile:(NSString *)file type:(NSString *)type
{
    NSString *path = [[NSBundle mainBundle] pathForResource:file ofType:type];
    NSURL *url = [NSURL fileURLWithPath:path];
    
    NSError *error;
    AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    
    if (!audioPlayer) {
        NSLog(@"%@",[error description]);
    }
    return audioPlayer;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
