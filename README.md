# Rails Templates with Vitejs

Quickly generate a Rails app with Stimulus and Scss bundled by Vite.js using [Rails Templates](http://guides.rubyonrails.org/rails_application_templates.html).

⚠️ The following templates have been made for Rails 7.

## Minimalist

Get a Rails app ready to be deployed on Heroku with Stimulus, SCSS and Vite's HMR for development.

```bash
rails new \
  -d postgresql \
  --skip-asset-pipeline \
  --skip-javascript \
  -m https://raw.githubusercontent.com/wJoenn/rails-vite-templates/master/minimalist.rb \
  CHANGE_THIS_TO_YOUR_RAILS_APP_NAME
```

## Advanced

Adds some additional tools such as Rubocop, esLint, Devise for authentification and RSpec for testing

```bash
rails new \
  -d postgresql \
  --api \
  -m https://raw.githubusercontent.com/wJoenn/rails-vite-templates/master/advanced.rb \
  CHANGE_THIS_TO_YOUR_RAILS_APP_NAME
```

## Github actions
To install actions on pull requests for rubocop and esLint run those commands from your root repository
```bash
mkdir -p .github/workflows
curl -L https://raw.githubusercontent.com/wJoenn/rails-vite-templates/master/linter.yml > .github/workflows/linter.yml

curl -L https://raw.githubusercontent.com/wJoenn/rails-vite-templates/master/pre-push > .git/hooks/pre-push
chmod -x .git/hooks/pre-push
```
