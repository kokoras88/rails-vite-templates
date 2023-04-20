# Rails Templates

Quickly generate a Rails app with Stimulus and Scss bundled by Vite.js using [Rails Templates](http://guides.rubyonrails.org/rails_application_templates.html).

⚠️ The following templates have been made for Rails 7.

## Rails full-stack + Turbo Stimulus

Get a minimal rails app ready to be deployed on Heroku with Bootstrap, Simple form and debugging gems.

```bash
rails new \
  -d postgresql \
  --skip-asset-pipeline \
  --skip-javascript \
  -m https://raw.githubusercontent.com/wJoenn/rails-vite-templates/master/stimulus.rb \
  CHANGE_THIS_TO_YOUR_RAILS_APP_NAME
```

## Rails API + ViteVue

```bash
rails new \
  -d postgresql \
  --api \
  -m https://raw.githubusercontent.com/wJoenn/rails-vite-templates/master/vue.rb \
  CHANGE_THIS_TO_YOUR_RAILS_APP_NAME
```

## Github actions
To install actions on pull requests for rubocop and esLint run those commands from your root repository
```
mkdir -p .github/workflows
curl -L https://raw.githubusercontent.com/wJoenn/rails-vite-templates/master/linter.yml > .github/workflows/linter.yml
```
