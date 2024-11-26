FROM node:22-alpine3.19 AS build

WORKDIR /usr/src/app

COPY package.json yarn.lock .yarnrc.yml .env.prod ./
COPY prisma ./prisma
COPY .yarn ./.yarn

RUN yarn

COPY . .

RUN yarn run build
RUN yarn workspaces focus --production && yarn cache clean

FROM node:22-alpine3.19

WORKDIR /usr/src/app

COPY --from=build /usr/src/app/package.json ./package.json
COPY --from=build /usr/src/app/dist ./dist
COPY --from=build /usr/src/app/node_modules ./node_modules
COPY --from=build /usr/src/app/.env.prod ./.env
COPY --from=build /usr/src/app/prisma ./prisma



EXPOSE 3000

CMD ["npm", "run", "start:prod"]
