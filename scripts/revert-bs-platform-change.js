#!/usr/bin/env node
var fs = require('fs');
var packageJson = JSON.parse(fs.readFileSync('./package.json'));
var depKey = 'devDependencies';
var bsPlatform = packageJson.devDependencies['bs-platform'];
if (!bsPlatform) {
  bsPlatform = packageJson.dependencies['bs-platform'];
  depKey = 'dependencies'
}
var match = bsPlatform.match(/\d+\.\d+\.\d+$/);
if (match && match[0] && match[0] !== bsPlatform) {
  var version = match[0];
  console.log(`Setting bs-platform version to ${version}`);
  packageJson[depKey]['bs-platform'] = version;
  fs.writeFileSync('./package.json', JSON.stringify(packageJson, null, indent=2));
} else {
  console.log(`No change needed to bs-platform version ${bsPlatform}`);
}
