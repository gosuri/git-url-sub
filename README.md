# git-sub

substitution utility for git

## Installation

    git clone git@github.com:gosuri/git-sub.git
    cd git-sub
    make
    sudo make install


## Usage

    git sub <subcommand>

## Subcommands

### url

Recursively substitute remote URLs for multiple repositories. Will not commit changes by default, run with -c option to commit changes

#### Example:

Replace all occurances of 'foo' in the remote url with 'bar'

    $ git sub url foo bar

    git@github.com:foo/myproject.git -> git@github.com:bar/myproject.git



## More help
------------
Man pages at (http://gregosuri.com/git-sub)

    git sub help
    git sub <subcommand> help

## License

git-sub is Copyright (C) 2011 [Greg Osuri](http://gregosuri.com)<br>
See the file [LICENSE](http://github.com/gosuri/git-sub/master/LICENSE) for information of licensing and distribution.

