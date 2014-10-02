#!/bin/bash

#
# Create k-mer suffix arrays from a directory of FASTA files
#

source ./config.sh

export CWD=$PWD

PROG=`basename "$0" ".sh"`
ERR_DIR="$CWD/err/$PROG"
OUT_DIR="$CWD/out/$PROG"

create_dirs "$ERR_DIR" "$OUT_DIR"

if [[ ! -d "$SUFFIX_DIR" ]]; then
    mkdir "$SUFFIX_DIR"
fi

cd $FASTA_DIR

i=0
find . -maxdepth 1 -type d | while read DIR; do
    if [ "$DIR" = '.' ]; then
        continue
    fi

    export FINAL_DIR=`readlink -f $SUFFIX_DIR/$DIR`
    if [ -d $FINAL_DIR ]; then
        $RM -rf $FINAL_DIR/*
    else
        $MKDIR $FINAL_DIR
    fi

    cd "$DIR"
    ls *.fa | while read file; do
        i=$((i+1))
        printf "%5d: %s" $i "$DIR/$file -> "
        FILE=`basename $file`
        FILE_PATH=`readlink -f $FASTA_DIR/$DIR/$IN`
        qsub -N suffix \
            -e "$ERR_DIR/$FILE"
            -o "$OUT_DIR/$FILE"
            -v MER_SIZE,FILE,FILE_PATH,FINAL_DIR \
            "$SCRIPT_DIR/create_suffix_arrays.sh"
    done
    cd "$FASTA_DIR"
done

# Just prettier enclosed in quotes...
echo "Submitted $i jobs for you.  Have a nice day."
