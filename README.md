Git Subsync Worker
==================

An iron worker (http://iron.io) to sync a subtree split of a git repository to another one.

Installation
------------

* Signup on [Iron IO](http://iron.io) and create a new project

* [Install Iron CLI](http://dev.iron.io/worker/reference/cli/#installing)

* Dowload `iron.json` into root directory to allow iron CLI to access your project

> In the top right of the dashboard, click on the key icon then click on "Download json file"

* Copy `config.json.sample` to `config.json` and edit it according to your needs

* Generate SSH keys if needed to connect to your repositories

```
ssh-keygen -t rsa -C "sync-workers" -f ssh/id_rsa
```

* Add the public key content to your github account (https://github.com/settings/ssh)

* Upload the worker:

```
iron_worker upload git-subsync.worker
```

Sync everything
---------------

Queue a task to synchronize every subtrees:

    iron_worker queue git-subsync

Github Webhook
--------------

If you want to sync subtree on commit:

    iron_worker webhook git-subsync

And copy-paste the URL into Github: "Your Repository" > "Settings" > "Services Hooks" > "WebHook URLs"


Build the deb package (for dev)
-------------------------------

Current version of git-core on iron VM (v1.7.9.3 on Ubuntu Linux 12.04 x64) doesn't support "subtree" command.
So we need to build a deb package to add the original git-subtree script (https://github.com/apenwarr/git-subtree/tree/master) to iron worker.

    sudo dpkg-deb --build git-subtree



[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/pitpit/git-subsync-worker/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

