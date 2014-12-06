//
//  global_const.h
//  PatientMonitor
//
//  Created by Alex Henry on 11/11/14.
//  Copyright (c) 2014 Alexander Henry. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface global_const : NSObject

// Viewing window constants
extern int const guide_top;
extern int const guide_bottom;
extern int const guide_left;
extern int const guide_right;

// Viewing window++
extern int const minimized_window_height;
extern float const slide_animate_time;

// Menu view window
extern int const height_menu;

// Menu sub-view window
extern int const menu_subview_width;
extern int const menu_subview_height;
extern int const menu_subview_x;
extern int const menu_subview_y;

// Menu button constants
extern int const menu_button_width;
extern int const menu_button_height;
extern int const menu_button_y;
extern int const history_button_x;
extern int const alarms_button_x;
extern int const settings_button_x;

// Menu button underline constants
extern int const button_underline_height;
extern int const button_underline_y;
extern int const button_underline_width_history;
extern int const button_underline_x_history;
extern int const button_underline_width_settings;
extern int const button_underline_x_settings;
extern int const button_underline_width_alarms;
extern int const button_underline_x_alarms;

// Title label constants
extern int const space_left_title_graph;    // space between *left* of enclosing window and left of title label
extern int const space_left_title_nograph;  // space between *left* of enclosing window and left of title label
extern int const space_top_title;
extern int const width_title;
extern int const height_title;

// Error message label constants
extern int const space_left_error_message_graph;    // space between *left* of enclosing window and left of title label
extern int const space_left_error_message_nograph;  // space between *left* of enclosing window and left of title label
extern int const space_top_error_message;
extern int const width_error_message;
extern int const height_error_message;

// Close button constants
extern int const space_left_close; // space between right of enclosing window and left of close button
extern int const space_top_close;  // space between top of window and top of close button
extern int const height_close;
extern int const width_close;

// Expand button constants
extern int const space_left_expand; // space between right of enclosing window and left of expand button
extern int const space_top_expand;  // space between top of window and top of expand button
extern int const height_expand;
extern int const width_expand;

// Minimize button constants
extern int const space_left_minimize; // space between right of enclosing window and left of minimize button
extern int const space_top_minimize;  // space between top of window and top of minimize button
extern int const height_minimize;
extern int const width_minimize;

// Graph window constants
extern int const space_graph_x;
extern int const space_graph_y;
extern int const width_graph;

// Nav buttons constants
extern int const nav_guide_top;
extern int const nav_guide_bottom;
extern int const nav_guide_left;
extern int const nav_guide_right;

// Icon constants
extern int const space_icon_x; // space between left of view and left of icon
extern int const space_icon_y; // space between top of view and top of icon

@end
