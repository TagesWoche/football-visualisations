fs     = require 'fs'
{exec} = require 'child_process'
uglify 	= require "uglify-js"

coffeeFiles  = [
  # omit public/ and .coffee to make the below lines a little shorter
  'js/field'
  'js/curve'
  'js/data'
  'js/raphaelMap'
  'js/soccerMap'
  'js/templates'
  'js/tableData'
]

# could not include all js files without problems... :(
# "js/vendor/jquery-1.7.2.min"
# "js/vendor/raphael-min"
# "js/vendor/jquery.tablesorter.min"

jsFiles = [
  "js/vendor/underscore"
  "js/vendor/sparklines"
	"tageswoche-fussball"
]

path  = "./"
outCoffee = "public/tageswoche-fussball"
outJs = "public/twfs-min"

task 'build', 'Build single application file from source files', ->
  appContents = new Array remaining = coffeeFiles.length
  for file, index in coffeeFiles then do (file, index) ->
    fs.readFile "public/#{file}.coffee", 'utf8', (err, fileContents) ->
      throw err if err
      appContents[index] = fileContents
      process() if --remaining is 0
      
  process = ->
    fs.writeFile "#{ outCoffee }.coffee", appContents.join('\n\n'), 'utf8', (err) ->
      throw err if err
      exec "coffee --compile #{ outCoffee }.coffee", (err, stdout, stderr) ->
        throw err if err
        console.log stdout + stderr
        fs.unlink "#{ outCoffee }.coffee", (err) ->
          throw err if err
          console.log 'Done.'


task "compress", 'Uglify JS', (params) ->
  
  console.log("\n    Compressing...\n\n")
  all = ""
  
  for file in jsFiles
    if file
      file = "public/#{ file }.js"
      console.log("#{ file }\n")
      all += ( fs.readFileSync(file) ).toString()
  
  ast = uglify.parser.parse all
  out = fs.openSync "#{ path }#{ outJs }.js", "w+"
  
  ast = uglify.uglify.ast_mangle ast
  ast = uglify.uglify.ast_squeeze ast
  
  fs.writeSync( out, "\n" + uglify.uglify.gen_code(ast) )
  
  console.log("\n Complete! #{ path }#{ outJs }.js \n\n")

# task 'minify', 'Minify the resulting application file after build', ->
#   exec 'java -jar "/home/stan/public/compiler.jar" --js lib/app.js --js_output_file lib/app.production.js', (err, stdout, stderr) ->
#     throw err if err
#     console.log stdout + stderr
    

# task 'minify', 'minifies proudify (YUI compressor)', ( options ) ->
#   [ output, filename ] = get_options options
# 
#   js_minified = set_extension filename, '.min.js'
#   css_minified = set_extension css_filename, '.min.css'
# 
#   system_with_echo "java -jar yuic/yuic.jar --nomunge #{output}/#{filename} -o #{output}/#{js_minified}"
#   system_with_echo "java -jar yuic/yuic.jar --nomunge #{css_filename} -o #{output}/#{css_minified}"

