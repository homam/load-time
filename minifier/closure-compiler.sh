# IN=all.js
# OUT=min.js

echo $1
echo $2

curl -s \
	-d compilation_level=SIMPLE_OPTIMIZATIONS \
	-d output_format=text \
	-d output_info=compiled_code \
	--data-urlencode "js_code@${1}" \
	http://closure-compiler.appspot.com/compile \
	> $2

