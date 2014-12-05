//
//  ViewController.m
//  DigitalThermometer
//
//  Created by Emily Quigley on 9/20/14.
//  Copyright (c) 2014 Emily Quigley. All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface ViewController ()
@property (strong, nonatomic) IBOutlet UILabel *CurrentT;
@property (strong, nonatomic) IBOutlet UILabel *Avg1;
@property (strong, nonatomic) IBOutlet UILabel *Avg10;
@property (strong, nonatomic) IBOutlet UISegmentedControl *toggle;
@property (strong, nonatomic) NSTimer *programTimer;
@property (strong, nonatomic) NSTimer *backgroundTimer;
@property (strong, nonatomic) IBOutlet UIView *attendingPatient;


@end

@implementation ViewController

/* ========== 'Attending to patient' button ========== */
- (IBAction) buttonPress: (UIButton *) sender {
    if (self.attendingPatient.hidden == false){
        self.attendingPatient.hidden = true;
    }
}

bool alarmPlaying    = false; // used to play alarm sound
bool alarmHasSounded = false; // used to reset alarm once temperature goes below threshold
NSDictionary *dict   = nil;

/* ========== Functions that deal with user notifications (alarm, alarm sound) ========== */
/* Generate the Audio Player object for the alarm */
- (AVAudioPlayer *) setupAudioPlayerWithFile:(NSString *)file type:(NSString *)type{
    NSString *path = [[NSBundle mainBundle] pathForResource:file ofType:type];
    NSURL *url = [NSURL fileURLWithPath:path];
    NSError *error;
    AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    if (!audioPlayer){
        NSLog(@"%@", [error description]);
    }
    return audioPlayer;
}

- (void) soundAlarm {
    alarmNoise      = [self setupAudioPlayerWithFile:@"beep_1" type:@"mp3"];
    alarmPlaying    = true;
    alarmHasSounded = true;
    [alarmNoise setVolume:0.3];
    [alarmNoise play];
}

- (void) stopAlarm {
    [alarmNoise stop];
    alarmPlaying = false;
}

- (void) resetAlarm {
    alarmHasSounded = false;
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    // alertView.tag 0 corresponds to the high temp, tag 1 is the WiFi connection
    if (buttonIndex == 0 && alertView.tag == 0) {
        [alertView dismissWithClickedButtonIndex:0 animated:NO];
        alertView = NULL;
        [self stopAlarm];
        // stop the flashing and revert to the original background color
        const CGFloat* colors = CGColorGetComponents(self.view.backgroundColor.CGColor);
        self.view.backgroundColor = [UIColor colorWithRed:(colors[0]) green:(colors[1]) blue:(colors[2]) alpha:1];
        [self.backgroundTimer invalidate];
        self.backgroundTimer = NULL;
        // display the attending patient button
        self.attendingPatient.hidden = false;
    }
    else if (alertView.tag == 1){
        if (buttonIndex == 0){
        // dismiss the WiFi connection alert
        }
        else if (buttonIndex == 1) {
         // try to reconnect the WiFi
        }
    }
}

/* Display the window with the Alarm Notification */
- (void) displayAlarm: (NSString *) alarmMessage {
    UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"ALERT"
                                                     message:alarmMessage
                                                    delegate:self
                                           cancelButtonTitle:@"Dismiss"
                                           otherButtonTitles: nil];
    [alert setTag: 0];
    // the WiFi disconnect alarm has the additional button option to reconnect
    if ([alarmMessage isEqualToString:@"WiFi Disconnected"]){
        [alert setTag: 1];
        [alert addButtonWithTitle:@"Reconnect"];
    }
    [alert show];
}

/* ========== Background Flashing ========== */
// Change the transperancy of the background from total to none every call, making a flashing appearance
- (void) flashBackground: (NSTimer *) timer {
    const CGFloat* colors = CGColorGetComponents(self.view.backgroundColor.CGColor);
    if (colors[3] == 1){
        self.view.backgroundColor = [UIColor colorWithRed:(colors[0]) green:(colors[1]) blue:(colors[2]) alpha:0];
    }
    else if (colors[3] == 0){
        self.view.backgroundColor = [UIColor colorWithRed:(colors[0]) green:(colors[1]) blue:(colors[2]) alpha:1];
    }
}
// Flash the background every 0.1 seconds while the alarm is going off by calling the function flashBackground
- (void) flashScreen {
    self.backgroundTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(flashBackground:) userInfo:nil repeats:YES];
}

/* ========== Functions that deal with temperature conversions, parsing, and rendering ========== */
/* convert between Celsius and Fahrenheit */
- (float) convertTemperature: (float) temp {
    // if we it is currently displaying Celsius
    if (self.toggle.selectedSegmentIndex == 0)
        temp = temp * (9.0/5.0) + 32.0;
    // if it is currently displaying Fahrenheit
    else if (self.toggle.selectedSegmentIndex == 1)
        temp = (temp - 32.0) * (5.0/9.0);
    return temp;
}

/* check if the current patient temperature has crossed the threshold */
- (BOOL) tempIsAboveThreshold {
    // if it is currently displaying Fahrenheit
    if (self.toggle.selectedSegmentIndex == 0) {
        return ([self.CurrentT.text floatValue] >= 85.0);
    }
    // otherwise it is displaying Celsius
    return ([self.CurrentT.text floatValue] >= 32.2);
}

