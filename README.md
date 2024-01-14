To initiate the application, commence by constructing the `.jar` archive within the *application* folder using the following commands:

```bash
cd application/
./gradlew bootJar
```

Subsequently, launch both the application and the database within *Docker* through the following commands:

```bash
docker-compose build
docker-compose up
```

Upon successful startup of the application, gain access through the following [link](http://localhost:8080/).