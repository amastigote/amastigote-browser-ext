# amastigote-browser-ext

Basically functional browser extension for amastigote open version.

## Server Installation/Deployment/Development

Please move steps to [amastigote-openserver](https://github.com/amastigote/amastigote-openserver).

## Install

- Firefox 54.0 or higher(lower?) version is required.
- Current version is not published, so you have to install without verification.
```
a) Download and unzip the ZIP file
b) Compress amastigote-browser-ext-master/ as {whatever}.zip (make sure the ZIP file directly contains several extension files instead of a directory)
b) Visit 'about:config'
c) Double click 'xpinstall.signatures.required' to set it to false
d) Visit 'about:addons'
e) Choose {whatever}.zip in 'Install Addon From File'
f) Configure server ip/address & port(running at 8080 in default)
```

## Debug

- Firefox 54.0 or higher(lower?) version is required.
- Extension installed in debug mode needs reinstallation each time the browser is restarted.
```
a) Visit 'about:debugging'
b) Press 'Load Temporary Add-on'
c) Choose manifest.json
d) Open extension preference page through 'Menu - Add-ons' or extension panel
e) Configure server ip/address & port(running at 8080 in default)
```

## Screenshots
### Extension Panel
![](https://github.com/amastigote/amastigote-browser-ext/blob/master/art/ext-panel.png)

### Bundled Web UI
![](https://github.com/amastigote/amastigote-browser-ext/blob/master/art/page.png)
![](https://github.com/amastigote/amastigote-browser-ext/blob/master/art/page-edit.png)
