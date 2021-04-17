#! /bin/bash
# this script needs to have executable rights: sudo chmod 755 make.sh


# args
#
# -e or --emulator (optional)
# which emulator to start after compilation
# can be either none or "vice" 
# default: vice
#
# -f or --filename (optional)
# the filename of the generated executable
# default: main
#
# -c or --crunch (optional)
# user exomizer packer to reduce the file size
# no args
#
# -d64 (optional)
# if set, creates additional d64 disc file with the prg in it
# no args

# config
build_folder=build
os=mac # mac, linux, win
path_vice=/Applications/vice-gtk/bin
path_acme=bin/$os/acme
path_exomizer=bin/$os/exomizer



while true ; do
    case "$1" in
        -e|--emulator )
            emulator=$2
            shift 2
        ;;
        -f|--filename )
            filename=$2
            shift 2
        ;;
        -c|--crunch )
            crunch=1
            shift 1
        ;;
        -d64 )
            d64=1
            shift 1
        ;;
        *)
            break
        ;;
    esac 
done;

# default filename is none is provided
[ ! $filename ] && filename="main"


# remove build folder and create a clean one afterwards
rm -rf $build_folder
mkdir $build_folder

# compile the file
echo compiling as $filename...
$path_acme -f cbm -r $build_folder/report.asm -l $build_folder/labels -o $build_folder/$filename.prg code/main.asm
echo done.


# crunch with exomizer
if [ $crunch ]
then
    STARTADDR=$(grep 'main' $build_folder/labels | cut -d$ -f2 | cut -f1)
    echo crunching with exomizer
    echo start address $STARTADDR
    $path_exomizer sfx 0x$STARTADDR -n -t 64 -o $build_folder/$filename.prg $build_folder/$filename.prg 
fi

# put prg file into a d64 image
if [ $d64 ]
then
    echo creating d64 file
    $path_vice/c1541 -format $filename,1 d64 $PWD/$build_folder/$filename.d64 -write $PWD/$build_folder/$filename.prg $filename
fi

# execute vice emulator
if [ !$emulator ] || [ $emulator = "vice" ]
then
    echo launching VICE
    $path_vice/x64sc -moncommands $PWD/$build_folder/labels $PWD/$build_folder/$filename.prg
fi
