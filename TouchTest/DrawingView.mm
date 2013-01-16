//
//  DrawingView.m
//  TouchTest
//
//  Created by Linda Morton on 10/11/12.
//  Copyright (c) 2012 William O'Neil. All rights reserved.
//

#import "DrawingView.h"
#import "LineSegment.h"
#import "LineDrawingStrategy.h"
#import "BoxDrawingStrategy.h"
#import "TriangleDrawingStrategy.h"
#import "UIColor+Extensions.h"

@interface DrawingView ()

/** The strategy used to draw touches detected on this view. */
@property (nonatomic, retain) DrawingStrategy* drawingStrategy;

/** Creates the bitmap context where off-screen drawing will occur. Whenever this
    view refreshes, the cacheContext will be rendered on-screen in drawRect.
 */
- (void) initCacheContext;

/** Converts touches into LineSegments and adds them to the undrawnSegments array. */
- (void) queueTouchesForDrawing: (NSSet*) touches;

/** Draws undrawnSegments using the cacheContext. */
- (void) updateCache;

/** Button callbacks */
- (void) clearButtonPressed: (UIButton*) button;
- (void) drawingStrategySelected: (id) sender;

@end

@implementation DrawingView

@synthesize drawingStrategy;

#pragma mark -
#pragma mark Init / Dealloc

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame: frame];
    if (self)
    {
        self.multipleTouchEnabled = YES;
        self.opaque = NO;
        self.clearsContextBeforeDrawing = NO;
        
        NSArray* segments = [NSArray arrayWithObjects:
                             @"Lines",
                             @"Boxes",
                             @"Trianges", nil];
        
        drawingStrategySelectionControl = [[UISegmentedControl alloc] initWithItems: segments];
        
        [drawingStrategySelectionControl addTarget: self
                                            action: @selector(drawingStrategySelected:)
                                  forControlEvents:UIControlEventValueChanged];
        
        [self addSubview: drawingStrategySelectionControl];
        [drawingStrategySelectionControl release];
        
        clearButton = [UIButton buttonWithType: UIButtonTypeRoundedRect];
        [clearButton setTitle: @"Clear" forState:UIControlStateNormal];
        [clearButton addTarget: self action: @selector(clearButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview: clearButton];
        
        [self initCacheContext];
        
        undrawnSegments = [[NSMutableArray alloc] initWithCapacity: 5];
        
        // default will be line drawing
        [drawingStrategySelectionControl setSelectedSegmentIndex: 0];
        
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
    float buttonHeight = 50.0f;
    
    clearButton.frame = CGRectMake (0.0f,
                                    self.frame.size.height - buttonHeight,
                                    self.frame.size.width,
                                    buttonHeight);
    
    drawingStrategySelectionControl.frame = CGRectMake (0.0f,
                                                        self.frame.size.height - (2 * buttonHeight),
                                                        self.frame.size.width,
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

- (void) drawingStrategySelected: (id) sender
{
    int selectedIndex = [sender selectedSegmentIndex];
    
    if (selectedIndex == 2)
    {
        self.drawingStrategy = [[TriangleDrawingStrategy new] autorelease];
    }
    else if (selectedIndex == 1)
    {
        self.drawingStrategy = [[BoxDrawingStrategy new] autorelease];
    }
    else
    {
        self.drawingStrategy = [[LineDrawingStrategy new] autorelease];
    }
}

- (void) clearButtonPressed: (UIButton*) button
{
    CGContextSetFillColorWithColor(cacheContext, [UIColor whiteColor].CGColor);
    CGContextFillRect(cacheContext, self.bounds);
    
    [self setNeedsDisplay];
}

@end
