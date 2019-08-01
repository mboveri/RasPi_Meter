FROM arm32v7/ruby:2.6
WORKDIR /opt/app

COPY src/Gemfile Gemfile
RUN bundle install 

COPY src/main.rb main.rb

ENTRYPOINT ["/usr/local/bin/ruby", "main.rb"]
