{id, odd, Obj,map, concat, filter, each, find, fold, foldr, fold1, zip, head, tail, all, flatten, sum, group-by, obj-to-pairs, partition, join, unique, sort-by, reverse, empty} = require 'prelude-ls'

# ferr = (f, callback) ->
# 	try
# 	  	(err, r) <- f!
# 	  	callback err, r
# 	catch error
# 		callback error, null
	  


# f :: x -> CB y
# g :: (y, x) -> z
# bindA :: (x -> CB y) -> ((y,x) -> z)  -> (x -> CB z)
bindA = (f, g) -->
	(x, callback) ->
		(err, fx) <- f x
		callback err, (g fx, x)

# mapA :: ((err, b) <- x) -> [x]-> ((err, [b]) <- void)
mapA = (f, xs, callback) !-->
	xs = xs `zip` [0 to xs.length - 1]
	results = []
	got = (i, err, r) !-->
		if !!err
			callback err, (results |> (sort-by ([_,i]) -> i) >> (map ([r,_]) -> r))
		else
			results := results ++ [[r,i]]
			if results.length == xs.length
				callback null, (results |> (sort-by ([_,i]) -> i) >> (map ([r,_]) -> r))
	xs |> each ([x,i]) -> f x, (got i)

# filterA :: ((err, bool) <- x) -> [x] -> ((err, [x]) <- void)
filterA = (f, xs, callback) !->

	g = bindA f, ((fx, x)-> [fx, x])
	(err, results) <- mapA g, xs

	callback err, (results |> (filter ([s,_]) -> s) >> (map ([_,x]) -> x))

# f :: (err, bool) <- x
anyA = (f, xs, callback) !->
	how-many-got = 0
	callback-called = false
	got = (err, res) -> 
		call = ->
			if not callback-called
				callback-called := true 
				callback err, res
		how-many-got := how-many-got + 1
		if !!err or res or (how-many-got == xs.length)
			call!
	xs |> each ((x) -> f x, got)

allA = (f, xs, callback) !->
	g = bindA f, ((fx,_) -> not fx)
	(err, res) <- anyA g, xs
	callback err, not res

findA = (f, xs, callback) !->
	how-many-got = 0
	callback-called = false
	got = (x, err, res) --> 
		call = ->
			if not callback-called
				callback-called := true 
				callback err, if res then x else null
		how-many-got := how-many-got + 1
		if !!err or res or (how-many-got == xs.length)
			call!
	xs |> each ((x) -> f x, (got x))

sort-byA = (f, xs, callback) !->
	null

f1 = (x, callback) -> setTimeout (-> callback null, x*x), 200
f2 = (x, callback) -> setTimeout (-> callback (if x == 7 then 'ERROR at 7' else null), (odd x*x)), 100
f3 = (x, callback) -> setTimeout (-> callback null, (odd x*x)), 100
f4 = (x, callback) -> setTimeout (-> callback null, (x*x > (-1))), 100

(err, res) <- mapA f1, [0 to 10]
console.log err, res

(err, res) <- filterA f3, [0 to 10]
console.log 'filterA', err, res

(err, res) <- anyA f3, [0 to 10]
console.log err, res

(err, res) <- allA f3, [0 to 10]
console.log err, res

(err, res) <- findA f3, [0 to 10]
console.log 'finA odd', err, res
