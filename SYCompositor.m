//
//  SYCompositor.m
//  SYCompositor
//
//  Created by Sam Soffes on 9/15/11.
//  Copyright (c) 2011 Synthetic. All rights reserved.
//

#import "SYCompositor.h"
#import <SSToolkit/NSArray+SSToolkitAdditions.h>
#import <SSToolkit/UIColor+SSToolkitAdditions.h>
#import <HipstaProcessor/HPUtilities.h>

NSString *const kSYCompositorModeKey = @"mode";
NSString *const kSYCompositorRectKey = @"rect";
NSString *const kSYCompositorImageKey = @"image";
NSString *const kSYCompositorImageNameKey = @"imageName";
NSString *const kSYCompositorImagePathKey = @"imagePath";
NSString *const kSYCompositorColorKey = @"color";
NSString *const kSYCompositorColorHexKey = @"colorHex";
NSString *const kSYCompositorAlphaKey = @"alpha";
NSString *const kSYCompositorMaskImageKey = @"maskImage";
NSString *const kSYCompositorMaskImageNameKey = @"maskImageName";
NSString *const kSYCompositorMaskImagePathKey = @"maskImagePath";
NSString *const kSYCompositorPersistentMaskKey = @"persistentMask";
NSString *const kSYCompositorGradientKey = @"gradient";
NSString *const kSYCompositorGradientColorsKey = @"gradientColors";
NSString *const kSYCompositorGradientColorsHexesKey = @"gradientColorsHexes";

@interface SYCompositor ()
+ (UIImage *)_drawWithLayers:(NSArray *)layers size:(CGSize)size;
+ (NSString *)_cachesDirectory;
@end

@implementation SYCompositor

+ (UIImage *)imageWithCacheName:(NSString *)cacheName {
	NSString *cachePath = [self pathForImageWithCacheName:cacheName];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSData *data = [fileManager contentsAtPath:cachePath];
	return [UIImage imageWithData:data];
}


+ (UIImage *)imageWithLayers:(NSArray *)layers size:(CGSize)size cacheName:(NSString *)cacheName {
	UIImage *image = [self imageWithCacheName:cacheName];

	// If no image on disk, draw it
	if (!image) {
		image = [self _drawWithLayers:layers size:size];
		
		// If an image was rendered, save it to disk
		if (image) {
			NSData *data = UIImagePNGRepresentation(image);
			
			// Create caches directory if necessary
			NSFileManager *fileManager = [NSFileManager defaultManager];
			NSString *cachePath = [self pathForImageWithCacheName:cacheName];
			NSString *cachesDirectory = [self _cachesDirectory];
			if (![fileManager fileExistsAtPath:cachesDirectory]) {
				NSError *error = nil;
				[fileManager createDirectoryAtPath:cachesDirectory withIntermediateDirectories:YES attributes:nil error:&error];
			}
			
			// Save image
			[fileManager createFileAtPath:cachePath contents:data attributes:nil];
		}
	}
	
	return image;
}


+ (NSString *)pathForImageWithCacheName:(NSString *)cacheName {
	return [[self _cachesDirectory] stringByAppendingPathComponent:cacheName];
}


+ (NSString *)_cachesDirectory {
	NSString *cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
	return [cachesDirectory stringByAppendingPathComponent:@"SYCompositor"];
}


+ (UIImage *)_drawWithLayers:(NSArray *)layers size:(CGSize)size {
	if (!layers) {
		return nil;
	}
	
	CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
	UIGraphicsBeginImageContext(size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	// Transform coordinates
	CGContextTranslateCTM(context, 0.0f, size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
	
	// Loop through blending layers
	for (NSDictionary *dictionary in layers) {
		
		if ([[dictionary objectForKey:kSYCompositorPersistentMaskKey] boolValue] == NO) {
			CGContextSaveGState(context);
		}
		
		// Blend mode
		NSString *modeString = [dictionary objectForKey:kSYCompositorModeKey];
		CGBlendMode blendMode = modeString ? CGBlendModeWithString(modeString) : kCGBlendModeNormal;
		CGContextSetBlendMode(context, blendMode);
		
		// Alpha
		NSNumber *alphaNumber = [dictionary objectForKey:kSYCompositorAlphaKey];
		CGFloat alpha = alphaNumber ? [alphaNumber floatValue] : 1.0f;
		CGContextSetAlpha(context, alpha);
		
		// Rect
		NSValue *rectValue = [dictionary objectForKey:kSYCompositorRectKey];
		CGRect frame = rectValue ? [rectValue CGRectValue] : rect;
		frame = CGRectMake(frame.origin.x, (size.height - frame.size.height) - frame.origin.y,
						   frame.size.width, frame.size.height);
		
		// Mask
		UIImage *maskImage = nil;
		NSString *maskImageName = [dictionary objectForKey:kSYCompositorMaskImageNameKey];
		if (maskImageName) {
			maskImage = [UIImage imageNamed:maskImageName];
		} else {
			NSString *maskImagePath = [dictionary objectForKey:kSYCompositorMaskImagePathKey];
			if (maskImagePath) {
				maskImage = [UIImage imageWithContentsOfFile:maskImagePath];
			}
		}
		
		if (maskImage) {
			CGContextClipToMask(context, frame, maskImage.CGImage);
		}
		
		// Draw color
		UIColor *color = [dictionary objectForKey:kSYCompositorColorKey];
		if (!color) {
			NSString *colorString = [dictionary objectForKey:kSYCompositorColorHexKey];
			if (colorString) {
				color = [UIColor colorWithHex:colorString];
			}
		}
		
		if (color) {
			CGContextSetFillColorWithColor(context, color.CGColor);
			CGContextFillRect(context, frame);
		}
		
		// Draw image
		UIImage *image = [dictionary objectForKey:kSYCompositorImageKey];
		if (!image) {
			NSString *imageName = [dictionary objectForKey:kSYCompositorImageNameKey];
			if (imageName) {
				image = [UIImage imageNamed:imageName];
			} else {
				NSString *imagePath = [dictionary objectForKey:kSYCompositorImagePathKey];
				if (imagePath) {
					image = [UIImage imageWithContentsOfFile:imagePath];
				}
			}
		}
		
		if (image) {
			CGContextDrawImage(context, frame, image.CGImage);
		}
		
		// Draw gradient
		NSString *gradientType = [dictionary objectForKey:kSYCompositorGradientKey];
		if (gradientType) {
			NSArray  *colorStrings = [dictionary objectForKey:kSYCompositorGradientColorsKey];
			NSMutableArray *colors = [[NSMutableArray alloc] initWithCapacity:[colorStrings count]];
			for (NSString *hex in colorStrings) {
				[colors addObject:[UIColor colorWithHex:hex]];
			}
			CGGradientRef gradient = SSCreateGradientWithColors(colors);
			[colors release];
			
			// Radial
			if ([gradientType isEqualToString:@"radial"]) {
				CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
				CGPoint endPoint = startPoint;
				CGFloat startRadius = rect.size.width;
				CGFloat endRadius = 0.0f;
				CGContextDrawRadialGradient(context, gradient, startPoint, startRadius, endPoint, endRadius, 0);
			}
			
			// Linear
			else {
				CGPoint startPoint = CGPointMake(0.0f, 0.0f);
				CGPoint endPoint = CGPointMake(0.0f, rect.size.height);
				CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
			}
			
			CGGradientRelease(gradient);
		}
		
		// Restore state
		if ([[dictionary objectForKey:kSYCompositorPersistentMaskKey] boolValue] == NO) {
			CGContextRestoreGState(context);
		}
	}
	
	UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return outputImage;
}

@end
