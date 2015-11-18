Nix image for Docker
====================

Executing software from Nixpkgs:

    $ docker --rm -ti datakurre/nix nix-shell -p python3 --run python

Creating local shared nix cache:

    $ docker create -v /nix --name=nix datakurre/nix sh

Using the local shared nix cache:

    $ docker --rm --volumes-from=nix -ti datakurre/nix nix-shell -p python3 --run python
