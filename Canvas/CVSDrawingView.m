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
        self.drawingStrategy = [CVSLineDrawingStrategy new];
    }
    return self;
}

- (void) initCacheContext
{
    float const width = CGRectGetWidth(self.frame) * [UIScreen mainScreen].scale;
    float const height = CGRectGetHeight(self.frame) * [UIScreen mainScreen].scale;
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
    CGContextFillRect(self.cacheContext, CGRectMake(0.0f, 0.0f, width, height));
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
    [self.drawingStrategy drawSegments: self.undrawnSegments inContext: self.cacheContext];
    
    CGRect lastUpdatedArea = self.drawingStrategy.lastUpdatedArea;
    lastUpdatedArea = CGRectMake (CGRectGetMinX(lastUpdatedArea) / [UIScreen mainScreen].scale,
                                  CGRectGetMinY(lastUpdatedArea) / [UIScreen mainScreen].scale,
                                  CGRectGetWidth(lastUpdatedArea) / [UIScreen mainScreen].scale,
                                  CGRectGetHeight(lastUpdatedArea) / [UIScreen mainScreen].scale);
    [self setNeedsDisplayInRect: lastUpdatedArea];
    
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
        prevLocation = CGPointMake(prevLocation.x * [UIScreen mainScreen].scale, prevLocation.y * [UIScreen mainScreen].scale);
        
        currentLocation = [touch locationInView: self];
        currentLocation = CGPointMake(currentLocation.x * [UIScreen mainScreen].scale, currentLocation.y * [UIScreen mainScreen].scale);
        
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

- (void)clearCanvasAnimated:(BOOL)animated
{
    void (^clearBlock)() = ^
    {
        CGContextSetFillColorWithColor(self.cacheContext, [UIColor whiteColor].CGColor);
        CGRect scaledBounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.bounds) * [UIScreen mainScreen].scale, CGRectGetHeight(self.bounds) * [UIScreen mainScreen].scale);
        CGContextFillRect(self.cacheContext, scaledBounds);
        
        [self setNeedsDisplay];
    };
    if (animated)
    {
        [UIView transitionWithView:self
                          duration:0.4f
                           options:UIViewAnimationOptionTransitionCurlUp
                        animations:^
         {
             clearBlock();
         }
                        completion:nil];
    }
    else
    {
        clearBlock();
    }
}

#pragma mark - Mapping touches to colors

- (NSValue *)keyForObject:(id)object
{
    return [NSValue valueWithPointer:(__bridge const void *)(object)];
}

#pragma mark - Getting the Drawing

- (UIImage *)image
{
    CGImageRef cacheImage = CGBitmapContextCreateImage(self.cacheContext);
    UIImage *upsideDownImage = [UIImage imageWithCGImage:cacheImage];
    UIImage *rightSideUpImage = [UIImage imageWithCGImage:upsideDownImage.CGImage
                                                    scale:upsideDownImage.scale
                                              orientation:UIImageOrientationDownMirrored];
    return rightSideUpImage;
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
