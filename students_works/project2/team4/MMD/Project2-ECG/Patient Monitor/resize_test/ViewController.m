//
//  ViewController.m
//  resize_test
//
//  Created by Inbar Fried on 11/6/14.
//  Copyright (c) 2014 Team4. All rights reserved.
//

#import "ViewController.h"
#import "Graph.h"
#import "TheData.h"
#import "TEMP.h"
#import "SettingsViewController.h"
#import "RecordsViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface ViewController () <UIActionSheetDelegate, UIPopoverControllerDelegate, UITextFieldDelegate>

@property (strong, nonatomic) TheData *graphData;
@property (strong, nonatomic) TheData *graphDataBP;
@property (strong, nonatomic) TheData *graphDataSPO2;
@property (strong, nonatomic) NSTimer *programTimer;
@property (strong, nonatomic) NSTimer *thresholdTimer;
@property (strong, nonatomic) NSTimer *flashColorTimer;
@property (strong, nonatomic) NSTimer *numberTimer;
@property (strong, nonatomic) NSTimer *tempTimer;

@property (nonatomic,strong) UIPopoverController *settingsPopOver;
@property (nonatomic,strong) UIPopoverController *recordsPopOver;

@end

@implementation ViewController


- (void)initialize_globals {
    // initialize all the global variables
    
    my_green        = [UIColor colorWithRed:0.0/256.0   green:200.0/256.0 blue:0.0/256.0 alpha:1.0];
    my_blue         = [UIColor colorWithRed:0.0/256.0   green:197.0/256.0 blue:205.0/256.0 alpha:1.0];
    my_yellow       = [UIColor colorWithRed:255.0/256.0 green:215.0/256.0 blue:0.0/256.0 alpha:1.0];
    my_pink         = [UIColor colorWithRed:236.0/256.0 green:56.0/256.0 blue:138.0/256.0 alpha:1.0];
    my_orange       = [UIColor colorWithRed:255.0/256.0 green:127.0/256.0 blue:36.0/256.0 alpha:1.0];
    my_black        = [UIColor colorWithRed:0.0/256.0   green:0.0/256.0 blue:0.0/256.0 alpha:1.0];
    my_red          = [UIColor colorWithRed:200.0/256.0 green:0.0/256.0 blue:0.0/256.0 alpha:1.0];
    my_white        = [UIColor colorWithRed:256.0/256.0 green:256.0/256.0 blue:256.0/256.0 alpha:1.0];
    my_white_opaque = [UIColor colorWithRed:256.0/256.0 green:256.0/256.0 blue:256.0/256.0 alpha:0.5];
    my_clear        = [UIColor colorWithRed:256.0/256.0 green:256.0/256.0 blue:256.0/256.0 alpha:0.01];
    
    orig_font_size              = 20;
    currentTemperatureThreshold = 90.0;
    
    button_gap       = 10;
    dist_from_top    = 30;
    num_orig_buttons = 5;
    screen_space     = self.view.frame.size.width - 200;
    
    // keys into the two dictionaries are strings, such as "ECG", "PULSE", ...
    buttonsDict       = [[NSMutableDictionary alloc] init];
    viewsDict         = [[NSMutableDictionary alloc] init];
    labelsDict        = [[NSMutableDictionary alloc] init];
    numbersDict       = [[NSMutableDictionary alloc] init];
    // use the button's tag to index into the array, for example, the ECG button has been programmed tag 0
    buttonsArrayByTag = [NSArray arrayWithObjects:@"ECG", @"BP", @"SPO2", @"PULSE", @"TEMP", nil];
}

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*============================== INITIAL SCREEN INITIALIZATION -- START =========================*/
- (void) initPULSENumber {
    self.PULSEunits = [[UILabel alloc] initWithFrame:CGRectMake(270, 410, 100, 100)];
    [self.PULSEunits setBackgroundColor:[UIColor clearColor]];
    [self.PULSEunits setTextColor:my_blue];
    [self.PULSEunits setText: @"bpm"];
    self.PULSEunits.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:30];
    [self.PULSEunits sizeToFit];
    [self.view addSubview:self.PULSEunits];
    
    self.PULSEnumber = [[UILabel alloc] initWithFrame:CGRectMake(150, 400, 100, 100)];
    [self.PULSEnumber setBackgroundColor:[UIColor clearColor]];
    [self.PULSEnumber setTextColor:my_blue];
    [self.PULSEnumber setText:@"68"];
    self.PULSEnumber.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:90];
    [self.PULSEnumber sizeToFit];
    [self.view addSubview:self.PULSEnumber];
}

- (void) adjustPULSElabels {
    UIView *tempView = [viewsDict objectForKey:@"PULSE"];
    [self.PULSEnumber setFrame:CGRectMake(self.PULSEnumber.frame.origin.x, tempView.frame.origin.y + tempView.frame.size.height / 2 - self.PULSEnumber.frame.size.height / 2,
                                          self.PULSEnumber.frame.size.width, self.PULSEnumber.frame.size.height)];
    [self.PULSEunits setFrame:CGRectMake(self.PULSEunits.frame.origin.x, tempView.frame.origin.y + tempView.frame.size.height / 2 - self.PULSEunits.frame.size.height / 2 - 20,
                                          self.PULSEunits.frame.size.width, self.PULSEunits.frame.size.height)];
}

