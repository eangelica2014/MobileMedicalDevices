//
//  RecordsViewController.m
//  resize_test_stretch
//
//  Created by Inbar Fried on 11/29/14.
//  Copyright (c) 2014 Team4. All rights reserved.
//

#import "RecordsViewController.h"

@interface RecordsViewController ()

@end

@implementation RecordsViewController

- (void) myInitialization {
    self.patientName = @"A. Rennel";
    [self initializeHeader];
    [self initializeLines];
    [self initializeData];
}

- (void) initializeData {
    for (int i = 0; i < 4; i++){
        UILabel *name = [[UILabel alloc] initWithFrame: CGRectMake(10, 65 + 60 * i, 100, 16)];
        [name setText:self.patientName];
        name.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16];
        [self.view addSubview:name];
        
        UILabel *alarmType = [[UILabel alloc] initWithFrame:CGRectMake(110, 65 + 60 * i, 100, 16)];
        [alarmType setText:@"TEMP"];
        alarmType.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16];
        [self.view addSubview:alarmType];
        
        NSString *val = NULL;
        NSString *t   = NULL;
        if (i == 0) { val = @"97.8° F"; t = @"12/3/2014 21:31"; }
        if (i == 1) { val = @"99.3° F"; t = @"12/3/2014 21:35"; }
        if (i == 2) { val = @"96.5° F"; t = @"12/4/2014 3:21"; }
        if (i == 3) { val = @"97.2° F"; t = @"12/4/2014 5:13"; }
        
        UILabel *value = [[UILabel alloc] initWithFrame:CGRectMake(210, 65 + 60 * i, 100, 16)];
        [value setText:val];
        value.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16];
        [self.view addSubview:value];
        
        UILabel *time = [[UILabel alloc] initWithFrame:CGRectMake(350, 65 + 60 * i, 150, 16)];
        [time setText:t];
        time.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16];
        [self.view addSubview:time];
    }
    
}

- (void) initializeHeader {
    UILabel *patient = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 100, 16)];
    [patient setText:@"Patient"];
    patient.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:20];
    [self.view addSubview:patient];
    
    UILabel *alarm = [[UILabel alloc] initWithFrame:CGRectMake(110, 10, 100, 16)];
    [alarm setText:@"Alarm"];
    alarm.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:20];
    [self.view addSubview:alarm];
    
    UILabel *value = [[UILabel alloc] initWithFrame:CGRectMake(210, 10, 100, 16)];
    [value setText:@"Maximum"];
    value.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:20];
    [self.view addSubview:value];
    
    UILabel *time = [[UILabel alloc] initWithFrame:CGRectMake(350, 10, 100, 16)];
    [time setText:@"Time"];
    time.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:20];
    [self.view addSubview:time];
}

- (void) initializeLines {
    UIView *lineView0 = [[UIView alloc] initWithFrame:CGRectMake(0, 40, self.view.bounds.size.width, 4)];
    lineView0.backgroundColor = [UIColor blackColor];
    [self.view addSubview:lineView0];
    UIView *lineView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 100, self.view.bounds.size.width, 1)];
    lineView1.backgroundColor = [UIColor blackColor];
    [self.view addSubview:lineView1];
    UIView *lineView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 160, self.view.bounds.size.width, 1)];
    lineView2.backgroundColor = [UIColor blackColor];
    [self.view addSubview:lineView2];
    UIView *lineView3 = [[UIView alloc] initWithFrame:CGRectMake(0, 220, self.view.bounds.size.width, 1)];
    lineView3.backgroundColor = [UIColor blackColor];
    [self.view addSubview:lineView3];
    UIView *lineView4 = [[UIView alloc] initWithFrame:CGRectMake(0, 280, self.view.bounds.size.width, 1)];
    lineView4.backgroundColor = [UIColor blackColor];
    [self.view addSubview:lineView4];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self myInitialization];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
