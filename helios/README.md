Description
===========

The Greek god of the sun, Helios, was responsible for turning darkness into light.  In a similar fashion, SSL Certificates are designed to bring the bright light of verified identity to the darkest corners of the internet.  Unfortunately, they can also be a PIA to manage.

Helios is designed to download certificates from remote URLs and import them into the appropriate Windows Certificate Store.

** NO SSL CERTIFICATE VERIFICATION PERFORMED **

Helios is simply a retreval-and-deployment tool, not any type of trust-verification engine.  If you point it at a valid certfile file, it will import it and your machine will begin trusting.  BE CAREFUL.

Requirements
============

Windows OS, powershell cookbook (which requires windows cookbook, which requires chef_handler cookbook)


Attributes
==========

[:helios][:ca] is an array of hashes, one per certificate authority name, listing the types of certificates to retrieve and install.  [:helios][:{root,intermediate}][:name] is a hash of filenames and url locations to download the certs from.  It would be simple enough to change this construction into a data bag lookup.

Usage
=====

Add your relevant 3rdparty cert providers to the [:ca] array, and then add their various certificate types.

This cookbook has been tested and verified working on Windows 2003 i386, Windows 2008 i386, and Windows 2008 R2 x86_64