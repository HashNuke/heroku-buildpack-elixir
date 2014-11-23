# Heroku Buildpack for Elixir

### Features

* **Easy configuration** with `elixir_buildpack.config` file
* Use **prebuilt Elixir binaries**
* Adds the free Heroku Postgres **database upon app creation**
* `DATABASE_URL` can be made available at compile time adding it to `config_vars_to_export` in `elixir_buildpack.config`
* Allows configuring Erlang
* If your app doesn't have a Procfile, default web task `mix server -p $PORT` will be run.
* Consolidates protocols
* Hex and rebar support
* Caching of Hex packages, Mix dependencies and downloads
* Allow execution of post Erlang/Elixir/App hooks


#### Version support info

* Erlang - Prebuilt packages (17.2, 17.1, etc)
* Elixir - Prebuilt releases (1.0.0, 0.15.1 etc) or prebuilt branches (master, stable, etc)


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
erlang_version=17.2

# Elixir version
elixir_version=1.0.0

# Always rebuild from scratch on every deploy?
always_rebuild=false

# Export heroku config vars
config_vars_to_export=(DATABASE_URL)

# Execute bash script after Erlang installation
post_erlang_hook=deploy/post_erlang.sh

# Execute bash script after Elixir installation
post_elixir_hook=deploy/post_elixir.sh

# Execute bash script after App installation
post_app_hook=deploy/post_app.sh
```


#### Specifying Elixir version

* Use prebuilt Elixir release

```
elixir_version=1.0.0
```

* Use prebuilt Elixir branch, the *branch* specifier ensures that it will be downloaded every time

```
elixir_version=(branch master)
```

#### Specifying Erlang version

* You can specify an Erlang release version like below

```
erlang_version=17.2
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

#### Specifying post hooks scripts

Post hook scripts files path are relative to your app's root dir.

* The `post_erlang_hook` is executed after the Erlang installation and before the Elixir installation.
* The `post_elixir_hook` is executed after the Elixir installation and before the App installation.
* The `post_app_hook` is executed after the App installation.

__Create a bash script to execute (e.g. `deploy/post_erlang.sh`):__

```bash
#!/usr/bin/env bash

echo "After Erlang installation"
```

__Specify the script you want to be executed in your `elixir_buildpack.config` file:__

```
post_erlang_hook=deploy/post_erlang.sh
```

## Other notes

* Add your own `Procfile` to your application, else the default web task `mix server -p $PORT` will be used.

* To make use of consolidated protocols they need to be added to the loadpath. Example: `elixir -pa _build/prod/consolidated -S mix run --no-halt`.

* If you create an application with this buildpack, then a free database addon`heroku-postgresql:hobby-dev` is also added. The database credentials are available from the env var `DATABASE_URL`.


## Credits

&copy; Akash Manohar under The MIT License. Feel free to do whatever you want with it.
