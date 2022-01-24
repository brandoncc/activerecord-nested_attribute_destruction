## [Unreleased]

## [0.2.0] - 2022-01-24

**POSSIBLY BREAKING CHANGE**

Use `around_update` instead of `before_update` and `after_commit, on: :update`.

In some situations, our `after_commit` would be run after `after_commit`
callbacks that were defined in the user application.

By using `around_update`, our callback finishes before any `after_*` callbacks are called.

## [0.1.1] - 2022-01-17

Fixed bug where the monitor might not have been created yet when it is accessed.

## [0.1.0] - 2021-12-22

- Initial release
