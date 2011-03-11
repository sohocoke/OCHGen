require "test/unit"
require "header_generator.rb"

class HeaderGenerationTest < Test::Unit::TestCase
 
  def testParseTestFiles
    ["tests/testfile", "tests/testfile-bare", "tests/testfile-with-category"].each do |path_prefix|
      implContent = File.new(path_prefix + ".m").read
      expectedHeader = File.new(path_prefix + ".h").read
      
      assert_equal expectedHeader, HeaderGenerator.new.parse(implContent)
    end
  end
  
  def testNoImpactForNonAnnotated
    implContent = File.new('tests/testfile-no-annotation.m').read
    assert_nil HeaderGenerator.new.parse(implContent)
  end
  
  def testNoImpactForMethodWithBlockComment
    implContent = File.new('tests/testfile-comment-in-method.m').read
    assert_not_nil HeaderGenerator.new.parse(implContent)
  end
  
end