- (void) initializeBPLabels {
    Graph *tempView = [viewsDict objectForKey:@"BP"];
    self.BPunits = [[UILabel alloc] initWithFrame:CGRectMake(tempView.frame.size.width - 100, tempView.frame.origin.y + tempView.frame.size.height/2 - 50, 100, 100)];
    [self.BPunits setBackgroundColor:[UIColor clearColor]];
    [self.BPunits setTextColor:my_pink];
    [self.BPunits setText: @"mmHg"];
    self.BPunits.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:30];
    [self.BPunits sizeToFit];
    [self.view addSubview:self.BPunits];
    
    self.BPnumber = [[UILabel alloc] initWithFrame:CGRectMake(tempView.frame.size.width - 220, tempView.frame.origin.y + tempView.frame.size.height/2 - 65, 150, 100)];
    [self.BPnumber setBackgroundColor:[UIColor clearColor]];
    [self.BPnumber setTextColor:my_pink];
    [self.BPnumber setText:@"120"];
    self.BPnumber.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:60];
    [self.BPnumber sizeToFit];
    [self.view addSubview:self.BPnumber];
    
    self.BPnumber2 = [[UILabel alloc] initWithFrame:CGRectMake(tempView.frame.size.width - 200, tempView.frame.origin.y + tempView.frame.size.height/2 - 10, 150, 100)];
    [self.BPnumber2 setBackgroundColor:[UIColor clearColor]];
    [self.BPnumber2 setTextColor:my_pink];
    [self.BPnumber2 setText:@"78"];
    self.BPnumber2.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:60];
    [self.BPnumber2 sizeToFit];
    [self.view addSubview:self.BPnumber2];

}

- (void) adjustBPLabels {
    Graph *tempView = [viewsDict objectForKey:@"BP"];
    [self.BPnumber setFrame:CGRectMake(self.BPnumber.frame.origin.x, tempView.frame.origin.y + tempView.frame.size.height / 2 - 65,
                                       self.BPnumber.frame.size.width, self.BPnumber.frame.size.height)];
    [self.BPnumber2 setFrame:CGRectMake(self.BPnumber2.frame.origin.x, tempView.frame.origin.y + tempView.frame.size.height / 2 - 10,
                                       self.BPnumber2.frame.size.width, self.BPnumber2.frame.size.height)];
    [self.BPunits setFrame:CGRectMake(self.BPunits.frame.origin.x, tempView.frame.origin.y + tempView.frame.size.height / 2 - self.BPunits.frame.size.height / 2 - 20,
                                         self.BPunits.frame.size.width, self.BPunits.frame.size.height)];
}

- (void) initializeLabels {
    [self initPULSENumber];
    [self initializeBPLabels];
    NSString *key    = nil;
    UIColor  *color  = nil;
    UIButton *button = nil;
    for (int i = 0; i < num_orig_buttons; i++){
        if (i == 0) { key = @"ECG";   color = my_green;  button = [buttonsDict objectForKey: buttonsArrayByTag[i]]; }
        if (i == 1) { key = @"BP";    color = my_pink;   button = [buttonsDict objectForKey: buttonsArrayByTag[i]]; }
        if (i == 2) { key = @"SPO2";  color = my_yellow; button = [buttonsDict objectForKey: buttonsArrayByTag[i]]; }
        if (i == 3) { key = @"PULSE"; color = my_blue;   button = [buttonsDict objectForKey: buttonsArrayByTag[i]]; }
        if (i == 4) { key = @"TEMP";  color = my_orange; button = [buttonsDict objectForKey: buttonsArrayByTag[i]]; }
        // place the label at the center of its button
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, button.frame.origin.y + (button.frame.size.height / 2) - 10, 80, 20)];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTextColor:color];
        [label setText:[buttonsArrayByTag objectAtIndex:i]];
        label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:orig_font_size];
        [self.view addSubview:label];
        [labelsDict setValue: label forKey: key];
    }
}


