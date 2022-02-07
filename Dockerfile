FROM node:latest
WORKDIR /
COPY package*.json app.js ./
RUN npm install
USER 1000
EXPOSE 3000
CMD ["node", "app.js"]
