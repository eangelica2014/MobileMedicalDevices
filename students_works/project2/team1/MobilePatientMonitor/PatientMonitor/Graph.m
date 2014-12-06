//
//  Graph.m
//  PatientMonitor
//
//  Created by Alex Henry on 11/13/14.
//  Copyright (c) 2014 Alexander Henry. All rights reserved.
//

#import "Graph.h"

@interface Graph ()

@property (nonatomic, assign) CGFloat xScale;
@property (nonatomic, assign) CGFloat yScale;
@property (nonatomic, assign) CGFloat yShift;
@property (nonatomic, assign) NSInteger plotStep; // This value corresponds to where the graph starts
@property (nonatomic, assign) NSInteger dataStep; // Where the data we are reading from starts
@property UIColor *axisColor;
@property UIColor *plotColor;
@property (nonatomic, strong) NSMutableArray *dataX;
@property (nonatomic, strong) NSMutableArray *dataY;
@property  int indexX; // This is the index to insert new data blocks at for X vals
@property  int indexY; // This is the index to insert new data blocks at for Y vals
@property  int dataSize;
@property int pointSpacing;
@property float sampleRate; // This is the rate the samples were taken at.

@end

@implementation Graph


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (NSMutableArray *) graphXData
{
    if (!_graphXData){
        _graphXData = [[NSMutableArray alloc] init];
    }
    self.dataSize = [_graphXData count];
        return _graphXData;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (NSMutableArray *) graphYData
{
    if (!_graphYData){
        _graphYData = [[NSMutableArray alloc] init];
    }
    
    return _graphYData;
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void) drawAxisX
{
    CGPoint start = CGPointMake(0, self.frame.size.height/2);
    CGPoint end = CGPointMake(self.frame.size.width, self.frame.size.height/2);
    
    UIBezierPath *axisX = [[UIBezierPath alloc] init];
    [self.axisColor setStroke];
    axisX.lineWidth = 1.0;
    [axisX moveToPoint: start];
    [axisX addLineToPoint: end];
    [axisX stroke];
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void) drawAxisY
{
    CGPoint start = CGPointMake(0, 0);
    CGPoint end = CGPointMake(0, self.frame.size.height);
    
    UIBezierPath *axisY = [[UIBezierPath alloc] init];
    [self.axisColor setStroke];
    axisY.lineWidth = 3.0;
    [axisY moveToPoint: start];
    [axisY addLineToPoint:end];
    [axisY stroke];
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)setFrame:(CGRect)rect {

    [super setFrame:rect];
    
    self.yScale = self.frame.size.height/3;
    self.xScale = self.frame.size.width/self.point_width;

}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)myInitialization
{
    // Initialization code
    self.backgroundColor = [UIColor clearColor];
    self.axisColor = [UIColor clearColor];
    //self.yScale = -.1;
    self.plotStep = 0;
    self.dataStep = 0;
    self.point_width = 1000*(self.sampleRate/250); // Width of the graph being displayed, in points
    self.num_points = self.point_width*.95; // Number of points on the screen at a time
    
    //self.sampleRate = 250; // In Hz
    self.xScale = self.frame.size.width/self.point_width;
    //NSLog(@"width is %f",self.frame.size.width);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (id)initWithCoder:(NSCoder*)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self myInitialization];
    }
    
    return self;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (id)initWithFrame:(CGRect)frame withYScale:(float)yScale withYShift:(float)yShift withSampleRate:(float)sampleRate
     withPointSpacing:(int)pointSpacing
{
    self = [super initWithFrame:frame];
    self.yScale = yScale;
    self.yShift = yShift;
    self.sampleRate = sampleRate;
    self.pointSpacing = pointSpacing;
    if (self) {
        // Initialization code
        [self myInitialization];
    }
    return self;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void) AnimatedPlacePoint
{
    [self.graphXData copy];
    NSArray *ay = [self.graphYData copy];

    [NSTimer scheduledTimerWithTimeInterval:((1/(self.sampleRate / self.pointSpacing))) target:self selector:@selector(goTime:) userInfo:nil repeats:YES];

    BOOL left_point_placed = false;
    
    UIBezierPath *rightPath = [UIBezierPath bezierPath]; // Right path is the path on the right side of the screen
    UIBezierPath *leftPath = [UIBezierPath bezierPath]; // Left path is on the left side of the screen, only
    
    // when the rightPath has gotten all the way to the edge of the screen
    CGPoint pa = CGPointMake(self.plotStep%self.point_width,
                             [ay[(self.plotStep)%self.dataSize] floatValue]);
    CGPoint ra = [self scalePoint2:pa];
    [rightPath moveToPoint:ra];
    float last_x_value=0;

    [self.plotColor setStroke];
    [rightPath stroke];
    [leftPath stroke];
    
    for (NSInteger i = 0; i < self.num_points; i=i+self.pointSpacing) {
        if (left_point_placed == false){
            // If the only graph on the screen is the right path
            if (last_x_value>(self.plotStep+i)%self.point_width){
                // If the right path has reached the right edge of the graph's frame,
                // then we must begin printing future points from the left side, so
                // we need to use a different path, i.e. the 'leftPath'
                left_point_placed = true;
                pa = CGPointMake((self.plotStep+i)%self.point_width,
                                 [ay[(self.dataStep+i)%self.dataSize] floatValue]);
                ra = [self scalePoint2:pa];
                [leftPath moveToPoint:ra];
                left_point_placed = true;
                [leftPath addCurveToPoint:ra controlPoint1:ra controlPoint2:ra];
                last_x_value =(self.plotStep)%self.point_width;
            }
            else {
                pa = CGPointMake((self.plotStep+i)%self.point_width,
                                 [ay[(self.dataStep+i)%self.dataSize] floatValue]);
                ra = [self scalePoint2:pa];
                [rightPath addCurveToPoint:ra controlPoint1:ra controlPoint2:ra];
                last_x_value =(self.plotStep+i)%self.point_width;}
        }
        else {
            pa = CGPointMake((self.plotStep+i)%self.point_width,
                             [ay[(self.dataStep+i)%self.dataSize] floatValue]);
            ra = [self scalePoint2:pa];
            [leftPath addCurveToPoint:ra controlPoint1:ra controlPoint2:ra];
            last_x_value =(self.plotStep+i)%self.point_width;
        }
    }
    
    rightPath.lineWidth = 2;
    leftPath.lineWidth = 2;
    [self.plotColor setStroke];
    [rightPath stroke];
    [leftPath stroke];
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void) setGraphColor:(UIColor*)color {
    self.plotColor = color;
    //self.scaleY = self.scaleY/2;
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void) goTime: (NSTimer *) timer
{
    //NSLog(@"%s", __FUNCTION__);
    
    self.plotStep = (self.plotStep + self.pointSpacing)%self.point_width;
    self.dataStep = (self.dataStep + self.pointSpacing)%self.dataSize;
    //NSLog(@"Timer");
    [timer invalidate];
    [self setNeedsDisplay];
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (CGPoint) scalePoint2: (CGPoint) data

{
    
    CGFloat plotY = (data.y*self.yScale+self.frame.size.height/2 + self.yShift);
    CGFloat plotX = (data.x*self.xScale);
    
    return CGPointMake(plotX, plotY);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [self drawAxisX];
    [self drawAxisY];
    [self AnimatedPlacePoint];
    
}


@end