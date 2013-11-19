require "net/http"
require "optparse"

class YumlCmd
  
  def YumlCmd.generate(args)
    # Defaults
    ext = "png"
    input = nil
    output = nil
    type = "/scruffy"
    diagramtype = "class"

    # Option parser
    opts = OptionParser.new do |o|
      o.banner = "Usage: #{File.basename($0)} [options]"
      o.on('-f', '--file FILENAME', 'File containing yuml.me diagram.') do |filename|
        input = filename
      end        
      o.on('-t', '--type EXTENSION', 'Output format: png (default), jpg') do |extension|
        ext = extension if extension
      end
      o.on('-o', '--orderly', 'Generate orderly') do |t|
        type = "/orderly" if t
      end      
      o.on('-n', '--name OUTPUT', 'Output filename') do |name|
        output = name
      end
      o.on('-d', '--diagram DIAGRAM', 'Diagram type: class, activity, usecase') do |diagram|
	diagramtype = diagram
      end
      o.on_tail('-h', '--help', 'Display this help and exit') do
        puts opts
        exit
      end              
    end
    opts.parse!(args)

    # Fetch the image
    lines = IO.readlines(input).collect!{|l| l.gsub("\n", "")}.reject{|l| l =~ /#/}
    output = output || "#{input.gsub(".", "-")}"
    writer = open("#{output}.#{ext}", "wb")

    res = Net::HTTP.start("yuml.me", 80) {|http|
      http.get(URI.escape("/diagram#{type}/#{diagramtype}/#{lines.join(",")}"))
    }
    writer.write(res.body)
    writer.close
  end
  
end

if $0 == __FILE__
  YumlCmd.generate(ARGV)
end