- (void) initializeViews {
    NSString *key     = nil;
    UIColor  *color   = nil;
    float width       = self.view.bounds.size.height ;
    int button_height = floor(screen_space / num_orig_buttons);
    for (int i = 0; i < num_orig_buttons; i++){
        if (i == 0) key = @"ECG",   color = my_green;
        if (i == 1) key = @"BP",    color = my_pink;
        if (i == 2) key = @"SPO2",  color = my_yellow;
        if (i == 3) key = @"PULSE", color = my_blue;
        if (i == 4) key = @"TEMP",  color = my_orange;
        // initialize the ECG view separately because its of class 'Graph'
        if ([key isEqualToString:@"ECG"]){
            Graph *view = [[Graph alloc] initWithFrame:CGRectMake(20, dist_from_top + button_height*i + button_gap*i, width, button_height)];
//            [view initializeNumberFor: key withColor:color withUnits:@""];
            [view initializeColor:color];
            [view setBackgroundColor:[UIColor clearColor]];
            [self.view addSubview:view];
            [viewsDict setValue: view forKey: key];
        }
        else if ([key isEqualToString:@"SPO2"]) {
            Graph *view = [[Graph alloc] initWithFrame:CGRectMake(20, dist_from_top + button_height*i + button_gap*i, width, button_height)];
            [view initializeNumberFor: key withColor:color withUnits:@"%"];
            [view setBackgroundColor:[UIColor clearColor]];
            [self.view addSubview:view];
            [viewsDict setValue: view forKey: key];
        }
        else if ([key isEqualToString:@"BP"]) {
            Graph *view = [[Graph alloc] initWithFrame:CGRectMake(20, dist_from_top + button_height*i + button_gap*i, width, button_height)];
//            [view initializeNumberFor: key withColor:color withUnits:@"mmHg"];
            [view initializeColor:color];
            [view setBackgroundColor:[UIColor clearColor]];
            [self.view addSubview:view];
            [viewsDict setValue: view forKey: key];
        }
        else if ([key isEqualToString:@"PULSE"]) {
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(20, dist_from_top + button_height*i + button_gap*i, 500, button_height)];
            //[view initializeNumberFor: key withColor:color];
            [view setBackgroundColor:[UIColor clearColor]];
            [self.view addSubview:view];
            [viewsDict setValue: view forKey: key];
        }
        else if ([key isEqualToString:@"TEMP"]) {
            TEMP *view = [[TEMP alloc] initWithFrame:CGRectMake(20, dist_from_top + button_height*i + button_gap*i, 500, button_height)];
            [view setBackgroundColor:[UIColor clearColor]];
            [self.view addSubview:view];
            [viewsDict setValue: view forKey: key];
        }
    }
}

- (void) initializeButtons {
    int button_height = floor(screen_space / num_orig_buttons);
    NSString *key     = nil;
    CGColorRef color  = nil;
    float width       = self.view.bounds.size.height + 20;
    float x_origin    = -10;
    
    for (int i = 0; i < num_orig_buttons; i++){
        if (i == 0) { key = @"ECG";   color = my_green.CGColor;  }
        if (i == 1) { key = @"BP";    color = my_pink.CGColor;   }
        if (i == 2) { key = @"SPO2";  color = my_yellow.CGColor; }
        if (i == 3) { key = @"PULSE"; color = my_blue.CGColor;   x_origin = -10; width = 500; }
        if (i == 4) { key = @"TEMP";  color = my_orange.CGColor; x_origin = -10; width = 500; }
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button setFrame:CGRectMake(x_origin, dist_from_top + button_height*i + button_gap*i, width, button_height)];
        [button setTag:i];
        [[button layer] setBorderWidth:1.5f];
        [[button layer] setBorderColor:color];
        [[button layer] setCornerRadius:10.0];
        [button addTarget:self action: @selector(respondToClick:) forControlEvents:UIControlEventTouchUpInside];
        [buttonsDict setValue: button forKey: key];
        [self.view addSubview:button];
    }
}


- (void) initializePasswordButtons {
    
    // Screen Cover to simulate "screen lock"
    self.totalCover = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.totalCover setFrame:CGRectMake(0,0, self.view.frame.size.height, self.view.frame.size.width)];
    [self.totalCover addTarget:self action: @selector(requirePassword:) forControlEvents:UIControlEventTouchUpInside];
    self.totalCover.backgroundColor = [UIColor clearColor];
    [self.totalCover setEnabled:NO];
    self.totalCover.hidden = YES;
    [self.view addSubview:self.totalCover];
    
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        [alertView dismissWithClickedButtonIndex:0 animated:NO];
    }
    // unlocked by providing password
    else if (buttonIndex == 1) {
        self.totalCover.enabled = NO;
        self.totalCover.hidden = YES;
        self.lockTimer = 0;
    }
}

/* Display the window with the Alarm Notification */
- (void) displayPasswordAlert {
    UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Screen Locked"
                                                     message:@"Enter Password"
                                                    delegate:self
                                           cancelButtonTitle:@"Dismiss"
                                           otherButtonTitles: nil];
    alert.alertViewStyle = UIAlertViewStyleSecureTextInput;
    [alert addButtonWithTitle:@"Done"];
    [alert show];
}

