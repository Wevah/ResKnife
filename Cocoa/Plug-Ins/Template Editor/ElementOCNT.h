#import "Element.h"

@interface ElementOCNT : Element
{
	UInt32 value;
}

- (BOOL)countFromZero;

- (void)setValue:(unsigned int)v;
- (unsigned int)value;

- (void)increment;
- (void)decrement;

- (NSString *)stringValue;
- (void)setStringValue:(NSString *)str;

@end
