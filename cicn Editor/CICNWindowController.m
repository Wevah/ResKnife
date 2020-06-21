//
//  CICNWindowController.m
//  ResKnife
//
//  Created by Nate Weaver on 2016-07-18.
//
//

#import "CICNWindowController.h"

@interface CICNWindowController ()

@end

@implementation CICNWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (id)initWithResource:(id <ResKnifeResourceProtocol>)inResource {
	if (self = [self initWithWindowNibName:@"PNGWindowController"]) {
		_resource = inResource;
		[self window];
	}

	return self;
}

- (NSImage *)imageWithCicnData:(NSData *)data {
	NSData *maskData =
}

@end
