class SimpleCov::Formatter::QualityFormatter
  def format(result)
    SimpleCov::Formatter::HTMLFormatter.new.format(result)
    File.open('coverage/covered_percent', 'w') do |f|
      f.puts result.source_files.covered_percent.to_f
    end
  end
end
SimpleCov.formatter = SimpleCov::Formatter::QualityFormatter

SimpleCov.start do
  add_filter '/spec/'
  add_group 'CLI', 'lib/presence/cli'
  add_group 'Listeners', 'lib/presence/listeners'
end
