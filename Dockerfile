FROM node:22-alpine3.19 AS builder
WORKDIR /live-app
COPY . .
RUN npm ci --silent
RUN npm run build

FROM node:22-alpine3.19  AS runner
WORKDIR /live-app

COPY --from=builder /live-app/.next /live-app/.next
COPY --from=builder /live-app/node_modules /live-app/node_modules
COPY --from=builder /live-app/package.json /live-app/package.json

# Questões de segurança, dependendo da aplicação NÃO rodar como "root"
RUN addgroup -g 1001 -S nonroot\
    && adduser -u 1002 -S nonroot -G nonroot

USER nonroot
ENV PORT 80
EXPOSE 80
ENTRYPOINT [ "npm", "start" ]