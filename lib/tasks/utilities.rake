namespace :git do
  desc 'Strip trailing whitespace from tracked source files'
  task :strip_spaces do
    `git ls-files`.split("\n").each do |file|
      puts file

      if `file '#{file}'` =~ /text/
        sh "git stripspace < '#{file}' > '#{file}.out'"
        mv "#{file}.out", file
      end
    end
  end
end
