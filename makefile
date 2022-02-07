IMAGE := ministryofjustice/modernisation-platform-nettest
TAG := 1.0

.built-image: Dockerfile package.json makefile
	docker build -t $(IMAGE) .
	touch .built-image

push: .built-image
	docker tag $(IMAGE) $(IMAGE):$(TAG)
	docker push $(IMAGE):$(TAG)
