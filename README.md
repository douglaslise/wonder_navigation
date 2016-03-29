# Rails Wonderful Navigation

[![Code Climate](https://codeclimate.com/github/douglaslise/wonder_navigation/badges/gpa.svg)](https://codeclimate.com/github/douglaslise/wonder_navigation)
[![Gem Version](https://badge.fury.io/rb/wonder_navigation.svg)](https://badge.fury.io/rb/wonder_navigation)

Describe your Rails' menus and breadcrumbs in a single place, with support for permissions, fixed and resource based labels.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'wonder_navigation'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install wonder_navigation

## Usage

In Rails, create a folder `config/navigation/default` and a file called `config/navigation/default.yml`. Inside the yml file you put the list of files that contains menu definitions:
```yml
---
default:
  - public
  - admin
```
After, create the corresponding files (`config/navigation/default/public.rb`, `config/navigation/default/admin.rb`):

```ruby
WonderNavigation::Menu.register(:default) do
  label { "Begin" }
  path { root_path }
  menu :blog, "Blog" do #Non-linked menu level
    resource :posts, label: "Posts", path: posts_path do |index, new, show|
      show.label {|post| post.title.truncate(15) }
      # Here you can overwrite new and index entries

      menu :comments, "Comments", path: post_comments_path do
        menu :comment_show do
          label {|comment| "Comment from #{comment.author}" }
          path {|comment| post_comment_path(comment) }
          menu :comment_edit, "Editing" do
            path {|comment| edit_post_comment_path(comment)}
          end
        end
      end
    end
  end
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/douglaslise/wonder_navigation.

