#import "PrefsWindowController.h"

@implementation PrefsWindowController

- (id)init
{
	return [self initWithWindowNibName:@"PrefsWindow"];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)awakeFromNib
{
	// represent current prefs in window state
	[self updatePrefs:nil];
	[[self window] center];
	
	// listen out for pref changes from elsewhere
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePrefs:) name:NSUserDefaultsDidChangeNotification object:nil];
}

- (void)updatePrefs:(NSNotification *)notification
{
	// load preferences�
	NSUserDefaults *defaults	= [NSUserDefaults standardUserDefaults];
	BOOL preserveBackups		= [defaults boolForKey:@"PreserveBackups"];
	BOOL autosave				= [defaults boolForKey:@"Autosave"];
	NSInteger autosaveInterval		= [defaults integerForKey:@"AutosaveInterval"];
	BOOL deleteResourceWarning	= [defaults boolForKey:@"DeleteResourceWarning"];
	BOOL createNewDocument		= [[defaults stringForKey:@"LaunchAction"] isEqualToString:@"OpenUntitledFile"];
	BOOL displayOpenPanel		= [[defaults stringForKey:@"LaunchAction"] isEqualToString:@"DisplayOpenPanel"];
	NSInteger launchAction			= createNewDocument? 1:(displayOpenPanel? 2:0);
	
	// �and set widgets accordingly
	[[dataProtectionMatrix cellAtRow:preserveBackupsBox column:0] setState:preserveBackups];
	[[dataProtectionMatrix cellAtRow:autosaveBox column:0] setState:autosave];
	[autosaveIntervalField setStringValue:[NSString stringWithFormat:@"%ld", autosaveInterval]];
	[[dataProtectionMatrix cellAtRow:deleteResourceWarningBox column:0] setState:deleteResourceWarning];
	[launchActionMatrix selectCellAtRow:launchAction column:0];
}

- (IBAction)acceptPrefs:(id)sender
{
	// bug: hey! where's NSValue's boolValue method? I have to use "intValue? YES:NO" :(
	NSUserDefaults *defaults	= [NSUserDefaults standardUserDefaults];
	BOOL preserveBackups		= [[dataProtectionMatrix cellAtRow:preserveBackupsBox column:0] intValue]? YES:NO;
	BOOL autosave				= [[dataProtectionMatrix cellAtRow:autosaveBox column:0] intValue]? YES:NO;
	int autosaveInterval		= [autosaveIntervalField intValue];
	BOOL deleteResourceWarning	= [[dataProtectionMatrix cellAtRow:deleteResourceWarningBox column:0] intValue]? YES:NO;
	BOOL createNewDocument		= ([launchActionMatrix selectedRow] == createNewDocumentBox)? YES:NO;
	BOOL displayOpenPanel		= ([launchActionMatrix selectedRow] == displayOpenPanelBox)? YES:NO;
	
	// hide the window
	[[self window] orderOut:nil];
	
	// now save the data to the defaults file
	[defaults setBool:preserveBackups forKey:@"PreserveBackups"];	// bug: this puts 1 or 0 into the defaults file rather than YES or NO
	[defaults setBool:autosave forKey:@"Autosave"];
	[defaults setInteger:autosaveInterval forKey:@"AutosaveInterval"];
	[defaults setBool:deleteResourceWarning forKey:@"DeleteResourceWarning"];
	if(createNewDocument)		[defaults setObject:@"OpenUntitledFile" forKey:@"LaunchAction"];
	else if(displayOpenPanel)	[defaults setObject:@"DisplayOpenPanel" forKey:@"LaunchAction"];
	else						[defaults setObject:@"None" forKey:@"LaunchAction"];
	[defaults synchronize];
}

- (IBAction)cancelPrefs:(id)sender
{
	// hide the window
	[[self window] orderOut:nil];
	
	// reset widgets to saved values
	[self updatePrefs:nil];
}

- (IBAction)resetToDefault:(id)sender
{
	// reset prefs window widgets to values stored in defaults.plist file
	NSDictionary *defaultsPlist	= [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"defaults" ofType:@"plist"]];
	BOOL preserveBackups		= [[defaultsPlist objectForKey:@"PreserveBackups"] intValue]? YES:NO;	// bug: this always evaluates to NO, even if the object in the dictionary is YES
	BOOL autosave				= [[defaultsPlist objectForKey:@"Autosave"] intValue]? YES:NO;
	int autosaveInterval		= [[defaultsPlist objectForKey:@"AutosaveInterval"] intValue];
	BOOL deleteResourceWarning	= [[defaultsPlist objectForKey:@"DeleteResourceWarning"] intValue]? YES:NO;
	BOOL createNewDocument		= [[defaultsPlist objectForKey:@"LaunchAction"] isEqualToString:@"OpenUntitledFile"];
	BOOL displayOpenPanel		= [[defaultsPlist objectForKey:@"LaunchAction"] isEqualToString:@"DisplayOpenPanel"];
	int launchAction			= createNewDocument? 1:(displayOpenPanel? 2:0);
	
	// note that this function does not modify the user defaults - the user still has to accept or cancel the panel
	[[dataProtectionMatrix cellAtRow:preserveBackupsBox column:0] setState:preserveBackups];
	[[dataProtectionMatrix cellAtRow:autosaveBox column:0] setState:autosave];
	[autosaveIntervalField setStringValue:[NSString stringWithFormat:@"%d", autosaveInterval]];
	[[dataProtectionMatrix cellAtRow:deleteResourceWarningBox column:0] setState:deleteResourceWarning];
	[launchActionMatrix selectCellAtRow:launchAction column:0];
}

+ (id)sharedPrefsWindowController
{
	static PrefsWindowController *sharedPrefsWindowController = nil;
	if( !sharedPrefsWindowController )
		sharedPrefsWindowController = [[PrefsWindowController alloc] init];
	return sharedPrefsWindowController;
}

@end
