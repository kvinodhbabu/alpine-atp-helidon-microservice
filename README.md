# ATPDocker
Create/Deploy apps with docker and using Cloud Native Development to connect Oracle Autonomous Transaction Processing Database.

Build docker images configured to run node.js apps on Oracle autonomous Databases.

To build a docker image, 

1. Clone repository to your local machine
2. Provision an Oracle Autonomous Transaction Processing (ATP) database in the Oracle Cloud. Download the credentials zip file
3. Unzip the database credentials zip file wallet_XXXXX.zip in the same folder as your Dockerfile
4. Install docker on your local machine if it doesn't exist
5. build Dockerfile - $docker build -t aone .
6. Launch container mapping local port to 3050 -- $docker run -i -p 3050:3050 -t nodeapp
7. Assumption is there exists a table EMP in ATP Database
8. check out using curl -XGET http://localhost:3050/atp/emp
# alpine-atp-helidon-microservice
