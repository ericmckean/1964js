# 1964js #

This is the first N64 emulator written in JavaScript (CoffeeScript to JS). It is loosely a port of our N64 emulator for Windows called 1964. 1964 was written in C and C++.

<a href='http://www.youtube.com/watch?feature=player_embedded&v=CM_QuJYqJvM' target='_blank'><img src='http://img.youtube.com/vi/CM_QuJYqJvM/0.jpg' width='425' height=344 /></a>
<a href='http://www.youtube.com/watch?feature=player_embedded&v=AwNLKogdaEE' target='_blank'><img src='http://img.youtube.com/vi/AwNLKogdaEE/0.jpg' width='425' height=344 /></a>

### Demos ###

<a href='http://1964js.com?rom=unofficial_roms/DynamixReadme.zip'>Dynamix Readme Demo (texrect wireframe)</a><br>
<a href='http://1964js.com/?rom=unofficial_roms/rotate.zip'>Rotate Demo</a><br>
<a href='http://1964js.com/?rom=unofficial_roms/n64stars.zip'>N64Stars Demo</a><br>
<a href='http://1964js.com/?rom=unofficial_roms/sp_crap.zip'>sp_crap Demo</a><br>
<a href='http://1964js.com/?rom=unofficial_roms/liner.zip'>Liner Demo</a>

This project is still in the early stages. The initial goal of this project was to see how well Google Chrome's V8 JavaScript compiler performs. I don't have benchmarks yet but the results look good.<br>
<br>
<br>
Instead of building a traditional dynarec (JIT compiler) as we did for 1964 for Windows which translated MIPS directly to x86, 1964js dynamically writes JavaScript to the web page by reversing MIPS code to JavaScript. This JavaScript represents blocks of rom code. Then, if using Chrome for instance, Google's V8 compiler compiles the JavaScript to native code for us automatically.<br>
<br>
For updates, please check <a href='http://1964js.com'>http://1964js.com</a> and visit the <a href='http://www.emutalk.net'>http://www.emutalk.net</a> forums.<br>
<br>
Be sure to check out n64js as well! <a href='http://hulkholden.github.com/n64js/'>http://hulkholden.github.com/n64js/</a>. Greets to StrmnNrmn, author of n64js and Daedalus. By pure coincidence, we started JavaScript N64 emulators around the same time.<br>
<br>
<br>
-schibo