- (void) initializeInteractiveIcons {
    
    [self initializePasswordButtons];
    
    // F/C Toggle
    [self initializeFCToggle];
    
    float y_origin = self.view.bounds.size.width - 110;
    
    // settings
    self.settings = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.settings setFrame:CGRectMake(50,y_origin,120,80)];
    [self.settings setTitle:@"SETTINGS" forState:UIControlStateNormal];
    self.settings.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:20];
    [self.settings addTarget:self action: @selector(showSettingsActionSheet:) forControlEvents:UIControlEventTouchUpInside];
    self.settings.tag = 2;
    [[self.settings layer] setBorderWidth:1.5f];
    [[self.settings layer] setBorderColor:my_white.CGColor];
    [[self.settings layer] setCornerRadius:10.0];
    [self.view addSubview:self.settings];
    
    // accounts
    self.accounts = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.accounts setFrame:CGRectMake(200, y_origin,120,80)];
    [self.accounts setTitle:@"ACCOUNTS" forState:UIControlStateNormal];
    self.accounts.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:20];
    [self.accounts addTarget:self action: @selector(showAccountsActionSheet:) forControlEvents:UIControlEventTouchUpInside];
    self.accounts.tag = 4;
    [[self.accounts layer] setBorderWidth:1.5f];
    [[self.accounts layer] setBorderColor:my_white.CGColor];
    [[self.accounts layer] setCornerRadius:10.0];
    [self.view addSubview:self.accounts];
    
    // patients
    self.patients = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.patients setFrame:CGRectMake(350, y_origin,120,80)];
    [self.patients setTitle:@"PATIENTS" forState:UIControlStateNormal];
    self.patients.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:20];
    [self.patients addTarget:self action: @selector(showPatientsActionSheet:) forControlEvents:UIControlEventTouchUpInside];
    self.patients.tag = 3;
    [[self.patients layer] setBorderWidth:1.5f];
    [[self.patients layer] setBorderColor:my_white.CGColor];
    [[self.patients layer] setCornerRadius:10.0];
    [self.view addSubview:self.patients];
    
    // sending messages
    self.messages = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.messages setFrame:CGRectMake(500,y_origin,120,80)];
    [self.messages setTitle:@"MESSAGES" forState:UIControlStateNormal];
    self.messages.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:20];
    [self.messages addTarget:self action: @selector(goToMessages:) forControlEvents:UIControlEventTouchUpInside];
    self.messages.tag = 1;
    [[self.messages layer] setBorderWidth:1.5f];
    [[self.messages layer] setBorderColor:my_white.CGColor];
    [[self.messages layer] setCornerRadius:10.0];
    [self.view addSubview:self.messages];
    
    // records
    self.records = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.records setFrame:CGRectMake(650, y_origin, 120, 80)];
    [self.records setTitle:@"RECORDS" forState:UIControlStateNormal];
    self.records.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:20];
    [self.records addTarget:self action: @selector(showRecordsActionSheet:) forControlEvents:UIControlEventTouchUpInside];
    self.records.tag = 5;
    [[self.records layer] setBorderWidth:1.5f];
    [[self.records layer] setBorderColor:my_white.CGColor];
    [[self.records layer] setCornerRadius:10.0];
    [self.view addSubview:self.records];

}

- (void) initializeNonInteractiveIcons {
    float y_origin = self.view.bounds.size.width - 90;
    // the translucent white bar behind the time, ipad battery life, ...
    self.topBar = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.topBar setFrame:CGRectMake(0, 0, 1200, 20)];
    [[self.topBar layer] setBorderColor:my_white_opaque.CGColor];
    [self.topBar setBackgroundColor: my_white_opaque];
    [self.view addSubview:self.topBar];
    // battery icon
    self.batteryIconView       = [[UIImageView alloc] initWithFrame:CGRectMake(900,y_origin,30,50)];
    self.batteryIconView.image = [UIImage imageNamed:@"battery_2.png"];
    [self.view addSubview:self.batteryIconView];
    // wifi icon
    self.wifiIcon       = [[UIImageView alloc] initWithFrame:CGRectMake(950,y_origin,30,50)];
    self.wifiIcon.image = [UIImage imageNamed:@"wifiIMG.png"];
    [self.view addSubview:self.wifiIcon];
}

- (void) initializePatientNumberLabel {
    self.patientLabel = [[UILabel alloc] initWithFrame:CGRectMake(540, 600, 80, 20)];
    [self.patientLabel setBackgroundColor:[UIColor clearColor]];
    [self.patientLabel setTextColor:my_white_opaque];
    [self.patientLabel setText:@"A. Rennel Room #133A"];
    self.patientLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:36];
    [self.patientLabel sizeToFit];
    [self.view addSubview:self.patientLabel];
}

/*============================== INITIAL SCREEN INITIALIZATION -- END ==========================*/
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*============================== BUTTON RESPONSE HANDLING -- START =============================*/
// responds to the screen locking after not being interacted with for 30 seconds
- (void) requirePassword: (id) sender {
    [self displayPasswordAlert];
}

- (IBAction) showSettingsActionSheet: (id) sender {
    self.settingsVC.tempUnits = self.FCToggle.tag;
    
    self.settingsPopOver = [[UIPopoverController alloc] initWithContentViewController:self.settingsVC];
    self.settingsPopOver.delegate = self;
    self.settingsPopOver.popoverContentSize = CGSizeMake(300, 450);
    [self.settingsPopOver presentPopoverFromRect:[(UIButton*) sender frame] inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    [self resetLockTimer];
}
- (IBAction)showRecordsActionSheet:(id)sender {
    self.recordsPopOver = [[UIPopoverController alloc] initWithContentViewController:self.recordsVC];
    self.recordsPopOver.delegate = self;
    self.recordsPopOver.popoverContentSize = CGSizeMake(500, 400);
    [self.recordsPopOver presentPopoverFromRect:[(UIButton*) sender frame] inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    [self resetLockTimer];
}
- (IBAction)showPatientsActionSheet:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Patients"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"R. Cohen Room #127B", @"D. Hopkins Room #108", @"A. Rennel Room #133A", nil];
    [actionSheet showFromRect:[(UIButton *)sender frame] inView:self.view animated:YES];
    actionSheet.tag = 100;
    [self resetLockTimer];
}
- (IBAction)showAccountsActionSheet:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Accounts"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"S. Johnson", @"L. Meck", nil];
    [actionSheet showFromRect:[(UIButton *)sender frame] inView:self.view animated:YES];
    actionSheet.tag = 200;
    [self resetLockTimer];
}

