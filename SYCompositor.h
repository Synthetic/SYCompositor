//
//  SYCompositor.h
//  SYCompositor
//
//  Created by Sam Soffes on 9/15/11.
//  Copyright (c) 2011-2012 Synthetic. All rights reserved.
//

#import <Foundation/Foundation.h>

// Blending mode
extern NSString *const kSYCompositorModeKey;

// Rect - only draw in part of the frame
extern NSString *const kSYCompositorRectKey;

// Draw an image
extern NSString *const kSYCompositorImageKey;
extern NSString *const kSYCompositorImageNameKey;
extern NSString *const kSYCompositorImagePathKey;

// Draw a color
extern NSString *const kSYCompositorColorKey;
extern NSString *const kSYCompositorColorHexKey;

// Set the alpha of what is drawn
extern NSString *const kSYCompositorAlphaKey;

// Masking
extern NSString *const kSYCompositorMaskImageKey;
extern NSString *const kSYCompositorMaskImageNameKey;
extern NSString *const kSYCompositorMaskImagePathKey;
extern NSString *const kSYCompositorPersistentMaskKey;

// Draw a gradient
extern NSString *const kSYCompositorGradientKey; // `radial` or `linear`
extern NSString *const kSYCompositorGradientColorsKey;
extern NSString *const kSYCompositorGradientColorsHexesKey;

@class SYCache;
@class UIImage;

@interface SYCompositor : NSObject

+ (UIImage *)imageWithKey:(NSString *)key;
+ (UIImage *)imageWithLayers:(NSArray *)layers size:(CGSize)size key:(NSString *)key;
+ (NSString *)pathForImageWithKey:(NSString *)key;

+ (SYCache *)cache;

@end
