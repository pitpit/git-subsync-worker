Git Subsync Worker
==================

An iron worker (iron.io) to sync a subtree split from a git repository to another one.

Installation
------------

* Sinup on (Iron IO)[http://iron.io] and create a new project

* (Install Iron CLI)[http://dev.iron.io/worker/reference/cli/#installing]

* dowload `iron.json` iton root directory to allow iron CLI to access your project

> In the top right of the dashboard, click on the key icon then click on "Download json file"

* copy `config.json.sample` to `config.json` and edit it according to your needs

* test the worker locally:

    iron_worker run git-subsync.worker -p '{"dry-run":true}'