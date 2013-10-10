Git Subsync Worker
==================

An iron worker (iron.io) to sync a subtree split from a git repository to another one.

Installation
------------

* Sinup on [Iron IO](http://iron.io) and create a new project

* [Install Iron CLI](http://dev.iron.io/worker/reference/cli/#installing)

* dowload `iron.json` into root directory to allow iron CLI to access your project

> In the top right of the dashboard, click on the key icon then click on "Download json file"

* copy `config.json.sample` to `config.json` and edit it according to your needs

> for now, the worker does not support public key negociation over ssh, so you need to use the HTTP URL of your repository with credentials in it. For instance: `https://username:password@github.com/username/dest-repo.git`

* test the worker locally:

```
iron_worker run git-subsync.worker -p '{"dry-run":true}'
```

* upload the worker:

```
iron_worker upload git-subsync.worker
```

Schedule or Webhook
-------------------

...

Build the deb package
---------------------

Actual version of git-core on iron VM (v1.7.9.3 on Ubuntu Linux 12.04 x64) doesn't support "subtree" command.
So we need to build a deb package to add the original git-subtree script (https://github.com/apenwarr/git-subtree/tree/master)

    sudo dpkg-deb --build git-subtree

