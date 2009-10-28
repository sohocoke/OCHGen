// this file has no annotations.

#import "testfile-bare.h"

/*@
*/
@implementation ActionAttachedButton
-(void) setValue:(NSString*)value {
	[self setTitle:value forState:UIControlStateNormal];
}
-(NSString*) value {
	return [self titleForState:UIControlStateNormal];
}

-(void) addTarget:(id)target action:(SEL)selector {
	[self addTarget:target
			 action:selector 
   forControlEvents:UIControlEventTouchUpInside
	 ];
}
@end
