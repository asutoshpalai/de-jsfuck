# de-jsfuck

It deobfuscates JSFuck into readable JavaScript.

## Quick use guide

_If you have already setup SBCL with Quicklisp, the you can skip installing Roswell_

- Install and setup [Roswell](https://github.com/roswell/roswell#installation-dependency--usage)

- Run

      $ ./run.sh '<File_Name_Containg_JsFuck_Code>'


## Background details

I had to get past some changing JSFuck code which injected some global variables and
get the values of those variables. My target was to reverse a JSFuck code with only
specific part varying every time. So, I embarked upon the strategy of pattern matching.
In the end, I was able to decode almost all of the JSFuck code.

The important observations on which the code is based are

- All codes began with a specific pattern which fetched `Function` of JS which
is used to generate functions from strings.

- All of them ended with () which called the generated function.

- The code between them had segments enclosed within () of [], sometimes
continuous, separated by +. They turned out to generate characters of the
string being concatenated with +.

Note: _I have added only those characters which I encountered during my inspection. The
token list is not complete. If you find `<unknown:` section in your output, you can
evaluate them and add them to the mapping in [jsfuck-map.lisp](https://github.com/asutoshpalai/de-jsfuck/blob/master/jsfuck-map.lisp).
A pull request on the same will also benifit a larger audience._

### TODO

- Check the missing characters and add support for them too.

[Blog post](http://blog.asutoshpalai.in/2017/03/jsfuck-is-bad-security-barrier.html)
