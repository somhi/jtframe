#!/bin/bash
docker image build --file jtcore-base.df --tag jotego/jtcore-base .
docker image build --file jtcore13.df --tag jotego/jtcore13 /opt/altera
docker login
docker push jotego/jtcore-base:latest
docker push jotego/jtcore13:latest
