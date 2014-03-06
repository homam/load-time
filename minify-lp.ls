{id, Obj,map, concat, filter, each, find, fold, foldr, fold1, zip, head, tail, all, flatten, sum, group-by, obj-to-pairs, partition, join, unique, sort-by, reverse, empty} = require 'prelude-ls'

foldA = (f, acc, xs, callback) ->
	| xs.length == 0 => callback acc
	| otherwise => 
		nacc <-  f acc, (head xs)
		foldA f, nacc, (tail xs), callback


mapA = (f, xs, callback) ->
	xs = xs `zip` [0 to xs.length - 1]
	results = []
	got = (i, r) !-->
		results := results ++ [[r,i]]
		if results.length == xs.length
			callback <| results |> (sort-by ([r,i]) -> i) >> (map ([r,i]) -> r)
	xs |> each ([x,i]) -> f x, (got i)


request = require \request
ch = require \cheerio
fs = require \fs
sh = require \execSync


download-and-save-urls = (urls, filename, callback) ->
	arr <- mapA ((url, callback) ->
		(e, r, b) <- request url
		console.log "Got #url #{b.length}"
		callback b
	), urls


	fs.writeFileSync filename, (join '\n\n', arr)

	callback arr

host = 'http://fun.mozook.com'


(error, response, body) <- request do 
	url: host + '/?pageid=526&country=Azerbaijan&ipx=1'
	headers:
		'User-Agent': 'Minify-lp, Homam'

$ = ch.load body, ignoreWhitespace: true

urls = $ 'head script[src]' |> map (host+) . (.attribs.src)

console.log urls

sh.exec 'mkdir out'

_ <- download-and-save-urls urls, 'out/all.js'

console.log 'all.js written'

sh.exec './closure-compiler.sh out/all.js out/all.min.js'

console.log 'all.min.js written'

urls = $ 'head link[href]' |>  map (host+) . (.attribs.href) |> filter (-> it.indexOf(\.css) > 0)

console.log urls

_ <- download-and-save-urls urls, 'out/all.css'

console.log 'all.css written'




#console.log body
#console.log response