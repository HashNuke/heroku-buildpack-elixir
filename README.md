# Heroku Buildpack for Elixir

## Features

* **Easy configuration** with `elixir_buildpack.config` file
* Use **prebuilt Elixir binaries**
* Allows configuring Erlang
* If your app doesn't have a Procfile, default web task `mix run --no-halt` will be run.
* Consolidates protocols
* Hex and rebar support
* Caching of Hex packages, Mix dependencies and downloads
* Compilation procedure hooks through `hook_pre_compile`, `hook_compile`, `hook_post_compile` configuration

#### Version support

* Erlang - Prebuilt packages (17.5, 17.4, etc)
  * The full list of prebuilt packages can be found here: 
    * gigalixir-20 or heroku-20 stacks: https://builds.hex.pm/builds/otp/ubuntu-20.04/builds.txt
    * gigalixir-22 or heroku-22 stacks: https://builds.hex.pm/builds/otp/ubuntu-22.04/builds.txt
    * gigalixir-24 or heroku-24 stacks: https://builds.hex.pm/builds/otp/ubuntu-24.04/builds.txt
    * All other stacks: https://github.com/HashNuke/heroku-buildpack-elixir-otp-builds/blob/master/otp-versions
* Elixir - Prebuilt releases (1.0.4, 1.0.3, etc) or prebuilt branches (master, v1.7, etc)
  * The full list of releases can be found here: https://github.com/elixir-lang/elixir/releases
  * The full list of branches can be found here: https://github.com/elixir-lang/elixir/branches

