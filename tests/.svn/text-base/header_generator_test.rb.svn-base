require "test/unit"
require "header_generator.rb"

class HeaderGenerationTest < Test::Unit::TestCase
  def testParseTestFiles
    ["tests/testfile", "tests/testfile-bare"].each do |path_prefix|
      implContent = File.new(path_prefix + ".m").read
      expectedHeader = File.new(path_prefix + ".h").read
      
      assert_equal expectedHeader, HeaderGenerator.new.parse(implContent)
    end
  end
  
  def testNoImpactToNonAnnotated
    implContent = File.new('tests/testfile-no-annotation.m').read
    assert_nil HeaderGenerator.new.parse(implContent)
  end
end
