#import "ElementDLNG.h"

#define SIZE_ON_DISK (4)

@implementation ElementDLNG

- (id)copyWithZone:(NSZone *)zone
{
	ElementDLNG *element = [super copyWithZone:zone];
	[element setValue:value];
	return element;
}

- (void)readDataFrom:(TemplateStream *)stream
{
	SInt32 tmp;
	[stream readAmount:SIZE_ON_DISK toBuffer:&tmp];
	value = CFSwapInt32BigToHost(tmp);
}

- (NSUInteger)sizeOnDisk
{
	return SIZE_ON_DISK;
}

- (void)writeDataTo:(TemplateStream *)stream
{
	SInt32 tmp = CFSwapInt32HostToBig(value);
	[stream writeAmount:SIZE_ON_DISK fromBuffer:&tmp];
}

- (void)setValue:(SInt32)v
{
	value = v;
}

- (SInt32)value
{
	return value;
}

- (NSString *)stringValue
{
	return [NSString stringWithFormat:@"%d", value];
}

- (void)setStringValue:(NSString *)str
{
	value = str.intValue;
}

@end

@implementation ElementKLNG
@end
