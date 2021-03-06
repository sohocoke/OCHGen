require "processors.rb"

class String
  def appendIndented!(str, blockStart, blockEnd)
    self << blockStart << "\n" if ! blockStart.nil?
    
    blockBody = ""
    str.each_line do |line|
      blockBody << "\t#{line}"
    end
    
    self << blockBody if ! blockBody.strip.empty?
    
    self << blockEnd << "\n" if ! blockEnd.nil?
  end
  
  def appendParagraph!(str)
    self << str << "\n" if ! str.strip.empty?
  end
end

class HeaderGenerator
  def parse(impl)
    # get rid of comments
    impl.gsub!(/\/\*[^@].*?\*\//m, "")
    impl.gsub!(/^\s*\/\/.*/, "")
    
    generated = "/* Generated by OCHGen */\n\n"
 
    headerDeclaration = HeaderDeclarationProcessor.new(impl)
    return nil if ! headerDeclaration.found
      
    # imports
    generated.appendParagraph!( headerDeclaration.generate(:imports) )

    # loop by implementation block (@implementation..@end)
    implBlocks = ImplBlockProcessor.parse(impl).map{|x| x.generate}
    implBlocks.each_index { |i|
      generated << "\n" if (i > 0) 
        
      implBlock = implBlocks[i]
      propertiesFromSynthesize = PropertiesProcessor.parse(implBlock)
  
      # class block begin
      classStartGenerator = ClassStartProcessor.new(implBlock)
      generated << classStartGenerator.generate
      # ivar block
      if classStartGenerator.isClassDefinition
        generatedIvarBlock = headerDeclaration.generate(:ivars) << "\n" << 
          propertiesFromSynthesize.generate(:ivarBlock)
        generated.appendIndented!(generatedIvarBlock, "{", "}")
      end
      generated << "\n"
      # method prototypes
      generated << MethodPrototypesProcessor.new(implBlock).generate
      generated << "\n"
      #properties
      generated << propertiesFromSynthesize.generate(:propertyDeclarationBlock)
      generated << MethodPropertiesProcessor.parse(implBlock).generate(:propertyDeclarationBlock)
      #class block end
      generated << "\n" << ClassEndProcessor.new.generate << "\n"
    }
    
    return generated
  end
end

# main method equivalent
if __FILE__ == $0
  generator = HeaderGenerator.new
  
  path = ARGV[0]
  
  if File.directory?(path)
    Dir["#{path}/**/*.m"].each { |f|
      generated = generator.parse(File.open(f).read)
      
      # write if needed  TODO provide a switch
      output_file = f.sub(/\.m$/, '.h')
      if (! generated.nil?) && 
	       ( ! File.exists?(output_file) || ! (generated.eql? File.open(output_file).read) )
        File.open(output_file, 'w') { |file| file.write(generated) }
        puts "Wrote generated header to #{output_file}."
      end
    }
  else
    ARGV.each do |filename|
      contents = File.open(filename).read
      puts generator.parse(contents)
    end
  end
end
