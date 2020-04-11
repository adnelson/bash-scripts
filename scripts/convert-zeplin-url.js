#!/usr/bin/env node
const exitWith = msg => {
  console.error(msg);
  process.exit(1);
}

if(process.stdin.isTTY) exitWith("you must pass a URL via stdin");
const input = require('fs').readFileSync('/dev/stdin').toString();
const { protocol, query } = require('url').parse(input);
if (protocol !== 'zpl:') exitWith("Expected a URL starting with zpl://");
const queryDict = {};
query.split('&').forEach(q => {
  const [k, v] = q.split("=");
  queryDict[k] = v;
});
if (!('sid' in queryDict)) exitWith("No screen ID (sid) in URL");
if (!('pid' in queryDict)) exitWith("No project ID (pid) in URL");
console.log(`https://app.zeplin.io/project/${queryDict.pid}/screen/${queryDict.sid}`);
