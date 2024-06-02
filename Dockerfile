# Dockerfile

# ベースイメージとしてrubyを使用
FROM ruby:3.3.0

# Node.jsをインストール
RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash - && apt-get install -y nodejs

# install yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && apt update && apt install -y yarn

# その他ツールインストール
RUN apt-get update && apt-get install -y vim graphviz imagemagick

# 作業ディレクトリを作成
WORKDIR /webapp

# ホストのGemfileとGemfile.lockをコンテナにコピー
COPY Gemfile /webapp/Gemfile
COPY Gemfile.lock /webapp/Gemfile.lock

# bundle installの実行
RUN bundle install -j4

# package.jsonとyarn.lockをコピーしてyarn installを実行
COPY package.json /webapp/package.json
COPY yarn.lock /webapp/yarn.lock
RUN yarn install

# ホストのアプリケーションディレクトリ内をすべてコンテナにコピー
COPY . /webapp

# ポートを公開
EXPOSE 3000

# サーバーの起動
CMD ["bash", "-c", "rm -f tmp/pids/server.pid && bundle exec puma -C config/puma.rb"]
