FROM node:24-alpine AS base
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"

FROM base AS build
WORKDIR /app
COPY . /app

RUN corepack enable
RUN apk add --no-cache python3 alpine-sdk

RUN pnpm install --prod --frozen-lockfile

RUN pnpm deploy --filter=@imput/cobalt-api --prod /prod/api

FROM base AS api
WORKDIR /app

COPY --from=build --chown=node:node /prod/api /app

RUN apk add --no-cache git && \
    git -c user.email="cobalt@cobalt" -c user.name="cobalt" init && \
    git -c user.email="cobalt@cobalt" -c user.name="cobalt" commit --allow-empty -m "cobalt"

USER node

EXPOSE 9000
CMD [ "node", "src/cobalt" ]
