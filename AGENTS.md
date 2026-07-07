# AGENTS.md

This file provides guidance to AI agents when working with code in this repository.

## What this module does

`pupmod-simp-autofs` is a SIMP Puppet module that installs, configures, and runs
the Linux **automounter** (`autofs`) on Enterprise Linux systems. It manages the
global daemon configuration (`/etc/autofs.conf`, `/etc/sysconfig/autofs`), the
master map (`/etc/auto.master`), and provides a set of resources for declaring
autofs **master entries** and their corresponding **map files** — including
optional LDAP-backed maps with SIMP PKI-managed client certificates.

The module is data-driven: a site can define all of its `file`-type maps as a
single `autofs::maps` hiera hash and the module will generate the master entry
files and map files for them.

### Business logic

The module is organized as a main class that fans out to private
install/config/service classes, plus a set of `define`d types that create the
individual master-entry and map files.

**`autofs` (`manifests/init.pp`)** — the public entry point.

- Exposes the full `/etc/autofs.conf` `[autofs]`-section surface as parameters
  (`timeout`, `browse_mode`, `logging`, `mount_nfs_default_protocol`, the LDAP
  lookup settings, `custom_autofs_conf_options` for unmanaged keys, etc.) plus
  `/etc/sysconfig/autofs` settings (`automount_use_misc_device`,
  `automount_options`).
- Defines the SIMP-managed directories: `master_conf_dir`
  (default `/etc/auto.master.simp.d`) and `maps_dir`
  (default `/etc/autofs.maps.simp.d`).
- `maps` (`Hash[String, Autofs::Mapspec]`, default `{}`) — the data-driven map
  specification; each entry becomes an `autofs::map`.
- Follows the standard SIMP pattern of resolving site-wide policy through
  `simplib::lookup`: `autofs_package_ensure`/`samba_package_ensure` default to
  `simp_options::package_ensure`, `ldap` to `simp_options::ldap`, and `pki` to
  `simp_options::pki`.
- `include`s `autofs::install`, `autofs::config`, and `autofs::service`, wiring
  the ordering `Install -> Config ~> Service`.

**`autofs::install` (`manifests/install.pp`, private)** — installs the `autofs`
package and `samba-client` (installed `before` `autofs`), each honoring its
`*_package_ensure` parameter.

**`autofs::config` (`manifests/config.pp`, private)** — the heart of the module:

- Renders `/etc/autofs.conf`, `/etc/sysconfig/autofs`, and `/etc/auto.master`
  from EPP templates.
- Creates `master_conf_dir` and `maps_dir` as **`recurse => true, purge => true`**
  directories — meaning any file in them that Puppet does not manage is removed.
  `master_conf_dir` is given `seltype => 'etc_t'` to match `/etc/auto.master.d`.
- If `$autofs::ldap` is true, `contain`s `autofs::ldap_auth`.
- Iterates `$autofs::maps` and declares an `autofs::map` for each entry.

**`autofs::service` (`manifests/service.pp`)** — keeps the `autofs` service
`running`/`enabled`, and defines the `Exec['autofs_reload']`
(`systemctl reload autofs`, `refreshonly`) that map resources notify when a
reload (not a full restart) is sufficient. `Service['autofs'] -> Exec['autofs_reload']`.

**Map resources** — the three current primitives (all sanitize `$name`,
replacing whitespace and `/` with `__` to form safe filenames):

- **`autofs::map` (`manifests/map.pp`, define)** — the convenience wrapper.
  Creates a matched `autofs::masterfile` + `autofs::mapfile` pair for a `file`
  map (`sun` format), ordered `Mapfile -> Masterfile`.
- **`autofs::masterfile` (`manifests/masterfile.pp`, define)** — writes one
  `${name}.autofs` entry into `master_conf_dir`. Validates that `$map` is an
  absolute path when `map_type` is `file`/`program`/unspecified. Always
  `notify`s `Exec['autofs_reload']`.
- **`autofs::mapfile` (`manifests/mapfile.pp`, define)** — writes one
  `${name}.map` into `maps_dir`. **Only direct maps** (`Autofs::Directmapping`)
  notify `Exec['autofs_reload']`, because indirect map changes are picked up
  without a reload — this conditional notify is the key correctness detail.

**`autofs::ldap_auth` (`manifests/ldap_auth.pp`, private)** — writes
`/etc/autofs_ldap_auth.conf` (`0600`). When `authtype` is `EXTERNAL` (client-cert
auth), it `contain`s `autofs::config::pki`.

**`autofs::config::pki` (`manifests/config/pki.pp`, private)** — when
`$autofs::pki` is truthy, uses `pki::copy` to install the autofs client cert/key
under `/etc/pki/simp_apps/autofs/x509`.

