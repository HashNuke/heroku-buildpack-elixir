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
* Post compilation hook through `post_compile` configuration


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

## Configuration

Create a `elixir_buildpack.config` file in your app's root dir. The file's syntax is bash.

If you don't specify a config option, then the default option from the buildpack's [`elixir_buildpack.config`](https://github.com/HashNuke/heroku-buildpack-elixir/blob/master/elixir_buildpack.config) file will be used.


__Here's a full config file with all available options:__

```
# Erlang version
erlang_version=18.1.3

# Elixir version
elixir_version=1.0.4

# Always rebuild from scratch on every deploy?
always_rebuild=false

# Export heroku config vars
config_vars_to_export=(DATABASE_URL)

# A command to run right after compiling the app
post_compile="pwd"
```


#### Specifying Elixir version

* Use prebuilt Elixir release

```
elixir_version=1.0.4
```

* Use prebuilt Elixir branch, the *branch* specifier ensures that it will be downloaded every time

```
elixir_version=(branch master)
```

#### Specifying Erlang version

* You can specify an Erlang release version like below

```
erlang_version=17.5
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

* If you create an application with this buildpack, then a free database addon `heroku-postgresql:hobby-dev` is also added. The database credentials are available from the env var `DATABASE_URL`.

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

* The buildpack will execute the command configured in `post_compile` in the root directory of your application after it has been compiled. This script can be used to build or prepare things for your application, for example compiling assets.


## Development

* Build scripts to build erlang are at <https://github.com/HashNuke/heroku-buildpack-elixir-otp-builds>
* Sample app to test is available at <https://github.com/HashNuke/heroku-buildpack-elixir-test>


## Credits

&copy; Akash Manohar under The MIT License. Feel free to do whatever you want with it.
