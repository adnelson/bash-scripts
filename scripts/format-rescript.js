#!/usr/bin/env node
/* eslint-disable no-console */
const { basename } = require("path");
const { existsSync, readFileSync, writeFileSync, lstatSync } = require("fs");
const { execSync } = require("child_process");
const fileNames = process.argv.slice(2);

if (!fileNames.length) {
  throw new Error(`Usage: ${basename(__filename)} <fileName> [<fileName>...]`);
}

let hasError = false;
let formatter;
if (existsSync("package.json")) {
  const packageJson = JSON.parse(readFileSync('./package.json', 'utf-8'));
  const dependencies = {
    ...(packageJson.dependencies ?? {}),
    ...(packageJson.devDependencies ?? {})
  }
  if (dependencies.rescript) {
    formatter = fileName => {
      try {
        execSync(`node_modules/.bin/rescript format ${fileName}`)
        console.log("Formatted", fileName);
      } catch {
        hasError = true
      }
    }
  } else if (dependencies["bs-platform"]) {
    formatter = fileName => {
      const contents = readFileSync(fileName).toString();

      try {
        const formattedCode = execSync(`node_modules/.bin/bsc -format ${fileName}`);
        if (formattedCode !== contents) {
          writeFileSync(fileName, formattedCode);
          console.log("Formatted", fileName);
        }
      } catch {
        hasError = true;
      }
    }
  }
}

if (!formatter) {
  throw "Couldn't find formatter based on package.json"
}

fileNames.forEach(fileName => {
  if (!fileName.endsWith(".res")) {
    throw new Error(`Not a rescript file: ${fileName}`);
  }

  if (lstatSync(fileName).isSymbolicLink()) {
    console.log(`Ignoring symlink ${fileName}`);
    return;
  }

  formatter(fileName)
});

if (hasError) {
  process.exit(1);
}
