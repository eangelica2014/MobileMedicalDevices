//
//  TEMP.h
//  resize_test
//
//  Created by Inbar Fried on 11/7/14.
//  Copyright (c) 2014 Team4. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TEMP : UIView

@property float currentTemperatureThreshold;
@property float currentMinuteAverage;
@property int numTempReadIn;
@property float previousThreshold;
@property (strong, nonatomic) NSMutableArray    *pastMinuteTemps;
@property (strong, nonatomic) UILabel           *currentTemp;
@property int pastMinuteTempsCapacity;

- (void) initLabel;
- (void) updateLabelLocation;
- (void) convertToCelsius;
- (void) convertToFahrenheit;
- (BOOL) isCurrentTempAboveThreshold;
- (BOOL) isAverageTempAboveThreshold;
- (BOOL) isAverageTempBelowPreviousThreshold;
- (void) setMinuteAverageTemp;
- (void) populateTempsArray: (float) newTemperature;


@end
