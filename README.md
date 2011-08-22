git-sub
=======

substitution utility for git

Installation
------------

		git clone git@github.com:gosuri/git-sub.git
		cd git-sub
		make
		sudo make install


Basic Usage
-----------

		git sub <subcommand>

*Subcommands*

url -  will recursively substitute remote URLs for multiple repositories.

Example:

		git sub url git@github.com:gosuri/git-sub.git git@github.com:gridbag/git-sub.git


More help
---------
		git sub help
		git sub <subcommand> help
