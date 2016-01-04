# HashtagDetector
Hashtag Detector for iOS

A project demonstrating how a user can type anything including hashtags into a text view 
and on retrieval of this string, we can parse out official hashtag values. These hashtags 
follow the business rules of Twitter, so it is easily adoptable for your app if you want 
to use hashtags for user input

## Usage

Since this is a project, you can simply download and run this code on the simulator (or to 
your device). When the app has loaded, you just type in anything into the text view, including
hashtags. Once you are done entering text, tap the "Done" key on the keyboard.

You will be taken to another page that has parsed out the hashtags, and make them into blue (or
a color of your choice). These blue hashtags are now tappable, and developers can customize the
behavior and logic when they are tapped.

Examples:

Entering info:

	Hello #world. How are you doing today? #awesomesauce #hashtags #hashtagdetector

Will result in 4 hashtags. Each will have an independant tap area.

	Hello#World   #!@@   

are two examples of invalid hashtags

You can download and see the Project for usages.

## Notes
Requires iOS 8 or greater. Written in Swift 2.0