-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    // selecting a patient
    if(actionSheet.tag == 100) {
        // buttonIndex 3 is the 'cancel' action, so do not change anything
        if (buttonIndex != 3) {
            NSString* newName = [actionSheet buttonTitleAtIndex:buttonIndex];
            [self.patientLabel setText:newName];
            [self.patientLabel sizeToFit];
            self.recordsVC.patientName = newName;
        }
    }
    // selecting a nurse account
    else if (actionSheet.tag == 200) {
        if (buttonIndex == 0) {
            //
        }
        else if (buttonIndex == 1) {
            //
        }
    }
}

// segues to the text message view
- (void) goToMessages: (UIButton*) sender {
    [self performSegueWithIdentifier:@"ToContacts" sender:sender];
    [self resetLockTimer];
}

// resizes the 5 main data views, ECG, PULSE, SPO2, BP, TEMP
- (void) resizeButtons {
    UIButton *button      = nil;
    UIView   *view        = nil;
    UILabel  *label       = nil;
    int minimized_buttons = 0;
    int starting_y        = dist_from_top;
    // count the number of buttons which should be minimized
    for (int i = 0; i < num_orig_buttons; i++){
        view = [viewsDict objectForKey: buttonsArrayByTag[i]];
        if (view.hidden == YES){
            minimized_buttons = minimized_buttons + 1;
        }
    }
    // pretend as if we have more buttons so that we allocate less space for minimized buttons (the 2 is just to get more space for large buttons)
    int pretend_button_count = (num_orig_buttons + minimized_buttons + 2);
    int small_button_height  = floor(screen_space / pretend_button_count);
    int large_button_height  = 0;
    // this 'if' is necessary for the edge case when we try to minimize all the buttons
    if ((num_orig_buttons - minimized_buttons) != 0){
        large_button_height = floor((screen_space - (small_button_height * minimized_buttons)) / (num_orig_buttons - minimized_buttons));
    }
    
    // base the font size for the non-hidden views based on how large they are (AKA, how many buttons are shrunk)
    int large_font_size = orig_font_size + 5 * minimized_buttons;
    
    // resize all the buttons as either small or large
    for (int i = 0; i < num_orig_buttons; i++){
        // get all the information about the section we are looking at
        button = [buttonsDict objectForKey: buttonsArrayByTag[i]];
        view   = [viewsDict   objectForKey: buttonsArrayByTag[i]];
        label  = [labelsDict  objectForKey: buttonsArrayByTag[i]];
        [label setLineBreakMode:NSLineBreakByWordWrapping];
        label.numberOfLines = 1;
        // if the view is hidden, minimize it
        if (view.hidden == YES){
            if ([buttonsArrayByTag[i] isEqualToString:@"PULSE"]) { self.PULSEnumber.hidden = YES; self.PULSEunits.hidden = YES; }
            if ([buttonsArrayByTag[i] isEqualToString:@"BP"]) { self.BPnumber.hidden = YES; self.BPnumber2.hidden = YES; self.BPunits.hidden = YES; }
            [view   setFrame:CGRectMake(20,  starting_y, view.frame.size.width, small_button_height)];
            [button setFrame:CGRectMake(-10, starting_y, button.frame.size.width, small_button_height)];
            [label  setFrame:CGRectMake(15,  button.frame.origin.y + (button.frame.size.height / 2) - 10, 80, 20)];
            label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:orig_font_size];
            starting_y = starting_y + small_button_height + button_gap;
        }
        // if the view is shown, adjust its size based on how many others views are shown or minimized
        else {
            if ([buttonsArrayByTag[i] isEqualToString:@"PULSE"]) { self.PULSEnumber.hidden = NO; self.PULSEunits.hidden = NO; }
            if ([buttonsArrayByTag[i] isEqualToString:@"BP"]) { self.BPnumber.hidden = NO; self.BPnumber2.hidden = NO; self.BPunits.hidden = NO; }
            [view   setFrame:CGRectMake(20,  starting_y, view.frame.size.width, large_button_height)];
            [button setFrame:CGRectMake(-10, starting_y, button.frame.size.width, large_button_height)];
            [label  setFrame:CGRectMake(15,  button.frame.origin.y + (button.frame.size.height / 2) - 10, 80, 20)];
            label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:large_font_size];
            [label sizeToFit];
            starting_y = starting_y + large_button_height + button_gap;
        }
    }
    
    Graph *tempView = [viewsDict objectForKey:@"ECG"];
    [tempView resizeNumberUnits];
    tempView = [viewsDict objectForKey:@"BP"];
    [tempView resizeNumberUnits];
    tempView = [viewsDict objectForKey:@"SPO2"];
    [tempView resizeNumberUnits];
    
    [self adjustPULSElabels];
    [self adjustBPLabels];
    
    // if there is only 1 view open, make the label vertical
    if (minimized_buttons == (num_orig_buttons - 1)){
        for (int i = 0; i < num_orig_buttons; i++){
            view   = [viewsDict   objectForKey: buttonsArrayByTag[i]];
            if (view.hidden == NO){
                label  = [labelsDict  objectForKey: buttonsArrayByTag[i]];
                [label setFrame:CGRectMake(label.frame.origin.x, label.frame.origin.y - 100, 30, 250)];
                label.numberOfLines = 5;
                [label setLineBreakMode:NSLineBreakByCharWrapping];
            }
        }
    }
    
    // update location of other labels
    TEMP *TEMPview = [viewsDict objectForKey:@"TEMP"];
    [TEMPview updateLabelLocation];
    
    // update FC Toggle location
    [self.FCToggle setFrame:CGRectMake(self.FCToggle.frame.origin.x, TEMPview.frame.origin.y + (TEMPview.frame.size.height / 2) - self.FCToggle.frame.size.height + 20, self.FCToggle.frame.size.width, self.FCToggle.frame.size.height)];
}

