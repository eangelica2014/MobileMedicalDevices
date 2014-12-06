//
//  Graph.h
//  PatientMonitor
//
//  Created by Alex Henry on 11/13/14.
//  Copyright (c) 2014 Alexander Henry. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Graph : UIView

@property (nonatomic, strong) NSMutableArray *graphXData;
@property (nonatomic, strong) NSMutableArray *graphYData;
@property int num_points;
@property int point_width;

- (void)setGraphColor:(UIColor*)color;
- (id)initWithFrame:(CGRect)frame withYScale:(float)yScale withYShift:(float)yShift withSampleRate:(float)sampleRate
   withPointSpacing:(int)pointSpacing;

@end
