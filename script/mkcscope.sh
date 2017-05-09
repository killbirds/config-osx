#!/bin/sh

#activator genCtags

rm -rf cscope.files cscope.out

find . -type d \( \
    -path ./.ctags_srcs -o \
    -path ./.git -o \
    -path target -o \
    -path node_modules \
  \) \
  -prune -o \
  \( \
    -name '*.scala' -o \
    -name '*.java' -o \
    -name '*.go' -o \
    -name '*.js' -o \
    -name '*.coffee' -o \
    -name '*.rb' \
  \) \
  -print > cscope.files

#find . -type d \( -path .ctags_srcs -o -path .git -o -path target \) -prune -o \( -name '*.scala' \) -print > cscope.files
#find . -type d \( -path .ctags_srcs -o -path .git -o -path target \) -prune -o \( -name '*.java' \) -print >> cscope.files
#find . -type d \( -path .ctags_srcs -o -path .git -o -path target \) -prune -o \( -name '*.go' \) -print >> cscope.files

#find . -type d \( -path .ctags_srcs -o -path .git -o -path target -o -path */node_modules \) -prune -o \( -name '*.js' \) -print >> cscope.files
#find . -type d \( -path .ctags_srcs -o -path .git -o -path target -o -path */node_modules \) -prune -o \( -name '*.coffee' \) -print >> cscope.files

#find . -type d \( -path .ctags_srcs -o -path .git -o -path target \) -prune -o \( -name '*.rb' \) -print >> cscope.files

cscope -i cscope.files

