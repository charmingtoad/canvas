//
//  DrawingView.m
//  Canvas
//
//  Created by Linda Morton on 10/11/12.
//  Copyright (c) 2012 Linda Morton. All rights reserved.
//

#import "CVSDrawingView.h"
#import "CVSLineSegment.h"
#import "CVSLineDrawingStrategy.h"
#import "CVSBoxDrawingStrategy.h"
#import "CVSTriangleDrawingStrategy.h"
#import "UIColor+CVSExtensions.h"

@interface CVSDrawingView ()

@property (nonatomic, strong) NSMutableDictionary *colorForTouch;

@property (nonatomic, assign) CGContextRef cacheContext;

@property (nonatomic, strong) NSMutableArray* undrawnSegments;

/** Creates the bitmap context where off-screen drawing will occur. Whenever this
    view refreshes, the cacheContext will be rendered on-screen in drawRect.
 */
- (void) initCacheContext;

/** Converts touches into LineSegments and adds them to the undrawnSegments array. */
- (void) queueTouchesForDrawing: (NSSet*) touches;

/** Draws undrawnSegments using the cacheContext. */
- (void) updateCache;

@end

@implementation CVSDrawingView

@synthesize drawingStrategy;

#pragma mark - Init / Dealloc

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame: frame];
    if (self)
    {
        self.multipleTouchEnabled = YES;
        self.opaque = NO;
        self.clearsContextBeforeDrawing = NO;

        [self initCacheContext];
        
        self.colorForTouch = [[NSMutableDictionary alloc] init];
        self.undrawnSegments = [[NSMutableArray alloc] initWithCapacity: 5];
        
        // default will be line drawing
        CVSDrawingStrategy* strategy = [CVSLineDrawingStrategy new];
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

#pragma mark - Drawing

- (void) drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGImageRef cacheImage = CGBitmapContextCreateImage(self.cacheContext);
    CGContextDrawImage(context, self.bounds, cacheImage);
    CGImageRelease(cacheImage);
}

- (void) updateCache
{
    [drawingStrategy drawSegments: self.undrawnSegments inContext: self.cacheContext];
    [self setNeedsDisplayInRect: drawingStrategy.lastUpdatedArea];
    
    [self.undrawnSegments removeAllObjects];
}

- (void) queueTouchesForDrawing: (NSSet*) touches
{
    CVSLineSegment* newSegment;
    
    CGPoint prevLocation = CGPointZero;
    CGPoint currentLocation = CGPointZero;
    
    for (UITouch* touch in touches)
    {
        prevLocation = [touch previousLocationInView: self];
        currentLocation = [touch locationInView: self];
        
        newSegment = [CVSLineSegment new];
        newSegment.start = prevLocation;
        newSegment.end = currentLocation;
        
        NSValue *touchKey = [self keyForObject:touch];
        if ([[self.colorForTouch allKeys] containsObject:touchKey])
        {
            newSegment.color = self.colorForTouch[touchKey];
        }
        else
        {
            UIColor *newColor = [UIColor cvs_randomColor];
            self.colorForTouch[touchKey] = newColor;
            newSegment.color = newColor;
        }
        [self.undrawnSegments addObject: newSegment];
    }
}

- (void)clear
{
    CGContextSetFillColorWithColor(self.cacheContext, [UIColor whiteColor].CGColor);
    CGContextFillRect(self.cacheContext, self.bounds);
    
    [self setNeedsDisplay];
}

#pragma mark - Mapping touches to colors

- (NSValue *)keyForObject:(id)object
{
    return [NSValue valueWithPointer:(__bridge const void *)(object)];
}

#pragma mark - UIResponder Overrides

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

@end
