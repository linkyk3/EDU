Projects from my Bachelor and Master Industrial Sciences at the VUB

## 3rd Bachelor:
### Databanken en Webtechnologie - Attendences Register Website
For the project of this course we had to design an application in the form of a website for registering attendences of different courses and subjects. The application includes a database, RESTful API and the site's frontend. SQLite is used for the database, Python for the backend and HTML/CSS for the frontend.

### Bachelorthesis - Roboball
As assignment we had to design and build a spherical robot that could move by modulating its mass. A well known example is the [Sphero](https://sphero.com/blogs/news/what-is-sphero) that uses a small, wheeled robot inside a shell that climbs up the walls and pushes them forward, causing the ball to roll. We were not allowed to copy this mechanism. These were the only design constrains that were given. We opted for an alternative method that used servo motors to control the rotation of the robot as well as the modulation of the mass, causing the robot to roll. In the report, all our design decisions, implementations and tests are explained.

## 1st Master:
### Computerarchitectuur - MIPS with UART Implementation in VHDL
In this project we implemented a basic MIPS processor in VHDL. The MIPS had to support the [core instruction set](https://inst.eecs.berkeley.edu/~cs61c/resources/MIPS_Green_Sheet.pdf). This allows the MIPS to run basic C programs like for loops, if statements, function calls, etc. A special feature also had to be present. We chose UART communication using Memory Mapped IO.

### Transmissietechnieken en Multimedia - MIVB/STIB Control App
For the multimedia part of this course we had to develop an Android app. [Back in 2014](https://www.nieuwsblad.be/cnt/dmf20140905_01252657) there was a popular app that allowed users to signal if there was a control happening at specific stops of the Brussels public transport system. This app was shut down a few years later. For this project we remade this app from scratch. The app uses the GPS of your phone to track the nearby stations and indicated if there is a control happening at the station. A Google Firestore database is used to save the stations where a control is happening so that the real-time data is available for multiple users. 
