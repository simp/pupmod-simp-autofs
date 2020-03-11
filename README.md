[![License](https://img.shields.io/:license-apache-blue.svg)](http://www.apache.org/licenses/LICENSE-2.0.html)
[![CII Best Practices](https://bestpractices.coreinfrastructure.org/projects/73/badge)](https://bestpractices.coreinfrastructure.org/projects/73)
[![Puppet Forge](https://img.shields.io/puppetforge/v/simp/autofs.svg)](https://forge.puppetlabs.com/simp/autofs)
[![Puppet Forge Downloads](https://img.shields.io/puppetforge/dt/simp/autofs.svg)](https://forge.puppetlabs.com/simp/autofs)
[![Build Status](https://travis-ci.org/simp/pupmod-simp-autofs.svg)](https://travis-ci.org/simp/pupmod-simp-autofs)


#### Table of Contents

* [Description](#description)
  * [This is a SIMP module](#this-is-a-simp-module)
* [Setup](#setup)
    * [What autofs affects](#what-autofs-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with autofs](#beginning-with-autofs)
* [Usage](#usage)
    * [Basic Usage](#basic-usage)
* [Reference](#reference)
* [Limitations](#limitations)
* [Development - Guide for contributing to the module](#development)

## Description

This is a module for managing fileystem automounting using autofs.

## This is a SIMP module

This module is a component of the [System Integrity Management Platform](https://simp-project.com),
a compliance-management framework built on Puppet.

If you find any issues, please submit them via [JIRA](https://simp-project.atlassian.net/).

This module is optimally designed for use within a larger SIMP ecosystem, but
it can be used independently:

 * When included within the SIMP ecosystem, security compliance settings will
   be managed from the Puppet server.
 * If used independently, all SIMP-managed security subsystems are disabled by
   default and must be explicitly opted into by administrators.  See the
   [SIMP `simp_options` module](https://github.com/simp/pupmod-simp-simp_options)
   for more detail.

## Setup

### What autofs affects

The `autofs` module installs autofs packages, configures the autofs service,
and manages all autofs configuration files.

It does not manage NFS, but seamlessly interoperates with the
[SIMP `nfs` module](https://github.com/simp/pupmod-simp-nfs), which does manage
NFS.

### Setup Requirements

The only requirement is to include the `autofs` module and its dependencies
in your modulepath.

### Beginning with autofs

You can use the `autofs` module to manage general `autofs` configuration files,
as well as `auto.master` entry files and map files.

#### Managing general configuration files

The `autofs` module manages the following general configuration files:

* `/etc/autofs.conf`
* `/etc/autofs/sysconfig/autofs`
* `/etc/auto.master`
* `/etc/autofs_ldap_auth.conf`

To configure the first three files, simply include `autofs` or one of this
module's defines in a node's manifest and then set the appropriate
configuration values from the `autofs` class via Hieradata.

* The managed `/etc/auto.master` file only allows configuration of included
  directories with one or more `+dir` directives.  All other auto.master
  entries must reside in one or more `*.autofs` files in one of the included
  directories.

To configure the third file:

* Include `autofs` or one of this module's defines in a node's manifest.
* Set the `autofs::ldap` parameter to `true` in Hieradata, along with any of the
  other LDAP-related parameters in the `autofs` class, as appropriate. This will
  ensure

  * `/etc/autofs.conf` is configured to load the appropriate LDAP authentication
    configuration file.
  * The `autofs::ldap_auth` class that manages that file is included in the
    node's manifest.

* Configure the LDAP-authentication-specific parameters of the
  `autofs::ldap_auth` class in Heiradata.

#### Managing automount maps

You can configure the automount map configuration via the `$autofs::maps`
parameter, or by including `autofs::map`, `autofs::masterfile`, and/or
`autofs::mapfile` defines in your node's manifest. By default these will
create auto.master entry files in `/etc/auto.master.simp.d` and map files in
`/etc/autofs.maps.simp.d`. Both directories are fully managed by the `autofs`
module. This means any files in those directories that are not managed by a
Puppet resource will be purged.

## Usage

### Basic Usage

#### Configuring auto.master entries and maps from hieradata

The `autofs` class provides a simple mechanism to configure 'file' type maps
in hieradata.  Via the `$autofs::map` parameter, you can configure any number
of direct or indirect 'file' maps.  For example,

``` yaml
autofs::maps:
  # direct mount
  data:
    mount_point: "/-"
    mappings:
      # mappings is a single Hash for direct maps
      key:      "/net/data"
      options:  "-fstype=nfs,soft,nfsvers=4,ro"
      location: "nfs.example.com:/exports/data"

  # indirect mount with wildcard key and key substitution
  home:
    mount_point:    "/home"
    master_options: "strictexpire --strict"
    mappings:
      # mappings is an Array for indirect maps
      - key:      "*"
        options:  "-fstype=nfs,soft,nfsvers=4,rw"
        location: "nfs.example.com:/exports/home/&"

  # indirect mount with multiple, explicit keys
  apps:
    mount_point: "/net/apps"
    mappings:
      - key:      "v1"
        options:  "-fstype=nfs,soft,nfsvers=4,ro"
        location: "nfs.example.com:/exports/apps1"
      - key:      "v2"
        options:  "-fstype=nfs,soft,nfsvers=4,ro"
        location: "nfs.example.com:/exports/apps2"
      - key:      "latest"
        options:  "-fstype=nfs,soft,nfsvers=4,ro"
        location: "nfs.example.com:/exports/apps3"
```

This would create 3 auto.master entry files and 3 corresponding map files:

* `/etc/auto.master.simp.d/data.autofs`: Direct map auto.master entry
  that references the `/etc/autofs.simp.maps.d/data.map` map file.

  ```
    /-  /etc/autofs.maps.simp.d/data.map
  ```

* `/etc/auto.master.simp.d/home.autofs`: Indirect map auto.master entry
  that references the `/etc/autofs.simp.maps.d/home.map` map file.

  ```
    /home  /etc/autofs.maps.simp.d/home.map
  ```

* `/etc/auto.master.simp.d/auto.autofs`: Indirect map auto.master entry
  that references the `/etc/autofs.simp.maps.d/apps.map` map file.

  ```
    /net/apps  /etc/autofs.maps.simp.d/apps.map
  ```

* `/etc/autofs.maps.simp.d/data.map`: Direct map.

  ```
    /net/data  -fstype=nfs,soft,nfsvers=4,ro  nfs.example.com:/exports/data

  ```

* `/etc/autofs.maps.simp.d/home.map`: Indirect map with wildcard key.

  ```
    *  -fstype=nfs,soft,nfsvers=4,rw  nfs.example.com:/exports/home/&
  ```

* `/etc/autofs.maps.simp.d/auto.map`: Indirect map with multiple keys.

  ```
    v1  -fstype=nfs,soft,nfsvers=4,ro  nfs.example.com:/exports/apps1
    v2  -fstype=nfs,soft,nfsvers=4,ro  nfs.example.com:/exports/apps2
    latest  -fstype=nfs,soft,nfsvers=4,ro  nfs.example.com:/exports/apps3
  ```

#### Configuring auto.master entries

To configure just an auto.master entry file, use the `autofs::masterfile`
define.  For example,

* To create an autofs master entry file for a direct 'file' map

  ```
    autofs::masterfile { 'data':
      mount_point => '/-',
      map         => '/etc/autofs.maps.simp.d/data'
    }
   ```

* To create an autofs master entry file for an indirect 'file' map

  ```
    autofs::masterfile { 'home':
      mount_point => '/home',
      map         => '/etc/autofs.maps.simp.d/home'
    }
  ```

* To create an autofs master entry file for a 'program' map

  ```
    autofs::masterfile { 'nfs4':
      mount_point => '/nfs4',
      map_type    => 'program',
      map         => '/usr/sbin/fedfs-map-nfs4',
      options     => 'nobind'
    }

  ```

* To create an autofs master entry file for a 'ldap' map with a pre-configured
  LDAP server

  ```
    autofs::masterfile { 'home':
      mount_point => '/home',
      map_type    => 'ldap',
      map         => 'ou=auto.indirect,dc=example,dc=com'
    }
  ```

#### Configuring map files

To configure just a map file, use the `autofs::mapfile` define.  For
example,

* To create an autofs map file for a direct map

  ```
    autofs::mapfile {'data':
      mappings => {
        'key'      => '/net/data',
        'options'  => '-fstype=nfs,soft,nfsvers=4,ro',
        'location' => '1.2.3.4:/exports/data'
      }
    }
  ```

* To create an autofs map file for an indirect map with wildcard key

  ```
    autofs::mapfile { 'home':
      mappings => [
        {
          'key'      => '*',
          'options'  => '-fstype=nfs,soft,nfsvers=4,rw',
          'location' => '1.2.3.4:/exports/home/&'
        }
      ]
    }
  ```

* To create an autofs map file for an indirect map with mutiple keys

  ```
    autofs::mapfile { 'apps':
      mappings => [
        {
          'key'      => 'v1',
          'options'  => '-fstype=nfs,soft,nfsvers=4,rw',
          'location' => '1.2.3.4:/exports/apps1'
        },
        {
          'key'      => 'v2',
          'options'  => '-fstype=nfs,soft,nfsvers=4,rw',
          'location' => '1.2.3.4:/exports/apps2'
        },
        {
          'key'      => 'latest',
          'options'  => '-fstype=nfs,soft,nfsvers=4,rw',
          'location' => '1.2.3.5:/exports/apps3'
        }
      ]
    }
  ```

#### Configuring auto.master entry + map file pairs

To configure an auto.master entry file and its corresponding map file, use the
`autofs::map` define.  For example,

* To create an autofs master and map files for a direct map

  ```
    autofs::map {'data':
      mount_point => '/-',
      mappings    => {
        'key'      => '/net/data',
        'options'  => '-fstype=nfs,soft,nfsvers=4,ro',
        'location' => '1.2.3.4:/exports/data'
      }
    }
  ```

* To create an autofs master and map files for an indirect map with the
  wildcard key

  ```
    autofs::map { 'home':
      mount_point    => '/home',
      master_options => 'strictexpire',
      mappings       => [
        {
          'key'      => '*',
          'options'  => '-fstype=nfs,soft,nfsvers=4,rw',
          'location' => '1.2.3.4:/exports/home/&'
        }
      ]
    }
  ```

* To create an autofs master and map files for an indirect map with multiple keys

  ```
    autofs::map { 'apps':
      mount_point => '/apps',
      mappings    => [
        {
          'key'      => 'v1',
          'options'  => '-fstype=nfs,soft,nfsvers=4,rw',
          'location' => '1.2.3.4:/exports/apps1'
        },
        {
          'key'      => 'v2',
          'options'  => '-fstype=nfs,soft,nfsvers=4,rw',
          'location' => '1.2.3.4:/exports/apps2'
        },
        {
          'key'      => 'latest',
          'options'  => '-fstype=nfs,soft,nfsvers=4,rw',
          'location' => '1.2.3.5:/exports/apps3'
        }
      ]
    }
  ```

## Reference

Please refer to the [REFERENCE.md](./REFERENCE.md).

## Limitations

* This module does not support `amd` configuration.

  * The `am-utils` service has been removed from Red Hat Enterprise Linux 8,
    and the support tail for `amd` configuration is unclear.

* This module has no direct support for creating hesiod-formatted map files.

  * You can use a `file` resource to manage a hesiod-formatted map file. Just
    make sure all of your custom map files that contain a direct map notify
    the `Exec['autofs_reload']` resource.

* This module does not manage program executables that may be referenced in an
  auto.master entry.

  * You can use a `file` resource to manage a program executable.

SIMP Puppet modules are generally intended for use on Red Hat Enterprise Linux
and compatible distributions, such as CentOS. Please see the [`metadata.json` file](./metadata.json)
for the most up-to-date list of supported operating systems, Puppet versions,
and module dependencies.

## Development

Please read our [Contribution Guide](https://simp.readthedocs.io/en/stable/contributors_guide/index.html).

### Unit tests

Unit tests, written in ``rspec-puppet`` can be run by calling:

```shell
bundle install
bundle exec rake spec
```

### Acceptance tests

This module includes [Beaker](https://github.com/puppetlabs/beaker) acceptance
tests using the SIMP [Beaker Helpers](https://github.com/simp/rubygem-simp-beaker-helpers).
By default the tests use [Vagrant](https://www.vagrantup.com/) with
[VirtualBox](https://www.virtualbox.org) as a back-end; Vagrant and VirtualBox
must both be installed to run these tests without modification. To execute the
tests run the following:

```shell
bundle install
bundle exec rake beaker:suites
```

Please refer to the [SIMP Beaker Helpers documentation](https://github.com/simp/rubygem-simp-beaker-helpers/blob/master/README.md) for more information.
