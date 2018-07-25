#!/bin/bash
git config --global user.email "davidsiaw@gmail.com"
git config --global user.name "David Siaw (via Circle CI)"

git clone git@github.com:davidsiaw/davidsiaw.net.git build
cp -r build/.git ./gittemp
bundle install
bundle exec weaver build -r https://davidsiaw.net
cp -r ./gittemp build/.git
pushd build
echo davidsiaw.net > CNAME
cp 404/index.html 404.html
git add .
git add -u
git commit -m "update `date`"
ssh-agent bash -c 'ssh-add ~/.ssh/id_github.com; git push'
popd

