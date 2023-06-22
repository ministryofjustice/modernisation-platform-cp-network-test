apiVersion: apps/v1
kind: Deployment
metadata:
  name: nettest
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nettest
  template:
    metadata:
      labels:
        app: nettest
    spec:
      containers:
        - name: nettest
          image: ${ECR_URL}:${IMAGE_TAG}
          ports:
            - containerPort: 3000
          imagePullPolicy: Always
