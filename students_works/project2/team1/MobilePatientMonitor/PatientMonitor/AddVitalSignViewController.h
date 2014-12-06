//
//  AddVitalSignViewController.h
//  PatientMonitor
//
//  Created by Bradley Frizzell on 12/2/14.
//  Copyright (c) 2014 Alexander Henry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VitalSign.h"

@protocol AddVitalSignDelegate <NSObject>
@required
-(void)selectedVitalSign:(NSString*)name;
@end

@interface AddVitalSignViewController : UITableViewController

@property (nonatomic, strong) NSMutableArray *vsNames;
@property (nonatomic, weak) id<AddVitalSignDelegate> delegate;

- (id)initWithStyle:(UITableViewStyle)style andTitles:(NSArray*)titleArray;


@end
