# The Fairlight C64 Intro 

The dissassembled source code of the iconic C64 intro.  
Read all about the process of unpacking and disassembly in [my blog](https://www.awsm.de/blog/)

[Fairlight Intro](https://www.awsm.de/blog/fairlight-intro/)  

If you're unfamiliar with the intro, [go check it out on youtube](https://youtu.be/WnYCERvc2B8?t=17).

## Files

`flt-01-converted.asm`  
Converted with [pydisass6502](https://github.com/Esshahn/pydisass6502).

`flt-02-cleaned.asm`  
Cleaned up version with named labels and separate files.

`flt-03-finished.asm`  
Finished version including bug fixes other improvements like a stable raster routine.

`flt-04-awsm.asm`  
Playing around with the code to create a new version of the intro for myself.


## How to compile

I'm using the ACME assembler, but all specific syntax can be easily adapted to other assemblers like KickAss. In addition, I've used the [ACME VSCode Template](https://github.com/Esshahn/acme-assembly-vscode-template), which is available for Windows, Mac and Linux.

Building should be relatively easy if you follow the `make.sh` file, but you can just drop the files into your build environment and skip the make file completely. `main.asm` is the right entrypoint. If you want to use the `make.sh` file, make sure to adapt these pathes to your specific setup. If you're using the VSCode Template, you're probably good to go already.

```
os=mac # mac, linux, win
path_vice=/Applications/vice-gtk/bin
path_acme=bin/$os/acme
path_exomizer=bin/$os/exomizer
```

