python-command-step-plugin
------

This directory contains an example script-based Remote Script Node Step Plugin.

Build
====

    make

produces:

    python-command-step-plugin.zip

Files
=====

`python-command-step-plugin/plugin.yaml`

:   Defines the metadata for the plugin

`python-command-step-plugin/contents/`

:   directory containing necessary scripts or assets

`python-command-step-plugin/contents/nodestep.sh`

:   the script defined in plugin.yaml to be executed for the plugin


Plugin metadata
=====

The `plugin.yaml` file declares one script based service provider for the `RemoteScriptNodeStep` service.

Usage
=====

Install the plugin in your `$RDECK_BASE/libext` directory:

    mv python-command-step-plugin.zip $RDECK_BASE/libext
