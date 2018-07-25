FROM mhart/alpine-node:8
MAINTAINER kaiyadavenport@gmail.com
RUN apk update
RUN apk upgrade
RUN apk add bash git
WORKDIR /app/indexer
COPY ./package.json /app/indexer/package.json
COPY ./yarn.lock /app/indexer/yarn.lock
RUN yarn install
COPY ./hugo_public /app/indexer/public
ENTRYPOINT ["npm", "run"]
CMD ["algolia"]