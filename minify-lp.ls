{id, Obj,map, concat, filter, each, find, fold, foldr, fold1, zip, head, tail, all, flatten, sum, group-by, obj-to-pairs, partition, join, unique, sort-by, reverse, empty} = require 'prelude-ls'

request = require \request
ch = require \cheerio
fs = require \fs
sh = require \execSync
css = require \css
path = require \path
{compA, mapA} = require \./async.ls


parse-css = ([text, url]) ->
	path = (url.replace host, '') |> (u) -> u.substring 0, u.lastIndexOf \/ |> (+ \/)
	css-obj = css.parse text
	css-obj.stylesheet.rules = map (fix-css-rule path), css-obj.stylesheet.rules
	css.stringify css-obj

	#console.log <| css.stringify <| css-obj

fix-css-rule = (path, rule) -->
	if !!rule.declarations
		rule.declarations = map (fix-css-declaration path), rule.declarations
	rule

fix-css-declaration = (path, declaration) -->
	regex = /^url\s*\(['"]?([\w./-]+)["']?\)(.*)$/ # "
	property = declaration.property
	value = declaration.value
	if ('background-image' == property or 'background' == property) and regex.test value
		fixed-value = value.replace regex, \url(' + (fix-css-url path, (regex.exec value).1) + "')$2"
		declaration.value = fixed-value
	declaration

fix-css-url = (current-path, url) ->
	#current-path = '/_common/css/'
	path.normalize current-path + url




download-url = (url, callback) !->
	(e, r, b) <- request url
	callback e, b

download-and-save-urls = (downlaoder, urls, filename, callback) !->
	(e, arr) <- mapA downlaoder, urls
	console.log <| map (.length), arr
	fs.writeFileSync filename, (join '\n\n', arr)
	callback arr


host = 'http://fun.mozook.com'


(error, response, body) <- request do 
	url: host + '/?pageid=526'
	headers:
		'User-Agent': 'Minify-lp, Homam'

$ = ch.load body, ignoreWhitespace: true

urls = $ 'head script[src]' |> map (host+) . (.attribs.src)

console.log urls

sh.exec 'mkdir out'


_ <- download-and-save-urls (download-url `compA` ((text,u) -> console.log("got #u #{text.length}"); text)), urls, 'out/all.js'


console.log 'all.js written'

sh.exec './closure-compiler.sh out/all.js out/all.min.js'

console.log 'all.min.js written'

urls = $ 'head link[href]' |>  map (host+) . (.attribs.href) |> filter (-> it.indexOf(\.css) > 0)

console.log urls

_ <- download-and-save-urls download-url `compA` ((text,u) -> [text, u]) `compA` parse-css, urls, 'out/all.css'

console.log 'all.css written'




#console.log body
#console.log response