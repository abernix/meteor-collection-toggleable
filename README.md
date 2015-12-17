[![Gitter](https://img.shields.io/badge/gitter-join_chat-brightgreen.svg)]
(https://gitter.im/zimme/meteor-collection-softremovable)
[![Code Climate](https://img.shields.io/codeclimate/github/zimme/meteor-collection-softremovable.svg)]
(https://codeclimate.com/github/zimme/meteor-collection-softremovable)

# Toggle fields with dates for collections

### Install
```sh
meteor add abernix:collection-toggleable
```

### Usage

Basic usage examples.

#### Attach

```js
Orders = new Mongo.Collection('orders');

//Add a custom toggle
CollectionBehaviours.attach(collection, "toggleable", {
  toggleOn: "cancel",
  toggleOff: "uncancel",
  toggle: "cancelled",
  toggledAt: "cancelledAt",
  toggledBy: "cancelledBy",
  untoggledAt: "uncancelledAt",
  untoggledBy: "uncancelledBy",
  omit: true,
  toggled: "cancelled" // This is the option NAME to include omitted from find/findOne
});
```

#### Remove/Restore

```js
// Soft remove document by _id
Orders.cancel({_id: 'BFpDzGuWG8extPwrE'});

// Restore document by _id
Orders.restore('BFpDzGuWG8extPwrE');

// Actually remove document from collection
Orders.uncancel({_id: 'BFpDzGuWG8extPwrE'});
```

#### Find

```js
// Find all orders except cancelled orders
Orders.find({});

// Find only orders that have been cancelled
// This is using the actual field name, defined in options as 'toggle'
Orders.find({cancelled: true});

// Find all orders including cancelled
// This is where you use the 'toggled' option, as the option name.
Orders.find({}, {cancelled: true});
```

#### Publish

For you to be able to find soft removed documents on the client you will need
to explicitly publish those. The example code below belongs in server-side code.

```js
Meteor.publish('orders', function() {
  return Orders.find({});
});

Meteor.publish('cancelledOrders', function() {
  return Orders.find({cancelled: true});
});

Meteor.publish('allOrders', function() {
  return Orders.find({}, {cancelled: true});
});
```

### Options

The following options can be used:

* `removed`: Optional. Set to `'string'` to change the fields name.
  This field can't be omitted.

* `removedAt`: Optional. Set to `'string'` to change the fields name.
  Set to `false` to omit field.

* `removedBy`: Optional. Set to `'string'` to change the fields name.
  Set to `false` to omit field.

* `restoredAt`: Optional. Set to `'string'` to change the fields name.
  Set to `false` to omit field.

* `restoredBy`: Optional. Set to `'string'` to change the fields name.
  Set to `false` to omit field.

* `systemId`: Optional. Set to `'string'` to change the id representing the
  system.

### Notes

* This package attaches a schema to the collection if `aldeed:simple-schema`,
  `aldeed:collection2` and/or `aldeed:autoform` are used in the application.
