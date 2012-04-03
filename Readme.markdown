# SYCompositor

Easy, flexible drawing in Objective-C. Sometimes dynamically generating Core Graphics drawing code can be a real pain. SYCompositor makes it really simple to do in Objective-C. Simply provide `NSDictionary`'s for each layer. SYCompositor handles everything else. Drawing, caching, you name it.

## Example

``` objective-c
// Build your cache key to be unique per your layer confiruation
NSString *cacheKey = @"some-key";

// Get the image from SYCompositor
UIImage *image = [SYCompositor imageWithKey:cacheKey];

// If the image is `nil`, you should build it
if (image == nil) {
	// Create your layers. See `SYCompositor.h` for a full list of available keys
	NSArray *layers = [[NSArray alloc] initWithObjects:
					   // Lens
					   [NSDictionary dictionaryWithObjectsAndKeys:
						@"lens.png", kSYCompositorImageNameKey,
						[NSValue valueWithCGRect:CGRectMake(88.0f, 275.0f, 138.0f, 138.0f)], kSYCompositorRectKey,
						nil],

					   // Body layer
					   [NSDictionary dictionaryWithObjectsAndKeys:
						@"camera-body.png", kSYCompositorMaskImageNameKey,
						bodyColor, kSYCompositorColorKey,
						nil],

					   // Shadows layer
					   [NSDictionary dictionaryWithObjectsAndKeys:
						@"camera-shadows.png", kSYCompositorImageNameKey,
						@"Multiply", kSYCompositorModeKey,
						nil],
					   nil];

	// Create the image. This will store it in the cache automatically.
	image = [SYCompositor imageWithLayers:layers size:[[UIScreen mainScreen] bounds].size key:cacheKey];
}

// Now `image` is ready to go!
someImageView.image = image;
```

## Adding to Your Project

Be sure to initialize the [SYCache](https://github.com/Synthetic/SYCache) submodule:

	$ cd whereverYouClonedSYCompositor
	$ git submodule update --init

Then add `SYCompostor.h`, `SYCompositor.h`, `SYCache/SYCache.h`, and `SYCache/SYCache.m` to your project.


### ARC

If you are including SYCompositor in a project that uses [Automatic Reference Counting (ARC)](http://clang.llvm.org/docs/AutomaticReferenceCounting.html) enabled, you will need to set the `-fno-objc-arc` compiler flag on all of the SYCompositor and SYCache source files. To do this in Xcode, go to your active target and select the "Build Phases" tab. In the "Compiler Flags" column, set `-fno-objc-arc` for each of the SYCompositor and SYCache source files.
