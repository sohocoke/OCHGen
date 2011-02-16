require "test/unit"
require "processors.rb"

class ProcessorsTest < Test::Unit::TestCase
  
  def testMethodPrototypeBlock
    generated = MethodPrototypesProcessor.new(File.new("tests/testfile.m").read).generate
    
    expected = "-(void)observeKeyPath:(NSString*)aKeyPath target:(id)aTarget;
- (void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
change:(NSDictionary *)change
context:(void *)context;"
    
    assert_equal expected, generated.strip
  end
  
  def testClassStartBlock
    token = ClassStartProcessor.new("@implementation MyClass")
    assert_equal "@interface MyClass :NSObject\n", token.generate    
  end
  
  def testClassStartBlock_subclassing
    token = ClassStartProcessor.new("@implementation MyClass //@ :MySuperClass")
    assert_equal "@interface MyClass :MySuperClass\n", token.generate
  end
  
  def testClassStartBlock_category
    token = ClassStartProcessor.new("@implementation MyClass (Category)")
    assert_equal "@interface MyClass (Category)\n", token.generate
  end
  
  def testClassEndBlock
    token = ClassEndProcessor.new
    assert_equal "@end", token.generate
  end
  
  def testHeaderDeclarationBlock_onlyImports
    str = '/*@
 #import <UIKit/UIKit.h>
*/
    '
    assert_equal '#import <UIKit/UIKit.h>',
      HeaderDeclarationProcessor.new(str).generate(:imports).strip
  end
  
  def testPropertyBlock_annotationOnSynthesize
    str = '@synthesize prop1; //@ (readonly) NSString*'
    assert_equal "@property(readonly) NSString* prop1;\n",
      PropertiesProcessor.parse(str).generate(:propertyDeclarationBlock)
    
    assert_equal "// ivars for properties:\nNSString* prop1;\n",
      PropertiesProcessor.parse(str).generate(:ivarBlock)
  end
  
  def testPropertyBlock_annotationOnDynamic
    str = '@dynamic prop1; //@ (readonly) NSString*'
    assert_equal "@property(readonly) NSString* prop1;\n",
      PropertiesProcessor.parse(str).generate(:propertyDeclarationBlock) 

    assert_equal "",
      PropertiesProcessor.parse(str).generate(:ivarBlock)
  end
  
  def testPropertyBlock_annotationOnMethods
    str = '-(NSTimeInterval) elapsed { //@ property(readonly)'
    assert_equal "@property(readonly) NSTimeInterval elapsed;\n", 
      MethodPropertiesProcessor.parse(str).generate(:propertyDeclarationBlock)
    # TODO check ivar decl block
  end
  
  def testImportBlock
    annotation = '
    /*@
     #import \'dependency\'
     @class DependencyClass
    */
    '
    generated = ""
    ImportsProcessor.parse(annotation).each {|processor|
      generated << processor.generate
    }
    
    assert_equal '#import \'dependency\'
@class DependencyClass', 
    generated.strip
  end
  
  def testClassBlock
    string = "
@implementation xxx
@end
@implementation xxx (category)
@end
"
    
    parsedBlocks = ImplBlockProcessor.parse(string)
    assert_equal parsedBlocks.class, Array
    assert_equal parsedBlocks.length, 2
    assert_equal parsedBlocks[0].generate, "@implementation xxx\n@end\n"
  end
end
