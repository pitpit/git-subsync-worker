Git Subsync Worker
==================

An iron worker (iron.io) to sync a subtree split from a git repository to another one.


Installation
------------

* copy `config.json.sample` to `config.json` and edit it according to your needs

* test the worker locally

     iron_worker run git-subsync.worker -p '{"dry-run":true}'