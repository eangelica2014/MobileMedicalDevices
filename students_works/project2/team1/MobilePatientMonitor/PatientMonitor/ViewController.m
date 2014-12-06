//
//  ViewController.m
//  PatientMonitor
//
//  Created by Alex Henry on 11/11/14.
//  Copyright (c) 2014 Alexander Henry. All rights reserved.
//

#import "ViewController.h"
#import "VitalSign.h"
#import "Graph.h"
#import "Numeric.h"
#import "Data.h"
#import "global_const.h"
#import <QuartzCore/QuartzCore.h>

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0)
#define arduinoTemperatureURL [NSURL URLWithString: @"http://10.3.14.177/"]

@interface ViewController ()

@property NSMutableArray* object_list;
@property NSMutableArray* hide_box_list;
@property NSMutableArray* nav_button_list;
@property UIButton *defaultViewNavButton;
@property UIButton *customViewNavButton;
@property int num_nav_button;
@property int num_objects;
@property int num_nograph_objects;
@property int index_last_expanded;
@property bool display_conf_flag;   // true = configured display; false = default display
@property bool screen_locked;   // true = buttons are locked except for unlock
@property float url_time;
@property UIView *helpView;
@property UIButton *helpBackButton;



@end

@implementation ViewController


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Handles loading the initial view and populates the view with stuff
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIColor *viewColor;
    NSString *viewTitle, *navTitle, *dataFileGraph, *dataFileNum, *unitLabel;
    bool viewGraph;
    
    // Initialize view controller variables
    self.display_conf_flag = false;
    self.index_last_expanded = -1;
    self.screen_locked = false;
    self.url_time = 3.0;
    
    
    // NEW STUFF FOR THE HELP VIEW //
    self.helpView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    self.helpView.backgroundColor= [UIColor colorWithPatternImage:[UIImage imageNamed:@"Help_Screen.png"]];
    self.helpView.contentMode = UIViewContentModeTopLeft;
    self.helpView.hidden = true;
    
    self.helpBackButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.helpBackButton addTarget:self action:@selector(handleNavButton:) forControlEvents:UIControlEventTouchUpInside];
    self.helpBackButton.titleLabel.text = @"Back";
    self.helpBackButton.titleLabel.textColor = [UIColor blackColor];
    [self.helpBackButton setTitle:@"Back" forState:UIControlStateNormal];
    [self.helpBackButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.helpBackButton setFrame:CGRectMake(50, 50, 200, 100)];
    self.helpBackButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:50];
    [self.helpBackButton setBackgroundColor:[UIColor whiteColor]];
    [self.helpView addSubview:self.helpBackButton];
    [self.view insertSubview:self.helpView atIndex:0];
    
    
    /////////////////////////////////
    
    float yScale=0;
    float yShift = 0;
    float sampleRate=0;
    int pointSpacing = 0;
    // Create all the vital sign objects
    self.num_objects = 6;
    self.num_nograph_objects = 3;
    self.object_list = [[NSMutableArray arrayWithCapacity:(self.num_objects)] init];
    for (int i = 0; i < self.num_objects; i++) {
        if (i == 0) {
            viewColor = [UIColor greenColor];
            viewTitle = @"ECG";
            viewGraph = true;
            dataFileGraph = @"ECGGraph";
            yScale = -0.1;
            yShift = 50;
            sampleRate = 250;
            pointSpacing = 5;
            unitLabel = @"";
        }
        else if (i == 1) {
            viewColor = [UIColor redColor];
            viewTitle = @"ABP";
            viewGraph = true;
            dataFileGraph = @"BPGraph";
            dataFileNum = @"BPTop";
            yScale = -2;
            yShift = 300;
            sampleRate = 20;
            pointSpacing = 1;
            unitLabel = @"mmHg";
        }
        else if (i == 2) {
            viewColor = [UIColor blueColor];
            viewTitle = @"SpO2";
            viewGraph = true;
            dataFileGraph = @"SpO2";
            dataFileNum = @"SpO2";
            yScale = -5;
            yShift = 500;
            sampleRate = 50;
            pointSpacing = 2;
            unitLabel = @"%";
        }
        else if (i == 3) {
            viewColor = [UIColor redColor];
            viewTitle = @"Temperature";
            viewGraph = false;
            dataFileNum = @"Temp";
            unitLabel = @"°F";
        }
        else if (i == 4) {
            viewColor = [UIColor greenColor];
            viewTitle = @"Heart Rate";
            viewGraph = false;
            dataFileNum = @"HR";
            unitLabel = @"bpm";
        }
        else {
            viewColor = [UIColor yellowColor];
            viewTitle = @"Resp. Rate";
            viewGraph = false;
            dataFileNum = @"Resp";
            unitLabel = @"bpm";
        }

        [self.object_list addObject: [self makeObject:i withTitle:viewTitle withColor:viewColor withGraph:viewGraph withGraphDataFile:dataFileGraph withYScale:yScale withYShift:yShift withSampleRate:sampleRate withPointSpacing:pointSpacing withNumericDataFile:dataFileNum withUnit:unitLabel]];
    }
    
    // Create the navigation buttons
    self.num_nav_button = 6;
    self.nav_button_list = [[NSMutableArray arrayWithCapacity:(self.num_nav_button)] init];
    for (int i = 0; i < self.num_nav_button; i++) {
        if (i == 0) {
            navTitle = @"Silence";
        }
        else if (i == 1) {
            navTitle = @"Pause Alarms";
        }
        else if (i == 2) {
            navTitle = @"Default View";
        }
        else if (i == 3) {
            navTitle = @"Custom View";
        }
        else if (i == 4) {
            navTitle = @"Help";
        }
        else {
            navTitle = @"Screen Lock";
        }
        [self.nav_button_list addObject:[self addNavButton:navTitle fromLeft:i]];
    }
    self.defaultViewNavButton = [self.nav_button_list objectAtIndex:2];
    self.customViewNavButton = [self.nav_button_list objectAtIndex:3];
    
    self.hide_box_list = [[NSMutableArray arrayWithCapacity:3] init];

    UIView *topBar = [[UIView alloc] initWithFrame:CGRectMake(guide_left, guide_top, (guide_right-guide_left), 1)];
    [topBar setBackgroundColor:[UIColor blackColor]];
    topBar.layer.borderColor = [UIColor whiteColor].CGColor;
    topBar.layer.borderWidth = 5.0;
    [self.hide_box_list addObject:topBar];
    
    UIView *topBlackBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, (guide_right-guide_left), guide_top)];
    [topBlackBar setBackgroundColor:[UIColor blackColor]];
    [self.hide_box_list addObject:topBlackBar];
    
    UIView *bottomBlackBar = [[UIView alloc] initWithFrame:CGRectMake(0, guide_bottom, (guide_right-guide_left), self.view.bounds.size.height-guide_bottom)];
    [bottomBlackBar setBackgroundColor:[UIColor blackColor]];
    [self.hide_box_list addObject:bottomBlackBar];
    
    // Add all subviews to the main view in the correct layer
    [self layerView:self.object_list];
    
    UIButton *addGraph = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [addGraph setFrame:CGRectMake((guide_right-40), (guide_top-40), 40, 40)];
    [addGraph setBackgroundColor:[UIColor clearColor]];
    addGraph.layer.borderColor = [UIColor whiteColor].CGColor;
    addGraph.layer.borderWidth = 3.0;
    addGraph.layer.cornerRadius = 5.0;
    [addGraph setTitle:@"+" forState:UIControlStateNormal];
    [addGraph setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    addGraph.titleLabel.font = [UIFont systemFontOfSize:40.0];

    [addGraph addTarget:self action:@selector(addVitalSign:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addGraph];

    
    // Sets a timer to check on the connection of each measurement
    [NSTimer scheduledTimerWithTimeInterval: self.url_time target:self selector:@selector(accessURLData) userInfo: nil repeats:YES];
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Sets the status bar colors to contrast with the black background
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Prepares all views by sizing and displaying properly
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
    [self sizeViews:self.object_list];
    [self unhideArrayView:self.object_list];
    
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Create the menu page buttons
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-(UIButton*) makeMenuButton:(NSString*)menuButtonTitle {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [button setTitle:menuButtonTitle forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont systemFontOfSize:20]];
    [button.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    
    return button;
    
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Creates an object and fills in every data field
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (VitalSign*)makeObject:(int)buttonNumber withTitle:(NSString*)buttonTitle withColor:(UIColor*)buttonColor withGraph:(bool)showGraph withGraphDataFile:(NSString *)fileNameGraph withYScale:(float)yScale withYShift:(float)yShift withSampleRate:(float) sampleRate withPointSpacing:(int)pointSpacing withNumericDataFile:(NSString *)fileNameNum withUnit:(NSString*)unit
{
    VitalSign *object = [[VitalSign alloc] init];
    UILabel *titlelabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width_title, height_title)];
    UILabel *unitLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    
    // Initialize all buttons/views assigned to objects main view
    UIView *encloseView = [[UIView alloc] init];
    UIView *line = [[UIView alloc] init];
    UIView *lineLeft = [[UIView alloc] init];
    UIView *lineRight = [[UIView alloc] init];
    UIImageView *icon = [[UIImageView alloc] init];
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    UIButton *expand = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    UIButton *minimize = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    Graph *graphobj = [[Graph alloc] initWithFrame:CGRectMake(0, 0, width_graph, (guide_bottom-guide_top)/(self.num_objects-self.num_nograph_objects+1)-(2*space_graph_y)) withYScale:yScale withYShift:yShift withSampleRate:sampleRate withPointSpacing:pointSpacing];
    
    Numeric *numericobj = [[Numeric alloc] initWithFrame:CGRectMake(780, 20, 100, 100)];
    
    Data *denominatorData = [[Data alloc] initWithFile:@"BPBottom"];
    Numeric *numericDenominator;
    numericDenominator = [[Numeric alloc] initWithFrame:CGRectMake(780, 70, 100, 100)];
    [numericDenominator.graphXData addObjectsFromArray:[denominatorData getDataX]];
    [numericDenominator.graphYData addObjectsFromArray:[denominatorData getDataY]];
    
    UILabel *errorMessage = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width_error_message, height_error_message)];
    
    // Initialize all buttons/views assigned to objects menu view
    UIView *menuView = [[UIView alloc] init];
    UIButton *menuSettings = [UIButton buttonWithType:UIButtonTypeCustom];
    UIButton *menuHistory = [UIButton buttonWithType:UIButtonTypeCustom];
    UIButton *menuAlarms = [UIButton buttonWithType:UIButtonTypeCustom];
    UIView *menuSettingsView = [[UIView alloc]init];
    UIView *menuHistoryView = [[UIView alloc]init];
    UIView *menuAlarmsView = [[UIView alloc]init];
    UIView *menuButtonUnderline = [[UIView alloc] init];
    
    UIButton *History_Histogram_Button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIButton *History_Line_Graph_Button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIButton *History_Numeric_Button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    UIView *Histogram_View = [[UIView alloc]init];
    UIView *Numeric_View = [[UIView alloc]init];
    UIView *Line_Graph_View = [[UIView alloc]init];
    
    UIButton *Histogram = [[UIButton alloc]init];
    [Histogram setContentMode:UIViewContentModeTop];
    [Histogram setBackgroundImage:[UIImage imageNamed:@"Histogram.png"] forState:UIControlStateNormal];
    [Histogram setFrame:CGRectMake(80, 0, 801, 151)];
    [Histogram_View addSubview:Histogram];
    
    UIButton *Line_Graph = [[UIButton alloc]init];
    [Line_Graph setContentMode:UIViewContentModeTop];
    [Line_Graph setBackgroundImage:[UIImage imageNamed:@"Line_Graph.png"] forState:UIControlStateNormal];
    [Line_Graph setFrame:CGRectMake(80, 0, 801, 151)];
    [Line_Graph_View addSubview:Line_Graph];
    
    UIButton *Numeric = [[UIButton alloc]init];
    [Numeric setContentMode:UIViewContentModeTop];
    [Numeric setBackgroundImage:[UIImage imageNamed:@"Table.png"] forState:UIControlStateNormal];
    [Numeric setFrame:CGRectMake(180, 0, 600, 151)];
    [Numeric_View addSubview:Numeric];
    
    UIButton *Alarms = [[UIButton alloc]init];
    [Alarms setContentMode:UIViewContentModeTop];
    [Alarms setBackgroundImage:[UIImage imageNamed:@"Alarms.png"] forState:UIControlStateNormal];
    [Alarms setFrame:CGRectMake(180, 0, 744, 110)];
    [menuAlarmsView addSubview:Alarms];
    
    UIButton *Settings = [[UIButton alloc]init];
    [Settings setContentMode:UIViewContentModeTop];
    [Settings setBackgroundImage:[UIImage imageNamed:@"Settings_Menu.png"] forState:UIControlStateNormal];
    [Settings setFrame:CGRectMake(300, 40, 414, 40)];
    [menuSettingsView addSubview:Settings];
    
    //Read in and store the sample data
    Data *sampledata = [[Data alloc] initWithFile:fileNameGraph];
    Data *numericData = [[Data alloc] initWithFile:fileNameNum];
    
    // Create title
    titlelabel.text = buttonTitle;
    titlelabel.textColor = buttonColor;
    unitLabel.text = unit;
    unitLabel.textColor = [UIColor whiteColor];
    
    // Create error message
    errorMessage.text = @"Equipment Disconnected";
    errorMessage.textColor = [UIColor whiteColor];
    [errorMessage setFont:[UIFont systemFontOfSize:50]];
    [errorMessage setFrame:CGRectMake(space_left_error_message_graph, space_top_error_message, width_error_message, height_error_message)];
    errorMessage.hidden = true;
    
    // Create enclosing view
    //encloseView.contentMode = UIViewContentModeTopLeft;
    [encloseView setBackgroundColor:[UIColor blackColor]];
    encloseView.clipsToBounds = YES;
    
    // Create boundary line
    [line setBackgroundColor:[UIColor clearColor]];
    line.layer.borderColor = [UIColor whiteColor].CGColor;
    line.layer.borderWidth = 1.0;
    [line setFrame:CGRectMake(0, (guide_bottom-guide_top)/(self.num_objects-self.num_nograph_objects+1)-1, (guide_right-guide_left), 1)];
    
    // Create close button
    [closeButton addTarget:self action:@selector(handleCloseAction:) forControlEvents:UIControlEventTouchUpInside];
    [closeButton setBackgroundImage:[UIImage imageNamed:@"Exit.png"]forState:UIControlStateNormal];
    closeButton.layer.cornerRadius = 5;
    
    // Create expand button
    [expand addTarget:self action:@selector(handleExpandAction:) forControlEvents:UIControlEventTouchUpInside];
    [expand setTitleColor:buttonColor forState:UIControlStateNormal];
    [expand setBackgroundImage:[UIImage imageNamed:@"More_Icon.png"]forState:UIControlStateNormal];
    expand.layer.cornerRadius = 5;
    
    // Create minimize button
    [minimize addTarget:self action:@selector(handleMinimizeAction:) forControlEvents:UIControlEventTouchUpInside];
    [minimize setBackgroundImage:[UIImage imageNamed:@"Minimize.png"]forState:UIControlStateNormal];
    minimize.layer.cornerRadius = 5;
    
    // Create menu view
    menuView.contentMode = UIViewContentModeTopLeft;
    [menuView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Pop_Out_BG.png"]]];
    
    // Create the underline for menu view buttons
    [menuButtonUnderline setFrame:CGRectMake(button_underline_x_history, button_underline_y, button_underline_width_history, button_underline_height)];
    [menuButtonUnderline setBackgroundColor:[UIColor whiteColor]];

    
    // Create the settings page of the menu
    [menuSettingsView setFrame:CGRectMake(menu_subview_x, menu_subview_y, menu_subview_width, menu_subview_height)];
    menuSettings = [self makeMenuButton:@"Settings"];
    [menuSettings setFrame:CGRectMake(settings_button_x, menu_button_y, menu_button_width, menu_button_height)];
    [menuSettings addTarget:self action:@selector(handleSettingsButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    // Create the history page of the menu
    [menuHistoryView setFrame:CGRectMake(menu_subview_x, menu_subview_y, menu_subview_width, menu_subview_height)];
    menuHistory = [self makeMenuButton:@"History"];
    [menuHistory setSelected:true];
    [menuHistory setFrame:CGRectMake(history_button_x, menu_button_y, menu_button_width, menu_button_height)];
    [menuHistory addTarget:self action:@selector(handleHistoryButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    // Create the alarms page of the menu
    [menuAlarmsView setFrame:CGRectMake(menu_subview_x, menu_subview_y, menu_subview_width, menu_subview_height)];
    menuAlarms = [self makeMenuButton:@"Alarms"];
    [menuAlarms setFrame:CGRectMake(alarms_button_x, menu_button_y, menu_button_width, menu_button_height)];
    [menuAlarms addTarget:self action:@selector(handleAlarmsButtonAction:) forControlEvents:UIControlEventTouchUpInside];
                              
    // Create the subviews for the History view
    [Histogram_View setFrame:CGRectMake(menu_subview_x, menu_subview_y-50, menu_subview_width-50, menu_subview_height)];
    [Line_Graph_View setFrame:CGRectMake(menu_subview_x, menu_subview_y-50, menu_subview_width-50, menu_subview_height)];
    [Numeric_View setFrame:CGRectMake(menu_subview_x, menu_subview_y-50, menu_subview_width-50, menu_subview_height)];
    /*[Histogram_View setBackgroundColor:[UIColor redColor]];
    [Line_Graph_View setBackgroundColor:[UIColor blueColor]];
    [Numeric_View setBackgroundColor:[UIColor greenColor]];*/
    
                              
    // Create the data display buttons in the History View
    [History_Histogram_Button setBackgroundImage:[UIImage imageNamed:@"Histogram_Icon.png"] forState:UIControlStateNormal];
    [History_Histogram_Button setBackgroundImage:[UIImage imageNamed:@"Histogram_Icon_Selected.png"] forState:UIControlStateSelected];
    [History_Histogram_Button setSelected:true]; // start with histogram selected
    [History_Histogram_Button setFrame:CGRectMake(975, 0, 44, 44)];
    [History_Histogram_Button setTitle:@"History_Histogram_Button" forState:UIControlStateNormal];
    [History_Histogram_Button setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
    [History_Histogram_Button addTarget:self action:@selector(handleDataDisplayButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [Histogram_View setHidden:false];
    [Line_Graph_View setHidden:true];
    [Numeric_View setHidden:true];
    
    [History_Line_Graph_Button setBackgroundImage:[UIImage imageNamed:@"Line_Graph_Icon.png"] forState:UIControlStateNormal];
    [History_Line_Graph_Button setBackgroundImage:[UIImage imageNamed:@"Line_Graph_Icon_Selected.png"] forState:UIControlStateSelected];
    [History_Line_Graph_Button setSelected:false];
    [History_Line_Graph_Button setFrame:CGRectMake(975, 50, 44, 44)];
    [History_Line_Graph_Button setTitle:@"History_Line_Graph_Button" forState:UIControlStateNormal];
    [History_Line_Graph_Button setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
    [History_Line_Graph_Button addTarget:self action:@selector(handleDataDisplayButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [History_Numeric_Button setBackgroundImage:[UIImage imageNamed:@"Number_Icon.png"] forState:UIControlStateNormal];
    [History_Numeric_Button setBackgroundImage:[UIImage imageNamed:@"Number_Icon_Selected.png"] forState:UIControlStateSelected];
    [History_Numeric_Button setSelected:false];
    [History_Numeric_Button setFrame:CGRectMake(975, 100, 44, 44)];
    [History_Numeric_Button setTitle:@"History_Numeric_Button" forState:UIControlStateNormal];
    [History_Numeric_Button setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
    [History_Numeric_Button addTarget:self action:@selector(handleDataDisplayButton:) forControlEvents:UIControlEventTouchUpInside];
    

    if (showGraph) {
        // This object has data to be graphed
        [titlelabel setFont:[UIFont systemFontOfSize:37]];
        [titlelabel setFrame:CGRectMake(space_left_title_graph, space_top_title, width_title, height_title)];
        //[encloseView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Graph_BG.png"]]];
        icon = nil;
        [closeButton setFrame:CGRectMake((guide_right-space_left_close), space_top_close, width_close, height_close)];
        [expand setFrame:CGRectMake((guide_right-space_left_expand), space_top_expand, width_expand, height_expand)];
        [minimize setFrame:CGRectMake((guide_right-space_left_minimize), space_top_minimize, width_minimize, height_minimize)];
        [graphobj.graphXData addObjectsFromArray:[sampledata getDataX]];
        [graphobj.graphYData addObjectsFromArray:[sampledata getDataY]];
        [graphobj setGraphColor:buttonColor];
        [unitLabel setFrame:CGRectMake(850, 30, 100, 100)];
        if ([buttonTitle isEqualToString:@"ECG"]){
            numericobj = NULL;
        }
        else{
            [numericobj setFrame:CGRectMake(780, 30, 100, 100)];
            [numericobj.graphXData addObjectsFromArray:[numericData getDataX]];
            [numericobj.graphYData addObjectsFromArray:[numericData getDataY]];
        }
        if([buttonTitle isEqualToString:@"ABP"]){
            numericDenominator.hidden = false;
        }
        else{
            numericDenominator.hidden = true;
        }
        lineLeft = nil;
        lineRight = nil;
    }
    else {
        // This object does not have data to be graphed
        [titlelabel setFont:[UIFont systemFontOfSize:25]];
        [titlelabel setFrame:CGRectMake(space_left_title_nograph, space_top_title, width_title, height_title)];
        //[encloseView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Bottom_3_BG.png"]]];
        if ([buttonTitle isEqualToString:@"Temperature"])
            [icon setImage:[UIImage imageNamed:@"Thermometer"]];
        else if ([buttonTitle isEqualToString:@"Heart Rate"])
            [icon setImage:[UIImage imageNamed:@"Heart"]];
        else if ([buttonTitle isEqualToString:@"Resp. Rate"])
            [icon setImage:[UIImage imageNamed:@"Lungs"]];
        [icon setFrame:CGRectMake(space_icon_x, space_icon_y, 1, 1)];
        icon.contentMode = UIViewContentModeTopLeft;
        [closeButton setFrame:CGRectMake(((guide_right-guide_left)/self.num_nograph_objects)-space_left_close, space_top_close, width_close, height_close)];
        [expand setFrame:CGRectMake(((guide_right-guide_left)/self.num_nograph_objects)-space_left_expand, space_top_expand, width_expand, height_expand)];
        [minimize setFrame:CGRectMake(((guide_right-guide_left)/self.num_nograph_objects)-space_left_minimize, space_top_minimize, width_minimize, height_minimize)];
        graphobj = NULL;
        [unitLabel setFrame:CGRectMake(220, 40, 100, 100)];
        [numericobj setFrame:CGRectMake(150, 40, 100, 100)];
        [numericobj.graphXData addObjectsFromArray:[numericData getDataX]];
        [numericobj.graphYData addObjectsFromArray:[numericData getDataY]];
        
        [lineLeft setFrame:CGRectMake(0, 0, 1, (guide_bottom-guide_top)/(self.num_objects-self.num_nograph_objects+1))];
        [lineRight setFrame:CGRectMake((guide_right-guide_left)/(self.num_nograph_objects)-1, 0, 1, (guide_bottom-guide_top)/(self.num_objects-self.num_nograph_objects+1))];
        if (buttonNumber > 3)
            [lineLeft setBackgroundColor:[UIColor whiteColor]];
        else
            [lineLeft setBackgroundColor:[UIColor clearColor]];
        
        if (buttonNumber < 5)
            [lineRight setBackgroundColor:[UIColor whiteColor]];
        else
            [lineRight setBackgroundColor:[UIColor clearColor]];
    }
    
    // Add all parameters to object
    object.titlelabel = titlelabel;
    object.encloseView = encloseView;
    object.menuView = menuView;
    object.line = line;
    object.lineLeft = lineLeft;
    object.lineRight = lineRight;
    object.icon = icon;
    object.closeButton = closeButton;
    object.expand = expand;
    object.minimize = minimize;
    object.graph = graphobj;
    object.numeric = numericobj;
    object.unitLabel = unitLabel;
    object.errorMessage = errorMessage;
    object.unplugFlash = nil;
    object.data = NULL;
    object.isExpanded = false;
    object.isMinimized = false;
    object.isHistory = true;
    object.isSettings = false;
    object.isAlarms = false;
    object.menuSettingsButton = menuSettings;
    object.menuHistoryButton = menuHistory;
    object.menuAlarmsButton = menuAlarms;
    object.menuSettingsView = menuSettingsView;
    object.menuHistoryView = menuHistoryView;
    object.menuAlarmsView = menuAlarmsView;
    object.menuButtonUnderline = menuButtonUnderline;
    object.History_Histogram_Button = History_Histogram_Button;
    object.History_Line_Graph_Button  = History_Line_Graph_Button;
    object.History_Numeric_Button = History_Numeric_Button;
    object.Histogram_View = Histogram_View;
    object.Numeric_View = Numeric_View;
    object.Line_Graph_View = Line_Graph_View;
    
    // Add all subviews to enclosing view
    [object.encloseView addSubview:object.titlelabel];
    [object.encloseView addSubview:object.line];
    [object.encloseView addSubview:object.lineLeft];
    [object.encloseView addSubview:object.lineRight];
    [object.encloseView addSubview:object.icon];
    [object.encloseView addSubview:object.closeButton];
    [object.encloseView addSubview:object.expand];
    [object.encloseView addSubview:object.minimize];
    [object.encloseView addSubview:object.graph];
    [object.encloseView addSubview:object.errorMessage];
    [object.encloseView addSubview:object.numeric];
    [object.encloseView addSubview:object.unitLabel];
    [object.encloseView addSubview:numericDenominator];
    
    // Add all subviews to menu view
    [object.menuView addSubview:object.menuSettingsButton];
    [object.menuView addSubview:object.menuAlarmsButton];
    [object.menuView addSubview:object.menuHistoryButton];
    
    [object.menuView addSubview:object.menuSettingsView];
    [object.menuView addSubview:object.menuAlarmsView];
    [object.menuView addSubview:object.menuHistoryView];
    [object.menuView addSubview:object.menuButtonUnderline];
    
    [object.menuHistoryView addSubview:object.History_Histogram_Button];
    [object.menuHistoryView addSubview:object.History_Line_Graph_Button];
    [object.menuHistoryView addSubview:object.History_Numeric_Button];
    [object.menuHistoryView addSubview:object.Line_Graph_View];
    [object.menuHistoryView addSubview:object.Histogram_View];
    [object.menuHistoryView addSubview:object.Numeric_View];
    
    object.encloseView.hidden = true;
    object.menuView.hidden = true;
    
    return object;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Add all views to the proper layer
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)layerView:(NSMutableArray*)array {

    // Place the menu views on the bottom layer
    for (int i = 0; i < [array count]; i++) {
        [self.view insertSubview:[[array objectAtIndex:i] menuView] atIndex:i];
    }
    
    // Place the main enclosing views on the middle layer
    for (int i = 0; i < [array count]; i++) {
        [self.view insertSubview:[[array objectAtIndex:i] encloseView] atIndex:([array count]+i)];
    }
    
    // Place the boxes to hide other views above movable objects, under nav buttons
    for (int i = 0; i < [self.hide_box_list count]; i++) {
        [self.view insertSubview:[self.hide_box_list objectAtIndex:i] atIndex:(2*[array count]+i)];
    }
    
    // Place the nav buttons on the top layer
    for (int i = 0; i < [self.nav_button_list count]; i++) {
        [self.view insertSubview:[self.nav_button_list objectAtIndex:i] atIndex:(2*[array count]+[self.hide_box_list count]+i)];
    }
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Unhide all views in an array
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)unhideArrayView:(NSMutableArray*)array {
    for (int i = 0; i< [array count]; i++) {
        ((VitalSign*)[array objectAtIndex:i]).encloseView.hidden = false;
    }
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Unhide all views in an array
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)unhideView:(UIView*)toView {
        toView.hidden = false;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// hide all views in an array
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)hideView:(UIView*)toView {
    toView.hidden = true;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Slide the views below this one down
// 0 = minimize slide
// 1 = enclose view slide
// 2 = menu view slide
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)slideView:(VitalSign*)thisObject toDirection:(bool)down byHeight:(int)slideHeight {
    UIView *thisView = thisObject.encloseView;
    UIView *thisMenu = thisObject.menuView;
    
    CGRect newFrame = thisView.frame;
    CGRect newFrame_menu = thisMenu.frame;
    if (slideHeight == 0) {
        if (down == true) {
            newFrame.origin.y += (guide_bottom-guide_top)/(self.num_objects-self.num_nograph_objects+1)-minimized_window_height;
            newFrame_menu.origin.y += (guide_bottom-guide_top)/(self.num_objects-self.num_nograph_objects+1)-minimized_window_height;
        }
        else {
            newFrame.origin.y -= (guide_bottom-guide_top)/(self.num_objects-self.num_nograph_objects+1)-minimized_window_height;
            newFrame_menu.origin.y -= (guide_bottom-guide_top)/(self.num_objects-self.num_nograph_objects+1)-minimized_window_height;
        }
    }
    else if (slideHeight == 1) {
        if (down == true) {
            newFrame.origin.y += (guide_bottom-guide_top)/(self.num_objects-self.num_nograph_objects+1);
            newFrame_menu.origin.y += (guide_bottom-guide_top)/(self.num_objects-self.num_nograph_objects+1);
        }
        else {
            newFrame.origin.y -= (guide_bottom-guide_top)/(self.num_objects-self.num_nograph_objects+1);
            newFrame_menu.origin.y -= (guide_bottom-guide_top)/(self.num_objects-self.num_nograph_objects+1);
        }
    }
    else if (slideHeight == 2) {
        if (down == true) {
            newFrame.origin.y += height_menu;
            newFrame_menu.origin.y += height_menu;
        }
        else {
            newFrame.origin.y -= height_menu;
            newFrame_menu.origin.y -= height_menu;
        }
    }
    else {
        if (down == true) {
            newFrame.origin.y += minimized_window_height;
            newFrame_menu.origin.y += minimized_window_height;
        }
        else {
            newFrame.origin.y -= minimized_window_height;
            newFrame_menu.origin.y -= minimized_window_height;
        }
    }
    
    [UIView animateWithDuration:slide_animate_time
                     animations:^{
                         thisView.frame = newFrame;
                         thisMenu.frame = newFrame_menu;
                     }];
     
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Slide the views below this one down
// 0 = minimize slide
// 1 = enclose view slide
// 2 = menu view slide
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)slideViewNoGraph:(VitalSign*)thisObject toDirection:(bool)down byHeight:(int)slideHeight {
    UIView *thisView = thisObject.encloseView;
    UIView *thisMenu = thisObject.menuView;
    
    CGRect newFrame = thisView.frame;
    CGRect newFrame_menu = thisMenu.frame;
    if (slideHeight == 0) {
        if (down == true) {
            newFrame.origin.y += (guide_bottom-guide_top)/(self.num_objects-self.num_nograph_objects+1)-minimized_window_height;
        }
        else {
            newFrame.origin.y -= (guide_bottom-guide_top)/(self.num_objects-self.num_nograph_objects+1)-minimized_window_height;
        }
    }
    else if (slideHeight == 1) {
        if (down == true) {
            newFrame.origin.y += (guide_bottom-guide_top)/(self.num_objects-self.num_nograph_objects+1);
        }
        else {
            newFrame.origin.y -= (guide_bottom-guide_top)/(self.num_objects-self.num_nograph_objects+1);
        }
    }
    else if (slideHeight == 2) {
        if (down == true) {
            newFrame.origin.y += height_menu;
        }
        else {
            newFrame.origin.y -= height_menu;
        }
    }
    else {
        if (down == true) {
            newFrame.origin.y += minimized_window_height;
        }
        else {
            newFrame.origin.y -= minimized_window_height;
        }
    }
    
    [UIView animateWithDuration:slide_animate_time
                     animations:^{
                         thisView.frame = newFrame;
                         thisMenu.frame = newFrame_menu;
                     }];
    
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Minimize the selected view and slide up below
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)minimizeView:(VitalSign*)thisObject shrink:(bool)up {
    UIView *thisView = thisObject.encloseView;
    UIView *thisLine = thisObject.line;
    
    CGRect newFrame = thisView.frame;
    CGRect newFrame_line = thisLine.frame;
    if (up == false) {
        newFrame.size.height = (guide_bottom-guide_top)/(self.num_objects-self.num_nograph_objects+1);
        newFrame_line.origin.y += (guide_bottom-guide_top)/(self.num_objects-self.num_nograph_objects+1)-minimized_window_height;
    }
    else {
        newFrame.size.height = minimized_window_height;
        newFrame_line.origin.y -= (guide_bottom-guide_top)/(self.num_objects-self.num_nograph_objects+1)-minimized_window_height;
    }
    
    [UIView animateWithDuration:slide_animate_time
                     animations:^{
                         thisView.frame = newFrame;
                         thisLine.frame = newFrame_line;
                     }];
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Size the button heights according to what has been selected
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)sizeViews:(NSMutableArray*)array {
    
    // Initialize all variables to create proper sizing
    int num_no_graph = 0;
    int num_row = 0;
    
    // Calculate useful variables for default view
    if ( !self.display_conf_flag ) {
        for (int i = 0; i < [array count]; i++) {
            num_row++;
            if ([[array objectAtIndex:i] graph] == NULL) {
                num_no_graph++;
                if (num_no_graph > 1)
                    num_row--;
            }
        }
    }
    
    int window_top = 0;
    int window_left = 0;
    for (int i = 0; i < [array count]; i++) {
        
        if ([[array objectAtIndex:i] graph] != NULL) {
            [[[array objectAtIndex:i] encloseView] setFrame:CGRectMake(guide_left, guide_top+window_top*(guide_bottom-guide_top)/(num_row), (guide_right-guide_left), (guide_bottom-guide_top)/(num_row))];
            [[[array objectAtIndex:i] menuView] setFrame:CGRectMake(guide_left, guide_top+(window_top+1)*(guide_bottom-guide_top)/(num_row), (guide_right-guide_left), height_menu)];
            
            window_top++;
        }
        else {
            
            [[[array objectAtIndex:i] encloseView] setFrame:CGRectMake((guide_left+window_left*(guide_right-guide_left)/(num_no_graph)), guide_top+window_top*(guide_bottom-guide_top)/(num_row), (guide_right-guide_left)/(num_no_graph), (guide_bottom-guide_top)/(num_row))];
            //[[[array objectAtIndex:i] menuView] setFrame:CGRectMake((guide_left+window_left*(guide_right-guide_left)/(num_no_graph)), guide_bottom-height_menu, (guide_right-guide_left)/(num_no_graph), height_menu)];
            [[[array objectAtIndex:i] menuView] setFrame:CGRectMake(guide_left, guide_bottom-height_menu, (guide_right-guide_left), height_menu)];
            
            window_left++;
        }
    }
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// IBAction to respond to navigation button touches
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (IBAction)addVitalSign:(id)sender {
    UIButton *buttonClicked = (UIButton *)sender;
    
    NSMutableArray *titleArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < [self.object_list count]; i++) {
        if (((VitalSign*)[self.object_list objectAtIndex:i]).encloseView.hidden == true) {
            [titleArray addObject:(NSString*)((VitalSign*)[self.object_list objectAtIndex:i]).titlelabel.text];
        }
    }
    
    self.vsPicker = nil;
    if (self.vsPicker == nil) {
        //Create the ColorPickerViewController.
        self.vsPicker = [[AddVitalSignViewController alloc] initWithStyle:UITableViewStylePlain andTitles:titleArray];
        
        //Set this VC as the delegate.
        self.vsPicker.delegate = self;
    }
    
    if (!self.vsPickerPopover.popoverVisible && self.vsPickerPopover != nil) {
        self.vsPickerPopover = nil;
    }
    
    if (self.vsPickerPopover == nil) {
        //The color picker popover is not showing. Show it.
        self.vsPickerPopover = [[UIPopoverController alloc] initWithContentViewController:self.vsPicker];
        [self.vsPickerPopover presentPopoverFromRect:buttonClicked.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
    }
    
    else {
        //The color picker popover is showing. Hide it.
        [self.vsPickerPopover dismissPopoverAnimated:YES];
        self.vsPickerPopover = nil;
    }
    
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Responds to vital sign object being added
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-(void)selectedVitalSign:(NSString *)name {
    // Add the requested vital sign object
    
    int index = 0;
    for (int i = 0; i < [self.object_list count]; i++) {
        if ([((VitalSign*)[self.object_list objectAtIndex:i]).titlelabel.text isEqualToString:name])
            index = i;
    }
    
    if ([[self.object_list objectAtIndex:index] isMinimized]) {
        // Unminimize first
        [self minimizeView:[self.object_list objectAtIndex:index] shrink:false];
        ((VitalSign*)[self.object_list objectAtIndex:index]).isMinimized = false;
        // Slide everything else down
        if ([[self.object_list objectAtIndex:index] graph] != NULL) {
            for (int i = index+1; i < [self.object_list count]; i++) {
                [self slideView:[self.object_list objectAtIndex:i] toDirection:true byHeight:0];
            }
        }
        
        if ([[self.object_list objectAtIndex:index] graph] != NULL) {
            for (int i = index; i < [self.object_list count]; i++) {
                [self slideView:[self.object_list objectAtIndex:i] toDirection:true byHeight:3];
            }
        }
        
     
    }
    
    else {
        if ([[self.object_list objectAtIndex:index] graph] != NULL) {
            for (int i = index; i < [self.object_list count]; i++) {
                [self slideView:[self.object_list objectAtIndex:i] toDirection:true byHeight:1];
            }
        }
    }

    ((VitalSign*)[self.object_list objectAtIndex:index]).encloseView.hidden = false;
    
    ((VitalSign*)[self.object_list objectAtIndex:index]).graph.hidden = false;
    ((VitalSign*)[self.object_list objectAtIndex:index]).errorMessage.hidden = true;
    
    [[[self.object_list objectAtIndex:index] unplugFlash] invalidate];
    ((VitalSign*)[self.object_list objectAtIndex:index]).unplugFlash = nil;
    ((VitalSign*)[self.object_list objectAtIndex:index]).encloseView.backgroundColor = [UIColor blackColor];
    
    //Dismiss the popover if it's showing.
    if (self.vsPickerPopover) {
        [self.vsPickerPopover dismissPopoverAnimated:YES];
        self.vsPickerPopover = nil;
    }
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Creates and displays the navigation button
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (UIButton*)addNavButton:(NSString*)title fromLeft:(int)left {
    UIButton *navButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [navButton addTarget:self
                  action:@selector(handleNavButton:)
        forControlEvents:UIControlEventTouchUpInside];
    [navButton setFrame:CGRectMake(nav_guide_left+left*(nav_guide_right-nav_guide_left)/6, nav_guide_top, (nav_guide_right-nav_guide_left)/6, (nav_guide_bottom-nav_guide_top))];
    [navButton setTitle:title forState:UIControlStateNormal];
    [navButton setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
    [navButton setBackgroundColor:[UIColor blackColor]];
    
    if ([title  isEqual: @"Screen Lock"]){
        [navButton setBackgroundImage:[UIImage imageNamed:@"Screen_Unlocked.png"] forState:UIControlStateNormal];
        [navButton setBackgroundImage:[UIImage imageNamed:@"Screen_Locked.png"] forState:UIControlStateSelected];
    }
    if ([title  isEqual: @"Default View"])
        [navButton setBackgroundImage:[UIImage imageNamed:@"Default_View_Selected.png"] forState:UIControlStateNormal];
    if ([title  isEqual: @"Custom View"])
        [navButton setBackgroundImage:[UIImage imageNamed:@"Custom_View.png"] forState:UIControlStateNormal];
    if ([title  isEqual: @"Pause Alarms"])
        [navButton setBackgroundImage:[UIImage imageNamed:@"Pause_Alarms.png"] forState:UIControlStateNormal];
    if ([title  isEqual: @"Silence"])
        [navButton setBackgroundImage:[UIImage imageNamed:@"Silence.png"] forState:UIControlStateNormal];
    if ([title  isEqual: @"Help"])
        [navButton setBackgroundImage:[UIImage imageNamed:@"Help_Unselected.png"] forState:UIControlStateNormal];
    
    return navButton;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// IBAction to respond to navigation button touches
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (IBAction)handleNavButton:(id)sender {
    UIButton *buttonClicked = (UIButton *)sender;
    if ([buttonClicked.titleLabel.text  isEqualToString: @"Default View"]) {
        if (self.display_conf_flag == true) {
            self.display_conf_flag = false;
            [self.customViewNavButton setBackgroundImage:[UIImage imageNamed:@"Custom_View.png"] forState:UIControlStateNormal];
            [self.defaultViewNavButton setBackgroundImage:[UIImage imageNamed:@"Default_View_Selected.png"] forState:UIControlStateNormal];
            [self returnToDefault];
        }
    }
    else if ([buttonClicked.titleLabel.text  isEqualToString: @"Custom View"]) {
        if (self.display_conf_flag == false) {
            self.display_conf_flag = true;
            [self.customViewNavButton setBackgroundImage:[UIImage imageNamed:@"Custom_View_Selected.png"] forState:UIControlStateNormal];
            [self.defaultViewNavButton setBackgroundImage:[UIImage imageNamed:@"Default_View.png"] forState:UIControlStateNormal];
            [self returnToConfigure];
        }
    }
    else if ([buttonClicked.titleLabel.text isEqualToString:@"Screen Lock"]) {
        if (self.screen_locked) {
            
            UIAlertView *passwordWindow = [[UIAlertView alloc] initWithTitle: @"Password" message:@"Please enter password." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Enter",nil];
            passwordWindow.alertViewStyle = UIAlertViewStylePlainTextInput;
            [passwordWindow setTag:0];
            
            UITextField *textField = [passwordWindow textFieldAtIndex:0];
            textField.secureTextEntry = YES;
            textField.keyboardType = UIKeyboardTypeDecimalPad;
            
            [passwordWindow show];
        }
        else {
            self.screen_locked = true;
            [buttonClicked setSelected:true];
        }
    }
    
    else if ([buttonClicked.titleLabel.text isEqualToString:@"Help"]) {
        self.helpView.hidden = !self.helpView.hidden;
    }
    else if ([buttonClicked.titleLabel.text isEqualToString:@"Back"]) {
        self.helpView.hidden = true;
    }
    
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Returns the display to the default view
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)returnToDefault {
    for (int i = 0; i < [self.object_list count]; i++) {
        if ([[self.object_list objectAtIndex:i] isExpanded]) {
            [self unexpandWindowAtIndex:i];
        }
        else if ([[self.object_list objectAtIndex:i] isMinimized]) {
            if ([[self.object_list objectAtIndex:i] graph] != NULL) {
                [self minimizeView:[self.object_list objectAtIndex:i] shrink:false];
                for (int j = i+1; j < [self.object_list count]; j++) {
                    [self slideView:[self.object_list objectAtIndex:j] toDirection:true byHeight:0];
                }
            }
            else {
                [self minimizeView:[self.object_list objectAtIndex:i] shrink:false];
            }
        }
    }
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Returns the display to the configure view
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)returnToConfigure {
    for (int i = 0; i < [self.object_list count]; i++) {
        if ([[self.object_list objectAtIndex:i] isExpanded]) {
            [self expandWindowAtIndex:i];
        }
        else if ([[self.object_list objectAtIndex:i] isMinimized]) {
            if ([[self.object_list objectAtIndex:i] graph] != NULL) {
                [self minimizeView:[self.object_list objectAtIndex:i] shrink:true];
                for (int j = i+1; j < [self.object_list count]; j++) {
                    [self slideView:[self.object_list objectAtIndex:j] toDirection:false byHeight:0];
                }
            }
            else {
                [self minimizeView:[self.object_list objectAtIndex:i] shrink:true];
            }
        }
    }
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Action to respond to button clicked on password window
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ( ([alertView tag] == 0) && (buttonIndex == 1) ) {
        NSString *pass = [[alertView textFieldAtIndex:0] text];
        
        if ([pass isEqualToString:@"password"]) {
            self.screen_locked = false;
            [[self.nav_button_list objectAtIndex:5] setSelected:false];
        }
    }
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (IBAction)handleHistoryButtonAction:(id)sender{
    UIButton *buttonClicked = (UIButton *)sender;
    
    if (self.screen_locked)
        return;
    
    // Finds index of currently displayed
    int index_now_selected = 0;
    for (int i = 0; i < [self.object_list count]; i++) {
        if ([[[self.object_list objectAtIndex:i] menuHistoryButton] isEqual:buttonClicked])
            index_now_selected= i;
    }
    
    // Animate the bar moving underneath the menu buttons
    UIView *bar = ((VitalSign*)[self.object_list objectAtIndex:index_now_selected]).menuButtonUnderline;
    [UIView animateWithDuration:0.5
                     animations:^{
                         bar.frame = CGRectMake(button_underline_x_history, button_underline_y, button_underline_width_history, button_underline_height);
                     }];
    
    // Hide Alarms Menu
    ((VitalSign*)[self.object_list objectAtIndex:index_now_selected]).menuAlarmsView.hidden = true;
    [((VitalSign*)[self.object_list objectAtIndex:index_now_selected]).menuAlarmsButton setSelected:false];
    
    // Hide Settings Menu
    ((VitalSign*)[self.object_list objectAtIndex:index_now_selected]).menuSettingsView.hidden = true;
    [((VitalSign*)[self.object_list objectAtIndex:index_now_selected]).menuSettingsButton setSelected:false];
    
    // Show History Menu
    ((VitalSign*)[self.object_list objectAtIndex:index_now_selected]).menuHistoryView.hidden = false;
    [((VitalSign*)[self.object_list objectAtIndex:index_now_selected]).menuHistoryButton setSelected:true];

}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (IBAction)handleSettingsButtonAction:(id)sender{
    UIButton *buttonClicked = (UIButton *)sender;
    
    if (self.screen_locked)
        return;
    
    // Finds index of currently displayed
    int index_now_selected = 0;
    for (int i = 0; i < [self.object_list count]; i++) {
        if ([[[self.object_list objectAtIndex:i] menuSettingsButton] isEqual:buttonClicked])
            index_now_selected= i;
    }
    
    // Animate the bar moving underneath the menu buttons
    UIView *bar = ((VitalSign*)[self.object_list objectAtIndex:index_now_selected]).menuButtonUnderline;
    [UIView animateWithDuration:0.5
                     animations:^{
                         bar.frame = CGRectMake(button_underline_x_settings, button_underline_y, button_underline_width_settings, button_underline_height);
                     }];
    // Hide Alarms Menu
    ((VitalSign*)[self.object_list objectAtIndex:index_now_selected]).menuAlarmsView.hidden = true;
    [((VitalSign*)[self.object_list objectAtIndex:index_now_selected]).menuAlarmsButton setSelected:false];
    
    // Hide History Menu
    ((VitalSign*)[self.object_list objectAtIndex:index_now_selected]).menuHistoryView.hidden = true;
    [((VitalSign*)[self.object_list objectAtIndex:index_now_selected]).menuHistoryButton setSelected:false];
    
    // Show Settings Menu
    ((VitalSign*)[self.object_list objectAtIndex:index_now_selected]).menuSettingsView.hidden = false;
    [((VitalSign*)[self.object_list objectAtIndex:index_now_selected]).menuSettingsButton setSelected:true];
    
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (IBAction)handleAlarmsButtonAction:(id)sender{
    UIButton *buttonClicked = (UIButton *)sender;

    if (self.screen_locked)
        return;

    // Finds index of currently displayed
    int index_now_selected = 0;
    for (int i = 0; i < [self.object_list count]; i++) {
        if ([[[self.object_list objectAtIndex:i] menuAlarmsButton] isEqual:buttonClicked])
            index_now_selected= i;
    }
    
    
    // Animate the bar moving underneath the menu buttons
    UIView *bar = ((VitalSign*)[self.object_list objectAtIndex:index_now_selected]).menuButtonUnderline;
    [UIView animateWithDuration:0.5
                     animations:^{
                         bar.frame = CGRectMake(button_underline_x_alarms, button_underline_y, button_underline_width_alarms, button_underline_height);
                     }];
    // Show Alarms Menu
    ((VitalSign*)[self.object_list objectAtIndex:index_now_selected]).menuAlarmsView.hidden = false;
    [((VitalSign*)[self.object_list objectAtIndex:index_now_selected]).menuAlarmsButton setSelected:true];
    
    // Hide History Menu
    ((VitalSign*)[self.object_list objectAtIndex:index_now_selected]).menuHistoryView.hidden = true;
    [((VitalSign*)[self.object_list objectAtIndex:index_now_selected]).menuHistoryButton setSelected:false];
    
    // Show Settings Menu
    ((VitalSign*)[self.object_list objectAtIndex:index_now_selected]).menuSettingsView.hidden = true;
    [((VitalSign*)[self.object_list objectAtIndex:index_now_selected]).menuSettingsButton setSelected:false];
    
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Handles the events when a data display button (the ones in the History view) is clicked
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (IBAction)handleDataDisplayButton:(id)sender{
    UIButton *buttonClicked = (UIButton *)sender;
    
    if (self.screen_locked)
        return;
    
    if ([buttonClicked.titleLabel.text isEqualToString:@"History_Histogram_Button"]){
        // Finds index of currently expanded
        int index_now_expanded = 0;
        for (int i = 0; i < [self.object_list count]; i++) {
            if ([[[self.object_list objectAtIndex:i] History_Histogram_Button ] isEqual:buttonClicked])
                index_now_expanded = i;
        }
        ((VitalSign*)[self.object_list objectAtIndex:index_now_expanded]).History_Histogram_Button.selected = true;
        ((VitalSign*)[self.object_list objectAtIndex:index_now_expanded]).History_Line_Graph_Button.selected = false;
        ((VitalSign*)[self.object_list objectAtIndex:index_now_expanded]).History_Numeric_Button.selected = false;
        
        ((VitalSign*)[self.object_list objectAtIndex:index_now_expanded]).Histogram_View.hidden = false;
        ((VitalSign*)[self.object_list objectAtIndex:index_now_expanded]).Numeric_View.hidden = true;
        ((VitalSign*)[self.object_list objectAtIndex:index_now_expanded]).Line_Graph_View.hidden = true;
    }
    
    if ([buttonClicked.titleLabel.text isEqualToString:@"History_Line_Graph_Button"]){
        // Finds index of currently expanded
        int index_now_expanded = 0;
        for (int i = 0; i < [self.object_list count]; i++) {
            if ([[[self.object_list objectAtIndex:i] History_Line_Graph_Button ] isEqual:buttonClicked])
                index_now_expanded = i;
        }
        ((VitalSign*)[self.object_list objectAtIndex:index_now_expanded]).History_Histogram_Button.selected = false;
        ((VitalSign*)[self.object_list objectAtIndex:index_now_expanded]).History_Line_Graph_Button.selected = true;
        ((VitalSign*)[self.object_list objectAtIndex:index_now_expanded]).History_Numeric_Button.selected = false;
        
        ((VitalSign*)[self.object_list objectAtIndex:index_now_expanded]).Histogram_View.hidden = true;
        ((VitalSign*)[self.object_list objectAtIndex:index_now_expanded]).Numeric_View.hidden = true;
        ((VitalSign*)[self.object_list objectAtIndex:index_now_expanded]).Line_Graph_View.hidden = false;
    }
    
    if ([buttonClicked.titleLabel.text isEqualToString:@"History_Numeric_Button"]){
        // Finds index of currently expanded
        int index_now_expanded = 0;
        for (int i = 0; i < [self.object_list count]; i++) {
            if ([[[self.object_list objectAtIndex:i] History_Numeric_Button ] isEqual:buttonClicked])
                index_now_expanded = i;
        }
        ((VitalSign*)[self.object_list objectAtIndex:index_now_expanded]).History_Histogram_Button.selected = false;
        ((VitalSign*)[self.object_list objectAtIndex:index_now_expanded]).History_Line_Graph_Button.selected = false;
        ((VitalSign*)[self.object_list objectAtIndex:index_now_expanded]).History_Numeric_Button.selected = true;
        
        ((VitalSign*)[self.object_list objectAtIndex:index_now_expanded]).Histogram_View.hidden = true;
        ((VitalSign*)[self.object_list objectAtIndex:index_now_expanded]).Numeric_View.hidden = false;
        ((VitalSign*)[self.object_list objectAtIndex:index_now_expanded]).Line_Graph_View.hidden = true;
    }
    
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Handles the events when an close window button is clicked
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (IBAction)handleCloseAction:(id)sender {
    UIButton *buttonClicked = (UIButton *)sender;
    
    if (self.screen_locked)
        return;
    
    // Finds index of currently expanded
    int index_now_closed = 0;
    for (int i = 0; i < [self.object_list count]; i++) {
        if ([[[self.object_list objectAtIndex:i] closeButton] isEqual:buttonClicked])
            index_now_closed = i;
    }

    ((VitalSign*)[self.object_list objectAtIndex:index_now_closed]).isClosed = true;
    [[self.object_list objectAtIndex:index_now_closed] encloseView].hidden = true;
    [[self.object_list objectAtIndex:index_now_closed] menuView].hidden = true;
    

    
    if ([[self.object_list objectAtIndex:index_now_closed] graph] != NULL) {
        if ([[self. object_list objectAtIndex:index_now_closed] isMinimized]) {
            for (int i = index_now_closed; i < [self.object_list count]; i++) {
                [self slideView:[self.object_list objectAtIndex:i] toDirection:false byHeight:3];
            }
        }
        else if ([[self. object_list objectAtIndex:index_now_closed] isExpanded]) {
            for (int i = index_now_closed; i < [self.object_list count]; i++) {
                [self slideView:[self.object_list objectAtIndex:i] toDirection:false byHeight:1];
                [self slideView:[self.object_list objectAtIndex:i] toDirection:false byHeight:2];
            }
        }
        else { // not expanded, not minimized
            for (int i = index_now_closed; i < [self.object_list count]; i++) {
                [self slideView:[self.object_list objectAtIndex:i] toDirection:false byHeight:1];
            }
        }
        
    }
    else {
        
    }
    
    if ([[self.object_list objectAtIndex:index_now_closed] isExpanded])
        self.index_last_expanded = -1;

}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Handles the events when an expand window is clicked
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (IBAction)handleExpandAction:(id)sender {
    UIButton *buttonClicked = (UIButton *)sender;

    if (self.screen_locked)
        return;
    
    // Automatically switch to custom view
    if (self.display_conf_flag == false) {
        for (int i = 0; i < [self.object_list count]; i++) {
            ((VitalSign*)[self.object_list objectAtIndex:i]).isExpanded = false;
            ((VitalSign*)[self.object_list objectAtIndex:i]).isMinimized = false;
        }
        self.index_last_expanded = -1;
        self.display_conf_flag = true;
        [self.customViewNavButton setBackgroundImage:[UIImage imageNamed:@"Custom_View_Selected.png"] forState:UIControlStateNormal];
        [self.defaultViewNavButton setBackgroundImage:[UIImage imageNamed:@"Default_View.png"] forState:UIControlStateNormal];
    }
    
    // Finds index of currently expanded
    int index_now_expanded = 0;
    for (int i = 0; i < [self.object_list count]; i++) {
        if ([[[self.object_list objectAtIndex:i] expand] isEqual:buttonClicked])
            index_now_expanded = i;
    }
    
    // No screen is currently expanded - expand it
    if (self.index_last_expanded == -1) {
        [self expandWindowAtIndex:index_now_expanded];
        
        ((VitalSign*)[self.object_list objectAtIndex:index_now_expanded]).isExpanded = true;
        ((VitalSign*)[self.object_list objectAtIndex:index_now_expanded]).isMinimized = false;
        self.index_last_expanded = index_now_expanded;
    }
    
    // Simply closing the expanded view from previously
    else if (self.index_last_expanded == index_now_expanded) {
        [self unexpandWindowAtIndex:self.index_last_expanded];
        
        ((VitalSign*)[self.object_list objectAtIndex:self.index_last_expanded]).isExpanded = false;
        self.index_last_expanded = -1;
    }
    
    // Old expanded view is not new expanded view
    else  {
        // First close the old window
        [self unexpandWindowAtIndex:self.index_last_expanded];
        ((VitalSign*)[self.object_list objectAtIndex:self.index_last_expanded]).isExpanded = false;

        
        // Now open the new window
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(slide_animate_time * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self expandWindowAtIndex:index_now_expanded];
            
            ((VitalSign*)[self.object_list objectAtIndex:index_now_expanded]).isExpanded = true;
            ((VitalSign*)[self.object_list objectAtIndex:index_now_expanded]).isMinimized = false;
            self.index_last_expanded = index_now_expanded;
        });
    }

}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Expand window
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)expandWindowAtIndex:(int)index {
    // Animate the bar moving underneath the menu buttons
    UIView *bar = ((VitalSign*)[self.object_list objectAtIndex:index]).menuButtonUnderline;
    bar.frame = CGRectMake(button_underline_x_history, button_underline_y, button_underline_width_history, button_underline_height);
    
    // Hide Alarms Menu
    ((VitalSign*)[self.object_list objectAtIndex:index]).menuAlarmsView.hidden = true;
    [((VitalSign*)[self.object_list objectAtIndex:index]).menuAlarmsButton setSelected:false];
    
    // Hide Settings Menu
    ((VitalSign*)[self.object_list objectAtIndex:index]).menuSettingsView.hidden = true;
    [((VitalSign*)[self.object_list objectAtIndex:index]).menuSettingsButton setSelected:false];
    
    // Show History Menu
    ((VitalSign*)[self.object_list objectAtIndex:index]).menuHistoryView.hidden = false;
    [((VitalSign*)[self.object_list objectAtIndex:index]).menuHistoryButton setSelected:true];
    
    ((VitalSign*)[self.object_list objectAtIndex:index]).menuView.hidden = false;
    // Handle graph objects first
    if ([[self.object_list objectAtIndex:index] graph] != NULL) {
        if ([[self.object_list objectAtIndex:index] isMinimized]) {
            [self minimizeView:[self.object_list objectAtIndex:index] shrink:false];
        }
        for (int i = index+1; i < [self.object_list count]; i++) {
            if ([[self.object_list objectAtIndex:index] isMinimized])
                [self slideView:[self.object_list objectAtIndex:i] toDirection:true byHeight:0];
            [self slideView:[self.object_list objectAtIndex:i] toDirection:true byHeight:2];
        }
    }
    // Handle non graph object (everything moves up)
    else {
        if ([[self.object_list objectAtIndex:index] isMinimized])
            [self minimizeView:[self.object_list objectAtIndex:index] shrink:false];
        for (int i = 0; i < [self.object_list count]; i++) {
            if (i != index)
                [self slideView:[self.object_list objectAtIndex:i] toDirection:false byHeight:2];
            else
                [self slideViewNoGraph:[self.object_list objectAtIndex:i] toDirection:false byHeight:2];
        }
    }
    
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Unexpand window
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)unexpandWindowAtIndex:(int)index {
    // Handle graph objects first
    if ([[self.object_list objectAtIndex:index] graph] != NULL) {
        for (int i = index+1; i < [self.object_list count]; i++) {
            [self slideView:[self.object_list objectAtIndex:i] toDirection:false byHeight:2];
        }
        [self performSelector:@selector(hideView:) withObject:[[self.object_list objectAtIndex:index] menuView] afterDelay:slide_animate_time];
    }
    // Handle non graph object (everything moves down)
    else {
        for (int i = 0; i < [self.object_list count]; i++) {
            if (i != index)
                [self slideView:[self.object_list objectAtIndex:i] toDirection:true byHeight:2];
            else
                [self slideViewNoGraph:[self.object_list objectAtIndex:i] toDirection:true byHeight:2];
        }
        [self performSelector:@selector(hideView:) withObject:[[self.object_list objectAtIndex:index] menuView] afterDelay:slide_animate_time];
    }
    
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Handles minimize action
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (IBAction)handleMinimizeAction:(id)sender {
    UIButton *buttonClicked = (UIButton *)sender;
    
    if (self.screen_locked)
        return;
    
    // Automatically switch to custom view
    if (self.display_conf_flag == false) {
        for (int i = 0; i < [self.object_list count]; i++) {
            ((VitalSign*)[self.object_list objectAtIndex:i]).isExpanded = false;
            ((VitalSign*)[self.object_list objectAtIndex:i]).isMinimized = false;
        }
        self.index_last_expanded = -1;
        self.display_conf_flag = true;
        [self.customViewNavButton setBackgroundImage:[UIImage imageNamed:@"Custom_View_Selected.png"] forState:UIControlStateNormal];
        [self.defaultViewNavButton setBackgroundImage:[UIImage imageNamed:@"Default_View.png"] forState:UIControlStateNormal];
    }
    
    // Finds index of currently minimized
    int index_minimized = 0;
    for (int i = 0; i < [self.object_list count]; i++) {
        if ([[[self.object_list objectAtIndex:i] minimize] isEqual:buttonClicked])
            index_minimized = i;
    }
    
    // Current window is already minimized, unminimize it
    if ([[self.object_list objectAtIndex:index_minimized] isMinimized]) {
        if ([[self.object_list objectAtIndex:index_minimized] graph] != NULL) {
            [self minimizeView:[self.object_list objectAtIndex:index_minimized] shrink:false];
            for (int i = index_minimized+1; i < [self.object_list count]; i++) {
                [self slideView:[self.object_list objectAtIndex:i] toDirection:true byHeight:0];
            }
        }
        else {
            [self minimizeView:[self.object_list objectAtIndex:index_minimized] shrink:false];
        }
        ((VitalSign*)[self.object_list objectAtIndex:index_minimized]).isMinimized = false;
    }
    
    // Minimize a window
    else {
        // Graph windows and non graph windows need to be treated differently
        if ([[self.object_list objectAtIndex:index_minimized] graph] != NULL) {
            // Shrink the window
            [self minimizeView:[self.object_list objectAtIndex:index_minimized] shrink:true];
            // Slide everything else up, depending on if its currently selected
            for (int i = index_minimized+1; i < [self.object_list count]; i++) {
                if ([[self.object_list objectAtIndex:index_minimized] isExpanded]) {
                    [self slideView:[self.object_list objectAtIndex:i] toDirection:false byHeight:2];
                    [self performSelector:@selector(hideView:) withObject:[[self.object_list objectAtIndex:index_minimized] menuView] afterDelay:slide_animate_time];
                    self.index_last_expanded = -1;
                }
                [self slideView:[self.object_list objectAtIndex:i] toDirection:false byHeight:0];
            }
        }
        else {
            // Shrink the window
            [self minimizeView:[self.object_list objectAtIndex:index_minimized] shrink:true];

        }
        ((VitalSign*)[self.object_list objectAtIndex:index_minimized]).isMinimized = true;
        ((VitalSign*)[self.object_list objectAtIndex:index_minimized]).isExpanded = false;
    }
    
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Makes URL request to Arduino server
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)accessURLData {
    NSLog(@"Attempting to access URL data ...");
    dispatch_async(kBgQueue, ^{
        //NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:arduinoTemperatureURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:(self.url_time-0.1)];
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
        
        [self performSelectorOnMainThread:@selector(handleURLData:) withObject:jsonData waitUntilDone:YES];
    });
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Sets graphs as hidden or not hidden depending on URL data
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)handleURLData:(NSDictionary *) jsonData {
    
    // Get the flag values from JSON data
    bool ecg_flag = [[jsonData objectForKey:@"ecg"] boolValue];
    bool hr_flag = [[jsonData objectForKey:@"hr"] boolValue];
    
    NSLog(@"The value of ecg flag = %@", ecg_flag ? @"true" : @"false");
    NSLog(@"The value of hr flag = %@", hr_flag ? @"true" : @"false");
    [self unplugAction:ecg_flag forObject:0];
    [self unplugAction:hr_flag forObject:4];
    
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Deals with formatting the rest of the screen depending on whether or not a plug is unplugged
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)unplugAction:(bool)unplugFlag forObject:(int)index {
    if (unplugFlag == true) { // The vital sign is unplugged
        ((VitalSign*)[self.object_list objectAtIndex:index]).graph.hidden = true;
        ((VitalSign*)[self.object_list objectAtIndex:index]).errorMessage.hidden = false;
        
        if ([[self.object_list objectAtIndex:index] unplugFlash] == nil) {
            NSTimer *flash = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(activateAlarmFlash:)    userInfo:[self.object_list objectAtIndex:index] repeats:YES];
            ((VitalSign*)[self.object_list objectAtIndex:index]).unplugFlash = flash;
        }
    }
    else { // The vital sign is not unplugged
        if (((VitalSign*)[self.object_list objectAtIndex:index]).encloseView.hidden == true) {
            
            if ([[self.object_list objectAtIndex:index] isMinimized]) {
                // Unminimize first
                [self minimizeView:[self.object_list objectAtIndex:index] shrink:false];
                ((VitalSign*)[self.object_list objectAtIndex:index]).isMinimized = false;
                // Slide everything else down
                if ([[self.object_list objectAtIndex:index] graph] != NULL) {
                    for (int i = index+1; i < [self.object_list count]; i++) {
                        [self slideView:[self.object_list objectAtIndex:i] toDirection:true byHeight:0];
                    }
                }
                
                if ([[self.object_list objectAtIndex:index] graph] != NULL) {
                    for (int i = index; i < [self.object_list count]; i++) {
                        [self slideView:[self.object_list objectAtIndex:i] toDirection:true byHeight:3];
                    }
                }
                
                
            }
            
            else {
                if ([[self.object_list objectAtIndex:index] graph] != NULL) {
                    for (int i = index; i < [self.object_list count]; i++) {
                        [self slideView:[self.object_list objectAtIndex:i] toDirection:true byHeight:1];
                    }
                }
            }
            
            ((VitalSign*)[self.object_list objectAtIndex:index]).encloseView.hidden = false;
        }
        
        ((VitalSign*)[self.object_list objectAtIndex:index]).graph.hidden = false;
        ((VitalSign*)[self.object_list objectAtIndex:index]).errorMessage.hidden = true;
        
        [[[self.object_list objectAtIndex:index] unplugFlash] invalidate];
        ((VitalSign*)[self.object_list objectAtIndex:index]).unplugFlash = nil;
        ((VitalSign*)[self.object_list objectAtIndex:index]).encloseView.backgroundColor = [UIColor blackColor];
    }
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Changes the background color of the unplugged vital sign
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)activateAlarmFlash:(NSTimer*)timer {
    if (((VitalSign*)[timer userInfo]).encloseView.backgroundColor == [UIColor blackColor])
        ((VitalSign*)[timer userInfo]).encloseView.backgroundColor = [UIColor yellowColor];
    else
        ((VitalSign*)[timer userInfo]).encloseView.backgroundColor = [UIColor blackColor];
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
