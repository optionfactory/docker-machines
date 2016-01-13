
DOCKER_BUILD_OPTIONS=--no-cache=false


.PHONY: all docker-image

docker-images: docker-optionfactory-ubuntu-jdk docker-optionfactory-ubuntu-tomcat


docker-optionfactory-ubuntu-jdk: docker-image
	docker build ${DOCKER_BUILD_OPTIONS} --tag=optionfactory/ubuntu-jdk:0.1 optionfactory-ubuntu-jdk
	docker tag -f optionfactory/ubuntu-jdk:0.1 optionfactory/ubuntu-jdk:latest

docker-optionfactory-ubuntu-tomcat: docker-image
	docker build ${DOCKER_BUILD_OPTIONS} --tag=optionfactory/ubuntu-tomcat:0.1 optionfactory-ubuntu-tomcat
	docker tag -f optionfactory/ubuntu-tomcat:0.1 optionfactory/ubuntu-tomcat:latest
