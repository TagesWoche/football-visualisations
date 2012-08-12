require 'rake/minify'
Rake::Minify.new(:minify_multiple) do
  dir("public") do # we specify only the source directory
    group("public/tageswoche-fussball.js") do # the output file name is full path
      add("js/field.js")
      add("js/curve.js")
      add("js/data.js")
      add("js/raphaelMap.js")
      add("js/soccerMap.js")
    end
  end
end