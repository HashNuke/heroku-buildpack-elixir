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
heroku create --buildpack "https://github.com/HashNuke/heroku-buildpack-elixir.git"
```

#### Set the buildpack of an existing Heroku app

```
heroku config:add BUILDPACK_URL="https://github.com/HashNuke/heroku-buildpack-elixir.git"
```


## Setting Elixir, Erlang and Rebar versions

Create a `elixir_buildpack.config` file in your app's root dir. The file's syntax is bash.

If you don't specify any tool's version, then the default version from the buildpack's [`elixir_buildpack.config`](https://github.com/HashNuke/heroku-buildpack-elixir/blob/master/elixir_buildpack.config) file will be used for it.

__Here's a full config file with all available options:__


```
# Erlang version
erlang_version=R16B03-1

# Elixir version
elixir_version=0.12.5

# Rebar version
rebar_version=(tag 2.2.0)

# Do dependencies have to be built from scratch on every deploy?
always_build_deps=false
```

#### Some other ways of specifying Elixir version

* **Build Elixir from a branch.** If you specify a branch, that particular Elixir branch will be re-downloaded and built from source every time you deploy.

```
elixir_version=(branch master)
```

* **Build Elixir from a tag**

```
elixir_version=(tag v0.12.5)
```

* **Build Elixir from a particular commit**

```
elixir_version=(commit b07fbcf8b73e)
```


## Credits

&copy; Akash Manohar under The MIT License. Feel free to do whatever you want with it.