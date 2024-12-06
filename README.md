# MVinl

A mini stack configuration language.

*Mini Vinl is not Lisp*

## Install

MVinl is packaged as gem. To install it from RubyGems.org go

```
gem install mvinl
```

or build and install it from this repo if you have it downloaded

```
gem build
gem install ./mvinl-0.1.0.gem
```

## Usage

Use `MVinl.eval` or `MVinl.eval_from_file` to evaluate mvinl code.

`imvnl` is an interactive shell for mvinl. It's not really how the language
suppose to be used but it's useful for quckly testing expressions.

Vinl execution returns a hash similar to YAML or JSON. The point is to create a
configuration structure to initiate objects in an application, like a game
engine.

The main elements that construct the resulting structure are groups and
properties. Groups typically sort objects into data categories, such as states.
Properties can be thought of as object constructors.

**Example:**

``` mvinl
def (center x (/ x 2))

@start
  SplashScreen 'path/to/image'.

@second
  Buttom (center 1920)
         (center 1080)
         "Hello, MVinl!"
        font_size: 21     # END_TAG is optional
```

## Contribute

I happily accept suggestions and changes. Please leave bug rapports
[here](https://github.com/513ry/mvinl/issues).

## License

MVinl is a free software distributed under MIT license. Read LICENSE file for
legal notice.
