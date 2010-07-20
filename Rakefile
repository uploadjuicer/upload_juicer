require "bundler"
Bundler.setup

# require "rspec/core/rake_task"
# Rspec::Core::RakeTask.new(:spec)

gemspec = eval(File.read("upload_juicer.gemspec"))

task :build => "#{gemspec.full_name}.gem"

file "#{gemspec.full_name}.gem" => gemspec.files + ["upload_juicer.gemspec"] do
  system "gem build upload_juicer.gemspec"
end