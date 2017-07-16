#!/bin/sh

a=1
for i in *.jpg; do
  new=$(printf "b.%04d.jpg" "$a")
  mv -i -- "$i" "$new"
  let a=a+1
done 

a=1
for i in *.jpg; do
  new=$(printf "background.%04d.jpg" "$a")
  mv -i -- "$i" "$new"
  let a=a+1
done 
