#import "PasteboardWindowController.h"

@implementation PasteboardWindowController

- (id)init
{
	self = [self initWithWindowNibName:@"ResourceDocument"];
	if( self ) [self setWindowFrameAutosaveName:@"PasteboardWindow"];
	return self;
}

+ (id)sharedPasteboardWindowController
{
	static PasteboardWindowController *sharedPasteboardWindowController = nil;
	if( !sharedPasteboardWindowController )
	{
		sharedPasteboardWindowController = [[PasteboardWindowController alloc] init];
	}
	return sharedPasteboardWindowController;
}

@end
