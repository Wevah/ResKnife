#import "NSString-FSSpec.h"

@implementation NSString (NGSFSSpec)

- (FSRef *)createFSRef
{
	// caller is responsible for disposing of the FSRef (method is a 'create' method)
	FSRef *fsRef = (FSRef *) malloc(sizeof(FSRef));
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
	OSStatus error = FSPathMakeRef((unsigned char *)[self fileSystemRepresentation], fsRef, NULL);
#pragma clang diagnostic pop
	if(error == noErr)
		return fsRef;

	free(fsRef);
	return NULL;
}

- (FSSpec *)createFSSpec
{
	// caller is responsible for disposing of the FSSpec (method is a 'create' method)
	FSRef fsRef;
	FSSpec *fsSpec = (FSSpec *) malloc(sizeof(FSSpec));
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
	OSStatus error = FSPathMakeRef((unsigned char *)[self fileSystemRepresentation], &fsRef, NULL);
#pragma clang diagnostic pop
	if(error == noErr)
	{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
		error = FSGetCatalogInfo(&fsRef, kFSCatInfoNone, NULL, NULL, fsSpec, NULL);
#pragma clang diagnostic pop
		if(error == noErr)
		{
			return fsSpec;
		}
	}

	free(fsSpec);
	return NULL;
}

@end

@implementation NSString (NGSBoolean)

- (BOOL)boolValue
{
	return ![self isEqualToString:@"NO"];
//	return [self isEqualToString:@"YES"];
}

+ (NSString *)stringWithBool:(BOOL)boolean
{
	return boolean? @"YES" : @"NO";
}

@end
