# src/server/lib/helpers.coffee

@randomFromCollection = (collection) ->
  ids = collection.find({}, { fields: { _id: 1 } }).fetch()
  i = Math.floor(Math.random() * ids.length)
  collection.findOne ids[i]._id
