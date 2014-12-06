//
//  global_const.m
//  PatientMonitor
//
//  Created by Alex Henry on 11/11/14.
//  Copyright (c) 2014 Alexander Henry. All rights reserved.
//

#import "global_const.h"

@implementation global_const

// Viewing window constants
int const guide_top = 59;
int const guide_bottom = 659;
int const guide_left = 0;
int const guide_right = 1024;

// Viewing window++
int const minimized_window_height = 50;
float const slide_animate_time = 0.5;

// Menu view window
int const height_menu = 200;

// Menu sub-view window
int const menu_subview_width = 1024;
int const menu_subview_height = 150;
int const menu_subview_x = 0;
int const menu_subview_y = 45;

// Menu button constants
int const menu_button_width = 80;
int const menu_button_height = 30;
int const menu_button_y = 10;
int const history_button_x = 370;
int const alarms_button_x = 570;
int const settings_button_x = 470;

// Menu button underline constants
int const button_underline_height = 1;
int const button_underline_y=40;
int const button_underline_width_history = 58;
int const button_underline_x_history = 380;
int const button_underline_width_settings = 70;
int const button_underline_x_settings = 475;
int const button_underline_width_alarms = 58;
int const button_underline_x_alarms = 580;

// Title label constants
int const space_left_title_graph = (guide_right-guide_left)*3/4;
int const space_left_title_nograph = 50;
int const space_top_title = 5;
int const width_title = 150;
int const height_title = 50;

// Error message label constants
int const space_left_error_message_graph = 20;
int const space_left_error_message_nograph = 20;
int const space_top_error_message = 40;
int const width_error_message = 600;
int const height_error_message = 100;

// Close button constants
int const space_left_close = 50;
int const space_top_close = 10;
int const height_close = 44;
int const width_close = 44;

// Expand button constants
int const space_left_expand = 150;
int const space_top_expand = 10;
int const height_expand = 44;
int const width_expand = 44;

// Minimize button constants
int const space_left_minimize = 100;
int const space_top_minimize = 10;
int const height_minimize = 44;
int const width_minimize = 44;

// Graph window constants
int const space_graph_x = 10;
int const space_graph_y = 10;
int const width_graph = (guide_right-guide_left)*3/4;

// Nav buttons constants
int const nav_guide_top = 680;
int const nav_guide_bottom = 738;
int const nav_guide_left = 13;
int const nav_guide_right = 1003;

// Icon constants
int const space_icon_x = 80;
int const space_icon_y = 70;

@end
