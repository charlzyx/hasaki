# clone ui dist from git
FROM alpine/git as repo
RUN rm -rf /ui
RUN git clone https://github.com/charlzyx/hasaki-ui.git /ui

FROM node:15.0.1-alpine as pkg
COPY --from=repo /ui /ui
RUN cd ui && yarn && npm run build

# build openresty
FROM openresty/openresty:alpine

VOLUME /hasaki

ADD ./conf /usr/local/openresty/nginx/conf
ADD ./html /usr/local/openresty/nginx/html
ADD /settings /hasaki
COPY --from=pkg /ui/dist /usr/local/openresty/nginx/html/__hasaki__

RUN ["openresty"]
# 对外暴露端口 80
EXPOSE 80
