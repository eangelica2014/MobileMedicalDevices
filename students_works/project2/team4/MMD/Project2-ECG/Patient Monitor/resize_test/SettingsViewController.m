//
//  SettingsViewController.m
//  resize_test
//
//  Created by Inbar Fried on 11/20/14.
//  Copyright (c) 2014 Team4. All rights reserved.
//

#import "SettingsViewController.h"
#import "ViewController.h"

@interface SettingsViewController () <UIPickerViewDelegate>

@end

@implementation SettingsViewController


- (void) initializeAlarmPicker {
    // the threshold label
    self.currentThreshold = [NSNumber numberWithFloat: 100.0];
    UILabel *ThresholdLabel = [[UILabel alloc] init];
    [ThresholdLabel setFrame:CGRectMake(90, 10, 150, 20)];
    [ThresholdLabel setText:@"Alarm Threshold"];
    [ThresholdLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:18]];
    [self.view addSubview:ThresholdLabel];
    
    self.alarmType    = @[@"TEMP", @"ECG", @"PULSE", @"SPO2", @"BP"];
    self.alarmPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(40,20,100,100)];
    self.alarmPicker.showsSelectionIndicator = YES;
    self.alarmPicker.delegate = self;
    [self.view addSubview:self.alarmPicker];
}

- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.alarmType count];
}

- (NSString*) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [self.alarmType objectAtIndex:row];
}

/*
- (void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (component == 1)
        self.currentThreshold = [NSNumber numberWithFloat: [[self.alarmValue objectAtIndex:row] floatValue]];
}*/

- (void) myInitialization {
    self.oldTempUnits = 0; // start with F
    self.lockNow = false;

    [self initializeAlarmPicker];
    [self initializeTempThresholdItems];
    [self initializeLockThresholdItems];
    [self initializeLines];
    
    UIButton *resetbutton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [resetbutton setFrame:CGRectMake(50, 340, 200, 40)];
    [resetbutton setTitle:@"Lock Screen" forState:UIControlStateNormal];
    [resetbutton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:30]];
    [resetbutton addTarget:self action: @selector(respondToScreenLock:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:resetbutton];
    
    UIButton *defaultSettings = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [defaultSettings setFrame:CGRectMake(50,395,200,40)];
    [defaultSettings setTitle:@"Default View" forState:UIControlStateNormal];
    [defaultSettings.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:30]];
    [self.view addSubview:defaultSettings];
}

- (void) respondToScreenLock: (UIButton *) sender {
    self.lockNow = true;
}

- (void) respondToStepper: (UIStepper *) sender {
    [self.ThresholdLabel setText:[NSString stringWithFormat:@"%0.1f°", [sender value]]];
    self.currentThreshold = [NSNumber numberWithFloat: [sender value]];
}

- (void) initializeTempThresholdItems {
    // the stepper element
    self.stepper = [[UIStepper alloc] init];
    self.stepper.frame = CGRectMake(170, 115, 100, 10);
    [self.stepper addTarget:self action:@selector(respondToStepper:)forControlEvents:UIControlEventValueChanged];
    self.stepper.maximumValue = 200;
    [self.stepper setValue:[self.currentThreshold floatValue]];
    [self.view addSubview: self.stepper];
    
    // the number being displayed
    self.ThresholdLabel = [[UILabel alloc] init];
    [self.ThresholdLabel setFrame:CGRectMake(180, 26, 120, 100)];
    [self.ThresholdLabel setText:[NSString stringWithFormat:@"%0.1f°", [self.stepper value]]];
    [self.ThresholdLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:40]];
    [self.view addSubview:self.ThresholdLabel];
}

- (void) initializeLockThresholdItems {
    // the threshold label
    self.currentLockThreshold = [NSNumber numberWithFloat: 1.0];
    UILabel *lockThresholdLabel = [[UILabel alloc] init];
    [lockThresholdLabel setFrame:CGRectMake(55, 140, 250, 100)];
    [lockThresholdLabel setText:@"Screen Lock Threshold"];
    [lockThresholdLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:18]];
    [self.view addSubview:lockThresholdLabel];
    
    UILabel *timeUnits = [[UILabel alloc] init];
    [timeUnits setFrame:CGRectMake(200, 235, 100, 20)];
    [timeUnits setText:@"Minutes"];
    [timeUnits setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:12]];
    [self.view addSubview:timeUnits];
    
    // the stepper element
    self.lockStepper = [[UIStepper alloc] init];
    self.lockStepper.frame = CGRectMake(100, 280, 100, 10);
    [self.lockStepper addTarget:self action:@selector(respondToLockStepper:)forControlEvents:UIControlEventValueChanged];
    self.lockStepper.maximumValue = 200;
    [self.lockStepper setValue:[self.currentLockThreshold floatValue]];
    [self.view addSubview: self.lockStepper];
    
    // the number being displayed
    self.lockThresholdLabel = [[UILabel alloc] init];
    [self.lockThresholdLabel setFrame:CGRectMake(120, 185, 100, 100)];
    [self.lockThresholdLabel setText:[NSString stringWithFormat:@"%0.1f", [self.lockStepper value]]];
    [self.lockThresholdLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:40]];
    [self.view addSubview:self.lockThresholdLabel];

}

- (void) respondToLockStepper: (UIStepper *) sender {
    [self.lockThresholdLabel setText:[NSString stringWithFormat:@"%0.1f", [sender value]]];
    self.currentLockThreshold = [NSNumber numberWithFloat: [sender value]];
}

- (void) initializeLines {
    UIView *lineView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 170, self.view.bounds.size.width, 1)];
    lineView1.backgroundColor = [UIColor blackColor];
    [self.view addSubview:lineView1];
    UIView *lineView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 330, self.view.bounds.size.width, 1)];
    lineView2.backgroundColor = [UIColor blackColor];
    [self.view addSubview:lineView2];
    UIView *lineView3 = [[UIView alloc] initWithFrame:CGRectMake(0, 390, self.view.bounds.size.width, 1)];
    lineView3.backgroundColor = [UIColor blackColor];
    [self.view addSubview:lineView3];
}

- (void) convertToCelsius {
    float convertedTemp = ([self.ThresholdLabel.text floatValue] - 32.0) * (5.0/9.0);
    self.ThresholdLabel.text = [NSString stringWithFormat:@"%0.01f°", convertedTemp];
    self.stepper.value = convertedTemp;
}

- (void) convertToFahrenheit {
    float convertedTemp = ([self.ThresholdLabel.text floatValue] * (9.0/5.0)) + 32;
    self.ThresholdLabel.text = [NSString stringWithFormat:@"%0.01f°", convertedTemp];
    self.stepper.value = convertedTemp;
}

- (float) returnCurrentLockThreshold {
    return [self.currentLockThreshold floatValue];
}

- (float) returnCurrentTempThreshold {
    return [self.currentThreshold floatValue];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self myInitialization];
    }
    return self;
}

- (void) viewDidAppear:(BOOL)animated {
    if (self.tempUnits != self.oldTempUnits) {
        if (self.tempUnits == 0) [self convertToFahrenheit];
        else                     [self convertToCelsius];
        self.oldTempUnits = self.tempUnits;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
