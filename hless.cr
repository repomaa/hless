require "option_parser"
require "tempfile"

VERSION = "0.1.0"

options = {} of Symbol => String

if ARGV.any? && File.exists?(ARGV[-1])
  file = ARGV.pop
end

OptionParser.parse! do |parser|
  parser.banner = "hless - less with syntax highlighting\n\n" \
                  "Usage #{$0} [-l lexer] [less options ...] [file]"

  parser.on("-l LEXER", "--lexer LEXER", "the pygments lexer to use") do |lexer|
    options[:lexer] = lexer
  end

  parser.on("-h", "--help", "show this help") do
    puts parser
    exit
  end

  parser.on("-v", "--version", "show version") do
    puts VERSION
    exit
  end

  parser.separator(
    "\nExamples:\n" \
    "# Open the file hless.cr in less and highlight it using the ruby lexer\n" \
    "$ #{$0} -l rb hless.cr\n" \
    "# Open the file foo.rb and highlight it with the lexer guessed from the file\n" \
    "$ #{$0} foo.rb\n" \
    "# Follow the tail of a logfile and highlight its contents using the ruby lexer\n" \
    "$ tail -f log/development.log | #{$0} -l rb"
  )
end

pygmentize_cmd = "pygmentize"
pygmentize_args = file ? [] of String : ["-s"]

if options[:lexer]?
  pygmentize_args += ["-l", options[:lexer], file].compact
elsif file
  pygmentize_args += ["-g", file]
else
  pygmentize_cmd = "cat"
  pygmentize_args = [] of String
end

Tempfile.open(File.basename($0)) do |tempfile|
  if file
    Process.run(
      pygmentize_cmd, pygmentize_args,
      output: tempfile,
      error: true
    )
    Process.run("less", ["-R", tempfile.path] + ARGV, output: true, error: true)
  else
    fork do
      Process.run(
        pygmentize_cmd, pygmentize_args,
        output: tempfile,
        input: STDIN,
        error: true
      )
    end
    Process.run("less", ["-R", "+F", tempfile.path] + ARGV, output: true, error: true) do
      Signal::INT.ignore
    end
  end

  tempfile.unlink
end
