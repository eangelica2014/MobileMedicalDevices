//
//  TheData.m
//  graphTest
//
//  Created by Inbar Fried on 11/2/14.
//  Copyright (c) 2014 Team4. All rights reserved.
//

#import "TheData.h"

@interface TheData()

@property (nonatomic, strong) NSMutableArray *dataX;
@property (nonatomic, strong) NSMutableArray *dataY;

@property (nonatomic, strong) NSMutableArray *coefs;

@end

static NSString *_file;

@implementation TheData

- (NSArray *) getDataX
{
    return (NSArray *) self.dataX;
}

- (NSArray *) getDataY
{
    return (NSArray *) self.dataY;
}

- (id) initWithFile: (NSString*) file {
    self = [super init];
    if (self)
    {
        [self myInitialization: file];
    }
    return self;
}

- (id) init {
    return [self initWithFile: _file];
}

- (void)myInitialization: (NSString *) file {
    // Initialization code
    
    NSString *filePathCSV = [[NSBundle mainBundle] pathForResource:file ofType:@"csv"];
    
    [self readColumnFromCSV:filePathCSV AtColumn:1];
    
    self.dataX = [NSMutableArray arrayWithArray: [self readColumnFromCSV:filePathCSV AtColumn:0] ];
    self.dataY = [NSMutableArray arrayWithArray: [self readColumnFromCSV:filePathCSV AtColumn:1] ];
    
    for (NSInteger i = 0; i < [self.dataX count]; ++i) {
        NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
        [f setNumberStyle:NSNumberFormatterDecimalStyle];
        self.dataX[i] = @([[f numberFromString:[self.dataX objectAtIndex:i]] floatValue] + 14); // NSNumber
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
}

-(NSString *)description
{
    return [NSString stringWithFormat:@"TheData - read from CSV file returns array of NSNumbers."];
}


@end
