# BluetoothTest
Sample for iOS10 Bluetooth bug.

A device in iOS 10 advertising a Bluetooth service, is not discovered by devices searching for that specific service after the app is moved to the background, even with the "bluetooth-peripheral" background mode capability.

This issue if only being manifested while the screen is unlocked, as after a few seconds that the screen is locked the device becomes discoverable again.

Steps to Reproduce:

You will need 2 devices to test these issue, let's call them device A and device B.
For this issue to be reproduced device B needs to have iOS 10, device A version does not matter. (Also it is useful to test with device B being iOS 9 or lower as the issue does not occur.)

1) Open app on both devices
2) On device A select "Scan" then "start".
3) On device B select "Advertise" then "start" (Accept the permission)
4) Verify that device A shows device B in the list (it is cleared and refresed every second).
5) Hit the home button on device B
6) On device A, device B should no longer appear (THIS IS THE BUG!!!)
7) Lock device B
8) Wait a few seconds and device B will now be discoverable again.
