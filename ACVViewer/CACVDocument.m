//
//  CDocument.m
//  ACVViewer
//
//  Created by Jonathan Wight on 3/20/12.
//  Copyright (c) 2012 toxicsoftware.com. All rights reserved.
//

#import "CACVDocument.h"

#import "CACVObject.h"
#import "CACVCurvesView.h"
#import "NSImage+CGImage.h"
#import "CColorCurve.h"

@interface CACVDocument ()
@property (readwrite, nonatomic, assign) IBOutlet CACVCurvesView *curvesView;
@property (readwrite, nonatomic, assign) IBOutlet NSImageView *RGBLUTImageView;
@property (readwrite, nonatomic, assign) IBOutlet NSImageView *redLUTImageView;
@property (readwrite, nonatomic, assign) IBOutlet NSImageView *greenLUTImageView;
@property (readwrite, nonatomic, assign) IBOutlet NSImageView *blueLUTImageView;
@end

@implementation CACVDocument

- (NSString *)windowNibName
	{
	return @"CACVDocument";
	}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
	{
	[super windowControllerDidLoadNib:aController];
	
	self.curvesView.ACVObject = self.ACVObject;
	
	self.RGBLUTImageView.image = [NSImage imageWithCGImage:self.ACVObject.RGBCurve.CGImage];
	self.redLUTImageView.image = [NSImage imageWithCGImage:self.ACVObject.redCurve.CGImage];
	self.greenLUTImageView.image = [NSImage imageWithCGImage:self.ACVObject.greenCurve.CGImage];
	self.blueLUTImageView.image = [NSImage imageWithCGImage:self.ACVObject.blueCurve.CGImage];
	}

- (BOOL)readFromURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError **)outError;
	{
	self.ACVObject = [[CACVObject alloc] initWithURL:url];
	return(YES);
	}

- (IBAction)export:(id)sender
	{
	NSSavePanel *thePanel = [NSSavePanel savePanel];
	
	[thePanel beginSheetModalForWindow:[[self.windowControllers lastObject] window] completionHandler:^(NSInteger result) {
		if (result == NSOKButton)
			{
			[NSKeyedArchiver archiveRootObject:self.ACVObject toFile:thePanel.URL.path];
			}
		}];
	}

@end
