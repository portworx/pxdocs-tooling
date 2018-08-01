const fs = require('fs')
const path = require('path')
const atomicalgolia = require('./update')
const indexName = process.env.ALGOLIA_INDEX_NAME
const indexDataFilename = path.join(__dirname, process.env.ALGOLIA_INDEX_FILE)

const MAX_ALGOLIA_RECORD_SIZE = 20000

if(!indexName) {
  console.error(`ALGOLIA_INDEX_NAME required`)
  process.exit(1)
}

if(!indexDataFilename) {
  console.error(`ALGOLIA_INDEX_FILE required`)
  process.exit(1)
}

if(!fs.existsSync(indexDataFilename)) {
  console.error(`${indexDataFilename} file not found`)
  process.exit(1)
}

const indexData = require(indexDataFilename)

console.log(`${indexData.length} records found`)

const splitString = (string, size) => {
  const re = new RegExp('.{1,' + size + '}', 'gs')
  return string.match(re)
}

const processedIndexData = indexData.reduce((all, record) => {
  const recordString = JSON.stringify(record)

  if(recordString.length >= MAX_ALGOLIA_RECORD_SIZE - 100) {
    const contentString = record.content
    const metadataLength = recordString.length - contentString.length
    const allowedContentLength = MAX_ALGOLIA_RECORD_SIZE - metadataLength - 100

    const contentChunks = splitString(contentString, allowedContentLength)

    contentChunks.forEach((chunk, i) => {
      const newRecord = Object.assign({}, record)
      newRecord.objectID = `${record.objectID}-${i}`
      newRecord.content = chunk

      all.push(newRecord)
    })

    console.log(`record content too big: ${record.objectID} -> ${record.sectionTitles} -> ${record.title}`)
    console.log(`original record is ${contentString.length} bytes - record metadata is ${metadataLength}`)
    console.log(`allowed record size is: ${MAX_ALGOLIA_RECORD_SIZE} - allowed content size is ${allowedContentLength}`)
    console.log(`split into ${contentChunks.length} chunks with the following lengths: ${contentChunks.map(chunk => chunk.length).join(', ')}`)
  }
  else {
    all.push(record)
  }
  return all
}, [])

console.log(`${processedIndexData.length} records to index after processing`)

atomicalgolia(indexName, processedIndexData, {verbose: true}, (error, result) => {
  if(error) {
    console.error(error)
    process.exit(1)
  }

  console.log(result)
})