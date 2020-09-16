FROM mhart/alpine-node:8
LABEL maintainer="nathaniel.wilson@portworx.com"
RUN apk update
RUN apk upgrade
RUN apk add bash git
WORKDIR /app/indexer
COPY ./package.json /app/indexer/package.json
COPY ./package-lock.json /app/indexer/package-lock.json
RUN npm cache clean --force
RUN npm install
COPY . /app/indexer
ENTRYPOINT ["npm", "run"]
CMD ["algolia"]