/* Parse temperature data from Dictionary made from JSON data*/
- (void) getTemperatures: (NSDictionary *) tempDict {
    // access the element values from the dictionary, read in as Celsius !!!
    NSNumber* currentT = [tempDict objectForKey:@"currentTemp"];
    NSNumber* avg1T    = [tempDict objectForKey:@"avg1Temp"];
    NSNumber* avg10T   = [tempDict objectForKey:@"avg10Temp"];
    
    // convert to float
    float currentTemp  = [currentT floatValue];
    float avg1Temp     = [avg1T floatValue];
    float avg10Temp    = [avg10T floatValue];
    
    // convert to Fahrenheit if that is what's currently being displayed
    if (self.toggle.selectedSegmentIndex == 0) {
        currentTemp = [self convertTemperature:currentTemp];
        avg1Temp    = [self convertTemperature:avg1Temp];
        avg10Temp   = [self convertTemperature:avg10Temp];
    }
    
    // render the read in values to the screen
    self.CurrentT.text = [NSString stringWithFormat:@"%0.01f", currentTemp];
    self.Avg1.text     = [NSString stringWithFormat:@"%0.01f", avg1Temp];
    self.Avg10.text    = [NSString stringWithFormat:@"%0.01f", avg10Temp];
}

/* ========== Functions that handle button presses ========== */
/* controls the actions to be taken when the Celsius/Fahrenheit button is pressed */
- (IBAction)segControlClicked: (id)sender
{
    self.CurrentT.text = [NSString stringWithFormat:@"%0.01f", [self convertTemperature:[self.CurrentT.text floatValue]]];
    self.Avg1.text     = [NSString stringWithFormat:@"%0.01f", [self convertTemperature:[self.Avg1.text floatValue]]];
    self.Avg10.text    = [NSString stringWithFormat:@"%0.01f", [self convertTemperature:[self.Avg10.text floatValue]]];
}

/* ========== Parse JSON from IP Address ========== */
/*
- (NSDictionary *) parseJSONFromHTTP {
    // Make URL request with server
    NSHTTPURLResponse *response = nil;
    NSString *jsonUrlString     = [NSString stringWithFormat:@"http://10.3.13.88"];
    NSURL *url                  = [NSURL URLWithString:[jsonUrlString stringByAddingPercentEscapesUsingEncoding:
                                                        NSUTF8StringEncoding]];
    
    // Get request and response though URL
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url];
    NSData *responseData  = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    
    if (responseData != nil) {
        // JSON Parsing
        NSDictionary *result  = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers
                                                                  error:nil];
        return result;
    }
    return nil;
}
 */

- (void) parseData:(NSData *)responseData
{
    NSError* error;
    
    // NEW in iOS 5: NSJSONSerialization
    // No more third-party libraries necessary for JSON parsing
    if (responseData != nil) {
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseData
                                                             options:NSJSONReadingMutableContainers
                                                               error:&error];
        dict = json;
    }
    else {
        dict = NULL;
    }
}

- (void) JSONRequest {

    // Get my messages; set up URL
    NSURL *url = [NSURL URLWithString:@"http://10.3.13.88"];

    // Set up a concurrent queue
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            NSData* data = [NSData dataWithContentsOfURL:url];
            [self performSelectorOnMainThread:@selector(parseData:)
                                   withObject:data
                                waitUntilDone:YES];
        });
}

/* ========== The MAIN loop of the program, this function is called every second from viewDidLoad ========== */
- (void) updateProgram: (NSTimer *) timer {
//    NSDictionary *dict = [self parseJSONFromHTTP];
    // parse temperatures out of the data dictionary and render to screen
    [self JSONRequest];
    if (dict) {
        [self getTemperatures:dict];
        if ([self tempIsAboveThreshold] && !alarmHasSounded && self.attendingPatient.hidden == true) {
            [self displayAlarm: @"High Patient Temperature"];
            [self soundAlarm];
            [self flashScreen];
        }
        else if (![self tempIsAboveThreshold] && alarmHasSounded){
            [self resetAlarm];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // create rounded edges for the UILabel squares on the screen
    self.Avg1.layer.cornerRadius             = 15;
    self.Avg10.layer.cornerRadius            = 15;
    self.CurrentT.layer.cornerRadius         = 15;
    self.doneButton.layer.cornerRadius       = 15;
    self.attendingPatient.layer.cornerRadius = 15;
    
    // call the updateProgram function every second
    self.programTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(updateProgram:) userInfo:nil
                                                        repeats:YES];
}

/*----------------------------------------------------------------------------------*/

/*
 - (void)updateColor: (NSTimer *) timer {
 const CGFloat* colors = CGColorGetComponents(self.view.backgroundColor.CGColor);
 
 NSLog(@"%f", colors[0]);
 self.view.backgroundColor = [UIColor colorWithRed:(colors[0] - (10.0/255.0)) green:(colors[1] - (20.0/255)) blue:(colors[2] - (10.0/255.0)) alpha:1];
 }
 
 - (void) viewDidAppear:(BOOL)animated{
 [super viewDidAppear:animated];
 
 self.myTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateColor:) userInfo:nil repeats:YES];
 }
 */
/*
 - (void) displayAlarmFromBackground: (NSString *) alarmMessage {
 UILocalNotification* localNotification = [[UILocalNotification alloc] init];
 localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:10]; // set alarm off in 10 seconds
 localNotification.alertBody = alarmMessage;
 localNotification.timeZone = [NSTimeZone defaultTimeZone];
 localNotification.repeatCalendar = nil;
 [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
 }*/

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
