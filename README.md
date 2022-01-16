WebService::HashiCorp::Vault
============================

WebService::HashiCorp::Vault is a first attempt at creating a pure Perl 6
implementation of an API wrapper for the excellent Vault secrets system
from Hashicorp.

Requirements
============

Rakudo Perl 6 (v6.d).

Installation
============

Documentation TBD

What's it for?
==============

This can be used to programmatically retrieve secrets and other metadata
stored in a Hashicorp Vault instance.

Examples
========

    use v6;
	use WebService::HashiCorp::Vault
    my $p = Client.new(token => 'some.vault.token');
    my $n = $p.getSecret(vault => "cubbyhole", key => "foo");
    say $n.v;   #prints the value of the key at 'cubbyhole/foo'

Future
======

This is very much alpha quality code. You shouldn't use it in
a production setting.

Testing
=======

Not yet. Soon!

License and Author
==================

Copyright (c) 2022  Dean Powell
