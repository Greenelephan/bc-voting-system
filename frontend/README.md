# frontend

Flutter frontend to the blockchain election system.

## Installation

For installation follow the instructions on the [oficial Website](https://docs.flutter.dev/get-started/install).

## Usage

To start the Webserver navigate to the frontend Folder

`cd frontend`

Then use the run command to run the app.

Note: this will not work if you haven't started the Backend yet.

`flutter run -d web-server --web-port=4040`

You will be asked to choose a device to run on. Choose ons to open it on your device. 

Now you can use the Following commands:

r - hot reload

R - hot Refresh

h - show commands

d - detatch. Terminates the application without closing your chosen device.

q - terminate the application



## Structure of the source code

You can find all the sourcecode in the **lib** folder.

There the application is structured in:

- **localisations:** the language package
- **providers:** ressources used all over the application
- **services:** Tasks to run in the Background
- **views:** files containing the visual structure, pages and navigation
- **wigets:** files containing the functions of a page such as API calls and files cotaining costom widgets such as custom buttons


