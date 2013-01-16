//
//  GesturePrintingView.m
//  TouchTest
//
//  Created by Linda Morton on 10/11/12.
//  Copyright (c) 2012 William O'Neil. All rights reserved.
//

#import "GesturePrintingView.h"
#import "LineSegment.h"
#import "LineDrawingStrategy.h"
#import "BoxDrawingStrategy.h"
#import "TriangleDrawingStrategy.h"
#import "UIColor+Extensions.h"

@interface GesturePrintingView ()

@property (nonatomic, retain) DrawingStrategy* drawingStrategy;

- (void) initCacheContext;

- (void) queueTouchesForDrawing: (NSSet*) touches;

- (void) clearButtonPressed: (UIButton*) button;
- (void) linesButtonPressed: (UIButton*) button;
- (void) boxesButtonPressed: (UIButton*) button;
- (void) trianglesButtonPressed: (UIButton*) button;

@end

@implementation GesturePrintingView

@synthesize drawingStrategy;

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame: frame];
    if (self)
    {
        self.multipleTouchEnabled = YES;
        self.opaque = NO;
        self.clearsContextBeforeDrawing = NO;
        
        clearButton = [UIButton buttonWithType: UIButtonTypeRoundedRect];
        [clearButton setTitle: @"Clear" forState:UIControlStateNormal];
        [clearButton addTarget: self action: @selector(clearButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview: clearButton];
        
        linesButton = [UIButton buttonWithType: UIButtonTypeRoundedRect];
        [linesButton setTitle: @"Lines" forState: UIControlStateNormal];
        [linesButton addTarget:self action:@selector(linesButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        linesButton.titleLabel.backgroundColor = [UIColor buttonOnColor];
        [self addSubview: linesButton];
        
        boxesButton = [UIButton buttonWithType: UIButtonTypeRoundedRect];
        [boxesButton setTitle: @"Boxes" forState: UIControlStateNormal];
        [boxesButton addTarget:self action:@selector(boxesButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        boxesButton.titleLabel.backgroundColor = [UIColor buttonOffColor];
        [self addSubview: boxesButton];
        
        trianglesButton = [UIButton buttonWithType: UIButtonTypeRoundedRect];
        [trianglesButton setTitle: @"Triangles" forState: UIControlStateNormal];
        [trianglesButton addTarget:self action:@selector(trianglesButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        trianglesButton.titleLabel.backgroundColor = [UIColor buttonOffColor];
        [self addSubview: trianglesButton];
        
        [self initCacheContext];
        
        undrawnSegments = [[NSMutableArray alloc] initWithCapacity: 5];
        
        // default will be line drawing
        DrawingStrategy* strategy = [LineDrawingStrategy new];
        self.drawingStrategy = strategy;
        [strategy release];
    }
    return self;
}

- (void) initCacheContext
{
    float const width = self.frame.size.width;
    float const height = self.frame.size.height;
    int const bitsPerComponent = 8;
    int const bytesPerRow = width * 4; // Each pixel gets 1 byte (8 bits) per channel, where we have 4 channels (RGBA)
    CGColorSpaceRef const colorspace = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo const bitmapInfo = kCGImageAlphaNoneSkipFirst;
    
    cacheContext = CGBitmapContextCreate(NULL,
                                         width,
                                         height,
                                         bitsPerComponent,
                                         bytesPerRow,
                                         colorspace,
                                         bitmapInfo);
    
    CGColorSpaceRelease(colorspace);

    CGContextSetFillColorWithColor(cacheContext, [UIColor whiteColor].CGColor);
    CGContextFillRect(cacheContext, self.bounds);
}

- (void) dealloc
{
    CGContextRelease(cacheContext);
    
    [undrawnSegments release];
    [drawingStrategy release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark Drawing

- (void) drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGImageRef cacheImage = CGBitmapContextCreateImage(cacheContext);
    CGContextDrawImage(context, self.bounds, cacheImage);
    CGImageRelease(cacheImage);
}

- (void) updateCache
{
    [drawingStrategy drawSegments: undrawnSegments inContext: cacheContext];
    [self setNeedsDisplayInRect: drawingStrategy.lastUpdatedArea];
    
    [undrawnSegments removeAllObjects];
}

- (void) queueTouchesForDrawing: (NSSet*) touches
{
    LineSegment* newSegment;
    
    CGPoint prevLocation = CGPointZero;
    CGPoint currentLocation = CGPointZero;
    
    for (UITouch* touch in touches)
    {
        prevLocation = [touch previousLocationInView: self];
        currentLocation = [touch locationInView: self];
        
        newSegment = [LineSegment new];
        newSegment.start = prevLocation;
        newSegment.end = currentLocation;
        
        if (colorForTouch.find(touch) != colorForTouch.end())
        {
            newSegment.color = colorForTouch[touch];
        }
        else
        {
            colorForTouch[touch] = [UIColor randomColor];
            newSegment.color = colorForTouch[touch];
        }
        
        [undrawnSegments addObject: newSegment];
        [newSegment release];
    }
}

#pragma mark -
#pragma mark Layout

- (void) layoutSubviews
{
    float const buttonWidth = 75.0f;
    float const buttonHeight = 25.0f;
    
    float const buttonX = self.frame.size.width - buttonWidth - 1.0f;
    
    float const clearButtonY = self.frame.size.height - buttonHeight;
    float const trianglesButtonY = clearButtonY - buttonHeight - 50.0f;
    float const boxesButtonY = trianglesButtonY - buttonHeight - 6.0f;
    float const linesButtonY = boxesButtonY - buttonHeight - 6.0f;
    
    clearButton.frame = CGRectMake (buttonX,
                                    clearButtonY,
                                    buttonWidth,
                                    buttonHeight);
    
    trianglesButton.frame = CGRectMake(buttonX,
                                       trianglesButtonY,
                                       buttonWidth,
                                       buttonHeight);
    
    boxesButton.frame = CGRectMake (buttonX,
                                    boxesButtonY,
                                    buttonWidth,
                                    buttonHeight);
    
    linesButton.frame = CGRectMake (buttonX,
                                    linesButtonY,
                                    buttonWidth,
                                    buttonHeight);
}

#pragma mark -
#pragma mark UIResponder Overrides

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self queueTouchesForDrawing:touches];
    [self updateCache];
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self queueTouchesForDrawing:touches];
    [self updateCache];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch* touch in touches)
    {
        if (colorForTouch.find(touch) != colorForTouch.end())
            colorForTouch.erase(colorForTouch.find(touch));
    }
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch* touch in touches)
    {
        if (colorForTouch.find(touch) != colorForTouch.end())
            colorForTouch.erase(colorForTouch.find(touch));
    }
}

#pragma mark -
#pragma mark Button Callbacks

- (void) clearButtonPressed: (UIButton*) button
{
    CGContextSetFillColorWithColor(cacheContext, [UIColor whiteColor].CGColor);
    CGContextFillRect(cacheContext, self.bounds);
    
    [self setNeedsDisplay];
}

- (void) linesButtonPressed: (UIButton*) button
{
    linesButton.titleLabel.backgroundColor = [UIColor buttonOnColor];
    boxesButton.titleLabel.backgroundColor = [UIColor buttonOffColor];
    trianglesButton.titleLabel.backgroundColor = [UIColor buttonOffColor];
    
    self.drawingStrategy = [[LineDrawingStrategy new] autorelease];
}

- (void) boxesButtonPressed: (UIButton*) button
{
    boxesButton.titleLabel.backgroundColor = [UIColor buttonOnColor];
    linesButton.titleLabel.backgroundColor = [UIColor buttonOffColor];
    trianglesButton.titleLabel.backgroundColor = [UIColor buttonOffColor];
    
    self.drawingStrategy = [[BoxDrawingStrategy new] autorelease];
}

- (void) trianglesButtonPressed: (UIButton*) button
{
    trianglesButton.titleLabel.backgroundColor = [UIColor buttonOnColor];
    boxesButton.titleLabel.backgroundColor = [UIColor buttonOffColor];
    linesButton.titleLabel.backgroundColor = [UIColor buttonOffColor];
    
    self.drawingStrategy = [[TriangleDrawingStrategy new] autorelease];
}

@end
