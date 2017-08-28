#import <Foundation/Foundation.h>

@class	Element, ElementOCNT;
@interface TemplateStream : NSObject
{
	char *data;
	NSUInteger bytesToGo;
	NSMutableArray *counterStack;
	NSMutableArray *keyStack;
}

+ (id)streamWithBytes:(char *)d length:(NSUInteger)l;
+ (id)substreamWithStream:(TemplateStream *)s length:(NSUInteger)l;

- (id)initStreamWithBytes:(char *)d length:(NSUInteger)l;
- (id)initWithStream:(TemplateStream *)s length:(NSUInteger)l;

- (char *)data;
- (NSUInteger)bytesToGo;
- (void)setBytesToGo:(NSUInteger)b;
- (ElementOCNT *)counter;
- (void)pushCounter:(ElementOCNT *)c;
- (void)popCounter;
- (Element *)key;
- (void)pushKey:(Element *)k;
- (void)popKey;

- (Element *)readOneElement;	// For parsing of 'TMPL' resource as template.
- (NSUInteger)bytesToNull;
- (void)advanceAmount:(NSUInteger)l pad:(BOOL)pad;					// advance r/w pointer and optionally write padding bytes
- (void)peekAmount:(NSUInteger)l toBuffer:(void *)buffer;				// read bytes without advancing pointer
- (void)readAmount:(NSUInteger)l toBuffer:(void *)buffer;				// stream reading
- (void)writeAmount:(NSUInteger)l fromBuffer:(const void *)buffer;	// stream writing
- (NSMutableDictionary *)fieldRegistry;

@end
