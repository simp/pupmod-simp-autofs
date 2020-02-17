[![License](https://img.shields.io/:license-apache-blue.svg)](http://www.apache.org/licenses/LICENSE-2.0.html)
[![CII Best Practices](https://bestpractices.coreinfrastructure.org/projects/73/badge)](https://bestpractices.coreinfrastructure.org/projects/73)
[![Puppet Forge](https://img.shields.io/puppetforge/v/simp/autofs.svg)](https://forge.puppetlabs.com/simp/autofs)
[![Puppet Forge Downloads](https://img.shields.io/puppetforge/dt/simp/autofs.svg)](https://forge.puppetlabs.com/simp/autofs)
[![Build Status](https://travis-ci.org/simp/pupmod-simp-autofs.svg)](https://travis-ci.org/simp/pupmod-simp-autofs)


#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with simp](#setup)
    * [What simp affects](#what-simp-affects)
4. [Usage - Configuration options and additional functionality](#usage)
    * [Basic Usage](#basic-usage)
    * [SIMP Scenarios](#simp-scenarios)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)
      * [Acceptance Tests - Beaker env variables](#acceptance-tests)

## Overview
Autofs is a module to mount any filesystem on demand. It will automatically mount the filesystem
and will also automatically unmount a filesystem if it has not been used for a predetermined timeout.


## This is a SIMP module
This module is a component of the [System Integrity Management Platform](https://simp-project.com)

If you find any issues, please submit them via [JIRA](https://simp-project.atlassian.net/).

Please read our [Contribution Guide](https://simp.readthedocs.io/en/stable/contributors_guide/index.html).


## Module Description

This module provides a convenient entry point for setting up systems for the 
autofs module in a SIMP environment.


## Setup


## Reference

See the [REFERENCE.md][reference_md] for a comprehensive overview of the module
components.

## Usage

### Basic Usage

See [module documentation][reference_md] for full details.

[reference_md]: https://github.com/simp/pupmod-autofs/blob/master/REFERENCE.md


## Development

Please read our [Contribution Guide](https://simp.readthedocs.io/en/stable/contributors_guide/index.html).

### Unit tests

Unit tests, written in ``rspec-puppet`` can be run by calling:

```shell
bundle exec rake spec
```

### Acceptance tests

To run the system tests, you need [Vagrant](https://www.vagrantup.com/) installed. Then, run:

```shell
bundle exec rake beaker:suites
```

To run the system compliance tests, you need [Vagrant](https://www.vagrantup.com/) installed. Then, run:

```shell
bundle exec rake beaker:suites[compliance]
```


Some environment variables may be useful:

```shell
BEAKER_debug=true
BEAKER_provision=no
BEAKER_destroy=no
BEAKER_use_fixtures_dir_for_modules=yes
```

* `BEAKER_debug`: show the commands being run on the STU and their output.
* `BEAKER_destroy=no`: prevent the machine destruction after the tests finish so you can inspect the state.
* `BEAKER_provision=no`: prevent the machine from being recreated. This can save a lot of time while you're writing the tests.
* `BEAKER_use_fixtures_dir_for_modules=yes`: cause all module dependencies to be loaded from the `spec/fixtures/modules` directory, based on the contents of `.fixtures.yml`.  The contents of this directory are usually populated by `bundle exec rake spec_prep`.  This can be used to run acceptance tests to run on isolated networks.

