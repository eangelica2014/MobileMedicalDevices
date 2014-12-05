//
//  Graph.m
//  graphTest
//
//  Created by Inbar Fried on 11/2/14.
//  Copyright (c) 2014 Team4. All rights reserved.
//

#import "Graph.h"

@interface Graph()

@property (nonatomic, assign) CGFloat scaleX;
@property (nonatomic, assign) CGFloat scaleY;

@property (nonatomic, assign) NSInteger plotStep;

@property (strong, nonatomic) UIColor *color;

@property int numberOfPoints;
@property int numberOfPointsToGraph;

@end

@implementation Graph

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self myInitialization];
    }
    return self;
}

- (NSMutableArray *) graphXData
{
    if (!_graphXData){
        _graphXData = [[NSMutableArray alloc] init];
    }
    return _graphXData;
}

- (NSMutableArray *) graphYData
{
    if (!_graphYData){
        _graphYData = [[NSMutableArray alloc] init];
    }
    return _graphYData;
}

- (void) initializeColor: (UIColor *) color {
    self.color = color;
}

- (void) initializeNumberFor: (NSString*) dataType withColor: (UIColor*) color withUnits: (NSString *) units{
    self.dataType = dataType;
    self.color    = color;
    
    self.units = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width - 120, self.frame.size.height / 2 - 50, 100, 100)];
    [self.units setBackgroundColor:[UIColor clearColor]];
    [self.units setTextColor:self.color];
    [self.units setText: units];
    self.units.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:30];
    [self.units sizeToFit];
    
    self.number = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width - 220, self.frame.size.height / 2 - 50, 150, 100)];
    [self.number setBackgroundColor:[UIColor clearColor]];
    [self.number setTextColor:self.color];
    [self.number setText:@"93"];
    self.number.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:90];
    [self.number sizeToFit];

    // render to screen
    [self addSubview:self.units];
    [self addSubview:self.number];
}

- (void) resizeNumberUnits {
    [self.number setFrame:CGRectMake(self.number.frame.origin.x, self.frame.size.height / 2 - self.number.frame.size.height / 2,
                                          self.number.frame.size.width, self.number.frame.size.height)];

    [self.units setFrame:CGRectMake(self.units.frame.origin.x, self.frame.size.height / 2 - self.units.frame.size.height / 2,
                                     self.units.frame.size.width, self.units.frame.size.height)];
}


- (void)myInitialization
{
    // Initialization code
    // scales the actual graph (not the background)
    self.scaleX   = self.bounds.size.width / 50.0;
    self.scaleY   = self.bounds.size.height / 50.0;
    self.plotStep = 0;
}

- (id)initWithCoder:(NSCoder*)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self myInitialization];
    }
    return self;
}

- (void) drawAxisX
{
    // represented as two points that are connected with a line
    CGPoint start = CGPointMake(14, -0.5);
    CGPoint end   = CGPointMake(57, -0.5);
    
    UIBezierPath *axisX = [[UIBezierPath alloc] init];
    [[UIColor whiteColor] setStroke];
    axisX.lineWidth = 3.0;
    [axisX moveToPoint: [self scalePoint: start]];
    [axisX addLineToPoint:[self scalePoint: end]];
//    [axisX stroke];
}

- (void) drawAxisY
{
    // represented as two points that are connected with a line
    CGPoint start = CGPointMake(14, -14);
    CGPoint end   = CGPointMake(14, 34);
    
    UIBezierPath *axisY = [[UIBezierPath alloc] init];
    [[UIColor whiteColor] setStroke];
    axisY.lineWidth = 3.0;
    [axisY moveToPoint: [self scalePoint: start]];
    [axisY addLineToPoint:[self scalePoint: end]];
//    [axisY stroke];
}

- (void) connectAllPoints:(NSMutableArray *) points {
    
    for (NSInteger i = 0; i < [points count] - 1; ++i){
        CGPoint one = [[points objectAtIndex:i] CGPointValue];
        CGPoint two = [[points objectAtIndex:(i+1)] CGPointValue];
        if (two.x > one.x) {
            UIBezierPath *path = [[UIBezierPath alloc] init];
            [self.color setStroke];
            path.lineWidth = 3.0;
            [path moveToPoint: [[points objectAtIndex:i] CGPointValue]];
            [path addLineToPoint: [[points objectAtIndex:(i+1)] CGPointValue]];
            [path stroke];
        }
    }
}

- (void) updateViewSize {
    self.scaleX   = self.bounds.size.width / 53.0;
    self.scaleY   = self.bounds.size.height / 50.0;
}

- (void) AnimatedPlacePoint
{
    [self updateViewSize];
    self.numberOfPointsToGraph = [self.graphXData count] - 5;//22;
    self.numberOfPoints        = [self.graphXData count];//35;
    NSArray *ax                = [self.graphXData copy];
    NSArray *ay                = [self.graphYData copy];
    
    NSMutableArray *pointPaths = [[NSMutableArray alloc] init];
    NSMutableArray *points     = [[NSMutableArray alloc] init];
    
    [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(goTime:) userInfo:nil repeats:YES];
    
    [self.color setFill];
    
    for (NSInteger i = 0; i < self.numberOfPointsToGraph; ++i) {
        // generate a point based on the data in the array
        CGPoint pa           = CGPointMake([ax[(self.plotStep+i)%self.numberOfPoints] floatValue], [ay[(self.plotStep+i)%self.numberOfPoints] floatValue]);
        CGPoint ra           = [self scalePoint:pa];
        CGRect oRect         = CGRectMake(ra.x,ra.y, 5, 5);
        UIBezierPath *pPoint = [UIBezierPath bezierPathWithOvalInRect:oRect];
        [pointPaths addObject:pPoint];
        [points addObject:[NSValue valueWithCGPoint:ra]];
    }
    // render the points
    /*
    for (NSInteger i = 0; i < self.numberOfPointsToGraph; ++i) {
        [[pointPaths objectAtIndex:i] fill];
    }
    */
    // connect the points being rendered
    [self connectAllPoints:points];
}

- (void) goTime: (NSTimer *) timer
{
    // 35 is the number of data points in the array of points
    self.plotStep = (self.plotStep + 1)%self.numberOfPoints;
    [timer invalidate];
    // redraw the screen
    [self setNeedsDisplay];
}

- (CGPoint) scalePoint: (CGPoint) data
{
    CGFloat offsetX   = -140;
    //CGFloat offsetX   = 15;
    CGFloat offsetY   = 15;
    CGFloat dataX     = data.x;
    CGFloat dataY     = data.y;
    CGFloat yheight   = self.bounds.size.height;
    CGFloat scaleX    = dataX*self.scaleX * 0.85;
    CGFloat scaleY    = dataY*self.scaleY * 0.75; //.75;
    CGFloat scaleOffY = offsetY*self.scaleY;
    CGFloat plotY     = yheight - scaleY - scaleOffY;
    CGFloat plotX     = scaleX + offsetX;
    
    return CGPointMake(plotX, plotY);
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    [self drawAxisX];
    [self drawAxisY];
    [self AnimatedPlacePoint];
    
}


@end