Note: you should choose an Elixir and Erlang version that are [compatible with one another](https://hexdocs.pm/elixir/compatibility-and-deprecations.html#compatibility-between-elixir-and-erlang-otp).

#### Cloud Native Support

* Cloud Native users should use [this buildpack](https://github.com/elixir-buildpack/cloud-native-buildpack)

**This buildpack is not guaranteed to be Cloud Native compatible.** 
The [elixir-buildpack/cloud-native-buildpack](https://github.com/elixir-buildpack/cloud-native-buildpack) is a buildpack that is actively under development
and is designed specifically to follow the Cloud Native Buildpack conventions.

## Usage

#### Create a Heroku app with this buildpack

```
heroku create --buildpack hashnuke/elixir
```

#### Set the buildpack for an existing Heroku app

```
heroku buildpacks:set hashnuke/elixir
```

#### Use the edge version of buildpack

The `hashnuke/elixir` buildpack contains the latest published version of the buildpack, but you can use the edge version (i.e. the source code in this repo) by running:

```
heroku buildpacks:set https://github.com/HashNuke/heroku-buildpack-elixir.git
```

When you decide to use the published or the edge version of the buildpack you should be aware that, although we attempt to maintain the buildpack for as many old Elixir and Erlang releases as possible, it is sometimes difficult since there's a matrix of 3 variables involved: Erlang version, Elixir version and Heroku stack. If your application cannot be updated for some reason and requires an older version of the buildpack then [use a specific version of buildpack](#use-a-specific-version-of-buildpack).

#### Use a specific version of buildpack

The methods above always use the latest version of the buildpack code. To use a specific version of the buildpack, choose a commit from the [commits](https://github.com/HashNuke/heroku-buildpack-elixir/commits/master) page. The commit SHA forms part of your buildpack url.

For example, if you pick the commit ["883f33e10879b4b8b030753c13aa3d0dda82e1e7"](https://github.com/HashNuke/heroku-buildpack-elixir/commit/883f33e10879b4b8b030753c13aa3d0dda82e1e7), then the buildpack url for your app would be:

```
https://github.com/HashNuke/heroku-buildpack-elixir.git#883f33e10879b4b8b030753c13aa3d0dda82e1e7
```

**It is recommended to use a buildpack url with a commit SHA on production apps.** This prevents the unpleasant moment when your Heroku build fails because the buildpack you use just got updated with a breaking change. Having buildpacks pinned to a specific version is like having your Hex packages pinned to a specific version in `mix.lock`.

#### Using Heroku CI

This buildpack supports Heroku CI. 

* To enable viewing test runs on Heroku, add [tapex](https://github.com/joshwlewis/tapex) to your project.
* To detect compilation warnings use the `hook_compile` configuration option set to `mix compile --force --warnings-as-errors`.

#### Elixir Releases

This buildpack can optionally build an [Elixir release](https://hexdocs.pm/mix/Mix.Tasks.Release.html). The release build will be run after `hook_post_compile`.

WARNING: If you need to do further compilation using another buildpack, such as the [Phoenix static buildpack](https://github.com/gjaldon/heroku-buildpack-phoenix-static), you probably don't want to use this option. See the [Elixir release buildpack](https://github.com/chrismcg/heroku-buildpack-elixir-mix-release) instead.

To build and use a release for an app called `foo` compiled with `MIX_ENV=prod`:
1. Make sure `elixir_version` in `elixir_buildpack.config` is at least 1.9
2. Add `release=true` to `elixir_buildpack.config`
3. Use `web: _build/prod/rel/foo/bin/foo start` in your Procfile

NOTE: This requires the master version of the buildpack (or a commit later than 7d369c)

## Configuration

Create a `elixir_buildpack.config` file in your app's root dir. The file's syntax is bash.

If you don't specify a config option, then the default option from the buildpack's [`elixir_buildpack.config`](https://github.com/HashNuke/heroku-buildpack-elixir/blob/master/elixir_buildpack.config) file will be used.


__Here's a full config file with all available options:__

```
# Erlang version
erlang_version=18.2.1

# Elixir version
elixir_version=1.2.0

# Always rebuild from scratch on every deploy?
always_rebuild=false

# Create a release using `mix release`? (requires Elixir 1.9)
release=true

# A command to run right before fetching dependencies
hook_pre_fetch_dependencies="pwd"

# A command to run right before compiling the app (after elixir, .etc)
hook_pre_compile="pwd"

hook_compile="mix compile --force --warnings-as-errors"

# A command to run right after compiling the app
hook_post_compile="pwd"

# Set the path the app is run from
runtime_path=/app

# Enable or disable additional test arguments
test_args="--cover"
```


#### Migrating from previous build pack
the following has been deprecated and should be removed from `elixir_buildpack.config`:
```
# Export heroku config vars
config_vars_to_export=(DATABASE_URL)
```

#### Specifying Elixir version

* Use prebuilt Elixir release

```
elixir_version=1.2.0
```

* Use prebuilt Elixir branch, the *branch* specifier ensures that it will be downloaded every time

```
elixir_version=(branch master)
```

#### Specifying Erlang version

* You can specify an Erlang release version like below

```
erlang_version=18.2.1
```

#### Specifying config vars to export at compile time

* To set a config var on your heroku node you can exec from the shell:

```
heroku config:set MY_VAR=the_value
```

## Other notes

* Add your own `Procfile` to your application, else the default web task `mix run --no-halt` will be used.

* Your application should build embedded and start permanent. Build embedded will consolidate protocols for a performance boost, start permanent will ensure that Heroku restarts your application if it crashes. See below for an example of how to use these features in your Mix project:

  ```elixir
  defmodule MyApp.Mixfile do
    use Mix.Project

    def project do
      [app: :my_app,
       version: "0.0.1",
       build_embedded: Mix.env == :prod,
       start_permanent: Mix.env == :prod]
    end
  end
  ```

* The buildpack will execute the commands configured in `hook_pre_compile` and/or `hook_post_compile` in the root directory of your application before/after it has been compiled (respectively). These scripts can be used to build or prepare things for your application, for example compiling assets.
* The buildpack will execute the commands configured in `hook_pre_fetch_dependencies` in the root directory of your application before it fetches the application dependencies. This script can be used to clean certain dependencies before fetching new ones.

## Development

* Build scripts to build erlang are at <https://github.com/HashNuke/heroku-buildpack-elixir-otp-builds>
* Sample app to test is available at <https://github.com/HashNuke/heroku-buildpack-elixir-test>

## Testing

To run tests
```
git clone https://github.com/HashNuke/heroku-buildpack-elixir
export BUILDPACK="$(pwd)/heroku-buildpack-elixir"
git clone https://github.com/jesseshieh/heroku-buildpack-testrunner
git clone https://github.com/jesseshieh/shunit2
export SHUNIT_HOME="$(pwd)/shunit2"
cd heroku-buildpack-testrunner
bin/run $BUILDPACK
```

See more info at https://github.com/jesseshieh/heroku-buildpack-testrunner/blob/master/README.md

## Credits

&copy; Akash Manohar under The MIT License. Feel free to do whatever you want with it.