// responds to clicks on any of the 5 data views (ECG, PULSE, SPO2, BP, TEMP)
- (void) respondToClick:(UIButton*)sender {
    NSString *buttonTitle = buttonsArrayByTag[sender.tag];
    UIView   *view        = [viewsDict objectForKey: buttonTitle];
    if (view.hidden == YES) {
        if ([buttonsArrayByTag[sender.tag] isEqualToString:@"TEMP"]) self.FCToggle.hidden = NO;
        view.hidden = NO;
    }
    else {
        if ([buttonsArrayByTag[sender.tag] isEqualToString:@"TEMP"]) self.FCToggle.hidden = YES;
        view.hidden = YES;
    }
    [self resizeButtons];
    [self resetLockTimer];
}

- (void) respondToAlarmClick: (id) sender {
    [self stopAlarm];
    self.alarmButton.hidden = true;
    [self resetLockTimer];
}
/*============================== BUTTON RESPONSE HANDLING -- END ===============================*/
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*========================= TEMPERATURE ALARM AND VALUE CONFIGS -- START =======================*/
- (void) initializeAlarmButton {
    self.alarmButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.alarmButton setFrame:CGRectMake(550, 540, 400, 50)];
    [[self.alarmButton layer] setBorderWidth:3.0f];
    [self.alarmButton setBackgroundColor:my_red];
    [[self.alarmButton layer] setBorderColor:my_red.CGColor];
    [[self.alarmButton layer] setCornerRadius:10.0];
    [self.alarmButton setTitle:@"ALARM: TEMP" forState:UIControlStateNormal];
    [self.alarmButton setTitleColor:my_white forState:UIControlStateNormal];
    self.alarmButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:36];
    [self.view addSubview:self.alarmButton];
    [self.alarmButton addTarget:self action: @selector(respondToAlarmClick:) forControlEvents:UIControlEventTouchUpInside];
    self.alarmButton.hidden = YES;
}

- (void) initializeFCToggle {
    TEMP *view = [viewsDict objectForKey:@"TEMP"];
    self.FCToggle = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.FCToggle setFrame:CGRectMake(320, view.frame.origin.y + (view.frame.size.height / 3),100,50)];
    [self.FCToggle setBackgroundImage:[UIImage imageNamed:@"FUnits"] forState:UIControlStateNormal];
    [self.FCToggle addTarget:self action: @selector(changeTempUnits:) forControlEvents:UIControlEventTouchUpInside];
    self.FCToggle.tag = 0;
    [self.view addSubview:self.FCToggle];
}

- (void) changeTempUnits: (UIButton*) sender {
    TEMP *view = [viewsDict objectForKey:@"TEMP"];
    if (self.FCToggle.tag == 0) { // we are in F, so convert to C
        [self.FCToggle setBackgroundImage:[UIImage imageNamed:@"CUnits"] forState:UIControlStateNormal];
        self.FCToggle.tag = 1;
        [view convertToCelsius];
    }
    else { // we are in C, so convert to F
        [self.FCToggle setBackgroundImage:[UIImage imageNamed:@"FUnits"] forState:UIControlStateNormal];
        self.FCToggle.tag = 0;
        [view convertToFahrenheit];
    }
}

- (AVAudioPlayer *) setupAudioPlayerWithFile: (NSString *) file type:(NSString *) type {
    NSString *path = [[NSBundle mainBundle] pathForResource:file ofType:type];
    NSURL *url = [NSURL fileURLWithPath:path];
    NSError *error;
    AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: url error:&error];
    if (!audioPlayer) NSLog(@"%@", [error description]);
    return audioPlayer;
}

- (void) soundAlarm {
    alarmNoise = [self setupAudioPlayerWithFile:@"beep_1" type:@"mp3"];
    [alarmNoise play];
}

- (void) stopAlarm {
    [alarmNoise stop];
    [self.flashColorTimer invalidate];
    TEMP *TEMPview = [viewsDict objectForKey: @"TEMP"];
    const CGFloat *colors = CGColorGetComponents(TEMPview.currentTemp.textColor.CGColor);
    TEMPview.currentTemp.textColor = [UIColor colorWithRed:(colors[0]) green:(colors[1]) blue:(colors[2]) alpha:1.0];
}

- (void) handleTempAlarm {
    [self soundAlarm];
    self.alarmHasBeenSetOffForCurrentThreshold = true;
    self.alarmButton.hidden = NO;
    [self flashNumber];
}

