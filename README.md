# Samedi Rails API Client

This application is a reference implementation of the [samedi Booking API](https://wiki.samedi.de/display/doc/Booking+API) client in Ruby.

This is a web application that allows a user to book an appointment for a given clinic.

## Requirements

The application is developed with Ruby 2.5.1.

## Setup

Clone this repository and run the setup script:

```
$ cd samedi-rails-api-client
$ bin/setup
```

Register your own [samedi API Credentials](https://patient.samedi.de/api/signup) and update your local `.env` file.

## Architecture

This app is a front-end for Samedi Bookking API.
Therefore, unlike a typical Rails app, this one doesn't use a database at all.

Typical the data flow goes like this:

* User agent sends a request to the Rails app
* An appropriate controller handles the request
* If necessary, the controller builds a form object to validate and filter the request data (params)
* The controller builds an operation object that will process the request and invokes it with validated params
* The operation object performs a request to Samedi API
* The operation object transforms the API response into entities that are the part of the domain model and returns them to the controller
* If necessary, the controller decorates the returned entities or builds a view-model using those entities, exposing the built object to a view

### Code Organization

While following the typical Rails code organization, `app` contains a few non-standard directories:

* `app/decorators` — containts [decorators](https://en.wikipedia.org/wiki/Decorator_pattern) for entities.
* `app/entities` — contains entity objects. These are POROs which encapsulate various types defined by Samedi Booking API.
* `app/forms` — contains form objects. These are typically ActiveModel objects that are used to render and validate data coming from web forms.
* `app/mappers` — contains objects that provide [data mapping](https://en.wikipedia.org/wiki/Data_mapper_pattern) between Samedi API response hashes and entities as defined within the app.
* `app/operations` — contains operation objects. An operation object is a function object, thus their names are verbs and their only public method is `#call`.
  Operation objects contain business logic and they work with service objects that are typically injected as dependencies in initializers.
* `app/view_models` — contains objects that encapsulate data that should be displayed on a single page.
  They are typically composed of multiple objcets, which could be a mix of forms, entities, and basic Ruby types.

## Front-end

Front-end is built exclusively with Webpacker, using the [Webpacker gem](https://github.com/rails/webpacker).

## Specs

Tests are written with RSpec. Tu run all tests, you could simply execute the following command in terminal:

```
$ bundle exec rspec
```
