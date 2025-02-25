# Query To App
Generates the endpoints (or a whole app) from a mapping (SQL query -> URL)

>:warning: This is a proof of concept at this moment. Until it reaches a stable version, it might (and will) break a compatibility.

# How to use

1. Navigate to a project catalog
   ```console
   $ mkdir new-project
   $ cd new-project
   ```

1. Create a mapping file `endpoints.yaml`
   ```console
   $ vim endpoints.yaml
   - path: /v1/categories
     get_list:
       query: >-
         SELECT id, name, name_ru, slug
           FROM categories
     post:
       query: >-
         INSERT INTO categories(name, slug, created_at, created_by, updated_at, updated_by)
         VALUES (:b.name, :b.slug, NOW(), :b.user_id, NOW(), :b.user_id)

   - path: /v1/categories/:categoryId
     get:
       query: >-
         SELECT id, name, name_ru, slug
           FROM categories
          WHERE id = :p.categoryId
     put:
       query: >-
         UPDATE categories
            SET name = :b.name, name_ru = :b.name_ru, slug = :b.slug, updated_at = NOW(), updated_by = :b.user_id
          WHERE id = :p.categoryId
     delete:
       query: >-
         DELETE
           FROM categories
          WHERE id = :p.categoryId
   ```
   Note that the queries use a little unusual named parameters: `:b.name`, `:p.categoryId`, etc The prefixes `b` (body) and `p` (path) are used here in order to bind to parameters from the appropriate sources. The prefixes are needed only during code generation and they will absent from the resulted code.

1. Generate code   
   | Language   | Command for code generation | Example of generated files | Libraries |
   | -----------| ----------------------------| ---------------------------| --------- |
   | JavaScript | `npx query2app --lang js`   | [`app.js`](examples/js/app.js)<br/>[`routes.js`](examples/js/routes.js)<br/>[`package.json`](examples/js/package.json) | Web: [`express`](https://www.npmjs.com/package/express), [`body-parser`](https://www.npmjs.com/package/body-parser)<br>Database: [`mysql`](https://www.npmjs.com/package/mysql) |
   | Golang     | `npx query2app --lang go`   | [`app.go`](examples/go/app.go)<br/>[`routes.go`](examples/go/routes.go)<br/>[`go.mod`](examples/go/go.mod) | Web: [`go-chi/chi`](https://github.com/go-chi/chi)<br/>Database: [`go-sql-driver/mysql`](https://github.com/go-sql-driver/mysql), [`jmoiron/sqlx`](https://github.com/jmoiron/sqlx) |
   | Python     | `npx query2app --lang python` | [`app.py`](examples/python/app.py)<br/>[`routes.py`](examples/python/routes.py)<br/>[`requirements.txt`](examples/python/requirements.txt) | Web: [FastAPI](https://github.com/tiangolo/fastapi), [Uvicorn](https://www.uvicorn.org)<br/>Database: [psycopg2](https://pypi.org/project/psycopg2/) |

1. Run the application
   | Language   | Commands to run the application |
   | -----------| --------------------------------|
   | JavaScript | <pre>$ npm install<br/>$ export DB_NAME=my-db DB_USER=my-user DB_PASSWORD=my-password<br/>$ npm start</pre> |
   | Golang     | <pre>$ go run *.go</pre>or<pre>$ go build -o app<br/>$ ./app</pre> |
   | Python     | <pre>$ pip install -r requirements.txt<br/>$ export DB_NAME=my-db DB_USER=my-user DB_PASSWORD=my-password<br/>$ uvicorn app:app</pre> |
   
   ---
   :bulb: **NOTE**
   
   While the example used `export` for setting up the environment variables, we don't recommend export variables that way! This was provided as an example to illustrate that an application follows [The Twelve Factors](https://12factor.net/config) and can be configured by passing environment variables. In real life, you will use docker, docker-compose, Kubernetes or other ways to run an app with required environment variables.
   
   ---
   :bulb: **NOTE**
   
   An app also supports other environment variables:
   
   * `PORT`: a port to listen (defaults to `3000`)
   * `DB_HOST` a database host (defaults to `localhost`)
   
   ---

1. Test that it works
   ```console
   $ curl -i -H 'Content-Type: application/json' -d '{"name":"Sport","name_ru":"Спорт","slug":"sport","user_id":100}' http://localhost:3000/v1/categories
   HTTP/1.1 204 No Content
   ETag: W/"a-bAsFyilMr4Ra1hIU5PyoyFRunpI"
   Date: Wed, 15 Jul 2020 18:06:33 GMT
   Connection: keep-alive
   $ curl http://localhost:3000/v1/categories
   [{"id":1,"name":"Sport","name_ru":"Спорт","slug":"sport"}]
   $ curl -i -H 'Content-Type: application/json' -d '{"name":"Fauna","name_ru":"Фауна","slug":"fauna","user_id":101}' -X PUT http://localhost:3000/v1/categories/1
   HTTP/1.1 204 No Content
   ETag: W/"a-bAsFyilMr4Ra1hIU5PyoyFRunpI"
   Date: Wed, 15 Jul 2020 18:06:34 GMT
   Connection: keep-alive
   $ curl http://localhost:3000/v1/categories/1
   {"id":1,"name":"Fauna","name_ru":"Фауна","slug":"fauna"}
   $ curl -i -X DELETE http://localhost:3000/v1/categories/1
   HTTP/1.1 204 No Content
   ETag: W/"a-bAsFyilMr4Ra1hIU5PyoyFRunpI"
   Date: Wed, 15 Jul 2020 18:06:35 GMT
   Connection: keep-alive
   ```
