# Dev image for heighliner: serves the site with `weaver preview`.
FROM ruby:4.0

# index.weave contains non-ASCII text ("résumé")
ENV LANG=C.UTF-8

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

EXPOSE 4567
CMD ["bundle", "exec", "weaver", "preview"]
