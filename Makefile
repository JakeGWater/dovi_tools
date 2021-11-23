.PHONY: docker clean dovi_tool shell

USER=$(shell whoami)
HOME=/Users/${USER}
DOWNLOADS=${HOME}/Downloads
HERE=$(shell pwd)
DOCKER_IMG_NAME=dovi
DOCKER=docker run -e HOME=${HOME} -it -v ${HERE}:/${HERE} -v ${DOWNLOADS}:/${DOWNLOADS} -w ${HERE} ${DOCKER_IMG_NAME}
DOVI_TOOL=dovi_tool/target/debug/dovi_tool
CHECK_DOCKER=var/.checkpoint-docker-image-done

dovi_too:
	${DOCKER} ${DOVI_TOOL}
shell:
	${DOCKER} bash
%.json: %.bin ${CHECK_DOCKER}
	${DOCKER} ${DOVI_TOOL} info -f 0 -i $< | tail -n +2 > $@ 
%.bin: %.hevc ${CHECK_DOCKER}
	${DOCKER} ${DOVI_TOOL} extract-rpu -i $< -o $@
%.hevc: %.MOV ${CHECK_DOCKER}
	${DOCKER} ffmpeg -i $< -c:v copy -vbsf hevc_mp4toannexb -f hevc $@
${CHECK_DOCKER}:
	docker build -t ${DOCKER_IMG_NAME} docker
	touch $@
docker: ${CHECK_DOCKER}
clean: 
	rm -rf var/.checkpoint*
	rm var/*.json
