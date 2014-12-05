//
//  ViewController.m
//  Patient Monitor
//
//  Created by Ryan Dougherty on 11/5/14.
//  Copyright (c) 2014 team3. All rights reserved.
//

#import "ViewController.h"
#define slope 0.0614f
#define offset -5.6311f

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //[self loadSoundFiles];

    [self initialize_dimentions];
    
    alarm = [AlarmOptions alloc];
    [self initializeData];
    
    [self addDefaultViews];
    [self initializeGraphs];
    [self.view bringSubviewToFront:SPO2_Button];

 //   [self makeAlarmWindow];
  
    [alarm setButton:alarmOptions];
    [alarm setMainView:self.view window:window];
    [alarm initializeAlarms];

    // COMMUNICATION STUFFF
    self.myURL = @"http://10.3.13.158";
    [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(serverRequest:) userInfo:nil repeats:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
// Set the dimentions of the frames when the view first loads
-(void)initialize_dimentions{
    // Position of the lower bar as a percentage of the screen
    float lower_bar_scale = .90;
    // Position of the right bar as a percentage of the screen
    float right_bar_scale = .70;
    // Number of breaks in the side view
    number_of_side_doopies = 4;
    // Number of breaks in the main view
    number_of_main_view_breaks = 0;
    // Buttons
    button_width = 50;
    button_height = 50;
    
    // Get window data
    // NOTE: UNCOMMENT THIS IF YOU ARE RUNNING ON ACTUAL HARDWARE
  //  if([[UIScreen mainScreen] bounds].size.width>[[UIScreen mainScreen] bounds].size.width){
        window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//    }else{
//        window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width)];
//    }
    
    // Set Main View Bounds
    main_view_x = 0;
    main_view_y = 0;
    main_view_width = window.frame.size.width*right_bar_scale;
    main_view_height = window.frame.size.height*lower_bar_scale;
    
    // Set Bottom (Options) Bar Bounds
    bottom_bar_x = 0;
    bottom_bar_y = window.frame.size.height*lower_bar_scale;
    bottom_bar_width = window.frame.size.width;
    bottom_bar_height = window.frame.size.height*(1-lower_bar_scale);
    
    // Set Side Bar Bounds
    side_view_x = window.frame.size.width*right_bar_scale;
    side_view_y = 0;
    side_view_width = window.frame.size.width*(1-right_bar_scale);
    side_view_height = window.frame.size.height*lower_bar_scale;
}

-(void)initializeGraphs{
    graphData = [[TheData alloc] init];

    //////////
    NSString *filePathCSV = [[NSBundle mainBundle] pathForResource:@"Spo2graphdata" ofType:@"csv"];
    
    [self readColumnFromCSV:filePathCSV AtColumn:1];
    NSMutableArray *dataX;
    NSMutableArray *dataY;
    
    dataX = [NSMutableArray arrayWithArray: [self readColumnFromCSV:filePathCSV AtColumn:0] ];
    dataY = [NSMutableArray arrayWithArray: [self readColumnFromCSV:filePathCSV AtColumn:1] ];
    
    for (NSInteger i = 0; i < [dataX count]; ++i) {
        NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
        [f setNumberStyle:NSNumberFormatterDecimalStyle];
        dataX[i] = [f numberFromString:[dataX objectAtIndex:i]]; // NSNumber
        dataY[i] = [f numberFromString:[dataY objectAtIndex:i]]; // NSNumber
    }
    //////////
    
    EKG_Graph = [[Graph alloc] initWithFrame:main_view.frame];
    SPO2_Graph = [[Graph alloc] initWithFrame:SPO2.frame];
    
    
    [EKG_Graph.graphXData addObjectsFromArray:[graphData getDataX]];
    [EKG_Graph.graphYData addObjectsFromArray:[graphData getDataY]];
    [self.view addSubview:EKG_Graph];
    [EKG_Graph setGraphColor:[UIColor blackColor] WithShapeColor:[UIColor orangeColor]];
    
    [SPO2_Graph.graphXData addObjectsFromArray:dataX];
    [SPO2_Graph.graphYData addObjectsFromArray:dataY];
    [self.view addSubview:SPO2_Graph];
    [SPO2_Graph setGraphColor:[UIColor blackColor] WithShapeColor:[UIColor blueColor]];
    
    main_graph = EKG_Graph;
}

-(NSMutableArray *)readColumnFromCSV:(NSString*)path AtColumn:(int)column
{
    
    NSMutableArray *readArray=[[NSMutableArray alloc]init];
    
    NSString *fileDataString=[NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    NSArray *linesArray=[fileDataString componentsSeparatedByString:@"\r\n"];
    
    for (NSString *lineString in linesArray)
    {
        NSArray *columnArray=[lineString componentsSeparatedByString:@","];
        [readArray addObject:[columnArray objectAtIndex:column]];
        
    }
    
    return readArray;
    
    // for debug: NSLog(@"%@",readArray);
    
}

-(void)initializeData{
    bloodpressure = 100;
    temperature = 98.5;
    pulse = 60;
    spo2 = 1;
    systolic = 120;
    diastolic = 80;
    
    alarm.bloodPressure = bloodpressure;
    alarm.temperature = temperature;
    alarm.pulse = pulse;
    alarm.spo2 = spo2;
}

// Create the bounds where elements will be drawn
-(void)addDefaultViews{
    main_view = [[UIView alloc] initWithFrame:CGRectMake(main_view_x, main_view_y, main_view_width, main_view_height)];
    //[main_view setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:main_view];
    
    side_view = [[UIView alloc] initWithFrame:CGRectMake(side_view_x, side_view_y, side_view_width, side_view_height)];
    //[side_view setBackgroundColor:[UIColor blueColor]];
    [self.view addSubview:side_view];
    
    [self makeBottomBar];
    
    [self initializeEKG];
    [self initializeSPO2];
    [self initializePULSE];
    [self initializeTEMPERATURE];
    [self initializeBloodPressure];
    
    [self.view addSubview:EKG];
    [self.view addSubview:SPO2];
    [self.view addSubview:PULSE];
    [self.view addSubview:TEMPERATURE];
    [self.view addSubview:BloodPressure];
    
    [self.view addSubview:EKG_Button];
    [self.view addSubview:SPO2_Button];
    [self.view addSubview:PULSE_Button];
    [self.view addSubview:TEMPERATURE_Button];
    [self.view addSubview:BloodPressure_Button];
    
}
-(void)makeBottomBar{
    layout_index = 0;
    
    bottom_bar = [[UIView alloc] initWithFrame:CGRectMake(bottom_bar_x, bottom_bar_y, bottom_bar_width, bottom_bar_height)];
    [bottom_bar setBackgroundColor:[UIColor grayColor]];
    [self.view addSubview:bottom_bar];
    
    // Add a layout button
    layout = [[UIButton alloc]initWithFrame:CGRectMake(bottom_bar_width/3-button_width/2, bottom_bar_height/2-button_height/2, button_width, button_height)];
    [layout addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [layout setBackgroundImage:[UIImage imageNamed:@"expandicon.png" ] forState:UIControlStateNormal];
    [bottom_bar addSubview:layout];
    
    // Add Text to the layout button
    UILabel *layoutText = [[UILabel alloc] initWithFrame:CGRectMake(bottom_bar_x+100, bottom_bar_y,300,bottom_bar_height)];
    [layoutText setText:@"Change Layout:"];
    [layoutText setTextColor: [UIColor whiteColor]];
    [self.view addSubview:layoutText];
    [self.view bringSubviewToFront:layoutText];
    
    // Make alarm options button
    alarmOptions = [[UIButton alloc]initWithFrame:CGRectMake(bottom_bar_width*2/3-button_width/2, bottom_bar_height/2-button_height/2, button_width, button_height)];
        [alarmOptions setBackgroundImage:[UIImage imageNamed:@"alarmonIcon.png" ] forState:UIControlStateNormal];
    [bottom_bar addSubview:alarmOptions];
    
    // Add Text to the alarm options button
    UILabel *optionsText = [[UILabel alloc] initWithFrame:CGRectMake(bottom_bar_x+450, bottom_bar_y,450,bottom_bar_height)];
    [optionsText setText:@"Alarm Options:"];
    [optionsText setTextColor: [UIColor whiteColor]];
    [self.view addSubview:optionsText];
    [self.view bringSubviewToFront:optionsText];
    
}

-(void)initializeEKG{
    float x = main_view_x;
    float y = main_view_y;
    float width = main_view_width;
    float height = main_view_height;
    
    EKG = [[UIView alloc] initWithFrame:CGRectMake(x, y, width, height)];
    
    EKG_Button = [[UIButton alloc]initWithFrame:CGRectMake(0, y+20, button_width, button_height)];
    [EKG_Button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [EKG_Button setBackgroundImage:[UIImage imageNamed:@"ekgicon.png" ] forState:UIControlStateNormal];

    main_view = EKG;
    main_button = EKG_Button;
}

-(void)initializeSPO2{
    float x = side_view_x;
    float y = side_view_y;
    float width = side_view_width;
    float height = side_view_height/number_of_side_doopies;
    
    SPO2 = [[UIView alloc] initWithFrame:CGRectMake(x, y, width, height)];
    
    SPO2_Label = [[UILabel alloc]initWithFrame:CGRectMake(x, y+SPO2.frame.size.height/2, SPO2.frame.size.width, SPO2.frame.size.height/2)];
    [SPO2_Label setText:[NSString stringWithFormat:@"%.f",spo2]];
    [SPO2_Label setTextAlignment:NSTextAlignmentRight];
    [SPO2_Label setTextColor:[UIColor blueColor]];
    [SPO2_Label setFont:[SPO2_Label.font fontWithSize:50]];
   // [self.view addSubview:SPO2_Label];
    
    SPO2_Button = [[UIButton alloc]initWithFrame:CGRectMake(x+width-button_width, y+20, button_width, button_height)];
    [SPO2_Button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [SPO2_Button setBackgroundImage:[UIImage imageNamed:@"SpO2icon.png"] forState:UIControlStateNormal];
}

-(void)initializePULSE{
    float x = side_view_x;
    float y = side_view_y+side_view_height/number_of_side_doopies;
    float width = side_view_width;
    float height = side_view_height/number_of_side_doopies;
    
    PULSE = [[UIView alloc] initWithFrame:CGRectMake(x, y, width,height)];
    [PULSE setBackgroundColor:[UIColor blackColor]];
    
    PULSE_Label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, PULSE.frame.size.width, PULSE.frame.size.height)];
    [PULSE_Label setText:[NSString stringWithFormat:@"%.f bpm",pulse]];
    [PULSE_Label setTextAlignment:NSTextAlignmentCenter];
    [PULSE_Label setTextColor:[UIColor magentaColor]];
    [PULSE_Label setFont:[PULSE_Label.font fontWithSize:50]];
    [PULSE addSubview:PULSE_Label];
    
    PULSE_Button = [[UIButton alloc]initWithFrame:CGRectMake(x+width-button_width, y, button_width, button_height)];
    [PULSE_Button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [PULSE_Button setBackgroundImage:[UIImage imageNamed:@"pulseicon.png"] forState:UIControlStateNormal];
}

-(void)initializeTEMPERATURE{
    float x = side_view_x;
    float y = side_view_y+2*side_view_height/number_of_side_doopies;
    float width = side_view_width;
    float height = side_view_height/number_of_side_doopies;
    
    TEMPERATURE = [[UIView alloc] initWithFrame:CGRectMake(x, y, width, height)];
    [TEMPERATURE setBackgroundColor:[UIColor blackColor]];
    
    TEMPERATURE_Label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, TEMPERATURE.frame.size.width, TEMPERATURE.frame.size.height)];
    [TEMPERATURE_Label setText:@"--"];
    [TEMPERATURE_Label setTextAlignment:NSTextAlignmentCenter];
    [TEMPERATURE_Label setTextColor:[UIColor redColor]];
    [TEMPERATURE_Label setFont:[TEMPERATURE_Label.font fontWithSize:50]];
    [TEMPERATURE addSubview:TEMPERATURE_Label];
    
    TEMPERATURE_Button = [[UIButton alloc]initWithFrame:CGRectMake(x+width-button_width, y, button_width, button_height)];
    [TEMPERATURE_Button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [TEMPERATURE_Button setBackgroundImage:[UIImage imageNamed:@"thermometericon.png"] forState:UIControlStateNormal];
}

-(void)initializeBloodPressure{
    float x = side_view_x;
    float y = side_view_y+3*side_view_height/number_of_side_doopies;
    float width = side_view_width;
    float height = side_view_height/number_of_side_doopies;
    
    BloodPressure = [[UIView alloc]initWithFrame:CGRectMake(x, y, width, height)];
    [BloodPressure setBackgroundColor:[UIColor blackColor]];
    
    BloodPressure_Label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, BloodPressure.frame.size.width, BloodPressure.frame.size.height)];
    [BloodPressure_Label setText:[[[NSString stringWithFormat:@"%.f",systolic] stringByAppendingString:@"/"]stringByAppendingString:[NSString stringWithFormat:@"%.fmmHg",diastolic]]];
    [BloodPressure_Label setTextAlignment:NSTextAlignmentCenter];
    [BloodPressure_Label setTextColor:[UIColor greenColor]];
    [BloodPressure_Label setFont:[BloodPressure_Label.font fontWithSize:50]];
    [BloodPressure addSubview:BloodPressure_Label];
    
    BloodPressure_Button = [[UIButton alloc]initWithFrame:CGRectMake(x+width-button_width, y, button_width, button_height)];
    [BloodPressure_Button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [BloodPressure_Button setBackgroundImage:[UIImage imageNamed:@"bloodpressicon.png"] forState:UIControlStateNormal];
    
}

// TODO: Make this better by using the number of children of the view in a for loop to condense the code
-(void) buttonClicked:(UIButton*)sender
{
    if(alarm.isAlarmWindowUp){
        NSLog(@"the window is up");
        return;
    }
    CGRect tempFrame = main_view.frame;
    //Graph *tempGraph = main_graph;
    CGRect tempButton = main_button.frame;
    
    [self.view sendSubviewToBack: main_view];
    if(sender == EKG_Button){
        if(main_view != EKG){
            [main_label setFont:[main_label.font fontWithSize:50]];
            
            [main_view setFrame:EKG.frame];
            [main_button setFrame:EKG_Button.frame];
            [main_label setFrame:CGRectMake(0, 0, EKG.frame.size.width, EKG.frame.size.height)];
            [main_graph setFrame:EKG.frame];
            [main_graph resize];

            
            [EKG setFrame:tempFrame];
            [EKG_Button setFrame:tempButton];
            [EKG_Graph setFrame:EKG.frame];
            
            main_view = EKG;
            main_button = EKG_Button;
            main_graph = EKG_Graph;
            main_label = nil;
            [EKG_Graph resize];
            [main_label setFont:[main_label.font fontWithSize:128]];
        }
    }
    if(sender == SPO2_Button){
        if(main_view != SPO2){
            [main_label setFont:[main_label.font fontWithSize:50]];
            
            [main_view setFrame:SPO2.frame];
            [main_button setFrame:SPO2_Button.frame];
            [main_label setFrame:CGRectMake(0, 0, SPO2.frame.size.width, SPO2.frame.size.height)];
            [main_graph setFrame:SPO2.frame];
            [main_graph resize];
            
            [SPO2 setFrame:tempFrame];
            [SPO2_Button setFrame:tempButton];
           
            [SPO2_Graph setFrame:SPO2.frame];
         //   [SPO2_Label setFrame:SPO2.frame];

            main_view = SPO2;
            main_button = SPO2_Button;
            main_graph = SPO2_Graph;
            main_label = nil;
            [SPO2_Graph resize];
            [main_label setFont:[main_label.font fontWithSize:128]];
       //     [self.view bringSubviewToFront:SPO2_Label];
        }
    }
    if(sender == PULSE_Button){
        if(main_view != PULSE){
            [main_label setFont:[main_label.font fontWithSize:50]];
            
            [main_view setFrame:PULSE.frame];
            [main_button setFrame:PULSE_Button.frame];
            [main_graph setFrame:PULSE.frame];
            [main_graph resize];
            [main_label setFrame:CGRectMake(0, 0, PULSE.frame.size.width, PULSE.frame.size.height)];
            
            [PULSE setFrame:tempFrame];
            [PULSE_Button setFrame:tempButton];
            [PULSE_Label setFrame:CGRectMake(0, 0, PULSE.frame.size.width, PULSE.frame.size.height)];

            main_view = PULSE;
            main_button = PULSE_Button;
            main_label = PULSE_Label;
            main_graph = nil;
            [main_label setFont:[main_label.font fontWithSize:128]];
        }
    }
    if(sender == TEMPERATURE_Button){
        if(main_view != TEMPERATURE){
            [main_label setFont:[main_label.font fontWithSize:50]];
            
            [main_view setFrame:TEMPERATURE.frame];
            [main_button setFrame:TEMPERATURE_Button.frame];
            [main_label setFrame:CGRectMake(0, 0, TEMPERATURE.frame.size.width, TEMPERATURE.frame.size.height)];
            [main_graph setFrame:TEMPERATURE.frame];
            [main_graph resize];
            
            [TEMPERATURE setFrame:tempFrame];
            [TEMPERATURE_Button setFrame:tempButton];
            [TEMPERATURE_Label setFrame:TEMPERATURE.frame];
            
            main_view = TEMPERATURE;
            main_button = TEMPERATURE_Button;
            main_graph = nil;
            main_label = TEMPERATURE_Label;
            [main_label setFont:[main_label.font fontWithSize:128]];
        }
    }
    if(sender == BloodPressure_Button){
        if(main_view != BloodPressure){
            [main_label setFont:[main_label.font fontWithSize:50]];
            
            [main_view setFrame:BloodPressure.frame];
            [main_button setFrame:BloodPressure_Button.frame];
            [main_label setFrame:CGRectMake(0, 0, BloodPressure.frame.size.width, BloodPressure.frame.size.height)];
            [main_graph setFrame:BloodPressure.frame];
            [main_graph resize];
            
            [BloodPressure setFrame:tempFrame];
            [BloodPressure_Button setFrame:tempButton];
            [BloodPressure_Label setFrame:BloodPressure.frame];
            
            main_view = BloodPressure;
            main_button = BloodPressure_Button;
            main_graph = nil;
            main_label = BloodPressure_Label;
            [main_label setFont:[main_label.font fontWithSize:100]];
        }
    }
    if(sender == layout){
        layout_index = (layout_index+1)%2;
        if(layout_index == 0){
            NSLog(@"Switching to default view");
            main_view.frame = CGRectMake(main_view_x, main_view_y, main_view_width, main_view_height);
            [layout setBackgroundImage:[UIImage imageNamed:@"expandicon.png"] forState:UIControlStateNormal];
            
        }else if (layout_index == 1){
            main_view.frame = CGRectMake(main_view_x, main_view_y, window.frame.size.width, main_view_height);
            [layout setBackgroundImage:[UIImage imageNamed:@"shrinkicon.png"] forState:UIControlStateNormal];
            NSLog(@"Switching to large view");
        }else if (layout_index == 2){
            // UNUSED
            NSLog(@"Switching to quadrant view");
        }else{
            NSLog(@"ERROR");
        }
        [main_label setFrame:CGRectMake(0, 0, main_view.frame.size.width, main_view.frame.size.height)];
//        if(main_label == SPO2_Label){
//            [main_label setFrame:CGRectMake(SPO2.frame.origin.x, SPO2.frame.origin.y, main_view.frame.size.width, main_view.frame.size.height)];
//        }
        [self.view bringSubviewToFront:main_graph];
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:.5];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        
        [main_graph setFrame:main_view.frame];
        
        [UIView commitAnimations];
        
        [main_graph resize];
    }
    
    [self.view bringSubviewToFront:main_view];
    [self.view bringSubviewToFront:main_graph];
    [self.view bringSubviewToFront:main_button];
    [self.view bringSubviewToFront:main_label];
    
    [self.view bringSubviewToFront:EKG_Button];
    [self.view bringSubviewToFront:SPO2_Button];
    [self.view bringSubviewToFront:PULSE_Button];
    [self.view bringSubviewToFront:TEMPERATURE_Button];
    [self.view bringSubviewToFront:BloodPressure_Button];
}

-(void)loadSoundFiles{
    // Set up file path to audio file
    NSString* path = [[NSBundle mainBundle] pathForResource:@"alarm" ofType:@"mp3"];
    NSURL* file = [NSURL fileURLWithPath:path];
    
    // Set up audio player
    alarmPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:file error:nil];
    [alarmPlayer prepareToPlay];
    alarmPlayer.numberOfLoops = -1;
    
    path = [[NSBundle mainBundle] pathForResource:@"Tink" ofType:@"mp3"];
    file = [NSURL fileURLWithPath:path];
    
    // Set up audio player
    effectPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:file error:nil];
    [effectPlayer prepareToPlay];
    
    NSLog(@"Sound files loaded");
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag == 1){
        if(buttonIndex == 0){
            [alarmPlayer pause];
        }
    }
}