- (void) flashTextColor: (NSTimer *) timer {
    TEMP *TEMPview = [viewsDict objectForKey: @"TEMP"];
    const CGFloat *colors = CGColorGetComponents(TEMPview.currentTemp.textColor.CGColor);
    if (colors[3] == 1)
        TEMPview.currentTemp.textColor = [UIColor colorWithRed:(colors[0]) green:(colors[1]) blue:(colors[2]) alpha:0.3];
    else
        TEMPview.currentTemp.textColor = [UIColor colorWithRed:(colors[0]) green:(colors[1]) blue:(colors[2]) alpha:1.0];
}

- (void) flashNumber {
    self.flashColorTimer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(flashTextColor:) userInfo:nil repeats:YES];
}

- (void) checkTempThreshold {
    TEMP *TEMPview = [viewsDict objectForKey: @"TEMP"];
    if ([TEMPview isCurrentTempAboveThreshold] && self.alarmHasBeenSetOffForCurrentThreshold == false){
        [self handleTempAlarm];
    }
}

- (void) thresholdUpdater: (NSTimer*) timer {
    TEMP *TEMPview  = [viewsDict objectForKey: @"TEMP"];
    
    [TEMPview setMinuteAverageTemp];
    if ([TEMPview isAverageTempAboveThreshold]){
        // set the new threshold to the minute average + 5% of it
        TEMPview.previousThreshold = TEMPview.currentTemperatureThreshold;
        TEMPview.currentTemperatureThreshold = TEMPview.currentMinuteAverage + (.05 * TEMPview.currentMinuteAverage);
        self.alarmHasBeenSetOffForCurrentThreshold = false;
        [self stopAlarm];
    }
    else if ([TEMPview isAverageTempBelowPreviousThreshold]){
        TEMPview.previousThreshold = TEMPview.currentTemperatureThreshold;
        TEMPview.currentTemperatureThreshold = TEMPview.currentMinuteAverage - (.05 * TEMPview.currentMinuteAverage);
        self.alarmHasBeenSetOffForCurrentThreshold = false;
        [self stopAlarm];
    }
}
/*========================= TEMPERATURE ALARM AND VALUE CONFIGS -- END =========================*/
/*========================= SCREEN LOCK WHEN SCREEN IS IDLE -- START ===========================*/
// whenever an action on the screen is recorded, this function is called to reset the lock timer
- (void) resetLockTimer {
    self.lockTimer = 0;
}

- (void) updateAndCheckScreenLock {
    // multiply by 60 seconds because the value is set in minutes, but the counter is every second
    self.lockThreshold = 60.0 * [self.settingsVC returnCurrentLockThreshold];
    // update the timer
    self.lockTimer = self.lockTimer + 1;
    // check if the timer has reached the lock threshold
    if (self.lockTimer >= self.lockThreshold && self.totalCover.enabled == NO) {
        [self.totalCover setEnabled:YES];
        [self.view bringSubviewToFront:self.totalCover];
        self.totalCover.hidden = NO;
    }
}

/*========================= SCREEN LOCK WHEN SCREEN IS IDLE -- END =============================*/

- (void) parseData:(NSData *) responseData {
    NSError* error;
    
    if (responseData != nil) {
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseData
                                                             options:NSJSONReadingMutableContainers
                                                               error:&error];
        self.wifiData = json;
    }
    else {
        self.wifiData = NULL;
    }
}

- (void) JSONRequest {
    
    // Get my messages; set up URL
    NSURL *url = [NSURL URLWithString:@"http://10.3.13.88/"];
    
    // Set up a concurrent queue
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSData* data = [NSData dataWithContentsOfURL:url];
        [self performSelectorOnMainThread:@selector(parseData:)
                               withObject:data
                            waitUntilDone:YES];
    });
}

- (void) getWifiInfo: (NSDictionary *) wifiDict {
    TEMP *TEMPview  = [viewsDict objectForKey: @"TEMP"];
    TEMPview.currentTemp = [wifiDict objectForKey:@"currentTemp"];
    TEMPview.currentTemp.text = [NSString stringWithFormat:@"%0.1f°", [TEMPview.currentTemp.text floatValue]];
    NSNumber* pulseReading   = [wifiDict objectForKey:@"pulse"];
    NSNumber* batteryReading = [wifiDict objectForKey:@"battery"];
    
    NSLog(@"%@, %@, %@", TEMPview.currentTemp, pulseReading, batteryReading);
}

- (void) updateProgram: (NSTimer*) timer {
    [self JSONRequest];
    if (self.wifiData) {
        [self getWifiInfo: self.wifiData];
    }
    
    TEMP *TEMPview  = [viewsDict objectForKey: @"TEMP"];
    // sync temp. threshold from settings view controller
    TEMPview.currentTemperatureThreshold = [self.settingsVC returnCurrentTempThreshold];

    // deal with immediate screen locking
    if (self.settingsVC.lockNow) {
        self.lockTimer = self.lockThreshold;
        self.settingsVC.lockNow = false;
        [self.settingsPopOver dismissPopoverAnimated:YES];
    }
    
    // FOR TESTING PURPOSES...
//    TEMPview.currentTemp.text = [NSString stringWithFormat:@"%0.1f°", [TEMPview.currentTemp.text floatValue] + 1];
    
    // add the new temp. reading to the collected data
    [TEMPview populateTempsArray:[TEMPview.currentTemp.text floatValue]];
    
    [self updateAndCheckScreenLock];
    [self checkTempThreshold];
    
    // needed to make buttons clickable after they are minimized. Why? I don't know
    UIButton *tempB = [buttonsDict objectForKey:@"ECG"];
    tempB.backgroundColor = my_clear;
    tempB = [buttonsDict objectForKey:@"SPO2"];
    tempB.backgroundColor = my_clear;
    tempB = [buttonsDict objectForKey:@"BP"];
    tempB.backgroundColor = my_clear;
    tempB = [buttonsDict objectForKey:@"PULSE"];
    tempB.backgroundColor = my_clear;
    tempB = [buttonsDict objectForKey:@"TEMP"];
    tempB.backgroundColor = my_clear;
}

