NTUST.IM - User
===============

The core user authentication & management system.


## Configuration

The two sample configuration files lays at `config/configuration.yml.example` and `config/database.yml.example`, just copy, remove the trailing `.example` and modify them to your liking. 

If the `.yml` file dosen't exists, `.yml.example` will be used. So you can configure your app using only environment variables, especially when deploying to heroku or dokku.


## Development Build

```bash
$ bundle install --without production
$ rake db:migrate
$ rails s  # or `ln -s "$(pwd)" ~/.pow/user.ntust` if you're using Pow
```

### LiveReload

```bash
$ gem install guard guard-livereload
$ guard init livereload
$ bundle exec guard  # or `bundle exec guard &!` in zsh
```

Sample Guardfile:
```ruby
notification :growl_notify

guard 'livereload' do
  watch(%r{app/views/.+\.(erb|haml|slim)$})
  watch(%r{app/helpers/.+\.rb})
  watch(%r{public/.+\.(css|js|html)})
  watch(%r{config/locales/.+\.yml})
  # Rails Assets Pipeline
  watch(%r{(app|vendor)(/assets/\w+/(.+\.(css|sass|scss|js|coffee|html|haml|png|jpg|svg))).*}) { |m| "/assets/#{m[3].gsub(/(s[ac]ss|coffee)$/, 'sass' => 'css', 'scss' => 'css', 'coffee' => 'js')}" }
end
```


## Setup

The web admin panel is located at `http://[your.domain]/admin`, default account: email `admin@dev.null` with passowrd `password`.

- Add 學院 data to `colleges` table.
- Add 系所 data to `departments` table.


## Contributing

1. Fork it.
2. Create your feature branch (`git checkout -b my-new-feature`).
3. Commit your changes (`git commit -m 'add some feature'`).
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request.