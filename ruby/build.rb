require "liquid"
require "fileutils"
require "json"

if ARGV.length < 3
    puts "\nUsage: ruby build.rb [in_file_path] [json_data_path] [out_folder_path]\n
    Example: ruby build.rb '../src/template.html' '../src/data.json' '../build/'\n "
    exit
end

inPath = ARGV[0]
data = JSON.parse(File.read(ARGV[1]))
outPath = ARGV[2]

inFile = File.read(inPath)
inFileName = File.basename(inPath)
@template = Liquid::Template.parse(inFile)

FileUtils.mkdir_p(outPath)
File.write(outPath+inFileName, @template.render(data))