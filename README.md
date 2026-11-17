# Application Tracker

A tiny native Mac app to keep track of job applications: who you applied to, whether they answered, and a few notes. No account, no cloud, no network. Your data stays on your Mac.

- One list of applications with six statuses: To apply, Sent, Got a reply, Interview, Rejected, Offer
- A note and a link per application
- Four counters: total, sent, replies (any answer, including rejections and offers), interviews
- Every change is saved the moment you make it, so closing the laptop or quitting the app never loses anything

Needs macOS 14 (Sonoma) or newer on a Mac with Apple Silicon.

## Install

Open Terminal and run:

```sh
curl -fsSL https://raw.githubusercontent.com/lukasheinichschnittstelle-lgtm/application-tracker/main/install.sh | bash
```

The app lands in `~/Applications` and starts. You can read [install.sh](install.sh) first; it is short.

## Update

Run the same command again. It quits the app, replaces it with the newest version and starts it. Your data is not touched.

## Your data

Everything lives in one file:

```
~/Library/Application Support/Application Tracker/applications.json
```

- **Show Data in Finder** (File menu) opens that folder.
- On every start the app keeps a copy of the last good file as `applications.backup.json`.
- If the file can't be read, the app never overwrites it. It moves it aside as `applications.unreadable-<date>.json` and tells you.
- To back up by hand, copy `applications.json` somewhere safe. To restore, quit the app and copy it back.

## Uninstall

```sh
rm -rf ~/Applications/"Application Tracker.app"
# and, only if you also want to delete your data:
rm -rf ~/Library/Application\ Support/"Application Tracker"
```

## Build

The app is a Swift package without an Xcode project. GitHub Actions tests and builds it on every push; a tag `v*` publishes a release.

```sh
swift test                      # on a Mac
scripts/build-app.sh 0.1.0      # builds build/ApplicationTracker.zip
```

## License

Code: [MIT](LICENSE). Fonts: [Archivo](Resources/Fonts/OFL-Archivo.txt) and [Geist](Resources/Fonts/OFL-Geist.txt), both under the SIL Open Font License 1.1.
