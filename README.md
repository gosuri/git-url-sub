# git-url-sub

Recursively substitute remote URLs for multiple repositories. Will not commit changes by default, run with -c option to commit changes

## Installation (homebrew)

    brew install git-url-sub

## Installation (source)

    git clone git://github.com/gosuri/git-url-sub.git
    cd git-url-sub
    sudo make install

## Usage

    git-url-sub [cs] <pattern> <replacement>

    OPTIONS

    -c: Commit changes
    -s: Silently executes

## Example:

Replace first occurance of 'foo' in the remote url with 'bar'

    $ git url-sub foo bar

    git@github.com:foo/myproject.git -> git@github.com:bar/myproject.git


## More help
------------
Man pages at (http://gregosuri.com/git-url-sub)

    git url-sub help

## License

git-url-sub is copyright (C) 2011 [Greg Osuri](http://gregosuri.com)<br>
See the file [LICENSE](http://github.com/gosuri/git-url-sub/master/LICENSE) for information of licensing and distribution.

