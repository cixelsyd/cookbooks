Description
===========

https://github.com/cixelsyd/cookbooks/tree/master/nephele

Nephele, the Greek cloud nymph, contains some basic utilities for working with cloud services.  At the moment, the only implemented item is a library that will sync a local directory with an S3 bucket.  This is still very much a work in progress, and functionality is extremely limited.

Requirements
============

The Nephele cookbook for linux requires the build-essentials cookbook due to the fog gem.

Attributes
==========

Attributes are used to refer to an encrypted data bag that hold Amazon access information.

Usage
=====

Adding the Nephele cookbook to your runlist will install the fog gem.  From there, check out s3syncexample for details.