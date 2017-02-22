#!/usr/bin/env bash -x
yard

export TARGET_BRANCH="gh-pages"
mkdir ${TARGET_BRANCH}
cd ${TARGET_BRANCH}

git clone -b ${TARGET_BRANCH} --single-branch https://github.com/ironSource/atom-ruby.git

cd atom-ruby
cp -r ../../doc/* .

# Remove old docs
git rm .
git commit -m "Clear GitHub Pages"

# Now that we're all set up, we can push.
git push origin ${TARGET_BRANCH}

# Add new docs
git add .
git commit -m "Deploy to GitHub Pages"

# Now that we're all set up, we can push.
git push origin ${TARGET_BRANCH}

cd ../../
rm -r -f ${TARGET_BRANCH}
rm -r -f doc