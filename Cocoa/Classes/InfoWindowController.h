#import <Cocoa/Cocoa.h>

@class ResourceDocument, Resource;

extern NSString *DocumentInfoWillChangeNotification;
extern NSString *DocumentInfoDidChangeNotification;

@interface InfoWindowController : NSWindowController

- (void)updateInfoWindow;
- (void)setMainWindow:(NSWindow *)mainWindow;
- (IBAction)attributesChanged:(id)sender;
- (IBAction)nameDidChange:(id)sender;
- (void)resourceAttributesDidChange:(NSNotification *)notification;
- (void)documentInfoDidChange:(NSNotification *)notification;

+ (id)sharedInfoWindowController;

@end

@interface NSWindowController (InfoWindowAdditions)

/*!	@function	resource
	@discussion	Your plug-in should override this method to return the primary resource it's editing. Default implementation returns nil.
*/
- (Resource *)resource;

@end
