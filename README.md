# Heroku Buildpack for Elixir

### Features

* **Easy configuration** with `elixir_buildpack.config` file
* Use **prebuilt Elixir binaries** or build from source
* Mix **dependency caching**
* Adds the free Heroku Postgres **database upon app creation**
* `DATABASE_URL` is made available at compile time
* Allows configuring Erlang
* If your app doesn't have a Procfile, default web task `mix server -p $PORT` will be run.
* Consolidates protocols
* Hex and rebar support


#### Version support info

* Erlang - Prebuilt packages (17.0, R16B03-1, etc)
* Elixir - Prebuilt binaries or build from a branch, tag or a commit


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
erlang_version=17.0

# Elixir version
elixir_version=0.12.5

# Do dependencies have to be built from scratch on every deploy?
always_build_deps=false
```


#### Some other ways of specifying Elixir version

* _Build Elixir from a branch._ If you specify a branch, that particular Elixir branch will be re-downloaded and built from source every time you deploy.

```
elixir_version=(branch master)
```

* _Build Elixir from a tag_

```
elixir_version=(tag v0.12.5)
```

* _Build Elixir from a particular commit_

```
elixir_version=(commit b07fbcf8b73e)
```

#### Specifying Erlang verisons

* You can either specify a stable Erlang release version like below

```
erlang_version=R16B03-1
```

* OR you can specify that Erlang builds from the master branch must be used

```
erlang_version=(branch master)
```

Note that if you specify the master branch of Erlang, then it is Heroku's periodic builds that will be used. I don't work for Heroku, but I'm assuming that's why they have master branch builds.


## Other notes

* Add your own `Procfile` to your application, else the default web task `mix server -p $PORT` will be used.

* To make use of consolidated protocols they need to be added to the loadpath. Example: `elixir -pa _build/prod/consolidated -S mix run --no-halt`.

* If you create an application with this buildpack, then a free database addon`heroku-postgresql:hobby-dev` is also added. The database credentials are available from the env var `DATABASE_URL`.


## Credits

&copy; Akash Manohar under The MIT License. Feel free to do whatever you want with it.
