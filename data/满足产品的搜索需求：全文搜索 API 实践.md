DELETE books

PUT books
{
  "mappings": {
    "properties": {
        "book_id": {
          "type": "keyword"
        },
        "name": {
          "type": "text",
          "analyzer": "standard"
        },
        "author": {
          "type": "keyword"
        },
        "intro": {
          "type": "text"
        },
        "price": {
          "type": "double"
        },
        "date": {
          "type": "date"
        }
      }
  },
  "settings": {
    "number_of_shards": 3,
    "number_of_replicas": 1
  }
}

PUT books/_doc/1
{
  "book_id": "4ee82462",
  "name": "Dive into the Linux kernel architecture",
  "author": "Wolfgang Mauerer",
  "intro": "The content is comprehensive and in-depth, appreciate the infinite scenery of the Linux kernel.",
  "price": 19.9,
  "date": "2010-06-01"
}

PUT books/_doc/2
{
  "book_id": "4ee82463",
  "name": "A Brief History Of Time",
  "author": "Stephen Hawking",
  "intro": "A fascinating story that explores the secrets at the heart of time and space.",
  "price": 9.9,
  "date": "1988-01-01"
}

PUT books/_doc/3
{
  "book_id": "4ee82464",
  "name": "Beginning Linux Programming 4th Edition",
  "author": "Neil Matthew、Richard Stones",
  "intro": "Describes the Linux system and other UNIX-style operating system on the program development",
  "price": 12.9,
  "date": "2010-06-01"
}