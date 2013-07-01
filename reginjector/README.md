Description
===========

It is a straightforward exercise to manage windows registry changes by either exporting or just writing out the registry changes to templates and then using a batch file wrapper around regedit to inject them into the registry.  Updates to the registry files will cause them to be reinjected.  Batch file was necessary for early versions of chef and windows; later versions of chef and windows work calling regedit directly.

Requirements
============

This cookbook does not have any other dependencies than regedit.  It should work on all versions of windows, without exception.

Attributes
==========

Minimal.  I deploy a small number of registry changes across the board, and they are stored in an attribute array on the nodes.

Usage
=====

Add the default recipe to your run_list.  Add appropriately formatted .reg files to the templates directory, and then update the payload array to deploy them.
