# Heroku Buildpack for Elixir

## Features

* **Easy configuration** with `elixir_buildpack.config` file
* Use **prebuilt Elixir binaries**
* `DATABASE_URL` can be made available at compile time adding it to `config_vars_to_export` in `elixir_buildpack.config`
* Allows configuring Erlang
* If your app doesn't have a Procfile, default web task `mix run --no-halt` will be run.
* Consolidates protocols
* Hex and rebar support
* Caching of Hex packages, Mix dependencies and downloads
* Pre & Post compilation hooks through `pre_compile`, `post_compile` configuration


#### Version support

* Erlang - Prebuilt packages (17.5, 17.4, etc)
* Elixir - Prebuilt releases (1.0.4, 1.0.3, etc) or prebuilt branches (master, stable, etc)


## Usage

#### Create a Heroku app with this buildpack

```
heroku create --buildpack "https://github.com/HashNuke/heroku-buildpack-elixir.git"
```

#### Set the buildpack of an existing Heroku app

```
heroku config:set BUILDPACK_URL="https://github.com/HashNuke/heroku-buildpack-elixir.git"
```

The above method always uses the latest version of the buildpack. To use a specific older version of the buildpack, [see notes below](#using-older-version-of-buildpack).

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

# Export heroku config vars
config_vars_to_export=(DATABASE_URL)

# A command to run right before compiling the app (after elixir, .etc)
pre_compile="pwd"

# A command to run right after compiling the app
post_compile="pwd"
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

* Add the config vars you want to be exported in your `elixir_buildpack.config` file:

```
config_vars_to_export=(DATABASE_URL MY_VAR)
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

* The buildpack will execute the commands configured in `pre_compile` and/or `post_compile` in the root directory of your application before/after it has been compiled (respectively). These scripts can be used to build or prepare things for your application, for example compiling assets.


#### Using older version of buildpack

Using the above methods always uses the latest version of the buildpack. We attempt to maintain the buildpack for as many old Elixir and Erlang releases as possible. But sometimes it does get hard since there's a matrix of 3 variables involved here (Erlang version, Elixir version and Heroku stack). If your application cannot be updated for some reason and requires an older version of the buildpack then use the [releases](https://github.com/HashNuke/heroku-buildpack-elixir/releases) page to pick a tag to use. Use the buildpack url with the tag name.

For example, if you pick the tag "v3", then the buildpack url for your app would be:

```
https://github.com/HashNuke/heroku-buildpack-elixir.git#v3
```

We only create a new tag/release when we've made breaking changes. So consider all tagged versions older than master as not recommended for use and not supported any further.

## Development

* Build scripts to build erlang are at <https://github.com/HashNuke/heroku-buildpack-elixir-otp-builds>
* Sample app to test is available at <https://github.com/HashNuke/heroku-buildpack-elixir-test>


## Credits

&copy; Akash Manohar under The MIT License. Feel free to do whatever you want with it.
