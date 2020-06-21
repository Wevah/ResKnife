//
//  CICNWindowController.h
//  ResKnife
//
//  Created by Nate Weaver on 2016-07-18.
//
//

#import <Cocoa/Cocoa.h>
#import "ResKnifePluginProtocol.h"
#import "ResKnifeResourceProtocol.h"



@interface CICNWindowController : NSWindowController <ResKnifePluginProtocol>

@property (assign) IBOutlet NSImageView *imageView;
@property (strong) id <ResKnifeResourceProtocol>	resource;
@property (strong) NSImage *image;

@end
