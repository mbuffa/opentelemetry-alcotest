# TODO

## Bugs

* [ ] Troubleshoot missing spans (see: https://docs.honeycomb.io/getting-data-in/troubleshooting-traces/#traces-have-a-missing-root-span-or-missing-spans)

## Improvements

* [x] Allow users to decide to start the handlers they want
* [ ] Make Batch Middleware support fields filtering from env
* [x] Allow users to set what they want to include in their spans
  * [x] Make sure we can include optional context items for operations (like the current user id)
* [x] Add the minimum requirements for testing (Phoenix app, GraphQL schema...)
* [x] Write documentation
* [x] Add a Github CI flow
* [x] Publish 0.1 on Hex
* [ ] Write assertions for selections
* [ ] Make sure complexity is correctly handled
* [ ] Support Dataloader tracking
* Support more Absinthe hooks
  * [x] Resolve
  * [x] Middleware
  * [ ] Subscription
