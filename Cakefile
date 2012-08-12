fs     = require 'fs'
{exec} = require 'child_process'

appFiles  = [
  # omit src/ and .coffee to make the below lines a little shorter
  'js/field'
  'js/curve'
  'js/data'
  'js/raphaelMap'
  'js/soccerMap'
]

task 'build', 'Build single application file from source files', ->
  appContents = new Array remaining = appFiles.length
  for file, index in appFiles then do (file, index) ->
    fs.readFile "public/#{file}.coffee", 'utf8', (err, fileContents) ->
      throw err if err
      appContents[index] = fileContents
      process() if --remaining is 0
      
  process = ->
    output = "public/tageswoche-fussball"
    fs.writeFile "#{ output }.coffee", appContents.join('\n\n'), 'utf8', (err) ->
      throw err if err
      exec "coffee --compile #{ output }.coffee", (err, stdout, stderr) ->
        throw err if err
        console.log stdout + stderr
        fs.unlink "#{ output }.coffee", (err) ->
          throw err if err
          console.log 'Done.'


# task 'minify', 'Minify the resulting application file after build', ->
#   exec 'java -jar "/home/stan/public/compiler.jar" --js lib/app.js --js_output_file lib/app.production.js', (err, stdout, stderr) ->
#     throw err if err
#     console.log stdout + stderr
    

task 'minify', 'minifies proudify (YUI compressor)', ( options ) ->
  [ output, filename ] = get_options options

  js_minified = set_extension filename, '.min.js'
  css_minified = set_extension css_filename, '.min.css'

  system_with_echo "java -jar yuic/yuic.jar --nomunge #{output}/#{filename} -o #{output}/#{js_minified}"
  system_with_echo "java -jar yuic/yuic.jar --nomunge #{css_filename} -o #{output}/#{css_minified}"