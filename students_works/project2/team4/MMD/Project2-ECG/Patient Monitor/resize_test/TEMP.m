//
//  TEMP.m
//  resize_test
//
//  Created by Inbar Fried on 11/7/14.
//  Copyright (c) 2014 Team4. All rights reserved.
//

#import "TEMP.h"

@implementation TEMP

- (void) initLabel {
    self.previousThreshold           = 100.0;
    self.currentTemperatureThreshold = 100.0;
    UIColor *my_orange = [UIColor colorWithRed:255.0/256.0 green:127.0/256.0 blue:36.0/256.0 alpha:1.0];
    
    self.currentTemp = [[UILabel alloc] initWithFrame:CGRectMake(70, self.frame.size.height / 2, 30, 10)];
    [self.currentTemp setBackgroundColor:[UIColor clearColor]];
    [self.currentTemp setTextColor:my_orange];
    [self.currentTemp setText:@"96.0°"];
    self.currentTemp.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:50];
    [self.currentTemp sizeToFit];
    [self.currentTemp setFrame:CGRectMake(130, self.frame.size.height / 2 - self.currentTemp.frame.size.height / 2,
                                          self.currentTemp.frame.size.width + 50, self.currentTemp.frame.size.height)];
    // render to screen
    [self addSubview:self.currentTemp];
    self.pastMinuteTempsCapacity = 60;
    self.pastMinuteTemps = [[NSMutableArray alloc] initWithCapacity:self.pastMinuteTempsCapacity];
//    self.thresholdChange = 1;
}

- (void) updateLabelLocation {
    // done when button are resized based on user clicks
    [self.currentTemp setFrame:CGRectMake(130, self.frame.size.height / 2 - self.currentTemp.frame.size.height / 2,
                                          self.currentTemp.frame.size.width, self.currentTemp.frame.size.height)];
}

- (void) convertToCelsius {
    float convertedTemp = ([self.currentTemp.text floatValue] - 32.0) * (5.0/9.0);
    self.currentTemp.text = [NSString stringWithFormat:@"%0.01f°", convertedTemp];
}

- (void) convertToFahrenheit {
    float convertedTemp = ([self.currentTemp.text floatValue] * (9.0/5.0)) + 32;
    self.currentTemp.text = [NSString stringWithFormat:@"%0.01f°", convertedTemp];
}

- (BOOL) isCurrentTempAboveThreshold {
    return ([self.currentTemp.text floatValue] > self.currentTemperatureThreshold);
}

- (BOOL) isAverageTempAboveThreshold {
    return (self.currentMinuteAverage > self.currentTemperatureThreshold);
}

- (BOOL) isAverageTempBelowPreviousThreshold {
    return (self.currentMinuteAverage < self.previousThreshold);
}

- (void) setMinuteAverageTemp {
    float sum = 0.0;
    for (int i = 0; i < [self.pastMinuteTemps count]; i++) {
        sum = sum + [[self.pastMinuteTemps objectAtIndex:i] floatValue];
    }
    self.currentMinuteAverage = sum / [self.pastMinuteTemps count];
}

- (void) populateTempsArray: (float) newTemperature {
    [self.pastMinuteTemps insertObject:[NSNumber numberWithFloat:newTemperature] atIndex:(self.numTempReadIn % self.pastMinuteTempsCapacity)];
    self.numTempReadIn = self.numTempReadIn + 1;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
 
}
*/

@end
