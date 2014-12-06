//
//  ViewController.h
//  PatientMonitor
//
//  Created by Alex Henry on 11/11/14.
//  Copyright (c) 2014 Alexander Henry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddVitalSignViewController.h"

@interface ViewController : UIViewController <AddVitalSignDelegate>

@property (nonatomic, strong) AddVitalSignViewController *vsPicker;
@property (nonatomic, strong) UIPopoverController *vsPickerPopover;

- (IBAction)addVitalSign:(id)sender;


@end

