Description
===========

Oftentimes it is helpful for your servers to create and post their own documentation.  In Operations, it is important that we focus on publishing information in a timely, organized, and appropriate fashion.  Of necessity, a good Operations team has multiple tools. Unfortunately, the multiplicity of tools can result in information fragmentation and difficulty in providing a single location for Developers and collegues to go for answers to common questions.  Additionally, it is often sub-optimal to give access to a particular toolset simply to provide log or status information.

Tasks such as updating tickets when build artifacts have been generated, self-generated wikipages, or even posting drive fragmentation status are all basic tasks that servers should be able to do themselves.  This is a basic attempt at enabling machines to interact with a Trac system for the specific purposes listed above... As well as others. 

Requirements
============

Trac: http://trac.edgewall.org/  Duh.  And, yeah, I know it's 2012 and I'm still using Trac.  Still havent found anything more simple and straightforward for a small organization that uses Subversion for their version control system.  Install the Trac xml-rpc (http://trac-hacks.org/wiki/XmlRpcPlugin) plugin and then ensure your trac user has permissions appropriate to the type of Trac-interaction the servers will be performing... My "notuser" account has TICKET_ADMIN, WIKI_ADMIN, and XML_RPC.

Attributes
==========

The bulk of the attributes point at an encrypted databag for Trac authentication information.

Usage
=====

See:

	ticketattach_example.rb
	wikicreate_example.rb

I am aware that this cookbook wields the Trac xml-rpc "delete" method like it's going out of style.  However, using straightup 'update' throws errors that I'm not currently willing to dig into.  Running this cookbook on some of my Linux servers has resulted in Cert errors; again, I do not currently have the time to dig into those.  It runs successfully on some of my machines.
