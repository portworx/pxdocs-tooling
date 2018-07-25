### algolia

We use [algolia](https://www.algolia.com/) to power the search.

The JSON index that is used to populate the algolia index is [here](layouts/_default/list.algilia.json).  When a hugo build is done - this will produce `public/algolia.json` that contains the records we will upload.

Then we use the [atomic-algoila](https://www.npmjs.com/package/atomic-algolia) node package that will upload the records to the index we use for searching.

You should set the following environment variables to power this:

 * `ALGOLIA_ADMIN_KEY` - the algolia admin key - used for writing records
 * `ALGOLIA_API_KEY` - the algolia api key - public, used for reading records
 * `ALGOLIA_APP_ID` - the algolia app that contains all indexes
 * `ALGOLIA_INDEX_NAME` - the index name for this build
 * `ALGOLIA_INDEX_FILE` - the JSON file to upload into the index

It is important that each branch build uses a different index name so results from one branch don't pollute another branch.

When doing a hugo build - it will need to have the following variables set:

 * `ALGOLIA_APP_ID`
 * `ALGOLIA_API_KEY`
 * `ALGOLIA_INDEX_NAME`

To upload the new algolia index for a given build - run the following from within the pxdocs repo:

```bash
make search-index
```
