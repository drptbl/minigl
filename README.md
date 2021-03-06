# MiniGL

MiniGL is a minimal **2D Game** Library, available as a Ruby gem, and built on
top of the [Gosu](http://www.libgosu.org/) gem.

It provides the following features:

  * Resource management (images, sounds, ...)
  * Input manipulation (keyboard, mouse, ...)
  * UI (text, buttons, text fields, ...)
  * Basic physics and collision checking
  * Animated objects

More functionalities are coming. Feel free to contribute! You can send feedback
to victordavidsantos@gmail.com.

## Installing

MiniGL was built on top of the Gosu gem. This gem has its own dependencies for
compiling extensions. Visit
[this page](https://github.com/jlnr/gosu/wiki/Getting-Started-on-Linux) for
details.

After installing the gosu dependencies, you can just `gem install minigl`.

Please note:

  * The test package is not complete! Most of the functionality
provided by the gem is difficult to test automatically, but you can check the
examples provided with the gem.
  * The library is 100% RDoc-documented.
  * An auxiliary, tutorial-like documentation is under construction
[here](https://github.com/victords/minigl/wiki/How-To).

## Version 2.0.3

  * Flexibilization of various methods and constructors with named parameters.
Please note I haven't used the "official" Ruby syntax for named parameters, but
the "first parameter as hash" technique (in order to keep the positional call
available), so you will need to be careful to include all the mandatory
parameters in your hash, or you could face some strange errors (you can find out
the mandatory parameters in the documentation). Here is the list of flexibilized
methods:
    * `GameWindow::new`
    * `Sprite#draw`
    * `GameObject#draw`
    * `TextHelper#write_line`
    * `Button::new`
    * `ToggleButton::new`
    * `TextField::new`
    * `ProgressBar::new`
    * `DropDownList::new`
  * Flexibilization of `Mouse::over?` with the possibility of passing a single
parameter (a `Rectangle` object) instead of four coordinates.
  * Passing of the `set_animation` method from `GameObject` to `Sprite`, so the
sprites also support it (`GameObject` still supports because it inherits from
`Sprite`).
  * Change of the parameter order in `TextHelper#write_line`, so that `alpha`
comes right after `color`, and not after all the `effect_...` parameters. **This
could generate incompatibility.**
