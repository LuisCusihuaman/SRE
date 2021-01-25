#!/bin/sh

isExistApp = `pgrep helloworld`
if [[ -n  $isExistApp ]]; then
    service helloworld stop
fi


