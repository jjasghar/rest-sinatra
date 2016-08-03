require 'sinatra'
require 'sinatra/json'
require 'bundler'

Bundler.require

require 'review'

DataMapper.setup(:default, 'sqlite::memory:')
DataMapper.finalize
DataMapper.auto_migrate!

get '/' do
  'Hello World!'
end

# get all the reviews
get '/reviews' do
  content_type :json

  reviews = Review.all
  reviews.to_json
end

# get a specific review
# curl -d "review[name]=Hello&review[text]=World" http://localhost:4567/reviews
# curl localhost:4567/reviews/1
# {"id":1,"name":"Hello","text":"World","created_at":"2016-08-03T13:49:29-05:00","updated_at":"2016-08-03T13:49:29-05:00"}13:49:31
get '/reviews/:id' do
  content_type :json
  review = Review.get params[:id]
  review.to_json
end

# 'inject' a review
# curl -d "" http://localhost:4567/reviews # should give you an error
# curl -d "review[name]=Hello&review[text]=World" http://localhost:4567/reviews # should inject hello world
# curl localhost:4567/reviews # should output something like the following
# [{"id":1,"name":"Hello","text":"World","created_at":"2016-08-03T13:41:03-05:00","updated_at":"2016-08-03T13:41:03-05:00"}]
post '/reviews' do
  content_type :json
  review = Review.new params[:review] # create in the review namespace
  if review.save
    status 201 # the exact status code to say resource has been created
  else
    status 500 # means server error
    json review.errors.full_messages
  end
end

# 'update' a specific review
# curl -d "review[name]=Hello&review[text]=World" http://localhost:4567/reviews # should inject hello world
# curl -X PUT -d "review[name]=Goodbye" http://localhost:4567/reviews/1
# curl localhost:4567/reviews # should output something like the following
# [{"id":1,"name":"Goodby","text":"World","created_at":"2016-08-03T13:41:03-05:00","updated_at":"2016-08-03T13:41:03-05:00"}]
put '/reviews/:id' do
  content_type :json
  review = Review.get params[:id]
  if review.update params[:review]
    status 200
    json "Review was updated."
  else
    status 500
    json review.errors.full_messages
  end
end

# delete a specific review
# curl -X DELETE localhost:4567/reviews/1
# "Review was removed."
delete '/reviews/:id' do
  content_type :json
  review = Review.get params[:id]
  if review.destroy
    status 200
    json "Review was removed."
  else
    status 500
    json "There was a problem removing the review."
  end
end
