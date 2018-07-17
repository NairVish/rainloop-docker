# Docker image for RainLoop

This is a minimal Docker image for the RainLoop webmail client built off of the [php:7.2.7-apache-stretch](https://hub.docker.com/_/php/) image. It contains the latest version of RainLoop (1.12.0 at the time of writing) and contains slightly more hardened PHP and Apache2 configurations than the base image.

To use it, simply run `docker compose up -d` in the working directory of this repo.