**Deprecated** — `autofs::map::entry` (`manifests/map/entry.pp`) and
`autofs::map::master` (`manifests/map/master.pp`) are `concat`-based
predecessors kept for backward compatibility; both emit a `deprecation()`
warning and should be replaced with `autofs::mapfile` / `autofs::masterfile` /
`autofs::map`. `autofs::map::entry` is what pulls in the **optional**
`puppetlabs/concat` dependency (guarded by `simplib::assert_optional_dependency`).

### Direct vs. indirect maps (domain concepts)

- A **direct** map uses `mount_point => '/-'` and a single `Autofs::Directmapping`
  hash (`key` is an absolute path). Changes require an autofs reload.
- An **indirect** map uses a real path `mount_point` (e.g. `/home`) and an
  **array** of `Autofs::Indirectmapping` hashes (`key` is a relative name, `*`
  wildcard and `&` substitution supported). Changes do not require a reload.

The `Autofs::Mapspec`, `Autofs::Directmapping`, `Autofs::Indirectmapping`,
`Autofs::Maptype`, `Autofs::Logging`, and `Autofs::Authtype` type aliases in
`types/` enforce these shapes.

## Dependencies

- `puppetlabs/stdlib` (`>= 8.0.0 < 10.0.0`).
- `simp/simplib` (`>= 4.9.0 < 5.0.0`) — provides `simplib::lookup`,
  `simplib::assert_optional_dependency`, and the `Simplib::*` types.
- `puppetlabs/concat` (`>= 6.4.0 < 10.0.0`) — **optional**; only needed by the
  deprecated `autofs::map::entry`.
- Runtime: `puppet >= 7.0.0 < 9.0.0` (see `metadata.json` `requirements`).
- Supported OS: EL7/8/9 across RedHat/CentOS/OracleLinux and EL8/9 for
  Rocky/AlmaLinux (see `metadata.json`).

## Repository layout

- `manifests/init.pp` — public `autofs` class (all global config parameters).
- `manifests/{install,config,service}.pp` — private install/config/service classes.
- `manifests/{map,masterfile,mapfile}.pp` — current map/master-entry defines.
- `manifests/map/{entry,master}.pp` — **deprecated** concat-based defines.
- `manifests/ldap_auth.pp`, `manifests/config/pki.pp` — LDAP auth + PKI (private).
- `templates/etc/**.epp` — EPP templates for `autofs.conf`, `sysconfig/autofs`,
  `auto.master`, master-entry files, and map files.
- `types/*.pp` — `Autofs::*` type aliases.
- `spec/classes/`, `spec/defines/` — rspec-puppet unit tests.
- `spec/acceptance/suites/default/` — beaker acceptance suite; `nodesets/` holds
  the per-OS node definitions.
- `REFERENCE.md` — generated Puppet Strings reference (do not hand-edit; regenerate).
- `metadata.json` — module metadata, dependencies, and supported OS matrix.

## Common commands

This module uses `puppetlabs_spec_helper` + `simp-rake-helpers (~> 5)` +
`simp-beaker-helpers (~> 2)`; tasks come from `Simp::Rake::Pupmod::Helpers`
(see `Rakefile`).

```sh
bundle install

# Unit tests (rspec-puppet)
bundle exec rake spec

# A single spec file
bundle exec rspec spec/defines/mapfile_spec.rb

# Lint / style
bundle exec rake lint
bundle exec rake rubocop

# Regenerate REFERENCE.md after changing manifest docstrings
bundle exec puppet strings generate --format markdown --out REFERENCE.md

# Acceptance tests (beaker; needs a hypervisor — CI uses vagrant_libvirt)
bundle exec rake beaker:suites[default]
```

## Conventions

- This is a component of the SIMP ecosystem. Follow SIMP module conventions:
  parameters that reflect site-wide policy are resolved through `simp_options::*`
  hiera keys via `simplib::lookup`, defaulting to safe values so the module works
  standalone.
- Prefer the data-driven path: add `file` maps to the `autofs::maps` hash rather
  than declaring `autofs::map` resources directly, and prefer
  `autofs::map`/`autofs::mapfile`/`autofs::masterfile` over the deprecated
  `autofs::map::entry` / `autofs::map::master`.
- Remember the reload semantics: a **direct**-map map file change must notify
  `Exec['autofs_reload']`; indirect maps must not need it. Preserve the
  conditional `notify` in `autofs::mapfile` when editing.
- `master_conf_dir` and `maps_dir` are purged — do not expect unmanaged files
  placed there to survive a Puppet run.
- Keep manifest parameter `@param` docstrings current — `REFERENCE.md` is
  generated from them.
