#include "TemplateInitalisation.h"
#include "TemplateWindow.h"
globals g;

/*** INITALISE NEW EDITOR INSTANCE ***/
OSStatus Plug_InitInstance( Plug_PlugInRef plug, Plug_ResourceRef resource )
{
	// get system version
	OSStatus error = Gestalt( gestaltSystemVersion, &g.systemVersion );
	if( error ) return error;
	
	// check appearance availablilty
#if TARGET_API_MAC_CARBON
	g.useAppearance = true;
#else
	ProcessSerialNumber psn;
	error = GetCurrentProcess( &psn );
	if( error ) g.useAppearance = false;
	else g.useAppearance = IsAppearanceClient( &psn );
#endif
	
	// get template for resource
	ResType type = Host_GetResourceType( resource );
	Handle tmpl = Host_GetDefaultTemplate( type );
	SInt32 size = GetHandleSize( tmpl );				// cannot be less than 5 (string length of zero, four char code)
	if( tmpl == null || size < 5 ) return paramErr;		// not the best error to return for this situation
	
	// create window
	Rect creationBounds;
	WindowRef window;
	SetRect( &creationBounds, 0, 0, kDefaultWindowWidth, kDefaultWindowHeight );
	OffsetRect( &creationBounds, 8, 48 );
	WindowAttributes attributes = kWindowStandardDocumentAttributes | kWindowStandardHandlerAttribute | kWindowInWindowMenuAttribute;
	if( g.systemVersion >= kMacOSX )	attributes |= kWindowLiveResizeAttribute;
	error = CreateNewWindow( kDocumentWindowClass, attributes, &creationBounds, &window );
	Plug_WindowRef plugWindow = Host_RegisterWindow( plug, resource, window );
	
#if TARGET_API_MAC_CARBON
	// install window event handler
	EventHandlerRef	ref			= null;
	EventHandlerUPP	handler		= NewEventHandlerUPP( CarbonWindowEventHandler );
	EventTypeSpec	events[]	= {	{ kEventClassWindow, kEventWindowClose } };
	InstallWindowEventHandler( window, handler, GetEventTypeCount(events), events, plug, &ref );
#else
	ClassicEventHandlerUPP handler = NewClassicEventHandlerUPP( ClassicWindowEventHandler );
	Host_InstallClassicWindowEventHandler( plugWindow, handler );
#endif
	
	// set window's background to default for theme
	if( g.useAppearance )
		SetThemeWindowBackground( window, kThemeBrushModelessDialogBackgroundActive, false );
	
	// cerate new template window class
	TemplateWindowPtr templateWindow = new TemplateWindow( window );
	Host_SetWindowRefCon( plugWindow, (UInt32) templateWindow );
	
	// parse the resource data
	Handle data = Host_GetResourceData( resource );
	error = templateWindow->UseTemplate( tmpl );	// pass responsibility for disposing to the window
	error = templateWindow->ParseData( data );		// parses the resource into an array of Elements
	
	// show window
	ShowWindow( window );
	SelectWindow( window );
	return error;
}

/*** ELEMENT CONSTRUCTOR ***/
Element::Element( void )
{
	BlockZero( this, sizeof(Element) );
}

/*** CARBON WINDOW EVENT HANDLER ***/
pascal OSStatus CarbonWindowEventHandler( EventHandlerCallRef handler, EventRef event, void *userData )
{
	#pragma unused( handler )
	OSStatus		error = eventNotHandledErr;
	Plug_PlugInRef	plugRef = (Plug_PlugInRef) userData;
	WindowRef		window = GetUserFocusWindow();	// overridden below for window class events
	
	// get event type
	UInt32 eventClass = GetEventClass( event );
	UInt32 eventKind = GetEventKind( event );
	
	// get event parameters
	if( eventClass == kEventClassWindow )
		GetEventParameter( event, kEventParamDirectObject, typeWindowRef, null, sizeof(WindowRef), null, &window );
	if( !window ) return error;
	Plug_WindowRef plugWindow = Host_GetPlugWindowFromWindowRef( window );
	if( !plugWindow ) return error;
	TemplateWindowPtr templateWindow = (TemplateWindowPtr) Host_GetWindowRefCon( plugWindow );
	if( !templateWindow ) return error;
	
	// get window rect
	Rect windowBounds;
	GetWindowPortBounds( window, &windowBounds );
	
	// handle event
	static EventHandlerRef resizeEventHandlerRef = null;
	switch( eventClass )
	{
		case kEventClassWindow:
			switch( eventKind )
			{
				case kEventWindowClose:
					delete templateWindow;
					break;
			}
			break;
	}
	return error;
}