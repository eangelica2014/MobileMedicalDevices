//
//  Graph.m
//  PatientMonitor
//
//  Created by Alex Henry on 11/13/14.
//  Copyright (c) 2014 Alexander Henry. All rights reserved.
//

#import "Numeric.h"

@interface Numeric ()

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
@property UILabel *numericLabel;

@end

@implementation Numeric


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

}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void) drawAxisY
{

}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)setFrame:(CGRect)rect {
    
    [super setFrame:rect];
    
    
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
    self.point_width = 1000; // Width of the graph being displayed, in points
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
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    self.numericLabel = [[UILabel alloc]init];
    
    [self.numericLabel setText:@"-"];
    [self.numericLabel setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    [self.numericLabel setTextColor:[UIColor whiteColor]];
    [self.numericLabel setFont:[UIFont fontWithName:@"Helvetica" size:40]];
    [self addSubview:self.numericLabel];
    
    if (self) {
        // Initialization code
        [self myInitialization];
    }
    
    self.backgroundColor = [UIColor clearColor];
    
    return self;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void) AnimatedPlacePoint
{
    [self.graphXData copy];
    NSArray *ay = [self.graphYData copy];
    //NSLog(@"In animated place point");
    
    [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(goTime:) userInfo:nil repeats:YES];
    
    
    // when the rightPath has gotten all the way to the edge of the screen
    self.numericLabel.text = [NSString stringWithFormat: @"%d",[ay[(self.dataStep)] intValue]];

    

    
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void) setGraphColor:(UIColor*)color {
    self.plotColor = color;
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void) goTime: (NSTimer *) timer
{
    //NSLog(@"%s", __FUNCTION__);
    
    self.plotStep = (self.plotStep + self.pointSpacing)%self.point_width;
    self.dataStep = (self.dataStep + 1)%self.dataSize;
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