run "if uname | grep -q 'Darwin'; then pgrep spring | xargs kill -9; fi"

# Gemfile
########################################
inject_into_file "Gemfile", after: 'gem "debug", platforms: %i[ mri mingw x64_mingw ]' do
  <<-RUBY.chomp
  
  gem "dotenv-rails"

  gem "rubocop", require: false
  gem "rubocop-performance", require: false
  gem "rubocop-rails", require: false
  RUBY
end

inject_into_file "Gemfile", before: "group :development, :test do" do
  <<~RUBY
    # Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
    gem "turbo-rails"
    
    # Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
    gem "stimulus-rails"
    
    # Vite.js integration in Ruby web apps [https://vite-ruby.netlify.app/]
    gem "vite_rails"
    
    gem "autoprefixer-rails"
    
  RUBY
end

gsub_file("Gemfile", '# gem "sassc-rails"', 'gem "sassc-rails"')
gsub_file("Gemfile", '%i[ mingw mswin x64_mingw jruby ]', '%i[mingw mswin x64_mingw jruby]')
gsub_file("Gemfile", /%i\[ mri mingw x64_mingw \] */, '%i[mri mingw x64_mingw]')

# Assets
########################################
run "rm -rf vendor"
run "mv app/assets/stylesheets/application.css app/assets/stylesheets/application.scss"
run "mkdir -p app/assets/stylesheets/config && touch app/assets/stylesheets/config/_setup.scss"
run "mkdir -p app/assets/stylesheets/components && touch app/assets/stylesheets/components/_index.scss"
run "mkdir -p app/assets/stylesheets/pages && touch app/assets/stylesheets/pages/_index.scss"
application_css = <<~CSS
  // Config files
  @import "config/setup";
  // External libraries
  // Your CSS Partials
  @import "pages/index";
  @import "components/index";
CSS
file "app/assets/stylesheets/application.scss", application_css, force: true

setup_css = <<-CSS
body {
  background-color: #181a1b;
  color: lightgrey;
}
CSS
file "app/assets/stylesheets/config/_setup.scss", setup_css, force: true

# Layout
########################################

gsub_file(
  "app/views/layouts/application.html.erb",
  '<meta name="viewport" content="width=device-width,initial-scale=1">',
  '<meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">'
)

# README
########################################
markdown_file_content = <<~MARKDOWN
  Rails app generated with [wJoenn/rails-templates](https://github.com/wJoenn/rails-templates).
  This is a fork by [Louis Ramos](https://louisramos.dev) from a template created by the [Le Wagon coding bootcamp](https://www.lewagon.com) team.
MARKDOWN
file "README.md", markdown_file_content, force: true

# Generators
########################################
generators = <<~RUBY
  config.generators do |generate|
    generate.assets false
    generate.helper false
    generate.test_framework :test_unit, fixture: false
  end
RUBY

environment generators

# Yarn Init
########################################
package_json = <<~JSON
  {
    "name": "app",
    "private": "true"
  }
JSON
file "package.json", package_json, force: true
run "yarn add autoprefixer"

run "mkdir -p app/javascript && touch app/javascript/application.js"

########################################
# After bundle
########################################
after_bundle do
  # Install Vite
  ########################################
  run "bundle exec vite install"
  run "yarn add -D vite-plugin-full-reload vite-plugin-stimulus-hmr sass"
  
  # Vite Config
  ########################################
  vite_config_ts = <<~JS
    import {defineConfig} from 'vite'
    import FullReload from "vite-plugin-full-reload"
    import RubyPlugin from 'vite-plugin-ruby'
    // import StimulusHMR from 'vite-plugin-stimulus-hmr'
    
    export default defineConfig({
      clearScreen: false,
      plugins: [
        RubyPlugin(), 
        // StimulusHMR(), 
        FullReload(["config/routes.rb", "app/views/**/*"], {delay: 200}),
      ],
    })
  JS
  file "vite.config.ts", vite_config_ts, force: true

  # Vite entrypoints
  ########################################
  inject_into_file "app/javascript/entrypoints/application.js", before: "// To see this message, add the following to the `<head>` section in your" do
    <<~JS
      import "../application"
      
    JS
  end
  
  file "app/javascript/entrypoints/application.scss", '@import "../../assets/stylesheets/application";', force: true
  
  gsub_file(
    "app/views/layouts/application.html.erb",
    '<%= stylesheet_link_tag "application" %>',
    '<%= vite_stylesheet_tag "application.scss", "data-turbo-track": "reload" %>'
  )
  
  # Postcss Config
  ########################################
  postcss_config_js = <<~JS
    module.exports = {
      plugins: {
        autoprefixer: {},
      },
    }
  JS
  file "postcss.config.js", postcss_config_js, force: true
  
  # Turbo
  ########################################
  run "rails turbo:install"
  
  # Stimulus
  #######################################
  run "rails stimulus:install"
  
  # Generators: db + simple form + pages controller
  ########################################
  rails_command "db:drop db:create db:migrate"
  generate(:controller, "pages", "home", "--skip-routes", "--no-test-framework")
  gsub_file("app/controllers/pages_controller.rb", /home\s*end/, "home() end")
  
  gsub_file(
    "app/views/pages/home.html.erb",
    '<h1>Pages#home</h1>',
    '<h1 data-controller="hello">Pages#home</h1>'
   )

  # Routes
  ########################################
  route 'root to: "pages#home"'

  # Gitignore
  ########################################
  gsub_file(".gitignore", "node_modules", "/node_modules")
  append_file ".gitignore", <<~TXT
    # Ignore .env file containing credentials.
    .env*
    # Ignore Mac and Linux file system files
    *.swp
    .DS_Store
  TXT

  # Heroku
  ########################################
  run "bundle lock --add-platform x86_64-linux"

  # Dotenv
  ########################################
  run "touch '.env'"

  # Rubocop
  ########################################
  run "curl -L https://raw.githubusercontent.com/wJoenn/rails-vite-templates/master/.rubocop.yml > .rubocop.yml"
  
  # EsLint
  ########################################
  run "yarn add -D eslint eslint-config-airbnb-base eslint-plugin-import"
  run "curl -L https://raw.githubusercontent.com/wJoenn/rails-vite-templates/master/.eslintrc.json > .eslintrc.json"
  
  # Bin Dev
  ########################################
  bin_dev = <<~EOF
    #!/usr/bin/env sh
    if ! gem list foreman -i --silent; then
      echo "Installing foreman..."
      gem install foreman
    fi
    exec foreman start -f Procfile.dev "$@"
  EOF
  file "bin/dev", bin_dev, force: true
  chmod "bin/dev", 0755, verbose: false
  
  # Procfile
  ########################################
  procfile = <<~EOF
    web: bin/rails server -p 3000
    vite: bin/vite dev --clobber
  EOF
  file "Procfile.dev", procfile, force: true

  # Git
  ########################################
  git :init
  git add: "."
  git commit: "-m 'Initial commit with minimal template from https://github.com/wJoenn/rails-templates'"
end
