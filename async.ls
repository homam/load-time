{id, odd, div, Obj,map, concat, filter, each, find, fold, foldr, fold1, zip, head, tail, all, flatten, sum, group-by, obj-to-pairs, partition, join, unique, sort-by, reverse, empty} = require 'prelude-ls'

# (>=>) :: Monad m => (a -> m b) -> (b -> m c) -> a -> m c
# (>>=) :: Monad m => m a -> (a -> m b) -> m b)
# (<*>) :: Applicative f => f (a -> b) -> f a -> f b
# fmap :: Functor f => (a -> b) -> f a -> f b

# ferr = (f, callback) ->
# 	try
# 	  	(err, r) <- f!
# 	  	callback err, r
# 	catch error
# 		callback error, null
	  


# f :: x -> CB y
# g :: (y, x) -> z
# fmapA :: (x -> CB y) -> ((y,x) -> z)  -> (x -> CB z)
# fmapA = (f, g) -->
# 	(x, callback) ->
# 		(err, fx) <- f x
# 		callback err, (g fx, x)

# compA :: (x -> CB y) -> ((y,x) -> z) -> (x -> CB z)
compA = (f, g) -->
	(x, callback) ->
		(err, fx) <- f x
		callback err, (g fx, x)

# compA_ :: (CB y) -> (y -> z) -> (CB z)
compA_ = (f, g) -->
	(callback) ->
		(err, fx) <- f!
		callback err, (g fx)

# kcompsA :: (x -> CB y) -> (y -> CB z) -> (CB z)
kcompsA = (f, g) -->
	(x, callback) ->
		(err, fx) <- f x
		g fx, callback

# :: (a -> CB b) -> [a] -> CB [b]
# parallel
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

# :: (a -> CB b) -> [a] -> CB [b]
# series
mapS = (f, xs, callback) !-->
	next = (results) ->
		(err, r) <- f(xs[results.length])
		if !!err
			callback err, results
		else
			results.push r
			if results.length == xs.length
				callback null, results
			else
				next results
	next []

mapA-limited = (n, f, xs, callback) !-->
	parts = partition-in-n-parts n, xs
	g = (mapS (mapA f)) `compA` concat
	g parts, callback

# filter-bu-map :: ((a -> CB [Bool, a]) -> [a] -> CB [[Bool, a]]) -> (a -> CB Bool) -> [a] -> CB [a]
filter-by-map = (mapper, f, xs, callback) !-->

	g = compA f, ((fx, x)-> [fx, x])
	(err, results) <- mapper g, xs

	callback err, (results |> (filter ([s,_]) -> s) >> (map ([_,x]) -> x))


# filterA :: (x -> CB Bool) -> [x] -> CB [x]
filterA = (f, xs, callback) !-->

	g = compA f, ((fx, x)-> [fx, x])
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
	g = compA f, ((fx,_) -> not fx)
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

# f :: x -> CB y (sortable)
# xs :: [x]
# callback :: CB [x]
sort-byA = (f, xs, callback) !->
	null


# :: Int -> [x] -> [[x]]
partition-in-n-parts = (n, arr) -->
	(arr `zip` [0 to arr.length]) |> (group-by ([a, i]) -> i `div` n) |> obj-to-pairs |> map (([_,ar]) -> (map (([a, _]) -> a), ar))

exports.mapA = mapA
exports.filterA = filterA
exports.allA = allA
exports.anyA = anyA
exports.findA = findA
exports.compA = compA
exports.compA_ = compA_

arr = [\a \b \c \d \e \f \g \h \i \j]
(err, res) <- mapA-limited 3, ((x, callback) -> callback(null, x + "!")), arr
console.log err, res

return 


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
