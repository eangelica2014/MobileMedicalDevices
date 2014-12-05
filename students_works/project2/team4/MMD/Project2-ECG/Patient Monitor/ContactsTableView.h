//
//  ContactsTableView.h
//  resize_test
//
//  Created by Inbar Fried on 11/15/14.
//  Copyright (c) 2014 Team4. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactsTableView : UITableViewController

@property (strong, nonatomic) NSMutableArray *names;
@property (strong, nonatomic) NSMutableArray *numbers;

@end
