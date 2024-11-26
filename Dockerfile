FROM node:18-alpine3.19 AS build

WORKDIR /usr/src/app

RUN corepack enable && corepack prepare yarn@4.5.1 --activate

COPY package.json yarn.lock .yarnrc.yml .env.prod ./
COPY .yarn ./.yarn

RUN yarn

COPY . .

RUN yarn run build
RUN yarn workspaces focus --production && yarn cache clean
RUN yarn prisma generate

FROM node:18-alpine3.19

WORKDIR /usr/src/app

COPY --from=build /usr/src/app/package.json ./package.json
COPY --from=build /usr/src/app/dist ./dist
COPY --from=build /usr/src/app/node_modules ./node_modules
COPY --from=build /usr/src/app/.env.prod ./.env


EXPOSE 3000

CMD ["npm", "run", "start:prod"]
