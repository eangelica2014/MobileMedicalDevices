//
//  Data.m
//  PatientMonitor
//
//  Created by Alex Henry on 11/13/14.
//  Copyright (c) 2014 Alexander Henry. All rights reserved.
//

/* 
 This module is for reading in data from a .csv file. It will not and can not handle data
 from any other source at this time. 
 */


#import "Data.h"

@interface Data()

@property (nonatomic, strong) NSMutableArray *dataX;
@property (nonatomic, strong) NSMutableArray *dataY;

@end

@implementation Data

- (NSArray *) getDataX
{
    return (NSArray *) self.dataX;
}

- (NSArray *) getDataY
{
    return (NSArray *) self.dataY;
}


- (id) init
{
    return [self initWithFile:@"DemoData"];
}

-(id) initWithFile:(NSString *) fileName
{
    self = [super init];
    if(self){
        [self myInitialization:fileName];
    }
    return self;
}

- (void)myInitialization: (NSString*) fileName
{
    // Initialization code
    
    NSString *filePathCSV = [[NSBundle mainBundle] pathForResource:fileName ofType:@"csv"];
    
    [self readColumnFromCSV:filePathCSV AtColumn:1];
    
    self.dataX = [NSMutableArray arrayWithArray: [self readColumnFromCSV:filePathCSV AtColumn:0] ];
    self.dataY = [NSMutableArray arrayWithArray: [self readColumnFromCSV:filePathCSV AtColumn:1] ];
    
    for (NSInteger i = 0; i < [self.dataX count]; ++i) {
        NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
        [f setNumberStyle:NSNumberFormatterDecimalStyle];
        self.dataX[i] = [f numberFromString:[self.dataX objectAtIndex:i]]; // NSNumber
        self.dataY[i] = [f numberFromString:[self.dataY objectAtIndex:i]]; // NSNumber
    }
    
}

#pragma mark -- file loader

-(NSMutableArray *)readColumnFromCSV:(NSString*)path AtColumn:(int)column
{
    
    NSMutableArray *readArray=[[NSMutableArray alloc]init];
    
    NSString *fileDataString=[NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSArray *linesArray=[fileDataString componentsSeparatedByString:@"\r"];
    
    for (NSString *lineString in linesArray)
    {
        NSArray *columnArray=[lineString componentsSeparatedByString:@","];
        [readArray addObject:[columnArray objectAtIndex:column]];
    }
    
    return readArray;
    
    // for debug: NSLog(@"%@",readArray);
    
}

-(NSString *)description
{
    return [NSString stringWithFormat:@"TheData - read from CSV file returns array of NSNumbers."];
}

@end
