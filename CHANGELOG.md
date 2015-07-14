1.4.0 / 2015-07-14
[FEATURE] Searcher now supports #options() to allow setting of the q.options parameter in the 2013 api

1.3.1 / 2015-07-13
[BUGFIX] Fixed failing tests

1.3.0 / 2014-11-22
[FEATURE] Added sorting option to searcher

1.2.4 / 2014-06-12
[FEATURE] Remove deep clone to allow inquisitio on jRuby

1.2.3 / 2014-06-05
[FEATURE] Return time taken by queries as time_ms on Searcher for 2013-01-01 api

1.2.2 / 2014-06-05
[FEATURE] Return time taken by queries as time_ms on Searcher

1.2.1 / 2014-06-03
[BUGFIX] Fixed start of search offset

1.2.0 / 2014-06-03
[FEATURE] Support for 2013-01-01 version of cloudsearch API

1.1.2 / 2014-03-20
[BUGFIX] Encode ampersands

1.1.1 / 2014-01-25
[BUGFIX] Sort records into result order before returning

1.1.0 / 2014-01-24
[BUGFIX] Use 'type' and 'id' fields instead of deprecated med_ fields

0.2.0 / 2014-01-14
[FEATURE] Add support for retrying query

0.1.7 / 2013-12-13
[FEATURE] Added dry-run configuration option to prevent data being sent to 
          CloudSearch when indexing.

0.1.6 / 2013-11-05
[BUGFIX] Correctly ignore nil fields when indexing.

0.1.5 / 2013-11-05
[FEATURE] Ignore nil fields when indexing.

0.1.4 / 2013-11-05
[FEATURE] Added logging when indexing.

0.1.3 / 2013-10-31
[BUGFIX] Fix namespacing issue with ActiveSupport::String

0.1.2 / 2013-10-30
[BUGFIX] Convert EXCON ERROR to Inquisitio Error

0.1.1 / 2013-10-29 
[FEATURE] Add pagination methods to match Kaminari

0.1.0 / 2013-10-28
[BUGFIX] Parse ids properly.

0.0.13 / 2013-10-28
[FEATURE] Implement Searcher#records
[FEATURE] Implement Searcher#ids
[FEATURE] Allow for Array-style method iteration
[FEATURE] Changed syntax to match ActiveRecord style.

0.0.12 / 2013-10-24
[FEATURE] Allow filter values to be arrays.

0.0.12 / 2013-10-24
[FEATURE] Searcher now has default size read from configuration.
[FEATURE] Searcher now performs simple sanatization of search queries.

0.0.9 / Unreleased
[FEATURE] Searcher now has id, records and results.
[FEATURE] Refactor SearchUrlBuilder out of Searcher.

0.0.8 / 2013-10-23
[FEATURE] Extended searcher to handle arguments (for example, facet arguments).

0.0.7 / 2013-10-23
[FEATURE] Extended searcher to handle boolean queries.

0.0.6 / 2013-10-23
[FEATURE] Changed version of excon

0.0.5 / 2013-10-22
[FEATURE] Initial indexer created.

0.0.4 / 2013-10-22
[FEATURE] Return_fields is now optional in search call.

0.0.3 / 2013-10-21
[FEATURE] Added ability to perform search using Searcher class.

0.0.2 / 2013-10-21
[FEATURE] Added Document class representing AWS SDF document.

0.0.1 / 2013-10-21
[FEATURE] Added configuration, logger and error classes.
