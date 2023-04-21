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

gsub_file("Gemfile", '%i[ mingw mswin x64_mingw jruby ]', '%i[mingw mswin x64_mingw jruby]')
gsub_file("Gemfile", /%i\[ mri mingw x64_mingw \] */, '%i[mri mingw x64_mingw]')
gsub_file("Gemfile", '# gem "rack-cors"', 'gem "rack-cors"')

# Assets
########################################
run "rm -rf vendor"

# README
########################################
markdown_file_content = <<~MARKDOWN
  Rails app generated with [wJoenn/rails-vite-templates](https://github.com/wJoenn/rails-vite-templates).
MARKDOWN
file "README.md", markdown_file_content, force: true

# Yarn Init
########################################
package_json = <<~JSON
  {
    "name": "app",
    "private": "true",
    "scripts": {
      "dev": "concurrently --kill-others -n Rails:api,Vite:frontend -c red,green \"rails s\" \"yarn vite:serve\"",
      slint": "cd frontend && yarn eslint --ext .js,.vue . --max-warnings=0",
      "vite:serve": "cd frontend && vite",
      "vite:build": "cd frontend && vite build",
      "vite:install": "cd frontend && yarn"
    }
  }
JSON
file "package.json", package_json, force: true
run "yarn add -D concurrently"

########################################
# After bundle
########################################
after_bundle do
   # Gitignore
  ########################################
  append_file ".gitignore", <<~TXT
    /node_modules

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
  
  # Bin Deploy
  ########################################
  bin_deploy = <<~EOF
    #!/usr/bin/env bash

    echo "Building project..."
    yarn vite:build

    echo "Pushing to Heroku..."
    git add .
    git commit -m "Pushing to prod"
    git push heroku master

    echo "Cleaning up..."
    git reset HEAD~
    rm -rf public/assets
    rm public/index.html

    echo "Deployment complete!"
  EOF
  file "bin/deploy", bin_deploy, force: true
  run "chmod +x bin/deploy"

  # Rack Cors
  ########################################
  rack_cors_config = <<~RUBY
    # Be sure to restart your server when you modify this file.

    # Avoid CORS issues when API is called from the frontend app.
    # Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin AJAX requests.

    # Read more: https://github.com/cyu/rack-cors

    Rails.application.config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins "*"

        resource "*",
          headers: :any,
          methods: %i[get post put patch delete options head]
      end
    end
  RUBY
  file "config/initializers/cors.rb", rack_cors_config, force: true
  
  # Install Vue
  ########################################
  run "git clone git@github.com:wJoenn/vue-boilerplate.git frontend"
  run "yarn vite:install"
  run "cd frontend && git remote remove origin"
  run "rm -rf frontend/.git"

  # Git
  ########################################
  git :init
  git add: "."
  git commit: "-m 'Initial commit with vue template from https://github.com/wJoenn/rails-vite-templates'"
end
