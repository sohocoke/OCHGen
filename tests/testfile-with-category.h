/* Generated by OCHGen */

#import <foundation/foundation.h>

@interface KVObserver :SomeSuperclass
{
	NSDictionary* keyPathRegistrationDictionary;
	
	// ivars for properties:
	CalcController* calcController;
	NSUInteger numberOfLows;
}

-(void)observeKeyPath:(NSString*)aKeyPath target:(id)aTarget;
- (void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
change:(NSDictionary *)change
context:(void *)context;

@property(assign,atomic) CalcController* calcController;
@property(readonly) NSUInteger numberOfLows;

@end


@interface UIView (MyCategory)
-(void)doCategoryOperation;
@end