- (void) initGraphs {
    // initialize the graph data associated with each view
    Graph*   view  = nil;
    for (int i = 0; i < num_orig_buttons; i++){
        if (i == 0) {
            view = [viewsDict objectForKey: buttonsArrayByTag[i]];
            [view.graphXData addObjectsFromArray:[self.graphData getDataX]];
            [view.graphYData addObjectsFromArray:[self.graphData getDataY]];
        }
        if (i == 1) {
            view = [viewsDict objectForKey: buttonsArrayByTag[i]];
            [view.graphXData addObjectsFromArray:[self.graphDataBP getDataX]];
            [view.graphYData addObjectsFromArray:[self.graphDataBP getDataY]];
        }
        if (i == 2) {
            view = [viewsDict objectForKey: buttonsArrayByTag[i]];
            [view.graphXData addObjectsFromArray:[self.graphDataSPO2 getDataX]];
            [view.graphYData addObjectsFromArray:[self.graphDataSPO2 getDataY]];
        }
    }
}

- (void) updateNumbers: (NSTimer*) timer {
    Graph *view = nil;
    for (int i = 0; i < num_orig_buttons; i++){
        if (i == 1) {
            view = [viewsDict objectForKey: buttonsArrayByTag[i]];
            if (self.increment)
                self.BPnumber.text = [NSString stringWithFormat:@"%d", [self.BPnumber.text integerValue] + 1];
            else
                self.BPnumber.text = [NSString stringWithFormat:@"%d", [self.BPnumber.text integerValue] - 1];

        }
        if (i == 2) {
            view = [viewsDict objectForKey: buttonsArrayByTag[i]];
            if (self.increment)
                view.number.text = [NSString stringWithFormat:@"%d", [view.number.text integerValue] + 1];
            else
                view.number.text = [NSString stringWithFormat:@"%d", [view.number.text integerValue] - 1];
        }
    }
    self.increment = !self.increment;
}

- (void) updateTemp: (NSTimer *) timer {
    TEMP *TEMPview  = [viewsDict objectForKey: @"TEMP"];
    // FOR TESTING PURPOSES...
    if (self.increment) {
        TEMPview.currentTemp.text = [NSString stringWithFormat:@"%0.1f°", [TEMPview.currentTemp.text floatValue] + 1];
    }
    else {
        TEMPview.currentTemp.text = [NSString stringWithFormat:@"%0.1f°", [TEMPview.currentTemp.text floatValue] - 1];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self my_initialize];
    [self initGraphs];
    
    self.increment = true;
    
    // call the updateProgram function every second
    self.programTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateProgram:) userInfo:nil
                                                        repeats:YES];
    // the machine learning aspect of the alarm
    self.thresholdTimer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(thresholdUpdater:) userInfo:nil
                                                          repeats:YES];
    // update the numbers associated with the data
    self.numberTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(updateNumbers:) userInfo:nil
                                                      repeats:YES];
    self.tempTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(updateTemp:) userInfo:nil
                                                       repeats:YES];
}

- (void) my_initialize {
    self.wifiData                              = NULL;
    self.lockTimer                             = 0;
    self.lockThreshold                         = 1.0 * 60.0;
    self.alarmHasBeenSetOffForCurrentThreshold = false;
    [self.view setBackgroundColor:my_black];
    
    self.settingsVC = [[SettingsViewController alloc] init];
    self.recordsVC  = [[RecordsViewController alloc] init];
    
    [self initialize_globals];
    [self initializeViews];
    [self initializeButtons];
    [self initializeLabels];
    [self initializeNonInteractiveIcons];
    [self initializeInteractiveIcons];
    [self initializeAlarmButton];
    [self initializePatientNumberLabel];
   
    TEMP *TEMPview = [viewsDict objectForKey: @"TEMP"];
    [TEMPview initLabel];
}

- (void)viewWillDisappear:(BOOL)animated {
    // makes it so that the navigation bar appears on all views other than the first view
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (TheData *) graphData {
    if (!_graphData){
        _graphData = [[TheData alloc] initWithFile:@"ekg3"];
    }
    return _graphData;
}

- (TheData *) graphDataBP {
    if (!_graphDataBP){
        _graphDataBP = [[TheData alloc] initWithFile:@"bloodpressure2"];
    }
    return _graphDataBP;
}

- (TheData *) graphDataSPO2 {
    if (!_graphDataSPO2){
        _graphDataSPO2 = [[TheData alloc] initWithFile:@"spo22"];
    }
    return _graphDataSPO2;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // hides the navigation bar from the first view
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
