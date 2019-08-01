FROM arm64v8/ruby:2.6-alpine
WORKDIR /opt/app

COPY src/Gemfile Gemfile
RUN bundle install 

COPY src/main.rb main.rb

ENTRYPOINT ["/usr/local/bin/ruby", "main.rb"]
