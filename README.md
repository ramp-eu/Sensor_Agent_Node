# TrySmart
# **S**ensor **A**gent **N**ode - SAN
- **S**ensor **A**gent **N**ode - SAN

  - [Background](#background)
  - [Components Description](#Components_Description)
    - [Black box of SAN](#Black_box_of_SAN)
  - [Prerequisites](#prerequisites)
  - [Install](#install)
  - [Configuration](#configuration)
    - [Step1](#step1)
    - [Step2](#step2)
  - [Interfaces](#interfaces)
    - [I1](#I1)
    - [I1](#I1)
  - [License](#license)
 ## Background
[OPIL](https://opil-documentation.readthedocs.io/) is the Open Platform for Innovations in Logistcs. This platform is meant to enable the development of value added services for the logistics sector in small-scale Industry 4.0 contexts such as those of manufacturing SMEs. In fact, it provides an easy deployable suite of applications for rapid development of complete logistics solutions, including components for task scheduling, path planning, automatic factory layout generation and navigation.

[Esthesis](https://github.com/esthesis-iot) is a modern Internet of Things platform, providing end-to-end management services for your devices. It consists of device management functionality, over-the-air firmware upgrade services, and a modular data-management approach. Built-in support for certificates and certificate authorities allows you to effortlessly set up a secure communication environment with your devices where provisioning packages can be signed and/or encrypted on the fly.

The **SAN** is located between OPIL and the sensor software and it is a extension of Esthesis platform. It's main features- advantages are:
**a**)Supports sensors and actuators (Input and output sensors).
**b**)Drivers of the sensors and actuators can be written in any prefered/suitable programming language(can use existing drivers), given that at the end the data are sent/retrieved through mqtt protocol, no restriction other than this.
**c**) Monitors health of host device(Disk space usage,Memory usage,Restart services, check logs for each running service,Monitor CPU temperature
).
**d**)Can be deployed to any host machine that supports java language, eg single board computers like  rpi, revpi or any other.






## Components_Description

```python

```
### Black_box_of_SAN

![Black Box of SAN](images/black%20box.PNG)

## Prerequisites

## Install

## Configuration

## Interfaces

## License

[APACHE2](LICENSE) ©
