[![Codeship](https://img.shields.io/codeship/8c098d90-da0a-0132-b325-528f3b81d645.svg?style=plastic)](https://codeship.com/projects/79171)

# ActiveNotifier

ActiveNotifier makes it easy to send notifications to your end user through
different channels (push notifications, websockets, email etc).


## Dependencies

ActiveNotifier is queue agnostic by utilizing [ActiveJob][activejob].

It does not depend on Rails, so it should be possible to use the gem in other
ruby projects.


## Usage

This notifier will attempt to deliver a payload via push or direct e-mail:

```ruby
class LikesController < ApplicationController
  def create
    @like = Like.create(like_params)
    if @like.persisted?
      LikeNotifier.deliver_later({
        recipient: @like.recipient,
        like: @like,
        channels: [:push, :email] # attempts to delivery through push, then email if not possible
      })
    end
    respond_with @like
  end
end
```

```ruby
# app/notifiers/like_notifier.rb
class LikeNotifier < ActiveNotifier::Base
  queue_as :like_notifications # default is :notifications

  attr_accessor :like

  deliver_through :email do |config|
    config.email_attribute :email_address # defaults to :email
    config.subject "You just received a like"
  end

  deliver_through :push do |config|
    config.network_attribute :device_network
    config.token_attribute :device_token
    config.serializer Notifiers::LikeSerializer
  end
end
```

```erb
<!-- app/views/notifiers/like/email.html.erb -->
Hi <%= @recipient.name %>!

You just received a like.
<%= link_to 'View this', like_path(@paylod) %>
```

```ruby
# app/serializers/notifiers/like_serializer.rb
class LikeSerializer < ApplicationSerializer
  attributes :alert, :badge

  def alert
    "You've just received a like!"
  end

  def badge
    object.like.recipient.likes.unread.count
  end
end
```


## Concepts

### Recipient

The recipient of the message. This object should respond to different methods,
depending on what transports should be supported.

### Channels

A way to communicate with your user. ActiveNotifier ships with transports that
lets you deliver through email and push (given some dependencies are present).

#### Email

This channel will be available if the `actionmailer` gem is available.

```ruby
deliver_through :email do |config|
  config.email_attribute :email_address # defaults to :email
  config.subject "You just received a like"
end
```

If you want to use another library for sending e-mails, you have to define a
custom transport. See below.

#### Push

This channel will be available if the `pushmeup` gem is available.

```ruby
deliver_through :push do |config|
  config.network_attribute :device_network
  config.token_attribute :device_token
end
```


### Transports

A transport represents a communication channel and a way of delivering a message
to your user.

ActiveNotifier ships with 2 transports

* `ActiveNotifier::Transports::ActionMailer`
* `ActiveNotifier::Transports::Pushmeup`


## Contributing to active-notifier

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2015 Skalar. See LICENSE.txt for further details.

[activejob]: https://github.com/rails/rails/blob/master/activejob
