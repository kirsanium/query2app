*** Settings ***
Documentation   Basic CRUD operations
Library         RequestsLibrary
Suite Setup     Create Session  alias=api  url=${SERVER_URL}
Suite Teardown  Delete All Sessions

*** Variables ***
${SERVER_URL}  http://host.docker.internal:3000

** Test Cases ***
GET should return a value
    ${response}=                 Get Request  api  /v1/categories/count
    Status Should Be             200  ${response}
    Should Be Equal As Integers  0    ${response.json()}

POST should create an object
    &{payload}=                  Create Dictionary  name=Sport  slug=sport  userId=1
    ${response}=                 Post Request  api  /v1/categories  json=${payload}
    Status Should Be             204  ${response}
    # checks that it was created
    ${response}=                 Get Request  api  /v1/categories/count
    Status Should Be             200  ${response}
    Should Be Equal As Integers  1    ${response.json()}

PUT should update an object
    &{payload}=       Create Dictionary  name=Fauna  nameRu=Фауна  slug=fauna  userId=1  categoryId=1
    ${response}=      Put Request  api  /v1/categories/1  json=${payload}
    Status Should Be  204  ${response}

DELETE should remove an object
    ${response}=                 Delete Request  api  /v1/categories/1
    Status Should Be             204  ${response}
    # checks that it was removed
    ${response}=                 Get Request  api  /v1/categories/count
    Status Should Be             200  ${response}
    Should Be Equal As Integers  0    ${response.json()}
