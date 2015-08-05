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

@property (nonatomic, strong) NSMutableDictionary *colorForTouch;

@property (nonatomic, assign) CGContextRef cacheContext;

/** The strategy used to draw touches detected on this view. */
@property (nonatomic, strong) DrawingStrategy* drawingStrategy;

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
        
        clearButton = [UIButton buttonWithType: UIButtonTypeRoundedRect];
        [clearButton setTitle: @"Clear" forState:UIControlStateNormal];
        [clearButton addTarget: self action: @selector(clearButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview: clearButton];
        
        [self initCacheContext];
        
        self.colorForTouch = [[NSMutableDictionary alloc] init];
        
        undrawnSegments = [[NSMutableArray alloc] initWithCapacity: 5];
        
        // default will be line drawing
        [drawingStrategySelectionControl setSelectedSegmentIndex: 0];
        
        DrawingStrategy* strategy = [LineDrawingStrategy new];
        self.drawingStrategy = strategy;
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
    CGBitmapInfo const bitmapInfo = (CGBitmapInfo)kCGImageAlphaNoneSkipFirst; // Cast to suppress warning. SO says this is normal: http://stackoverflow.com/questions/18921703/implicit-conversion-from-enumeration-type-enum-cgimagealphainfo-to-different-e
    
    self.cacheContext = CGBitmapContextCreate(NULL,
                                              width,
                                              height,
                                              bitsPerComponent,
                                              bytesPerRow,
                                              colorspace,
                                              bitmapInfo);
    
    CGColorSpaceRelease(colorspace);

    CGContextSetFillColorWithColor(self.cacheContext, [UIColor whiteColor].CGColor);
    CGContextFillRect(self.cacheContext, self.bounds);
}

- (void) dealloc
{
    CGContextRelease(self.cacheContext);
}

#pragma mark -
#pragma mark Drawing

- (void) drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGImageRef cacheImage = CGBitmapContextCreateImage(self.cacheContext);
    CGContextDrawImage(context, self.bounds, cacheImage);
    CGImageRelease(cacheImage);
}

- (void) updateCache
{
    [drawingStrategy drawSegments: undrawnSegments inContext: self.cacheContext];
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
        
        NSValue *touchKey = [self keyForObject:touch];
        NSLog(@"touch key = %@", touchKey);
        if ([[self.colorForTouch allKeys] containsObject:touchKey])
        {
            newSegment.color = self.colorForTouch[touchKey];
        }
        else
        {
            UIColor *newColor = [UIColor randomColor];
            self.colorForTouch[touchKey] = newColor;
            newSegment.color = newColor;
        }
        [undrawnSegments addObject: newSegment];
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
        NSValue *touchKey = [self keyForObject:touch];
        if ([[self.colorForTouch allKeys] containsObject:touchKey])
        {
            [self.colorForTouch removeObjectForKey:touchKey];
        }
    }
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch* touch in touches)
    {
        NSValue *touchKey = [self keyForObject:touch];
        if ([[self.colorForTouch allKeys] containsObject:touchKey])
        {
            [self.colorForTouch removeObjectForKey:touchKey];
        }
    }
}

- (NSValue *)keyForObject:(id)object
{
    return [NSValue valueWithPointer:(__bridge const void *)(object)];
}

#pragma mark -
#pragma mark Button Callbacks

- (void) drawingStrategySelected: (id) sender
{
    NSInteger selectedIndex = [sender selectedSegmentIndex];
    
    if (selectedIndex == 2)
    {
        self.drawingStrategy = [TriangleDrawingStrategy new];
    }
    else if (selectedIndex == 1)
    {
        self.drawingStrategy = [BoxDrawingStrategy new];
    }
    else
    {
        self.drawingStrategy = [LineDrawingStrategy new];
    }
}

- (void) clearButtonPressed: (UIButton*) button
{
    CGContextSetFillColorWithColor(self.cacheContext, [UIColor whiteColor].CGColor);
    CGContextFillRect(self.cacheContext, self.bounds);
    
    [self setNeedsDisplay];
}

@end
