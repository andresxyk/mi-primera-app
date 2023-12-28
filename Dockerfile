# Stage 1: Compile and Build angular codebase

# Use official node image as the base image
FROM image-registry.openshift-image-registry.svc:5000/openshift/nodejs:16-ubi9 as builder

# Set the working directory
WORKDIR /app

USER root
#RUN ls -lrt
# Add the source code to app
COPY package.json ./

# Install all the dependencies
RUN npm install
RUN npm install -g @angular/cli

COPY . .

#genera dist
#RUN mkdir /dist
RUN --from=builder pwd
# Generate the build of the application
RUN npm run build -- --configuration production --output-path=./dist
#WORKDIR /dist
#RUN pwd
#RUN ls -lrt
# Stage 2: Serve app with nginx server

# Use official nginx image as the base image
FROM image-registry.openshift-image-registry.svc:5000/openshift/nginx:1.20-ubi7

# TEST
USER root

COPY nginx.conf /etc/nginx/nginx.conf

# RUN rm -rf /usr/share/nginx/html/*
# COPY --from=builder /dist /usr/share/nginx/html
RUN chmod 777 /opt/app-root/src
RUN rm -rf /opt/app-root/src/*
COPY --from=builder --chmod=777 ./dist /opt/app-root/src
RUN ls -lrt

# Expose port 8080
EXPOSE 8080

ENTRYPOINT ["nginx", "-g", "daemon off;"]
