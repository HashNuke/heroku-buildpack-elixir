## Heroku Elixir Buildpack

[ This readme is also a TODO. More docs coming. After I get some sleep. ]

Has support for using prebuilt Elixir binaries. Borrows heavily from Gosha Arinich's [work](https://github.com/goshakkk/heroku-buildpack-elixir).


#### To create a Heroku app with this buildpack

    heroku create --buildpack "https://github.com/HashNuke/heroku-elixir-buildpack.git"


#### To set the buildpack of an existing Heroku app

    heroku config:add BUILDPACK_URL="https://github.com/HashNuke/heroku-elixir-buildpack.git" -a APP_NAME


#### To set your Elixir and Erlang versions

* Create a `.language_versions` file in your app's root dir.

* Refer to the default `[.language_versions](https://github.com/HashNuke/heroku-elixir-buildpack/blob/master/.language_versions)` that comes with this repository for syntax. It is just a bash file.


#### Procfile

You can add your own Procfile. If you don't add one, the default profile will run `mix server -p $PORT`.
