//
// KVOObserver.m
// ProgrammeManager
//
//

/*@
#import <foundation/foundation.h>

state:
  NSDictionary* keyPathRegistrationDictionary

*/

#import "KVObserver.h"

#define kChange @"kChange"
#define kObject @"kObject"

#define kSelector @"kSelector"
#define kTargets @"kTargets"

/*
@implementation CommentedClass
*/
//@implementation AnotherCommentedClass

// TODO find out why this wasn't used
@implementation KVObserver

@synthesize calcController; //@ (assign,atomic) CalcController*
@synthesize numberOfLows; //@ (readonly) NSUInteger

// target calls this method
-(void)observeKeyPath:(NSString*)aKeyPath target:(id)aTarget {
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
change:(NSDictionary *)change
context:(void *)context
{
    NSDictionary* observationArguments = [NSDictionary dictionary];
    [observationArguments setValue:change forKey:kChange];
    [observationArguments setValue:object forKey:kObject];
    SEL selector = [[keyPathRegistrationDictionary valueForKey:keyPath] valueForKey:kSelector];
    id targets = [[keyPathRegistrationDictionary valueForKey:keyPath] valueForKey:kTargets];
    for (id target in targets) {
        [target performSelector:selector withObject:observationArguments]; // target implements method
    }
}

@end