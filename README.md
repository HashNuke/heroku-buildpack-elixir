# Heroku Elixir Buildpack

Heroku buildpack for Elixir applications.

### Features

* Easy version configuration with `.tool_versions` file
* Use **prebuilt Elixir binaries** or build Elixir from source
* Allows configuring Erlang and Rebar versions
* If your application doesn't have a Procfile, default task `mix server -p $PORT` will be run.


#### Version support info

* Erlang - Prebuilt packages
* Elixir - Prebuilt binaries or build from a branch, tag or a commit
* Rebar - Always built from source. You can specify tag, branch or commit.


## Usage

#### Create a Heroku app with this buildpack

```
heroku create --buildpack "https://github.com/HashNuke/heroku-elixir-buildpack.git"
```

#### Set the buildpack of an existing Heroku app

```
heroku config:add BUILDPACK_URL="https://github.com/HashNuke/heroku-elixir-buildpack.git"
```


## Setting Elixir, Erlang and Rebar versions

Create a `elixir_buildpack.config` file in your app's root dir. The file's syntax is bash.

If you don't specify any tool's version, then the default version from the buildpack's [`elixir_buildpack.config`](https://github.com/HashNuke/heroku-elixir-buildpack/blob/master/elixir_buildpack.config) file will be used for it.

__Here are valid examples:__

* Use prebuilt Elixir binary (available only for released versions)

```
erlang_version=R16B02
elixir_version=0.12.5
# default version of Rebar is used in this case
```

* **Build Elixir from a branch.** If you specify a branch, that particular Elixir branch will be re-downloaded and built from source every time you deploy.

```
erlang_version="R16B03-1"
elixir_version=(branch master)
rebar_version=(tag 2.2.0)
```

* **Build Elixir from a tag**

```
erlang_version="R16B03-1"
elixir_version=(tag v0.12.5)
rebar_version=(tag 2.2.0)
```

* **Build Elixir from a commit**

```
erlang_version="R16B03-1"
elixir_version=(commit b07fbcf8b73e)
rebar_version=(tag 2.2.0)
```


## Credits

&copy; Akash Manohar under The MIT License. Feel free to do whatever you want with it.