- (void) playAlarm {
    NSLog(@"Playing Sound");
    if ([alarmPlayer isPlaying]) {
        [alarmPlayer pause];
    } else {
        [alarmPlayer play];
    }
}


// Make request to server
-(void)serverRequest:(NSTimer*)timer{
    //NSLog(@"Requesting Server");
    // Load URL
    NSURL *url = [NSURL URLWithString:self.myURL];
    if(!url){
        NSLog(@"NO URL");
        isConnected = false;
        return;
    }
    isConnected = true;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [request setCachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
        [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        
        NSURLResponse *response;
        NSError *error;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        if(!data){
            NSLog(@"NO DATA");
            NSLog(@"%@",[error localizedDescription]);
            didGetPackage = false;
            return;
        }
        didGetPackage = true; // If data was obtained, set the flag to true
        // NSLog(@"%@", data);
        [self performSelectorOnMainThread:@selector(handleResponse:) withObject:data waitUntilDone:YES];
    });
}

// Handle server response
-(void)handleResponse:(NSData *)response{
    if(response){
        NSError *error;
        
        NSDictionary *jsonPackage = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:&error];
       // NSArray *arduinoData = jsonPackage[@"packet"];
        
        NSLog(@"%@", jsonPackage);
        float tempTemp =[self convert:[[jsonPackage valueForKey:@"s_avg"] floatValue]];
        NSLog([NSString stringWithFormat:@"%f °C",tempTemp]);
        
        alarm.temperature =tempTemp;
        [TEMPERATURE_Label setText:[NSString stringWithFormat:@"%.f°C",tempTemp]];
    }else{
        NSLog(@"ERROR OBTAINING RESULTS, CHECK URL");
    }
}


-(float)convert:(float)degree{
    return degree * slope + offset;
}


@end
