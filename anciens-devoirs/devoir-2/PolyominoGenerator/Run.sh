#!/bin/sh

dune exec PolyominoGenerator "$@"
swipl -s Prolog/Analysis.pl -g print_information -g halt
