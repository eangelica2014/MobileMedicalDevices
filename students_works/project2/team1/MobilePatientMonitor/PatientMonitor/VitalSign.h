//
//  VitalSign.h
//  PatientMonitor
//
//  Created by Alex Henry on 11/11/14.
//  Copyright (c) 2014 Alexander Henry. All rights reserved.
//

#import "Graph.h"
#import "Numeric.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface VitalSign : NSObject

@property UILabel *titlelabel;
@property UIView *encloseView;
@property UIView *menuView;
@property UIView *line;
@property UIView *lineLeft;
@property UIView *lineRight;
@property UIImageView *icon;
@property UIButton *closeButton;
@property UIButton *expand;
@property UIButton *minimize;
@property Graph *graph;
@property Numeric *numeric;
@property UILabel *unitLabel;
@property UILabel *errorMessage;
@property NSTimer *unplugFlash;
@property NSMutableArray *data;
@property bool isClosed;
@property bool isExpanded;
@property bool isMinimized;
@property bool isHistory;
@property bool isSettings;
@property bool isAlarms;
@property UIButton *menuSettingsButton;
@property UIButton *menuHistoryButton;
@property UIButton *menuAlarmsButton;
@property UIView *menuSettingsView;
@property UIView *menuHistoryView;
@property UIView *menuAlarmsView;
@property UIView *menuButtonUnderline;

@property UIButton *History_Histogram_Button;
@property UIButton *History_Line_Graph_Button;
@property UIButton *History_Numeric_Button;

@property UIView *Histogram_View;
@property UIView *Line_Graph_View;
@property UIView *Numeric_View;


@end
