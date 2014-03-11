# Heroku Elixir Buildpack

Heroku buildpack for Elixir applications.

#### Features

* Easy version configuration
* Use **prebuilt Elixir binaries** or build Elixir from source
* Allows configuring Erlang and Rebar versions


__Version support:__

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

Create a `.language_versions` file in your app's root dir.

If you don't specify any tool's version, then the default version from the buildpack's `[.language_versions](https://github.com/HashNuke/heroku-elixir-buildpack/blob/master/.language_versions)` file will be used for it.

__Here are valid examples:__

* Use prebuilt Elixir binary (available only for released versions)

```
erlang_version=R16B02
elixir_version=0.12.5
# default version of Rebar is used in this case
```

* Build Elixir from a branch

```
erlang_version="R16B03-1"
elixir_version=(branch master)
rebar_version=(tag 2.2.0)
```

* Build Elixir from a tag

```
erlang_version="R16B03-1"
elixir_version=(tag v0.12.5)
rebar_version=(tag 2.2.0)
```

* Build Elixir from a commit

```
erlang_version="R16B03-1"
elixir_version=(commit b07fbcf8b73e)
rebar_version=(tag 2.2.0)
```

#### Procfile

You can add your own Procfile. If you don't add one, the default procfile will run `mix server -p $PORT`.


## Credits

&copy; Akash Manohar under The MIT License. Feel free to do whatever you want with it.