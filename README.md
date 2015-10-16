Lua Nova
========

This is the content for the Lua Nova web site.

[![Circle CI](https://circleci.com/gh/luanova/luanova.org.svg?style=svg)](https://circleci.com/gh/luanova/luanova.org)

### Setup

* Install the `hugo` binary, download it at [gohugo.io](http://gohugo.io/).
* Install [sassc](https://github.com/sass/sassc).
  Mac: `brew install sassc`
* SassC doesn't watch for file changes, but you can use [cmd/notify](https://github.com/rjeczalik/cmd).
* Install [Pygments](http://pygments.org/) for syntax highlighting.

### Deployment

CircleCI automatically deploys the website when changes are merged to master. It takes about 30 seconds to deploy.

* [luanova.org.s3-website-us-east-1.amazonaws.com](http://luanova.org.s3-website-us-east-1.amazonaws.com/) is the website endpoint on Amazon S3.
* [luanova.org](https://luanova.org/) is cached by CloudFlare.

### License

See LICENSE.
