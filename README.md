# BabyNet

Default network client

- Returns a default URLSessionTask to control its state
- Wraps the task in a domain entitty mapper
- Performs primary exception handling and generates custom errors (BabyNetError)
- Ability to track the progress of a Task through an optional completion block

