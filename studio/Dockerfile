FROM node:20-alpine
WORKDIR /app
COPY package.json ./
RUN npm install --omit=dev dotenv express mysql2
COPY src ./src
COPY public ./public
RUN mkdir -p data
ENV NODE_ENV=production
ENV PORT=3000
EXPOSE 3000
CMD ["node", "src/server.js"]
