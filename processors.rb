# interface that parses for tokens to process.

SingleLineAnnotationSymbol = /\/\/@/

class ImplBlockProcessor
  def initialize(str)
    @str = str
  end
  
  def self.parse(str)
    blocks = Array.new
    str.scan(/@implementation\s+.*?@end/m).each do |block|
      blocks << self.new(block)
    end
    return blocks
  end
  
  def generate
    return @str + "\n"
  end
end

class MethodPrototypesProcessor
  def initialize(str)
    @tokens = str.scan(/^[+-]\s*\(.*?\)\s*.*?(?=\{)/m)
  end
  
  def generate
    generated = ""
    @tokens.each do |token|
      generated << token.gsub(/\/\/.*$/, '').strip << ";\n"
    end
    return generated
  end
end

class ClassStartProcessor
  Pattern = /@implementation\s+([\w]+)(.*)?/
  AnnotationPattern = /(?:\s*\/\/@(.*))/
  CategoryPattern = /\s*\(.*?\)/  
  
  attr_reader :isClassDefinition
  
  def initialize(str)
    super()
    parsed = str.scan(Pattern).first
    @className = parsed[0]
    if parsed[1] != nil
      @isClassDefinition = parsed[1].scan(CategoryPattern).flatten.empty?
      
      @postClassName = parsed[1].scan(AnnotationPattern).flatten[0]
      @postClassName ||= parsed[1].scan(CategoryPattern)[0]
    end
    @postClassName ||= ' :NSObject'
  end
  
  def generate
    return '@interface ' << @className << @postClassName << "\n"
  end

end

class ClassEndProcessor
  def generate
    return "@end"
  end
end

class HeaderDeclarationProcessor
  attr_reader :found
  
  def initialize(str)
    parsed = str.scan(/\/\*@*(.*)\*\//m).first
    @found = ! parsed.nil?
    @imports = ImportsProcessor.parse(parsed.to_s)
    @ivars = IvarsProcessor.parse(parsed.to_s)
  end
  
  def generate(token_symbol)
    generated = ""
    instance_variable_get("@" << token_symbol.to_s).each {|token| generated << token.generate}
    return generated
  end
end

class ImportsProcessor
  def self.parse(str)
    tokens = Array.new
    str.scan(/(?:#import|@class).*/).each do |proto|
      tokens << self.new(proto)
    end
    return tokens
  end
  
  def initialize(str)
    @str = str
  end
  
  def generate
    return @str + "\n"
  end
end

class IvarsProcessor
  def self.parse(str)
    tokens = []
    parsed = str.split(/^\s*state:\s*\n/);
    return tokens if parsed.length < 2

    parsed[1].each do |line|
      tokens << self.new(line.strip) if ! line.strip.empty?
    end
    return tokens
  end
  
  def initialize(ivarDeclaration)
    @ivarDeclaration = ivarDeclaration
  end
  
  def generate
    return @ivarDeclaration << ";\n"  
  end
end

class PropertiesProcessor
  def self.parse(str, tokenType)
    case tokenType
      when :synthesize
        return self.new(
          str.scan(/@synthesize\s*(.*?)(?:\s*#{SingleLineAnnotationSymbol})\s*(\(.*?\))\s*(.*)/)
          )
      when :method
        parsed = str.scan(/-\s*\((.*?)\)\s*(\w+)\s*\{?\s#{SingleLineAnnotationSymbol}\s*property(\(\w+\))/)
        reorderedLines = []
        parsed.each do |line|
          type, name, attrs = line[0..2]
          reorderedLines << [name + ";", attrs, type]
        end
        return self.new(reorderedLines)
    end
  end

  def initialize(tokens)
    @tokens = tokens
  end

  def generate(generationType)
    generated = ""
    case generationType
      when :ivarBlock
        return generated if @tokens.empty?
        generated << "// ivars for properties:\n"
        @tokens.each do |synthesizeLine|
          generated << synthesizeLine[2] << " " << synthesizeLine[0] << "\n"
        end
      when :propertyDeclarationBlock
        @tokens.each do |synthesizeLine|
          generated << '@property' << synthesizeLine[1] << " " << 
            synthesizeLine[2] << " " << synthesizeLine[0] << "\n"
        end
    end
    return generated
  end
end
