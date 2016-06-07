
DOCKER_BUILD_OPTIONS=--no-cache=false


.PHONY: docker-image


docker-images: $(addprefix docker-,$(wildcard optionfactory-*))


docker-optionfactory-%: docker-image
	$(eval name=$(subst docker-optionfactory-,,$@))
	docker build ${DOCKER_BUILD_OPTIONS} --tag=optionfactory/$(name):0.1 optionfactory-$(name)
	docker tag optionfactory/$(name):0.1 optionfactory/$(name):latest


docker-image:
	echo optionfactory-*-jdk | xargs -n 1 cp install-jdk.sh
	echo optionfactory-*-tomcat | xargs -n 1 cp install-tomcat.sh
	echo optionfactory-*-wildfly | xargs -n 1 cp install-wildfly.sh
	echo optionfactory-*-jdk optionfactory-*-db2 optionfactory-*-mariadb | xargs -n 1 cp install-ps1.sh
	echo optionfactory-*-jdk optionfactory-*-db2 optionfactory-*-mariadb | xargs -n 1 cp install-spawn-and-tail.sh
	echo optionfactory-*-alfresco | xargs -n 1 cp install-alfresco.sh
	#echo optionfactory-*-db2 | xargs -n 1 cp install-db2.sh
        

clean:
	rm -rf optionfactory-*/install-*.sh
